/**
 * Ping production health so Render free tier stays awake (optional cron every 5–10 min).
 * Run: node scripts/warm-render-prod.mjs
 */
import cfg from "../config/environments.json" with { type: "json" };

const url = cfg.production.healthUrl;
const res = await fetch(url, { signal: AbortSignal.timeout(60_000) });
const body = await res.text();
if (!res.ok) {
  console.error(`Warm failed ${res.status}: ${body.slice(0, 200)}`);
  process.exit(1);
}
console.log(`Warm OK ${url} ${body.slice(0, 80)}`);
