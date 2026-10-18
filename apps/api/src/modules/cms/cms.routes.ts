import { Router } from "express";
import { z } from "zod";
import { cmsService } from "./cms.service";

export const cmsRouter = Router();

cmsRouter.get("/banners", (req, res, next) => {
  const query = z
    .object({
      placement: z
        .enum([
          "home_hero",
          "home_featured",
          "announcement_bar",
          "campaign",
          "shop_top",
          "goals_top",
        ])
        .optional(),
    })
    .parse(req.query);

  void cmsService
    .banners({ placement: query.placement })
    .then((result) => res.json(result))
    .catch(next);
});
