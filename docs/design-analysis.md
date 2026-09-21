# Moozhayil Design Analysis

**Audit date:** 21 September 2026  
**Auditor role:** Principal product designer + senior Flutter engineer + fintech UX auditor  
**Scope:** Flutter mobile (`apps/mobile/`) — light touch on admin/API where customer-facing  
**Method:** Code-only analysis — *no live visual verification on emulator in this pass* (APK built; install/session not fully observed)

---

## 1. Executive summary

Moozhayil’s mobile UI has a **coherent premium editorial direction** in code: burgundy `#6B1020`, ink `#14100D`, hallmark gold `#C49A3C`, Cormorant + Inter, flat corners, and a 51-file component library. It reads closer to a heritage jeweller than a crypto wallet.

**However, it is not shippable to App Store / Play Store as a premium gold app today.** The visual layer is ahead of the **trust layer**: price validity (BR-PRICE-005) is modeled but not enforced; KYC gates exist for enrollment but not for contributions or gold redemption; INR/gram formatting is inconsistent; product language drifts between Schemes / Goals / My Plans; and several scheme promises (Crest weight lock, Dhanam rate protection) are marketing copy without matching payment UX at enrollment.

The codebase also **intentionally diverged** from `docs/02-design-system.md` (obsidian/antiqueGold/DM Sans/rounded cards) toward a flat burgundy editorial system — docs are stale and will mislead future contributors.

**Verdict:** Strong design foundation (~7/10 visual intent), weak financial-trust execution (~4/10). Fix trust/compliance UX before store launch; polish visuals after.

---

## 2. Scorecard

| Dimension | Score | One-line reason |
|-----------|------:|-----------------|
| 1. Premium brand feel | **7/10** | Burgundy/gold/ivory tokens are disciplined (`colors.dart:11–62`); undermined by glass tab bar, gold shimmer, and philosophy-breaking elastic/flying animations |
| 2. Design system consistency | **6/10** | Strong token files but dual motion systems, 13+ stray `Color(0x…)`, docs/code drift, 38 files with ad-hoc `fontSize` |
| 3. Information architecture | **5/10** | Schemes vs Goals vs My Plans naming split; Dream Vault only in drawer/top bar; Aura tab competes with Schemes for savings intent |
| 4. Core flows (friction) | **5/10** | Shop path works; scheme enrollment ≠ first payment; contribute lacks KYC/rate preview; checkout lacks price refresh |
| 5. Trust & transparency | **4/10** | No 15-min price enforcement; contradictory KYC copy; grams shown to 2 decimals; no rate timestamp on home/My Gold |
| 6. Data visualization | **6/10** | My Gold hero + ledger solid; live rate strip good; `GoldRateTicker` built but unused; scheme progress lacks calendar/maturity UX |
| 7. Microcopy & tone | **7/10** | Heritage voice in `golden_wish_plan.dart`; ruined by `kycUnlockSchemes` contradiction; no Indian grouping on scheme amounts |
| 8. Accessibility | **5/10** | Gold-on-paper contrast mostly OK; tab labels small (11px uppercase); no l10n; semantics UNVERIFIED on icon-only actions |
| 9. Perceived performance | **6/10** | Shimmer widely used; first Android build ~25 min; Render cold-start latency unhandled; heavy animation library |
| 10. Conversion & retention | **5/10** | KYC gate on enroll good; post-enroll payment step easy to miss; empty states exist but weak re-engagement for missed installments |
| 11. Competitive gap (UNVERIFIED) | **5/10** | Likely behind Tanishq/Malabar on branch pickup, scheme comparison tables, rate alerts, family accounts |
| 12. Admin ↔ mobile consistency | **6/10** | CMS banners + API-driven catalog; scheme copy is client-static (`golden_wish_plan.dart`) — CRM changes won’t update plan pages |

---

## 3. Top 10 critical issues

### 1. Price validity not enforced (BR-PRICE-005)

- **Severity:** P0  
- **What's wrong:** `price_valid_until` exists on `ProductPrice` and `CartSummary` but PDP, add-to-cart, and checkout never check expiry or force refresh.  
- **Why it matters:** Customer can checkout at a stale gold rate — legal and trust risk for jewellery pricing.  
- **Evidence:** `core/models/product.dart:39`; `cart_screen.dart:250–253` (display only); `checkout_screen.dart` (no expiry logic); grep shows no client timer/stale handler  
- **Fix:** Add `PriceValidityGuard` service: block checkout when `DateTime.now() > priceValidUntil`, show `PriceBreakdownSheet` with refreshed rate + explicit user confirm before Razorpay.

