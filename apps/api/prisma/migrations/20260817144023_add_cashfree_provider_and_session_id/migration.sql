-- Add Cashfree to payment_provider enum
ALTER TYPE payment_provider ADD VALUE IF NOT EXISTS 'cashfree';

-- Add provider_session_id column to payment_transactions table
ALTER TABLE payment_transactions 
ADD COLUMN IF NOT EXISTS provider_session_id VARCHAR(500);

-- Add index for provider_session_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_payment_transactions_provider_session_id 
ON payment_transactions(provider_session_id);
