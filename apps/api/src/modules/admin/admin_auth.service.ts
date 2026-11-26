import { prisma } from "../../db/prisma";
import { AppError } from "../../middleware/error.middleware";
import { hashPassword, verifyPassword } from "../../utils/password";
import {
  signAdminStepUpToken,
  signAdminToken,
} from "./admin.middleware";
import type { AdminLoginInput } from "./admin.schema";

export class AdminAuthService {
  async login(input: AdminLoginInput) {
    const admin = await prisma.adminUser.findUnique({
      where: { email: input.email.toLowerCase() },
    });

    if (!admin || admin.disabledAt || !admin.passwordHash) {
      throw new AppError(401, "UNAUTHORIZED", "Invalid admin credentials");
    }

    if (!verifyPassword(input.password, admin.passwordHash)) {
      throw new AppError(401, "UNAUTHORIZED", "Invalid admin credentials");
    }

    await prisma.adminUser.update({
      where: { id: admin.id },
      data: { lastLoginAt: new Date() },
    });

    return {
      access_token: signAdminToken(admin.id, admin.role),
      admin: {
        id: admin.id,
        email: admin.email,
        name: admin.name,
        role: admin.role,
      },
    };
  }

  async stepUp(adminId: string, password: string) {
    const admin = await prisma.adminUser.findUnique({
      where: { id: adminId },
    });

    if (!admin?.passwordHash || !verifyPassword(password, admin.passwordHash)) {
      throw new AppError(401, "UNAUTHORIZED", "Invalid admin credentials");
    }

    return {
      step_up_token: signAdminStepUpToken(adminId),
      expires_in_seconds: 300,
    };
  }

  async me(adminId: string) {
    const admin = await prisma.adminUser.findUnique({
      where: { id: adminId },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        lastLoginAt: true,
      },
    });

    if (!admin) {
      throw new AppError(404, "NOT_FOUND", "Admin user does not exist");
    }

    return { admin };
  }

  static hashPasswordForSeed(password: string): string {
    return hashPassword(password);
  }
}

export const adminAuthService = new AdminAuthService();
