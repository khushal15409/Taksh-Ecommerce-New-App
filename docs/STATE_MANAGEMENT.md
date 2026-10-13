# State Management

The app uses **flutter_bloc** with two styles:

| Style | When | Examples |
|-------|------|----------|
| **BLoC** | Multi-step / many events / complex transitions | Auth, Address, Checkout, Payment, Dashboard, profile join forms |
| **Cubit** | Simpler CRUD or single-flow async | Cart, Orders, Product, Search, Wallet, Splash |

Both emit immutable states; events/states extend **Equatable**.

---

## Core patterns

### 1. Either fold (mandatory)

Use cases return `ResultFuture<T>` (`Future<Either<Failure, T>>`).

```dart
final result = await _useCase(params);

result.fold(
  (failure) {
    if (isClosed) return; // Cubit
    emit(MyError(failure.message));
  },
  (data) {
    if (isClosed) return;
    emit(MyLoaded(data));
  },
);
```

BLoC equivalent guard: `if (emit.isDone) return;` before emit.

### 2. One event class per action

```dart
class AuthSendOtpRequested extends AuthEvent {
  final String phone;
  const AuthSendOtpRequested(this.phone);
  @override
  List<Object?> get props => [phone];
}
```

### 3. Preserve data during loading when UX needs it

Example pattern: `AddingToCart` may carry `currentCart` so the UI does not flash empty.

### 4. Logging

Prefer structured context:

```dart
final log = loggerWithContext({'feature': 'cart', 'action': 'add'});
log.info('Adding item');
```

---

## Singleton cubits (app-wide)

| Cubit | Why shared |
|-------|------------|
| `SplashCubit` | Locale, themeMode, location permission for entire app |
| `CartCubit` | Badge + multi-tab consistency; guest token lifecycle |
| `WishlistCubit` | Heart icons across product surfaces |

Register with `registerLazySingleton`. Provide once at shell/root and `context.read` elsewhere — do **not** create a second instance via factory by mistake.

---

## Factory blocs/cubits

Most others are `registerFactory`. Create via `BlocProvider(create: (_) => getIt<X>())` at the route or feature subtree that owns the lifecycle.

Root exceptions: `AuthBloc` and `AddressBloc` are factories but provided **once** at app root.

---

## Typical state shapes

```text
Initial → Loading → Loaded(data) | Error(message)
```

Checkout/Auth add intermediate states (`OtpSent`, `PaymentInitiated`, `OrderPlaced`, …). Keep states explicit rather than a single enum with nullable fields when transitions are non-trivial.

---

## UI wiring

```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // side effects: navigation, snackbars, dialogs
  },
  builder: (context, state) {
    // pure UI
  },
)
```

- `BlocBuilder` — UI only  
- `BlocListener` — side effects only  
- `BlocConsumer` — both  
- `context.read` — fire-and-forget events  
- `context.watch` / `BlocBuilder` — rebuild on changes  

---

## Guest vs authenticated UI

- Router may redirect (checkout, addresses, quick-delivery).  
- Shell tabs may show `GuestAuthWall` while still mounted under shell.  
- Listen to `AuthBloc` for `Authenticated` / `Unauthenticated`; on logout, address feature resets via root `BlocListener`.

---

## Testing

Dev dependencies: `bloc_test`, `mockito`.

```dart
blocTest<AuthBloc, AuthState>(
  'emits loading then authenticated',
  build: () => authBloc,
  act: (b) => b.add(...),
  expect: () => [isA<AuthLoading>(), isA<Authenticated>()],
);
```

See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for fuller samples. No full suite is checked in yet.

---

## Anti-patterns

- Business logic in widgets  
- Emitting after close  
- Calling `getIt<FactoryBloc>()` in a child when parent already provided a different instance  
- Swallowing `Left` failures without user feedback  
- Mixing secret keys or tokens into state objects beyond what UI needs  

---

## Related

- [ARCHITECTURE.md](ARCHITECTURE.md)  
- [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md)  
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
