import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// ── Types ─────────────────────────────────────────────────────────────────────

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

interface PushQueueItem {
  id: string;
  user_id: string;
  title: string;
  body: string;
  data: Record<string, unknown>;
}

interface DeviceToken {
  token: string;
  platform: "ios" | "android" | "web";
}

// ── Env ───────────────────────────────────────────────────────────────────────

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const serviceAccountJson = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON") ?? "";

const supabase = createClient(supabaseUrl, supabaseServiceKey);

// ── OAuth 2.0 via service-account JWT (FCM HTTP v1 API) ───────────────────────

function base64url(data: Uint8Array): string {
  const bytes = Array.from(data);
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(
    new TextEncoder().encode(JSON.stringify({ alg: "RS256", typ: "JWT" })),
  );
  const payload = base64url(
    new TextEncoder().encode(
      JSON.stringify({
        iss: sa.client_email,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
      }),
    ),
  );

  const signingInput = `${header}.${payload}`;

  const pemKey = sa.private_key.replace(/\\n/g, "\n");
  const pemBody = pemKey
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const keyBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(signingInput),
  );

  const jwt = `${signingInput}.${base64url(new Uint8Array(signature))}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenRes.json() as { access_token: string };
  return tokenData.access_token;
}

// ── FCM HTTP v1 send ──────────────────────────────────────────────────────────

async function sendFcmV1(
  accessToken: string,
  projectId: string,
  deviceToken: string,
  platform: string,
  title: string,
  body: string,
  data: Record<string, unknown>,
): Promise<{ ok: boolean; error?: string }> {
  const stringData = Object.fromEntries(
    Object.entries(data).map(([k, v]) => [k, String(v)]),
  );

  const message: Record<string, unknown> = {
    token: deviceToken,
    notification: { title, body },
    data: stringData,
    android: {
      priority: "high",
      notification: { channel_id: "unify_notifications", sound: "default" },
    },
    apns: {
      payload: {
        aps: {
          alert: { title, body },
          sound: "default",
          badge: 1,
          "content-available": 1,
        },
      },
    },
  };

  if (platform === "web") {
    // Web push doesn't use android/apns blocks
    delete message.android;
    delete message.apns;
  }

  try {
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({ message }),
      },
    );

    if (!res.ok) {
      const text = await res.text();
      return { ok: false, error: `FCM ${res.status}: ${text}` };
    }
    return { ok: true };
  } catch (err) {
    return { ok: false, error: String(err) };
  }
}

// ── Batch processor ───────────────────────────────────────────────────────────

async function processBatch(): Promise<{ sent: number; failed: number }> {
  if (!serviceAccountJson) {
    console.error("GOOGLE_SERVICE_ACCOUNT_JSON secret is not set");
    return { sent: 0, failed: 0 };
  }

  const sa = JSON.parse(serviceAccountJson) as ServiceAccount;
  const accessToken = await getAccessToken(sa);

  const { data: queue, error } = await supabase
    .from("push_notification_queue")
    .select("id, user_id, title, body, data")
    .eq("status", "pending")
    .order("created_at")
    .limit(50);

  if (error || !queue?.length) {
    if (error) console.error("Queue fetch error:", error);
    return { sent: 0, failed: 0 };
  }

  let sent = 0;
  let failed = 0;

  for (const item of queue as PushQueueItem[]) {
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("token, platform")
      .eq("user_id", item.user_id)
      .eq("is_active", true);

    if (!tokens?.length) {
      await supabase
        .from("push_notification_queue")
        .update({ status: "failed", error_message: "No device tokens" })
        .eq("id", item.id);
      failed++;
      continue;
    }

    let anySucceeded = false;
    const errors: string[] = [];

    for (const device of tokens as DeviceToken[]) {
      const result = await sendFcmV1(
        accessToken,
        sa.project_id,
        device.token,
        device.platform,
        item.title,
        item.body,
        item.data ?? {},
      );
      if (result.ok) {
        anySucceeded = true;
      } else {
        console.error(`FCM fail [${item.id}] ${device.platform}: ${result.error}`);
        errors.push(result.error ?? "unknown");
      }
    }

    const updateData: Record<string, unknown> = {
      status: anySucceeded ? "sent" : "failed",
      sent_at: anySucceeded ? new Date().toISOString() : null,
    };
    if (!anySucceeded) updateData.error_message = errors.join("; ");

    await supabase
      .from("push_notification_queue")
      .update(updateData)
      .eq("id", item.id);

    if (anySucceeded) sent++;
    else failed++;
  }

  return { sent, failed };
}

// ── Entry point ───────────────────────────────────────────────────────────────

serve(async (_req) => {
  try {
    const result = await processBatch();
    return new Response(JSON.stringify({ ok: true, ...result }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Fatal error:", err);
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
