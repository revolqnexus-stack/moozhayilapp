import { resolveContributionGramsCredited } from "../src/modules/goals/crest.service";
import { calculateGramsFromPaise } from "../src/utils/gold";

describe("CREST contribution grams (regression)", () => {
  const enrollRatePaise = 774_000;
  const paymentRatePaise = 800_000;
  const advancePaise = 5_000_000;
  const lockedTarget = calculateGramsFromPaise(
    advancePaise,
    enrollRatePaise,
  ).toFixed(4);

  it("credits locked target grams when payment rate differs from enrollment", () => {
    const grams = resolveContributionGramsCredited({
      schemeType: "crest",
      targetGrams: lockedTarget,
      amountPaise: advancePaise,
      goldRatePerGramPaise: paymentRatePaise,
    });

    expect(grams.toFixed(4)).toBe(lockedTarget);
    expect(grams.toFixed(4)).not.toBe(
      calculateGramsFromPaise(advancePaise, paymentRatePaise).toFixed(4),
    );
  });

  it("legacy: without targetGrams, falls back to amount ÷ payment rate", () => {
    const grams = resolveContributionGramsCredited({
      schemeType: "crest",
      targetGrams: null,
      amountPaise: advancePaise,
      goldRatePerGramPaise: paymentRatePaise,
    });

    expect(grams.toFixed(4)).toBe(
      calculateGramsFromPaise(advancePaise, paymentRatePaise).toFixed(4),
    );
  });

  it("aura installments are not overridden by crest locking helper", () => {
    const grams = resolveContributionGramsCredited({
      schemeType: "aura",
      targetGrams: lockedTarget,
      amountPaise: 100_000,
      goldRatePerGramPaise: enrollRatePaise,
    });

    expect(grams.toFixed(4)).toBe(
      calculateGramsFromPaise(100_000, enrollRatePaise).toFixed(4),
    );
  });
});
