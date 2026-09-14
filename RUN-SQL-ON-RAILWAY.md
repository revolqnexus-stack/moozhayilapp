# How to Run SQL on Railway Database

You have the complete database schema in `create-all-tables.sql`. Here's how to run it:

## Option 1: Railway Console (Recommended)

1. Go to Railway dashboard
2. Click on your **Postgres** service
3. Click **Data** tab
4. Click **Query** button
5. Copy the ENTIRE contents of `create-all-tables.sql`
6. Paste and click **Run**

## Option 2: Command Line with psql

```bash
# Connect to Railway database
PGPASSWORD=UPsEDXIyBpdrNgIJdplEPjYblseAotFU psql -h tokaido.proxy.rlwy.net -U postgres -p 43065 -d railway

# Once connected, run the SQL file
\i create-all-tables.sql

# Or paste the contents directly
```

## Option 3: Copy-paste directly in Railway Query tab

Open the **Query** tab in Railway Postgres and copy-paste the entire SQL file content.

## What This SQL Does

1. ✅ Creates all 36 ENUM types
2. ✅ Creates all 46 database tables
3. ✅ Sets up all foreign key relationships
4. ✅ Creates all 100+ indexes for performance
5. ✅ Seeds the admin user: `admin@moozhayil.com` / `Admin123!@#`
6. ✅ Creates Prisma migrations tracking table

## After Running

Once the SQL executes successfully:

1. Your database is FULLY SET UP
2. All tables exist with proper relationships
3. Admin user is ready to login
4. Go to: https://moozhayil-gold-diamonds.vercel.app
5. Login with: `admin@moozhayil.com` / `Admin123!@#`

## Troubleshooting

If you get "already exists" errors, that means some tables already exist. You can either:

- **Option A**: Drop all existing tables first (CAREFUL!):
  ```sql
  DROP SCHEMA public CASCADE;
  CREATE SCHEMA public;
  ```

- **Option B**: Just ignore the errors for tables that already exist. The SQL has `ON CONFLICT DO NOTHING` for the admin user so it's safe to re-run.
