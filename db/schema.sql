-- ============================================================================
-- ANIMAZING PLATFORM - NEONDB SERVERLESS POSTGRESQL SCHEMA
-- Compatible with Neon Postgres 16+, pg_trgm full-text search & JSONB indexing
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 1. Media Catalog (Anime Series, Movies, OVAs, & 18+ Uncut Hentai/Ecchi Vault)
CREATE TABLE IF NOT EXISTS media_catalog (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(120) UNIQUE NOT NULL,
    title_en VARCHAR(200) NOT NULL,
    title_jp VARCHAR(200) NOT NULL,
    category VARCHAR(40) NOT NULL CHECK (category IN ('Simulcast', 'Dark Fantasy', 'Mecha Sci-Fi', 'Romance', 'Uncut 18+ Hentai', 'Ecchi OVA', 'Real HD Showcase')),
    is_mature BOOLEAN DEFAULT FALSE NOT NULL,
    age_rating VARCHAR(16) NOT NULL DEFAULT 'TV-14',
    release_year INT NOT NULL,
    season VARCHAR(32) NOT NULL,
    studio VARCHAR(120) NOT NULL,
    director VARCHAR(120) NOT NULL,
    episodes_total INT NOT NULL DEFAULT 12,
    duration_mins INT NOT NULL DEFAULT 24,
    resolution VARCHAR(24) NOT NULL DEFAULT '4K UHD HDR',
    audio_tracks TEXT[] DEFAULT ARRAY['Japanese (5.1)', 'English Dub'],
    genres TEXT[] NOT NULL,
    rating NUMERIC(3, 2) DEFAULT 9.00 CHECK (rating >= 0 AND rating <= 10),
    views_count BIGINT DEFAULT 0,
    favorites_count INT DEFAULT 0,
    poster_url TEXT NOT NULL,
    banner_url TEXT,
    synopsis TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_catalog_mature ON media_catalog(is_mature);
CREATE INDEX IF NOT EXISTS idx_media_catalog_category ON media_catalog(category);
CREATE INDEX IF NOT EXISTS idx_media_catalog_genres ON media_catalog USING GIN(genres);
CREATE INDEX IF NOT EXISTS idx_media_catalog_title_trgm ON media_catalog USING GIN(title_en gin_trgm_ops);

-- 2. Episodes & Multi-Bitrate Streaming Sources
CREATE TABLE IF NOT EXISTS episodes (
    id SERIAL PRIMARY KEY,
    media_id INT NOT NULL REFERENCES media_catalog(id) ON DELETE CASCADE,
    episode_number INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    duration_seconds INT NOT NULL DEFAULT 1440,
    stream_hls_url TEXT NOT NULL,
    is_uncensored BOOLEAN DEFAULT FALSE,
    air_date DATE NOT NULL,
    UNIQUE(media_id, episode_number)
);

-- 3. User Watchlist & Cloud Playback Progress
CREATE TABLE IF NOT EXISTS user_watchlist (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_handle VARCHAR(64) NOT NULL,
    media_id INT NOT NULL REFERENCES media_catalog(id) ON DELETE CASCADE,
    watch_status VARCHAR(24) NOT NULL CHECK (watch_status IN ('Watching', 'Plan to Watch', 'Completed', 'On Hold')),
    current_episode INT DEFAULT 1,
    progress_seconds INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_handle, media_id)
);

-- 4. Community Reviews & Studio Discussions
CREATE TABLE IF NOT EXISTS community_reviews (
    id SERIAL PRIMARY KEY,
    media_id INT NOT NULL REFERENCES media_catalog(id) ON DELETE CASCADE,
    author_handle VARCHAR(64) NOT NULL,
    author_tier VARCHAR(32) DEFAULT 'Neon Otaku VIP',
    score NUMERIC(3, 1) NOT NULL CHECK (score >= 1.0 AND score <= 10.0),
    comment_body TEXT NOT NULL,
    contains_spoilers BOOLEAN DEFAULT FALSE,
    likes_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
