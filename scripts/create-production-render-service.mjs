/**
 * Create the production Render web service (moozhayilapp-prod) cloned from staging.
 * Idempotent: skips if service already exists. Updates config/environments.json.
 *
 * Requires: .render-api-key
 * Does not print secret values.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const KEY_FILE = path.join(ROOT, ".render-api-key");
const ENV_CONFIG = path.join(ROOT, "config/environments.json");

const STAGING_SERVICE_ID = "srv-dammuh61egvs73csp3ng";
const PROD_SERVICE_NAME = "moozhayilapp-prod";
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
    throw new Error(`Render API ${method} ${pathName} failed: ${res.status} ${text.slice(0, 300)}`);
  }
  return text ? JSON.parse(text) : null;
}

async function findService(apiKey, name) {
  const list = await renderApi(apiKey, "GET", "/services?limit=100");
  return list
    .map((row) => row.service)
    .find((svc) => svc.name === name || svc.id === name);
}

async function main() {
  const apiKey = loadApiKey();
  const existing = await findService(apiKey, PROD_SERVICE_NAME);
  if (existing) {
    console.log(`Production service already exists: ${existing.name} (${existing.id})`);
    console.log(`URL: ${existing.serviceDetails?.url ?? "pending"}`);
    updateConfig(existing);
    return;
  }

  const staging = await renderApi(apiKey, "GET", `/services/${STAGING_SERVICE_ID}`);
  const payload = {
    type: "web_service",
    name: PROD_SERVICE_NAME,
    ownerId: OWNER_ID,
    repo: REPO,
    branch: staging.branch ?? "main",
    rootDir: staging.rootDir ?? "apps/api",
    autoDeploy: "yes",
    serviceDetails: {
      runtime: "docker",
      plan: staging.serviceDetails?.plan ?? "free",
      region: staging.serviceDetails?.region ?? "oregon",
      envSpecificDetails: {
        dockerContext: ".",
        dockerfilePath: "Dockerfile",
      },
    },
  };

  console.log(`Creating Render production service "${PROD_SERVICE_NAME}"...`);
  const created = await renderApi(apiKey, "POST", "/services", payload);
  const service = created.service ?? created;
  console.log(`Created: ${service.name} (${service.id})`);
  console.log(`URL: ${service.serviceDetails?.url ?? "pending DNS"}`);
  updateConfig(service);
}

function updateConfig(service) {
  if (!fs.existsSync(ENV_CONFIG)) return;
  const cfg = JSON.parse(fs.readFileSync(ENV_CONFIG, "utf8"));
  const url = service.serviceDetails?.url;
  cfg.production.renderServiceId = service.id;
  cfg.production.renderServiceName = service.name;
  if (url) {
    cfg.production.apiBase = url;
    cfg.production.apiV1 = `${url}/v1`;
    cfg.production.healthUrl = `${url}/health`;
  }
  fs.writeFileSync(ENV_CONFIG, JSON.stringify(cfg, null, 2) + "\n");
  console.log("Updated config/environments.json");
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
