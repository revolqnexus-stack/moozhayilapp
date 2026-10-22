const BANK_NAME_MATCH_OK = new Set(["GOOD_MATCH", "MATCH", "PARTIAL_MATCH"]);

export function isBankNameMatchResultOk(
  nameMatchResult: string | undefined,
  nameProvided: boolean,
): boolean {
  if (!nameProvided) {
    return true;
  }

  if (!nameMatchResult?.trim()) {
    return true;
  }

  return BANK_NAME_MATCH_OK.has(nameMatchResult.trim().toUpperCase());
}

export function maskBankAccountNumber(accountNumber: string): string {
  const digits = accountNumber.replace(/\D/g, "");
  if (digits.length < 4) {
    return "••••";
  }

  return `••••••${digits.slice(-4)}`;
}
