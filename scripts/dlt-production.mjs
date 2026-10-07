/**
 * Single source of truth for India DLT IDs (also in config/dlt-production.json).
 * Brand DLT ID must NOT be used as MSG91 PE_ID.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** MOOZHAYIL brand registration ID — not the Principal Entity (PE) for SMS. */
export const BRAND_DLT_ID = "1016720216615695729";

export function loadDltProductionConfig(rootDir = path.join(__dirname, "..")) {
  const file = path.join(rootDir, "config", "dlt-production.json");
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

export function assertPeIdNotBrand(peId) {
  if (peId === BRAND_DLT_ID) {
    throw new Error(
      `MSG91_DLT_PE_ID is the Brand DLT ID (${BRAND_DLT_ID}). Use peId from config/dlt-production.json (Principal Entity).`,
    );
  }
}

export function msg91DltEnvFromConfig(cfg) {
  return {
    MSG91_DLT_PE_ID: cfg.peId,
    MSG91_DLT_TE_ID: cfg.airtelDltTemplateId,
    MSG91_OTP_TEMPLATE_ID: cfg.msg91OtpTemplateId,
  };
}