### 2. KYC not gated on scheme contributions

- **Severity:** P0  
- **What's wrong:** `KycGateReason.contribution` exists in `kyc_gate_bottom_sheet.dart:12–28` but `contribute_screen.dart` never calls it.  
- **Why it matters:** Real money installments without verified identity violates stated BR-KYC-001 intent.  
- **Evidence:** `profile/widgets/kyc_gate_bottom_sheet.dart:12–28`; `goals/screens/contribute_screen.dart:28–49` (no KYC import/check)  
- **Fix:** Before Razorpay on contribute, call `showKycGateBottomSheet(reason: KycGateReason.contribution)` if `user.kycStatus != verified`.

### 3. Gold redemption checkout without KYC

- **Severity:** P0  
- **What's wrong:** `CheckoutScreen(redeemWithGold: true)` and `RedeemScreen` only check auth, not KYC.  
- **Why it matters:** Using accumulated gold toward jewellery is a regulated high-trust action.  
- **Evidence:** `checkout_screen.dart:27–30`; `my_gold/screens/my_gold_screen.dart` redeem path (auth-only — UNVERIFIED full line in redeem flow)  
- **Fix:** Mirror enrollment gate on redeem CTA; block checkout with clear “Complete verification to use My Gold” panel.

### 4. Contradictory KYC copy erodes trust

- **Severity:** P0  
- **What's wrong:** Profile shows “Optional — required to join Schemes” — logically impossible.  
- **Why it matters:** Users preparing to deposit ₹500–₹2L/month need unambiguous compliance messaging.  
- **Evidence:** `customer_copy.dart:51`; `profile_screen.dart:338`  
- **Fix:** Replace with: `Required to enroll in Schemes and pay installments. Shop browsing does not require KYC.`

### 5. Enrollment confirmation ≠ first payment (Crest/Dhanam promise gap)

- **Severity:** P1  
- **What's wrong:** Plan copy promises “weight locked at enrollment” (`golden_wish_plan.dart:63–71`) but wizard ends at confirmation without collecting payment; user must discover Contribute separately.  
- **Why it matters:** Marketing promise ≠ UX reality — support tickets and chargeback risk.  
- **Evidence:** `golden_wish_plan.dart:63–71`; `payment_setup_screen.dart:38–39` (explicit separation); `confirmation_screen.dart` navigates to My Plans not Contribute  
- **Fix:** For Crest/Dhanam, route confirmation → `/goals/:id/contribute?firstPayment=1` with locked amount; show step indicator “Step 2 of 2: Secure your booking”.

### 6. INR formatting inconsistent (BR-PRICE-004 partial)

- **Severity:** P1  
- **What's wrong:** Checkout has Indian grouping (`checkout_screen.dart:36–51`); contribute/goal screens use `₹$rupees` without lakhs grouping.  
- **Why it matters:** ₹50000 vs ₹50,000 reads as amateur for luxury fintech; older users misread amounts.  
- **Evidence:** `checkout_screen.dart:36–51`; `contribute_screen.dart:173`; `goal_detail_screen.dart:212`; no shared `formatInr()` utility  
- **Fix:** Add `core/utils/indian_format.dart` with `formatInrPaise()` / `formatGrams()`; replace all manual `₹` strings.

### 7. Grams displayed to 2 decimals (spec: 1 decimal, floor)

- **Severity:** P1  
- **What's wrong:** My Gold hero uses `toStringAsFixed(2)` instead of API `totalGramsDisplay`.  
- **Why it matters:** Overstates holdings; conflicts with BR-BALANCE-003 / BR-PRICE-004.  
- **Evidence:** `my_gold/widgets/my_gold_hero.dart:55–58`  
- **Fix:** Use `balance.totalGramsDisplay` from API; never client-format grams except via shared formatter.

### 8. No gold-rate timestamp shown to customer

- **Severity:** P1  
- **What's wrong:** Home and My Gold show rate without `rate_updated_at`; cached rate shown offline with no staleness warning.  
- **Why it matters:** “Today’s rate” must be provably today for scheme credibility.  
- **Evidence:** `home/widgets/live_gold_rate_strip.dart:69–71`; `my_gold_hero.dart:93–99`; `gold_balance` model has `rateUpdatedAt` UNVERIFIED on hero  
- **Fix:** Append “as of {time} IST” under rate; amber banner when cache age > 15 min.

### 9. Spec drift: Goals tab vs Schemes tab + dead `GoalsScreen`

