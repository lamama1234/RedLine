# RedLine — Netanya Community Project Payments (Poleg & Ir Yamim)

A responsive GIS web application for tracking and visualizing community project payments by building in Netanya, focusing on the **Poleg** and **Ir Yamim** neighborhoods.

Includes **OpenStreetMap & Esri World Imagery (satellite without API keys)**, **colored building polygon outlines**, **role-based access control**, **centralized Supabase real-time synchronization**, and **zero-cost static hosting deployment**.

---

## 🚀 One-Click Free Deployment

The application is bundled for deployment to any free-tier static hosting platform (**Vercel** or **Netlify**) with zero operating costs.

### Option A: Deploy to Vercel (Recommended)

1. Push this repository to GitHub or GitLab.
2. Go to [vercel.com](https://vercel.com) and click **"Add New Project"**.
3. Import the repository.
4. Set the **Framework Preset** to **"Other"** (Root directory: `./`).
5. (Optional) Under **Environment Variables**, add:
   - `VITE_SUPABASE_URL` = your Supabase Project URL
   - `VITE_SUPABASE_ANON_KEY` = your Supabase Anon public key
   - `VITE_ADMIN_PASSCODE` = your admin passcode (default: `KavAdom1`)
6. Click **Deploy**. Vercel will deploy using `vercel.json` with clean URLs and SPA routing.

### Option B: Deploy to Netlify

1. Go to [netlify.com](https://netlify.com) and click **"Add new site" -> "Import an existing project"**.
2. Select your repository.
3. The build settings will automatically be detected from `netlify.toml` (Publish directory: `.`).
4. (Optional) In **Site configuration -> Environment variables**, add `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, and `VITE_ADMIN_PASSCODE`.
5. Click **Deploy site**.

---

## 🗄️ Free Multi-Tenant Database Setup (Supabase)

All devices and browser tabs automatically sync state in real time via **Supabase Realtime** (`postgres_changes` on the `buildings` table).

### Step-by-Step Setup:
1. Create a free account at [supabase.com](https://supabase.com) and create a new project.
2. Navigate to **SQL Editor** in the left sidebar.
3. Open [`supabase-schema.sql`](file:///c:/Users/sblueeye/Documents/AntiGravity/RedLine/supabase-schema.sql) in this repository, copy its contents, paste them into the SQL editor, and click **Run**.
   - This sets up the `buildings` table schema (`id`, `address`, `status`, `target_ils`, `paid_ils`, `lat`, `lng`, `polygon`, `updated_at`).
   - Enables Row Level Security (RLS) with public read access.
   - Activates Realtime replication publication (`supabase_realtime`).
   - Seeds the 20 residential buildings in Poleg & Ir Yamim.
4. Copy your **Project URL** and **Anon API Key** from **Project Settings -> API**.
5. Connect your app:
   - In production: Set them as environment variables in Vercel/Netlify.
   - In the browser: Click the **Database Settings icon (⚙️)** in the top header bar and paste your URL and Key. The credentials will be tested and saved securely to `localStorage`.

---

## 🔐 Security & Access Control

- **Public Read-Only Mode**: Default mode for general visitors and neighborhood residents. Allows zooming, searching, address autocompletion, hovering over building footprints for payment statistics, and downloading CSV reports. All editing actions are disabled.
- **Admin Editing Mode**: Gated by passcode (configured via `VITE_ADMIN_PASSCODE`, default: `KavAdom1`). Unlocks:
  - Clicking any building or polygon to edit status (`uncommitted`, `committed`, `paid`), custom paid amounts, and notes.
  - Adding new buildings (by button or clicking directly on the map).
  - Deleting individual buildings or bulk-clearing data.
  - Resetting to defaults.
- All admin mutations are optimistic on the client and immediately dispatched to Supabase, which broadcasts updates to all active viewer sessions in milliseconds.

---

## 🗺️ GIS Features & Satellite Map

- **Zero-Key Satellite Imagery**: High-resolution Esri World Imagery with no API key requirement, capped strictly at Zoom 18 to avoid blank tiles.
- **Dynamic Building Footprints**: Colored polygon footprints reflect real-time payment states:
  - ⚪ **Uncommitted**: Translucent slate border & faint fill
  - 🔵 **Committed**: Bright blue border & fill
  - 🟢 **Paid**: Emerald green border & fill + ₪ paid amount badge
- **Map Click-to-Add**: In Admin mode, click anywhere on the map to place a building with automatic reverse geocoding via OpenStreetMap Nominatim.
- **Address Autocomplete**: Search bar supports bilingual (Hebrew & English) address autocompletion bounded to Netanya.

---

## 🛠️ Local Development

To run the application locally:
```bash
python -m http.server 8080
# Open http://localhost:8080 in your browser
```
