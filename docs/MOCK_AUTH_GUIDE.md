# Mock Authentication & Mock Data Guide

This guide explains how to run the app **without backend API calls** using mock data sources.

> **Current entry point:** `lib/main_mock.dart` → `AppConfig.mock()` → `useMockData: true`  
> **Mock OTP (code):** `1234` — see `AuthMockDataSource.mockOtp`  
> **OTP field length:** 4 (`AppConstants.otpLength`)

Related: [features/AUTH.md](features/AUTH.md) · [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md) · [DEVELOPMENT.md](DEVELOPMENT.md)

---

## Overview

When mock mode is enabled, DI swaps selected implementations:

| Area | Mock binding |
|------|----------------|
| Auth | `AuthMockDataSource` |
| Address | `MockAddressRepository` |
| Express dashboard | `MockExpressDashboardRepository` |
| Checkout | `CheckoutMockDataSource` |
| Payment | `PaymentMockDataSource` |

Other features may still attempt real network calls unless also mocked — mock mode is **strongest** around auth + checkout/payment + address + express home.

Benefits:

- **Send OTP**: Accepts phone numbers and returns mock guest context  
- **Verify OTP**: Validates against fixed mock OTP and returns a mock user + token  
- **No network required** for mocked slices  
- **Configurable delays** in mock classes where implemented  

---

## Quick Start

### 1. Run mock entry point

```bash
flutter run -t lib/main_mock.dart
```

VS Code: launch configuration **Mock**.

Equivalent config (already in `AppConfig.mock()`):

```dart
AppConfig(
  environment: Environment.mock,
  baseUrl: ApiConstants.prodBaseUrl, // unused for mocked calls
  logLevel: Level.debug,
  enableDebugLogs: true,
  useMockData: true,
)
```

### 2. Test credentials

| Item | Value |
|------|--------|
| Phone | Any valid-looking number |
| Preset users | `9876543210` John Doe · `9876543211` Jane Smith · `9876543212` Bob Johnson |
| **OTP** | **`1234`** |
| Other phones | Create a new mock user automatically |

> Historical docs and the comment in `main_mock.dart` may still mention OTP `123456`. **Trust the code constant `mockOtp = '1234'`.**

### 3. Mock user shape

Mock auth returns a user roughly like:

```dart
UserModel(
  id: <generated>,
  name: 'Mock User' | preset name,
  mobile: <your_phone_number>,
  email: 'mock.user@example.com' | preset,
  // verification flags depend on preset
)
```

Inspect `lib/features/auth/data/datasources/auth_mock_datasource.dart` for exact fields.

---

## Usage examples

### Mock mode (recommended)

```dart
// lib/main_mock.dart
void main() async {
  await app.runApp(app.AppConfig.mock());
}
```

### Real API development

```dart
// lib/main_dev.dart
void main() async {
  await app.runApp(app.AppConfig.development()); // useMockData: false
}
```

### Flag name (important)

| Correct (current) | Obsolete name in older docs |
|-------------------|-----------------------------|
| `useMockData` on `AppConfig` / `initializeDependencies` | `useMockAuth` |

Older snippets below are kept for history; prefer `useMockData`.

<details>
<summary>Historical API (do not use)</summary>

```dart
// OUTDATED — AppConfig no longer takes useMockAuth
app.AppConfig.development(useMockAuth: true)
```

</details>

---

## Testing the auth flow

### Step 1: Send OTP

1. Enter any phone number (e.g. `9876543210`)  
2. Tap send OTP  
3. Mock system simulates delay and succeeds  

### Step 2: Verify OTP

1. Enter OTP: **`1234`**  
2. Mock validates, saves user/token locally, emits `Authenticated`  
3. Router navigates via post-auth helpers  

### Step 3: Invalid OTP

Any value other than `1234` fails with a mock error message indicating the expected OTP.

---

## Configuration options

### Network delay

If the mock datasource exposes a delay parameter, adjust registration in DI / mock constructor (see `auth_mock_datasource.dart` and `injector.dart`).

### Valid OTP

Change only if the whole team agrees — update:

1. `AuthMockDataSource.mockOtp`  
2. This guide  
3. `main_mock.dart` dartdoc comment  
4. Any QA scripts  

---

## Switching mock vs real

### Method 1: Separate entry points (recommended)

```bash
flutter run -t lib/main_mock.dart   # mock
flutter run -t lib/main_dev.dart    # real API
```

### Method 2: Custom main (advanced)

You can construct `AppConfig` manually with `useMockData: true` while pointing at another environment name if needed for experiments.

---

## Logging

Look for DI logs indicating mock datasources are registered, e.g. mock auth / mock checkout. Exact log strings depend on current logger calls in `injector.dart` and mock classes.

---

## Benefits of mock mode

1. Offline UI development  
2. Faster iteration without API rate limits  
3. Predictable OTP/users  
4. Safer demos  
5. Checkout/payment UI without real charges  

---

## Limitations

1. Not all features are mocked — some screens may still hit network  
2. Single primary OTP (`1234`)  
3. Mock user data is simplified  
4. Production / store builds must use real entry (`main.dart`) with `useMockData: false`  
5. Payment mock does not replace real Razorpay certification testing  

---

## Troubleshooting

### Mock auth not working

- Confirm launch target is `main_mock.dart`  
- Confirm logs show mock datasource registration  
- Full restart after switching entry points  

### OTP verification fails

- Use **`1234`**, not `123456`  
- Ensure 4-digit input matches validators  

### Still making API calls

- Feature may not be in the mock switch list — add a mock DS or run against real API  
- Clear app data if old tokens confuse state  

### Want different mock data

Edit:

- `lib/features/auth/data/datasources/auth_mock_datasource.dart`  
- Other `*_mock_datasource.dart` / mock repositories  

---

## Best practices

1. Use mock for UI and navigation polish  
2. Use `main_dev.dart` for integration against backend  
3. Keep this guide’s OTP in sync with code  
4. Never ship `useMockData: true` in production entry  
5. When adding a feature critical for offline demos, add mock DS + DI branch  

---

## Architecture

The mock system follows the same Clean Architecture as production:

```
Presentation (AuthBloc, pages)
        ↓
Domain (use cases, repository interface)
        ↓
Data: AuthRepositoryImpl
        ↓
   AuthRemoteDataSource  ─┬─ Real impl (API)
                          └─ Mock impl  ← switched by useMockData
```

---

## Related files

- `lib/features/auth/data/datasources/auth_mock_datasource.dart`  
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`  
- `lib/core/di/injector.dart`  
- `lib/app.dart` — `AppConfig.mock()`  
- `lib/main_mock.dart`  

---

## Historical notes (preserved)

Earlier iterations of this guide documented:

- `useMockAuth` flag naming  
- OTP `123456` and 6-digit flows  
- `AuthRemoteDataSourceMock` class name variants  

The **behavior goal** (offline auth simulation) is unchanged; only the flag name, class file name (`auth_mock_datasource.dart`), and OTP length/value follow current code.
