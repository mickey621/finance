exports.handler = async () => {
  const config = {
    SUPABASE_URL: process.env.SUPABASE_URL || "https://qxgxszsjlkebolrndeas.supabase.co",
    SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || "sb_publishable_4mQ2T7yNYBuzpvAq-YhbXA_thRyDhEt"
  };

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/javascript; charset=utf-8",
      "Cache-Control": "no-store"
    },
    body: `window.__APP_CONFIG__ = ${JSON.stringify(config)};`
  };
};
