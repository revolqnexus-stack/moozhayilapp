/**
 * Send one test OTP via MSG91 (same payload as production API).
 * Usage: node scripts/test-msg91-direct.mjs 7997027875
 * Reads MSG91_* from PRODUCTION_ENV.txt — does not print auth key.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  assertPeIdNotBrand,
  loadDltProductionConfig,
  msg91DltEnvFromConfig,
} from "./dlt-production.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const envFile = path.join(ROOT, "PRODUCTION_ENV.txt");

function loadEnv(file) {
  const vars = {};
  for (const line of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) vars[m[1]] = m[2].trim();
  }
  return vars;
}

const digits = (process.argv[2] ?? "").replace(/\D/g, "");
if (digits.length !== 10) {
  console.error("Usage: node scripts/test-msg91-direct.mjs <10-digit mobile>");
  process.exit(1);
}

const dltCfg = loadDltProductionConfig(ROOT);
const dltDefaults = msg91DltEnvFromConfig(dltCfg);

const env = { ...dltDefaults, ...loadEnv(envFile) };
const authKey = env.MSG91_AUTH_KEY;
const templateId = env.MSG91_OTP_TEMPLATE_ID;
if (!authKey || !templateId) {
  console.error("Missing MSG91_AUTH_KEY or MSG91_OTP_TEMPLATE_ID in PRODUCTION_ENV.txt");
  process.exit(1);
}
try {
  assertPeIdNotBrand(env.MSG91_DLT_PE_ID);
} catch (e) {
  console.error(e.message);
  process.exit(1);
}
if (!env.MSG91_DLT_PE_ID || !env.MSG91_DLT_TE_ID) {
  console.error("Missing MSG91 DLT PE/TE — check config/dlt-production.json");
  process.exit(1);
}
console.log("DLT PE_ID:", env.MSG91_DLT_PE_ID, "DLT_TE_ID:", env.MSG91_DLT_TE_ID);

const mobile = `91${digits}`;
const otp = String(Math.floor(100000 + Math.random() * 900000));

const res = await fetch("https://control.msg91.com/api/v5/otp", {
  method: "POST",
  headers: {
    authkey: authKey,
    "content-type": "application/json",
    accept: "application/json",
  },
  body: JSON.stringify({
    template_id: templateId,
    mobile,
    otp,
    otp_length: 6,
    otp_expiry: 10,
    ...(dltCfg.header ? { sender: dltCfg.header } : {}),
    ...(env.MSG91_DLT_PE_ID ? { PE_ID: env.MSG91_DLT_PE_ID } : {}),
    ...(env.MSG91_DLT_TE_ID ? { DLT_TE_ID: env.MSG91_DLT_TE_ID } : {}),
  }),
});

const body = await res.text();
console.log("HTTP", res.status);
console.log(body.slice(0, 500));
if (res.ok && body.includes('"type":"success"')) {
  console.log("\nMSG91 accepted the request. Check the phone SMS inbox (and spam).");
  console.log(
    "If MSG91 Logs show Failed: PE-TM Chain Error / Invalid DLT Entity Id, run: node scripts/print-pe-tm-fix.mjs",
  );
} else {
  console.log("\nMSG91 did not accept — fix dashboard config before testing the app again.");
}
