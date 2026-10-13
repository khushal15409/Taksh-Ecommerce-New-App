# AGENTS.md — Taksh E-Commerce

Conventions for humans and AI agents working on this codebase.

**Documentation index:** [docs/README.md](docs/README.md)  
**Feature catalog:** [docs/FEATURES.md](docs/FEATURES.md)

---

## Entry points

Four entry points via `flutter run -t lib/main_<env>.dart`:

| File | Mode | Notes |
|------|------|-------|
| `main.dart` | Production | `AppConfig.production()` |
| `main_dev.dart` | Development | Real API, debug logs |
| `main_staging.dart` | Staging | Real API, info logs |
| `main_mock.dart` | Mock | `useMockData: true`; any phone; OTP always **`1234`** |

VSCode launch configs in `.vscode/launch.json` mirror these four.

---

## Key commands

```bash
flutter pub get

# Codegen (after model changes)
dart run build_runner build --delete-conflicting-outputs

# Localization (after ARB changes)
flutter gen-l10n

# Lint
flutter analyze

# Test
flutter test
# Coverage
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

---

## Architecture

Feature-first **Clean Architecture** under `lib/features/<feature>/`:

- `domain/` — pure Dart, `Either<Failure, T>` via dartz (`ResultFuture<T>`/`ResultVoid` typedefs in `core/utils/typedef.dart`)
- `data/` — models (json_serializable, `.g.dart` gitignored), datasources, repository impls
- `presentation/` — BLoC (complex flows) or Cubit (simple CRUD)

Shared infra in `lib/core/` (network, DI, routing, theme, error types, websocket, utils, shared widgets).

Deep dive: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

### Presentation-only features

`categories`, `search`, `splash`, `onboarding` — UI (and splash cubit) without their own data layer; they consume other features.

---

## DI conventions (`lib/core/di/injector.dart`)

- **DataSources, Repositories, UseCases** → `registerLazySingleton`
- **BLoCs/Cubits** → `registerFactory` (new per widget), **except** `CartCubit`, `SplashCubit`, `WishlistCubit` → `registerLazySingleton`
- Complex features (address, orders, checkout, payment, quick_delivery, wallet, home_service) have their own `di/<feature>_di.dart`
- Mock/real switching uses `useMockData` flag

Root providers in `app.dart`: `SplashCubit`, `AuthBloc` (+ `AuthCheckRequested`), `AddressBloc`.

Details: [docs/DEPENDENCY_INJECTION.md](docs/DEPENDENCY_INJECTION.md)

---

## Network

`ApiClient` wraps Dio at `lib/core/network/api_client.dart`:

- Auto-injects Bearer token from `SecureStore`
- 401 responses auto-clear the stored token
- Error mapping: DioException → typed AppException
- Envelope: `{ success, message, data }` via `BaseResponse`

All envs share the same base URL: `https://taksh-admin.takshallinone.in/api`

Endpoint map: [docs/NETWORK_AND_API.md](docs/NETWORK_AND_API.md)

---

## Routing

`go_router` with `ShellRoute` for bottom nav tabs. Auth guard in `_redirect()`:

- Routes in `_authRequiredRoutes` → redirect to login with `redirectAfter` param
- Shell tabs (orders, profile, cart) handle guest via `GuestAuthWall` in-page (no redirect)
- Placeholder pages (Onboarding is real; Register, ForgotPassword, etc. may still be stubs) live in `app_router.dart`

Details: [docs/ROUTING.md](docs/ROUTING.md)

---

## State management

- Always `result.fold((failure) => emit(ErrorState(...)), (data) => emit(SuccessState(...)))`
- Guard emissions with `isClosed` (Cubit) or `emit.isDone` (BLoC)
- BLoC events extend `Equatable`, one class per action
- Prefer structured logs: `loggerWithContext({'feature': '...', 'action': '...'})`

Details: [docs/STATE_MANAGEMENT.md](docs/STATE_MANAGEMENT.md)

---

## Codegen & generated files

- `**/*.g.dart`, `**/*.freezed.dart`, `**/*.mocks.dart` — gitignored and excluded from analyzer
- Run `dart run build_runner build --delete-conflicting-outputs` after modifying models/freezed classes
- ARB files in `lib/l10n/` (`app_en.arb`, `app_hi.arb`), run `flutter gen-l10n` after changes

---

## Environment

- `.env` file for optional Razorpay keys (not committed, `.env.example` shows schema)
- Runtime checkout uses **public** Razorpay key from `POST /payments/create` — never ship secret in app logic
- `.fvm/versions/stable` — configured in `.vscode/settings.json`

---

## Imports & style

- Use package imports (`package:taksh_e_commerce/...`), not relative
- Linting inherits `flutter_lints` from `analysis_options.yaml`
- Theme tokens from `lib/core/theme/` — use `AppColors`, `AppSpacing`, `AppTypography`
- User-facing strings → ARB / `AppLocalizations` only

---

## Payments / checkout

- Canonical online pay path: **CheckoutBloc** → place order → initiate payment → `RazorpayService` → verify payment
- `PaymentBloc` is legacy for new flows
- Docs: [docs/features/CHECKOUT.md](docs/features/CHECKOUT.md), [docs/RAZORPAY_INTEGRATION.md](docs/RAZORPAY_INTEGRATION.md)

---

## Tests

No full test suite is checked in yet. Dev deps include `mockito`, `bloc_test`. When adding tests:

- Run `flutter test` for all tests
- Coverage: `flutter test --coverage`
- Patterns in [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)

---

## CI

GitHub Actions workflow (`build-release-apk.yml`) — triggers on push/PR to `main`, `staging`, `master`. Flutter **3.38.5** stable. Builds release APK, renames with version/date, uploads artifact, creates GitHub release on main pushes.

Details: [docs/CI_CD.md](docs/CI_CD.md)

---

## When changing the app, update docs

1. Feature behavior → `docs/features/<FEATURE>.md`  
2. Routes / endpoints / DI → ROUTING / NETWORK_AND_API / DEPENDENCY_INJECTION  
3. New module → row in FEATURES.md + index link in docs/README.md  
4. Do not delete historical docs; add a **Current state** banner if outdated  
