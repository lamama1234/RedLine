-- ==============================================================================
-- RedLine GIS - Supabase Database Schema & Realtime Setup
-- Netanya: Poleg & Ir Yamim Community Project Payments
-- ==============================================================================
-- Instructions:
-- 1. Open your Supabase Dashboard (https://supabase.com/dashboard)
-- 2. Select your project -> Go to SQL Editor (left navigation)
-- 3. Click "New query", paste this entire script, and click "Run" (Ctrl+Enter)
-- ==============================================================================

-- 1. Create the `buildings` table with the requested schema + GIS support
CREATE TABLE IF NOT EXISTS public.buildings (
  id TEXT PRIMARY KEY,
  address TEXT NOT NULL,
  street TEXT,
  neighborhood TEXT NOT NULL CHECK (neighborhood IN ('Poleg', 'Ir Yamim', 'Other')),
  units INTEGER DEFAULT 40,
  manager TEXT,
  status TEXT NOT NULL DEFAULT 'uncommitted' CHECK (status IN ('uncommitted', 'committed', 'paid')),
  target_ils NUMERIC NOT NULL DEFAULT 5000,
  paid_ils NUMERIC NOT NULL DEFAULT 0,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  polygon JSONB,
  notes TEXT DEFAULT '',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create index on neighborhood and status for fast geospatial and statistical queries
CREATE INDEX IF NOT EXISTS idx_buildings_neighborhood ON public.buildings (neighborhood);
CREATE INDEX IF NOT EXISTS idx_buildings_status ON public.buildings (status);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.buildings ENABLE ROW LEVEL SECURITY;

-- 4. Public Read Policy: Allow anyone (visitors, viewers, residents) to read buildings
DROP POLICY IF EXISTS "Public read access for all users" ON public.buildings;
CREATE POLICY "Public read access for all users"
  ON public.buildings
  FOR SELECT
  USING (true);

-- 5. Public Write Policy (Anon key allowed):
-- The client-side application securely gates write/mutation operations behind the Admin passcode.
-- If you later integrate Supabase Auth with admin users, you can replace 'anon' with 'authenticated'.
DROP POLICY IF EXISTS "Allow anon modifications for admin actions" ON public.buildings;
CREATE POLICY "Allow anon modifications for admin actions"
  ON public.buildings
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- 6. Trigger to automatically keep `updated_at` updated
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_buildings_updated_at ON public.buildings;
CREATE TRIGGER trigger_buildings_updated_at
  BEFORE UPDATE ON public.buildings
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- 7. Enable Realtime Replication on the `buildings` table
-- This enables postgres_changes broadcasts to all connected map clients
ALTER PUBLICATION supabase_realtime ADD TABLE public.buildings;

-- ==============================================================================
-- 8. Seed Initial Data (Poleg & Ir Yamim 20 Residential Buildings)
-- ==============================================================================
INSERT INTO public.buildings (id, address, street, neighborhood, units, manager, status, target_ils, paid_ils, lat, lng, notes)
VALUES
  ('b1',  'שדרות שז"ר 1',    'שדרות שז"ר',    'Ir Yamim', 42, 'דוד לוי',     'uncommitted', 5000,  0,     32.2762, 34.8472, ''),
  ('b2',  'שדרות שז"ר 3',    'שדרות שז"ר',    'Ir Yamim', 38, 'שרה כהן',    'committed',   5000,  0,     32.2755, 34.8480, 'צפוי לשלם בקרוב'),
  ('b3',  'שדרות שז"ר 5',    'שדרות שז"ר',    'Ir Yamim', 55, 'משה ישראלי', 'paid',        5000,  5000,  32.2748, 34.8488, ''),
  ('b4',  'שדרות שז"ר 7',    'שדרות שז"ר',    'Ir Yamim', 60, 'יעקב מזרחי', 'paid',        7500,  7500,  32.2741, 34.8495, 'שולם במלואו'),
  ('b5',  'שדרות שז"ר 9',    'שדרות שז"ר',    'Ir Yamim', 36, 'מרים אברהם', 'committed',   5000,  0,     32.2735, 34.8503, ''),
  ('b6',  'רחוב הגלים 10',   'רחוב הגלים',    'Ir Yamim', 48, 'רחל גולן',   'uncommitted', 5000,  0,     32.2770, 34.8460, ''),
  ('b7',  'רחוב הגלים 12',   'רחוב הגלים',    'Ir Yamim', 72, 'אבי שפירא',  'paid',        10000, 9500,  32.2778, 34.8452, 'שולם חלקית'),
  ('b8',  'רחוב הגלים 14',   'רחוב הגלים',    'Ir Yamim', 50, 'חיים בר',    'uncommitted', 7500,  0,     32.2785, 34.8445, ''),
  ('b9',  'שדרות ים התיכון 20','שדרות ים התיכון','Ir Yamim',68,'נעמי גרין', 'uncommitted', 10000, 0,     32.2792, 34.8438, ''),
  ('b10', 'שדרות ים התיכון 22','שדרות ים התיכון','Ir Yamim',44,'טלי שמש',  'committed',   5000,  0,     32.2798, 34.8430, ''),
  ('b11', 'רחוב פולג 2',      'רחוב פולג',     'Poleg',    40, 'אורן בן דוד','paid',        5000,  5000,  32.2820, 34.8400, ''),
  ('b12', 'רחוב פולג 4',      'רחוב פולג',     'Poleg',    35, 'ליאת כץ',   'committed',   5000,  0,     32.2830, 34.8395, ''),
  ('b13', 'שדרות ויצמן 45',   'שדרות ויצמן',   'Poleg',    88, 'רוני פרץ',  'paid',        10000, 10000, 32.2812, 34.8408, 'שולם במלואו ובזמן'),
  ('b14', 'שדרות ויצמן 47',   'שדרות ויצמן',   'Poleg',    64, 'דינה לפיד', 'uncommitted', 7500,  0,     32.2818, 34.8415, ''),
  ('b15', 'שדרות ויצמן 49',   'שדרות ויצמן',   'Poleg',    52, 'עמי רוזן',  'committed',   7500,  0,     32.2825, 34.8420, 'הובטח תשלום לחודש הבא'),
  ('b16', 'רחוב אלון 3',      'רחוב אלון',     'Poleg',    30, 'יפה עוז',   'paid',        5000,  5000,  32.2835, 34.8380, ''),
  ('b17', 'רחוב אלון 5',      'רחוב אלון',     'Poleg',    28, 'בן ציון',   'uncommitted', 5000,  0,     32.2845, 34.8375, ''),
  ('b18', 'רחוב הדקל 1',      'רחוב הדקל',     'Poleg',    46, 'שלומית בר', 'committed',   5000,  0,     32.2850, 34.8385, ''),
  ('b19', 'רחוב הדקל 3',      'רחוב הדקל',     'Poleg',    33, 'נחום ורד',  'paid',        5000,  4500,  32.2855, 34.8392, 'חסר ₪500'),
  ('b20', 'רחוב פולג 6',      'רחוב פולג',     'Poleg',    56, 'גיל יחיאל', 'uncommitted', 7500,  0,     32.2840, 34.8388, '')
ON CONFLICT (id) DO NOTHING;
