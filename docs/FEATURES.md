# Feature Catalog

Inventory of every module under `lib/features/` as implemented today.

Legend:

| Column | Meaning |
|--------|---------|
| Layers | `D` domain · `A` data · `P` presentation · `DI` feature di module |
| SM | Primary state management class(es) |

---

## Summary table

| Feature | Layers | SM | Primary pages | Notes |
|---------|--------|-----|---------------|-------|
| [auth](#auth) | D A P | `AuthBloc` | Login, Verify OTP | Guest token on send OTP |
| [splash](#splash) | P | `SplashCubit` ★ | SplashPage | Locale + theme + location |
| [onboarding](#onboarding) | P | — | OnboardingPage | First-launch carousel |
| [home](#home) | D A P | `DashboardBloc`, `ExpressDashboardBloc`, `RecentViewsCubit` | HomePage, MainShell, ViewAll | Delivery tabs |
| [categories](#categories) | P | uses `ProductCubit` | CategoriesPage | No own domain |
| [product](#product) | D A P | `ProductCubit`, `DeliveryCheckCubit`, `SimilarProductsCubit` | ProductDetailsPage | Express products API |
| [search](#search) | P | `SearchCubit` | SearchPage | Uses product use cases |
| [cart](#cart) | D A P | `CartCubit` ★ | CartPage | Dual carts + guest token |
| [wishlist](#wishlist) | D A P | `WishlistCubit` ★ | WishlistPage | |
| [address](#address) | D A P DI | `AddressBloc`, `MapCubit` | List, Add, MapPicker | Hive cache |
| [checkout](#checkout) | D A P DI | `CheckoutBloc` | Select items, Checkout, Order placed | COD + Razorpay |
| [payment](#payment) | D A P DI | `PaymentBloc` (legacy path) | Success, Failed | Canonical pay via CheckoutBloc |
| [orders](#orders) | D A P DI | `OrdersCubit` | Orders, Detail, Return | Invoice download |
| [quick_delivery](#quick_delivery) | D A P DI | `QuickDeliveryTrackingCubit`, `ExpressProductsCubit` | Tracking, Express products | Auth required |
| [home_service](#home_service) | D A P DI | `HomeServiceCubit` | Courier/General service pages | Services tab |
| [wallet](#wallet) | D A P DI | `WalletCubit` | WalletPage | Withdrawal |
| [profile](#profile) | D A P | Multiple BLoCs | Profile hub + forms | Guest wall |

★ = registered `registerLazySingleton` (app-wide shared instance)

Deep-dives live under [docs/features/](features/).

---

## auth

| | |
|--|--|
| Path | `lib/features/auth/` |
| Purpose | Phone OTP login, session restore, profile fetch/update, logout |
| Entities | `User`, credentials / update-profile params |
| Endpoints | `POST /auth/send-otp`, `POST /auth/verify-otp`, `GET /auth/profile`, `POST /auth/update-profile` |
| SM | `AuthBloc` — events: check, send OTP, verify OTP, logout, get/update/fetch profile |
| Pages | `LoginPage`, `VerifyOtpPage` |
| Mock | `AuthMockDataSource` when `useMockData` |
| Special | Guest cart token passed through verify; root provider; logout resets addresses |

→ [features/AUTH.md](features/AUTH.md) · [MOCK_AUTH_GUIDE.md](MOCK_AUTH_GUIDE.md)

---

## splash

| | |
|--|--|
| Path | `lib/features/splash/` |
| Purpose | Startup UX; holds **locale** and **themeMode** for whole app; location permission helpers |
| SM | `SplashCubit` singleton |
| Pages | `SplashPage` (+ location permission UI showcase) |
| Layers | Presentation only |

→ [features/SPLASH_AND_ONBOARDING.md](features/SPLASH_AND_ONBOARDING.md) · [SPLASH_CUBIT_ARCHITECTURE.md](SPLASH_CUBIT_ARCHITECTURE.md)

---

## onboarding

| | |
|--|--|
| Path | `lib/features/onboarding/` |
| Purpose | First-launch carousel; flag in SharedPreferences |
| Pages | `OnboardingPage` (assets `01.png`–`03.png`) |
| Layers | Presentation only |

---

## home

| | |
|--|--|
| Path | `lib/features/home/` |
| Purpose | Main shopping home; standard + express dashboards; hosts bottom shell |
| Entities | Dashboard sections, banners, product cards, express fulfillment centers |
| Endpoints | `GET /dashboard`, `GET /express-30/dashboard` |
| SM | `DashboardBloc`, `ExpressDashboardBloc`, `RecentViewsCubit` |
| Pages | `HomePage`, `MainShell`, `ViewAllProductsPage` |
| Special | `DeliveryType`: standard · quick · services; services tab embeds home_service UI |

→ [features/HOME.md](features/HOME.md)

---

## categories

| | |
|--|--|
| Path | `lib/features/categories/` |
| Purpose | Category sidebar + product grid UI |
| Layers | **Presentation only** — data from product feature |
| Pages | `CategoriesPage` + sidebar/card widgets |
| Query | `categoryId`, `subcategoryId`, `delivery` |

---

## product

| | |
|--|--|
| Path | `lib/features/product/` |
| Purpose | Categories API, product list/detail, search data, delivery check, express products, recent views/searches |
| Entities | Product, Category, Brand, variants, reviews/QA, ExpressProductsResponse, etc. |
| Endpoints | `/ecommerce/categories`, `/ecommerce/products`, `/ecommerce/products/:id`, check-delivery, `/products/search`, `/express-30/products`, recent-searches/views |
| SM | `ProductCubit`, `DeliveryCheckCubit`, `SimilarProductsCubit` |
| Pages | `ProductDetailsPage` |
| Docs | [EXPRESS_PRODUCTS_README.md](../lib/features/product/EXPRESS_PRODUCTS_README.md) |

→ [features/PRODUCT.md](features/PRODUCT.md)

---

## search

| | |
|--|--|
| Path | `lib/features/search/` |
| Purpose | Search UI + recent searches |
| SM | `SearchCubit` (registered with product DI) |
| Pages | `SearchPage` |
| Layers | Presentation only |

---

## cart

| | |
|--|--|
| Path | `lib/features/cart/` |
| Purpose | Server-backed cart; guest token; standard vs express carts |
| Entities | `Cart`, `CartItem`, `ExtraCharge` |
| Endpoints | `/cart/cart`, `/cart/add`, `/cart/update`, `/cart/item/:id`, `/cart/clear` |
| SM | `CartCubit` singleton — `fetchAllCarts`, add/update/remove/clear |
| Pages | `CartPage` (+ add-to-cart widgets, variant bottom sheet) |
| Special | Guest token in SecureStore; dual delivery types |

→ [features/CART.md](features/CART.md)

---

## wishlist

| | |
|--|--|
| Path | `lib/features/wishlist/` |
| Purpose | Saved products |
| Endpoints | `/wishlist`, `/wishlist/add`, `/wishlist/remove/:id` (paths may be hardcoded in DS) |
| SM | `WishlistCubit` singleton |
| Pages | `WishlistPage` |

→ [features/WISHLIST.md](features/WISHLIST.md)

---

## address

| | |
|--|--|
| Path | `lib/features/address/` |
| Purpose | CRUD addresses, default, map pick, geolocation, place search |
| Entities | `Address`, `AddressType`, `Location` |
| Endpoints | `/address/addresses`, `/address/add`, update/delete/default |
| SM | `AddressBloc` (root), `MapCubit` |
| Pages | `AddressListPage`, `AddAddressPage`, `MapPickerPage` |
| Special | Hive offline cache; mock repo in mock mode |
| Docs | [ADDRESS_SYNC_README.md](../lib/features/address/ADDRESS_SYNC_README.md) |

→ [features/ADDRESS.md](features/ADDRESS.md)

---

## checkout

| | |
|--|--|
| Path | `lib/features/checkout/` |
| Purpose | Select cart lines → address/delivery/payment → place order → online pay |
| Entities | Selected items, summary, delivery option, price breakdown, place-order response |
| Endpoints | Cart read, `POST /order/place`; payment via payment use cases |
| SM | `CheckoutBloc` |
| Pages | `SelectItemsPage`, `CheckoutPage`, `OrderReviewPage`, `OrderPlacedPage` |
| Auth | Router requires login |

→ [features/CHECKOUT.md](features/CHECKOUT.md)

---

## payment

| | |
|--|--|
| Path | `lib/features/payment/` |
| Purpose | Create/verify Razorpay payment; history; success/failed UI |
| Endpoints | `POST /payments/create`, `POST /payments/verify`, `GET /payments/history` |
| SM | `PaymentBloc` — **legacy for new flows**; CheckoutBloc is canonical |
| Pages | `PaymentSuccessPage`, `PaymentFailedPage` |
| Service | `core/services/razorpay_service.dart` |

→ [features/PAYMENT.md](features/PAYMENT.md) · [RAZORPAY_INTEGRATION.md](RAZORPAY_INTEGRATION.md)

---

## orders

| | |
|--|--|
| Path | `lib/features/orders/` |
| Purpose | Order list/detail, cancel, return + media, invoice PDF |
| Endpoints | `/order/orders`, detail, cancel, return create/upload; invoice outside `/api` |
| SM | `OrdersCubit`; `LiveOrderTrackingCubit` exists but **not DI-wired** |
| Pages | `OrdersPage` (GuestAuthWall), `OrderDetailsPage`, `ReturnRequestPage` |

→ [features/ORDERS.md](features/ORDERS.md)

---

## quick_delivery

| | |
|--|--|
| Path | `lib/features/quick_delivery/` |
| Purpose | Map tracking for express orders; express category product listing |
| Endpoints | delivery-location; express products via product use case |
| SM | `QuickDeliveryTrackingCubit`, `ExpressProductsCubit` |
| Pages | `QuickDeliveryTrackingPage`, `ExpressProductsPage` |
| Auth | `/quick-delivery` prefix requires login |

→ [features/QUICK_DELIVERY.md](features/QUICK_DELIVERY.md)

---

## home_service

| | |
|--|--|
| Path | `lib/features/home_service/` |
| Purpose | Services catalog; courier quote/book; electrician/plumber/salon bookings; service order history |
| Endpoints | `/service/services`, courier partners/quote/bookings, trade bookings, service-orders |
| SM | `HomeServiceCubit` |
| Pages | Courier + general service + history pages; `HomeServiceContent` on home services tab |

→ [features/HOME_SERVICE.md](features/HOME_SERVICE.md)

---

## wallet

| | |
|--|--|
| Path | `lib/features/wallet/` |
| Purpose | Wallet points summary, bank accounts, withdrawal request |
| Endpoints | `GET/POST /wallet`, `GET /bank-detail` |
| SM | `WalletCubit` |
| Pages | `wallet/presentation/pages/wallet_page.dart` (main) |

→ [features/WALLET.md](features/WALLET.md)

---

## profile

| | |
|--|--|
| Path | `lib/features/profile/` |
| Purpose | Profile hub; update profile; join as delivery boy / vendor; development request; callback; bank detail; legal pages |
| SM | `DeliveryBoyBloc`, `VendorBloc`, `DevelopmentBloc`, `CallbackBloc`, `BankDetailBloc` |
| Pages | `ProfilePage` (GuestAuthWall), update profile, join forms, policies, about |

→ [features/PROFILE.md](features/PROFILE.md)

---

## Shared shell (`MainShell`)

Bottom navigation (5 tabs):

1. Home  
2. Categories  
3. Cart  
4. Orders  
5. Profile  

On enter, shell typically ensures `CartCubit.fetchAllCarts()` and `WishlistCubit.fetchWishlist()` and provides required blocs for home/product.

---

## Core modules used by features (not under `features/`)

| Module | Path | Role |
|--------|------|------|
| ApiClient | `core/network/` | Dio + Bearer + error map |
| WebSocket | `core/websocket/` | Live feed infra (order tracking planned) |
| RazorpayService | `core/services/` | SDK open checkout |
| GuestAuthWall | `core/widgets/` | In-page login prompt |
| Theme | `core/theme/` | Design system |
| SecureStore | `core/utils/` | Auth + guest cart tokens |

---

## Stubs / leftovers

Present in routes or `ApiConstants` but **no full feature folder**:

- Restaurant list/details placeholders  
- Register / forgot password / change password / settings / notifications placeholders in `app_router.dart`  
- Legacy restaurant/menu/favorites endpoint constants  

Do not document these as live product features until implemented.
