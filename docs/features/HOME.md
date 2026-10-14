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
