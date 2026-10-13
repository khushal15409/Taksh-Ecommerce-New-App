# Development Guide

How to set up, run, and work on Taksh E-Commerce day to day.

Related: [ARCHITECTURE.md](ARCHITECTURE.md) · [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md) · [AGENTS.md](../AGENTS.md)

---

## Prerequisites

- Flutter SDK `>=3.22` (team CI: **3.38.5** stable)
- Dart SDK `>=3.8.0 <4.0.0`
- Android Studio / Xcode toolchains as needed
- Optional: [FVM](https://fvm.app/) — project references `.fvm/versions/stable` in VS Code settings

```bash
flutter doctor -v
```

---

## First-time setup

```bash
git clone <repo-url>
cd taksh_e_commerce
flutter pub get
cp .env.example .env          # optional local secrets
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### `.env`

Schema (from `.env.example`):

```env
RAZORPAY_KEY_ID=your_razorpay_key_id_here
RAZORPAY_KEY_SECRET=your_razorpay_key_secret_here
```

**Important:**

- `.env` is **not** committed.
- Checkout online payment uses the **public** Razorpay key returned by the backend (`POST /payments/create`). The Flutter `RazorpayService` validates `rzp_` prefix and must never embed the secret.
- `.env` loading is fail-soft in `app.dart` (missing file does not crash bootstrap).

---

## Entry points

| File | Factory | `useMockData` | Log level | Purpose |
|------|---------|---------------|-----------|---------|
| `lib/main.dart` | `AppConfig.production()` | `false` | warning | Production |
| `lib/main_dev.dart` | `AppConfig.development()` | `false` | debug | Daily dev against API |
| `lib/main_staging.dart` | `AppConfig.staging()` | `false` | info | Staging |
| `lib/main_mock.dart` | `AppConfig.mock()` | **`true`** | debug | Offline / UI without backend |

```bash
flutter run -t lib/main_dev.dart
flutter run -t lib/main_mock.dart
```

VS Code: `.vscode/launch.json` — Dev / Staging / Production / Mock.

### API base URL

All environments currently share:

```
https://taksh-admin.takshallinone.in/api
```

Defined in `lib/core/constants/api_constants.dart` (`devBaseUrl`, `stagingBaseUrl`, `prodBaseUrl`).

---

## Bootstrap sequence (`lib/app.dart`)

`runApp(AppConfig)`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Load `.env` (optional)
3. `Hive.initFlutter()`
4. `initializeDependencies(baseUrl:, useMockData:)`
5. `runApp(TakshECommerceApp)`

Root providers:

- `SplashCubit` (lazy singleton) — locale, theme, location permission
- `AuthBloc` — immediately `AuthCheckRequested`
- `AddressBloc` — app-wide addresses; reset on `Unauthenticated`

`MaterialApp.router` uses `AppRouter`, light/dark themes, and `en` / `hi` localizations.

---

## Essential commands

```bash
# Dependencies
flutter pub get

# Codegen (models / freezed / hive adapters)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

# Localization
flutter gen-l10n

# Quality
flutter analyze
dart format lib/
flutter test
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html

# Release
flutter build apk --release
flutter build appbundle --release
```

Generated files (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`) are gitignored and excluded from the analyzer — always regenerate after model edits.

---

## Mock mode cheat sheet

```bash
flutter run -t lib/main_mock.dart
```

| Item | Value |
|------|--------|
| Phone | Any (preset: `9876543210`, `9876543211`, `9876543212`) |
| OTP | **`1234`** (see `AuthMockDataSource.mockOtp`) |
| What is mocked | Auth, address repo, express dashboard, checkout DS, payment DS |

Full guide: [MOCK_AUTH_GUIDE.md](MOCK_AUTH_GUIDE.md)

> Note: `lib/main_mock.dart` file comment may still say OTP `123456`. **Code accepts `1234`** (`AppConstants.otpLength = 4`). Prefer the code.

---

## Project layout for everyday work

| Path | When you touch it |
|------|-------------------|
| `lib/features/<feature>/` | Feature business + UI |
| `lib/core/di/injector.dart` | Register simple features; call feature `di/` modules |
| `lib/core/routing/app_routes.dart` + `app_router.dart` | New screens |
| `lib/core/constants/api_constants.dart` | New endpoints |
| `lib/core/theme/` | Colors, spacing, typography |
| `lib/l10n/app_en.arb` (+ `app_hi.arb`) | User-visible strings |
| `docs/features/*.md` | Document behavior changes |

---

## Imports & style

- Use **package imports**: `package:taksh_e_commerce/...`
- Theme tokens: `AppColors`, `AppSpacing`, `AppTypography`
- Domain returns `ResultFuture<T>` / `ResultVoid` (`core/utils/typedef.dart`)
- Presentation: `result.fold((f) => ..., (d) => ...)`
- Guard emits: `isClosed` (Cubit) / `emit.isDone` (BLoC)

---

## Platform notes

### Android

- Location permissions in `AndroidManifest.xml` (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`)
- Min SDK / compile SDK follow Flutter template + plugin requirements (Maps, Razorpay)

### iOS

- `Info.plist` location usage strings
- Google Maps API key configuration as required by `google_maps_flutter`

### Assets

Declared in `pubspec.yaml`:

- `assets/images/`
- Selected images under `docs/` (splash logo, reference art)

---

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Missing `.g.dart` | Run `build_runner` |
| Missing l10n getters | Run `flutter gen-l10n`; ensure key exists in template ARB |
| 401 loops | Token cleared on 401 — re-login; check SecureStore |
| Mock still hits network | Confirm `-t lib/main_mock.dart` and `useMockData: true` in logs |
| DI not found | Feature registered in `injector.dart` / feature `di/`? |
| Hive adapter errors | Adapters registered; box opened before use (address typeIds 1, 2, 10) |

---

## CI alignment

Local release builds should roughly match [CI_CD.md](CI_CD.md):

- Flutter 3.38.5 stable
- `flutter pub get` → `build_runner` → `flutter build apk --release`

CI does **not** currently run `flutter test` or `flutter analyze` on every push.
