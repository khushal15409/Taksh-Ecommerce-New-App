# Feature: Checkout

**Path:** `lib/features/checkout/`  
**DI:** `di/checkout_injection.dart` → `registerCheckoutDependencies`  
**State:** `CheckoutBloc`  
**Related:** [PAYMENT.md](PAYMENT.md) · [RAZORPAY_INTEGRATION.md](../RAZORPAY_INTEGRATION.md) · [CART.md](CART.md) · [ADDRESS.md](ADDRESS.md)

---

## Purpose

Multi-step purchase:

1. Select cart line items  
2. Choose address + delivery option  
3. Choose payment method (COD | Online)  
4. Place order  
5. If online → initiate Razorpay → verify signature server-side  
6. Order placed / payment result pages  

**Auth required** via router (`/checkout`, `/checkout/select-items`).

---

## Pages

| Page | Route |
|------|--------|
| `SelectItemsPage` | `/checkout/select-items` |
| `CheckoutPage` | `/checkout` |
| `OrderReviewPage` | `/checkout/review` |
| `OrderPlacedPage` | `/order/placed?...` |

---

## Domain concepts

- `SelectedCheckoutItems`  
- `CheckoutSummary` / price breakdown  
- `DeliveryOption`  
- `PaymentMethodSelection` (`cod` | `online`)  
- `OrderRequest` / `PlaceOrderResponse`  

---

## Canonical payment flow (CheckoutBloc)

```
PlaceOrderEvent
  → POST /order/place
  → if COD → success / order placed
  → if online → InitiatePaymentEvent
       → POST /payments/create
       → response: razorpay_order_id, amount (paise), currency, razorpay_key (PUBLIC)
       → RazorpayService.openCheckout(...)
       → on SDK success → VerifyPaymentEvent
            → POST /payments/verify (signature)
            → success UI
       → on failure → PaymentFailedPage
```

**Security:** Flutter never holds Razorpay secret. Public key comes from backend create-payment response. Client success is not trusted without verify.

`PaymentBloc` still exists for legacy/success-page paths — **do not** add new primary flows there.

---

## Key events

- Load/select items, select address, select delivery, select payment method  
- `PlaceOrderEvent`  
- `InitiatePaymentEvent(orderId)`  
- `VerifyPaymentEvent(...)`  

---

## Mock mode

`CheckoutMockDataSource` + `PaymentMockDataSource` when `useMockData` — allows UI walkthrough without real pay.

---

## Place order payload (conceptual)

Backend form/body fields commonly include:

- `address_id`  
- `warehouse_id`  
- `delivery_type` (`normal` / express variants as API expects)  
- `payment_method` (`cod` | `online`)  
- selected item identifiers as implemented in request model  

Confirm exact fields in `PlaceOrderRequestModel` / remote DS when changing API.

---

## Pricing display (current state)

- Delivery is no longer charged (`delivery_charge.price` is `0`), so the
  delivery line renders as **Free**.
- Fees (`charges[]` — platform fee, quick delivery fee) are rendered as their
  own labeled lines in the price breakdown, not folded into delivery charges.
- The amount to pay is `total_with_delivery` (cart) and `grand_total` (order).

---

## When updating

1. Change order of steps only with UX + deep-link awareness.  
2. Keep verify-on-backend mandatory for online pay.  
3. Wire new fees into price breakdown entity + UI.  
4. Update RAZORPAY_INTEGRATION + this doc together.  
5. Ensure delivery check from product feature still gates express checkout when required.
