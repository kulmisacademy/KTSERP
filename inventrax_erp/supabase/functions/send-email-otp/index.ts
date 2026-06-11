import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import {
  generateOtpCode,
  hashSecret,
  MAX_HOURLY_SENDS,
  normalizeEmail,
  OTP_TTL_SEC,
  RESEND_COOLDOWN_SEC,
} from "../_shared/email_otp.ts";
import { passwordResetEmailHtml, sendResendEmail } from "../_shared/resend.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const DEV_MODE = Deno.env.get("OTP_DEV_MODE") === "true";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const email = normalizeEmail(String(body.email ?? ""));
    const purpose = String(body.purpose ?? "password_reset");

    if (!email) {
      return json({ error: "Enter a valid email address" }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceKey);

    // Account must exist for password reset (case-insensitive email match).
    if (purpose === "password_reset") {
      const { data: profileJson, error: lookupErr } = await admin.rpc(
        "inventrax_find_profile_for_password_reset",
        { p_phone: "", p_email: email },
      );
      if (lookupErr) throw lookupErr;
      if (!profileJson) {
        return json({ error: "No account found for this email" }, 404);
      }
    }

    const hourAgo = new Date(Date.now() - 60 * 60_000).toISOString();
    const { count: hourlyCount } = await admin
      .from("email_otps")
      .select("id", { count: "exact", head: true })
      .eq("email", email)
      .eq("purpose", purpose)
      .gte("created_at", hourAgo);

    if ((hourlyCount ?? 0) >= MAX_HOURLY_SENDS) {
      return json(
        { error: "Too many requests. Please try again in 1 hour." },
        429,
      );
    }

    const { data: recent } = await admin
      .from("email_otps")
      .select("last_sent_at")
      .eq("email", email)
      .eq("purpose", purpose)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (recent?.last_sent_at) {
      const elapsed = Date.now() - new Date(recent.last_sent_at).getTime();
      if (elapsed < RESEND_COOLDOWN_SEC * 1000) {
        const retryAfter = Math.ceil(
          (RESEND_COOLDOWN_SEC * 1000 - elapsed) / 1000,
        );
        return json(
          {
            error: `Please wait ${retryAfter}s before requesting another code`,
            retry_after_sec: retryAfter,
          },
          429,
        );
      }
    }

    const code = DEV_MODE ? "123456" : generateOtpCode();
    const otpHash = await hashSecret(code);
    const expiresAt = new Date(Date.now() + OTP_TTL_SEC * 1000).toISOString();

    const { data: row, error: insertErr } = await admin
      .from("email_otps")
      .insert({
        email,
        purpose,
        otp_hash: otpHash,
        expires_at: expiresAt,
        attempts: 0,
        max_attempts: 5,
      })
      .select("id")
      .single();

    if (insertErr) throw insertErr;

    let emailSent = false;
    if (!DEV_MODE) {
      const sent = await sendResendEmail({
        to: email,
        subject: "Reset Your KULMIS ERP Password",
        html: passwordResetEmailHtml(code),
        text:
          `Your verification code is:\n\n${code}\n\nThis code expires in 10 minutes.\n\nKULMIS ERP`,
      });
      if (!sent.ok) {
        console.error("[send-email-otp] Resend failed:", sent.error);
        const hint = sent.error.includes("domain") ||
            sent.error.includes("verify")
          ? "Email domain not verified in Resend. Contact support."
          : sent.error.includes("RESEND_API_KEY")
          ? "Email service not configured."
          : "Could not send email. Check spam folder or try again.";
        return json({ error: hint }, 502);
      }
      emailSent = true;
    }

    return json({
      request_id: row.id,
      expires_in_sec: OTP_TTL_SEC,
      resend_cooldown_sec: RESEND_COOLDOWN_SEC,
      dev_mode: DEV_MODE,
      email_sent: emailSent,
      dev_otp: DEV_MODE ? code : undefined,
    });
  } catch (e) {
    console.error("[send-email-otp]", e);
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
