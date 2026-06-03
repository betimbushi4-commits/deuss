/*
  # Fix RLS Policies - Secure Multi-User Access

  1. Schema Changes
    - Add `user_id` column to clients, bookings, and history tables
    - Backfill with a default authenticated user (for existing data)
    - Then enforce NOT NULL constraint

  2. Security Fixes
    - Replace permissive `true` policies with ownership checks
    - All operations now validate auth.uid() matches user_id
    - Data is properly isolated per user

  3. Tables Modified
    - `clients`: Add user_id with ownership validation
    - `bookings`: Add user_id with ownership validation
    - `history`: Add user_id with ownership validation
*/

-- Add nullable user_id columns
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clients' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE clients ADD COLUMN user_id uuid;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bookings' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE bookings ADD COLUMN user_id uuid;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'history' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE history ADD COLUMN user_id uuid;
  END IF;
END $$;

-- Get the first admin user from auth.users (or use a system user)
-- Backfill existing records with the first authenticated user
DO $$
DECLARE
  system_user_id uuid;
BEGIN
  -- Get first user from auth.users table
  SELECT id INTO system_user_id FROM auth.users LIMIT 1;
  
  -- If no user exists, use a placeholder (this will be the admin)
  IF system_user_id IS NULL THEN
    system_user_id := '00000000-0000-0000-0000-000000000000'::uuid;
  END IF;
  
  UPDATE clients SET user_id = system_user_id WHERE user_id IS NULL;
  UPDATE bookings SET user_id = system_user_id WHERE user_id IS NULL;
  UPDATE history SET user_id = system_user_id WHERE user_id IS NULL;
END $$;

-- Make user_id NOT NULL after backfill
ALTER TABLE clients ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE bookings ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE history ALTER COLUMN user_id SET NOT NULL;

-- Drop all existing overly permissive policies
DROP POLICY IF EXISTS "Authenticated users can view clients" ON clients;
DROP POLICY IF EXISTS "Authenticated users can insert clients" ON clients;
DROP POLICY IF EXISTS "Authenticated users can update clients" ON clients;
DROP POLICY IF EXISTS "Authenticated users can delete clients" ON clients;
DROP POLICY IF EXISTS "Authenticated users can view bookings" ON bookings;
DROP POLICY IF EXISTS "Authenticated users can insert bookings" ON bookings;
DROP POLICY IF EXISTS "Authenticated users can update bookings" ON bookings;
DROP POLICY IF EXISTS "Authenticated users can delete bookings" ON bookings;
DROP POLICY IF EXISTS "Authenticated users can view history" ON history;
DROP POLICY IF EXISTS "Authenticated users can insert history" ON history;
DROP POLICY IF EXISTS "Authenticated users can delete history" ON history;

-- Clients table policies - ownership-based
CREATE POLICY "Users can view own clients"
  ON clients FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own clients"
  ON clients FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own clients"
  ON clients FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own clients"
  ON clients FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Bookings table policies - ownership-based
CREATE POLICY "Users can view own bookings"
  ON bookings FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own bookings"
  ON bookings FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own bookings"
  ON bookings FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own bookings"
  ON bookings FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- History table policies - ownership-based
CREATE POLICY "Users can view own history"
  ON history FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own history"
  ON history FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own history"
  ON history FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
