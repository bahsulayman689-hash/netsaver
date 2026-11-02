# NetSaver GM

An offline-first web app that helps people in The Gambia spend less on mobile data, keep learning without a connection, and report outages and prices so the problem becomes visible.

**Live app:** https://netsaver-gm.vercel.app  
**Public dashboard:** https://netsaver-gm.vercel.app/dashboard.html

## Why this exists

The Gambia depends heavily on a single submarine cable, so the internet is easy to disrupt, and mobile data is expensive relative to income. A World Bank analysis of the country's digital challenges points to high broadband costs and a large mobile internet usage gap ([source](https://blogs.worldbank.org/en/digital-development/road-digital-nation-what-are-challenges-gambia-faces)). NetSaver GM works around the problem on the phone people already own, and collects evidence about it.

## Features

| Tab | What it does |
|---|---|
| **Data** | Save bundles and rank them by cost per GB. Track the active bundle on a gauge with days left, a safe daily amount and a warning if you are using data too fast. Share a bundle price publicly (opt-in). |
| **Library** | 28 offline notes: WASSCE Maths, Physics, Chemistry, Biology and English, exam tips, general rights information and farming guidance. Search, filter, add your own, and export or import as JSON to share without using data. |
| **Tools** | Loan calculator (shows total interest repaid) and savings goal calculator. |
| **Monitor** | Checks connectivity every 30 seconds while the app is open. Shows uptime, latency and outages, and exports a CSV log you can use as evidence. |
| **Outbox** | Write outage, slow-speed or price reports offline. They queue on the phone and send automatically when the connection returns. |

Also: installable PWA that works fully offline, English / Wolof / Mandinka language switch (translations are drafts), light and dark mode, and a public dashboard with a map, provider breakdowns and median price per GB.

## How it works

```
Phone (PWA, service worker, localStorage)
   |  reports and shared prices, only when the user opts in
   v
Supabase (Postgres + row-level security)
   |  approved rows only
   v
Public dashboard (static page)
```

- **Offline first:** the app shell is cached by a service worker. Personal data (bundles, usage, notes, logs) never leaves the phone.
- **Privacy:** reports include a consent step, locations are rounded to about 1 km and must fall inside The Gambia, and phone-number-like text is masked by a database trigger.
- **Moderation:** anonymous users can only insert unapproved rows. Nothing appears publicly until you approve it.
- **No secrets in the repo:** the build generates `config.js` from environment variables. Only the publishable (anon) key is ever used in the browser.

## Setup

1. **Create a Supabase project.**
2. In the SQL Editor, run these files in order:
   1. `supabase.sql` (reports table, policies, stats function)
   2. `moderation.sql` (masks phone numbers in new reports)
   3. `bundle_prices.sql` (crowd-sourced bundle prices)
3. From Project Settings, API Keys, copy:
   - `SUPABASE_URL`: the project URL, for example `https://abcdxyz.supabase.co` (no `/rest/v1/`)
   - `SUPABASE_ANON`: the **publishable** key (`sb_publishable_...`) or the legacy `anon` key.
   **Never use the secret or service_role key.** The app refuses to run if it detects one.
4. Deploy (below), set the two environment variables, and redeploy after any change to them.

### Deploy on Vercel
Import the repo, set Framework Preset to **Other**, add `SUPABASE_URL` and `SUPABASE_ANON`, and deploy. `vercel.json` and `build.sh` handle the rest.

### Deploy on Render
New, then Blueprint, then choose the repo. `render.yaml` creates a static site and asks for the same two variables.

### Run locally
```
cp config.example.js config.js   # fill in your values
python3 -m http.server 8000      # then open http://localhost:8000
```

## Moderation

Open the Supabase Table Editor, then `reports` or `bundle_prices`, and tick `approved` on good rows. Delete spam. Ready-made queries are at the bottom of `moderation.sql` and `bundle_prices.sql`.

## Project structure

```
index.html          the app (UI + logic)
dashboard.html      public connectivity dashboard
sw.js               service worker (offline cache)
manifest.json       PWA manifest
icon.svg            app icon
ping.txt            tiny file used by the connection monitor
content.js          pre-loaded offline library (edit freely)
i18n.js             translations (drafts, need native review)
config.example.js   copy to config.js for local use
build.sh            generates config.js from env vars (Vercel)
vercel.json         Vercel build and headers
render.yaml         Render blueprint
supabase.sql        reports table, policies, stats
moderation.sql      phone-number masking + moderation queries
bundle_prices.sql   bundle price table, policies, stats
```

After changing any app file, bump the cache name in `sw.js` (for example `netsaver-v6` to `netsaver-v7`) so installed phones pick up the update.

## Known limitations

- Wolof is a first draft and Mandinka is an empty scaffold; both need review by native speakers.
- Rights notes are general information, not legal advice. Verify them and replace with checked content.
- The connection monitor only measures while the app is open, and cannot tell whether an outage is caused by the cable or by a provider.
- Price comparison ignores how long a bundle lasts.
- The app is at pilot stage: no user numbers or impact claims yet.

## Roadmap

- Spending tracker for top-ups and real cost per GB
- First-run welcome screen and install button
- Low-data mode
- Backup and restore
- Moderation page
- Price comparison normalised per 30 days

## Author

Sulayman Bah, software developer, The Gambia  
GitHub: https://github.com/bahsulayman689-hash  
LinkedIn: https://linkedin.com/in/sulayman-bah-8a7096423

## License

Add a license before accepting contributions (MIT is a common choice).
