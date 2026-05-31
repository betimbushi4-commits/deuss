/*
  # Create backups table

  1. New Tables
    - `backups`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to auth.users)
      - `backup_type` (text: 'full', 'clients', 'bookings')
      - `data` (jsonb: the backup data)
      - `created_at` (timestamptz)
  
  2. Security
    - Enable RLS on `backups` table
    - Users can only read/create their own backups
*/

CREATE TABLE IF NOT EXISTS backups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  backup_type text NOT NULL DEFAULT 'full',
  data jsonb NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE backups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own backups"
  ON backups FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own backups"
  ON backups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_backups_user_created ON backups(user_id, created_at DESC);
