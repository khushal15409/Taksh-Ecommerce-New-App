# Network Layer & API Map

| File | Role |
|------|------|
| `lib/core/network/api_client.dart` | Dio wrapper |
| `lib/core/network/network_info.dart` | Connectivity |
| `lib/core/network/base_response_model.dart` | `{ success, message, data }` |
| `lib/core/constants/api_constants.dart` | Paths + base URLs |
| `lib/core/error/exceptions.dart` | Data-layer throws |
| `lib/core/error/failures.dart` | Domain-layer `Either` lefts |

Also: [API_RESPONSE_MODELS.md](API_RESPONSE_MODELS.md)

---

## Base URL

```
https://taksh-admin.takshallinone.in/api
```

Same value for dev / staging / production constants today. Invoice PDFs use **server origin without `/api`** via `ApiConstants.serverOriginFromBaseUrl` / `orderInvoiceFile`.

Timeouts: **30s** connect / receive / send.

---

## ApiClient behavior

`ApiClient` wraps Dio and:

1. **Auth header** — injects `Authorization: Bearer <token>` from `SecureStore` when present  
2. **401** — clears stored token (no refresh-token rotation implemented)  
3. **Errors** — maps `DioException` → typed exceptions:

| HTTP / condition | Exception |
|------------------|-----------|
| Timeout | `TimeoutException` |
| 400 | `BadRequestException` (Laravel `errors` flattened when present) |
| 401 / 403 | `AuthException` |
| 404 | `NotFoundException` |
| 5xx | `ServerException` |
| No connection | `NetworkException` |
| Other | `GeneralException` |

4. **Logging** — request/response verbose logging in client (debug interceptor exists but may be commented)

Repositories catch these exceptions and return `Left(Failure)`.

---

## Standard response envelope

```json
{
  "success": true,
  "message": "...",
  "data": { }
}
```

Parse with `BaseResponse` / `BaseResponseModel` and the feature’s data model. Always check `success` before using `data`.

Pattern:

```dart
final base = BaseResponse.fromJson(
  responseData,
  (json) => MyModel.fromJson(json as DataMap),
);
if (!base.success) throw ServerException(base.message);
if (base.data == null) throw ServerException('Data not received');
return base.data!;
```

---

## Endpoint map (actively used)

Paths are relative to the API base unless noted. Prefer constants from `ApiConstants`; some datasources still hardcode paths (noted).

### Auth

| Method | Path | Notes |
|--------|------|--------|
| POST | `/auth/send-otp` | Returns guest token context |
| POST | `/auth/verify-otp` | Access token + user |
| GET | `/auth/profile` | |
| POST | `/auth/update-profile` | |

### Home / express dashboard

| Method | Path |
|--------|------|
| GET | `/dashboard` |
| GET | `/express-30/dashboard` |
| POST | `/express-30/products` | Form: category_id, lat, lng |

### Catalog / product

| Method | Path |
|--------|------|
| GET | `/ecommerce/categories` |
| GET | `/ecommerce/products` | Query filters / pagination |
| GET | `/ecommerce/products/:id` | |
| POST | `/ecommerce/products/:id/check-delivery` | |
| GET | `/products/search` | |
| GET | `/products/:id` | Legacy detail path may still appear |
| GET | `/product/recent-searches` | |
| GET | `/product/recent-views` | |

### Cart

| Method | Path |
|--------|------|
| GET | `/cart/cart` |
| POST | `/cart/add` |
| POST | `/cart/update` |
| POST/DELETE | `/cart/item/:id` | remove |
| DELETE | `/cart/clear` |

Guest cart uses a guest token stored in SecureStore and sent per backend contract.

### Wishlist

| Method | Path | Notes |
|--------|------|--------|
| GET | `/wishlist` | Often hardcoded in DS |
| POST | `/wishlist/add` | |
| DELETE/POST | `/wishlist/remove/:id` | |

### Address

| Method | Path |
|--------|------|
| GET | `/address/addresses` |
| POST | `/address/add` |
| PUT | `/address/:id` |
| POST | delete path per DS (`/address/user/addresses/delete` constant exists) |
| PUT | `/address/:id/default` |

### Checkout / orders

