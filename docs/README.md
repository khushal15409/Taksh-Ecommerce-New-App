# Taksh E-Commerce — Documentation Index

Start here. Docs are grouped so you can find the right guide without scanning every file.

> **Audience:** developers joining the project, AI agents, and anyone making app updates.  
> **Source of truth for code conventions:** [`AGENTS.md`](../AGENTS.md)  
> **Package:** `taksh_e_commerce` · Flutter `>=3.22` · Dart `>=3.8`

---

## Quick start

| Task | Doc |
|------|-----|
| Clone, run, env setup | [DEVELOPMENT.md](DEVELOPMENT.md) |
| Understand architecture | [ARCHITECTURE.md](ARCHITECTURE.md) |
| See what features exist | [FEATURES.md](FEATURES.md) |
| Daily code patterns | [QUICK_REFERENCE.md](QUICK_REFERENCE.md) |
| Agent / PR conventions | [../AGENTS.md](../AGENTS.md) |

```bash
flutter pub get
flutter run -t lib/main_dev.dart          # real API
flutter run -t lib/main_mock.dart         # offline mocks, OTP: 1234
```

---

## Core guides

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Clean Architecture layers, dependency rules, adding features |
| [FEATURES.md](FEATURES.md) | Full feature catalog (all 17 modules), SM classes, pages |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Setup, entry points, codegen, lint, FVM, `.env` |
| [ROUTING.md](ROUTING.md) | go_router, shell tabs, auth guards, guest walls |
| [NETWORK_AND_API.md](NETWORK_AND_API.md) | ApiClient, BaseResponse, endpoint map, auth headers |
| [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md) | GetIt conventions, feature DI modules, mock flag |
| [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md) | BLoC vs Cubit, fold pattern, singletons |
| [API_RESPONSE_MODELS.md](API_RESPONSE_MODELS.md) | Standard `{ success, message, data }` envelope |
| [LOCALIZATION.md](LOCALIZATION.md) | en/hi ARB, gen-l10n, SplashCubit locale |
| [CI_CD.md](CI_CD.md) | GitHub Actions release APK workflow |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Snippets for common tasks |
| [MOCK_AUTH_GUIDE.md](MOCK_AUTH_GUIDE.md) | Offline mock mode (`main_mock.dart`) |

---

## Feature deep-dives

| Document | Feature |
|----------|---------|
| [features/AUTH.md](features/AUTH.md) | OTP login, session, guest cart token |
| [features/HOME.md](features/HOME.md) | Dashboard, express 30-min, delivery tabs, services embed |
| [features/PRODUCT.md](features/PRODUCT.md) | Catalog, details, search data, express products |
| [features/CART.md](features/CART.md) | Dual carts, guest token, variants |
| [features/CHECKOUT.md](features/CHECKOUT.md) | Select items → place order → pay |
| [features/PAYMENT.md](features/PAYMENT.md) + [RAZORPAY_INTEGRATION.md](RAZORPAY_INTEGRATION.md) | Razorpay create/verify |
| [features/ORDERS.md](features/ORDERS.md) | List, detail, cancel, returns, invoice |
| [features/ADDRESS.md](features/ADDRESS.md) | CRUD, Hive cache, map picker |
| [features/WALLET.md](features/WALLET.md) | Points, bank accounts, withdrawal |
| [features/HOME_SERVICE.md](features/HOME_SERVICE.md) | Courier + electrician/plumber/salon |
| [features/WISHLIST.md](features/WISHLIST.md) | Wishlist CRUD |
| [features/SPLASH_AND_ONBOARDING.md](features/SPLASH_AND_ONBOARDING.md) | Startup, locale/theme, onboarding |
| [features/QUICK_DELIVERY.md](features/QUICK_DELIVERY.md) | Live map tracking, express product pages |
| [QUICK_DELIVERY_FLOW_REVIEW.md](QUICK_DELIVERY_FLOW_REVIEW.md) | End-to-end Quick flow review (app + admin API), risks, do-not-break checklist |
| [features/PROFILE.md](features/PROFILE.md) | Profile hub, join flows, legal pages |

In-feature READMEs (kept in place):

- [`lib/features/address/ADDRESS_SYNC_README.md`](../lib/features/address/ADDRESS_SYNC_README.md)
- [`lib/features/product/EXPRESS_PRODUCTS_README.md`](../lib/features/product/EXPRESS_PRODUCTS_README.md)

---

## Location & splash (historical + current)

These documents were written during implementation. Prefer the **Current state** sections and [features/ADDRESS.md](features/ADDRESS.md) / [features/SPLASH_AND_ONBOARDING.md](features/SPLASH_AND_ONBOARDING.md) for day-to-day work.

| Document | Notes |
|----------|--------|
| [SPLASH_CUBIT_ARCHITECTURE.md](SPLASH_CUBIT_ARCHITECTURE.md) | SplashCubit singleton (still accurate core design) |
| [SPLASH_IMPLEMENTATION.md](SPLASH_IMPLEMENTATION.md) | Early prototype notes — see Current state banner |
| [LOCATION_PERMISSION_QUICK_START.md](LOCATION_PERMISSION_QUICK_START.md) | Permission UI widgets |
| [LOCATION_PERMISSION_INTEGRATION.md](LOCATION_PERMISSION_INTEGRATION.md) | Full permission integration |
| [location_feature_architecture.md](location_feature_architecture.md) | Address/map design spec |
| [location_feature_diagrams.md](location_feature_diagrams.md) | Mermaid diagrams |
| [location_feature_implementation_guide.md](location_feature_implementation_guide.md) | Step-by-step build guide |
| [location_feature_implementation_status.md](location_feature_implementation_status.md) | Status tracker (feature is **complete**) |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Product/category early summary (feature is **complete**) |

---

## Design assets in `docs/`

Image/JPEG files under `docs/` (splash logo, UI references) are also registered as Flutter assets in `pubspec.yaml`. They are not prose docs.

---

## Doc maintenance rules

When you change the app:

1. Update the relevant **feature** doc under `docs/features/`.
2. If you add routes, endpoints, or DI registrations, update ROUTING / NETWORK_AND_API / DEPENDENCY_INJECTION.
3. If conventions change, update `AGENTS.md` and this index if a new doc is added.
4. Prefer enhancing existing docs over deleting history — mark outdated sections with a **Current state** note instead of removing them.
5. Do not invent APIs or routes; verify against `lib/core/constants/api_constants.dart` and datasources.