- **Severity:** P1  
- **What's wrong:** Product spec says Goals tab; app shows Schemes; `/goals` redirects; `goals_screen.dart` unrouted duplicate of My Plans.  
- **Why it matters:** Engineering and support will use wrong terms; users see “My Plans” in one place and “Schemes” in another.  
- **Evidence:** `bottom_tab_bar.dart:39`; `app_router.dart` `/goals` redirect; `goals/screens/goals_screen.dart` (unregistered)  
- **Fix:** Pick one vocabulary (recommend **Schemes** tab + **My Plans** list); delete or wire `GoalsScreen`; update `docs/01-product-spec.md`.

### 10. Aura AI lacks financial disclaimer

- **Severity:** P2  
- **What's wrong:** Free-form chat for gold/scheme advice with no visible “not financial advice” / AI limitation copy.  
- **Why it matters:** Hallucinated scheme terms or rate predictions create regulatory and brand risk.  
- **Evidence:** `aura/screens/aura_conversation_screen.dart` (no disclaimer grep); BR-AURA-003 rate limit UI UNVERIFIED  
- **Fix:** Persistent footer on Aura screens: “AI suggestions are informational. Confirm scheme terms with Moozhayil before paying.”

---

## 4. Screen-by-screen teardown

*Analysis inferred from code only — no live visual verification.*

### A. Home (`features/home/screens/home_screen.dart`)

**Purpose:** Editorial discovery hub — rate, hero, categories, featured jewellery, schemes promo, Aura card.

**Strengths:**
- Layered `SectionReveal` motion (`home_screen.dart:65–79`) — calm stagger
- Live gold rate strip at top (`home_screen.dart:67–71`)
- Fallback to sample catalog when API empty (`home_screen.dart:37–40`) — dev-friendly

**Weaknesses:**
- Rate shown without timestamp (`live_gold_rate_strip.dart`)
- Sample imagery may mask production CMS gaps
- Schemes + Aura both compete for “save gold” attention on one scroll

**States:** Loading via gold rate shimmer ✅; empty products fall back to samples ⚠️; error on gold rate shows unavailable ✅; offline banner global ✅

---

### B. Golden Wish hub / Schemes tab (`features/golden_wish/screens/golden_wish_screen.dart`)

**Purpose:** Scheme catalogue (Aura, Crest, Dhanam, Swarna Nidhi) + inline My Plans.

**Strengths:**
- Plan copy is plain-language and legally cautious on Aura missed installments (`golden_wish_plan.dart:49–54`)
- KYC gate before enrollment (`golden_wish_screen.dart:231–233`)
- Live rate strip repeated for scheme context

**Weaknesses:**
- All plan marketing is **hardcoded** — admin cannot edit without app release
- Inline My Plans duplicates `/my-plans` route
- Swarna Nidhi slug `gold-nidhi` vs title “Swarna Nidhi” — minor naming friction

**States:** Plans static ✅; enrollment loading UNVERIFIED; KYC blocked ✅; empty My Plans uses `CustomerCopy` ✅

---

### C. Plan Detail (`features/golden_wish/screens/plan_detail_screen.dart`)

**Purpose:** Long-form scheme story + enroll CTA.

**Strengths:**
- Bottom nav hidden — focused reading (`app_router.dart` chrome rules)
- KYC gate on enroll (`plan_detail_screen.dart:279–281`)
- Highlights list from `golden_wish_plan.dart`

**Weaknesses:**
- No side-by-side scheme comparison (user must back-nav to compare Crest vs Dhanam)
- No link to full T&Cs PDF/hosted page
- “Enroll” starts goal wizard, not payment — mismatch for Crest “weight locked” copy

---

### D. Goal enrollment — Amount step (`features/goals/screens/amount_screen.dart`)

**Purpose:** Set monthly/installment amount + show plan terms.

**Strengths:**
- Aura missed-installment + MC waiver copy present (`amount_screen.dart:94–100` per agent audit)
- Slider UX for amount selection

**Weaknesses:**
- Min ₹500 in provider vs BR-GOAL-001 ₹1,000 — UNVERIFIED exact line in `goal_create_provider.dart`
- Amounts not Indian-formatted
- No preview of grams credited at today’s rate

---

### E. Contribute (`features/goals/screens/contribute_screen.dart`)

**Purpose:** Pay installment via Razorpay.

**Strengths:**
- `LuxurySuccessOverlay` on success
- Razorpay integration wired
- Slider ₹1,000–₹50,000 (`contribute_screen.dart:38`)

**Weaknesses:**
- **No KYC gate** (P0)
- No “You will receive ~X.XX g at ₹Y/g” preview
- Generic payment error only (`CustomerCopy.paymentError`)
- Default `_amountPaise = 300000` (₹3,000) — may not match plan minimum

