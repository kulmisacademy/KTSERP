/**
 * Somali phone normalization.
 * - Storage / OTP DB: E.164 digits e.g. 252613609678
 * - Hormuud API mobile field: local e.g. 613609678 (no 252, no leading 0)
 */

export type PhoneNormalizeResult = {
  ok: boolean;
  e164: string;
  hormuud: string;
  error?: string;
};

const LOCAL_MOBILE_RE = /^[679]\d{8}$/;

function digitsOnly(raw: string): string {
  let d = raw.replace(/[^\d+]/g, "");
  if (d.startsWith("+")) d = d.slice(1);
  if (d.startsWith("00")) d = d.slice(2);
  return d;
}

/** Local Somali mobile: 9 digits, starts with 6, 7, or 9 */
export function toLocalMobile(digits: string): string | null {
  let d = digits;

  if (d.startsWith("252") && d.length >= 12) {
    d = d.slice(3);
  }
  if (d.startsWith("0") && d.length >= 9) {
    d = d.slice(1);
  }

  if (!LOCAL_MOBILE_RE.test(d)) {
    return null;
  }
  return d;
}

/** Canonical E.164 without plus: 252 + local */
export function normalizeSomaliPhone(raw: string): PhoneNormalizeResult {
  const digits = digitsOnly(raw);
  if (!digits || digits.length < 7) {
    return {
      ok: false,
      e164: "",
      hormuud: "",
      error: "Invalid phone number",
    };
  }

  const local = toLocalMobile(digits);
  if (!local) {
    return {
      ok: false,
      e164: "",
      hormuud: "",
      error:
        "Invalid Somali mobile. Use 061XXXXXXX, 613XXXXXXX, or +25261XXXXXXX",
    };
  }

  return {
    ok: true,
    e164: `252${local}`,
    hormuud: local,
  };
}

/** @deprecated Use normalizeSomaliPhone — kept for imports */
export function normalizeMobile(phone: string): string {
  const r = normalizeSomaliPhone(phone);
  return r.ok ? r.e164 : phone.replace(/[^\d]/g, "");
}

export function toHormuudMobile(phone: string): string {
  const r = normalizeSomaliPhone(phone);
  return r.ok ? r.hormuud : phone.replace(/[^\d]/g, "");
}
