/**
 * Provision Cloudflare R2 for production and wire PRODUCTION_ENV.txt.
 *
 * Uses Wrangler OAuth token (~/.wrangler/config/default.toml) or:
 *   CLOUDFLARE_API_TOKEN + CLOUDFLARE_ACCOUNT_ID
 *
 * Does not print secret values.
 */
import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const PROD_ENV = path.join(ROOT, "PRODUCTION_ENV.txt");
const ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID ?? "28247e5c8e5aca83c94a869bdfbd0b6d";
const BUCKET = process.env.R2_BUCKET_NAME ?? "moozhayil-media";
const TOKEN_NAME = "moozhayil-api-production";

function parseEnv(content) {
  const vars = {};
  for (const line of content.split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2];
  }
  return vars;
}

function serializeEnv(vars, templateContent) {
  return templateContent
    .split(/\r?\n/)
    .map((line) => {
      const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
      if (!m) return line;
      const key = m[1];
      return vars[key] !== undefined ? `${key}=${vars[key]}` : line;
    })
    .join("\n");
}

function loadCloudflareToken() {
  if (process.env.CLOUDFLARE_API_TOKEN?.trim()) {
    return process.env.CLOUDFLARE_API_TOKEN.trim();
  }
  const wranglerConfig = path.join(
    os.homedir(),
    "AppData/Roaming/xdg.config/.wrangler/config/default.toml",
  );
  if (!fs.existsSync(wranglerConfig)) return null;
  const content = fs.readFileSync(wranglerConfig, "utf8");
  const match = content.match(/^oauth_token\s*=\s*"([^"]+)"/m);
  return match?.[1] ?? null;
}

async function cfApi(token, method, apiPath, body) {
  const res = await fetch(`https://api.cloudflare.com/client/v4${apiPath}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json();
  if (!res.ok || !json.success) {
    const msg = json.errors?.[0]?.message ?? res.statusText;
    throw new Error(`Cloudflare API ${method} ${apiPath}: ${msg}`);
  }
  return json.result;
}

async function ensureBucket(token) {
  try {
    await cfApi(token, "POST", `/accounts/${ACCOUNT_ID}/r2/buckets`, {
      name: BUCKET,
      locationHint: "apac",
    });
    console.log(`Created R2 bucket "${BUCKET}".`);
  } catch (err) {
    if (/already exists|409|duplicate/i.test(err.message)) {
      console.log(`R2 bucket "${BUCKET}" already exists.`);
      return;
    }
    throw err;
  }
}

async function createR2S3Credentials(token) {
  const attempts = [
    async () => {
      const groups = await cfApi(token, "GET", "/user/tokens/permission_groups");
      const writeGroup = groups.find((g) =>
        /Workers R2 Storage Bucket Item Write/i.test(g.name),
      );
      if (!writeGroup?.id) throw new Error("missing permission group");
      const resourceKey = `com.cloudflare.edge.r2.bucket.${ACCOUNT_ID}_default_${BUCKET}`;
      const created = await cfApi(token, "POST", "/user/tokens", {
        name: `${TOKEN_NAME}-${Date.now()}`,
        policies: [
          {
            effect: "allow",
            resources: { [resourceKey]: "*" },
            permission_groups: [{ id: writeGroup.id }],
          },
        ],
      });
      if (!created?.id || !created?.value) throw new Error("missing token value");
      return {
        access_key_id: created.id,
        secret_access_key: createHash("sha256").update(created.value).digest("hex"),
      };
    },
    async () => {
      const created = await cfApi(
        token,
        "POST",
        `/accounts/${ACCOUNT_ID}/r2/temp-access-credentials`,
        {
          bucket: BUCKET,
          parentAccessKeyId: process.env.R2_PARENT_ACCESS_KEY_ID,
          permission: "object-read-write",
          ttlSeconds: 604800,
        },
      );
      if (!created?.accessKeyId || !created?.secretAccessKey) {
        throw new Error("temp credentials unavailable");
      }
      return {
        access_key_id: created.accessKeyId,
        secret_access_key: created.secretAccessKey,
      };
    },
  ];

  let lastError = null;
  for (const attempt of attempts) {
    try {
      return await attempt();
    } catch (err) {
      lastError = err;
    }
  }
  throw lastError ?? new Error("Could not create R2 S3 credentials via API");
}

function enableDevPublicUrl() {
  execSync(`npx wrangler r2 bucket dev-url enable ${BUCKET}`, {
    cwd: ROOT,
    stdio: "pipe",
  });
}

function getDevPublicUrl() {
  const out = execSync(`npx wrangler r2 bucket dev-url get ${BUCKET}`, {
    cwd: ROOT,
    encoding: "utf8",
  });
  const match = out.match(/https:\/\/pub-[a-z0-9]+\.r2\.dev/i);
  if (!match) {
    throw new Error("Could not parse r2.dev public URL from wrangler output");
  }
  return match[0].replace(/\/$/, "");
}

async function testR2(accessKeyId, secretAccessKey, publicBaseUrl) {
  const { S3Client, PutObjectCommand, GetObjectCommand } = await import(
    "@aws-sdk/client-s3"
  );
  const client = new S3Client({
    region: "auto",
    endpoint: `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: { accessKeyId, secretAccessKey },
  });
  const key = `test/setup-${Date.now()}.txt`;
  const body = `r2-setup-${new Date().toISOString()}`;
  await client.send(
    new PutObjectCommand({ Bucket: BUCKET, Key: key, Body: body, ContentType: "text/plain" }),
  );
  await client.send(new GetObjectCommand({ Bucket: BUCKET, Key: key }));
  if (!publicBaseUrl.startsWith("https://")) {
    throw new Error("Invalid public base URL");
  }
  console.log("R2 upload/read test passed.");
}

