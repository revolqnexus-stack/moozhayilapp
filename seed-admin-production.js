// Create an admin user in a target database.
// Usage: DATABASE_URL=postgresql://... node seed-admin-production.js
// NEVER hardcode credentials or passwords in this file.

const { Pool } = require("pg");

const DATABASE_URL = process.env.DATABASE_URL;
const ADMIN_EMAIL = process.env.ADMIN_EMAIL ?? "admin@moozhayil.com";
const ADMIN_PASSWORD_HASH = process.env.ADMIN_PASSWORD_HASH;
const ADMIN_NAME = process.env.ADMIN_NAME ?? "Admin";
const ADMIN_ROLE = process.env.ADMIN_ROLE ?? "super_admin";

if (!DATABASE_URL) {
  console.error("DATABASE_URL is required.");
  process.exit(1);
}

if (!ADMIN_PASSWORD_HASH) {
  console.error(
    "ADMIN_PASSWORD_HASH is required (bcrypt hash). Generate with apps/api seed:admin or bcrypt CLI.",
  );
  process.exit(1);
}

async function seedAdmin() {
  const pool = new Pool({ connectionString: DATABASE_URL });

  try {
    const existing = await pool.query("SELECT id FROM admins WHERE email = $1", [
      ADMIN_EMAIL,
    ]);
    if (existing.rows.length > 0) {
      console.log("Admin user already exists:", ADMIN_EMAIL);
      process.exit(0);
    }

    const id = Math.random().toString(36).substring(2) + Date.now().toString(36);
    await pool.query(
      `INSERT INTO admins (id, email, password_hash, name, role, status, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, 'active', NOW(), NOW())`,
      [id, ADMIN_EMAIL, ADMIN_PASSWORD_HASH, ADMIN_NAME, ADMIN_ROLE],
    );

    console.log("Admin user created:", ADMIN_EMAIL);
  } finally {
    await pool.end();
  }
}

seedAdmin().catch((err) => {
  console.error("Failed to seed admin:", err.message);
  process.exit(1);
});
