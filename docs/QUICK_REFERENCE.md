# Quick Reference Guide

Quick code snippets and patterns for daily development.

**Full docs index:** [README.md](README.md) · **Conventions:** [../AGENTS.md](../AGENTS.md) · **Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md)

## Table of Contents
- [Creating a New Feature](#creating-a-new-feature)
- [Common Code Patterns](#common-code-patterns)
- [BLoC Patterns](#bloc-patterns)
- [Cubit Patterns](#cubit-patterns)
- [API Integration](#api-integration)
- [Error Handling](#error-handling)
- [Navigation](#navigation)
- [Form Validation](#form-validation)
- [Localization](#localization)
- [Theme](#theme)
- [DI lifetimes](#di-lifetimes)

---

## Creating a New Feature

### 1. Domain Layer

**Entity**:
```dart
import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String image;
  
  const Restaurant({
    required this.id,
    required this.name,
    required this.image,
  });
  
  @override
  List<Object?> get props => [id, name, image];
}
```

**Repository Interface**:
```dart
import 'package:taksh_e_commerce/core/utils/typedef.dart';

abstract class RestaurantRepository {
  ResultFuture<List<Restaurant>> getRestaurants();
  ResultFuture<Restaurant> getRestaurantById(String id);
}
```

**Use Case**:
```dart
import 'package:taksh_e_commerce/core/usecase/usecase.dart';

class GetRestaurantsUseCase extends UseCaseNoParams<List<Restaurant>> {
  final RestaurantRepository _repository;
  
  const GetRestaurantsUseCase(this._repository);
  
  @override
  ResultFuture<List<Restaurant>> call() {
    return _repository.getRestaurants();
  }
}
```

### 2. Data Layer

**Model**:
```dart
import 'package:taksh_e_commerce/core/utils/typedef.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.image,
  });
  
  factory RestaurantModel.fromJson(DataMap json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
  
  DataMap toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}
```

**Remote Data Source**:
```dart
abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> getRestaurants();
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final ApiClient _apiClient;
  
  const RestaurantRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;
  
  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    final response = await _apiClient.get('/restaurants');
    final List<dynamic> data = response.data['restaurants'];
    return data.map((json) => RestaurantModel.fromJson(json)).toList();
  }
}
```

**Repository Implementation**:
```dart
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  
  const RestaurantRepositoryImpl({
    required RestaurantRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;
  
  @override
  ResultFuture<List<Restaurant>> getRestaurants() async {
    try {
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }
      
      final restaurants = await _remoteDataSource.getRestaurants();
      return Right(restaurants);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
```

### 3. Presentation Layer

**Events**:
```dart
abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();
  
  @override
  List<Object?> get props => [];
}

class RestaurantLoadRequested extends RestaurantEvent {
  const RestaurantLoadRequested();
}
```

**States**:
```dart
abstract class RestaurantState extends Equatable {
  const RestaurantState();
  
  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  
  const RestaurantLoaded(this.restaurants);
  
  @override
  List<Object?> get props => [restaurants];
}

class RestaurantError extends RestaurantState {
  final String message;
  
  const RestaurantError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**BLoC**:
```dart
class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurantsUseCase _getRestaurantsUseCase;
  
  RestaurantBloc({required GetRestaurantsUseCase getRestaurantsUseCase})
      : _getRestaurantsUseCase = getRestaurantsUseCase,
        super(RestaurantInitial()) {
    on<RestaurantLoadRequested>(_onLoadRequested);
  }
  
  Future<void> _onLoadRequested(
    RestaurantLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    
    final result = await _getRestaurantsUseCase();
    
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurants) => emit(RestaurantLoaded(restaurants)),
    );
  }
}
```

**Page**:
```dart
class RestaurantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RestaurantBloc>()
        ..add(const RestaurantLoadRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Restaurants')),
        body: BlocBuilder<RestaurantBloc, RestaurantState>(
          builder: (context, state) {
            if (state is RestaurantLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is RestaurantError) {
              return Center(child: Text(state.message));
            }
            
            if (state is RestaurantLoaded) {
              return ListView.builder(
                itemCount: state.restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = state.restaurants[index];
                  return ListTile(
                    title: Text(restaurant.name),
                    leading: Image.network(restaurant.image),
                  );
                },
              );
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
```

### 4. Register & route (checklist)

```text
□ DI: registerLazySingleton DS/Repo/UseCase; registerFactory Bloc/Cubit
□ Complex feature → lib/features/<name>/di/<name>_di.dart
□ AppRoutes constant + GoRoute in app_router.dart
□ Auth: _authRequiredRoutes or GuestAuthWall
□ l10n keys en + hi → flutter gen-l10n
□ docs/features/<NAME>.md + FEATURES.md row
□ build_runner if models changed
```

---

## Common Code Patterns

### BLoC Consumer Pattern
```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // Handle navigation, snackbars, dialogs
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    
    if (state is Authenticated) {
      context.go(AppRoutes.home);
    }
  },
  builder: (context, state) {
    // Build UI based on state
    if (state is AuthLoading) {
      return const CircularProgressIndicator();
    }
    
    return LoginForm();
  },
)
```

### API Call Pattern
```dart
try {
  final response = await _apiClient.get(
    '/endpoint',
    queryParameters: {'page': 1, 'limit': 20},
  );
  
  final data = response.data;
  return data;
} on NetworkException {
  throw const NetworkException();
} on ServerException catch (e) {
  throw ServerException(e.message);
} catch (e) {
  throw GeneralException(e.toString());
}
```

### Navigation Pattern
```dart
// Navigate to a route
context.go(AppRoutes.home);
context.go(AppRoutes.homeWithDelivery('quick')); // standard | quick | services

// Navigate with helpers (prefer AppRoutes helpers over string replace)
context.push(AppRoutes.orderDetails(orderId));
context.go(AppRoutes.categoriesToCategory(12, subcategoryId: 3));

// Navigate back
context.pop();

// After login redirect
// AppRouter.navigateAfterAuth(...) — used by auth success path
```

See [ROUTING.md](ROUTING.md).

### Cubit Patterns
```dart
class ProductCubit extends Cubit<ProductState> {
  final GetProducts _getProducts;
  ProductCubit(this._getProducts) : super(ProductInitial());

  Future<void> load() async {
    emit(ProductLoading());
    final result = await _getProducts();
    if (isClosed) return;
    result.fold(
      (f) => emit(ProductError(f.message)),
      (data) => emit(ProductLoaded(data)),
    );
  }
}
```

Singletons (do not re-create via new factory provider blindly):

- `CartCubit`, `WishlistCubit`, `SplashCubit`

### Form Validation Pattern
```dart
final _formKey = GlobalKey<FormState>();

TextFormField(
  validator: (value) => Validators.getEmailError(value ?? ''),
  decoration: const InputDecoration(labelText: 'Email'),
)

// On submit
if (_formKey.currentState!.validate()) {
  // Process form
}
```

---

## Error Handling

### Try-Catch in Repository
```dart
@override
ResultFuture<User> getUser() async {
  try {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    
    final user = await _remoteDataSource.getUser();
    return Right(user);
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } catch (e) {
    return Left(GeneralFailure(e.toString()));
  }
}
```

### Handle Either Result
```dart
final result = await useCase();

result.fold(
  (failure) {
    // Handle failure
    print('Error: ${failure.message}');
  },
  (data) {
    // Handle success
    print('Success: $data');
  },
);
```

---

## Dependency Injection

### Register Dependencies
```dart
// In injector.dart

// Singleton (one instance for entire app)
getIt.registerLazySingleton<ApiClient>(
  () => ApiClient(baseUrl: baseUrl, prefs: getIt()),
);

// Factory (new instance every time)
getIt.registerFactory(
  () => AuthBloc(sendOtpUseCase: getIt()),
);

// Feature module
registerCheckoutDependencies(getIt, useMock: useMockData);
```

### DI lifetimes

| Type | Registration |
|------|----------------|
| DS, Repo, UseCase | `registerLazySingleton` |
| Bloc/Cubit | `registerFactory` |
| CartCubit, WishlistCubit, SplashCubit | `registerLazySingleton` |

Full guide: [DEPENDENCY_INJECTION.md](DEPENDENCY_INJECTION.md)

### Use Dependencies
```dart
// Prefer existing provider when already above in tree
context.read<AuthBloc>().add(AuthLogoutRequested());

// Route-scoped factory
BlocProvider(
  create: (context) => getIt<CheckoutBloc>(),
  child: MyWidget(),
)
```

### Localization
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.loginTitle); // example key
```

After ARB edits: `flutter gen-l10n` — [LOCALIZATION.md](LOCALIZATION.md)

### Theme
```dart
// Prefer tokens
color: AppColors.primary,
padding: EdgeInsets.all(AppSpacing.md),
style: AppTypography.titleMedium,
```

---

## Logging

```dart
// Info
LoggerHelper.i('User logged in successfully');

// Debug
LoggerHelper.d('Current state: $state');

// Warning
LoggerHelper.w('Token expiring soon');

// Error
LoggerHelper.e('Failed to fetch data', error, stackTrace);

// API request
LoggerHelper.apiRequest('POST', '/login', data: credentials);

// API response
LoggerHelper.apiResponse('/login', 200, data: response);

// Navigation
LoggerHelper.navigation('LoginPage', 'HomePage');

// State change
LoggerHelper.stateChange('AuthBloc', 'Authenticated');

// Cache operation
LoggerHelper.cache('SAVE', 'user', value: user.name);
```

---

## Testing Patterns

### Unit Test (Use Case)
```dart
void main() {
  late MockAuthRepository mockRepository;
  late VerifyOtpUseCase useCase;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyOtpUseCase(mockRepository);
  });
  
  test('should return User when OTP is valid', () async {
    // Arrange
    final credentials = OtpCredentials(phone: '1234567890', otp: '123456');
    final user = User(id: '1', name: 'Test', phone: '1234567890');
    when(mockRepository.verifyOtp(credentials))
        .thenAnswer((_) async => Right(user));
    
    // Act
    final result = await useCase(credentials);
    
    // Assert
    expect(result, Right(user));
    verify(mockRepository.verifyOtp(credentials));
  });
}
```

### BLoC Test
```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, Authenticated] when OTP is verified',
  build: () {
    when(mockVerifyOtpUseCase(any))
        .thenAnswer((_) async => Right(tUser));
    return authBloc;
  },
  act: (bloc) => bloc.add(AuthVerifyOtpRequested(...)),
  expect: () => [
    const AuthLoading(),
    Authenticated(tUser),
  ],
);
```

---

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run -t lib/main_dev.dart      # real API
flutter run -t lib/main_mock.dart     # mocks, OTP 1234
flutter run -t lib/main_staging.dart
flutter run -t lib/main.dart          # production config

# Build APK
flutter build apk --release

# Run tests
flutter test

# Run specific test
flutter test test/features/auth/domain/usecases/verify_otp_usecase_test.dart

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Localization
flutter gen-l10n

# Analyze code
flutter analyze

# Format code
dart format lib/

# Check outdated packages
flutter pub outdated
```

---

## Mock OTP (quick)

| | |
|--|--|
| Entry | `lib/main_mock.dart` |
| OTP | **`1234`** |
| Guide | [MOCK_AUTH_GUIDE.md](MOCK_AUTH_GUIDE.md) |

---

This quick reference should help you navigate common development tasks quickly!

## Toasts (success / error / warning / info)

All user messages use the top-center toast in `lib/core/widgets/app_toast.dart`
(white card, status icon, title + message, close button, countdown bar).

- Preferred: `AppToast.success/error/warning/info(context, 'Title', message: '...')`
- Errors: `AppErrorToast.show(context, message: ...)`
- Legacy `AppToastMessenger.of(context).showSnackBar(SnackBar(...))` (a drop-in
  for `ScaffoldMessenger.of`) renders the same toast; the type is inferred from
  the SnackBar `backgroundColor` (or keywords in the text when it has none).
