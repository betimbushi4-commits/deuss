/*
  # Create initial CRM schema for Deuss Studio Massage CRM

  1. New Tables
    - `clients`: Stores client information and their purchased packages
      - `id` (uuid, primary key)
      - `name` (text, required)
      - `phone` (text, optional)
      - `sold_by` (text, therapist who sold the package)
      - `created_at` (timestamptz)
      - `packages` (jsonb, array of package objects containing service, sessions, etc.)
    
    - `bookings`: Stores appointment bookings
      - `id` (uuid, primary key)
      - `client_id` (uuid, foreign key to clients)
      - `client_name` (text)
      - `therapist` (text)
      - `service` (text)
      - `room` (text)
      - `date` (date)
      - `time` (text)
      - `status` (text: booked, done, cancelled)
      - `revenue` (numeric)
      - `package_id` (text, references package within client's packages)
      - `created_at` (timestamptz)
    
    - `history`: Stores activity log
      - `id` (uuid, primary key)
      - `type` (text: client_added, booking_added, session_done, etc.)
      - `message` (text)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Create policies for authenticated users to manage all data (shared CRM access)
  
  3. Important Notes
    - Packages are stored as JSONB to allow flexible package structures
    - All tables use uuid primary keys for consistency
    - Timestamps track creation times for auditing
*/

-- Create clients table
CREATE TABLE IF NOT EXISTS clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone text DEFAULT '',
  sold_by text DEFAULT '',
  packages jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  client_name text DEFAULT '',
  therapist text NOT NULL,
  service text NOT NULL,
  room text NOT NULL,
  date date NOT NULL,
  time text NOT NULL,
  status text DEFAULT 'booked',
  revenue numeric DEFAULT 0,
  package_id text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Create history table
CREATE TABLE IF NOT EXISTS history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL,
  message text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE history ENABLE ROW LEVEL SECURITY;

-- Create policies for clients table
CREATE POLICY "Users can view all clients"
  ON clients FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert clients"
  ON clients FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update clients"
  ON clients FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete clients"
  ON clients FOR DELETE
  TO authenticated
  USING (true);

-- Create policies for bookings table
CREATE POLICY "Users can view all bookings"
  ON bookings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert bookings"
  ON bookings FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update bookings"
  ON bookings FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete bookings"
  ON bookings FOR DELETE
  TO authenticated
  USING (true);

-- Create policies for history table
CREATE POLICY "Users can view all history"
  ON history FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert history"
  ON history FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can delete history"
  ON history FOR DELETE
  TO authenticated
  USING (true);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(date);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_client_id ON bookings(client_id);
CREATE INDEX IF NOT EXISTS idx_history_type ON history(type);
CREATE INDEX IF NOT EXISTS idx_history_created_at ON history(created_at DESC);
