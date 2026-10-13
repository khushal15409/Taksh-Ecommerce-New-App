# Clean Architecture Guide

## Overview

This project follows **Clean Architecture** principles by Robert C. Martin (Uncle Bob), ensuring:

- Separation of concerns  
- Testability  
- Independence from frameworks  
- Independence from UI  
- Independence from databases  

**Also read:** [FEATURES.md](FEATURES.md) · [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md) · [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md) · [AGENTS.md](../AGENTS.md)

---

## Current project layout (actual)

```
lib/
├── main.dart / main_dev.dart / main_staging.dart / main_mock.dart
├── app.dart                          # AppConfig + bootstrap + root providers
├── l10n/                             # ARB + generated localizations
├── core/
│   ├── constants/                    # api_constants, app_constants, storage_constants
│   ├── di/                           # injector.dart, secure_store_di.dart
│   ├── error/                        # exceptions.dart, failures.dart
│   ├── network/                      # api_client, network_info, base_response_model
│   ├── routing/                      # app_router, app_routes
│   ├── services/                     # razorpay_service
│   ├── theme/                        # AppColors, AppSpacing, AppTypography, AppTheme
│   ├── usecase/                      # UseCase / UseCaseNoParams base types
│   ├── utils/                        # typedefs, validators, secure_store, logger, extensions
│   ├── websocket/                    # live feed infra
│   └── widgets/                      # GuestAuthWall, toasts, avatars, …
└── features/
    ├── auth/ address/ cart/ checkout/ orders/ payment/
    ├── home/ product/ categories/ search/ wishlist/
    ├── quick_delivery/ home_service/ wallet/ profile/
    ├── splash/ onboarding/
```

Feature-first: each product capability owns its folder. Shared infrastructure stays in `core/`.

**Presentation-only features** (no domain/data of their own): `categories`, `search`, `splash`, `onboarding` — they consume other features’ use cases/cubits.

---

## Architecture Layers

### 1. Domain Layer (Innermost - Pure Dart)

**Location**: `lib/features/[feature]/domain/`

**Purpose**: Contains the business logic and rules of the application.

**Components**:

#### Entities (`entities/`)

- Pure Dart classes representing business objects  
- No dependencies on Flutter or external packages (except Equatable)  
- Use `Equatable` for value equality  
- Example: `User`, `Cart`, `Address`, `Order`

```dart
class User extends Equatable {
  final String id;
  final String name;
  final String phone;
  
  const User({required this.id, required this.name, required this.phone});
  
  @override
  List<Object?> get props => [id, name, phone];
}
```

#### Repository Interfaces (`repositories/`)

- Abstract contracts defining data operations  
- Return types use `Either<Failure, T>` from Dartz  
- Project typedefs: `ResultFuture<T>`, `ResultVoid` in `core/utils/typedef.dart`  
- No implementation details

```dart
abstract class AuthRepository {
  ResultFuture<User> verifyOtp(OtpCredentials credentials);
  ResultVoid logout();
}
```

#### Use Cases (`usecases/`)

- Single responsibility business logic  
- Each use case performs one specific action  
- Depends only on repository interfaces  
- Base types: `UseCase<T, Params>`, `UseCaseNoParams<T>` in `core/usecase/usecase.dart`

```dart
class VerifyOtpUseCase extends UseCase<User, OtpCredentials> {
  final AuthRepository _repository;
  
  const VerifyOtpUseCase(this._repository);
  
  @override
  ResultFuture<User> call(OtpCredentials params) {
    return _repository.verifyOtp(params);
  }
}
```

**Key Rules**:

- ✅ No Flutter imports  
- ✅ No external package imports (except Equatable, Dartz)  
- ✅ Pure business logic only  
- ✅ All methods return `Either<Failure, T>` / `ResultFuture` / `ResultVoid`

---

### 2. Data Layer (Middle Layer)

**Location**: `lib/features/[feature]/data/`

**Purpose**: Implements domain contracts and handles data operations.

**Components**:

#### Models (`models/`)

- Extend domain entities **or** map to/from entities via `toEntity()`  
- JSON serialization via `json_serializable` (`*.g.dart` generated, gitignored)  
- Hive models use `hive_generator` where local cache is required (e.g. address)

```dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}
```

#### Data Sources (`datasources/`)

**Remote Data Source**:

