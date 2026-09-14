// Quick script to create admin user in production database
// Run with: node seed-admin-production.js

const { Pool } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:DBDZDffKbyxXXYPwPBwceeYiqAXlYwmS@zephyr.proxy.rlwy.net:20424/railway';

async function seedAdmin() {
  const pool = new Pool({ connectionString: DATABASE_URL });
  
  try {
    const email = 'admin@moozhayil.com';
    const password = 'Admin123!@#';
    const name = 'Admin';
    const role = 'super_admin';
    
    // Check if admin already exists
    const existing = await pool.query('SELECT id FROM admins WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      console.log('✅ Admin user already exists:', email);
      process.exit(0);
    }
    
    // Hash password (using pre-hashed for Admin123!@#)
    const passwordHash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
    
    // Create admin
    const id = Math.random().toString(36).substring(2) + Date.now().toString(36);
    const result = await pool.query(
      `INSERT INTO admins (id, email, password_hash, name, role, status, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
       RETURNING id, email, name, role`,
      [id, email, passwordHash, name, role, 'active']
    );
    
    console.log('✅ Admin user created successfully!');
    console.log('Email:', result.rows[0].email);
    console.log('Role:', result.rows[0].role);
    console.log('\nYou can now login at your admin panel with:');
    console.log('Email:', email);
    console.log('Password:', password);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

seedAdmin();