async function main() {
  if (!fs.existsSync(PROD_ENV)) {
    throw new Error("Missing PRODUCTION_ENV.txt");
  }

  const token = loadCloudflareToken();
  if (!token) {
    throw new Error(
      "No Cloudflare credentials. Run: npx wrangler login  OR set CLOUDFLARE_API_TOKEN",
    );
  }

  await ensureBucket(token);

  console.log("Enabling r2.dev public URL (product/banner media)...");
  try {
    enableDevPublicUrl();
  } catch {
    console.log("Public URL already enabled or enable skipped.");
  }
  const publicBaseUrl = getDevPublicUrl();
  console.log(`Public media base: ${publicBaseUrl}`);

  const prodContent = fs.readFileSync(PROD_ENV, "utf8");
  const prodVars = parseEnv(prodContent);
  prodVars.STORAGE_BACKEND = "s3";
  prodVars.S3_ENDPOINT = `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`;
  prodVars.S3_REGION = "auto";
  prodVars.S3_BUCKET = BUCKET;
  prodVars.S3_PUBLIC_BASE_URL = publicBaseUrl;
  prodVars.S3_FORCE_PATH_STYLE = "false";

  if (process.env.S3_ACCESS_KEY_ID && process.env.S3_SECRET_ACCESS_KEY) {
    prodVars.S3_ACCESS_KEY_ID = process.env.S3_ACCESS_KEY_ID.trim();
    prodVars.S3_SECRET_ACCESS_KEY = process.env.S3_SECRET_ACCESS_KEY.trim();
    await testR2(prodVars.S3_ACCESS_KEY_ID, prodVars.S3_SECRET_ACCESS_KEY, publicBaseUrl);
  } else {
    console.log("Creating R2 S3 API credentials...");
    const creds = await createR2S3Credentials(token);
    prodVars.S3_ACCESS_KEY_ID = creds.access_key_id;
    prodVars.S3_SECRET_ACCESS_KEY = creds.secret_access_key;
    await testR2(creds.access_key_id, creds.secret_access_key, publicBaseUrl);
  }

  fs.writeFileSync(PROD_ENV, serializeEnv(prodVars, prodContent));
  console.log("Updated PRODUCTION_ENV.txt with R2 settings (secrets not printed).");
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
