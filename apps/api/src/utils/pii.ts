const SENSITIVE_KEY_PATTERN =
  /aadhaar|pan|phone|email|otp|token|selfie|address|refresh|secret|password|payload/i;

export function redactString(value: string): string {
  const trimmed = value.trim();
  if (trimmed.length <= 4) {
    return "[REDACTED]";
  }

  return `${trimmed.slice(0, 2)}${"*".repeat(Math.max(trimmed.length - 4, 1))}${trimmed.slice(-2)}`;
}

export function redactValue(value: unknown): unknown {
  if (value === null || value === undefined) {
    return value;
  }

  if (typeof value === "string") {
    return redactString(value);
  }

  if (Array.isArray(value)) {
    return value.map((item) => redactValue(item));
  }

  if (typeof value === "object") {
    return redactObject(value as Record<string, unknown>);
  }

  return value;
}

export function redactObject<T extends Record<string, unknown>>(
  input: T,
): Record<string, unknown> {
  const output: Record<string, unknown> = {};

  for (const [key, value] of Object.entries(input)) {
    if (SENSITIVE_KEY_PATTERN.test(key)) {
      output[key] =
        typeof value === "string" ? redactString(value) : "[REDACTED]";
      continue;
    }

    output[key] = redactValue(value);
  }

  return output;
}

export function maskName(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) {
    return "[REDACTED]";
  }

  const first = parts[0] ?? "";
  const last = parts.length > 1 ? (parts[parts.length - 1] ?? "") : "";
  const maskedFirst =
    first.length <= 1 ? first : `${first[0]}${"*".repeat(first.length - 1)}`;
  const maskedLast =
    last.length <= 1 ? last : `${last[0]}${"*".repeat(last.length - 1)}`;

  if (parts.length === 1) {
    return maskedFirst;
  }

  return `${maskedFirst} ${maskedLast}`;
}

export function maskPan(pan: string): string {
  const value = pan.trim().toUpperCase();
  if (!/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(value)) {
    return "••••••••••";
  }

  return `${value.slice(0, 5)}••••${value.slice(-1)}`;
}
