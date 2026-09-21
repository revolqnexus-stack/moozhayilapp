-- CreateEnum
CREATE TYPE "PriceQuoteStatus" AS ENUM ('active', 'consumed', 'superseded', 'expired');

-- CreateTable
CREATE TABLE "price_quotes" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "status" "PriceQuoteStatus" NOT NULL DEFAULT 'active',
    "valid_until" TIMESTAMPTZ(6) NOT NULL,
    "server_time_at_issue" TIMESTAMPTZ(6) NOT NULL,
    "total_paise" INTEGER NOT NULL,
    "gold_value_paise" INTEGER NOT NULL,
    "making_charges_paise" INTEGER NOT NULL,
    "wastage_paise" INTEGER NOT NULL DEFAULT 0,
    "stone_value_paise" INTEGER NOT NULL DEFAULT 0,
    "gst_paise" INTEGER NOT NULL,
    "making_charge_waiver_paise" INTEGER NOT NULL DEFAULT 0,
    "aura_plan_goal_id" UUID,
    "gold_rate_at_quote_paise" INTEGER NOT NULL,
    "lines_json" JSONB NOT NULL,
    "consumed_order_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "price_quotes_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "orders" ADD COLUMN "price_quote_id" UUID;

-- CreateIndex
CREATE INDEX "idx_price_quotes_user_id_status" ON "price_quotes"("user_id", "status");

-- CreateIndex
CREATE INDEX "idx_price_quotes_valid_until" ON "price_quotes"("valid_until");

-- AddForeignKey
ALTER TABLE "price_quotes" ADD CONSTRAINT "price_quotes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
