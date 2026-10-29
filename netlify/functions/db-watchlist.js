import { neon } from '@neondatabase/serverless';

export default async (req, context) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers });
  }

  try {
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
      return new Response(
        JSON.stringify({ status: 'local_sync', message: 'Synced to browser storage (set DATABASE_URL for NeonDB cloud persistence)' }),
        { status: 200, headers }
      );
    }

    const sql = neon(dbUrl);

    if (req.method === 'POST') {
      const body = await req.json();
      const { user_handle = 'cyber_otaku', media_id, watch_status = 'Watching', current_episode = 1 } = body;
      const result = await sql`
        INSERT INTO user_watchlist (user_handle, media_id, watch_status, current_episode, updated_at)
        VALUES (${user_handle}, ${media_id}, ${watch_status}, ${current_episode}, NOW())
        ON CONFLICT (user_handle, media_id)
        DO UPDATE SET watch_status = EXCLUDED.watch_status, current_episode = EXCLUDED.current_episode, updated_at = NOW()
        RETURNING *
      `;
      return new Response(JSON.stringify({ status: 'ok', entry: result[0] }), { status: 200, headers });
    }

    const url = new URL(req.url);
    const userHandle = url.searchParams.get('user') || 'cyber_otaku';
    const list = await sql`
      SELECT w.*, m.title_en, m.poster_url, m.rating, m.episodes_total
      FROM user_watchlist w
      JOIN media_catalog m ON m.id = w.media_id
      WHERE w.user_handle = ${userHandle}
      ORDER BY w.updated_at DESC
    `;
    return new Response(JSON.stringify({ status: 'ok', watchlist: list }), { status: 200, headers });
  } catch (err) {
    return new Response(JSON.stringify({ status: 'error', error: err.message }), { status: 500, headers });
  }
};
