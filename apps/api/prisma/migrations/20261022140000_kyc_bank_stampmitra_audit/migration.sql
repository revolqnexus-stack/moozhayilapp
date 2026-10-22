ALTER TABLE "kyc_documents"
ADD COLUMN "bank_account_number_encrypted" TEXT,
ADD COLUMN "bank_ifsc_encrypted" TEXT,
ADD COLUMN "bank_verified" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "bank_verification_reference_id" VARCHAR(64),
ADD COLUMN "bank_verification_valid" BOOLEAN,
ADD COLUMN "bank_verified_at" TIMESTAMPTZ(6),
ADD COLUMN "name_at_bank_encrypted" TEXT;
