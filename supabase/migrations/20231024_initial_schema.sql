-- Create investigations table
CREATE TABLE investigations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  user_id UUID -- optional, allowing null for anonymous for now
);

-- Create hfacs_levels table
CREATE TABLE hfacs_levels (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  color_main TEXT NOT NULL,
  color_pale TEXT NOT NULL
);

-- Create hfacs_categories table
CREATE TABLE hfacs_categories (
  id SERIAL PRIMARY KEY,
  level_id INTEGER REFERENCES hfacs_levels(id) ON DELETE CASCADE,
  name TEXT NOT NULL
);

-- Create nodes table (React Flow nodes)
CREATE TABLE nodes (
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
CREATE TABLE edges (
  id TEXT PRIMARY KEY,
  investigation_id UUID REFERENCES investigations(id) ON DELETE CASCADE,
  source_node_id TEXT REFERENCES nodes(id) ON DELETE CASCADE,
  target_node_id TEXT REFERENCES nodes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Insert HFACS Taxonomy Data
INSERT INTO hfacs_levels (id, name, color_main, color_pale) VALUES
  (1, 'Unsafe Acts', 'bg-red-500', 'bg-red-100'),
  (2, 'Preconditions for Unsafe Acts', 'bg-orange-500', 'bg-orange-100'),
  (3, 'Unsafe Supervision', 'bg-blue-500', 'bg-blue-100'),
  (4, 'Organizational Influences', 'bg-purple-500', 'bg-purple-100');

INSERT INTO hfacs_categories (level_id, name) VALUES
  -- Level 1: Unsafe Acts
  (1, 'Skill-based errors'),
  (1, 'Decision errors'),
  (1, 'Perceptual errors'),
  (1, 'Routine violations'),
  (1, 'Exceptional violations'),

  -- Level 2: Preconditions for Unsafe Acts
  (2, 'Adverse mental states'),
  (2, 'Adverse physiological states'),
  (2, 'Physical/Mental limitations'),
  (2, 'Physical environment'),
  (2, 'Technological environment'),
  (2, 'Crew resource management'),
  (2, 'Personal readiness'),

  -- Level 3: Unsafe Supervision
  (3, 'Inadequate supervision'),
  (3, 'Planned inappropriate operations'),
  (3, 'Failed to correct known problems'),
  (3, 'Supervisory violations'),

  -- Level 4: Organizational Influences
  (4, 'Resource management'),
  (4, 'Organizational climate'),
  (4, 'Organizational process');

-- Enable RLS (Row Level Security) on tables
ALTER TABLE investigations ENABLE ROW LEVEL SECURITY;
ALTER TABLE hfacs_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE hfacs_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE edges ENABLE ROW LEVEL SECURITY;

-- Create simple RLS policies for anonymous access (For development purposes)
-- We will allow ALL operations for anonymous users temporarily
CREATE POLICY "Enable read access for all users" ON hfacs_levels FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON hfacs_categories FOR SELECT USING (true);

CREATE POLICY "Enable ALL for anonymous users on investigations" ON investigations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anonymous users on nodes" ON nodes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable ALL for anonymous users on edges" ON edges FOR ALL USING (true) WITH CHECK (true);
