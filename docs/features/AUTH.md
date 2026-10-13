# Feature: Authentication

**Path:** `lib/features/auth/`  
**State:** `AuthBloc` (factory, provided once at app root)  
**Related:** [MOCK_AUTH_GUIDE.md](../MOCK_AUTH_GUIDE.md) · [ROUTING.md](../ROUTING.md)

---

## Purpose

Phone OTP login, session restore on cold start, profile fetch/update, logout. Guests can browse catalog; protected actions force login.

---

## Layers

```
domain/     User entity, AuthRepository, use cases (send/verify OTP, logout, profile…)
data/       models, AuthRemoteDataSource / AuthMockDataSource, AuthLocalDataSource, AuthRepositoryImpl
presentation/  AuthBloc + events/states, LoginPage, VerifyOtpPage
```

---

## API

| Action | Endpoint |
|--------|----------|
| Send OTP | `POST /auth/send-otp` |
| Verify OTP | `POST /auth/verify-otp` |
| Profile | `GET /auth/profile` |
| Update profile | `POST /auth/update-profile` |

Tokens stored via **SecureStore** (`flutter_secure_storage`). User cache via local datasource (SharedPreferences/Hive patterns as implemented).

---

## Flow

```
App start → AuthCheckRequested
  ├─ token + cached user → Authenticated
  └─ none → Unauthenticated (guest browse OK)

LoginPage → AuthSendOtpRequested(phone)
  → AuthOtpSent (may carry guest token)
  → VerifyOtpPage → AuthVerifyOtpRequested(phone, otp, guestToken?)
  → token saved → Authenticated
  → AppRouter.navigateAfterAuth(redirectAfter)

Logout → clear token/user → Unauthenticated
  → root listener → ResetAddressesEvent
```

OTP length in UI/constants: **4 digits** (`AppConstants.otpLength`).

---

## Guest cart handoff

Send OTP / verify can accept a **guest cart token** so the backend merges anonymous cart into the authenticated user. Token lives in SecureStore (`guest_cart_token` / related keys via `SecureStore` + cart feature).

---

## AuthBloc events (summary)

- `AuthCheckRequested`
- `AuthSendOtpRequested`
- `AuthVerifyOtpRequested`
- `AuthLogoutRequested`
- `AuthGetCurrentUserRequested` / `AuthFetchProfileRequested`
- `AuthUpdateProfileRequested`

States include: `AuthInitial`, `AuthLoading`, `AuthOtpSent`, `Authenticated`, `Unauthenticated`, `AuthError`, profile update success/failure, `LogoutSuccess`.

---

## Mock mode

`useMockData: true` → `AuthMockDataSource`

| | |
|--|--|
| OTP | **`1234`** (`mockOtp` constant) |
| Phones | Any; presets `9876543210` John, `9876543211` Jane, `9876543212` Bob |

Entry: `flutter run -t lib/main_mock.dart`

---

## Guard integration

| Mechanism | Where |
|-----------|--------|
| Router redirect | addresses, checkout, quick-delivery |
| GuestAuthWall | cart, orders, profile tabs |
| ApiClient 401 | clears token → user must re-auth |

---

## When updating this feature

1. Keep domain free of Flutter imports.  
2. Map all API errors to failures.  
3. Never log full tokens.  
4. Update mock datasource + this doc + MOCK_AUTH_GUIDE if OTP/test users change.  
5. If adding refresh tokens, update ApiClient 401 handling and this flow diagram.
