/*
  # Create admin user with proper password

  1. New User
    - Email: admin@deuss.com
    - Password: DeussStudio1234!
    - Email confirmed automatically
  
  2. Security
    - Uses bcrypt for password hashing
    - Auto-confirmed email
    - This is the ONLY user allowed in the system
*/

-- Create the admin user with a properly hashed password
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@deuss.com',
  crypt('DeussStudio1234!', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Admin"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
);
