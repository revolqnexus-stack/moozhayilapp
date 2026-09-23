import { Router } from "express";
import {
  accessibilityPageHtml,
  landingPageHtml,
  privacyPageHtml,
  termsPageHtml,
} from "./legal_pages";

export const legalRouter = Router();

legalRouter.get("/", (_req, res) => {
  res.type("html").send(landingPageHtml());
});

legalRouter.get("/privacy", (_req, res) => {
  res.type("html").send(privacyPageHtml());
});

legalRouter.get("/terms", (_req, res) => {
  res.type("html").send(termsPageHtml());
});

legalRouter.get("/accessibility", (_req, res) => {
  res.type("html").send(accessibilityPageHtml());
});
