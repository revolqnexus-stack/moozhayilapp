import {
  assertKycGate,
  checkCheckoutGate,
  checkContributionGate,
  checkGoalCreationGate,
  checkRedemptionGate,
} from "../src/utils/kyc_gates";
import { AppError } from "../src/middleware/error.middleware";

describe("KYC gate rules", () => {
  it("requires basic KYC for scheme enrollment", () => {
    expect(checkGoalCreationGate("not_started").allowed).toBe(false);
    expect(checkGoalCreationGate("basic_verified").allowed).toBe(true);
    expect(checkGoalCreationGate("enhanced_verified").allowed).toBe(true);
  });

  it("requires enhanced KYC for monthly contributions above ₹50,000", () => {
    expect(
      checkContributionGate("basic_verified", 5_000_000).allowed,
    ).toBe(true);
    expect(
      checkContributionGate("basic_verified", 5_000_001).allowed,
    ).toBe(false);
    expect(
      checkContributionGate("enhanced_verified", 20_000_000).allowed,
    ).toBe(true);
  });

  it("requires KYC for My Gold redemption", () => {
    expect(checkRedemptionGate("not_started").allowed).toBe(false);
    expect(checkRedemptionGate("in_review").allowed).toBe(false);
    expect(checkRedemptionGate("basic_verified").allowed).toBe(true);
    expect(checkRedemptionGate("enhanced_verified").allowed).toBe(true);
  });

  it("requires KYC for checkout with gold balance or high-value orders", () => {
    expect(checkCheckoutGate("not_started", 1_000_000, true).allowed).toBe(
      false,
    );
    expect(checkCheckoutGate("basic_verified", 1_000_000, true).allowed).toBe(
      true,
    );
    expect(checkCheckoutGate("not_started", 5_000_001, false).allowed).toBe(
      false,
    );
    expect(checkCheckoutGate("basic_verified", 5_000_001, false).allowed).toBe(
      true,
    );
    expect(checkCheckoutGate("not_started", 1_000_000, false).allowed).toBe(
      true,
    );
  });

  it("assertKycGate throws 403 KYC_REQUIRED with status details", () => {
    expect(() =>
      assertKycGate(checkRedemptionGate("not_started"), "not_started"),
    ).toThrow(AppError);

    try {
      assertKycGate(checkRedemptionGate("not_started"), "not_started");
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      const appError = error as AppError;
      expect(appError.statusCode).toBe(403);
      expect(appError.code).toBe("KYC_REQUIRED");
      expect(appError.details).toEqual({ kyc_status: "not_started" });
    }
  });
});