| Method | Path |
|--------|------|
| POST | `/order/place` |
| GET | `/order/orders` |
| GET | `/order/orders/:id` |
| POST | `/order/orders/:id/cancel` |
| GET | `/order/orders/:id/delivery-location` | Quick delivery |
| POST | `/return/customer/create` |
| POST | `/return/customer/upload-media` |
| GET | `{origin}/orders/:orderNumber/invoice/file` | **Outside** `/api`, Bearer required |

### Payment

| Method | Path |
|--------|------|
| POST | `/payments/create` | Razorpay order + **public key** |
| POST | `/payments/verify` | Signature verification |
| GET | `/payments/history` | |

### Wallet & bank

| Method | Path |
|--------|------|
| GET/POST | `/wallet` |
| GET/POST | `/bank-detail` |

### Profile extras

| Method | Path |
|--------|------|
| POST | `/delivery-boy/join-request` |
| POST | `/vendor/register` |
| POST | `/development-request` |
| POST | `/request-callback` |

### Home services

| Method | Path |
|--------|------|
| GET | `/service/services` |
| GET/POST | courier partners / quote / bookings |
| POST | `/service/electrician/bookings` |
| POST | `/service/plumber/bookings` |
| POST | `/service/salon/bookings` |
| GET | `/service/service-orders` |
| POST | `/service/service-inquiry` |

---

## Pricing & fees (current model)

Effective pricing: the **Taksh charge** is added per piece on top of the
vendor's selling price, and delivery is no longer charged.

- `sell_price` — vendor share. **Never display** as the price.
- `price` / `final_sell_price` — what the customer pays (includes the per-piece Taksh charge). Display this.
- `delivery_charge.price` — always `0` now.
- `charges[]` — dynamic list of fee lines (e.g. `platform`, `quick_delivery`). Loop and render each `label` + `amount`; an **empty array is normal** when fees are switched off.
- Cart total to charge the customer: `total_with_delivery` (items + fees; no delivery inside).

Orders now store their own money fields instead of relying on recalculated product prices:

| Field | Meaning |
|-------|---------|
| `items_total` | Products only, charge excluded |
| `taksh_charge_total` | Taksh charge for every piece |
| `platform_fee` | Once per order, `0` when off |
| `quick_delivery_fee` | 30-minute orders only |
| `discount_total` | Coupon discount (positive number) |
| `grand_total` | What the customer paid — use this as the amount paid |
| `refund_transactions` | Wallet credits given back for this order |

Refunds are wallet credits by default (`POST /api/refunds` is called by the
server; the app does **not** send an `amount` for a full refund).

`GET /api/app-charges` (no login) returns `{ platform_fee, quick_delivery_fee }`
for a pre-cart summary screen. **Optional** — not yet wired in the app.

---

## Constants present but not full features

These remain in `ApiConstants` for historical or future use — **no complete feature module**:

- Restaurant / menu endpoints  
- Favorites (restaurant-era)  
- Notifications  
- Location geocode search (device geocoding often used instead)  
- Password login/register/refresh-token style auth  

When implementing, wire datasources first, then remove “dead” labeling here.

---

## Error handling stack

```
Datasource throws AppException
        ↓
Repository catches → Left(Failure)
        ↓
Use case returns Either
        ↓
Bloc/Cubit fold → Error state / toast
```

Never surface raw Dio errors in UI; use `failure.message`.

---

## Connectivity

`NetworkInfo` (`connectivity_plus`) is used in repositories before remote calls. Offline-capable features (e.g. address Hive cache) fall back to local data when disconnected.

---

## WebSocket (related real-time)

Not REST, but part of network story:

- Stack: `lib/core/websocket/` — config, service, manager, `LiveFeedCubit`
- Intended consumer: live order tracking  
- **Status:** infrastructure present; `LiveOrderTrackingCubit` is **not** fully DI-wired with a production WS URL  

See [features/ORDERS.md](features/ORDERS.md).

---

## Adding an endpoint

1. Add path helper to `ApiConstants`.  
2. Implement datasource method using `ApiClient` + `BaseResponse`.  
3. Map model → entity in repository; convert exceptions → failures.  
4. Expose via use case.  
5. Update this document and the feature doc.  
6. Run `build_runner` if new `@JsonSerializable` models were added.
