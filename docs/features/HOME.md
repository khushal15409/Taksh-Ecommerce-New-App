# Feature: Home & Main Shell

**Path:** `lib/features/home/`  
**Related:** product, categories, quick_delivery, home_service

---

## Purpose

Primary shopping surface after splash. Hosts:

- Standard ecommerce **dashboard**
- **Express 30-min** dashboard (fulfillment-center aware)
- Delivery type switcher including **services** (embeds home_service UI)
- **MainShell** bottom navigation

---

## Layers

```
domain/   Dashboard + express dashboard entities
data/     remote datasources, repos (mock express repo in mock mode)
presentation/
  pages/  home_page.dart, main_shell.dart, view_all_products_page.dart
  bloc/   DashboardBloc, ExpressDashboardBloc
  cubit/  RecentViewsCubit
  widgets/ …
```

---

## Delivery types

Query key: `delivery` (`AppRoutes.deliveryTypeQueryKey`)

| Value | Behavior |
|-------|----------|
| `standard` | Normal dashboard / catalog |
| `quick` | Express 30-min dashboard & product paths |
| `services` | Home services content (`HomeServiceContent`) |

Navigate: `context.go(AppRoutes.homeWithDelivery('quick'));`

---

## API

| Endpoint | Use |
|----------|-----|
| `GET /dashboard` | Standard home sections/banners/products |
| `GET /express-30/dashboard` | Express home |

Mock: express dashboard repository can be swapped when `useMockData`.

---

## State management

| Class | Role |
|-------|------|
| `DashboardBloc` | Load/refresh standard dashboard |
| `ExpressDashboardBloc` | Load/refresh express dashboard |
| `RecentViewsCubit` | Recently viewed products strip |

Shell on init typically warms **CartCubit** + **WishlistCubit**.

---

## MainShell tabs

1. Home  
2. Categories  
3. Cart  
4. Orders  
5. Profile  

See [ROUTING.md](../ROUTING.md).

---

## When updating

- Keep standard vs express data paths separate (different endpoints and blocs).  
- New home section types → extend entities/models + UI section widgets; run codegen.  
- Services tab should stay a thin embed of `home_service` to avoid duplicating booking logic.  
- Update l10n for any new section titles.

## Banner types

Banners carry a `type` (`standard` | `quick` | `service`) set in the admin panel. Standard home uses the `Banners` section of `/dashboard`, Quick uses `/express-30/dashboard`, Service uses `GET /ecommerce/banners?type=service` (`ServiceBannersSection`). One banner renders as a static card, several as an auto-playing slider (`BannerCarousel`); with none, the section is hidden.

## Banners: type and position (dynamic)
Banners come from the admin panel and are filtered by **type** on the server:
Standard tab → `GET /api/ecommerce/dashboard` (type `standard`), Quick tab → express
dashboard (type `quick`), Service tab → `GET /api/ecommerce/banners?type=service`.

**Position** (`position` field) decides where the banner shows on that tab, via
`banner_slots.dart` (`bannerSlotFor` / `groupBannersBySlot`):
`home_top` and `dashboard` → above all sections; `home_middle` → between the
product sections (service tab: after the first half of the services);
`home_bottom` → below all sections. Order inside a slot follows admin `sort_order`.
Empty slots render nothing. Admin form labels were updated to match.

### Update: static promo banners removed, "after section" for middle banners
- The static Diwali promo images (`ModePromoBanner`) on the Standard / Quick tabs were removed; every banner now comes from the admin panel.
- A **Middle** banner can choose the dashboard section it is shown below (admin: Banner → "Show after which section?"). The API sends `after_section_name`; the app matches it to the rendered section `key` and inserts the banner right after it. No section chosen, or that section is not shown → fallback to the middle of the sections. Service tab has no sections (middle = after the first half of the services).

## Dashboard sections: type + design (admin-configured)
Admin (App Home Sections) now sets, per section:
- **Show on dashboard** — `standard`, `quick` or `both` (old sections stay `both`). `/api/dashboard` returns standard+both, `/express-30/dashboard` quick+both.
- **Design** — none (normal horizontal row) or one of 5 templates: `premium`, `hot_deals`, `fresh_picks`, `spotlight`, `minimal`.
- **Rows × products per row** (rows 1–10, per row 1–4; default 2×2) — only for a design.

The API adds `id`, `design`, `rows`, `items_per_row` to each section. In the app `DashboardSectionModel` parses them and `DashboardContent` / `ExpressDashboardContent` render a section with `DesignedProductSection` when `design` is a known template, otherwise with the unchanged `ProductSection`. Unknown design keys fall back to the normal row. Banners/Logo/Categories are not affected.
