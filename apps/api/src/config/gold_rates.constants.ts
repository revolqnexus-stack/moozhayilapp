/** Gold rate staleness — admin-set daily at market open (BR-PRICE-002). */
export const GOLD_RATE_STALE_AFTER_MS = 8 * 60 * 60 * 1000;
export const GOLD_RATE_STALE_AFTER_SECONDS = GOLD_RATE_STALE_AFTER_MS / 1000;

export function isGoldRateStale(effectiveFrom: Date, nowMs = Date.now()): boolean {
  return nowMs - effectiveFrom.getTime() > GOLD_RATE_STALE_AFTER_MS;
}
