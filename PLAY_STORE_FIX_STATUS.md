# Play Store issues – fix status (branch `fix/play-store-issues`, app + API)

No build/run was possible (Flutter CLI is not installed on this machine). Backend changes were checked with `php -l` and scripted tests; app changes were read carefully but **not compiled**: run `flutter analyze && flutter build apk --release -t lib/main.dart` before shipping.

## Fixed in code
| ID | What was done |
|---|---|
| BE-03 | Wrong-guess limits for the 4 login OTP contexts: code burned after 5 wrong tries, number locked after 10 in 15 min, 429 `api.otp_locked`. **Behind `AUTH_OTP_LIMITS_ENABLED` (default false)**: enable on staging first. Other OTP flows untouched. |
| BE-04 | Per-IP throttle (30/min per route) on login `send-otp` / `verify-otp` (customer, vendor, salesman, delivery). |
| BE-05 | `SANCTUM_EXPIRATION` env added; default stays "never" (no behaviour change). Set it only after the apps log in again on a 401. |
| BE-10 / BE-01 (example file) | `.env.example`: `APP_DEBUG=false`; real APP_KEY, DB host/user/password, Razorpay key/secret/webhook secret removed. **They are still in git history: rotate them (see below).** |
| PY-04 | `RAZORPAY_REFUND_ON_CANCEL`, `UNPAID_ORDER_EXPIRY_MINUTES` documented in `.env.example` (live values still to be set by you). |
| BE-12 / PY-08 | `POST /api/razorpay/test-keys` now needs a signed-in user + throttle. |
| BE-14 | OTP-sent log writes only the last 4 digits of the mobile. |
| BE-15 | Upload file names: script/executable or odd client extensions are replaced by the detected type (or `bin`). Normal images/PDF/XLSX unchanged. |
| PY-06 | Wallet withdrawal: balance check + insert under a user row lock. |
| FL-10 | Manifest: app label "Taksh", `allowBackup="false"`, `<queries>` for https / mailto / tel / whatsapp. |
| FA-002 | Order help screen uses the real support email + WhatsApp number the Profile page already uses (`SupportContacts`). |
| FA-006 | One `LegalConstants.policiesLastUpdated` for the three policy pages. |
| FA-010 | `print()` calls (bank-detail datasource) removed; the structured logger calls stay. |
| FA-017 | `pubspec.yaml` description corrected. |

## Already done before this branch (merged P0 work) or stale in the register
Account deletion, invoice-route auth, refund cap / double-refund guard (BE-02, PY-01/02, FA-001/BE-07 backend) were merged earlier; FA-011 (`dispose`) is already in `wallet_page.dart`.

## Needs YOU (cannot be done safely from here)
- **FL-01** upload keystore + release signing; **FL-02** final `applicationId` (permanent) and **FL-03** matching `google-services.json`.
- **BE-01 / secrets:** rotate the Firebase service-account key, DB password, APP_KEY, Razorpay key/secret/webhook secret (they were in git history). Checklist: `API/docs/release/secret-rotation-checklist.md`.
- **FL-05** restrict the Google Maps key (package + SHA-1); **FL-06** stop bundling `.env`; **FL-07** target SDK 36; **FL-04** R8/obfuscation (needs a release build + test).
- **BE-11** `composer update symfony/*` (8 advisories): needs a staging test run. **BE-06/08/09, BE-13, BE-16, PY-03/05/07/10–13, FL-08, FA-003–005/007/008:** product/legal decisions or larger changes; not started.
