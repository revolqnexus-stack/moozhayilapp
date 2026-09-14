-- Moozhayil Gold & Diamonds - Complete Database Schema
-- Run this in your Railway PostgreSQL database

-- ============================================
-- ENUMS
-- ============================================

CREATE TYPE kyc_status AS ENUM ('not_started', 'in_progress', 'in_review', 'basic_verified', 'enhanced_verified', 'rejected');
CREATE TYPE intent_type AS ENUM ('wedding', 'investment', 'festival', 'gift', 'family', 'other');
CREATE TYPE otp_session_status AS ENUM ('pending', 'verified', 'expired', 'blocked');
CREATE TYPE device_platform AS ENUM ('ios', 'android', 'web');
CREATE TYPE admin_role AS ENUM ('super_admin', 'catalog_manager', 'kyc_reviewer', 'order_manager', 'finance_manager', 'support_agent', 'auditor');
CREATE TYPE ledger_adjustment_status AS ENUM ('pending', 'approved', 'rejected', 'posted');
CREATE TYPE sar_review_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE purity AS ENUM ('14k', '18k', '22k', '24k');
CREATE TYPE product_image_type AS ENUM ('white_background', 'on_model', 'detail', 'lifestyle');
CREATE TYPE goal_type AS ENUM ('wedding', 'investment', 'festival', 'gift', 'family', 'other');
CREATE TYPE scheme_type AS ENUM ('aura', 'crest', 'dhanam', 'gold_nidhi');
CREATE TYPE goal_status AS ENUM ('active', 'contribution_due', 'paused', 'completed', 'cancelled', 'discontinued');
CREATE TYPE contribution_status AS ENUM ('scheduled', 'pending_payment', 'processing', 'completed', 'payment_failed', 'cancelled', 'refunded');
CREATE TYPE contribution_type AS ENUM ('autopay', 'manual', 'bonus', 'adjustment');
CREATE TYPE ledger_entry_type AS ENUM ('contribution_credit', 'bonus_credit', 'redemption_debit', 'refund_credit', 'manual_adjustment_credit', 'manual_adjustment_debit');
CREATE TYPE ledger_status AS ENUM ('pending', 'posted', 'reversed');
CREATE TYPE payment_method_type AS ENUM ('upi', 'card', 'netbanking');
CREATE TYPE payment_provider AS ENUM ('razorpay');
CREATE TYPE payment_transaction_status AS ENUM ('created', 'pending', 'authorized', 'captured', 'failed', 'refund_initiated', 'refunded', 'reconciled');
CREATE TYPE payment_transaction_type AS ENUM ('goal_contribution', 'order_payment', 'refund', 'mandate_setup');
CREATE TYPE order_status AS ENUM ('draft', 'pending_payment', 'confirmed', 'processing', 'shipped', 'delivered', 'delivery_failed', 'cancelled', 'refund_initiated', 'refunded');
CREATE TYPE order_payment_method AS ENUM ('gold_balance', 'upi', 'card', 'netbanking', 'cod');
CREATE TYPE inventory_reservation_status AS ENUM ('reserved', 'confirmed', 'released', 'expired');
CREATE TYPE webhook_status AS ENUM ('received', 'processing', 'processed', 'ignored_duplicate', 'failed');
CREATE TYPE notification_type AS ENUM ('contribution_due', 'contribution_success', 'contribution_failed', 'milestone_reached', 'goal_completed', 'order_confirmed', 'order_shipped', 'order_delivered', 'kyc_verified', 'kyc_rejected', 'gold_rate_alert', 'aura_suggestion', 'product_back_in_stock', 'refund_initiated', 'refund_completed', 'referral_reward');
CREATE TYPE aura_flow_type AS ENUM ('goal_planning', 'product_discovery', 'gold_insights', 'chat');
CREATE TYPE aura_role AS ENUM ('aura', 'user');
CREATE TYPE referral_status AS ENUM ('pending', 'registered', 'rewarded');

