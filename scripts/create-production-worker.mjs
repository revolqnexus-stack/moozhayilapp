/**
 * Create production background worker on Render (moozhayil-worker-prod).
 * Env vars are copied from moozhayilapp-prod after creation via Render dashboard/API sync.
 * Idempotent: skips if worker already exists.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const KEY_FILE = path.join(ROOT, ".render-api-key");
const ENV_CONFIG = path.join(ROOT, "config/environments.json");

const WORKER_NAME = "moozhayil-worker-prod";
const OWNER_ID = "tea-damms4942hec739o0ll0";
const REPO = "https://github.com/revolqnexus-stack/moozhayilapp";

function loadApiKey() {
  if (process.env.RENDER_API_KEY?.trim()) return process.env.RENDER_API_KEY.trim();
  if (fs.existsSync(KEY_FILE)) return fs.readFileSync(KEY_FILE, "utf8").trim();
  throw new Error("Missing Render API key (.render-api-key or RENDER_API_KEY)");
}

async function renderApi(apiKey, method, pathName, body) {
  const res = await fetch(`https://api.render.com/v1${pathName}`, {
    method,
    headers: {
      Authorization: `Bearer ${apiKey}`,
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`Render API ${method} ${pathName} failed: ${res.status} ${text.slice(0, 400)}`);
  }
  return text ? JSON.parse(text) : null;
}

async function findService(apiKey, name) {
  const list = await renderApi(apiKey, "GET", "/services?limit=100");
  return list.map((row) => row.service).find((svc) => svc.name === name);
}

async function copyEnvFromProd(apiKey, workerId, prodId) {
  const prodEnv = await renderApi(apiKey, "GET", `/services/${prodId}/env-vars?limit=100`);
  for (const row of prodEnv) {
    const key = row.envVar.key;
    const value = row.envVar.value;
    await renderApi(apiKey, "PUT", `/services/${workerId}/env-vars/${key}`, { value });
  }
}

async function main() {
  const apiKey = loadApiKey();
  const cfg = JSON.parse(fs.readFileSync(ENV_CONFIG, "utf8"));
  const prodId = cfg.production.renderServiceId;
  const prodWeb = await renderApi(apiKey, "GET", `/services/${prodId}`);

  const existing = await findService(apiKey, WORKER_NAME);
  if (existing) {
    console.log(`Worker already exists: ${existing.name} (${existing.id})`);
    return;
  }

  const payload = {
    type: "background_worker",
    name: WORKER_NAME,
    ownerId: OWNER_ID,
    repo: REPO,
    branch: prodWeb.branch ?? "main",
    rootDir: prodWeb.rootDir ?? "apps/api",
    autoDeploy: "yes",
    serviceDetails: {
      runtime: prodWeb.serviceDetails?.runtime ?? "node",
      plan: prodWeb.serviceDetails?.plan ?? "free",
      region: prodWeb.serviceDetails?.region ?? "oregon",
      envSpecificDetails: {
        buildCommand: prodWeb.serviceDetails?.envSpecificDetails?.buildCommand ?? "npm ci && npm run build",
        startCommand: "npm run worker:start",
      },
    },
  };

  console.log(`Creating worker "${WORKER_NAME}"...`);
  const created = await renderApi(apiKey, "POST", "/services", payload);
  const worker = created.service ?? created;
  console.log(`Created worker: ${worker.name} (${worker.id})`);
  console.log("Copying production env vars to worker...");
  await copyEnvFromProd(apiKey, worker.id, prodId);
  console.log("Triggering worker deploy...");
  await renderApi(apiKey, "POST", `/services/${worker.id}/deploys`, { clearCache: "do_not_clear" });
  console.log("Done.");
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
