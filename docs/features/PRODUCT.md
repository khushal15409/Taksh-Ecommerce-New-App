# Feature: Product & Catalog Data

**Path:** `lib/features/product/`  
**In-tree doc:** [EXPRESS_PRODUCTS_README.md](../../lib/features/product/EXPRESS_PRODUCTS_README.md)  
**UI consumers:** categories (presentation-only), search, home, quick_delivery

---

## Purpose

Owns catalog **domain/data**: categories, product lists, ecommerce product details, search backend, recent views/searches, delivery availability check, express products by lat/lng.

---

## State management

| Class | Role |
|-------|------|
| `ProductCubit` | Categories, lists, details, pagination |
| `DeliveryCheckCubit` | Pincode/location delivery check on PDP |
| `SimilarProductsCubit` | Related products |
| `SearchCubit` | Registered with product DI; UI in `features/search` |

---

## Key endpoints

| Path | Notes |
|------|--------|
| `GET /ecommerce/categories` | |
| `GET /ecommerce/products` | Filters + pagination |
| `GET /ecommerce/products/:id` | PDP |
| `POST /ecommerce/products/:id/check-delivery` | |
| `GET /products/search` | |
| `POST /express-30/products` | Form: category_id, latitude, longitude |
| `GET /product/recent-searches` | |
| `GET /product/recent-views` | |

Express products return fulfillment center + paginated products — details in EXPRESS_PRODUCTS_README.

---

## Entities (high level)

Product, Category, Brand, images, variants/attributes, rating/review/QA structures, `PaginatedProducts`, `DeliveryAvailability`, `ExpressProductsResponse`, `FulfillmentCenter`, search/recent types.

Models use `json_serializable` → run `build_runner` after changes.

---

## Pages

- `ProductDetailsPage` — route provides ProductCubit + cart + wishlist when needed after auth redirect

Categories UI lives under `features/categories/` but calls into this feature’s cubits/use cases.

---

## When updating

1. Prefer ecommerce paths over legacy `/products/:id` unless API still requires both.  
2. Keep express flow location-driven (address lat/lng).  
3. Register new use cases in injector product section.  
4. Update EXPRESS_PRODUCTS_README if express contract changes.
