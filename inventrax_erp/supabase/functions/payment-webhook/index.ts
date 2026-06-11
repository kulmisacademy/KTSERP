// Payment webhook — verify Waafi callbacks before activating subscriptions/SMS.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-webhook-secret, x-webhook-signature",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const secret = Deno.env.get("PAYMENT_WEBHOOK_SECRET") ?? "";
    const incoming = req.headers.get("x-webhook-secret") ?? "";
    if (secret && incoming !== secret) {
      return json({ error: "Invalid webhook secret" }, 401);
    }

    const body = await req.json();
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceKey);

    const eventId = crypto.randomUUID();
    const provider = String(body.provider ?? "waafi");

    const referenceId = String(
      body.referenceId ?? body.reference_id ?? body.provider_reference_id ?? "",
    );
    let transactionId = String(
      body.transaction_id ?? body.internal_transaction_id ?? "",
    );
    const providerTxId = String(
      body.provider_transaction_id ?? body.transactionId ??
        body.params?.transactionId ?? "",
    );
    const waafiState = String(
      body.state ?? body.params?.state ?? "",
    ).toUpperCase();
    const status = resolveStatus(body, waafiState);

    if (!transactionId && referenceId) {
      const { data: row } = await admin
        .from("payment_transactions")
        .select("id")
        .eq("provider_reference_id", referenceId)
        .maybeSingle();
      if (row?.id) transactionId = String(row.id);
    }

    await admin.from("payment_webhook_events").insert({
      id: eventId,
      provider,
      event_type: body.event_type ?? body.serviceName ?? "payment.callback",
      transaction_id: transactionId || null,
      payload: body,
      processed: false,
    });

    if (!transactionId) {
      return json({ error: "transaction_id or referenceId required" }, 400);
    }

    if (status === "completed") {
      const { error } = await admin.rpc("inventrax_billing_fulfill_payment", {
        p_transaction_id: transactionId,
        p_provider_transaction_id: providerTxId || null,
        p_status: "completed",
      });
      if (error) {
        await admin.from("payment_webhook_events").update({
          processed: false,
          error_message: error.message,
        }).eq("id", eventId);
        return json({ error: error.message }, 500);
      }
    } else if (
      status === "failed" || status === "cancelled" || status === "expired"
    ) {
      await admin.from("payment_transactions").update({
        status,
        error_message: String(
          body.error ?? body.message ?? body.responseMsg ?? "Webhook failed",
        ),
        provider_transaction_id: providerTxId || null,
        updated_at: new Date().toISOString(),
      }).eq("id", transactionId);
    }

    await admin.from("payment_webhook_events").update({
      processed: true,
    }).eq("id", eventId);

    return json({ success: true, event_id: eventId, status });
  } catch (e) {
    console.error("[payment-webhook]", e);
    return json(
      { error: e instanceof Error ? e.message : "Internal error" },
      500,
    );
  }
});

function resolveStatus(
  body: Record<string, unknown>,
  waafiState: string,
): string {
  const explicit = String(body.status ?? "").toLowerCase();
  if (explicit) return explicit;

  const code = String(body.responseCode ?? "");
  if (code === "2001" || waafiState === "APPROVED" || waafiState === "COMPLETED") {
    return "completed";
  }
  if (waafiState === "CANCELLED" || waafiState === "REJECTED") {
    return "cancelled";
  }
  if (code.startsWith("520")) return "failed";
  return "failed";
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
