/**
 * Generate Firebase Admin service account key (via logged-in Firebase CLI)
 * and push FIREBASE_* env vars to Render.
 *
 * Usage: node scripts/setup-firebase-render.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { createRequire } from "module";

const require = createRequire(import.meta.url);
const firebaseToolsRoot = path.join(
  path.dirname(process.execPath),
  "node_modules",
  "firebase-tools",
);
const auth = require(path.join(firebaseToolsRoot, "lib/auth"));
const scopes = require(path.join(firebaseToolsRoot, "lib/scopes"));

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROJECT_ID = "moozhayil-prod";
const SERVICE_ID = "srv-dammuh61egvs73csp3ng";
const SA_PATH = path.join(ROOT, "apps/api/firebase-service-account.json");
const ENV_FILE = path.join(ROOT, "PRODUCTION_ENV.txt");
const KEY_FILE = path.join(ROOT, ".render-api-key");

async function getAccessToken() {
  const account = auth.getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error("Firebase CLI not logged in. Run: firebase login");
  }
  const authScopes = [scopes.CLOUD_PLATFORM];
  const tokens = await auth.getAccessToken(
    account.tokens.refresh_token,
    authScopes,
  );
  if (!tokens?.access_token) {
    throw new Error("Failed to obtain Firebase access token");
  }
  return tokens.access_token;
}

async function findFirebaseAdminServiceAccount(accessToken) {
  const url = `https://iam.googleapis.com/v1/projects/${PROJECT_ID}/serviceAccounts`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`List service accounts failed (${res.status}): ${body}`);
  }
  const data = await res.json();
  const accounts = data.accounts ?? [];
  const adminSdk = accounts.find((a) =>
    a.email?.includes("firebase-adminsdk"),
  );
  if (!adminSdk?.email) {
    throw new Error(
      "No firebase-adminsdk service account found. Enable Firebase in console first.",
    );
  }
  return adminSdk.email;
}

async function createServiceAccountKey(accessToken, serviceAccountEmail) {
  const encoded = encodeURIComponent(serviceAccountEmail);
  const url = `https://iam.googleapis.com/v1/projects/${PROJECT_ID}/serviceAccounts/${encoded}/keys`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({}),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Create service account key failed (${res.status}): ${body}`);
  }
  const data = await res.json();
  const json = Buffer.from(data.privateKeyData, "base64").toString("utf8");
  return JSON.parse(json);
}

function updateProductionEnv(creds) {
  let content = fs.readFileSync(ENV_FILE, "utf8");
  const privateKeyOneLine = creds.private_key.replace(/\n/g, "\\n");

  const replacements = {
    FIREBASE_MODE: "live",
    FIREBASE_PROJECT_ID: creds.project_id,
    FIREBASE_CLIENT_EMAIL: creds.client_email,
    FIREBASE_PRIVATE_KEY: privateKeyOneLine,
  };

  for (const [key, value] of Object.entries(replacements)) {
    const re = new RegExp(`^${key}=.*$`, "m");
    if (re.test(content)) {
      content = content.replace(re, `${key}=${value}`);
    } else {
      content += `\n${key}=${value}`;
    }
  }

  fs.writeFileSync(ENV_FILE, content);
}

async function pushToRender(creds) {
  if (!fs.existsSync(KEY_FILE)) {
    throw new Error("Missing .render-api-key");
  }
  const apiKey = fs.readFileSync(KEY_FILE, "utf8").trim();
  const headers = {
    Authorization: `Bearer ${apiKey}`,
    Accept: "application/json",
    "Content-Type": "application/json",
  };

  const privateKeyOneLine = creds.private_key.replace(/\n/g, "\\n");
  const vars = {
    FIREBASE_MODE: "live",
    FIREBASE_PROJECT_ID: creds.project_id,
    FIREBASE_CLIENT_EMAIL: creds.client_email,
    FIREBASE_PRIVATE_KEY: privateKeyOneLine,
  };

  for (const [key, value] of Object.entries(vars)) {
    const res = await fetch(
      `https://api.render.com/v1/services/${SERVICE_ID}/env-vars/${key}`,
      {
        method: "PUT",
        headers,
        body: JSON.stringify({ value }),
      },
    );
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Render env update failed for ${key} (${res.status}): ${body}`);
    }
    console.log(`  Render: updated ${key}`);
  }

  const deployRes = await fetch(
    `https://api.render.com/v1/services/${SERVICE_ID}/deploys`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({ clearCache: "do_not_clear" }),
    },
  );
  if (!deployRes.ok) {
    const body = await deployRes.text();
    throw new Error(`Render deploy failed (${deployRes.status}): ${body}`);
  }
  const deploy = await deployRes.json();
  console.log(`  Render: deploy ${deploy.id} (${deploy.status})`);
}

async function waitForHealth() {
  const url = "https://moozhayilapp-fyz6.onrender.com/health";
  for (let i = 0; i < 18; i++) {
    await new Promise((r) => setTimeout(r, 10000));
    try {
      const res = await fetch(url);
      const health = await res.json();
      if (health.status === "ok") {
        console.log("  Health OK");
        return;
      }
    } catch {
      // retry
    }
  }
  console.log("  Deploy triggered; health not confirmed yet.");
}

async function main() {
  console.log("1. Getting Firebase CLI access token...");
  const accessToken = await getAccessToken();

  console.log("2. Finding firebase-adminsdk service account...");
  const email = await findFirebaseAdminServiceAccount(accessToken);
  console.log(`   Found: ${email}`);

  console.log("3. Creating service account key...");
  const creds = await createServiceAccountKey(accessToken, email);
  fs.writeFileSync(SA_PATH, JSON.stringify(creds, null, 2));
  console.log(`   Saved: ${SA_PATH}`);

  console.log("4. Updating PRODUCTION_ENV.txt...");
  updateProductionEnv(creds);

  console.log("5. Pushing FIREBASE_* to Render and redeploying...");
  await pushToRender(creds);

  console.log("6. Waiting for health check...");
  await waitForHealth();

  console.log("\nDone. Firebase push is live on Render staging.");
}

main().catch((err) => {
  console.error("ERROR:", err.message);
  process.exit(1);
});
