/**
 * When MSG91 API returns success but delivery logs show DLT failures.
 */
import { loadDltProductionConfig } from "./dlt-production.mjs";

const cfg = loadDltProductionConfig();

console.log(`
MSG91 accepted the OTP API call, but Indian operators rejected delivery.
That is almost always DLT portal setup — not app code.

Your IDs (from config/dlt-production.json):
  PE (Entity):     ${cfg.peId}
  Brand DLT ID:    ${cfg.brandDltId}  ← do NOT use as PE
  Header:          ${cfg.header}
  Airtel Template: ${cfg.airtelDltTemplateId}
  MSG91 template:  ${cfg.msg91OtpTemplateId}
  Telemarketer:    ${cfg.telemarketerName}
  TM ID (required): ${cfg.telemarketerId}

─── Fix 1: Airtel DLT (Manage SMS Workflow / PE–TM) ───
1. Log in to Airtel DLT → Manage SMS Workflow (or PE–TM binding).
2. For entity ${cfg.peId}, add telemarketer TM ID ${cfg.telemarketerId}
   (Walkover Web Solutions Pvt Ltd — MSG91's delivery partner).
3. Approve the request until status is Active (not Pending at PE).

─── Fix 2: MSG91 (SMS → PE-TM Chain) ───
1. MSG91 → SMS (left menu) → PE-TM Chain.
2. Entity ID: ${cfg.peId}
3. TM-D: Walkover Web Solutions — ${cfg.telemarketerId}
4. Chain must show Active for that entity.

─── Fix 3: MSG91 sender + OTP template ───
1. SMS → Sender Id → ${cfg.header} → PE field = ${cfg.peId} (not ${cfg.brandDltId}).
2. SendOTP → Templates → Moozhayil_App_Login_OTP
   DLT Template ID = ${cfg.airtelDltTemplateId} (Airtel numeric id, not PE id).

─── Verify ───
After chain is Active, wait ~30 min, then:
  node scripts/test-msg91-direct.mjs <10-digit mobile>
MSG91 Logs should move from Failed → Delivered.

Help: https://msg91.com/help/dlt-registration-in-india/how-to-add-pe-tm-chain-on-msg91
`);
