import type { PriceQuote } from "@prisma/client";
import { formatPaise } from "../../utils/money";
import { parseQuoteLines } from "./quote.types";

export function mapQuoteToDto(quote: PriceQuote, serverTime = new Date()) {
  return {
    quote_id: quote.id,
    status: quote.status,
    server_time: serverTime.toISOString(),
    price_valid_until: quote.validUntil.toISOString(),
    server_time_at_issue: quote.serverTimeAtIssue.toISOString(),
    total_paise: quote.totalPaise,
    total_display: formatPaise(quote.totalPaise),
    kyc_gross_total_paise: quote.totalPaise,
    making_charge_waiver_paise: quote.makingChargeWaiverPaise,
    lines: parseQuoteLines(quote.linesJson),
  };
}
