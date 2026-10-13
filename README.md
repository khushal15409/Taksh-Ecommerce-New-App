# Taksh E-Commerce

Production Flutter multi-commerce application (standard delivery, 30-minute express, home services, wallet) built with **feature-first Clean Architecture**.

[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.22-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.8-blue.svg)](https://dart.dev/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-green.svg)](docs/ARCHITECTURE.md)

> Full documentation index: **[docs/README.md](docs/README.md)**  
> Agent / coding conventions: **[AGENTS.md](AGENTS.md)**

---

## What this app does

- **Browse & buy** products (standard ecommerce catalog)
- **Express 30-min** delivery from nearest fulfillment center
- **Home services** — courier booking, electrician, plumber, salon
- **OTP authentication** with guest browsing
- **Cart** (including guest cart token merge on login)
- **Checkout** with COD or **Razorpay** online payment
- **Orders** — list, detail, cancel, returns, invoice download
- **Addresses** with map picker + Hive offline cache
- **Wishlist**, **wallet** (points + withdrawal), **profile** join flows
- **i18n** — English and Hindi
- **Mock mode** for offline UI development

---

## Requirements

| Tool | Version |
|------|---------|
| Flutter SDK | `>=3.22.0` (CI uses **3.38.5** stable) |
| Dart SDK | `>=3.8.0 <4.0.0` |
| IDE | Android Studio / VS Code + Flutter extensions |
| Optional | FVM (see `.vscode/settings.json`) |

---

## Tech stack

| Area | Packages |
|------|----------|
| UI | Flutter Material 3, Google Fonts (Nunito), flutter_svg, cached_network_image |
| State | flutter_bloc, equatable |
| DI | get_it |
| Errors | dartz (`Either` / `ResultFuture`) |
| Network | dio, connectivity_plus |
| Storage | flutter_secure_storage, shared_preferences, hive |
| Routing | go_router |
| Maps / location | google_maps_flutter, geolocator, geocoding, permission_handler |
| Payments | razorpay_flutter |
| Logging | logger, talker |
| Codegen | freezed, json_serializable, build_runner, hive_generator |
| i18n | flutter_localizations, intl, ARB (`lib/l10n/`) |
| Testing (deps ready) | mockito, bloc_test, flutter_test |

---

## Project structure (high level)

```
lib/
├── main.dart / main_dev.dart / main_staging.dart / main_mock.dart
├── app.dart                 # AppConfig, bootstrap, root MultiBlocProvider
├── core/                    # network, DI, routing, theme, error, websocket, widgets
├── features/                # feature modules (Clean Architecture)
│   ├── auth/ address/ cart/ checkout/ orders/ payment/
│   ├── home/ product/ categories/ search/ wishlist/
│   ├── quick_delivery/ home_service/ wallet/ profile/
│   ├── splash/ onboarding/
└── l10n/                    # app_en.arb, app_hi.arb
docs/                        # all project documentation (start at docs/README.md)
```

Each full feature typically has:

```
features/<name>/
├── domain/     # entities, repository contracts, use cases
├── data/       # models, datasources, repository impls
├── presentation/  # bloc|cubit, pages, widgets
└── di/         # optional feature-local GetIt registration
```

---

## Getting started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Environment file (payments)

```bash
cp .env.example .env
# Optional: Razorpay keys for local experiments.
# Runtime checkout uses the PUBLIC key returned by POST /payments/create.
```

### 3. Code generation (after model changes)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Localization (after ARB changes)

```bash
flutter gen-l10n
```

### 5. Run

| Mode | Command | Notes |
|------|---------|--------|
| Development | `flutter run -t lib/main_dev.dart` | Debug logs, real API |
| Staging | `flutter run -t lib/main_staging.dart` | Info logs, real API |
| Production | `flutter run -t lib/main.dart` | Warning logs |
| Mock | `flutter run -t lib/main_mock.dart` | No API; OTP **`1234`** |

VS Code launch configs in `.vscode/launch.json` mirror these four.

**API base URL (all environments today):**  
`https://taksh-admin.takshallinone.in/api`

### 6. Build release

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

CI also builds release APKs on push/PR — see [docs/CI_CD.md](docs/CI_CD.md).

---

## Architecture (summary)

**Dependency rule:** Domain ← Data · Domain ← Presentation  

- **Domain** — pure Dart, `Either<Failure, T>` via dartz  
- **Data** — Dio/`ApiClient`, Hive/SharedPreferences, exception → failure mapping  
- **Presentation** — BLoC (complex flows) or Cubit (CRUD); theme tokens from `core/theme/`

Details: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) · Feature list: [docs/FEATURES.md](docs/FEATURES.md)

---

## Authentication (summary)

1. Guest can browse home, categories, products.  
2. Phone → `POST /auth/send-otp` → OTP screen.  
3. Verify → token in `SecureStore`, user cached.  
4. Auth-required routes (addresses, checkout, quick-delivery) redirect to login with `redirectAfter`.  
5. Shell tabs orders / profile / cart use in-page `GuestAuthWall`.

Mock: any phone + OTP `1234` — [docs/MOCK_AUTH_GUIDE.md](docs/MOCK_AUTH_GUIDE.md)

---

## Documentation map

| Need | Go to |
|------|--------|
| Index of all docs | [docs/README.md](docs/README.md) |
| Architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Features catalog | [docs/FEATURES.md](docs/FEATURES.md) |
| Routing & auth guards | [docs/ROUTING.md](docs/ROUTING.md) |
| API / network | [docs/NETWORK_AND_API.md](docs/NETWORK_AND_API.md) |
| DI | [docs/DEPENDENCY_INJECTION.md](docs/DEPENDENCY_INJECTION.md) |
| State management | [docs/STATE_MANAGEMENT.md](docs/STATE_MANAGEMENT.md) |
| Checkout / Razorpay | [docs/features/CHECKOUT.md](docs/features/CHECKOUT.md), [docs/RAZORPAY_INTEGRATION.md](docs/RAZORPAY_INTEGRATION.md) |
| Quick snippets | [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) |
| AI agent rules | [AGENTS.md](AGENTS.md) |

---

## Testing & quality

```bash
flutter analyze
flutter test
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
dart format lib/
```

Automated tests are not fully populated yet; `mockito` and `bloc_test` are available. Patterns: [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md#testing-patterns).

---

## Code style

- Package imports: `package:taksh_e_commerce/...`
- Lints: `flutter_lints` via `analysis_options.yaml`
- Theme: `AppColors`, `AppSpacing`, `AppTypography` — no hard-coded design values
- User-facing strings: ARB files only

---

## Contributing

1. Follow Clean Architecture and DI conventions in `AGENTS.md`.  
2. After model changes → `build_runner`. After ARB → `flutter gen-l10n`.  
3. Update the relevant doc under `docs/` when behavior or APIs change.  
4. Prefer enhancing docs over deleting historical notes.

---

## License

Project-internal unless a `LICENSE` file is added at the repository root.
