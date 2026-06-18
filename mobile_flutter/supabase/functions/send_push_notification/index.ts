import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

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

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const fcmServerKey = Deno.env.get("FCM_SERVER_KEY") ?? "";

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function sendFcmMessage(
  token: string,
  platform: string,
  title: string,
  body: string,
  data: Record<string, unknown>,
): Promise<{ ok: boolean; error?: string }> {
  const message: Record<string, unknown> = {
    to: token,
    notification: { title, body },
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)]),
    ),
  };

  if (platform === "ios") {
    message.content_available = true;
    message.priority = "high";
  }

  try {
    const response = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${fcmServerKey}`,
      },
      body: JSON.stringify(message),
    });

    if (!response.ok) {
      const text = await response.text();
      return { ok: false, error: `FCM ${response.status}: ${text}` };
    }
    return { ok: true };
  } catch (err) {
    return { ok: false, error: String(err) };
  }
}

async function processBatch(): Promise<{ sent: number; failed: number }> {
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

    let allFailed = true;
    for (const device of tokens as DeviceToken[]) {
      const result = await sendFcmMessage(
        device.token,
        device.platform,
        item.title,
        item.body,
        item.data ?? {},
      );

      if (result.ok) {
        allFailed = false;
      } else {
        console.error(`FCM fail for ${item.id} -> ${device.platform}: ${result.error}`);
      }
    }

    const status = allFailed ? "failed" : "sent";
    const updateData: Record<string, unknown> = {
      status,
      sent_at: allFailed ? null : new Date().toISOString(),
    };
    if (allFailed) {
      updateData.error_message = "All device deliveries failed";
    }

    await supabase.from("push_notification_queue").update(updateData).eq("id", item.id);

    if (allFailed) failed++;
    else sent++;
  }

  return { sent, failed };
}

serve(async (_req) => {
  try {
    const result = await processBatch();
    return new Response(
      JSON.stringify({ ok: true, ...result }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Fatal error:", err);
    return new Response(
      JSON.stringify({ ok: false, error: String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