-- ============================================
-- CORE TABLES
-- ============================================

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(15) UNIQUE NOT NULL,
  name VARCHAR(100),
  email VARCHAR(255) UNIQUE,
  city VARCHAR(100),
  kyc_status kyc_status DEFAULT 'not_started' NOT NULL,
  kyc_verified_at TIMESTAMPTZ(6),
  referral_code VARCHAR(20) UNIQUE,
  member_since DATE DEFAULT CURRENT_DATE NOT NULL,
  last_active_at TIMESTAMPTZ(6),
  deleted_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Auth Sessions
CREATE TABLE auth_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_token_hash VARCHAR(255) UNIQUE NOT NULL,
  device_id UUID,
  expires_at TIMESTAMPTZ(6) NOT NULL,
  revoked_at TIMESTAMPTZ(6),
  last_used_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- User Devices
CREATE TABLE user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform device_platform NOT NULL,
  push_token VARCHAR(500) UNIQUE NOT NULL,
  device_fingerprint VARCHAR(255),
  app_version VARCHAR(50),
  last_seen_at TIMESTAMPTZ(6),
  disabled_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Update auth_sessions foreign key for device
ALTER TABLE auth_sessions ADD CONSTRAINT auth_sessions_device_id_fkey 
  FOREIGN KEY (device_id) REFERENCES user_devices(id) ON DELETE SET NULL;

-- User Intents
CREATE TABLE user_intents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  intent_type intent_type NOT NULL,
  selected_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT true NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- OTP Sessions
CREATE TABLE otp_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(15) NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  otp_hash VARCHAR(255) NOT NULL,
  status otp_session_status DEFAULT 'pending' NOT NULL,
  attempts INT DEFAULT 0 NOT NULL,
  expires_at TIMESTAMPTZ(6) NOT NULL,
  verified_at TIMESTAMPTZ(6),
  blocked_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Gold Rate History
CREATE TABLE gold_rate_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purity purity NOT NULL,
  rate_per_gram_paise INT NOT NULL,
  effective_from TIMESTAMPTZ(6) NOT NULL,
  effective_to TIMESTAMPTZ(6),
  source VARCHAR(100) NOT NULL,
  created_by_admin_id UUID,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  icon_url VARCHAR(1000),
  image_url VARCHAR(1000),
  sort_order INT DEFAULT 0 NOT NULL,
  is_active BOOLEAN DEFAULT true NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Collections
CREATE TABLE collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  cover_image_url VARCHAR(1000),
  is_active BOOLEAN DEFAULT true NOT NULL,
  is_featured BOOLEAN DEFAULT false NOT NULL,
  valid_from DATE,
  valid_to DATE,
  sort_order INT DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Occasions
CREATE TABLE occasions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  icon_url VARCHAR(1000),
  bg_image_url VARCHAR(1000),
  is_active BOOLEAN DEFAULT true NOT NULL,
  sort_order INT DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Products
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sku VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  collection_id UUID REFERENCES collections(id) ON DELETE SET NULL,
  purity purity NOT NULL,
  hallmark_number VARCHAR(50),
  weight_grams DECIMAL(10, 4) NOT NULL,
  making_charge_pct DECIMAL(5, 2) NOT NULL,
  wastage_pct DECIMAL(5, 2) DEFAULT 0 NOT NULL,
  has_stones BOOLEAN DEFAULT false NOT NULL,
  stone_value_paise INT DEFAULT 0 NOT NULL,
  gst_pct DECIMAL(5, 2) DEFAULT 3.00 NOT NULL,
  stock_quantity INT DEFAULT 0 NOT NULL,
  is_published BOOLEAN DEFAULT false NOT NULL,
  is_featured BOOLEAN DEFAULT false NOT NULL,
  has_ar BOOLEAN DEFAULT false NOT NULL,
  ar_model_url VARCHAR(1000),
  sort_order INT DEFAULT 0 NOT NULL,
  deleted_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Product Images
