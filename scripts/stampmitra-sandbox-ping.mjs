/**
 * Send one sandbox PAN (and optional bank) request to StampMitra.
 * Does not start the API and does not touch production.
 *
 * 1. Put STAMPMITRA_API_KEY=sk_test_... in apps/api/.env.local (gitignored)
 * 2. node scripts/stampmitra-sandbox-ping.mjs
 *    node scripts/stampmitra-sandbox-ping.mjs --pan ABCDE1234F --name "TEST USER"
 *
 * Use StampMitra's documented sandbox PAN if they gave you one.
 * Do not use a real customer's PAN.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), "..");
const BASE_URL = "https://api-b2b.stampmitra.in";

function loadEnvFile(filePath) {
  if (!fs.existsSync(filePath)) {
    return;
  }
  for (const line of fs.readFileSync(filePath, "utf8").split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (!match) {
      continue;
    }
    const key = match[1];
    const value = match[2].trim().replace(/^['"]|['"]$/g, "");
    if (!process.env[key]) {
      process.env[key] = value;
    }
  }
}

function argValue(flag) {
  const index = process.argv.indexOf(flag);
  if (index === -1 || !process.argv[index + 1]) {
    return undefined;
  }
  return process.argv[index + 1];
}

async function post(apiKey, pathName, body) {
  const response = await fetch(`${BASE_URL}${pathName}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(15_000),
  });

  const text = await response.text();
  let json = null;
  try {
    json = JSON.parse(text);
  } catch {
    json = null;
  }

  return { status: response.status, json, text: text.slice(0, 500) };
}

function summarize(label, result) {
  const requestId =
    result.json?.error?.requestId ?? result.json?.referenceId ?? "(none)";
  const valid = result.json?.valid;
  const code = result.json?.error?.code ?? result.json?.panStatus ?? "";
  console.log(`${label}: HTTP ${result.status} requestId=${requestId} valid=${valid ?? "n/a"} ${code}`);
  if (result.status >= 400) {
    const message = result.json?.error?.message ?? result.text;
    console.log(`  ${message}`);
  }
}

async function main() {
  loadEnvFile(path.join(ROOT, "apps/api/.env.local"));
  loadEnvFile(path.join(ROOT, "apps/api/.env"));
  loadEnvFile(path.join(ROOT, ".env.local"));

  const apiKey = process.env.STAMPMITRA_API_KEY?.trim();
  if (!apiKey || apiKey.includes("xxx") || apiKey.length < 16) {
    console.error(
      "Missing sandbox key. Add STAMPMITRA_API_KEY=sk_test_... to apps/api/.env.local",
    );
    process.exit(1);
  }
  if (apiKey.startsWith("sk_live_")) {
    console.error("This ping is for the sandbox key (sk_test_...). Do not use sk_live_ here.");
    process.exit(1);
  }

  const pan = (argValue("--pan") ?? "ABCDE1234F").toUpperCase();
  const name = argValue("--name");
  const panBody = { pan };
  if (name) {
    panBody.name = name;
  }

  console.log("Calling StampMitra sandbox (key not printed).");
  const panResult = await post(apiKey, "/v1/verify/pan", panBody);
  summarize("PAN", panResult);

  if (process.argv.includes("--bank")) {
    const accountNumber = argValue("--account") ?? "12345678901";
    const ifsc = (argValue("--ifsc") ?? "HDFC0000001").toUpperCase();
    const bankResult = await post(apiKey, "/v1/verify/bank-account", {
      accountNumber,
      ifsc,
      ...(name ? { name } : {}),
    });
    summarize("BANK", bankResult);
  }

  const ok = panResult.status > 0 && panResult.status < 500;
  if (!ok) {
    process.exit(1);
  }
  console.log(
    "StampMitra received the request. Screenshot this output (no key shown) for their team.",
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
