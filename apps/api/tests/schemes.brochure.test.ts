import Decimal from "decimal.js";
import { calculateGramsFromPaise } from "../src/utils/gold";
import { calculateAuraMcWaiver } from "../src/modules/goals/aura.mc_waiver.service";
import { calculateProductPrice } from "../src/modules/products/price";

/** Brochure illustration checks — not contractual rates. */
describe("Golden Wish brochure math (implementation checks)", () => {
  it("CREST: ₹50,000 at ₹7,740/g ≈ 6.459948 g before display rounding", () => {
    const advancePaise = 5_000_000;
    const ratePaisePerGram = 774_000;
    const grams = calculateGramsFromPaise(advancePaise, ratePaisePerGram);
    expect(grams.toFixed(4)).toBe("6.4599");
    expect(grams.toDecimalPlaces(3, Decimal.ROUND_DOWN).toFixed(3)).toBe(
      "6.459",
    );
  });

  it("AURA: 11 × ₹1,000 contributions total ₹11,000 in paise", () => {
    const installmentPaise = 100_000;
    const totalPaise = installmentPaise * 11;
    expect(totalPaise).toBe(1_100_000);
  });

  it("AURA brochure redemption example: ₹11,000 ÷ ₹7,860/g ≈ 1.399491 g (rupee÷rate model)", () => {
    const balancePaise = 1_100_000;
    const redemptionRatePaise = 786_000;
    const grams = calculateGramsFromPaise(balancePaise, redemptionRatePaise);
    expect(grams.toFixed(4)).toBe("1.3994");
  });

  it("20% MC discount on ₹5,000 making is ₹1,000 (reference — not current Aura waiver formula)", () => {
    const makingPaise = 500_000;
    const discountPaise = Math.round(makingPaise * 0.2);
    expect(discountPaise).toBe(100_000);
  });

  it("Aura waiver model: waives min(MC%, cap%) of gold value, full MC when MC ≤ cap", () => {
    const price = calculateProductPrice({
      weightGrams: "10.0000",
      ratePerGramPaise: 624_000,
      makingChargePct: "12.00",
      wastagePct: "0.00",
      stoneValuePaise: 0,
      gstPct: "3.00",
      rateUpdatedAt: new Date("2026-06-26T04:30:00Z"),
    });

    const waiver = calculateAuraMcWaiver({
      goldValuePaise: price.gold_value_paise,
      makingChargePct: "12.00",
      makingChargePaise: price.making_charge_paise,
      maxWaiverPct: 20,
    });

    expect(waiver.waived_making_paise).toBe(price.making_charge_paise);
    expect(waiver.payable_making_paise).toBe(0);
  });
});
