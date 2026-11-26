import { z } from "zod";

import {
  MIN_MONTHLY_CONTRIBUTION_PAISE,
  VALID_GOAL_DURATIONS_MONTHS,
} from "../../config/goals.constants";
import {
  AURA_DURATION_MONTHS,
  AURA_INSTALLMENT_STEP_PAISE,
  AURA_MIN_INSTALLMENT_PAISE,
} from "../../config/aura.constants";
import {
  CREST_ADVANCE_STEP_PAISE,
  CREST_DURATION_MONTHS,
  CREST_MIN_ADVANCE_PAISE,
} from "../../config/crest.constants";
import {
  DHANAM_ADVANCE_STEP_PAISE,
  DHANAM_DURATION_MONTHS,
  DHANAM_MIN_ADVANCE_PAISE,
} from "../../config/dhanam.constants";
import {
  GOLD_NIDHI_DEPOSIT_STEP_PAISE,
  GOLD_NIDHI_MIN_DEPOSIT_PAISE,
  GOLD_NIDHI_OPEN_DURATION_MONTHS,
} from "../../config/gold_nidhi.constants";
import { DEFAULT_SCHEME_TYPE, SCHEME_TYPES } from "../../config/schemes.constants";

export const listGoalsQuerySchema = z.object({
  status: z.enum(["active", "completed", "paused", "all"]).default("all"),
});

export const createGoalSchema = z
  .object({
    scheme_type: z.enum(SCHEME_TYPES).optional(),
    goal_type: z.enum([
      "wedding",
      "investment",
      "festival",
      "gift",
      "family",
      "other",
    ]),
    name: z.string().trim().min(1).max(255),
    // Older app builds send "browse-later" when the customer skips linking a
    // piece. Treat anything that is not a real product id as "no product".
    target_product_id: z.preprocess(
      (value) =>
        typeof value === "string" &&
        /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)
          ? value
          : undefined,
      z.string().uuid().optional(),
    ),
    target_amount_paise: z.number().int().positive().optional(),
    monthly_amount_paise: z.number().int().positive(),
    duration_months: z.number().int().positive(),
    payment_method_id: z.string().uuid().optional(),
    start_date: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, "start_date must be YYYY-MM-DD"),
  })
  .superRefine((value, ctx) => {
    const schemeType = value.scheme_type ?? DEFAULT_SCHEME_TYPE;

    if (schemeType === "aura") {
      if (value.duration_months !== AURA_DURATION_MONTHS) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Aura Plan runs for 11 months",
          path: ["duration_months"],
        });
      }

      if (value.monthly_amount_paise < AURA_MIN_INSTALLMENT_PAISE) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Minimum Aura installment is ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      if (value.monthly_amount_paise % AURA_INSTALLMENT_STEP_PAISE !== 0) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Aura installment must be in multiples of ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      return;
    }

    if (schemeType === "crest") {
      if (value.duration_months !== CREST_DURATION_MONTHS) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Crest is a single advance payment plan",
          path: ["duration_months"],
        });
      }

      if (value.monthly_amount_paise < CREST_MIN_ADVANCE_PAISE) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Minimum Crest advance is ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      if (value.monthly_amount_paise % CREST_ADVANCE_STEP_PAISE !== 0) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Crest advance must be in multiples of ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      return;
    }

    if (schemeType === "dhanam") {
      if (value.duration_months !== DHANAM_DURATION_MONTHS) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Dhanam booking runs for 12 months",
          path: ["duration_months"],
        });
      }

      if (value.monthly_amount_paise < DHANAM_MIN_ADVANCE_PAISE) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Minimum Dhanam booking advance is ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      if (value.monthly_amount_paise % DHANAM_ADVANCE_STEP_PAISE !== 0) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Dhanam advance must be in multiples of ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      return;
    }

    if (schemeType === "gold_nidhi") {
      if (value.duration_months !== GOLD_NIDHI_OPEN_DURATION_MONTHS) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Gold Nidhi is an open-ended plan",
          path: ["duration_months"],
        });
      }

      if (value.monthly_amount_paise < GOLD_NIDHI_MIN_DEPOSIT_PAISE) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Minimum Gold Nidhi deposit is ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      if (value.monthly_amount_paise % GOLD_NIDHI_DEPOSIT_STEP_PAISE !== 0) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: "Gold Nidhi deposits must be in multiples of ₹500",
          path: ["monthly_amount_paise"],
        });
      }

      return;
    }

    if (value.monthly_amount_paise < MIN_MONTHLY_CONTRIBUTION_PAISE) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "Monthly contribution below minimum",
        path: ["monthly_amount_paise"],
      });
    }

    if (
      !(VALID_GOAL_DURATIONS_MONTHS as readonly number[]).includes(
        value.duration_months,
      )
    ) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "Duration must be one of 12, 18, 24, or 36 months",
        path: ["duration_months"],
      });
    }
  });

export const patchGoalSchema = z
  .object({
    name: z.string().trim().min(1).max(255).optional(),
    status: z.enum(["paused", "active"]).optional(),
  })
  .refine((value) => value.name !== undefined || value.status !== undefined, {
    message: "At least one field must be provided",
  });

export const contributeSchema = z.object({
  amount_paise: z.number().int().positive(),
  payment_method_id: z.string().uuid().optional(),
});

export type ListGoalsQuery = z.infer<typeof listGoalsQuerySchema>;
export type CreateGoalInput = z.infer<typeof createGoalSchema>;
export type PatchGoalInput = z.infer<typeof patchGoalSchema>;
export type ContributeInput = z.infer<typeof contributeSchema>;