---

### F. Checkout (`features/orders/screens/checkout_screen.dart`)

**Purpose:** Address + payment + optional My Gold balance apply.

**Strengths:**
- Indian `_formatPaise` for totals (`checkout_screen.dart:36–51`)
- Gold balance application logic
- `AuraMcWaiverBanner` for scheme-related checkout context
- Empty/signed-out/error states handled

**Weaknesses:**
- **No price validity check** (P0)
- No KYC for orders > ₹50k or gold redemption (P0)
- Address loading uses spinner not shimmer (inconsistent)
- COD ₹25k limit not enforced — UNVERIFIED BR-ORDER-004

---

### G. My Gold (`features/my_gold/screens/my_gold_screen.dart`)

**Purpose:** Portfolio hero + ledger + redeemable products.

**Strengths:**
- Ink hero with gold shimmer balance — premium (`my_gold_hero.dart:32–64`)
- Ledger list + redeem flow exists
- Loading shimmer + retry on error

**Weaknesses:**
- **2 decimal grams** in hero (`my_gold_hero.dart:58`)
- No sell/withdraw (correct per scope) but redemption path lacks KYC
- Rate shown uppercase without timestamp (`my_gold_hero.dart:94`)
- Redeemable products error silently hidden — trust gap

---

### H. KYC landing (`features/profile/screens/kyc_landing_screen.dart`)

**Purpose:** Entry to Aadhaar → PAN → selfie → review pipeline.

**Strengths:**
- Handles verified / in_review / rejected / start states
- Pending screen SLA copy (~30 min)
- Onboarding allows skip to home (`kyc_intro_screen.dart:43–46`) for browse-only

**Weaknesses:**
- `KycGateBottomSheet` names “Gold Nidhi” vs product “Swarna Nidhi”
- No explainer on data encryption / who sees documents (trust for Aadhaar)
- Step progress not shared component — user may not know how many steps remain

---

## 5. Quick wins vs structural fixes

### Quick wins (< 1 day each)

1. Fix `CustomerCopy.kycUnlockSchemes` text (`customer_copy.dart:51`)
2. Wire KYC gate on `contribute_screen.dart` before payment
3. Wire KYC gate on gold redeem checkout path
4. Switch `my_gold_hero.dart:58` to `balance.totalGramsDisplay`
5. Add “Rate as of {time}” to `live_gold_rate_strip.dart` and My Gold hero
6. Delete or register orphaned `goals_screen.dart`
7. Add Aura disclaimer footer on conversation screen
8. Tokenize editorial scrim colors (`editorial_hero.dart:63`, `editorial_promo_band.dart:37`)
9. Map Razorpay errors through `customer_error_copy.dart`
10. Drawer “Help & Contact” duplicates Store Locator — add phone/email CTA distinct from map

### Structural fixes (multi-day)

1. **Price validity system** — client guard + checkout refresh API + blocking UI (2–3 days)
2. **Shared `formatInr()` / `formatGrams()`** — replace 20+ ad-hoc format sites (1–2 days)
3. **Enrollment → first payment unified flow** for Crest/Dhanam (2–3 days)
4. **Reconcile design docs** — rewrite `02-design-system.md` to match burgundy editorial code (1 day)
5. **Consolidate `AppMotion` + `AppAnimations`** (1 day)
6. **i18n foundation** — Malayalam for Kerala launch (1–2 weeks)
7. **CMS-driven scheme copy** — move `golden_wish_plan.dart` content to API/admin (3–5 days)
8. **IA refactor** — merge Aura savings features under Schemes or rename tab (2–3 days)
9. **Accessibility pass** — semantics, 48dp targets, dynamic type (3–5 days)
10. **Animation audit vs philosophy** — remove elastic, flying cart, reduce glass (2 days)

---

## 6. Proposed design tokens (docs + code reconciled)

Use **`AppColors` names as source of truth.** Deprecate doc-only tokens unless aliased in code.

### Color

