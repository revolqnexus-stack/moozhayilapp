import {
  isBankNameMatchResultOk,
  maskBankAccountNumber,
} from "../src/modules/kyc/bank_account.util";

describe("bank_account.util", () => {
  it("masks account numbers for display", () => {
    expect(maskBankAccountNumber("000123456789")).toBe("••••••6789");
  });

  it("accepts GOOD_MATCH when a name was supplied", () => {
    expect(isBankNameMatchResultOk("GOOD_MATCH", true)).toBe(true);
    expect(isBankNameMatchResultOk("NO_MATCH", true)).toBe(false);
  });

  it("skips name match when no name was supplied", () => {
    expect(isBankNameMatchResultOk("NO_MATCH", false)).toBe(true);
  });
});
