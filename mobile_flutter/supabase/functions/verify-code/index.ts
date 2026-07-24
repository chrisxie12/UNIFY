import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization")!;
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return new Response(JSON.stringify({ error: "Not authenticated" }), { status: 401 });
    }

    const { code } = await req.json();

    const { data: row, error } = await supabase
      .from("email_verifications")
      .select("*")
      .eq("user_id", user.id)
      .single();

    if (error || !row) {
      return new Response(JSON.stringify({ error: "No verification pending" }), { status: 400 });
    }
    if (new Date(row.expires_at) < new Date()) {
      return new Response(JSON.stringify({ error: "Code expired" }), { status: 400 });
    }
    if (row.code !== code) {
      return new Response(JSON.stringify({ error: "Invalid code" }), { status: 400 });
    }

    await supabase.from("email_verifications").update({ verified: true }).eq("user_id", user.id);

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