| Token | Hex | Usage | WCAG notes |
|-------|-----|-------|------------|
| `paper` | `#FEFCF9` | Primary surface | Background |
| `pearl` | `#F8F5F0` | Secondary surface | Background |
| `ink` | `#14100D` | Hero bands, primary button fill | Pair with `cream` text — **~12.8:1** ✅ |
| `brandBurgundy` | `#6B1020` | Primary CTA | Pair with `cream` — **~9.5:1** ✅ |
| `gold` | `#C49A3C` | Accents, labels on dark | On `paper`: **~2.4:1** ⚠️ large text only; never body copy on cream |
| `goldLight` | `#DDB96A` | Rate labels on ink | On `ink`: **~8:1** ✅ |
| `textPrimary` | `#14100D` | Body on paper | **~16:1** ✅ |
| `textSecondary` | `#635C54` | Supporting copy | **~5.8:1** ✅ |
| `textMuted` | `#9A9189` | Captions | **~3.2:1** ⚠️ micro labels only |
| `successFill` | (see `colors.dart`) | Paid / verified | Do not rely on color alone — add icon |
| `errorFill` | (see `colors.dart`) | Failed payment | Same |

**Deprecate in docs:** `obsidian`, `champagneVeil`, `vaultDusk` as primary — keep as aliases only (`colors.dart` legacy section).

**Add (proposed):**
- `scrimOverlay = Color(0x7314100D)` — replace 6 inline scrims
- `rateStale = warningFill` — banner when rate > 15 min old

### Typography

| Role | Font | Size / weight | Use |
|------|------|---------------|-----|
| Display | Cormorant Garamond | 32–40 / w400 | My Gold grams, hero headlines |
| Heading | Cormorant Garamond | 22–28 / w500 | Plan detail headlines |
| Screen title | Cormorant | 20 / w500 | Top bar titles |
| Body | Inter | 14 / w400 | Descriptions, T&Cs |
| UI label | Inter | 11–12 / w500 uppercase | Tab bar, micro labels |
| Price LG | Inter | 18 / w600 **tabular figures** | Checkout totals |
| Price MD | Inter | 14 / w600 tabular | Product cards |

**Action:** Add `AppTypography.priceTabular` with `fontFeatures: [FontFeature.tabularFigures()]`.

### Spacing (keep existing scale)

`xxs:4` → `x3l:64`; `screenPadding:16`; `homeScreenPadding:20`; `tabBarHeight:64`.

### Radius (editorial flat — codify intent)

| Token | Value | Use |
|-------|------:|-----|
| `card`, `button`, `input` | 0 | Default editorial |
| `thumbnail` | 2 | PDP gallery thumbs |
| `showcaseCard` | 20 | Home carousel only |
| `avatar`, `full` | 999 | Avatars, pills |

Update `02-design-system.md` to match `radii.dart:4–27` — not 8–20px rounded cards.

### Motion

**Single system — propose `AppMotion` only:**

| Token | ms | Use |
|-------|---:|-----|
| `instant` | 120 | Press feedback |
| `fast` | 180 | Tab switch |
| `normal` | 220 | Section reveal |
| `slow` | 320 | Sheet open |
| `hero` | 480 | Payment success |

**Remove:** `Curves.elasticIn/Out` from production paths (`animations.dart`, `gold_rate_ticker.dart:226`).

---

## 7. Component library gaps

**Present and healthy:** `PrimaryButton`, `ProductCard`, `EmptyState`, `ErrorState`, `LoadingShimmer`, `OfflineBanner`, `NavigationShell`, editorial suite, `PriceBreakdownSheet`, `OtpDotField`.

**Missing vs screens that hand-roll:**

| Missing component | Hand-rolled in | Priority |
|-------------------|----------------|----------|
| `SchemeStatusBadge` (on track / missed / matured) | `goal_detail_screen.dart` | P1 |
| `GoldRateLabel` (rate + timestamp + stale state) | home, schemes, my gold | P0 |
| `PriceValidityBanner` | cart, PDP, checkout | P0 |
| `KycStatusCard` | profile, kyc landing | P1 |
| `InstallmentPreviewRow` (₹ → grams) | contribute, amount | P0 |
| `SchemeComparisonTable` | plan detail | P2 |
| `MultiStepProgress` (KYC, enrollment) | kyc flow, goal wizard | P1 |
| `AppIconButton` (44×44) | top bar, vault | P2 |
| `FilterChip` / `SchemeChip` | shop (partial: `OccasionChip`) | P2 |
| `TrustFooter` (Razorpay + encryption) | checkout, contribute | P1 |

---

## 8. Prioritized roadmap

| Now (pre–App Store) | Next (v1.1) | Later |
|---------------------|-------------|-------|
| Price validity enforcement | CMS-driven scheme copy | Malayalam i18n |
| KYC on contribute + redeem | Scheme comparison UI | Family / joint accounts |
| Fix KYC + INR/gram formatting | Rate push alerts | Branch pickup scheduling |
| Enrollment → first payment UX | Missed installment re-engagement | Hallmark certificate viewer |
| Aura financial disclaimer | Goal duration picker (12/18/24/36) | Dark mode (if ever) |
| Reconcile design docs | Consolidate motion tokens | Advanced Aura (voice) |
| Real device QA pass | Payment animation wiring | Competitive rate alerts |
| Store screenshots from production API | Admin scheme content editor | |

