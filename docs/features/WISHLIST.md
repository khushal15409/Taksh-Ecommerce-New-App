# Feature: Wishlist

**Path:** `lib/features/wishlist/`  
**State:** `WishlistCubit` — **`registerLazySingleton`**

---

## Purpose

Save / unsave products; shared state so PDP hearts and wishlist page stay consistent.

---

## API

Common paths (may be hardcoded in datasource — align with constants when editing):

- `GET /wishlist`  
- `POST /wishlist/add`  
- `… /wishlist/remove/:id`  

---

## UI

- `WishlistPage`  
- Toggle widgets on product cards / PDP using the singleton cubit  

Shell typically calls `fetchWishlist()` on enter.

---

## When updating

- Keep singleton semantics (no second instance).  
- Optimistic UI optional; always reconcile with server result via fold.  
- Guest behavior: if API requires auth, gate with GuestAuthWall or disable heart with login prompt.
