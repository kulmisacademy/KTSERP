// Password reset after Resend email OTP verification.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { hashSecret, normalizeEmail, RESET_TOKEN_TTL_SEC } from "../_shared/email_otp.ts";

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
    const resetToken = String(body.reset_token ?? "").trim();
    const requestId = String(body.request_id ?? "");
    const newPassword = String(body.new_password ?? "");

    if (!email || !resetToken || !requestId || newPassword.length < 8) {
      return json({
        error: "email, request_id, reset_token, and new_password (8+) required",
      }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceKey);

    const { data: otpRow, error: otpErr } = await admin
      .from("email_otps")
      .select("id, email, verified_at, reset_token_hash, used_at, purpose")
      .eq("id", requestId)
      .eq("email", email)
      .eq("purpose", "password_reset")
      .maybeSingle();

    if (otpErr) throw otpErr;
    if (!otpRow?.verified_at || !otpRow.reset_token_hash) {
      return json({ error: "OTP not verified or expired" }, 400);
    }
    if (otpRow.used_at) {
      return json({ error: "Reset token already used" }, 400);
    }

    const verifiedAt = new Date(otpRow.verified_at).getTime();
    if (Date.now() - verifiedAt > RESET_TOKEN_TTL_SEC * 1000) {
      return json({ error: "Verification expired. Start again." }, 400);
    }

    const tokenHash = await hashSecret(resetToken);
    if (tokenHash !== otpRow.reset_token_hash) {
      return json({ error: "Invalid reset session" }, 400);
    }

    const { data: profile } = await admin
      .from("profiles")
      .select("id, email")
      .eq("email", email)
      .maybeSingle();

    let userId = profile?.id as string | undefined;

    if (!userId) {
      const { data: authData } = await admin.auth.admin.listUsers();
      const user = authData.users.find((u) => u.email?.toLowerCase() === email);
      userId = user?.id;
    }

    if (!userId) {
      return json({ error: "Account not found" }, 404);
    }

    const { error: updateErr } = await admin.auth.admin.updateUserById(
      userId,
      { password: newPassword },
    );

    if (updateErr) {
      console.error("[reset-password] auth update failed", updateErr);
      return json({ error: updateErr.message }, 500);
    }

    await admin.from("email_otps").update({
      used_at: new Date().toISOString(),
    }).eq("id", requestId);

    return json({ success: true, email });
  } catch (e) {
    console.error("[reset-password]", e);
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