---

## 9. Open questions for product owner

1. **Swarna Nidhi:** Is `gold_nidhi` enrollment live on API or UI-only? All four plans show `enrollmentAvailable: true` (`golden_wish_plan.dart:56–109`).
2. **Malayalam at launch:** Required for App Store Kerala audience, or English-only v1?
3. **My Gold redemption:** In-store only, or ship-to-home with gold balance applied?
4. **Crest/Dhanam:** Must first payment happen at enrollment, or is post-enroll Contribute acceptable legally?
5. **Aura tab:** Keep as 5th tab, or fold into Schemes as “Get advice”?
6. **Price lock:** Is 15-minute window legally binding copy, or internal ops rule?
7. **Enhanced KYC ₹2L limit:** Should UI expose path to raise contribute cap above ₹50k?
8. **Render free tier:** Cold-start latency — show branded splash “Connecting to Moozhayil”?

---

## 10. Spec drift register

| Topic | Spec (`docs/`) | Code (Flutter) | Resolution |
|-------|----------------|----------------|------------|
| Bottom tabs | Home \| Shop \| **Goals** \| Aura \| Profile (`01-product-spec.md`) | Home \| Shop \| **Schemes** \| AI Advisor \| Profile (`bottom_tab_bar.dart:36–47`) | Update spec to Schemes |
| Primary palette | obsidian + antiqueGold (`02-design-system.md`) | ink + gold `#C49A3C` + burgundy (`colors.dart:31–53`) | Rewrite design doc |
| UI font | DM Sans | Inter (`typography.dart`) | Update doc |
| Border radius | 8–20px cards | Flat 0 editorial (`radii.dart:7–19`) | Update doc — intentional |
| Icons | Custom SVG set | Lucide (`app_icons.dart`) | Update doc |
| `/goals` route | Goals hub | Redirects to `/golden-wish` (`app_router.dart`) | Remove dead `GoalsScreen` |
| GoalsScreen | Active tab screen | Unregistered (`goals_screen.dart`) | Delete or wire |
| Price lock 15 min | BR-PRICE-005 enforced | Display-only on cart | Implement guard |
| Gram decimals | 1 decimal floor | 2 decimals on hero (`my_gold_hero.dart:58`) | Use API display field |
| KYC for schemes | Required | Required enroll, **not** contribute | Align code to spec |
| Sell gold flow | N/A | Not implemented | Correct — no drift |
| Dream Vault tab | Spec varies | Drawer + top bar only | Consider tab badge or home entry |
| Payment animations | Specified in component library | Built but unused in checkout/contribute | Wire or remove |
| Help & Contact | Distinct support | Same route as store locator (`navigation_drawer.dart`) | Add contact screen |

---

## Appendix A: Screen & route inventory

