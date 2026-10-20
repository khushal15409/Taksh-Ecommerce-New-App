# Quick Delivery: End-to-End Flow Review (App + Admin API)

**Date:** 2026-10-15
**Scope:** Flutter app (`taksh_e_commerce`) and Laravel admin/API (`taksh-admin`)
**Method:** Static code reading only. Nothing was run or changed. Every finding below should be reproduced before it is fixed.

Naming used in both codebases: Quick = `30_min` = `express_30` = `is_express_30`. Standard = `normal`.

---

## 1. Summary

**How it works today:** Admin marks a product as Quick (`products.is_express_30`) and gives it stock in `vendor_products`. The app sends the selected address coordinates. The server decides serviceability (approved vendor within 10 km) and returns a Quick dashboard and category products. The user adds to a Quick cart bucket, checks out through `/cart/quote` then `/order/place`, and pays by COD or Razorpay. The order is auto-assigned to a vendor rider, who delivers it. The app tracks the rider by polling.

**Most important findings (fix first):**

| # | Where | Problem |
|---|-------|---------|
| 1 | Backend | COD Quick orders reserve stock but never commit it. `reserved_qty` leaks forever on delivered COD orders. |
| 2 | Backend | Rider delivery completion skips the customer OTP check (commented out). |
| 3 | Backend | Generic rider API has the `delivery_man_id` ownership filter commented out in about 30 places. Any rider can touch any express order. |
| 4 | Backend | A rider can overwrite the COD payment amount at cash collection. |
| 5 | Backend | Old warehouse-based endpoints are still routed and use a different stock table. Orders from them never get a rider. |
| 6 | Backend | Auto-assigned orders stay `pending`/`confirmed`, but the rider app only lists `ready_for_pickup/assigned/...`. The rider may never see them. |
| 7 | App | "View all" from a Standard section adds items to the Quick cart. |
| 8 | App | Checkout lets the user switch Standard/Quick. Totals and the order can come from a different bucket than the items shown. |
| 9 | App | Rider location is never drawn on the tracking map. |
| 10 | App | Quick category listing stops after the first 30 products. |

---

## 2. Flow, step by step

### 2.1 Listing (admin)
- Flag: `products.is_express_30` (boolean, indexed). Set in the admin create/edit form and via the vendor API (`Admin/ProductController`, `Api/Vendor/VendorProductController`).
- Every product has exactly one `vendor_id`. Stock lives in `vendor_products` (`stock_qty`, `reserved_qty`), unique per vendor and variant. Available stock = `stock_qty - reserved_qty`.
- Admin-created products are auto-approved. Vendor-created products start inactive and go through approval.
- Quick eligibility (`Express30Controller::scopeQuickEligible`): active, approved, `is_express_30`, vendor within range, and at least one active variant with available stock.
- There is no per-pincode or dark-store stock. Serviceability is tied to the vendor's shop location.

### 2.2 Serviceability
- `QuickServiceability`: vendor must be approved, have shop lat/lng, and be within 10 km (hardcoded `RADIUS_KM`). Haversine is done in PHP.
- The client never decides. The app only reads `serviceable`, `quick_not_serviceable`, `quick_location_required`.
- Not modelled: vendor open/closed hours, paused shop, rider availability.

### 2.3 App browsing
- **Home Quick tab:** guest is sent to login. Address sheet always shows. Location is resolved by `resolveQuickLocation` (selected address, then first saved address with valid coordinates, then GPS). Invalid coordinates never fall back to made-up values. Calls `GET /express-30/dashboard`.
- **Categories (Quick):** `POST /express-30/products` with `category_id`, lat, lng, `page_number`. Category list comes from `/ecommerce/categories?delivery_type=express_30`.
- **Search:** `/products/search?delivery_type=30_min`. Not location aware.
- **Product details:** `/ecommerce/products/:id`. Not location aware.

### 2.4 Cart
- Server: one cart per user, split into two buckets by the product's `is_express_30`. One vendor per bucket. Stock is checked on add and on quantity increase. Nothing is reserved in the cart.
- App: `CartCubit` (lazy singleton) holds both buckets and emits one merged cart. Widgets must filter with `CartCubit.matchesDeliveryType`. Cart page has Quick and Standard tabs. Each tab checks out separately.

