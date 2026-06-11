// WaafiPay mobile push payments — API_PREAUTHORIZE → PIN on phone → COMMIT
// https://docs.waafipay.com/preauthorization-api

export type WaafiPushResult = {
  success: boolean;
  responseCode?: string;
  transactionId?: string;
  state?: string;
  errorMessage?: string;
  raw?: unknown;
};

function friendlyWaafiMessage(
  code: string,
  msg: string,
  sandbox: boolean,
): string {
  if (code === "5301") {
    return "Invalid Waafi API credentials (check merchant UID, API user ID, and API key).";
  }
  if (code === "5308") {
    return "Merchant not enabled for API purchases — contact Waafi support.";
  }
  if (code.startsWith("520")) {
    if (msg.toLowerCase().includes("reject") || code === "5202") {
      return "Payment rejected on your phone. You cancelled or declined the request.";
    }
    if (msg.toLowerCase().includes("balance") || code === "5204") {
      return "Insufficient wallet balance. Top up your mobile wallet and try again.";
    }
    if (msg.toLowerCase().includes("pin") || code === "5203") {
      return "Wrong PIN entered. Please try again.";
    }
    return msg || "Payment failed on mobile wallet. Please try again.";
  }
  if (code === "5001" || msg.toLowerCase().includes("could not be processed")) {
    if (msg.toLowerCase().includes("authentication failed")) {
      if (sandbox) {
        return "Waafi sandbox authentication failed. Your API keys are production keys — "
          + "set WAAFI_SANDBOX=false or get sandbox credentials from Waafi.";
      }
      return "Waafi authentication failed. Check WAAFI_MERCHANT_UID, WAAFI_API_USER_ID, and WAAFI_API_KEY.";
    }
    if (sandbox) {
      return "Sandbox payment rejected. Use test wallet 252611111111 (EVC Plus, PIN 1212).";
    }
    return "Waafi could not process payment — check wallet number (25261…), balance, and credentials.";
  }
  if (code === "5206" || msg.toLowerCase().includes("push notification")) {
    return "Waafi could not send payment push to this number. Use your real EVC/Zaad wallet "
      + "(061… or 25261…) with sufficient balance.";
  }
  return msg || "Waafi payment declined";
}

export function waafiBaseUrl(sandbox: boolean): string {
  return sandbox
    ? "https://sandbox.waafipay.com/asm"
    : "https://api.waafipay.net/asm";
}

function waafiTimestamp(): string {
  return new Date().toISOString().replace("T", " ").slice(0, 19);
}

/** Waafi docs show apiUserId/merchantUid as unquoted JSON numbers when numeric. */
function waafiCredential(value: string): string | number {
  const trimmed = value.trim();
  if (/^\d+$/.test(trimmed)) return Number(trimmed);
  return trimmed;
}

