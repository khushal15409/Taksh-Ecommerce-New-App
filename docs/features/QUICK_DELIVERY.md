# Feature: Quick Delivery

**Path:** `lib/features/quick_delivery/`  
**DI:** `di/quick_delivery_di.dart`  
**Auth:** `/quick-delivery` prefix requires login (router)

---

## Purpose

1. **Live/map tracking** of an express order’s delivery location  
2. **Express products page** for category browsing against nearest FC (uses `GetExpressProducts` from product feature)

---

## State

| Class | Role |
|-------|------|
| `QuickDeliveryTrackingCubit` | Poll/fetch delivery location; map markers |
| `ExpressProductsCubit` | Express category product list |

DI also registers `GetExpressProducts` for reuse (including `ProductCubit` paths).

---

## API

| Path | Role |
|------|------|
| `GET /order/orders/:id/delivery-location` | Courier/order location for map |
| `POST /express-30/products` | Via product use case |

Route builder: `AppRoutes.quickDeliveryTracking(id, customerLat:, customerLng:, orderNumber:)`

---

## Pages

- `QuickDeliveryTrackingPage`  
- `ExpressProductsPage`  

---

## Relation to WebSocket live tracking

Map tracking here is **HTTP location endpoint** driven. Separate WS-based `LiveOrderTrackingCubit` under orders is not the same pipeline — see [ORDERS.md](ORDERS.md).

---

## When updating

- Map performance: throttle polls; handle permission denials.  
- Keep customer lat/lng query params optional with sensible camera defaults.  
- Express empty FC product list is valid — show empty state, not error.