### 2.5 Checkout and order
1. App calls `GET /cart/quote?delivery_type=30_min&address_id=` and blocks Quick checkout if the quote is missing or not serviceable.
2. App calls `POST /order/place` with only `address_id`, `delivery_type`, `payment_method` (`cod` or `online`). Prices are always recalculated on the server.
3. Server, in one transaction: locks cart, takes the matching bucket, checks single approved vendor, checks 10 km, locks `vendor_products`, checks stock, reserves stock, builds charges (platform fee, Quick fee, coupon), creates order, payment row and items, clears those cart lines.
4. COD: tries rider assignment immediately. Online: app calls `/payments/create`, opens Razorpay, then `/payments/verify`. `markPaid` is idempotent and shared with the webhook. It confirms the order, commits stock, then tries rider assignment.
5. App navigation after success: online Quick goes to tracking. COD goes to `/order/placed`.
6. No wallet payment and no delivery slots in the Quick flow.

### 2.6 Fulfilment
- Auto-assign (`QuickOrderDispatch`): least-loaded online approved rider of the same vendor, under `max_active_orders`. If none, the order stays unassigned for admin.
- Admin can assign from the Quick orders screen or the general order screen. Riders use `/api/delivery/quick/*` for pickup, OTP delivery, cash collection, cancel and return.
- Rider location: `POST /api/delivery/location/update`, broadcast on `private-order.{id}`. Customer app polls `GET /order/orders/:id/delivery-location` every 8 s.
- The Observer pays vendor/center earnings and wallet rewards on status changes.

### 2.7 Cancel, refund, expiry
- Customer cancel is allowed in `pending`/`confirmed`. It releases stock and coupon usage. Refund is automatic only if `RAZORPAY_REFUND_ON_CANCEL` is true.
- `ExpireUnpaidOrders` runs every 5 minutes but does nothing unless `UNPAID_ORDER_EXPIRY_MINUTES` is set. COD is never expired.

---

## 3. Backend (taksh-admin) findings

### High
- **B-H1: COD stock never committed.** `OrderStockService::commit` is only called from online `markPaid` (`app/Services/PaymentSettlementService.php:91`). COD orders reserve at `Api/OrderController.php:248` and nothing converts it on delivery or cash collection. `stock_qty` stays wrong and `reserved_qty` leaks after delivery.
- **B-H2: OTP bypass on delivery.** The OTP-verified check is commented out in `deliverToCustomerUploadImages` (`QuickDeliveryOrderController.php:1738-1740`).
- **B-H3: Rider IDOR.** In `DeliveryManController.php` the `->where('delivery_man_id', ...)` scope is commented out at about 30 places (for example `updateStatus` :1573, `orderDetails` :1646, `deliver` :2067, and :2167, :2278, :2410, :2557). Any logged-in rider can read or complete any express order.
- **B-H4: COD amount overwrite.** `collectCodCash` lets the rider pass an `amount` that replaces `payments.amount` with no check against `grand_total`, and with no status restriction (`QuickDeliveryOrderController.php:1856-1870`).
- **B-H5: Legacy endpoints still live.** `POST /orders/express-30` and `POST /express-30/order` use `warehouse_products` and fulfillment centers, a 5 km default radius, no cart, no coupons, no vendor check. Orders have no `vendor_id`, so no rider is ever auto-assigned (`ExpressOrderController.php:107-125, 279-281`). The app uses `/order/place`, so these should be disabled or removed.

### Medium
- **B-M1: Rider cannot see auto-assigned orders.** Rider list shows `courier_assigned, ready_for_pickup, assigned, out_for_delivery, assigned_to_delivery` (`QuickDeliveryOrderController.php:68-76`). Auto-assign leaves `pending`/`confirmed` (`QuickOrderDispatch.php:61-69`). Only the generic `acceptOrder` or the logistic panel moves it forward. The quick API has no endpoint for `out_for_delivery`.
- **B-M2: Rider load miscount and race.** `activeOrders()` ignores `pending`, `assigned`, `out_for_pickup` (`DeliveryMan.php:137-141`) and assignment is not locked, so one rider can get many orders.
- **B-M3: No ETA/SLA on `/order/place` orders.** `estimated_delivery_time`, `sla_minutes`, `confirmed_at` are not set (`Api/OrderController.php:285-293`). Admin deadline column shows N/A and SLA never breaches.
- **B-M4: Admin list mix-up.** `Admin/OrderController.php:67, 93, 188` exclude only `express_30`, so `30_min` orders show up in the standard lists.
- **B-M5: Weak admin `assignDeliveryMan`** (`Admin/OrderController.php:586-677`): no status check, rider need not be approved, online or same vendor, and it overwrites `order_type`.
- **B-M6: Cancel ignores rider.** Cancelling an assigned order does not clear `delivery_man_id` or notify anyone.
- **B-M7: Price mismatch risk.** Listing uses `PricingService::finalPrice`, cart and checkout use `calculateCheckoutPrice`, and product detail applies a campaign sale price that checkout ignores.
- **B-M8: No notifications.** No push, FCM or order-status notification exists in the order, payment or rider flows. New Quick orders do not notify rider, vendor or customer. Broadcast default is `reverb`, `.env.example` has `BROADCAST_DRIVER=log`. Check production `.env`.
- **B-M9: Unpaid expiry is off by default**, so unpaid online Quick orders hold stock indefinitely.
- **B-M10: Hardcoded 10 km, no shop hours, no check that any rider exists.** A customer can order and nobody delivers.
- **B-M11: Admin validation.** `is_express_30` is validated as boolean but saved with `$request->has(...)`, so a "0" value counts as true (`Admin/ProductController.php:579`). `flagToggle` does not validate `value` (:1183).