| Screen | Route | Purpose | File path | Entry points |
|--------|-------|---------|-----------|--------------|
| Splash / Onboarding | `/onboarding` | Brand entry | `features/onboarding/screens/splash_screen.dart` | Cold start |
| Onboarding carousel | `/onboarding/carousel` | Story slides | `onboarding_carousel_screen.dart` | Splash CTA |
| Intent | `/onboarding/intent` | User intent | `intent_screen.dart` | Post-OTP new user |
| Name | `/onboarding/name` | Collect name | `name_screen.dart` | Intent |
| KYC intro | `/onboarding/kyc-intro` | KYC opt-in | `kyc_intro_screen.dart` | Name |
| Auth | `/auth` | Phone entry | `features/auth/screens/auth_screen.dart` | Redirect if signed out |
| OTP | `/auth/otp` | Verify OTP | `otp_screen.dart` | Auth |
| **Home** | `/home` | Discovery hub | `features/home/screens/home_screen.dart` | Tab 0, drawer |
| Shop | `/shop` | Catalogue hub | `features/shop/screens/shop_screen.dart` | Tab 1, drawer |
| Shop search | `/shop/search` | Search | `search_screen.dart` | Shop, home |
| Product list | `/shop/category/:id` | Category grid | `product_list_screen.dart` | UNVERIFIED in-app links |
| Collection / Occasion | `/shop/collection/:id`, `/shop/occasion/:id` | Curated lists | `collection_screen.dart` | Shop, home |
| Product detail | `/shop/product/:id` | PDP | `product_detail_screen.dart` | Cards everywhere |
| New arrivals | `/new` | Featured new | `new_arrivals_screen.dart` | Home |
| **Golden Wish / Schemes** | `/golden-wish` | Scheme catalogue | `features/golden_wish/screens/golden_wish_screen.dart` | Tab 2, drawer, home banner |
| Plan detail | `/golden-wish/plans/:slug` | Scheme story | `plan_detail_screen.dart` | Plan cards |
| My Plans | `/my-plans` | Active schemes | `my_plans_screen.dart` | Profile, drawer, schemes tab |
| Goal detail | `/goals/:goalId` | Plan progress | `features/goals/screens/goal_detail_screen.dart` | My Plans |
| Contribute | `/goals/:goalId/contribute` | Pay installment | `contribute_screen.dart` | Goal detail |
| Goal wizard | `/goals/create/*` | Enroll | `moment/piece/amount/payment/confirmation_screen.dart` | Plan detail, vault |
| **Aura** | `/aura` | AI hub | `features/aura/screens/aura_screen.dart` | Tab 3, drawer, home |
| Aura conversation | `/aura/conversation/:id` | Chat | `aura_conversation_screen.dart` | Aura hub |
| Aura goal planning | `/aura/goal-planning` | Structured flow | `aura_goal_planning_screen.dart` | Aura hub |
| Aura product discovery | `/aura/product-discovery` | Structured flow | `aura_product_discovery_screen.dart` | Aura hub |
| Aura gold insights | `/aura/gold-insights` | Rate + balance | `aura_gold_insights_screen.dart` | Aura hub |
| **Profile** | `/profile` | Account hub | `features/profile/screens/profile_screen.dart` | Tab 4, drawer |
| KYC pipeline | `/profile/kyc/*` | Verification | `kyc_landing/aadhaar/pan/selfie/review/pending_screen.dart` | Profile, gates |
| Addresses | `/profile/addresses` | Shipping | `addresses_screen.dart` | Profile, checkout |
| Payment methods | `/profile/payment-methods` | Saved methods | `orders/screens/payment_methods_screen.dart` | Profile |
| Dream Vault | `/dream-vault` | Wishlist | `features/vault/screens/dream_vault_screen.dart` | Top bar, drawer, profile |
| **My Gold** | `/my-gold` | Ledger | `features/my_gold/screens/my_gold_screen.dart` | Drawer, profile |
| My Gold redeem | `/my-gold/redeem` | Redeem picker | same file (`RedeemScreen`) | My Gold CTA |
| Cart | `/cart` | Bag | `features/cart/screens/cart_screen.dart` | Top bar |
| **Checkout** | `/checkout` | Pay | `features/orders/screens/checkout_screen.dart` | Cart, redeem |
| Orders | `/orders` | History | `orders_screen.dart` | Profile, drawer |
| Order detail | `/orders/:id` | Tracking | `order_detail_screen.dart` | Orders list |
| Order confirmation | `/orders/confirmation/:id` | Success | `order_confirmation_screen.dart` | Checkout |
| Notifications | `/notifications` | Inbox | `features/notifications/screens/notifications_screen.dart` | Profile |
| Store locator | `/store-locator` | Branches | `features/store/screens/store_locator_screen.dart` | Drawer, profile help |
| Referrals | `/referrals` | Refer program | `features/referrals/screens/referrals_screen.dart` | Profile |
| Dev gallery | `/dev/screens` | Debug only | `features/dev/screens/dev_screen_gallery.dart` | Debug drawer only — **gated** (`dev_preview.dart`) |

**Redirects:** `/wishlist` → `/dream-vault`; `/goals` → `/golden-wish`; `/goals/create` → `/goals/create/moment`.

**Orphan:** `features/goals/screens/goals_screen.dart` — not registered.

---

## Appendix B: State coverage matrix (summary)

| Screen | Loading | Empty | Error | Offline | Stale rate | Payment states | KYC gate |
|--------|---------|-------|-------|---------|------------|----------------|----------|
| Home | ✅ shimmer | ⚠️ samples | ⚠️ partial | ✅ banner | ❌ | — | — |
| Schemes | ✅ | ✅ | ⚠️ | ✅ | ❌ | — | ✅ enroll |
| Plan detail | ✅ | — | — | ✅ | — | — | ✅ enroll |
| Contribute | ⚠️ | — | ⚠️ generic | ✅ | ❌ | ✅ partial | ❌ |
| Checkout | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ redeem |
| My Gold | ✅ | ✅ | ✅ | ✅ | ❌ | — | ❌ redeem |
| KYC | ✅ | — | ✅ | ✅ | — | — | — |
| Shop PDP | ✅ | — | ✅ | ✅ | ❌ | — | — |
| Cart | ✅ | ✅ | ✅ | ✅ | ⚠️ display only | — | — |
| Aura | ✅ | — | ⚠️ | ✅ | — | — | ⚠️ auth only |

