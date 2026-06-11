const OTP_PEPPER = Deno.env.get("EMAIL_OTP_PEPPER") ?? "kulmis-email-otp-v1";

export const OTP_TTL_SEC = 600; // 10 minutes
export const RESEND_COOLDOWN_SEC = 30;
export const MAX_HOURLY_SENDS = 5;
export const MAX_ATTEMPTS = 5;
export const RESET_TOKEN_TTL_SEC = 900; // 15 minutes after verify

export function normalizeEmail(raw: string): string | null {
  const email = raw.trim().toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return null;
  return email;
}

export async function hashSecret(value: string): Promise<string> {
  const data = new TextEncoder().encode(`${OTP_PEPPER}:${value}`);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

export function generateOtpCode(): string {
  const n = crypto.getRandomValues(new Uint32Array(1))[0] % 1_000_000;
  return n.toString().padStart(6, "0");
}

export function generateResetToken(): string {
  return crypto.randomUUID();
}
