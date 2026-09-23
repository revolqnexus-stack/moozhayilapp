/**
 * Switch moozhayilapp-prod from Docker to Node runtime (staging-compatible build).
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const KEY_FILE = path.join(ROOT, ".render-api-key");
const SERVICE_ID = "srv-dapva7k9v7es73a27ukg";

function loadApiKey() {
  if (process.env.RENDER_API_KEY?.trim()) return process.env.RENDER_API_KEY.trim();
  return fs.readFileSync(KEY_FILE, "utf8").trim();
}

async function main() {
  const apiKey = loadApiKey();
  const res = await fetch(`https://api.render.com/v1/services/${SERVICE_ID}`, {
    method: "PATCH",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      serviceDetails: {
        runtime: "node",
        plan: "free",
        envSpecificDetails: {
          buildCommand: "npm ci && npm run build && npx prisma generate",
          startCommand: "npm run start:prod",
        },
        healthCheckPath: "/health",
      },
    }),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`PATCH failed: ${res.status} ${text.slice(0, 300)}`);
  }
  console.log("Updated prod service to Node runtime.");

  const deploy = await fetch(`https://api.render.com/v1/services/${SERVICE_ID}/deploys`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ clearCache: "clear" }),
  });
  const deployBody = await deploy.json();
  console.log(`Deploy triggered: ${deployBody.id} (${deployBody.status})`);
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