CREATE TABLE product_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  s3_key VARCHAR(1000) NOT NULL,
  cdn_url VARCHAR(1000) NOT NULL,
  type product_image_type NOT NULL,
  sort_order INT DEFAULT 0 NOT NULL,
  is_primary BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Product Occasion Tags
CREATE TABLE product_occasion_tags (
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  occasion_id UUID NOT NULL REFERENCES occasions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (product_id, occasion_id)
);

-- CMS Banners
CREATE TABLE cms_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  image_url VARCHAR(1000) NOT NULL,
  cta_label VARCHAR(100),
  cta_route VARCHAR(500),
  placement VARCHAR(50) NOT NULL,
  sort_order INT DEFAULT 0 NOT NULL,
  valid_from TIMESTAMPTZ(6),
  valid_to TIMESTAMPTZ(6),
  is_active BOOLEAN DEFAULT true NOT NULL,
  created_by_admin_id UUID,
  updated_by_admin_id UUID,
  deleted_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Dream Vault Items
CREATE TABLE dream_vault_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  goal_id UUID,
  added_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  removed_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Cart Items
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INT DEFAULT 1 NOT NULL,
  added_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (user_id, product_id)
);

-- Addresses
CREATE TABLE addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label VARCHAR(50),
  full_name VARCHAR(100) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  pincode VARCHAR(6) NOT NULL,
  is_default BOOLEAN DEFAULT false NOT NULL,
  deleted_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Serviceable Pincodes
CREATE TABLE serviceable_pincodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pincode VARCHAR(6) UNIQUE NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  serviceable BOOLEAN NOT NULL,
  estimated_delivery_days INT,
  pickup_available BOOLEAN DEFAULT true NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Admin Users
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  role admin_role NOT NULL,
  password_hash VARCHAR(255),
  mfa_enabled BOOLEAN DEFAULT false NOT NULL,
  disabled_at TIMESTAMPTZ(6),
  last_login_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- KYC Documents
CREATE TABLE kyc_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  aadhaar_number_encrypted TEXT,
  aadhaar_verified BOOLEAN DEFAULT false NOT NULL,
  pan_number_encrypted TEXT,
  pan_verified BOOLEAN DEFAULT false NOT NULL,
  selfie_s3_key VARCHAR(1000),
  selfie_verified BOOLEAN DEFAULT false NOT NULL,
  name_on_aadhaar_encrypted TEXT,
  name_on_pan_encrypted TEXT,
  submitted_at TIMESTAMPTZ(6),
  reviewed_at TIMESTAMPTZ(6),
  rejection_reason TEXT,
  reviewer_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- KYC Aadhaar Sessions
CREATE TABLE kyc_aadhaar_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  aadhaar_number_encrypted TEXT NOT NULL,
  otp_hash VARCHAR(255) NOT NULL,
  attempts INT DEFAULT 0 NOT NULL,
  expires_at TIMESTAMPTZ(6) NOT NULL,
  verified_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Audit Logs
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_type VARCHAR(30) NOT NULL,
  actor_id UUID,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id UUID,
  before JSONB,
  after JSONB,
  reason TEXT,
  request_id UUID,
  ip_address VARCHAR(45),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Payment Methods
CREATE TABLE payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type payment_method_type NOT NULL,
  display_label VARCHAR(100) NOT NULL,
  provider payment_provider DEFAULT 'razorpay' NOT NULL,
  provider_token VARCHAR(500) NOT NULL,
  is_default BOOLEAN DEFAULT false NOT NULL,
  is_autopay_enabled BOOLEAN DEFAULT false NOT NULL,
  deleted_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Goals
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  scheme_type scheme_type DEFAULT 'aura' NOT NULL,
  goal_type goal_type NOT NULL,
  status goal_status DEFAULT 'active' NOT NULL,
  target_product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  target_amount_paise INT,
  target_grams DECIMAL(10, 4),
  monthly_amount_paise INT NOT NULL,
  duration_months INT NOT NULL,
  start_date DATE NOT NULL,
  next_contribution_date DATE NOT NULL,
  payment_method_id UUID REFERENCES payment_methods(id) ON DELETE SET NULL,
  completed_at TIMESTAMPTZ(6),
  paused_at TIMESTAMPTZ(6),
  cancelled_at TIMESTAMPTZ(6),
  discontinued_at TIMESTAMPTZ(6),
  discontinued_reason VARCHAR(500),
  bonus_eligible BOOLEAN DEFAULT true NOT NULL,
  booking_rate_paise_per_gram INT,
  aura_created BOOLEAN DEFAULT false NOT NULL,
  deleted_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Update dream_vault_items goal_id foreign key
