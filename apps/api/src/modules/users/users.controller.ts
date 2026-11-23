import type { Request, Response } from "express";
import { z } from "zod";
import { AppError } from "../../middleware/error.middleware";
import {
  registerDeviceSchema,
  saveIntentSchema,
  updateMeSchema,
} from "./users.schema";
import { usersService } from "./users.service";

function requireUserId(req: Request): string {
  if (!req.user) {
    throw new AppError(401, "UNAUTHORIZED", "Missing access token");
  }

  return req.user.userId;
}

export class UsersController {
  async getMe(req: Request, res: Response): Promise<void> {
    const result = await usersService.getMe(requireUserId(req));
    res.status(200).json(result);
  }

  async updateMe(req: Request, res: Response): Promise<void> {
    console.log('📝 PATCH /user/me - Request body:', JSON.stringify(req.body));
    console.log('📝 PATCH /user/me - User ID:', req.user?.userId);
    const input = updateMeSchema.parse(req.body);
    console.log('📝 PATCH /user/me - Parsed input:', JSON.stringify(input));
    const result = await usersService.updateMe(requireUserId(req), input);
    console.log('📝 PATCH /user/me - Success:', JSON.stringify(result));
    res.status(200).json(result);
  }

  async saveIntent(req: Request, res: Response): Promise<void> {
    console.log('🎯 POST /user/intent - Request body:', JSON.stringify(req.body));
    console.log('🎯 POST /user/intent - User ID:', req.user?.userId);
    const input = saveIntentSchema.parse(req.body);
    console.log('🎯 POST /user/intent - Parsed input:', JSON.stringify(input));
    const result = await usersService.saveIntents(requireUserId(req), input);
    console.log('🎯 POST /user/intent - Success:', JSON.stringify(result));
    res.status(200).json(result);
  }

  async registerDevice(req: Request, res: Response): Promise<void> {
    const input = registerDeviceSchema.parse(req.body);
    const result = await usersService.registerDevice(requireUserId(req), input);
    res.status(200).json(result);
  }

  async deleteDevice(req: Request, res: Response): Promise<void> {
    const deviceId = z.string().uuid().parse(req.params.deviceId);
    const result = await usersService.deleteDevice(requireUserId(req), deviceId);
    res.status(200).json(result);
  }
}

export const usersController = new UsersController();