### Low
- Dead code: `Express30CategoryController` (unrouted) and about 15 old FC-era methods in `Express30Controller`.
- Response key `fulfillment_center` actually holds the vendor.
- Hardcoded: stock display cap 20, page size 30, 100 m "nearby" radius.
- Rider quick endpoints do not enforce status preconditions. Location update does not check the order is active, and treats distance 0 as null (:132, :140).
- Per-rider count queries and loading all of a rider's orders to sum amounts.
- `delivery_types.price` (50) for `30_min` is not used in totals. The real Quick fee comes from App Charges settings.

---

## 4. App (taksh_e_commerce) findings

### High
- **A-H1: "View all" is always Quick.** `ProductCard.showDeliveryTime` defaults to true (`home/presentation/widgets/product_card.dart:35`) and doubles as the cart bucket. `ViewAllProductsPage` (`view_all_products_page.dart:221-231`) and `ViewAllProductsArgs` carry no delivery type, so Standard "View all" adds to the Quick bucket.
- **A-H2: Bucket depends on entry point.** Cards use the listing mode. Product details and Buy Now use `product.isExpress30` (default false) (`product_details_page.dart:446-467, 746-748`). The same product can land in different buckets.
- **A-H3: Rider never shown on map.** `quick_delivery_tracking_page.dart` only builds the customer marker. `riderLocation` is used only for a text label.
- **A-H4: Checkout bucket switching.** Both delivery options are always available (`checkout_bloc.dart:287-293`). Switching re-fetches the other bucket's totals and places that bucket's order, while the item list shown still comes from the original bucket. Item selection is not sent to `/order/place`, so the whole server bucket is ordered.

### Medium
- **A-M1: Quick category listing is one page (30 items).** `categories_page.dart:104` returns early for Quick and `limit` is not sent.
- **A-M2: N+1 stock lookups.** Each Quick card without stock info calls `getProducts(search: name, limit: 20)` on init (`product_add_to_cart_button.dart:285-300, 387-450`). The product is found only if it is in the first 20 search hits.
- **A-M3: Home state lost.** Category and See All use `context.go`, which destroys HomePage state. Bottom-nav Home goes back to Standard.
- **A-M4: Categories Quick address** is stored locally only, not in `AddressBloc`. Re-picking an address may not refetch. Quick categories there are not location aware, home ones are, so lists can differ.
- **A-M5: Deep link `/categories?delivery=quick` and `/express-products` are not auth gated** for guests.
- **A-M6: Tracking polling.** Does not stop on terminal status, no overlap guard, camera resets on every emit, back button is trapped to `/home`.
- **A-M7: Tracking hard to reach.** COD Quick orders and pay-now retries go to `/order/placed`. No button in orders list or details opens tracking.
- **A-M8: Static item lists in checkout datasources** (`checkout_remote_datasource_impl.dart:31-37`). Two live checkouts or stale state would mix items.
- **A-M9: Order details.** Unknown Quick statuses map to timeline rank 0. Cancel is offered up to `out_for_delivery`. No auto refresh. No WebSocket is wired.
- **A-M10: Cart tab forcing.** The cart page auto-switches away from an empty tab (`cart_page.dart:69-94`).

### Low
- Placeholders `warehouseId: 1`, `vendorId: '8'` in code and logs (not sent by `toFormData`).
- Hard-coded "Delivery charges: Free", "In stock" badge, and English strings on the tracking page and Order Summary. Violates the ARB-only rule.
- Increment paths do not check `availableStock` (server rejects, toast shown).
- `debugPrint`/`print` in production paths (`categories_page.dart`, `product_cubit.dart`, `product_add_to_cart_button.dart:1027-1035`, `app_router.dart:512`).
- Mock mode fakes only auth, address, express dashboard, checkout and payment. Cart, products, search and orders still hit the real API, and no serviceability case can be tested in mock mode.
- Dead code: `ExpressProductsPage`/`ExpressProductsCubit` and `/express-products` route, `checkout_page.dart.backup`, legacy `CreateOrderEvent` path, unused home section widgets, unused cart conflict constants, `LiveOrderTrackingCubit`. `docs/features/QUICK_DELIVERY.md` is stale.

