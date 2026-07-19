import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts";

const VALID_DOMAINS = [
  "@gctu.edu.gh", "@knust.edu.gh", "@ug.edu.gh",
  "@ucc.edu.gh", "@st.ug.edu.gh", "@std.uew.edu.gh",
  "@uds.edu.gh", "@upsa.edu.gh", "@uenr.edu.gh",
];

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

    const { email } = await req.json();
    if (!email || !VALID_DOMAINS.some((d) => email.endsWith(d))) {
      return new Response(JSON.stringify({ error: "Invalid university email" }), { status: 400 });
    }

    const code = (100000 + Math.floor(Math.random() * 900000)).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();

    const { error: dbError } = await supabase
      .from("email_verifications")
      .upsert({ user_id: user.id, email, code, expires_at: expiresAt, verified: false });

    if (dbError) throw dbError;

    const client = new SMTPClient({
      connection: {
        hostname: Deno.env.get("SMTP_HOST")!,
        port: Number(Deno.env.get("SMTP_PORT")!),
        tls: true,
        auth: {
          username: Deno.env.get("SMTP_USER")!,
          password: Deno.env.get("SMTP_PASS")!,
        },
      },
    });

    await client.send({
      from: Deno.env.get("SMTP_FROM")!,
      to: email,
      subject: "Your UNIFY verification code",
      content: `Your verification code is ${code}. It expires in 10 minutes.`,
    });
    await client.close();

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