ALTER TABLE dream_vault_items ADD CONSTRAINT dream_vault_items_goal_id_fkey 
  FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE SET NULL;

-- Plan Interests
CREATE TABLE plan_interests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  scheme_type scheme_type NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (user_id, scheme_type)
);

-- Contributions
CREATE TABLE contributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  payment_transaction_id UUID,
  amount_paise INT NOT NULL,
  gold_rate_per_gram_paise INT NOT NULL,
  grams_credited DECIMAL(10, 4),
  contribution_month DATE NOT NULL,
  type contribution_type NOT NULL,
  status contribution_status DEFAULT 'scheduled' NOT NULL,
  payment_method_id UUID REFERENCES payment_methods(id) ON DELETE SET NULL,
  completed_at TIMESTAMPTZ(6),
  failed_at TIMESTAMPTZ(6),
  failure_reason TEXT,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (goal_id, contribution_month, type)
);

-- Gold Ledger Entries
CREATE TABLE gold_ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  entry_type ledger_entry_type NOT NULL,
  status ledger_status DEFAULT 'posted' NOT NULL,
  grams_delta DECIMAL(10, 4) NOT NULL,
  amount_paise INT,
  gold_rate_per_gram_paise INT NOT NULL,
  source_type VARCHAR(50) NOT NULL,
  source_id UUID NOT NULL,
  correlation_id UUID NOT NULL,
  idempotency_key VARCHAR(100) UNIQUE,
  reversal_of_ledger_entry_id UUID REFERENCES gold_ledger_entries(id) ON DELETE SET NULL,
  posted_at TIMESTAMPTZ(6) NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Gold Balance Snapshots
CREATE TABLE gold_balance_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total_grams DECIMAL(10, 4) NOT NULL,
  total_value_paise INT NOT NULL,
  gold_rate_used_paise INT NOT NULL,
  snapshot_at TIMESTAMPTZ(6) NOT NULL,
  reason VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- User Milestones
CREATE TABLE user_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  milestone_type VARCHAR(50) NOT NULL,
  reached_at TIMESTAMPTZ(6) NOT NULL,
  celebrated_at TIMESTAMPTZ(6),
  goal_id UUID REFERENCES goals(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (user_id, milestone_type)
);

-- Payment Transactions
CREATE TABLE payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider payment_provider DEFAULT 'razorpay' NOT NULL,
  provider_payment_id VARCHAR(255) UNIQUE,
  provider_order_id VARCHAR(255),
  type payment_transaction_type NOT NULL,
  status payment_transaction_status NOT NULL,
  amount_paise INT NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR' NOT NULL,
  idempotency_key VARCHAR(100) UNIQUE,
  failure_code VARCHAR(100),
  failure_message TEXT,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Update contributions payment_transaction_id foreign key
ALTER TABLE contributions ADD CONSTRAINT contributions_payment_transaction_id_fkey 
  FOREIGN KEY (payment_transaction_id) REFERENCES payment_transactions(id) ON DELETE SET NULL;

