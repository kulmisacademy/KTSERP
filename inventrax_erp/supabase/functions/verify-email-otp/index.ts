import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import {
  generateResetToken,
  hashSecret,
  MAX_ATTEMPTS,
  normalizeEmail,
  RESET_TOKEN_TTL_SEC,
} from "../_shared/email_otp.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const email = normalizeEmail(String(body.email ?? ""));
    const code = String(body.code ?? "").trim();
    const requestId = body.request_id ? String(body.request_id) : null;
    const purpose = String(body.purpose ?? "password_reset");

    if (!email || code.length !== 6) {
      return json({ error: "Email and 6-digit code are required" }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceKey);

    const base = admin.from("email_otps").select("*");
    const { data: row, error } = requestId
      ? await base
        .eq("id", requestId)
        .eq("email", email)
        .eq("purpose", purpose)
        .maybeSingle()
      : await base
        .eq("email", email)
        .eq("purpose", purpose)
        .is("used_at", null)
        .is("verified_at", null)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
    if (error) throw error;

    if (!row) {
      return json({ error: "Invalid or expired verification code" }, 400);
    }

    if (new Date(row.expires_at).getTime() < Date.now()) {
      return json({ error: "Code expired. Request a new one." }, 400);
    }

    if ((row.attempts as number) >= (row.max_attempts as number ?? MAX_ATTEMPTS)) {
      return json({ error: "Too many attempts. Request a new code." }, 429);
    }

    const otpHash = await hashSecret(code);
    if (otpHash !== row.otp_hash) {
      await admin
        .from("email_otps")
        .update({
          attempts: (row.attempts as number) + 1,
        })
        .eq("id", row.id);

      const remaining = (row.max_attempts as number ?? MAX_ATTEMPTS) -
        (row.attempts as number) - 1;
      return json(
        {
          error: "Invalid verification code",
          attempts_remaining: Math.max(0, remaining),
        },
        400,
      );
    }

    const resetToken = generateResetToken();
    const resetTokenHash = await hashSecret(resetToken);
    const verifiedAt = new Date().toISOString();

    const { error: updateErr } = await admin
      .from("email_otps")
      .update({
        verified_at: verifiedAt,
        reset_token_hash: resetTokenHash,
        attempts: (row.attempts as number) + 1,
      })
      .eq("id", row.id);

    if (updateErr) throw updateErr;

    return json({
      verified: true,
      request_id: row.id,
      reset_token: resetToken,
      reset_token_expires_in_sec: RESET_TOKEN_TTL_SEC,
    });
  } catch (e) {
    console.error("[verify-email-otp]", e);
    return json(
      { error: e instanceof Error ? e.message : "Internal error" },
      500,
    );
  }
});

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