async function waafiPost(
  sandbox: boolean,
  body: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const res = await fetch(waafiBaseUrl(sandbox), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  return await res.json().catch(() => ({})) as Record<string, unknown>;
}

function parseWaafiResponse(
  raw: Record<string, unknown>,
  sandbox: boolean,
): WaafiPushResult {
  const responseCode = String(raw?.responseCode ?? "");
  const params = raw?.params as Record<string, unknown> | undefined;
  const state = String(params?.state ?? "");
  const transactionId = String(
    params?.transactionId ?? params?.issuerTransactionId ?? "",
  );

  const ok =
    responseCode === "2001" &&
    (state.toUpperCase() === "APPROVED" ||
      state.toLowerCase() === "forapproval" ||
      state === "");

  if (!ok) {
    const errMsg = friendlyWaafiMessage(
      responseCode,
      String(raw?.responseMsg ?? params?.description ?? "Waafi payment declined"),
      sandbox,
    );
    return {
      success: false,
      responseCode,
      state,
      transactionId: transactionId || undefined,
      errorMessage: errMsg,
      raw,
    };
  }

  return {
    success: true,
    responseCode,
    transactionId: transactionId || undefined,
    state,
    raw,
  };
}

/** Sends mobile push — blocks until customer enters PIN on phone. */
export async function waafiPreAuthorizePush(input: {
  sandbox: boolean;
  merchantUid: string;
  apiUserId: string;
  apiKey: string;
  payerAccountNo: string;
  referenceId: string;
  invoiceId: string;
  amount: string;
  currency: string;
  description: string;
}): Promise<WaafiPushResult> {
  const requestId = crypto.randomUUID();
  const body = {
    schemaVersion: "1.0",
    requestId,
    timestamp: waafiTimestamp(),
    channelName: "WEB",
    serviceName: "API_PREAUTHORIZE",
    serviceParams: {
      merchantUid: waafiCredential(input.merchantUid),
      apiUserId: waafiCredential(input.apiUserId),
      apiKey: input.apiKey.trim(),
      paymentMethod: "MWALLET_ACCOUNT",
      payerInfo: { accountNo: input.payerAccountNo },
      transactionInfo: {
        referenceId: input.referenceId,
        invoiceId: input.invoiceId,
        amount: input.amount,
        currency: input.currency,
        description: input.description.slice(0, 255),
      },
    },
  };

  console.log("[waafi] preauthorize push", {
    sandbox: input.sandbox,
    referenceId: input.referenceId,
    amount: input.amount,
    payer: input.payerAccountNo.slice(0, 6) + "****",
  });

  try {
    const raw = await waafiPost(input.sandbox, body);
    const result = parseWaafiResponse(raw, input.sandbox);
    if (!result.success) {
      console.error("[waafi] preauthorize declined", {
        responseCode: result.responseCode,
        state: result.state,
        raw,
      });
    }
    return result;
  } catch (e) {
    return {
      success: false,
      errorMessage: e instanceof Error ? e.message : "Waafi push request failed",
    };
  }
}

/** Captures funds after customer approved push on phone. */
export async function waafiPreAuthorizeCommit(input: {
  sandbox: boolean;
  merchantUid: string;
  apiUserId: string;
  apiKey: string;
  transactionId: string;
  referenceId: string;
  description?: string;
}): Promise<WaafiPushResult> {
  const body = {
    schemaVersion: "1.0",
    requestId: crypto.randomUUID(),
    timestamp: waafiTimestamp(),
    channelName: "WEB",
    serviceName: "API_PREAUTHORIZE_COMMIT",
    serviceParams: {
      merchantUid: waafiCredential(input.merchantUid),
      apiUserId: waafiCredential(input.apiUserId),
      apiKey: input.apiKey.trim(),
      transactionId: input.transactionId,
      referenceId: input.referenceId,
      description: input.description ?? "KULMIS ERP payment",
    },
  };

  try {
    const raw = await waafiPost(input.sandbox, body);
    return parseWaafiResponse(raw, input.sandbox);
  } catch (e) {
    return {
      success: false,
      errorMessage: e instanceof Error ? e.message : "Waafi commit failed",
    };
  }
}

/** Releases held funds when payment is cancelled or times out. */
export async function waafiPreAuthorizeCancel(input: {
  sandbox: boolean;
  merchantUid: string;
  apiUserId: string;
  apiKey: string;
  transactionId: string;
  referenceId: string;
  description?: string;
}): Promise<WaafiPushResult> {
  const body = {
    schemaVersion: "1.0",
    requestId: crypto.randomUUID(),
    timestamp: waafiTimestamp(),
    channelName: "WEB",
    serviceName: "API_PREAUTHORIZE_CANCEL",
    serviceParams: {
      merchantUid: waafiCredential(input.merchantUid),
      apiUserId: waafiCredential(input.apiUserId),
      apiKey: input.apiKey.trim(),
      transactionId: input.transactionId,
      referenceId: input.referenceId,
      description: input.description ?? "Payment cancelled",
    },
  };

  try {
    const raw = await waafiPost(input.sandbox, body);
    return parseWaafiResponse(raw, input.sandbox);
  } catch (e) {
    return {
      success: false,
      errorMessage: e instanceof Error ? e.message : "Waafi cancel failed",
    };
  }
}

/** Full push flow: preauthorize (PIN on phone) → commit. */
export async function waafiPushAndCommit(input: {
  sandbox: boolean;
  merchantUid: string;
  apiUserId: string;
  apiKey: string;
  payerAccountNo: string;
  referenceId: string;
  invoiceId: string;
  amount: string;
  currency: string;
  description: string;
}): Promise<WaafiPushResult> {
  const push = await waafiPreAuthorizePush(input);
  if (!push.success || !push.transactionId) {
    return push;
  }

  const commit = await waafiPreAuthorizeCommit({
    sandbox: input.sandbox,
    merchantUid: input.merchantUid,
    apiUserId: input.apiUserId,
    apiKey: input.apiKey,
    transactionId: push.transactionId,
    referenceId: input.referenceId,
    description: input.description,
  });

  if (!commit.success) {
    await waafiPreAuthorizeCancel({
      sandbox: input.sandbox,
      merchantUid: input.merchantUid,
      apiUserId: input.apiUserId,
      apiKey: input.apiKey,
      transactionId: push.transactionId,
      referenceId: input.referenceId,
    });
    return commit;
  }

  return {
    ...commit,
    transactionId: push.transactionId,
  };
}
