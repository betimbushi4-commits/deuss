/*
  # Add legacy packages support

  1. New Column
    - `legacy_packages` (jsonb) - Legacy packages from old clients
      - Sessions and revenue counted for therapist bonus
      - NOT included in overall package sales or revenue metrics
      - Structure: [{ service, sessions, therapist, date_added }]
  
  2. Purpose
    - Track historical sessions for therapist bonus calculations
    - Keep reporting accurate for current business metrics
    - Maintain complete therapist performance history
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clients' AND column_name = 'legacy_packages'
  ) THEN
    ALTER TABLE clients ADD COLUMN legacy_packages jsonb DEFAULT '[]'::jsonb;
  END IF;
END $$;