- Communicates with external APIs  
- Uses `ApiClient` (Dio wrapper)  
- Throws exceptions on errors  
- Returns raw data (models)  
- Prefer parsing `BaseResponse` envelope — see [API_RESPONSE_MODELS.md](API_RESPONSE_MODELS.md)

```dart
abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String phone);
  Future<AuthResponseModel> verifyOtp(String phone, String otp, String token);
}
```

**Local Data Source**:

- Manages local storage (SharedPreferences, Hive, SecureStore for secrets)  
- Caches data for offline access  
- Throws `CacheException` on errors

```dart
abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel> getUser();
  Future<void> clearUserData();
}
```

**Mock Data Source** (selected features):

- Auth, checkout, payment, address (mock repo), express dashboard  
- Enabled when `useMockData: true` (`main_mock.dart`)

#### Repository Implementation (`repositories/`)

- Implements domain repository interface  
- Coordinates between remote and local data sources  
- Handles network connectivity checks  
- Converts exceptions to failures  
- Returns `Either<Failure, T>`

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  @override
  ResultFuture<User> verifyOtp(OtpCredentials credentials) async {
    try {
      // Check network
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }
      
      // Fetch from remote
      final response = await _remoteDataSource.verifyOtp(...);
      final user = UserModel.fromJson(response.user);
      
      // Cache locally
      await _localDataSource.saveUser(user);
      
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

**Key Rules**:

- ✅ Implements domain interfaces  
- ✅ Converts exceptions to failures  
- ✅ Checks network before remote calls  
- ✅ Caches data when possible  
- ✅ Returns `Either<Failure, T>`

---

### 3. Presentation Layer (Outermost - UI)

**Location**: `lib/features/[feature]/presentation/`

**Purpose**: Handles UI, user interactions, and state management.

**Components**:

#### BLoC or Cubit

| Prefer BLoC when | Prefer Cubit when |
|------------------|-------------------|
| Many discrete user intents | Simple load/refresh/CRUD |
| Multi-step flows (checkout, auth OTP) | Single async pipeline |
| Need event replay/testing granularity | Less boilerplate is better |

**Events** (`*_event.dart`):

- User actions and intents  
- Immutable classes extending `Equatable`

```dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String phone;
  final String otp;
  
  const AuthVerifyOtpRequested({required this.phone, required this.otp});
  
  @override
  List<Object?> get props => [phone, otp];
}
```

**States** (`*_state.dart`):

- Application states  
- Immutable classes extending `Equatable`

```dart
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
```

**BLoC** (`*_bloc.dart`):

- Business logic component  
- Transforms events into states  
- Uses use cases from domain layer  
- Always `result.fold(...)`  
- Guard with `emit.isDone` / Cubit `isClosed`

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final VerifyOtpUseCase _verifyOtpUseCase;
  
  AuthBloc({required VerifyOtpUseCase verifyOtpUseCase})
      : _verifyOtpUseCase = verifyOtpUseCase,
        super(const AuthInitial()) {
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
  }
  
  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final credentials = OtpCredentials(phone: event.phone, otp: event.otp);
    final result = await _verifyOtpUseCase(credentials);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
}
```

#### Pages (`pages/`)

- Full-screen widgets  
- Contain BlocProvider and BlocListener  
- Handle navigation and snackbars  
- User strings via `AppLocalizations`

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(...);
            }
          },
          builder: (context, state) {
            return LoginForm();
          },
        ),
      ),
    );
  }
}
```

> **Note:** For singleton cubits (`CartCubit`, `WishlistCubit`, `SplashCubit`) and root-provided blocs (`AuthBloc`, `AddressBloc`), prefer `context.read` / existing providers over creating a new `getIt` instance.

#### Widgets (`widgets/`)

- Reusable UI components  
- Stateless when possible  
- Accept data through constructor  
- Theme via `AppColors` / `AppSpacing` / `AppTypography`

**Key Rules**:

- ✅ Only depends on domain layer (not data models)  
- ✅ Uses BLoC/Cubit for state management  
- ✅ No business logic in widgets  
- ✅ Handles UI-related concerns only  

---

## Dependency Flow

```
Presentation Layer
       ↓ (uses)
  Domain Layer
       ↑ (implements)
    Data Layer
```

**Important**:

- Presentation depends on Domain  
- Data implements Domain contracts  
- Domain depends on nothing (pure Dart)  
- **Never** import `data/` from `presentation/`  

