// Waafi mobile push payment — async PIN confirmation on customer phone.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { normalizeSomaliPhone } from "../_shared/phone_normalizer.ts";
import { waafiPushAndCommit } from "../_shared/waafi.ts";

declare const EdgeRuntime: { waitUntil(promise: Promise<unknown>): void };

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const PUSH_TIMEOUT_MS = 120_000;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const admin = createClient(supabaseUrl, serviceKey);

    const { data: { user } } = await userClient.auth.getUser();
    if (!user) {
      return json({ error: "Unauthorized" }, 401);
    }

    const body = await req.json();
    const paymentType = String(body.payment_type ?? "subscription");
    const planId = body.plan_id ? String(body.plan_id) : null;
    const smsPackageId = body.sms_package_id
      ? String(body.sms_package_id)
      : null;
    const billingCycle = String(body.billing_cycle ?? "monthly");
    const rawPhone = String(body.payer_phone ?? body.phone ?? "");

    const phoneResult = normalizeSomaliPhone(rawPhone);
    if (!phoneResult.ok || !phoneResult.e164) {
      return json({
        error: phoneResult.error ?? "Valid payer phone required",
      }, 400);
    }

    const { data: pending, error: createErr } = await userClient.rpc(
      "inventrax_billing_create_payment",
      {
        p_payment_type: paymentType,
        p_plan_id: planId,
        p_sms_package_id: smsPackageId,
        p_billing_cycle: billingCycle,
        p_payer_phone: phoneResult.e164,
      },
    );

    if (createErr) {
      return json({ error: createErr.message }, 400);
    }

    const tx = pending as Record<string, unknown>;
    const transactionId = String(tx.transaction_id ?? "");
    const referenceId = String(tx.reference_id ?? transactionId);
    const amountCents = Number(tx.amount_cents ?? 0);
    const currency = String(tx.currency_code ?? "USD");
    const amount = formatWaafiAmount(amountCents);
    const invoiceId = transactionId.replace(/[^a-zA-Z0-9._-]/g, "").slice(0, 32);

    const merchantUid = Deno.env.get("WAAFI_MERCHANT_UID") ?? "";
    const apiUserId = Deno.env.get("WAAFI_API_USER_ID") ?? "";
    const apiKey = Deno.env.get("WAAFI_API_KEY") ?? "";
    const sandbox = Deno.env.get("WAAFI_SANDBOX") !== "false";
    const devMode = Deno.env.get("WAAFI_DEV_MODE") === "true";

    await admin.from("payment_transactions").update({
      status: "processing",
      metadata: {
        push_sent_at: new Date().toISOString(),
        payer_phone_masked: phoneResult.e164.slice(0, 6) + "****",
        flow: "mobile_push",
      },
      updated_at: new Date().toISOString(),
    }).eq("id", transactionId);

    EdgeRuntime.waitUntil(
      processPushPayment({
        admin,
        transactionId,
        referenceId,
        invoiceId: invoiceId || referenceId,
        amount,
        currency,
        paymentType,
        payerPhone: phoneResult.e164,
        merchantUid,
        apiUserId,
        apiKey,
        sandbox,
        devMode,
      }),
    );

    return json({
      status: "processing",
      transaction_id: transactionId,
      reference_id: referenceId,
      message:
        "Payment push sent to your phone. Check your mobile and enter your PIN.",
      hint: sandbox
        ? "Sandbox: approve on test wallet 252611111111 (PIN 1212)"
        : undefined,
    }, 202);
  } catch (e) {
    console.error("[waafi-payment]", e);
    return json(
      { error: e instanceof Error ? e.message : "Internal error" },
      500,
    );
  }
});

