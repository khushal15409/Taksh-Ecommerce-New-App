# Feature: Cart

**Path:** `lib/features/cart/`  
**State:** `CartCubit` — **`registerLazySingleton`** (shared app-wide)

---

## Purpose

Server-backed shopping cart with:

- Guest cart token support  
- Dual carts for **standard** vs **express** (`30_min` / `express_30` style delivery types)  
- Variant selection before add  
- Clear / update / remove line items  

---

## Layers

```
domain/     Cart, CartItem, ExtraCharge, CartRepository, use cases
data/       models, remote DS, repository impl
presentation/
  cubit/    CartCubit
  pages/    CartPage
  widgets/  AddToCartButton, ProductAddToCartButton, VariantSelectionBottomSheet
  services/ VariantCacheService
```

---

## API

| Method | Path |
|--------|------|
| GET | `/cart/cart` |
| POST | `/cart/add` |
| POST | `/cart/update` |
| … | `/cart/item/:id` remove |
| DELETE | `/cart/clear` |

Some paths may be hardcoded in the datasource — keep in sync with `ApiConstants` when touching cart DS.

---

## Guest behavior

1. Unauthenticated users can still have a **guest token** stored in SecureStore / prefs.  
2. Cart API calls attach guest identity per backend contract.  
3. On OTP verify, guest token is passed so backend can **merge** cart.  
4. `CartPage` uses **GuestAuthWall** for full cart UX when policy requires login (confirm current page behavior when changing guest rules).

---

## CartCubit responsibilities

- `fetchAllCarts()` — load standard + express carts (called from shell)  
- add / update qty / remove / clear  
- Expose counts for badges  
- Persist/refresh guest token lifecycle  

Because it is a singleton, never `BlocProvider(create: getIt<CartCubit>())` in a way that confuses ownership — provide the **same** instance from shell/root.

---

## Variants

Add-to-cart from PDP often opens `VariantSelectionBottomSheet`. `VariantCacheService` reduces repeated variant lookups.

---

## Pricing display (current state)

The cart bill is now built from the server response, not hardcoded rows:

- Item price shown is `price` / `final_sell_price` (never `sell_price`).
- `charges[]` is looped and rendered per `label` + `amount`; an **empty array**
  is normal while fees are switched off (no packaging/other/platform rows).
- Delivery is rendered as **Free** and never added to the total.
- The amount to charge is `total_with_delivery` (items + fees).

See [NETWORK_AND_API.md](../NETWORK_AND_API.md) for the money-field map.

---

## When updating

- Preserve dual-cart model when adding delivery types.  
- Keep guest merge path intact when changing auth verify payload.  
- After structural cart model changes, regenerate `.g.dart` and update checkout selected-items mapping.  
- Document endpoint path changes here and in NETWORK_AND_API.
