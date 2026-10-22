import { verifyBankAccountSchema } from "../src/modules/kyc/kyc.schema";

describe("verifyBankAccountSchema", () => {
  it("normalizes account digits and IFSC", () => {
    const parsed = verifyBankAccountSchema.parse({
      account_number: "000-123456789",
      ifsc: "icic0001234",
    });
    expect(parsed.account_number).toBe("000123456789");
    expect(parsed.ifsc).toBe("ICIC0001234");
  });

  it("rejects short account numbers", () => {
    expect(() =>
      verifyBankAccountSchema.parse({
        account_number: "12345",
        ifsc: "ICIC0001234",
      }),
    ).toThrow();
  });

  it("rejects invalid IFSC before provider call", () => {
    expect(() =>
      verifyBankAccountSchema.parse({
        account_number: "123456789",
        ifsc: "INVALID",
      }),
    ).toThrow();
  });
});
