import { neon } from '@neondatabase/serverless';

export default async (req, context) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers });
  }

  try {
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
      return new Response(
        JSON.stringify({
          status: 'fallback_mode',
          message: 'DATABASE_URL not configured in Netlify env; serving cached NeonDB edge snapshot.',
        }),
        { status: 200, headers }
      );
    }

    const sql = neon(dbUrl);
    const url = new URL(req.url);
    const includeMature = url.searchParams.get('mature') === 'true';
    const category = url.searchParams.get('category');
    const search = url.searchParams.get('q');

    let rows;
    if (search) {
      rows = await sql`
        SELECT * FROM media_catalog
        WHERE (${includeMature} OR is_mature = FALSE)
          AND (title_en ILIKE ${'%' + search + '%'} OR title_jp ILIKE ${'%' + search + '%'})
        ORDER BY rating DESC, views_count DESC
        LIMIT 30
      `;
    } else if (category && category !== 'All') {
      rows = await sql`
        SELECT * FROM media_catalog
        WHERE (${includeMature} OR is_mature = FALSE)
          AND category = ${category}
        ORDER BY rating DESC
        LIMIT 30
      `;
    } else {
      rows = await sql`
        SELECT * FROM media_catalog
        WHERE (${includeMature} OR is_mature = FALSE)
        ORDER BY rating DESC, views_count DESC
        LIMIT 30
      `;
    }

    return new Response(JSON.stringify({ status: 'ok', count: rows.length, data: rows }), {
      status: 200,
      headers,
    });
  } catch (err) {
    return new Response(JSON.stringify({ status: 'error', error: err.message }), {
      status: 500,
      headers,
    });
  }
};
