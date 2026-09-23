/**
 * List and delete old Firebase Admin SDK keys, keeping the newest one.
 * Requires: firebase login (CLI)
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { createRequire } from "module";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROJECT_ID = "moozhayil-prod";
const SA_PATH = path.join(ROOT, "apps/api/firebase-service-account.json");

const require = createRequire(import.meta.url);
const firebaseToolsRoot = path.join(
  path.dirname(process.execPath),
  "node_modules",
  "firebase-tools",
);
const auth = require(path.join(firebaseToolsRoot, "lib/auth"));
const scopes = require(path.join(firebaseToolsRoot, "lib/scopes"));

async function getAccessToken() {
  const account = auth.getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) {
    throw new Error("Firebase CLI not logged in");
  }
  const tokens = await auth.getAccessToken(
    account.tokens.refresh_token,
    [scopes.CLOUD_PLATFORM],
  );
  return tokens.access_token;
}

async function main() {
  const accessToken = await getAccessToken();

  const listSaRes = await fetch(
    `https://iam.googleapis.com/v1/projects/${PROJECT_ID}/serviceAccounts`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  const saData = await listSaRes.json();
  const email = saData.accounts?.find((a) =>
    a.email?.includes("firebase-adminsdk"),
  )?.email;
  if (!email) throw new Error("No firebase-adminsdk account found");

  const keysRes = await fetch(
    `https://iam.googleapis.com/v1/projects/${PROJECT_ID}/serviceAccounts/${encodeURIComponent(email)}/keys`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  const keysData = await keysRes.json();
  const keys = (keysData.keys ?? []).filter(
    (k) => k.keyType === "USER_MANAGED",
  );

  if (keys.length === 0) {
    console.log("No user-managed keys found.");
    return;
  }

  // Keep newest by validAfterTime
  keys.sort((a, b) =>
    (b.validAfterTime ?? "").localeCompare(a.validAfterTime ?? ""),
  );
  const keep = keys[0];
  const toDelete = keys.slice(1);

  console.log(`Keeping newest key: ${keep.name.split("/").pop()}`);
  console.log(`Deleting ${toDelete.length} older key(s)...`);

  for (const key of toDelete) {
    const delRes = await fetch(
      `https://iam.googleapis.com/v1/${key.name}`,
      {
        method: "DELETE",
        headers: { Authorization: `Bearer ${accessToken}` },
      },
    );
    if (!delRes.ok) {
      const body = await delRes.text();
      console.error(`Failed to delete ${key.name}: ${body.slice(0, 120)}`);
    } else {
      console.log(`  Deleted ${key.name.split("/").pop()}`);
    }
  }

  if (fs.existsSync(SA_PATH)) {
    console.log("Local firebase-service-account.json present (gitignored).");
  }
}

main().catch((e) => {
  console.error("ERROR:", e.message);
  process.exit(1);
});
