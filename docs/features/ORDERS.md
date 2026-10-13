# Feature: Orders

**Path:** `lib/features/orders/`  
**DI:** `di/order_di.dart`  
**State:** `OrdersCubit` (factory)  
**Related:** quick_delivery tracking, websocket infra

---

## Purpose

- Paginated order list  
- Order detail  
- Cancel order  
- Return request + media upload  
- Invoice PDF download (open via `path_provider` + `open_filex`)  
- Planned live tracking (partial)

---

## Pages

| Page | Notes |
|------|--------|
| `OrdersPage` | Shell tab; `GuestAuthWall` |
| `OrderDetailsPage` | `/orders/:id` |
| `ReturnRequestPage` | Return flow |

---

## API

| Action | Path |
|--------|------|
| List | `GET /order/orders` |
| Detail | `GET /order/orders/:id` |
| Cancel | `POST /order/orders/:id/cancel` |
| Return create | `POST /return/customer/create` |
| Return media | `POST /return/customer/upload-media` |
| Invoice file | `GET {origin}/orders/:orderNumber/invoice/file` (**not** under `/api`) |

Invoice helper: `ApiConstants.orderInvoiceFile(orderNumber, baseUrl:)`.

---

## Live tracking status

| Piece | Status |
|-------|--------|
| `core/websocket/*` | Infrastructure ready |
| `LiveOrderTrackingCubit` | Code exists; **not registered in order_di** as of last audit |
| Production WS URL | Not finalized in app config |

Quick delivery map polling/location uses `GET /order/orders/:id/delivery-location` via quick_delivery feature — separate from generic WS live feed.

When finishing live tracking:

1. Register cubit + manager in DI  
2. Configure `WebSocketConfig` URL + auth  
3. Document protocol messages here  
4. Attach from order details UI  

---

## Order bill (current state)

Order detail builds the bill from the order's own money fields rather than
adding items up in the app:

`items_total`, `taksh_charge_total`, `platform_fee`, `quick_delivery_fee`,
`discount_total`, `grand_total` — with `grand_total` used as the amount paid.

Refunds come back as `refund_transactions` (wallet credits) and are shown on
the order screen. The app's return flow does **not** send an `amount`.

---

## When updating

- Keep invoice URL outside `/api` when backend stays that way.  
- Return media upload: respect multipart limits and error mapping.  
- List pagination: preserve scroll/page state patterns in cubit.  
- Guest wall copy → l10n.