-- Orders
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number VARCHAR(30) UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status order_status DEFAULT 'pending_payment' NOT NULL,
  total_paise INT NOT NULL,
  gold_value_paise INT NOT NULL,
  making_charges_paise INT NOT NULL,
  wastage_paise INT DEFAULT 0 NOT NULL,
  stone_value_paise INT DEFAULT 0 NOT NULL,
  gst_paise INT NOT NULL,
  making_charge_waiver_paise INT DEFAULT 0 NOT NULL,
  aura_plan_goal_id UUID,
  delivery_address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
  delivery_address_snapshot JSONB NOT NULL,
  payment_method order_payment_method NOT NULL,
  gold_balance_used_grams DECIMAL(10, 4) DEFAULT 0 NOT NULL,
  gold_rate_at_order_paise INT NOT NULL,
  payment_transaction_id UUID REFERENCES payment_transactions(id) ON DELETE SET NULL,
  notes TEXT,
  shipped_at TIMESTAMPTZ(6),
  delivered_at TIMESTAMPTZ(6),
  cancelled_at TIMESTAMPTZ(6),
  refunded_at TIMESTAMPTZ(6),
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Order Items
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  product_snapshot JSONB NOT NULL,
  quantity INT DEFAULT 1 NOT NULL,
  unit_price_paise INT NOT NULL,
  weight_grams DECIMAL(10, 4) NOT NULL,
  gold_rate_paise INT NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Inventory Reservations
CREATE TABLE inventory_reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  quantity INT NOT NULL,
  status inventory_reservation_status NOT NULL,
  reserved_at TIMESTAMPTZ(6) NOT NULL,
  expires_at TIMESTAMPTZ(6) NOT NULL,
  confirmed_at TIMESTAMPTZ(6),
  released_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Ledger Adjustments
CREATE TABLE ledger_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  grams_delta DECIMAL(10, 4) NOT NULL,
  amount_paise INT,
  reason TEXT NOT NULL,
  status ledger_adjustment_status DEFAULT 'pending' NOT NULL,
  requested_by_admin_id UUID NOT NULL REFERENCES admin_users(id) ON DELETE RESTRICT,
  approved_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  idempotency_key VARCHAR(100) UNIQUE NOT NULL,
  approved_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- SAR Reviews
CREATE TABLE sar_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status sar_review_status DEFAULT 'pending' NOT NULL,
  decision_reason TEXT,
  decided_by_admin_id UUID REFERENCES admin_users(id) ON DELETE SET NULL,
  decided_at TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Webhook Events
CREATE TABLE webhook_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider VARCHAR(50) NOT NULL,
  provider_event_id VARCHAR(255) NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  status webhook_status NOT NULL,
  payload JSONB NOT NULL,
  signature_valid BOOLEAN NOT NULL,
  received_at TIMESTAMPTZ(6) NOT NULL,
  processed_at TIMESTAMPTZ(6),
  error_message TEXT,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (provider, provider_event_id)
);

-- Idempotency Keys
CREATE TABLE idempotency_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  key VARCHAR(100) NOT NULL,
  scope VARCHAR(100) NOT NULL,
  request_hash VARCHAR(255) NOT NULL,
  response_snapshot JSONB,
  resource_type VARCHAR(50),
  resource_id UUID,
  expires_at TIMESTAMPTZ(6) NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (scope, key)
);

-- Notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  deep_link VARCHAR(500),
  metadata JSONB,
  idempotency_key VARCHAR(200) UNIQUE,
  is_read BOOLEAN DEFAULT false NOT NULL,
  is_sent BOOLEAN DEFAULT false NOT NULL,
  sent_at TIMESTAMPTZ(6),
  read_at TIMESTAMPTZ(6),
  scheduled_for TIMESTAMPTZ(6),
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Notification Preferences
CREATE TABLE notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  push_enabled BOOLEAN DEFAULT true NOT NULL,
  contributions_enabled BOOLEAN DEFAULT true NOT NULL,
  milestones_enabled BOOLEAN DEFAULT true NOT NULL,
  orders_enabled BOOLEAN DEFAULT true NOT NULL,
  kyc_enabled BOOLEAN DEFAULT true NOT NULL,
  aura_enabled BOOLEAN DEFAULT true NOT NULL,
  gold_rate_alert_enabled BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Aura Sessions
