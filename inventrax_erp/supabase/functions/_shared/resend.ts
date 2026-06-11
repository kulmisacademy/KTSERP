export type ResendSendResult =
  | { ok: true; id: string }
  | { ok: false; error: string };

export async function sendResendEmail(opts: {
  to: string;
  subject: string;
  html: string;
  text?: string;
}): Promise<ResendSendResult> {
  const apiKey = Deno.env.get("RESEND_API_KEY")?.trim();
  const fromEmail = Deno.env.get("RESEND_FROM_EMAIL")?.trim() ??
    "noreply@kulmiserp.com";
  const fromName = Deno.env.get("RESEND_FROM_NAME")?.trim() ?? "KULMIS ERP";

  if (!apiKey) {
    return { ok: false, error: "RESEND_API_KEY not configured" };
  }

  const from = `${fromName} <${fromEmail}>`;
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to: [opts.to],
      subject: opts.subject,
      html: opts.html,
      text: opts.text ?? stripHtml(opts.html),
    }),
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = (data as { message?: string }).message ??
      `Resend HTTP ${res.status}`;
    return { ok: false, error: msg };
  }

  const id = (data as { id?: string }).id ?? "";
  return { ok: true, id };
}

function stripHtml(html: string): string {
  return html.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
}

export function passwordResetEmailHtml(code: string): string {
  return `
    <div style="font-family:Inter,Arial,sans-serif;max-width:480px;margin:0 auto;padding:24px">
      <h2 style="color:#0d9488;margin:0 0 16px">KULMIS ERP</h2>
      <p style="color:#334155;line-height:1.6">Your verification code is:</p>
      <p style="font-size:32px;font-weight:800;letter-spacing:6px;color:#0f172a;margin:16px 0">${code}</p>
      <p style="color:#64748b;font-size:14px">This code expires in 10 minutes.</p>
      <p style="color:#94a3b8;font-size:12px;margin-top:32px">KULMIS ERP</p>
    </div>
  `.trim();
}
