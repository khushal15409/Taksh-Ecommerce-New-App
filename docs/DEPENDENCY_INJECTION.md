# Dependency Injection

GetIt is the single service locator. Registration happens in `initializeDependencies` during app bootstrap.

| File | Role |
|------|------|
| `lib/core/di/injector.dart` | Central registration + feature module calls |
| `lib/core/di/secure_store_di.dart` | SecureStore |
| `lib/features/<feature>/di/*_di.dart` | Complex feature modules |
| `lib/core/websocket/di/websocket_di.dart` | WebSocket manager factory |

Global instance:

```dart
final getIt = GetIt.instance;
```

---

## Bootstrap signature

```dart
Future<void> initializeDependencies({
  required String baseUrl,
  bool useMockData = false,
})
```

Called from `app.dart` with `AppConfig.baseUrl` and `AppConfig.useMockData`.

---

## Registration rules

| Type | GetIt API | Why |
|------|-----------|-----|
| DataSources | `registerLazySingleton` | Shared clients |
| Repositories | `registerLazySingleton` | Shared |
| Use cases | `registerLazySingleton` | Stateless orchestration |
| BLoCs / Cubits | **`registerFactory`** | Fresh instance per widget tree |
| Exceptions ↓ | | |
| `SplashCubit` | `registerLazySingleton` | App-wide locale/theme/location |
| `CartCubit` | `registerLazySingleton` | Shared cart across tabs |
| `WishlistCubit` | `registerLazySingleton` | Shared wishlist across tabs |

**Do not** register UI widgets. Prefer constructor injection of use cases into blocs/cubits.

---

## Registration order (conceptual)

1. Externals — `SharedPreferences`, `Connectivity`, bare `Dio`  
2. Core — `NetworkInfo`, `ApiClient`, `AppRouter`, SecureStore  
3. Features — splash, auth, home/dashboard, address, product, cart, wishlist, orders, checkout, payment, quick_delivery, profile, wallet, websocket, home_service  
4. Feature modules may be extracted to `di/<name>_di.dart`

---

## Feature DI modules

| Module | Function | Feature |
|--------|----------|---------|
| `address/di/address_di.dart` | `registerAddressDependencies` | Address + Hive + MapCubit |
| `orders/di/order_di.dart` | `registerOrderDependencies` | Orders |
| `checkout/di/checkout_injection.dart` | `registerCheckoutDependencies` | Checkout |
| `payment/di/payment_injection.dart` | `registerPaymentDependencies` | Payment |
| `quick_delivery/di/quick_delivery_di.dart` | `registerQuickDeliveryDependencies` | Tracking + express products |
| `wallet/di/wallet_di.dart` | `registerWalletDependencies` | Wallet |
| `home_service/di/home_service_di.dart` | `registerHomeServiceDependencies` | Home services |
| `core/websocket/di/websocket_di.dart` | `registerWebSocketDependencies` | `WebSocketManagerFactory` |

Simple features (auth, cart, product, wishlist, splash, profile pieces) register inline in `injector.dart`.

**Convention for new complex features:**

```dart
void registerFooDependencies(GetIt getIt, {bool useMock = false}) {
  // datasources → repos → usecases → blocs
}

// in initializeDependencies:
registerFooDependencies(getIt, useMock: useMockData);
```

---

## Mock switching (`useMockData`)

When `true` (only `AppConfig.mock()` / `main_mock.dart`):

| Feature | Mock binding |
|---------|----------------|
| Auth | `AuthMockDataSource` instead of remote impl |
| Express dashboard | `MockExpressDashboardRepository` |
| Address | `MockAddressRepository` (skips remote/local DS pair) |
| Checkout | `CheckoutMockDataSource` |
| Payment | `PaymentMockDataSource` |

Other features still use real datasources unless extended — mock mode is **partial**, strongest around auth/checkout/payment/address.

---

## Root vs route providers

### App root (`TakshECommerceApp`)

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => getIt<SplashCubit>()),
    BlocProvider(create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested())),
    BlocProvider(create: (_) => getIt<AddressBloc>()),
  ],
  ...
)
```

Even if `AddressBloc` / `AuthBloc` are factories, they are created **once** at root and shared.

### Shell / route

- `MainShell` provides cart/wishlist/dashboard/product as needed  
- Product details route provides `ProductCubit`, cart, wishlist when stack may not include shell  
- Checkout pages provide `CheckoutBloc` via factory  

```dart
BlocProvider(
  create: (_) => getIt<CheckoutBloc>(),
  child: const CheckoutPage(),
)
```

---

## State management inventory (DI scope)

| Class | Scope |
|-------|-------|
| SplashCubit | singleton |
| CartCubit | singleton |
| WishlistCubit | singleton |
| AuthBloc | factory (root once) |
| AddressBloc | factory (root once) |
| MapCubit | factory |
| DashboardBloc / ExpressDashboardBloc | factory |
| RecentViewsCubit | factory |
| ProductCubit / DeliveryCheckCubit / SimilarProductsCubit / SearchCubit | factory |
| CheckoutBloc / PaymentBloc | factory |
| OrdersCubit | factory |
| QuickDeliveryTrackingCubit / ExpressProductsCubit | factory |
| HomeServiceCubit | factory |
| WalletCubit | factory |
| Profile sub-blocs (DeliveryBoy, Vendor, Development, Callback, BankDetail) | factory |
| LiveOrderTrackingCubit | **not registered** (as of last audit) |

---

## Usage patterns

```dart
// Resolve
final cubit = getIt<CartCubit>();

// In widget
BlocProvider(
  create: (_) => getIt<ProductCubit>()..load(...),
  child: ...,
)

// Prefer reading provided instance
context.read<AuthBloc>().add(...);
```

Avoid `getIt<SomeBloc>()` inside deeply nested widgets if a `BlocProvider` already exists above — you may get a **different factory instance**.

---

## Adding dependencies checklist

1. Create classes following Clean Architecture.  
2. Register DS → Repo → UseCase → Bloc/Cubit with correct lifetime.  
3. Complex feature → own `di/` file + call from `injector.dart`.  
4. If mockable, branch on `useMockData`.  
5. Provide bloc at correct tree level (root / shell / route).  
6. Update this doc + [FEATURES.md](FEATURES.md).

- `NotificationsCubit` is also a `registerLazySingleton` (home bell badge + notifications page share one unread count), like `WishlistCubit`.