CREATE TABLE aura_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  flow_type aura_flow_type NOT NULL,
  summary TEXT,
  started_at TIMESTAMPTZ(6) NOT NULL,
  ended_at TIMESTAMPTZ(6),
  expires_at TIMESTAMPTZ(6) NOT NULL,
  goal_created BOOLEAN DEFAULT false NOT NULL,
  products_added_to_vault INT DEFAULT 0 NOT NULL,
  goal_id_created UUID REFERENCES goals(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Aura Messages
CREATE TABLE aura_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES aura_sessions(id) ON DELETE CASCADE,
  role aura_role NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB,
  sequence INT NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (session_id, sequence)
);

-- Product Views
CREATE TABLE product_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  anonymous_id VARCHAR(100),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  source VARCHAR(50),
  viewed_at TIMESTAMPTZ(6) NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Referrals
CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  referred_user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
  referral_code VARCHAR(20) NOT NULL,
  status referral_status DEFAULT 'pending' NOT NULL,
  registered_at TIMESTAMPTZ(6),
  rewarded_at TIMESTAMPTZ(6),
  reward_type VARCHAR(50),
  reward_value_paise INT,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Store Locations
CREATE TABLE store_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  pincode VARCHAR(6) NOT NULL,
  phone VARCHAR(15) NOT NULL,
  latitude DECIMAL(9, 6) NOT NULL,
  longitude DECIMAL(9, 6) NOT NULL,
  opening_hours JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true NOT NULL,
  created_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ============================================
-- INDEXES
-- ============================================

-- Users indexes
CREATE INDEX idx_users_kyc_status ON users(kyc_status);
CREATE INDEX idx_users_last_active_at ON users(last_active_at);

-- Auth sessions indexes
CREATE INDEX idx_auth_sessions_user_id ON auth_sessions(user_id);
CREATE INDEX idx_auth_sessions_device_id ON auth_sessions(device_id);
CREATE INDEX idx_auth_sessions_expires_at ON auth_sessions(expires_at);

-- User devices indexes
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);
CREATE INDEX idx_user_devices_last_seen_at ON user_devices(last_seen_at);

-- User intents indexes
CREATE INDEX idx_user_intents_user_id ON user_intents(user_id);
CREATE INDEX idx_user_intents_intent_type ON user_intents(intent_type);

-- OTP sessions indexes
CREATE INDEX idx_otp_sessions_phone ON otp_sessions(phone);
CREATE INDEX idx_otp_sessions_expires_at ON otp_sessions(expires_at);
CREATE INDEX idx_otp_sessions_status ON otp_sessions(status);

-- Gold rate history indexes
CREATE INDEX idx_gold_rate_history_purity_effective_from ON gold_rate_history(purity, effective_from DESC);
CREATE INDEX idx_gold_rate_history_purity_effective_to ON gold_rate_history(purity, effective_to);

-- Categories indexes
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_is_active ON categories(is_active);
CREATE INDEX idx_categories_sort_order ON categories(sort_order);

-- Collections indexes
CREATE INDEX idx_collections_is_active ON collections(is_active);
CREATE INDEX idx_collections_is_featured ON collections(is_featured);
CREATE INDEX idx_collections_valid_from ON collections(valid_from);
CREATE INDEX idx_collections_valid_to ON collections(valid_to);

-- Occasions indexes
CREATE INDEX idx_occasions_is_active ON occasions(is_active);
CREATE INDEX idx_occasions_sort_order ON occasions(sort_order);

-- Products indexes
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_collection_id ON products(collection_id);
CREATE INDEX idx_products_purity ON products(purity);
CREATE INDEX idx_products_is_featured ON products(is_featured);
CREATE INDEX idx_products_published_deleted_at ON products(is_published, deleted_at);

-- Product images indexes
CREATE INDEX idx_product_images_product_id ON product_images(product_id);
CREATE INDEX idx_product_images_product_id_sort_order ON product_images(product_id, sort_order);

-- Product occasion tags indexes
CREATE INDEX idx_product_occasion_tags_occasion_id ON product_occasion_tags(occasion_id);
CREATE INDEX idx_product_occasion_tags_product_id ON product_occasion_tags(product_id);