---

## Error Handling Pattern

### 1. Exceptions (Data Layer)

Thrown by data sources when operations fail:

```dart
throw ServerException('API error', 500);
throw CacheException('Failed to save data');
throw NetworkException('No internet');
```

Full set includes `AuthException`, `NotFoundException`, `TimeoutException`, `BadRequestException`, `ValidationException`, `GeneralException` — see `core/error/exceptions.dart`.

### 2. Failures (Domain Layer)

Returned as `Left` in `Either<Failure, T>`:

```dart
return const Left(ServerFailure('API error'));
return const Left(CacheFailure('Failed to save'));
return const Left(NetworkFailure('No internet'));
```

Parallel hierarchy in `core/error/failures.dart`.

### 3. Error States (Presentation Layer)

Displayed to users:

```dart
if (state is AuthError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
}
```

Or shared `AppErrorToast` where used.

---

## Dependency Injection

All dependencies are registered via `lib/core/di/injector.dart` and feature modules. Full guide: [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md).

```dart
// Data sources
getIt.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(apiClient: getIt()),
);

// Repositories
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    remoteDataSource: getIt(),
    localDataSource: getIt(),
    networkInfo: getIt(),
  ),
);

// Use cases
getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt()));

// BLoCs (factory - new instance each time)
getIt.registerFactory(() => AuthBloc(verifyOtpUseCase: getIt()));

// Shared cubits
getIt.registerLazySingleton(() => CartCubit(...));
```

Complex features: `address`, `orders`, `checkout`, `payment`, `quick_delivery`, `wallet`, `home_service` → `di/<feature>_di.dart`.

---

## Cross-cutting core services

| Concern | Location |
|---------|----------|
| HTTP | `ApiClient` — Bearer token, 401 clears token, Dio→exception map |
| Routing | `go_router` + auth redirect + GuestAuthWall |
| Theme | Material 3, Nunito, India-inspired palette tokens |
| Secure storage | Auth token + guest cart token |
| Payments SDK | `RazorpayService` — public key from backend only |
| Realtime | WebSocket manager + `LiveFeedCubit` (order tracking WIP) |
| Logging | Talker/logger helpers with context maps |

---

## Benefits of This Architecture

1. **Testability**: Each layer can be tested independently  
2. **Maintainability**: Clear separation makes changes easier  
3. **Scalability**: Easy to add new features  
4. **Flexibility**: Easy to change implementations  
5. **Team Collaboration**: Different teams can work on different layers  

---

## Adding a New Feature

1. **Create feature folder**: `lib/features/new_feature/`  
2. **Domain Layer**:  
   - Define entities  
   - Create repository interface  
   - Write use cases  
3. **Data Layer**:  
   - Create models + `build_runner`  
   - Implement data sources  
   - Implement repository  
4. **Presentation Layer**:  
   - Create BLoC or Cubit (events, states)  
   - Build pages  
   - Create widgets  
5. **Register in DI**: `injector.dart` or `di/<name>_di.dart`  
6. **Routing**: `app_routes.dart` + `app_router.dart` (+ auth guard if needed)  
7. **L10n**: `app_en.arb` + `app_hi.arb` → `flutter gen-l10n`  
8. **Docs**: add/update `docs/features/<NAME>.md` and [FEATURES.md](FEATURES.md)  
9. **Write Tests**: Unit, BLoC, and widget tests  

Detailed checklists: [QUICK_REFERENCE.md](QUICK_REFERENCE.md) · [DEVELOPMENT.md](DEVELOPMENT.md)

---

## Best Practices

✅ **DO**:

- Keep domain layer pure (no Flutter imports)  
- Use `Either<Failure, T>` for operations that can fail  
- Write single-responsibility use cases  
- Test each layer independently  
- Use dependency injection  
- Use package imports `package:taksh_e_commerce/...`  
- Use theme tokens and l10n for UI  
- Guard bloc/cubit emits after close  

❌ **DON'T**:

- Put business logic in widgets  
- Import Flutter in domain layer  
- Skip error handling  
- Create god classes  
- Tightly couple layers  
- Commit secrets or Razorpay secret keys  
- Invent API paths — verify `ApiConstants` / backend  

---

## References

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)  
- [Flutter Clean Architecture by Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/)  
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)  
- Project docs index: [README.md](README.md)  
