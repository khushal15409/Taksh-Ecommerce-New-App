# Feature: Payment

**Path:** `lib/features/payment/`  
**DI:** `di/payment_injection.dart`  
**Service:** `lib/core/services/razorpay_service.dart`  
**Deep guide:** [RAZORPAY_INTEGRATION.md](../RAZORPAY_INTEGRATION.md)

---

## Purpose

- Create Razorpay order via backend  
- Verify payment signature via backend  
- Payment history  
- Success / failed result pages  

**Canonical orchestration for checkout is `CheckoutBloc`**, which depends on payment use cases (`InitiatePayment`, `VerifyPaymentUseCase`). `PaymentBloc` remains for older or page-local flows — treat as legacy for new work.

---

## Endpoints

| Method | Path | Role |
|--------|------|------|
| POST | `/payments/create` | Server creates Razorpay order; returns public key + order id + amount |
| POST | `/payments/verify` | Verifies signature |
| GET | `/payments/history` | History |

---

## RazorpayService

```dart
initialize(onSuccess:, onFailure:)
openCheckout(
  razorpayOrderId:,
  amountInPaise:,
  razorpayKey:, // MUST be from backend, rzp_ prefix
  orderNumber:,
  userName:, userEmail:, userPhone:,
)
```

Dispose listeners when page disposes.

---

## Pages

- `PaymentSuccessPage`  
- `PaymentFailedPage` (often auto-redirects toward cart after delay)

---

## Env vs runtime key

| Source | Use |
|--------|-----|
| Backend `razorpay_key` on create | **Runtime checkout** |
| `.env` RAZORPAY_KEY_* | Optional local/dev; secret must never ship in app binaries for production logic |

---

## Mock

`PaymentMockDataSource` under mock mode for create/verify without Razorpay UI dependency (or with simulated responses).

---

## When updating

- Prefer extending CheckoutBloc payment events over growing PaymentBloc.  
- Any new method (UPI intent, wallets) still must create+verify server-side.  
- Update test cards section in RAZORPAY_INTEGRATION for QA.
