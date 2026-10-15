# Feature: Home Service

**Path:** `lib/features/home_service/`  
**DI:** `di/home_service_di.dart`  
**State:** `HomeServiceCubit`  
**Entry UX:** Home tab with `delivery=services` embeds `HomeServiceContent`

---

## Purpose

Non-product services marketplace:

- Service catalog  
- **Courier** — delivery partners, quote, book, history (payment pending)  
- **Electrician / plumber / salon** — book + Razorpay payment  
- Service order / inquiry history  

---

## API (`ApiConstants`)

| Path | Role |
|------|------|
| `/service/services` | Catalog (returns `base_price` + `service_charge`) |
| `/service/book` | Availability + create booking + Razorpay order (`POST`), list bookings (`GET`) |
| `/service/book/verify` | Verify booking payment signature |
| `/service/book/{id}` | Booking detail |
| `/service/book/{id}/cancel` | Cancel booking |
| `/service/service-inquiry` | Inquiry (legacy) |
| `/service/service-orders` | Orders list (legacy, still used by history UI) |
| `/service/courier/delivery-partners` | Partners |
| `/service/courier/quote` | Quote |
| `/service/courier/bookings` | Book courier (payment pending) |
| `/service/electrician/bookings` | Legacy per-trade booking |
| `/service/plumber/bookings` | Legacy per-trade booking |
| `/service/salon/bookings` | Legacy per-trade booking |

---

## Payment flow (electrician / plumber / salon)

Mirrors product checkout, but booking + payment order are created in one call:

1. `POST /service/book` with customer/address details + `idempotency_key`
   → returns booking (`id`, `booking_number`, `status`, `payment_status`) **and**
   Razorpay order (`razorpay_order_id`, `amount`, `amount_in_paise`,
   `currency`, `razorpay_key`, `gateway`).
2. `RazorpayService.openCheckout(...)` (`lib/core/services/razorpay_service.dart`).
3. On SDK success → `POST /service/book/verify`
   (`razorpay_order_id`, `razorpay_payment_id`, `razorpay_signature`).
4. Success dialog → history. Booking remains `pending` if payment is abandoned.

The required service description and optional notes are joined into the single
`customer_notes` field the API accepts. `type` is sent as `home`. Services with a
zero `service_charge` are confirmed without a Razorpay step.

**History:** `ServiceHistoryPage` reads `GET /service/book` (list),
`GET /service/book/{id}` (detail) and cancels via
`POST /service/book/{id}/cancel`. The list response has no `service_id` filter,
so the page filters client-side when opened for a specific service. The
in-service filter (`service_id`) and invoice download remain TODO.

---

## Entities (examples)

`HomeService`, `CourierBooking`, `CourierQuote`, `CourierDeliveryPartner`, `ServiceInquiry`,
`ServiceBooking`, `ServiceBookingPayment`, `VerifyServiceBookingResult`

---

## Pages

- `CourierBookingPage`, `CourierHistoryPage`  
- `GeneralServicePage`, `ServiceHistoryPage`  
- Widget: `HomeServiceContent` (embedded in home)

---

## When updating

- New trade type → new endpoint constant + booking model + cubit methods + page route if needed.  
- Keep home embed thin; heavy forms stay in feature pages.  
- All copy in ARB (en + hi).  
- Auth: confirm whether bookings require login (likely yes) and align with router guards if exposed as top-level routes.

---

## Current state: Courier booking, payment, history & invoices

**Courier booking** now uses the Shiprocket flow of the admin API:

1. `POST /service/courier/quote` (pickup/delivery pincode + weight + size) → live `couriers[]` with `rate`, `service_charge`, `total_amount`.
2. `POST /service/courier/bookings` (with `shiprocket_courier_company_id` + `quoted_rate`) → booking + embedded Razorpay `payment` order.
3. Razorpay checkout (`RazorpayService`, same as the other services). If the order was not created with the booking, `POST /service/courier/payment/create` is called.
4. `POST /service/courier/payment/verify` → booking confirmed; shipment/AWB is created by the server.

An unpaid booking is reused for "Retry Payment" while the form is unchanged; changing pincodes/weight/size invalidates the rates.

**History / details**: `GET /service/courier/bookings` and `GET /service/courier/bookings/{id}` (timeline from `tracking_timeline`), cancel via `POST /service/courier/bookings/{id}/cancel`. `CourierHistoryPage` mirrors `ServiceHistoryPage`.

**Invoices** (paid bookings only, own bookings only): `GET /service/courier/bookings/{id}/invoice` and `GET /service/book/{id}/invoice` stream a PDF. The app downloads via `downloadServiceInvoice()` (`presentation/utils/service_invoice_downloader.dart`) and opens it.

**Form validation**: `ServiceFormValidators` + `validateFields()` — messages show under each field after the first failed submit and clear as the user types; the view scrolls to the first error.
