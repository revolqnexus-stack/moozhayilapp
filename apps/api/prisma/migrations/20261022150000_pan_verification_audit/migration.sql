-- Audit fields for StampMitra PAN checks. The PAN number itself stays encrypted
-- only after an accepted verification.
ALTER TABLE "kyc_documents"
  ADD COLUMN "pan_reference_id" VARCHAR(64),
  ADD COLUMN "pan_valid" BOOLEAN,
  ADD COLUMN "pan_checked_at" TIMESTAMPTZ(6);