-- CMS banners indexes
CREATE INDEX idx_cms_banners_placement_is_active_sort_order ON cms_banners(placement, is_active, sort_order);
CREATE INDEX idx_cms_banners_valid_from ON cms_banners(valid_from);
CREATE INDEX idx_cms_banners_valid_to ON cms_banners(valid_to);

-- Dream vault items indexes
CREATE INDEX idx_dream_vault_items_user_id ON dream_vault_items(user_id);
CREATE INDEX idx_dream_vault_items_product_id ON dream_vault_items(product_id);
CREATE INDEX idx_dream_vault_items_goal_id ON dream_vault_items(goal_id);

-- Cart items indexes
CREATE INDEX idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);

-- Addresses indexes
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_pincode ON addresses(pincode);
CREATE INDEX idx_addresses_user_id_is_default ON addresses(user_id, is_default);

-- Serviceable pincodes indexes
CREATE INDEX idx_serviceable_pincodes_serviceable ON serviceable_pincodes(serviceable);

-- Admin users indexes
CREATE INDEX idx_admin_users_email ON admin_users(email);
CREATE INDEX idx_admin_users_role ON admin_users(role);

-- KYC documents indexes
CREATE INDEX idx_kyc_documents_user_id ON kyc_documents(user_id);
CREATE INDEX idx_kyc_documents_submitted_at ON kyc_documents(submitted_at);
CREATE INDEX idx_kyc_documents_reviewed_at ON kyc_documents(reviewed_at);
CREATE INDEX idx_kyc_documents_reviewer_id ON kyc_documents(reviewer_id);

-- KYC aadhaar sessions indexes
CREATE INDEX idx_kyc_aadhaar_sessions_user_id ON kyc_aadhaar_sessions(user_id);
CREATE INDEX idx_kyc_aadhaar_sessions_expires_at ON kyc_aadhaar_sessions(expires_at);