async function processPushPayment(ctx: {
  admin: ReturnType<typeof createClient>;
  transactionId: string;
  referenceId: string;
  invoiceId: string;
  amount: string;
  currency: string;
  paymentType: string;
  payerPhone: string;
  merchantUid: string;
  apiUserId: string;
  apiKey: string;
  sandbox: boolean;
  devMode: boolean;
}): Promise<void> {
  const {
    admin,
    transactionId,
    referenceId,
    invoiceId,
    amount,
    currency,
    paymentType,
    payerPhone,
    merchantUid,
    apiUserId,
    apiKey,
    sandbox,
    devMode,
  } = ctx;

  const fail = async (
    message: string,
    providerTxId?: string,
    waafiMeta?: Record<string, unknown>,
  ) => {
    const { data: existing } = await admin.from("payment_transactions")
      .select("metadata")
      .eq("id", transactionId)
      .single();
    const prevMeta = (existing?.metadata ?? {}) as Record<string, unknown>;
    await admin.from("payment_transactions").update({
      status: "failed",
      error_message: message,
      provider_transaction_id: providerTxId ?? null,
      metadata: { ...prevMeta, ...waafiMeta, failed_at: new Date().toISOString() },
      updated_at: new Date().toISOString(),
    }).eq("id", transactionId);
  };

  const expire = async (message: string) => {
    await admin.from("payment_transactions").update({
      status: "expired",
      error_message: message,
      updated_at: new Date().toISOString(),
    }).eq("id", transactionId);
  };

  try {
    if (devMode) {
      await new Promise((r) => setTimeout(r, 2500));
      const ok = await fulfillSmsOrSubscription(
        admin,
        transactionId,
        `dev-${transactionId}`,
        paymentType,
      );
      if (!ok) {
        await fail("Payment simulated but SMS wallet activation failed");
      }
      return;
    }

    if (!merchantUid || !apiUserId || !apiKey) {
      await fail("Waafi credentials not configured");
      return;
    }

    const result = await Promise.race([
      waafiPushAndCommit({
        sandbox,
        merchantUid,
        apiUserId,
        apiKey,
        payerAccountNo: payerPhone,
        referenceId,
        invoiceId,
        amount,
        currency,
        description: `KULMIS ERP ${paymentType}`,
      }),
      new Promise<null>((resolve) =>
        setTimeout(() => resolve(null), PUSH_TIMEOUT_MS)
      ),
    ]);

    if (result === null) {
      await expire(
        "Payment timed out. No PIN confirmation received within 2 minutes.",
      );
      return;
    }

    if (!result.success) {
      const raw = result.raw as Record<string, unknown> | undefined;
      await fail(
        result.errorMessage ?? "Waafi payment failed",
        result.transactionId,
        {
          waafi_response_code: result.responseCode ?? raw?.responseCode,
          waafi_response_msg: raw?.responseMsg,
          waafi_sandbox: sandbox,
        },
      );
      return;
    }

    const ok = await fulfillSmsOrSubscription(
      admin,
      transactionId,
      result.transactionId ?? referenceId,
      paymentType,
    );

    if (!ok) {
      await fail(
        "Payment received but SMS credits were not applied. Support has been notified.",
        result.transactionId,
      );
    }
  } catch (e) {
    console.error("[waafi-payment] async error", e);
    await fail(e instanceof Error ? e.message : "Payment processing error");
  }
}

async function fulfillSmsOrSubscription(
  admin: ReturnType<typeof createClient>,
  transactionId: string,
  providerTxId: string,
  paymentType: string,
): Promise<boolean> {
  const { data: fulfilled, error: fulfillErr } = await admin.rpc(
    "inventrax_billing_fulfill_payment",
    {
      p_transaction_id: transactionId,
      p_provider_transaction_id: providerTxId,
      p_status: "completed",
    },
  );

  if (fulfillErr) {
    console.error("[waafi-payment] fulfill error", fulfillErr);
    return false;
  }

  const row = fulfilled as Record<string, unknown> | null;
  if (paymentType === "sms_package") {
    const credits = Number(row?.sms_credits_added ?? 0);
    const balance = Number(row?.wallet_balance ?? 0);
    if (credits <= 0 && row?.already_fulfilled !== true) {
      const { data: recovered } = await admin.rpc(
        "inventrax_finalize_sms_purchase",
        { p_transaction_id: transactionId },
      );
      const rec = recovered as Record<string, unknown> | null;
      return Number(rec?.sms_credits_added ?? 0) > 0 ||
        Number(rec?.balance_remaining ?? 0) > 0;
    }
    return credits > 0 || balance > 0 || row?.already_fulfilled === true;
  }

  return row?.success === true;
}

function formatWaafiAmount(cents: number): string {
  const v = cents / 100;
  return Number.isInteger(v) ? String(v) : v.toFixed(2);
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
