# Razorpay Payment Gateway Integration

Instructions for Razorpay in the Taksh checkout flow.

**Also read:** [features/CHECKOUT.md](features/CHECKOUT.md) · [features/PAYMENT.md](features/PAYMENT.md) · `lib/core/services/razorpay_service.dart`

---

## Overview

Supported checkout payment methods:

1. **Cash on Delivery (COD)** — default  
2. **Online Payment via Razorpay** — card, UPI, wallets, net banking (as enabled on Razorpay dashboard)

### Canonical orchestration

**`CheckoutBloc`** owns place-order + initiate + verify.  
Payment feature supplies use cases/datasources.  
`PaymentBloc` may still power some result pages — treat as **legacy** for new features.

---

## Current production-shaped flow

### COD

```
Select COD → PlaceOrderEvent → POST /order/place → Order placed / success UI
```

### Online (Razorpay)

```
Select Pay Online
  → PlaceOrderEvent → POST /order/place  (creates app order)
  → InitiatePaymentEvent → POST /payments/create
       response includes:
         - razorpay_order_id
         - amount (paise)
         - currency
         - razorpay_key   ← PUBLIC key (rzp_test_* / rzp_live_*)
  → RazorpayService.openCheckout(...)
  → SDK success → VerifyPaymentEvent → POST /payments/verify (signature)
  → Success UI / order placed
  → SDK failure / cancel → PaymentFailedPage
```

### Security rules (enforced in code comments)

- **Secret key never lives in Flutter runtime payment path**  
- Public key for checkout comes from **backend create payment** response  
- `RazorpayService` rejects empty/non-`rzp_` keys  
- Never trust client-only success without `/payments/verify`  

---

## Setup

### 1. Backend

Ensure backend implements:

- `POST /payments/create` — creates Razorpay order, returns public key + order id + amount  
- `POST /payments/verify` — verifies signature  

### 2. Optional local `.env`

```bash
cp .env.example .env
```

```env
RAZORPAY_KEY_ID=rzp_test_your_key_id_here
RAZORPAY_KEY_SECRET=your_key_secret_here
```

Notes:

- `.env` is fail-soft loaded at bootstrap  
- Checkout path prefers **backend-issued** public key  
- Do **not** commit real secrets  
- Secret must not be embedded in release logic  

### 3. Dependencies

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Package: `razorpay_flutter` (see `pubspec.yaml`).

### 4. Test cards (Razorpay test mode)

- **Card:** `4111 1111 1111 1111`  
- Any future expiry  
- Any CVV (e.g. `123`)  

Use Razorpay’s current test docs for UPI/wallet test instruments.

---

## Architecture map

```
lib/
├── core/services/razorpay_service.dart
└── features/
    ├── checkout/
    │   ├── domain/… payment_method_selection, place order entities
    │   ├── presentation/bloc/checkout_bloc.dart  ← PlaceOrder / Initiate / Verify
    │   └── presentation/pages/checkout_page.dart ← opens RazorpayService
    └── payment/
        ├── domain/usecases/  InitiatePayment, VerifyPayment, …
        ├── data/datasources/ payment_remote + payment_mock
        └── presentation/pages/ payment_success_page, payment_failed_page
```

---

## Historical flow note (preserved)

Earlier documentation described:

```
Pay Online → mock Razorpay order → open checkout → on success place order API
```

**Current code places the app order first**, then creates the Razorpay order and verifies after SDK success. Prefer the “Current production-shaped flow” section above when implementing or testing.

Mock datasources still allow offline UI when `useMockData: true`.

---

## Key UI pieces

### Payment method selection

- COD vs Online selector widget on checkout  
- Button label may switch (“Place Order” vs “Proceed to Pay”) based on method  

### Success & failure pages

- **Success:** order number / confirmation  
- **Failure:** error message; may auto-redirect to cart after a delay; retry actions  

---

## State management (CheckoutBloc)

```dart
// Events (names as in codebase)
PlaceOrderEvent
InitiatePaymentEvent(orderId)
VerifyPaymentEvent(...)
SelectPaymentMethodEvent(PaymentMethodSelection)

// Selection type
PaymentMethodSelection → cod | online
```

---

## Backend contracts (app-facing)

### Create payment

```
POST /api/payments/create
Authorization: Bearer <token>
```

Response `data` must include fields consumed by `InitiatePayment` models (order id, amount paise, currency, **razorpay_key**).

### Verify payment

```
POST /api/payments/verify
```

Body includes Razorpay payment id, order id, signature (see verify params model).

### Place order

```
POST /api/order/place
```

Typical fields (confirm in `PlaceOrderRequestModel`):

- `address_id`  
- `warehouse_id`  
- `delivery_type`  
- `payment_method`: `cod` | `online`  
- line-item selection fields as implemented  

---

## Testing checklist

1. **COD** — place order end-to-end, order appears in Orders  
2. **Online success** — test card → verify called → success UI  
3. **Online cancel/fail** — failure page + no false “paid” state  
4. **Mock mode** — `main_mock.dart` checkout without real Razorpay  
5. **Invalid key** — backend returns bad key → service fails closed  

---

## Troubleshooting

| Issue | Check |
|-------|--------|
| “Payment gateway configuration error” | Backend `razorpay_key` missing/invalid prefix |
| Checkout SDK never opens | Plugin install, platform setup, console logs |
| Paid in Razorpay but order unpaid | Verify endpoint / signature / order id mismatch |
| Works in test not live | Live keys on backend + Razorpay dashboard activation |

---

## Next steps / backlog (from original plan, still valid)

1. Ensure production backend always issues correct live public key  
2. Payment history UI completeness  
3. Refunds (backend-first)  
4. Reduce reliance on PaymentBloc for any remaining paths  

---

## Support links

- [Razorpay Documentation](https://razorpay.com/docs/)  
- [Razorpay Flutter SDK](https://github.com/razorpay/razorpay-flutter)  
- [Razorpay Support](https://razorpay.com/support/)  