-- Audit logs indexes
CREATE INDEX idx_audit_logs_entity_type_entity_id ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_actor_type_actor_id ON audit_logs(actor_type, actor_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Payment methods indexes
CREATE INDEX idx_payment_methods_user_id ON payment_methods(user_id);
CREATE INDEX idx_payment_methods_user_id_is_default ON payment_methods(user_id, is_default);

-- Goals indexes
CREATE INDEX idx_goals_user_id_status ON goals(user_id, status);
CREATE INDEX idx_goals_scheme_type ON goals(scheme_type);
CREATE INDEX idx_goals_target_product_id ON goals(target_product_id);
CREATE INDEX idx_goals_next_contribution_date ON goals(next_contribution_date);

-- Plan interests indexes
CREATE INDEX idx_plan_interests_scheme_type ON plan_interests(scheme_type);

-- Contributions indexes
CREATE INDEX idx_contributions_goal_id_contribution_month ON contributions(goal_id, contribution_month DESC);
CREATE INDEX idx_contributions_user_id_status ON contributions(user_id, status);
CREATE INDEX idx_contributions_contribution_month ON contributions(contribution_month);

-- Gold ledger entries indexes
CREATE INDEX idx_gold_ledger_entries_user_id_posted_at ON gold_ledger_entries(user_id, posted_at DESC);
CREATE INDEX idx_gold_ledger_entries_user_id_status ON gold_ledger_entries(user_id, status);
CREATE INDEX idx_gold_ledger_entries_source_type_source_id ON gold_ledger_entries(source_type, source_id);
CREATE INDEX idx_gold_ledger_entries_correlation_id ON gold_ledger_entries(correlation_id);

-- Gold balance snapshots indexes
CREATE INDEX idx_gold_balance_snapshots_user_id_snapshot_at ON gold_balance_snapshots(user_id, snapshot_at DESC);

-- User milestones indexes
CREATE INDEX idx_user_milestones_user_id_celebrated_at ON user_milestones(user_id, celebrated_at);

-- Payment transactions indexes
CREATE INDEX idx_payment_transactions_user_id ON payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_status ON payment_transactions(status);
CREATE INDEX idx_payment_transactions_provider_order_id ON payment_transactions(provider_order_id);

-- Orders indexes
CREATE INDEX idx_orders_user_id_created_at ON orders(user_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_payment_transaction_id ON orders(payment_transaction_id);

-- Order items indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Inventory reservations indexes
CREATE INDEX idx_inventory_reservations_product_id_status ON inventory_reservations(product_id, status);
CREATE INDEX idx_inventory_reservations_expires_at ON inventory_reservations(expires_at);
CREATE INDEX idx_inventory_reservations_order_id ON inventory_reservations(order_id);
CREATE INDEX idx_inventory_reservations_user_id ON inventory_reservations(user_id);

-- Ledger adjustments indexes
CREATE INDEX idx_ledger_adjustments_user_id ON ledger_adjustments(user_id);
CREATE INDEX idx_ledger_adjustments_status ON ledger_adjustments(status);

-- SAR reviews indexes
CREATE INDEX idx_sar_reviews_status ON sar_reviews(status);

-- Webhook events indexes
CREATE INDEX idx_webhook_events_status ON webhook_events(status);
CREATE INDEX idx_webhook_events_received_at ON webhook_events(received_at);

-- Idempotency keys indexes
CREATE INDEX idx_idempotency_keys_expires_at ON idempotency_keys(expires_at);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id_created_at ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_user_id_is_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_scheduled_for ON notifications(scheduled_for);

-- Aura sessions indexes
CREATE INDEX idx_aura_sessions_user_id_started_at ON aura_sessions(user_id, started_at DESC);
CREATE INDEX idx_aura_sessions_expires_at ON aura_sessions(expires_at);

-- Aura messages indexes
CREATE INDEX idx_aura_messages_session_id_sequence ON aura_messages(session_id, sequence);

-- Product views indexes
CREATE INDEX idx_product_views_user_id_viewed_at ON product_views(user_id, viewed_at DESC);
CREATE INDEX idx_product_views_product_id_viewed_at ON product_views(product_id, viewed_at DESC);
CREATE INDEX idx_product_views_anonymous_id ON product_views(anonymous_id);

-- Referrals indexes
CREATE INDEX idx_referrals_referrer_user_id ON referrals(referrer_user_id);
CREATE INDEX idx_referrals_status ON referrals(status);
CREATE INDEX idx_referrals_referral_code ON referrals(referral_code);

-- Store locations indexes
CREATE INDEX idx_store_locations_city ON store_locations(city);
CREATE INDEX idx_store_locations_pincode ON store_locations(pincode);
CREATE INDEX idx_store_locations_is_active ON store_locations(is_active);
CREATE INDEX idx_store_locations_lat_lng ON store_locations(latitude, longitude);

-- ============================================
-- MIGRATIONS TRACKING TABLE (Prisma)
-- ============================================

CREATE TABLE IF NOT EXISTS "_prisma_migrations" (
  id VARCHAR(36) PRIMARY KEY,
  checksum VARCHAR(64) NOT NULL,
  finished_at TIMESTAMPTZ(6),
  migration_name VARCHAR(255) NOT NULL,
  logs TEXT,
  rolled_back_at TIMESTAMPTZ(6),
  started_at TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  applied_steps_count INT DEFAULT 0 NOT NULL
);

-- ============================================
-- SEED ADMIN USER
-- ============================================

-- Insert the admin user: admin@moozhayil.com / Admin123!@#
-- Password hash is bcrypt for "Admin123!@#"
INSERT INTO admin_users (id, email, name, role, password_hash, mfa_enabled, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'admin@moozhayil.com',
  'Admin',
  'super_admin',
  '$2b$10$VYR5K8lOkbB5XkD6X3fWOuQZRGK5wXHn8h8Ev8vL0yFLxJ2gBP4Iq',
  false,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

-- All tables, indexes, and admin user created successfully!
-- You can now run your API with this database.