---

## 5. App and backend contract mismatches

| Topic | App | Backend |
|-------|-----|---------|
| Endpoint | `/order/place` | Legacy `/orders/express-30` also live and different. |
| ETA | Shows no ETA (correct) | Sets no ETA on `/order/place`. Legacy sets 30 min. |
| Categories | `/ecommerce/categories?delivery_type=express_30` (not location aware) | Quick listing filters by `is_express_30`, `categories.delivery_types` not used. |
| Item selection | User selects items in checkout | `/order/place` orders the whole bucket. |
| Notifications | Polls only | Does not push anything. |
| Missing `serviceable` | Dashboard: treated as serviceable. Quote: treated as not serviceable. | Always sends it. (Intentional, keep both defaults.) |

---

## 6. Do-not-break checklist (when fixing anything above)

**App**
1. Never compute serviceability on the client. Keep fail-closed quote behaviour and the intentionally opposite default for dashboard payloads.
2. Never call Quick APIs with invented coordinates. Selected address without valid coordinates returns null.
3. Quick needs login at: home tab, categories tab, `/quick-delivery`, add to cart. Cart page uses `GuestAuthWall`.
4. Keep stale-response guards (`RequestGuard`, `_listRequestId`) and `_lastQuickRequest` / `QuickLocation.key` (prevents reload loops).
5. `CartCubit` is a lazy singleton. Never close it from a `BlocProvider(create:)`. Always filter items with `matchesDeliveryType`. Item `isExpress30` is rewritten from the bucket.
6. `showDeliveryTime` on product cards is the cart bucket. Changing its default changes behaviour (see A-H1).
7. `/order/place` sends only `address_id`, `delivery_type`, `payment_method`. Totals come from `/cart/cart`. Do not add client-calculated amounts or a client platform fee.
8. Payment is trusted only after `/payments/verify`. `OrderReviewPage` shares the same `CheckoutBloc`. Keep `CheckoutError.code` strings (`quick_not_serviceable`, `quick_location_required`).
9. Order Quick detection stays `resolveIsQuickOrder` (`is_quick`, then `delivery_type`, then `is_express`). Keep delivery-location parsing tolerant.

**Backend**
1. Keep the server as the only source of prices, stock and serviceability.
2. Keep row locks (cart, `vendor_products`, order, payment) and idempotent `markPaid`.
3. Keep the one-vendor-per-bucket rule and the bucket mismatch error.
4. When removing legacy endpoints, confirm no old app version still calls them. Check release adoption first.
5. When committing COD stock, make it idempotent so it cannot double count with `release()` on cancel.
6. Order status changes trigger the Observer (earnings, wallet rewards). Test status changes against it.

**Existing tests (app):** `quick_serviceability_test`, `quick_location_test`, `express_dashboard_model_test`, `order_delivery_mode_test`, `quick_checkout_gate_test`. There are none for `CartCubit`, `ExpressDashboardBloc`, `ProductCubit.fetchExpressProducts`, `CheckoutBloc` quote logic or tracking.

---

## 7. Suggested fix order

**Phase 1: money and security (backend)**
B-H3, B-H2, B-H4, B-H1, B-H5.

**Phase 2: flow correctness**
B-M1 (rider visibility), B-M3 (ETA/SLA), B-M4, B-M2, A-H1, A-H2, A-H4.

**Phase 3: customer experience**
A-H3, A-M1, A-M6, A-M7, B-M8 (notifications), A-M9, B-M9.

**Phase 4: cleanup**
Remove dead code, move hard-coded strings to ARB, update `docs/features/QUICK_DELIVERY.md`, add tests for cart, checkout and tracking.

---

## 8. Not examined

Vendor-panel `OrderStepController` (advances Quick orders), `OrderEarning` payouts, `SaleService`, `RefundController`, and the logistic panel database internals. Review these before changing status transitions.

---

## 9. Smart Quick catalogue and location-based availability (2026-10-16)

**Status: code changes are UNVERIFIED.** Backend unit tests ran (pure logic and compiled SQL only). No Flutter/Dart SDK, no PHP database driver and no approved test database were available, so nothing touching the database or the app was executed. See "Tested / not tested" below.

