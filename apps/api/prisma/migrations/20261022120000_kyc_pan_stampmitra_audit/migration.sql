-- StampMitra PAN verification audit fields on KYC documents
ALTER TABLE "kyc_documents"
ADD COLUMN "pan_verification_reference_id" VARCHAR(64),
ADD COLUMN "pan_verification_valid" BOOLEAN,
ADD COLUMN "pan_verified_at" TIMESTAMPTZ(6);
