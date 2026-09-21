import type { Request, Response } from "express";
import { AppError } from "../../middleware/error.middleware";
import { quoteService } from "./quote.service";
import { createQuoteSchema } from "./quote.schema";

function requireUserId(req: Request): string {
  if (!req.user) {
    throw new AppError(401, "UNAUTHORIZED", "Missing access token");
  }

  return req.user.userId;
}

export class QuoteController {
  async createFromCart(req: Request, res: Response): Promise<void> {
    res.status(201).json(await quoteService.createFromCart(requireUserId(req)));
  }

  async create(req: Request, res: Response): Promise<void> {
    const input = createQuoteSchema.parse(req.body ?? {});
    const userId = requireUserId(req);

    if (input.items?.length) {
      res
        .status(201)
        .json(await quoteService.createQuote(userId, input.items));
      return;
    }

    res.status(201).json(await quoteService.createFromCart(userId));
  }
}

export const quoteController = new QuoteController();
