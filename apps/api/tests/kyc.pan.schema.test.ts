import { verifyPanSchema } from "../src/modules/kyc/kyc.schema";

describe("verifyPanSchema", () => {
  it("uppercases and validates PAN format", () => {
    const parsed = verifyPanSchema.parse({ pan_number: "abcde1234f" });
    expect(parsed.pan_number).toBe("ABCDE1234F");
  });

  it("rejects malformed PAN before provider call", () => {
    expect(() => verifyPanSchema.parse({ pan_number: "BAD-PAN" })).toThrow();
  });

  it("trims optional name and drops empty values", () => {
    const parsed = verifyPanSchema.parse({
      pan_number: "ABCDE1234F",
      name: "  Rahul Kumar  ",
    });
    expect(parsed.name).toBe("Rahul Kumar");

    const withoutName = verifyPanSchema.parse({
      pan_number: "ABCDE1234F",
      name: "   ",
    });
    expect(withoutName.name).toBeUndefined();
  });
});
