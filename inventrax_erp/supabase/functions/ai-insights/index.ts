// Secure OpenAI proxy — API key stays in Supabase secrets only.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `You are InventraX AI — an expert retail ERP business analyst for store owners.
You receive ONLY pre-aggregated JSON metrics (never raw transactions).
Respond with valid JSON only (no markdown fences) using this schema:
{
  "summary": "2-4 sentences, clear executive summary",
  "metrics": [{"label": "string", "value": "string"}],
  "recommendations": ["actionable bullet strings"],
  "warnings": ["risk bullet strings"],
  "opportunities": ["growth bullet strings"],
  "charts": [{"type": "revenue_trend|profit_trend|expense_comparison|product_performance|inventory", "title": "string", "subtitle": "optional"}]
}
Rules:
- Use the store currency when mentioning money (convert cents to major units).
- Be specific; cite numbers from the payload.
- Max 5 recommendations, 4 warnings, 3 opportunities, 6 metrics.
- Suggest chart types that match available data in the payload.
- If data is sparse, say so honestly.
- ALWAYS respond in the language specified in the user payload (language / language_code). All summary, metrics, recommendations, warnings, opportunities, and chart titles must use that language.
- Answer ONLY the current question. prior_turns are context only — never copy them verbatim.
- Each bullet must be unique; do not duplicate facts between summary and lists.`;

const MONTHLY_PROMPT =
  "Generate an executive MONTHLY business report for the store owner. " +
  "Highlight revenue, profit, top risks, inventory issues, debts, and 3 priorities for next month.";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing authorization" }, 401);
    }

    const openAiKey = Deno.env.get("OPENAI_API_KEY");
    if (!openAiKey) {
      return json(
        { error: "OPENAI_API_KEY not configured on server. Set Supabase Edge secret." },
        503,
      );
    }

    const body = await req.json();
    const question = String(body.question ?? "").trim();
    const analytics = body.analytics ?? {};
    const detectedRisks = String(body.detected_risks ?? "");
    const reportType = String(body.report_type ?? "chat");
    const model = String(body.model ?? Deno.env.get("OPENAI_MODEL") ?? "gpt-4o-mini");
    const language = String(body.language ?? "English");
    const languageCode = String(body.language_code ?? "en");
    const priorTurns = Array.isArray(body.prior_turns) ? body.prior_turns : [];
    const stream = body.stream === true;

    if (!question && reportType !== "monthly") {
      return json({ error: "question is required" }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const caller = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userErr } = await caller.auth.getUser();
    if (userErr || !userData.user) {
      return json({ error: "Unauthorized" }, 401);
    }

    const userQuestion =
      reportType === "monthly"
        ? MONTHLY_PROMPT
        : question;

    const userPayload = JSON.stringify({
      question: userQuestion,
      report_type: reportType,
      analytics,
      detected_risks: detectedRisks,
      language,
      language_code: languageCode,
      prior_turns: priorTurns,
      instruction: `Respond entirely in ${language}. Answer the current question only; do not repeat prior_turns.`,
    });

    const openAiBody: Record<string, unknown> = {
      model,
      temperature: 0.35,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        {
          role: "user",
          content: `Analyze this store data and answer:\n${userPayload}`,
        },
      ],
    };

    if (stream) {
      openAiBody.stream = true;
    } else {
      openAiBody.response_format = { type: "json_object" };
    }

    const openAiRes = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${openAiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(openAiBody),
    });

    if (stream) {
      if (!openAiRes.ok) {
        const errBody = await openAiRes.text();
        return json(
          { error: errBody || "OpenAI stream request failed" },
          openAiRes.status === 429 ? 429 : 502,
        );
      }
      return new Response(openAiRes.body, {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          Connection: "keep-alive",
        },
      });
    }

    const openAiJson = await openAiRes.json();
    if (!openAiRes.ok) {
      return json(
        {
          error: openAiJson?.error?.message ?? "OpenAI request failed",
          status: openAiRes.status,
        },
        openAiRes.status === 429 ? 429 : 502,
      );
    }

    const content =
      openAiJson?.choices?.[0]?.message?.content ?? "{}";
    let parsed: Record<string, unknown>;
    try {
      parsed = JSON.parse(content);
    } catch {
      parsed = { summary: content, metrics: [], recommendations: [], warnings: [], opportunities: [], charts: [] };
    }

    return json({ response: parsed }, 200);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