---

## Appendix C: Design system extraction (implemented)

**Colors:** `apps/mobile/lib/core/constants/colors.dart` — paper/pearl/ivory surfaces; ink/burgundy darks; gold `#C49A3C`; legacy aliases for old doc names.

**Typography:** Cormorant Garamond (display) + Inter (UI) in `typography.dart` — smaller/restrained vs doc (11px uppercase buttons).

**Spacing:** `spacing.dart` — 4–64 scale; shell chrome heights defined.

**Motion:** Dual `motion.dart` + `animations.dart` — **needs consolidation**.

**Radii:** Flat editorial `radii.dart:4–27` — contradicts rounded doc spec.

**Icons:** Lucide via `components/icons/app_icons.dart`.

**Hardcoded colors:** ~13 outside token files (scrims in `editorial_hero.dart:63`, `editorial_promo_band.dart:37`, etc.).

**i18n:** **None** — no `.arb`, no `flutter_localizations`; English in `customer_copy.dart` + inline strings.

---

## Top 5 fixes to implement first (awaiting approval)

1. **Price validity guard** on cart → checkout → Razorpay (BR-PRICE-005)
2. **KYC gate on contribute + gold redemption checkout**
3. **Fix KYC copy** + add rate timestamp/stale banner on gold rate displays
4. **Shared `formatInr()` / use `totalGramsDisplay`** — remove formatting drift
5. **Enrollment → first payment handoff** for Crest/Dhanam with explicit step UI

**No code has been modified in this audit.** Awaiting approval before implementation.

---

## Fix log

### Fix 4: Shared INR and gram formatting — **done (closed)**

| Item | Detail |
|------|--------|
| **Status** | Done |
| **Commit** | `033c29a` + closure amend |
| **Files changed** | `indian_format.dart`, `typography.dart`, checkout/schemes/my-gold formatters, providers, animations; closure: `docs/test-baseline.txt`, `api_money_format_parity_test.dart`, expanded `indian_format_test.dart` |
| **Tests added** | 34 core tests pass; full suite **72 pass / 14 fail** — identical 14 failures vs parent of `033c29a` (see `docs/test-baseline.txt`). Gate: no new failures + analyze 0 errors |
| **Backend gaps** | None for formatting — verified `apps/api/src/utils/money.ts` uses `Intl.NumberFormat("en-IN")`; client `formatInrPaise` matches at ₹97,899, ₹1,23,456, ₹1,23,45,678 |
| **Closure notes** | `formatGramsDouble` now string-truncates (no `floor(x*10^n)`). `toStringAsFixed` absent from `lib/` for money/grams. `grams_counter_animation.dart` analyze errors were **pre-existing on parent** (fixed collaterally). Rs 1,23,45,678 = `1234567800` paise (crore grouping level) |
| **Follow-ups** | Static marketing ₹ strings unchanged. API display fields still rendered as returned on cart/PDP |

### Fix 3: KYC copy + GoldRateLabel — **done**

| Item | Detail |
|------|--------|
| **Status** | Done |
| **Files changed** | `customer_copy.dart`, `kyc_gate_bottom_sheet.dart`, `kyc_intro_screen.dart`, `gold_rate_label.dart`, `live_gold_rate_strip.dart`, `my_gold_hero.dart`, `home_screen.dart`, `golden_wish_screen.dart`, `my_gold_screen.dart`, `server_clock.dart`, `server_clock_provider.dart`, `ist_format.dart`, `gold_rate_freshness.dart`, `api_service.dart` (Date header sync) |
| **Tests added** | `gold_rate_label_test.dart`, `gold_rate_freshness_test.dart`, `server_clock_test.dart`, `ist_format_test.dart` |
| **Backend gaps** | No dedicated `server_time` JSON field — offset derived from HTTP `Date` header only; `usesDeviceTimeFallback` until first response. `rate_updated_at` present on gold balance (`updated_at`) and product price; PDP/cart use product payload |
| **Other rate surfaces (not wired)** | `shop_masthead.dart` `_RateChip`, `aura_gold_insights_screen.dart` — still plain `rateDisplay` text |
| **Follow-ups** | Schemes `RefreshIndicator` invalidates goals but not gold balance on pull (pre-existing) |

---

*End of design analysis.*