### Rules used (no new flags, radius or capacity rules)
- Catalogue eligibility = existing `products.is_express_30` plus `status = active`, `approval_status = approved`, an **approved vendor** and at least one **active variant** (`QuickAvailability::catalogue`). No new column.
- Orderable here = catalogue rule plus the product's vendor serves the address (`QuickServiceability`, 10 km, unchanged) plus free stock (`stock_qty - reserved_qty > 0`) in the product's **own** vendor row (`QuickAvailability::available`). Another vendor's stock never counts.
- Statuses: `available`, `out_of_stock`, `area_unserviceable`, `location_required`, `vendor_unavailable`, `variant_unavailable`, `product_unavailable`. `vendor_unavailable` is only emitted by the single-product check (vendor not approved); such products are not in the catalogue.

### API contract (all additive; old apps see no change)
| Endpoint | Change |
|----------|--------|
| `GET /express-30/dashboard`, `POST /express-30/products` | New optional `include_unavailable=1`. Without it: unchanged. With it: whole catalogue, orderable products first (then `created_at desc, id desc` on the dashboard; `id` on category listing), each product carries `availability {status, can_order, message}`, `in_stock=false` and the message in `out_of_stock_message` when not orderable. Unserviceable/no-location answers are HTTP 200 with `serviceable:false`, `code`, `message` and the catalogue, instead of 404/empty. Category items get `available_count`; listing gets `availability_summary {available_count,total}`. Free stock of unavailable products is reported as 0. |
| `GET /express-30/products/{id}/availability?address_id=` (or `latitude`/`longitude`) `&variant_id=` | **New**, auth required. Returns `status`, `can_order`, `serviceable`, `code`, `message`. Fails closed (unknown product, bad address/location). |
| `POST /cart/add` | New optional `address_id`: with `delivery_type=30_min` the line is refused (422, `code: quick_item_unavailable`, `availability_status`) when that address cannot order it. Quick products that are no longer approved are refused. Stock failures on Quick products also carry the code. |
| `GET /cart/quote` (30_min) | Also checks every Quick line (approval, vendor, variant, stock vs qty). On failure: `serviceable:false`, `code: quick_item_unavailable`, `unavailable_items[]`. |
| `POST /order/place` (30_min) | Inside the existing transaction, un-approved Quick products and missing/insufficient stock return `code: quick_item_unavailable` (same HTTP status as before). Row locks, idempotency and bucket isolation untouched. |

### Do-not-break notes
- `include_unavailable` is opt-in; the new app sends it for the dashboard and Quick category listing only. Standard endpoints, `CartCubit` and `matchesDeliveryType` were not touched.
- In the app, an unserviceable dashboard with a catalogue is now `ExpressDashboardLoaded` with a notice; with no catalogue (old server) it is still `ExpressDashboardNotServiceable`.
- Product details gate Add to Cart and Buy Now on `QuickProductAvailabilityCubit` (fails closed: idle/checking/failed/unknown never order). The category listing still turns a `serviceable:false` payload into the not-serviceable screen.
- ARB: 10 new `quickAvailability*` / `quickBadge*` / `quickCatalogueFallbackNotice` keys in en and hi; `app_localizations*.dart` were edited by hand (SDK missing) and must be regenerated with `flutter gen-l10n`. Backend messages exist in en, gu, hi (`api.express.availability.*`).

### Tested / not tested
- Run: `vendor/bin/phpunit tests/Unit` (backend; new `QuickAvailabilityTest`: decision table, fail-closed, ordering stability, catalogue/own-vendor-stock SQL shape, messages in 3 languages, route behind auth).
- Written but NOT run (no Dart SDK): `test/core/utils/quick_availability_test.dart`, `test/features/home/product_availability_model_test.dart`, `test/features/home/express_dashboard_catalogue_bloc_test.dart`, `test/features/quick_delivery/quick_product_availability_cubit_test.dart`.
- Not tested at all: dashboard/listing/availability endpoints and cart/quote/order against a database (pagination with the availability ordering, category counts, stock changing after load, Quick/Standard cart isolation, Standard checkout regression), the new product-details UI, build_runner output for the new `availability` JSON key.

### Remaining risks / next steps
1. Run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze`, `flutter test`.
2. On an approved test database: seed two vendors (one in range, one out) and check ordering, pagination across pages, counts, and the add / quote / place rejections after stock is lowered.
3. The cart "add" call from the app does not send `address_id` yet (the order and quote still enforce the area); wire it through `CartCubit` later if add-time area refusal is wanted.
4. Unavailable products are all pushed behind orderable ones per query, so on a big catalogue the unavailable part is reached only on later pages; category listing paging is still one page in the app (A-M1).
5. Vendor opening hours, paused shops and rider capacity remain unmodelled.
