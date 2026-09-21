/** BR-PRICE-005: price lock window after quote issuance. */
export const PRICE_VALIDITY_MS = 15 * 60 * 1000;
export const PRICE_VALIDITY_MINUTES = 15;

/**
 * Grace applied at order-create when comparing quote expiry to server time.
 * Covers network latency between client expiry check and POST /orders.
 */
export const ORDER_CREATE_LATENCY_TOLERANCE_MS = 2_000;
