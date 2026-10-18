/** Placements stored in DB; app currently renders home_hero in the hero carousel. */
export const BANNER_PLACEMENTS = [
  {
    value: "home_hero",
    label: "Home hero (carousel)",
    hint: "Shown on app home. Use 9:16 or wide hero art (~1080×1920 or 16:9).",
  },
  {
    value: "shop_top",
    label: "Shop top",
    hint: "Reserved for shop tab promos (API ready; wire in app when needed).",
  },
  {
    value: "goals_top",
    label: "Schemes / Golden Wish top",
    hint: "Reserved for schemes tab (API ready).",
  },
  {
    value: "home_featured",
    label: "Home featured rail",
    hint: "Future editorial band below hero.",
  },
  {
    value: "announcement_bar",
    label: "Announcement bar",
    hint: "Short strip message (future).",
  },
  {
    value: "campaign",
    label: "Campaign",
    hint: "Generic campaign slot.",
  },
] as const;

/** In-app routes the mobile app understands (see cms_navigation.dart). */
export const CTA_APP_ROUTES = [
  { value: "", label: "Default (Shop tab)" },
  { value: "/shop", label: "Shop catalogue" },
  { value: "/new", label: "New arrivals" },
  { value: "/golden-wish", label: "Golden Wish / schemes" },
  { value: "/my-gold", label: "My Gold" },
  { value: "/dream-vault", label: "Dream vault / wishlist" },
  { value: "/aura", label: "Aura advisor" },
  { value: "/store-locator", label: "Store locator" },
  { value: "/profile/kyc", label: "Start KYC" },
  { value: "/cart", label: "Cart" },
] as const;

export type BannerPlacement = (typeof BANNER_PLACEMENTS)[number]["value"];

export function formatPlacement(placement: string): string {
  return (
    BANNER_PLACEMENTS.find((item) => item.value === placement)?.label ?? placement
  );
}

export interface AdminBanner {
  id: string;
  title: string;
  image_url: string;
  cta_label: string | null;
  cta_route: string | null;
  placement: string;
  sort_order: number;
  valid_from: string | null;
  valid_to: string | null;
  is_active: boolean;
}

export interface BannerFormValues {
  title: string;
  image_url: string;
  cta_label: string;
  cta_route: string;
  placement: string;
  sort_order: string;
  valid_from: string;
  valid_to: string;
  is_active: boolean;
}

export function emptyBannerForm(): BannerFormValues {
  return {
    title: "",
    image_url: "",
    cta_label: "",
    cta_route: "",
    placement: "home_hero",
    sort_order: "0",
    valid_from: "",
    valid_to: "",
    is_active: true,
  };
}

export function bannerToFormValues(banner: AdminBanner): BannerFormValues {
  return {
    title: banner.title,
    image_url: banner.image_url,
    cta_label: banner.cta_label ?? "",
    cta_route: banner.cta_route ?? "",
    placement: banner.placement,
    sort_order: String(banner.sort_order),
    valid_from: isoToDatetimeLocal(banner.valid_from),
    valid_to: isoToDatetimeLocal(banner.valid_to),
    is_active: banner.is_active,
  };
}

export function formValuesToPayload(values: BannerFormValues, editing: boolean) {
  const sortOrder = Number.parseInt(values.sort_order, 10);

  const payload: Record<string, unknown> = {
    title: values.title.trim(),
    image_url: values.image_url.trim(),
    placement: values.placement,
    sort_order: Number.isNaN(sortOrder) ? 0 : sortOrder,
    is_active: values.is_active,
  };

  const ctaLabel = values.cta_label.trim();
  const ctaRoute = values.cta_route.trim();

  if (ctaLabel) {
    payload.cta_label = ctaLabel;
  } else if (editing) {
    payload.cta_label = "";
  }

  if (ctaRoute) {
    payload.cta_route = ctaRoute;
  } else if (editing) {
    payload.cta_route = "";
  }

  const validFrom = datetimeLocalToIso(values.valid_from);
  const validTo = datetimeLocalToIso(values.valid_to);

  if (validFrom) payload.valid_from = validFrom;
  if (validTo) payload.valid_to = validTo;

  return payload;
}

function isoToDatetimeLocal(value: string | null): string {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function datetimeLocalToIso(value: string): string | undefined {
  if (!value.trim()) return undefined;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return undefined;
  return date.toISOString();
}

export function formatBannerDate(value: string | null): string {
  if (!value) return "—";
  return new Date(value).toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
}
