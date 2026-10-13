# Routing Guide

Navigation uses **go_router** with a **ShellRoute** for the bottom bar and a central redirect for auth.

| File | Role |
|------|------|
| `lib/core/routing/app_routes.dart` | Path constants + path builders |
| `lib/core/routing/app_router.dart` | `GoRouter` config, guards, page builders |

---

## Mental model

```
/splash ──► /onboarding? ──► /home (guest OK)
                │
                ├── login required routes ──► /login?redirectAfter=...
                │                              └── after auth: navigateAfterAuth
                │
                └── shell tabs: home | categories | cart | orders | profile
                      cart/orders/profile: GuestAuthWall in-page (no redirect)
```

---

## Shell tabs (bottom navigation)

| Path | Page | Guest behavior |
|------|------|----------------|
| `/home` | `HomePage` | Allowed |
| `/categories` | `CategoriesPage` | Allowed |
| `/cart` | `CartPage` | `GuestAuthWall` (in-page) |
| `/orders` | `OrdersPage` | `GuestAuthWall` (in-page) |
| `/profile` | `ProfilePage` | `GuestAuthWall` (in-page) |

Query helpers:

- Home delivery mode: `AppRoutes.homeWithDelivery('standard'|'quick'|'services')` → `/home?delivery=...`
- Categories: `AppRoutes.categoriesToCategory(id, subcategoryId:, deliveryType:)`

`MainShell` hosts the bottom nav and provides shared cubits/blocs used by tabs.

---

## Auth strategy (two layers)

### 1. Router redirect (`_authRequiredRoutes`)

If the user is **not** authenticated and navigates to a guarded path, router redirects to:

```
/login?redirectAfter=<encoded original location>
```

Guarded prefixes/paths include (see `_authRequiredRoutes` in `app_router.dart`):

- `/addresses`, `/addresses/add`
- `/checkout`, `/checkout/select-items`
- `/quick-delivery` (prefix)

### 2. In-page `GuestAuthWall`

Used on shell tabs where guests may open the tab but cannot use the content until login. Avoids yanking users off the shell for browse-adjacent tabs.

Widget: `lib/core/widgets/guest_auth_wall.dart`

### After successful login

`AppRouter.navigateAfterAuth`:

- Always lands on home shell first when needed
- Then `push`es non-shell destinations from `redirectAfter`
- Ensures product details still get `ProductCubit` / cart / wishlist providers when the stack replaces the shell

---

## Route inventory

### Auth & startup

| Constant | Path | Page |
|----------|------|------|
| `splash` | `/splash` | SplashPage |
| `onboarding` | `/onboarding` | OnboardingPage |
| `login` | `/login` | LoginPage |
| `verifyOtp` | `/verify-otp` | VerifyOtpPage |
| `register` | `/register` | Placeholder |
| `forgotPassword` | `/forgot-password` | Placeholder |

### Catalog & product

| Constant | Path | Page |
|----------|------|------|
| `search` | `/search` | SearchPage |
| product details | `/products/:id` (see `AppRoutes`) | ProductDetailsPage |
| view-all / express products | helpers in `AppRoutes` | ViewAll / ExpressProductsPage |

### Cart & checkout

| Constant | Path | Page |
|----------|------|------|
| `cart` | `/cart` | CartPage |
| `checkoutSelectItems` | `/checkout/select-items` | SelectItemsPage |
| `checkout` | `/checkout` | CheckoutPage |
| `orderReview` | `/checkout/review` | OrderReviewPage |
| `orderPlaced` | `/order/placed?...` | OrderPlacedPage |

### Orders & tracking

| Constant | Path | Page |
|----------|------|------|
| `orders` | `/orders` | OrdersPage |
| `orderDetailsPath` | `/orders/:id` | OrderDetailsPage |
| `quickDeliveryTrackingPath` | `/quick-delivery/:id` | QuickDeliveryTrackingPage |

### Payment results

| Path | Page |
|------|------|
| payment success | PaymentSuccessPage |
| payment failed | PaymentFailedPage |

### Addresses & wishlist

| Constant | Path | Page |
|----------|------|------|
| addresses list / add | `/addresses`, `/addresses/add` | AddressListPage, AddAddressPage |
| wishlist | `/wishlist` (see AppRoutes) | WishlistPage |
| notifications | `/profile/notifications` | NotificationsPage (static data, UI only) |
| notification-detail | `/profile/notifications/detail` | NotificationDetailPage (`extra`: AppNotification) |

### Placeholders still in `app_router.dart`

These exist as simple scaffold pages for future work — **not full features**:

- Register, ForgotPassword, EditProfile, ChangePassword, Settings  
- Favorites, Notifications  
- RestaurantDetails  
- NotFound, NoInternet  

---

## Navigation patterns

```dart
// Go (replaces stack segment per go_router rules)
context.go(AppRoutes.home);
context.go(AppRoutes.homeWithDelivery('quick'));

// Push
context.push(AppRoutes.productDetails(id)); // use helper from AppRoutes

// Back
context.pop();

// Parameterized
context.go(AppRoutes.orderDetails(orderId));
context.go(AppRoutes.quickDeliveryTracking(
  orderId,
  customerLat: lat,
  customerLng: lng,
  orderNumber: number,
));

// Order placed
context.go(AppRoutes.orderPlacedPath(
  orderId: id,
  orderNumber: number,
  paymentMethod: 'cod', // or online
));
```

Always prefer `AppRoutes` helpers over string concatenation so query keys stay consistent (`delivery`, `redirectAfter`, etc.).

---

## Adding a new route

1. Add constant + helper in `app_routes.dart`.  
2. Add `GoRoute` in `app_router.dart` (inside or outside shell as appropriate).  
3. If login required, add path to `_authRequiredRoutes` **or** wrap page with `GuestAuthWall`.  
4. Provide any factory BLoC/Cubit in the route’s `builder` / `pageBuilder` via `BlocProvider` + `getIt`.  
5. Document in this file and [FEATURES.md](FEATURES.md).  
6. Add l10n strings for the new screen title/copy.

---

## Deep linking & query params

Common query keys:

| Key | Used by |
|-----|---------|
| `delivery` | Home, categories |
| `categoryId` / `subcategoryId` | Categories |
| `redirectAfter` | Login return path |
| `orderId` / `orderNumber` / `paymentMethod` | Order placed |
| `customerLat` / `customerLng` | Quick delivery map |

---

## Related

- Auth flow: [features/AUTH.md](features/AUTH.md)  
- Checkout flow: [features/CHECKOUT.md](features/CHECKOUT.md)  
- DI for route-scoped blocs: [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md)
