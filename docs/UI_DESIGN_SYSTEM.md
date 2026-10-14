# UI design system & screen audit

Reference: the **Home Dashboard**. Its widgets use a compact scale — body and
metadata at 10–14sp, section headings at 16–18sp — so redesigned screens follow
that scale rather than the larger 22–26sp page titles a generic guideline would
suggest. Tokens: `lib/core/theme/app_text_scale.dart` (new),
`app_spacing.dart`, `app_colors.dart`, `app_tokens.dart`, `app_typography.dart`
(existing — Nunito, Material roles).

## Shared building blocks
| Piece | File |
|-------|------|
| Top-center toast (success/error/warning/info) | `core/widgets/app_toast.dart` |
| Festive header (cart/checkout style) | `core/widgets/festive_page_header.dart` |
| Dashed divider | `core/widgets/dashed_divider.dart` |
| Checkout section title/card helpers | `features/checkout/presentation/widgets/checkout_section_card.dart` |
| Font-size / control-size scale | `core/theme/app_text_scale.dart` |

## Screen audit (static, from code — not run on a device)
Redesigned to the new look (sizes calibrated from mock-ups, consistent with the
dashboard scale): Cart, Checkout (+ address, payment, price widgets), Order
Details, Product Details, OTP verification (digit boxes visible), Home header
logo, Home banners (Standard / Quick / Service), toasts everywhere.

Not yet reviewed / still using literal font sizes (candidates, in priority order):
1. Product listing, Search, Categories, `view_all_products_page`
2. Orders list, Order placed / review / select items, Payment success/failed
3. Notifications + detail, Address list / add address / map picker
4. Profile and sub-pages (wallet ×2, vendor/delivery-boy join, policies)
5. Home service pages, Quick delivery pages, Onboarding, Splash

Literal `fontSize:` usage is widespread (most common: 14, 16, 12, 13, 11, 15,
10, 18). Migrate to `AppTextScale` screen by screen; do not bulk-replace.

## Housekeeping found during the audit
- `lib/features/checkout/presentation/pages/checkout_page.dart.backup` and
  `lib/features/home/presentation/pages/home_page.dart.tmp` are stray files.
- Duplicate wallet pages exist under `profile/` and `wallet/`.
- `design_system_example.dart` is an example, not wired to the app.

## Rules for new UI work
- Pick sizes from `AppTextScale`; keep Android font scaling on.
- Primary button 45–50dp tall, compact 36dp, minimum touch target ~40dp.
- Cards: white, radius 12–14, soft shadow; side margin 14dp.
- Use `AppToast` for all user messages.
- Never change callbacks/blocs while restyling; verify with `flutter analyze`.
