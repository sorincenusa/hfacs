-- Create investigations table
CREATE TABLE IF NOT EXISTS investigations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  user_id UUID -- optional, allowing null for anonymous for now
);

-- Create hfacs_levels table
CREATE TABLE IF NOT EXISTS hfacs_levels (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  color_main TEXT NOT NULL,
  color_pale TEXT NOT NULL
);

-- Create hfacs_categories table
CREATE TABLE IF NOT EXISTS hfacs_categories (
  id SERIAL PRIMARY KEY,
  level_id INTEGER REFERENCES hfacs_levels(id) ON DELETE CASCADE,
  name TEXT NOT NULL
);

-- Create nodes table (React Flow nodes)
CREATE TABLE IF NOT EXISTS nodes (
  id TEXT PRIMARY KEY,
  investigation_id UUID REFERENCES investigations(id) ON DELETE CASCADE,
  label TEXT,
  description TEXT,
  attachment_url TEXT,
  hfacs_category_id INTEGER REFERENCES hfacs_categories(id) ON DELETE SET NULL,
  position_x FLOAT NOT NULL,
  position_y FLOAT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create edges table (React Flow edges)
CREATE TABLE IF NOT EXISTS edges (
  id TEXT PRIMARY KEY,
  investigation_id UUID REFERENCES investigations(id) ON DELETE CASCADE,
  source_node_id TEXT REFERENCES nodes(id) ON DELETE CASCADE,
  target_node_id TEXT REFERENCES nodes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Insert HFACS Taxonomy Data (Only if empty to prevent duplicates on subsequent runs)
INSERT INTO hfacs_levels (id, name, color_main, color_pale)
SELECT 1, 'Unsafe Acts', 'bg-red-500', 'bg-red-100'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_levels WHERE id = 1);

INSERT INTO hfacs_levels (id, name, color_main, color_pale)
SELECT 2, 'Preconditions for Unsafe Acts', 'bg-orange-500', 'bg-orange-100'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_levels WHERE id = 2);

INSERT INTO hfacs_levels (id, name, color_main, color_pale)
SELECT 3, 'Unsafe Supervision', 'bg-blue-500', 'bg-blue-100'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_levels WHERE id = 3);

INSERT INTO hfacs_levels (id, name, color_main, color_pale)
SELECT 4, 'Organizational Influences', 'bg-purple-500', 'bg-purple-100'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_levels WHERE id = 4);


INSERT INTO hfacs_categories (level_id, name)
SELECT 1, 'Skill-based errors'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Skill-based errors');

INSERT INTO hfacs_categories (level_id, name)
SELECT 1, 'Decision errors'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Decision errors');

INSERT INTO hfacs_categories (level_id, name)
SELECT 1, 'Perceptual errors'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Perceptual errors');

INSERT INTO hfacs_categories (level_id, name)
SELECT 1, 'Routine violations'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Routine violations');

INSERT INTO hfacs_categories (level_id, name)
SELECT 1, 'Exceptional violations'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Exceptional violations');

INSERT INTO hfacs_categories (level_id, name)
SELECT 2, 'Adverse mental states'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Adverse mental states');

INSERT INTO hfacs_categories (level_id, name)
SELECT 2, 'Adverse physiological states'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Adverse physiological states');

INSERT INTO hfacs_categories (level_id, name)
SELECT 2, 'Physical/Mental limitations'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Physical/Mental limitations');

INSERT INTO hfacs_categories (level_id, name)
SELECT 2, 'Physical environment'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Physical environment');

INSERT INTO hfacs_categories (level_id, name)
SELECT 2, 'Technological environment'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Technological environment');

INSERT INTO hfacs_categories (level_id, name)
SELECT 2, 'Crew resource management'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Crew resource management');

INSERT INTO hfacs_categories (level_id, name)
SELECT 2, 'Personal readiness'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Personal readiness');

INSERT INTO hfacs_categories (level_id, name)
SELECT 3, 'Inadequate supervision'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Inadequate supervision');

INSERT INTO hfacs_categories (level_id, name)
SELECT 3, 'Planned inappropriate operations'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Planned inappropriate operations');

INSERT INTO hfacs_categories (level_id, name)
SELECT 3, 'Failed to correct known problems'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Failed to correct known problems');

INSERT INTO hfacs_categories (level_id, name)
SELECT 3, 'Supervisory violations'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Supervisory violations');

INSERT INTO hfacs_categories (level_id, name)
SELECT 4, 'Resource management'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Resource management');

INSERT INTO hfacs_categories (level_id, name)
SELECT 4, 'Organizational climate'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Organizational climate');

INSERT INTO hfacs_categories (level_id, name)
SELECT 4, 'Organizational process'
WHERE NOT EXISTS (SELECT 1 FROM hfacs_categories WHERE name = 'Organizational process');

-- Enable RLS (Row Level Security) on tables
ALTER TABLE investigations ENABLE ROW LEVEL SECURITY;
ALTER TABLE hfacs_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE hfacs_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE edges ENABLE ROW LEVEL SECURITY;

-- Safely recreate policies
DO $$
BEGIN
    DROP POLICY IF EXISTS "Enable read access for all users" ON hfacs_levels;
    DROP POLICY IF EXISTS "Enable read access for all users" ON hfacs_categories;
    DROP POLICY IF EXISTS "Enable ALL for anonymous users on investigations" ON investigations;
    DROP POLICY IF EXISTS "Enable ALL for anonymous users on nodes" ON nodes;
    DROP POLICY IF EXISTS "Enable ALL for anonymous users on edges" ON edges;
END $$;

-- Create simple RLS policies for anonymous access (For development purposes)
CREATE POLICY "Enable read access for all users" ON hfacs_levels FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON hfacs_categories FOR SELECT USING (true);

CREATE POLICY "Enable ALL for anonymous users on investigations" ON investigations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anonymous users on nodes" ON nodes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anonymous users on edges" ON edges FOR ALL USING (true) WITH CHECK (true);
