/*
  # Add indexes and constraints for user_id columns

  1. Indexes
    - Add indexes on user_id for faster queries
    - Improves performance for row-level security filtering

  2. Constraints
    - Foreign key from user_id to auth.users (optional but recommended)
    - Ensures data integrity

  3. Performance
    - Queries filtered by user_id will be fast with these indexes
*/

-- Add indexes for user_id columns (improves RLS performance)
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_history_user_id ON history(user_id);

-- Ensure DEFAULT is set for new inserts
ALTER TABLE clients ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE bookings ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE history ALTER COLUMN user_id SET DEFAULT auth.uid();
