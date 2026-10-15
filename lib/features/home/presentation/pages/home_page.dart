import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/core/utils/quick_location.dart';
import 'package:taksh_e_commerce/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/express_dashboard_entity.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/quick_state_views.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/category.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_event.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_state.dart';
import 'package:taksh_e_commerce/features/address/presentation/widgets/address_selection_bottom_sheet.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/dashboard_event.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/dashboard_state.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/express_dashboard_bloc.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/express_dashboard_event.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/express_dashboard_state.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/recent_views_cubit.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/dashboard_content.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/dashboard_shimmer.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/express_dashboard_content.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/home_header.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/home_mode_theme.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/delivery_type_selector.dart';
import 'package:taksh_e_commerce/features/home_service/presentation/widgets/home_service_content.dart';

class HomePage extends StatelessWidget {
  final DeliveryType? initialDeliveryType;

  const HomePage({super.key, this.initialDeliveryType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RecentViewsCubit>(),
      child: _HomePageContent(
        initialDeliveryType: initialDeliveryType ?? DeliveryType.standard,
      ),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  final DeliveryType initialDeliveryType;

  const _HomePageContent({required this.initialDeliveryType});

  @override
  State<_HomePageContent> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePageContent> {
  final _log = loggerWithContext({'feature': 'home', 'page': 'HomePage'});
  // Standard dashboard only: used when no usable location exists. The Quick
  // dashboard never uses made-up coordinates.
  static const double _standardFallbackLatitude = 23.0695;
  static const double _standardFallbackLongitude = 72.6738;
  final ScrollController _scrollController = ScrollController();

  // Tab selection state - default to standard delivery where products are displayed
  DeliveryType _selectedDeliveryType = DeliveryType.standard;
  /// Location of the last Quick dashboard request (null = none yet). Used to
  /// reload only when the selected address/coordinates really change.
  QuickLocation? _lastQuickRequest;
  int _servicesReloadCount = 0;

  @override
  void initState() {
    super.initState();
    _log.infoWithContext('Home page displayed', {'action': 'init'});
    _ensureAddressesLoaded();
    // Quick delivery needs a signed-in user (the API rejects guests).
    final isAuthenticated = context.read<AuthBloc>().state is Authenticated;
    _selectedDeliveryType =
        widget.initialDeliveryType == DeliveryType.quick && !isAuthenticated
        ? DeliveryType.standard
        : widget.initialDeliveryType;
    _loadDashboard();
    // The Quick dashboard is requested lazily, when the Quick tab is used.
    _loadQuickIfNeeded();
  }

  /// Addresses currently known to the AddressBloc, or null while they are
  /// still loading (no Quick request must be made with a partial picture).
  ({Address? selected, List<Address> saved})? _addressSnapshot() {
    final state = context.read<AddressBloc>().state;
    if (state is AddressesLoaded) {
      return (selected: state.selectedAddress, saved: state.addresses);
    }
    if (state is AddressOperationSuccess) {
      return (selected: state.selectedAddress, saved: state.addresses);
    }
    if (state is AddressOperationError) {
      return (selected: state.selectedAddress, saved: state.addresses);
    }
    if (state is AddressError) {
      return (selected: null, saved: const <Address>[]);
    }
    return null; // AddressInitial / AddressLoading
  }

  /// Selected/saved address first, device location only when there is no
  /// saved address at all; never invented coordinates.
  QuickLocation? _resolveQuickLocation({Address? selectedOverride}) {
    final snapshot = _addressSnapshot();
    if (snapshot == null && selectedOverride == null) return null;
    final splash = context.read<SplashCubit>();
    final device = splash.currentLocation;
    return resolveQuickLocation(
      selected: selectedOverride ?? snapshot?.selected,
      saved: snapshot?.saved ?? const <Address>[],
      deviceLatitude: device?.latitude,
      deviceLongitude: device?.longitude,
      deviceAllowed: splash.hasLocationPermission,
    );
  }

  /// Requests the Quick dashboard when the Quick tab is in use, the user is
  /// signed in and the location differs from the last request. Called on
  /// address / auth / tab changes; it never loops because the last requested
  /// location is compared first.
  void _loadQuickIfNeeded({bool force = false, Address? selectedOverride}) {
    if (!mounted || _selectedDeliveryType != DeliveryType.quick) return;
    if (context.read<AuthBloc>().state is! Authenticated) return;

    // Addresses still loading: wait, a partial picture must not trigger a
    // request (nor reset the last requested location).
    if (_addressSnapshot() == null && selectedOverride == null) return;

    final location = _resolveQuickLocation(selectedOverride: selectedOverride);
    if (location == null) {
      _lastQuickRequest = null;
      return;
    }
    if (!force && !shouldReloadQuick(_lastQuickRequest, location)) return;

    _lastQuickRequest = location;
    _log.infoWithContext('Loading express dashboard', {
      'address_id': location.addressId,
      'source': location.source.name,
    });
    context.read<ExpressDashboardBloc>().add(
      ExpressDashboardLoadRequested(
        latitude: location.latitude,
        longitude: location.longitude,
        pincode: location.pincode,
      ),
    );
  }

  void _ensureAddressesLoaded() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return;
    }

    final addressState = context.read<AddressBloc>().state;
    if (addressState is AddressInitial || addressState is AddressError) {
      context.read<AddressBloc>().add(const LoadAddressesEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddressSelectionBottomSheet() async {
    // Guest users must log in before selecting an address.
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      context.push('${AppRoutes.login}?redirectAfter=${Uri.encodeComponent(AppRoutes.home)}');
      return;
    }

    _log.infoWithContext('Opening address selection', {
      'action': 'user_action',
    });

    // Get current selected address from bloc
    Address? currentAddress;
    final addressState = context.read<AddressBloc>().state;
    if (addressState is AddressesLoaded) {
      currentAddress = addressState.selectedAddress;
    }

    final selectedAddress = await AddressSelectionBottomSheet.show(
      context,
      currentAddress: currentAddress,
    );

    if (selectedAddress != null && mounted) {
      // Dispatch event to update selected address in bloc
      context.read<AddressBloc>().add(
        SelectAddressForDeliveryEvent(selectedAddress),
      );
      _log.infoWithContext('Address selected', {
        'address_id': selectedAddress.id,
        'address_label': selectedAddress.displayLabel,
      });
    }
  }

  void _loadDashboard() {
    final location = _resolveQuickLocation();
    final latitude = location?.latitude ?? _standardFallbackLatitude;
    final longitude = location?.longitude ?? _standardFallbackLongitude;
    _log.infoWithContext('Loading dashboard', {
      'latitude': latitude,
      'longitude': longitude,
    });
    context.read<DashboardBloc>().add(
      DashboardLoadRequested(latitude: latitude, longitude: longitude),
    );
  }

  void _refreshDashboard() {
    final location = _resolveQuickLocation();
    final latitude = location?.latitude ?? _standardFallbackLatitude;
    final longitude = location?.longitude ?? _standardFallbackLongitude;
    _log.infoWithContext('Refreshing dashboard', {
      'latitude': latitude,
      'longitude': longitude,
    });
    context.read<DashboardBloc>().add(
      DashboardRefreshRequested(latitude: latitude, longitude: longitude),
    );
  }

  void _refreshExpressDashboard() {
    final location = _resolveQuickLocation();
    if (location == null) return;
    _lastQuickRequest = location;
    _log.infoWithContext('Refreshing express dashboard', {
      'address_id': location.addressId,
      'source': location.source.name,
    });
    context.read<ExpressDashboardBloc>().add(
      ExpressDashboardRefreshRequested(
        latitude: location.latitude,
        longitude: location.longitude,
        pincode: location.pincode,
      ),
    );
  }

  Future<void> _onDeliveryTypeChanged(DeliveryType type) async {
    Address? pickedAddress;
    if (type == DeliveryType.quick) {
      // Guest users must log in before using quick delivery.
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        context.push('${AppRoutes.login}?redirectAfter=${Uri.encodeComponent(AppRoutes.home)}');
        return;
      }

      // Get current selected address from bloc
      Address? currentAddress;
      final addressState = context.read<AddressBloc>().state;
      if (addressState is AddressesLoaded) {
        currentAddress = addressState.selectedAddress;
      }

      // Always show the address selection popup for quick delivery,
      // even if an address is already saved.
      final selectedAddress = await AddressSelectionBottomSheet.show(
        context,
        currentAddress: currentAddress,
      );

      if (selectedAddress == null) {
        return;
      }

      if (!mounted) return;
      pickedAddress = selectedAddress;
      // Dispatch event to update selected address in bloc
      context.read<AddressBloc>().add(
        SelectAddressForDeliveryEvent(selectedAddress),
      );
    }

    setState(() {
      _selectedDeliveryType = type;
    });

    if (type == DeliveryType.quick) {
      // The picked address is passed explicitly: the bloc has not applied the
      // selection yet, and the address listener would otherwise reload again.
      _loadQuickIfNeeded(selectedOverride: pickedAddress);
    }
  }

  /// Pull-to-refresh: re-calls the API of the selected mode and keeps the
  /// spinner until the response (or an error) arrives.
  Future<void> _handleRefresh() async {
    switch (_selectedDeliveryType) {
      case DeliveryType.standard:
        final bloc = context.read<DashboardBloc>();
        if (bloc.state is DashboardLoaded) {
          _refreshDashboard();
        } else {
          _loadDashboard();
        }
        await _waitFor(
          bloc.stream,
          (s) => s is DashboardLoaded || s is DashboardError,
        );
        break;
      case DeliveryType.quick:
        final bloc = context.read<ExpressDashboardBloc>();
        if (_resolveQuickLocation() == null) break;
        if (bloc.state is ExpressDashboardLoaded) {
          _refreshExpressDashboard();
        } else {
          _loadQuickIfNeeded(force: true);
        }
        await _waitFor(
          bloc.stream,
          (s) =>
              s is ExpressDashboardLoaded ||
              s is ExpressDashboardError ||
              s is ExpressDashboardNotServiceable,
        );
        break;
      case DeliveryType.services:
        // Recreating the services content (new key) fetches the services and
        // banners again.
        setState(() => _servicesReloadCount++);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        break;
    }
  }

  Future<void> _waitFor<S>(Stream<S> stream, bool Function(S) done) async {
    try {
      await stream
          .firstWhere(done)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Timed out or the bloc closed: just stop the spinner.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current is Authenticated || current is Unauthenticated,
          listener: (context, state) {
            if (state is Unauthenticated) {
              // Quick is for signed-in users only.
              if (_selectedDeliveryType == DeliveryType.quick) {
                setState(() => _selectedDeliveryType = DeliveryType.standard);
              }
              _lastQuickRequest = null;
              return;
            }
            _ensureAddressesLoaded();
            _loadQuickIfNeeded();
          },
        ),
        BlocListener<AddressBloc, AddressState>(
          listener: (context, state) {
            // The selected delivery address is maintained in AddressBloc.
            // Reload Quick only when the selected address/coordinates changed.
            _loadQuickIfNeeded();
          },
        ),
      ],
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, dashboardState) {
          // Get selected address from AddressBloc
          Address? selectedAddress;
          final addressState = context.watch<AddressBloc>().state;
          if (addressState is AddressesLoaded) {
            selectedAddress = addressState.selectedAddress;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // Festive artwork, always edge-to-edge (full width) and
                // fading into white below the header.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Align(
                        key: ValueKey(_selectedDeliveryType),
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          HomeModeTheme.of(
                            _selectedDeliveryType,
                          ).backgroundAsset,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    BlocBuilder<ExpressDashboardBloc, ExpressDashboardState>(
                      builder: (context, quickState) => HomeHeader(
                        selectedDeliveryType: _selectedDeliveryType,
                        onDeliveryTypeChanged: _onDeliveryTypeChanged,
                        selectedAddress: selectedAddress,
                        onAddressTap: _showAddressSelectionBottomSheet,
                        quickCategories: _quickCategoriesOf(quickState),
                      ),
                    ),
                    // Only this area scrolls: it starts at the promo banner.
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(child: _buildContent()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedDeliveryType) {
      case DeliveryType.standard:
        return Column(
          children: [
            BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const DashboardShimmer();
                }

                if (state is DashboardError) {
                  return _buildErrorState(state.message, onRetry: _loadDashboard);
                }

                if (state is DashboardLoaded || state is DashboardRefreshing) {
                  final dashboard = state is DashboardLoaded
                      ? state.dashboard
                      : (state as DashboardRefreshing).dashboard;

                  return DashboardContent(dashboard: dashboard);
                }

                return const DashboardShimmer();
              },
            ),
          ],
        );
      case DeliveryType.quick:
        return Column(
          children: [
            BlocBuilder<ExpressDashboardBloc, ExpressDashboardState>(
              builder: (context, state) {
                final location = _resolveQuickLocation();
                final addressesLoading = _addressSnapshot() == null;

                if (location == null) {
                  if (addressesLoading) return const DashboardShimmer();
                  // No address with a valid map location: never call the
                  // Quick API with made-up coordinates.
                  return QuickLocationNeededView(
                    onSelectAddress: _showAddressSelectionBottomSheet,
                  );
                }

                if (state is ExpressDashboardLoading) {
                  return const DashboardShimmer();
                }

                if (state is ExpressDashboardNotServiceable) {
                  return QuickNotServiceableView(
                    message: state.message,
                    onChangeAddress: _showAddressSelectionBottomSheet,
                  );
                }

                if (state is ExpressDashboardError) {
                  return _buildErrorState(
                    state.message,
                    onRetry: () => _loadQuickIfNeeded(force: true),
                  );
                }

                if (state is ExpressDashboardLoaded ||
                    state is ExpressDashboardRefreshing) {
                  final dashboard = state is ExpressDashboardLoaded
                      ? state.dashboard
                      : (state as ExpressDashboardRefreshing).dashboard;

                  return ExpressDashboardContent(
                    dashboard: dashboard,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    onProductTap: (product) {
                      context.push(
                        AppRoutes.productDetails(product.id),
                        extra: {
                          'inStock': product.inStock,
                          'outOfStockMessage': product.outOfStockMessage,
                        },
                      );
                    },
                  );
                }

                return const DashboardShimmer();
              },
            ),
          ],
        );
      case DeliveryType.services:
        return HomeServiceContent(key: ValueKey(_servicesReloadCount));
    }
  }

  List<Category>? _quickCategoriesOf(ExpressDashboardState state) {
    final ExpressDashboardEntity? dashboard = state is ExpressDashboardLoaded
        ? state.dashboard
        : state is ExpressDashboardRefreshing
        ? state.dashboard
        : null;
    if (dashboard == null) return null;
    for (final section in dashboard.sections) {
      if (section.key == 'Categories') {
        return section.data.whereType<Category>().toList();
      }
    }
    return null;
  }

  Widget _buildErrorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: IndiaGradients.saffronGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
