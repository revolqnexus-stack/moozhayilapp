DELETE FROM admin_users WHERE email = 'admin@moozhayil.com';

INSERT INTO admin_users (id, email, name, role, password_hash, mfa_enabled, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'admin@moozhayil.com',
  'Admin',
  'super_admin',
  'e63cf0f92e472dd3280274ff7418cd7c:2a3a1551eadeadb9d19d95613ca7f6d8ebb9f0265b17b7779e0d861f1f35bb66a301c1579b0a30af0076662195b7949cde942030cd95344684edc4f40edd98c4',
  false,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);
