# Animazing — Ultra-HD Anime & 18+ Vault Platform (Netlify + NeonDB)

**Animazing** is a responsive, production-ready web application engineered for anime and mature (18+ hentai/ecchi OVA) enthusiasts, featuring Ultra-HD artwork and real-world Akihabara photography, an interactive theater player, a PIN/Age-verified 18+ Vault, and full **NeonDB Serverless PostgreSQL** integration ready for **Netlify** deployment.

## Root Directory Structure

```text
animazing/
├── favicon.svg                      # Custom neon kitsune-katana 'A' vector favicon in root directory
├── index.html                       # Responsive single-page application with linked favicon & NeonDB Studio
├── netlify.toml                     # Netlify publish, headers, and serverless function routing config
├── package.json                     # Project scripts & @neondatabase/serverless driver
├── .env.example                     # Environment template for NeonDB DATABASE_URL
├── assets/
│   └── images/                      # Ultra-HD anime & real-world photography assets
│       ├── hero_cyberpunk.jpg
│       ├── poster_valkyrie.jpg
│       ├── poster_mecha.jpg
│       ├── poster_shrine.jpg
│       ├── poster_velvet.jpg
│       └── studio_akihabara.jpg
├── db/
│   ├── schema.sql                   # PostgreSQL DDL for media_catalog, episodes, user_watchlist, community_reviews
│   └── seed.sql                     # Initial seed data for Anime & 18+ Vault catalog
└── netlify/
    └── functions/
        ├── db-catalog.js            # Serverless endpoint querying NeonDB media_catalog
        ├── db-watchlist.js          # Serverless endpoint syncing user watchlists with NeonDB
        └── db-reviews.js            # Serverless endpoint for community reviews & ratings
```

## Quick Deployment to Netlify + NeonDB

1. **Create a NeonDB Database**:
   - Sign in at [https://console.neon.tech](https://console.neon.tech) and create a project named `animazing-prod`.
   - Copy your pooled PostgreSQL connection string (`DATABASE_URL`).
   - Run `psql $DATABASE_URL -f db/schema.sql` and `psql $DATABASE_URL -f db/seed.sql` (or paste them directly into the Neon SQL Editor).

2. **Deploy to Netlify**:
   - Drag and drop this folder into **Netlify Drop**, or connect your Git repository to Netlify.
   - In **Netlify Site Configuration → Environment Variables**, add `DATABASE_URL` with your Neon connection string, or connect автоматически via the **Neon Netlify Integration** (`netlify addons:create neon`).
