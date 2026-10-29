import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/constants/app_constants.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/core/utils/quick_location.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_event.dart';
import 'package:taksh_e_commerce/features/address/presentation/bloc/address_state.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/quick_state_views.dart';
import 'package:taksh_e_commerce/features/address/presentation/widgets/address_selection_bottom_sheet.dart';
import 'package:taksh_e_commerce/features/categories/presentation/widgets/widgets.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/delivery_type_selector.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/home_mode_theme.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/category.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/product_cubit.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/product_state.dart';

/// Categories page - displays categories on left, subcategories and products on right
class CategoriesPage extends StatefulWidget {
  final int? initialCategoryId;
  final int? initialSubcategoryId;
  final DeliveryType? initialDeliveryType;

  const CategoriesPage({
    super.key,
    this.initialCategoryId,
    this.initialSubcategoryId,
    this.initialDeliveryType,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> _categories = [];
  int _selectedIndex = 0;
  Category? _selectedSubcategory;
  DeliveryType _homeDeliveryType = DeliveryType.standard;
  Address? _selectedAddress;
  bool _hasLoadedInitialProducts = false;

  /// Drives "load next page" for the standard product grid.
  final ScrollController _gridScroll = ScrollController();

  /// Category id the standard grid is currently showing (parent or sub).
  int? _activeCategoryId;

  /// Location the Quick listing was last requested for. Lets the app-wide
  /// address listener reload only when the address really changed, and not a
  /// second time after this page already requested it itself.
  String? _lastQuickKey;

  bool get _isQuickDelivery => _homeDeliveryType == DeliveryType.quick;

  /// Address chosen on this page, else the delivery address selected app-wide.
  Address? get _effectiveAddress {
    if (_selectedAddress != null) return _selectedAddress;
    final state = context.read<AddressBloc>().state;
    return state is AddressesLoaded ? state.selectedAddress : null;
  }

  /// Quick location of the effective address; null when it has no valid
  /// coordinates (the Quick API is then never called).
  QuickLocation? get _quickLocation =>
      quickLocationFromAddress(_effectiveAddress);

  Future<void> _pickQuickAddress() async {
    final selected = await AddressSelectionBottomSheet.show(
      context,
      currentAddress: _effectiveAddress,
    );
    if (selected == null || !mounted) return;
    context.read<AddressBloc>().add(SelectAddressForDeliveryEvent(selected));
    setState(() => _selectedAddress = selected);
    if (_categories.isNotEmpty && _selectedIndex < _categories.length) {
      _fetchProductsForCategory(_categories[_selectedIndex].id);
    }
  }

  @override
  void initState() {
    super.initState();
    _homeDeliveryType = widget.initialDeliveryType ?? DeliveryType.standard;
    _gridScroll.addListener(_maybeLoadMoreProducts);
    context.read<ProductCubit>().fetchCategories(
      deliveryType: _mapApiDeliveryType(_homeDeliveryType),
    );
  }

  @override
  void dispose() {
    _gridScroll
      ..removeListener(_maybeLoadMoreProducts)
      ..dispose();
    super.dispose();
  }

  /// Loads the next page of the standard listing when the grid is scrolled
  /// near its end (or does not fill the screen yet). Quick delivery keeps its
  /// own single-page listing.
  void _maybeLoadMoreProducts() {
    if (!mounted || _isQuickDelivery || !_gridScroll.hasClients) return;
    final categoryId = _activeCategoryId;
    if (categoryId == null) return;

    final position = _gridScroll.position;
    if (position.maxScrollExtent - position.pixels > 300) return;

    context.read<ProductCubit>().fetchMoreProducts(
      categoryId: categoryId,
      limit: AppConstants.defaultPageSize,
    );
  }

  void _fetchProductsForCategory(int categoryId) {
    if (_isQuickDelivery) {
      final location = _quickLocation;
      if (location == null) return;
      _lastQuickKey = location.key;
      context.read<ProductCubit>().fetchExpressProducts(
        categoryId: categoryId,
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } else {
      _activeCategoryId = categoryId;
      context.read<ProductCubit>().fetchProducts(
        categoryId: categoryId,
        page: 1,
        limit: AppConstants.defaultPageSize,
      );
    }
  }

  void _selectCategory(int index) {
    if (_selectedIndex == index && _hasLoadedInitialProducts) return;
    _hasLoadedInitialProducts = true;

    setState(() {
      _selectedIndex = index;
      _selectedSubcategory = null;
    });

    final category = _categories[index];

    // Debug logging
    print('🏷️ Selected category: ${category.name} (id: ${category.id})');
    print('🏷️ Has children: ${category.hasChildren}');
    print('🏷️ Children count: ${category.children?.length ?? 0}');

    // Quick delivery keeps its previous behaviour: first subcategory shown as
    // selected while the parent's products are listed.
    if (_isQuickDelivery && category.hasChildren && category.children!.isNotEmpty) {
      setState(() {
        _selectedSubcategory = category.children!.first;
      });
    }

    // Standard: no subcategory is pre-selected. Choosing a parent lists the
    // products of the parent and all of its subcategories; picking a
    // subcategory in the dropdown narrows the list to that subcategory.
    print(
      '🏷️ Fetching products for category: ${category.name} (id: ${category.id})',
    );
    _fetchProductsForCategory(category.id);
  }

  void _handleSubcategoryChanged(Category? subcategory) {
    if (subcategory != null && _selectedSubcategory?.id != subcategory.id) {
      setState(() => _selectedSubcategory = subcategory);

      // Get the parent category
      final parentCategory = _categories[_selectedIndex];

      // Debug logging
      print(
        '🏷️ Subcategory changed to: ${subcategory.name} (id: ${subcategory.id})',
      );

      // Standard: list only the chosen subcategory. Quick delivery keeps
      // requesting the parent category, as its API expects.
      _fetchProductsForCategory(
        _isQuickDelivery ? parentCategory.id : subcategory.id,
      );
    }
  }

  void _retryFetchCategories() {
    context.read<ProductCubit>().fetchCategories(
      deliveryType: _mapApiDeliveryType(_homeDeliveryType),
    );
  }

  void _retryFetchProducts() {
    _fetchProductsForCategory(
      (_isQuickDelivery ? null : _activeCategoryId) ??
          _categories[_selectedIndex].id,
    );
  }

  void _navigateToHome() {
    context.go(AppRoutes.homeWithDelivery('services'));
  }

  String _mapApiDeliveryType(DeliveryType type) {
    switch (type) {
      case DeliveryType.quick:
        return 'express_30';
      case DeliveryType.standard:
      case DeliveryType.services:
        return 'standard_delivery';
    }
  }

  /// The delivery address selected app-wide in [state], if the state carries one.
  Address? _selectedAddressOf(AddressState state) {
    if (state is AddressesLoaded) return state.selectedAddress;
    if (state is AddressOperationSuccess) return state.selectedAddress;
    if (state is AddressOperationError) return state.selectedAddress;
    return null;
  }

  String? _addressKey(Address? address) {
    final location = quickLocationFromAddress(address);
    if (location != null) return location.key;
    return address == null ? null : 'no-location|${address.id}';
  }

  /// The address was changed somewhere else in the app (Home, product page,
  /// checkout): the app-wide selection wins over this page's own pick, and
  /// the Quick listing is requested again for it.
  void _onSelectedAddressChanged(AddressState state) {
    final selected = _selectedAddressOf(state);
    if (selected == null || !mounted) return;

    if (_selectedAddress != null &&
        _addressKey(_selectedAddress) != _addressKey(selected)) {
      setState(() => _selectedAddress = null);
    }

    if (!_isQuickDelivery ||
        _categories.isEmpty ||
        _selectedIndex >= _categories.length) {
      return;
    }
    final location = quickLocationFromAddress(selected);
    if (location == null || location.key == _lastQuickKey) return;
    _fetchProductsForCategory(_categories[_selectedIndex].id);
  }

  Future<void> _handleDeliveryTypeSelection(DeliveryType type) async {
    if (type == DeliveryType.services) {
      setState(() => _homeDeliveryType = type);
      _navigateToHome();
      return;
    }

    if (type == DeliveryType.quick) {
      // Guest users must log in before using quick delivery.
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        context.push(
          '${AppRoutes.login}?redirectAfter=${Uri.encodeComponent(AppRoutes.categories)}',
        );
        return;
      }

      // Always show the address selection popup for quick delivery,
      // even if an address is already saved.
      final selectedAddress = await AddressSelectionBottomSheet.show(
        context,
        currentAddress: _selectedAddress,
      );

      if (selectedAddress == null) {
        return;
      }

      if (!mounted) return;
      // Same as every other place that picks a delivery address: make it the
      // app-wide selection too, so Home, the product page and checkout agree.
      context.read<AddressBloc>().add(
        SelectAddressForDeliveryEvent(selectedAddress),
      );
      setState(() {
        _selectedAddress = selectedAddress;
      });
    }

    if (_homeDeliveryType == type && _categories.isNotEmpty) {
      // Quick chosen again (maybe with another address): ask the server for the
      // products of the category on screen instead of keeping the old answer.
      if (type == DeliveryType.quick && _selectedIndex < _categories.length) {
        _fetchProductsForCategory(_categories[_selectedIndex].id);
      }
      return;
    }

    setState(() {
      _homeDeliveryType = type;
      _categories = [];
      _selectedIndex = 0;
      _selectedSubcategory = null;
      _hasLoadedInitialProducts = false;
    });

    context.read<ProductCubit>().fetchCategories(
      deliveryType: _mapApiDeliveryType(type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return BlocListener<AddressBloc, AddressState>(
      listenWhen: (previous, current) =>
          _addressKey(_selectedAddressOf(previous)) !=
          _addressKey(_selectedAddressOf(current)),
      listener: (context, state) => _onSelectedAddressChanged(state),
      child: _buildPage(context, topPadding),
    );
  }

  Widget _buildPage(BuildContext context, double topPadding) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Festive artwork: always edge-to-edge, fading into white.
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/images/diwali/home_categories_diwali_bg.jpg',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: topPadding + 8),
              Text(
                AppLocalizations.of(context)!.categoriesTab,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildModeTabs(context),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 14,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      (DeliveryType.standard, l10n.standard),
      (DeliveryType.quick, l10n.quick),
      (DeliveryType.services, l10n.services),
    ];
    return Row(
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                final type = tabs[i].$1;
                final theme = HomeModeTheme.of(type);
                final selected = _homeDeliveryType == type;
                return GestureDetector(
                  onTap: () => _handleDeliveryTypeSelection(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: [theme.accent, theme.accentDark],
                            )
                          : null,
                      color: selected ? null : Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (selected ? theme.accent : Colors.black)
                              .withOpacity(selected ? 0.4 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          theme.tabIcon,
                          size: 16,
                          color: selected ? Colors.white : theme.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tabs[i].$2,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: _handleStateChange,
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError && _categories.isEmpty) {
          return ErrorView(
            message: state.message,
            onRetry: _retryFetchCategories,
          );
        }

        if (_categories.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noCategoriesAvailable),
          );
        }

        return Row(
          children: [
            CategoriesSidebar(
              categories: _categories,
              selectedIndex: _selectedIndex,
              onCategorySelected: _selectCategory,
            ),
            Expanded(child: _buildProductsPanel(state)),
          ],
        );
      },
    );
  }

  void _handleStateChange(BuildContext context, ProductState state) {
    if (state is CategoryLoaded) {
      final categories = state.categories
          .where((cat) => cat.parentId == null)
          .toList();

      // Debug logging
      print('🏷️ Categories loaded: ${categories.length} parent categories');
      for (var cat in categories) {
        print(
          '🏷️   - ${cat.name} (id: ${cat.id}, children: ${cat.children?.length ?? 0})',
        );
      }

      if (categories.isNotEmpty && _categories.isEmpty) {
        setState(() => _categories = categories);

        // Auto-select category/subcategory if provided
        if (widget.initialSubcategoryId != null) {
          final subcategoryMatch = _findParentForSubcategory(
            categories,
            widget.initialSubcategoryId!,
          );

          if (subcategoryMatch != null) {
            _selectCategory(subcategoryMatch.parentIndex);
            setState(() => _selectedSubcategory = subcategoryMatch.subcategory);
            if (!_isQuickDelivery) {
              // Show just the requested subcategory (replaces the parent list).
              _fetchProductsForCategory(subcategoryMatch.subcategory.id);
            }
            return;
          }
        }

        if (widget.initialCategoryId != null) {
          final index = categories.indexWhere(
            (cat) => cat.id == widget.initialCategoryId,
          );
          _selectCategory(index >= 0 ? index : 0);
        } else {
          _selectCategory(0);
        }
      }
    }
  }

  _SubcategoryMatch? _findParentForSubcategory(
    List<Category> categories,
    int subcategoryId,
  ) {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      if (category.children == null || category.children!.isEmpty) continue;

      for (final child in category.children!) {
        if (child.id == subcategoryId) {
          return _SubcategoryMatch(parentIndex: i, subcategory: child);
        }
      }
    }

    return null;
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(
              '${AppRoutes.search}?delivery_type=${_isQuickDelivery ? '30_min' : 'normal'}',
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryOrange,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.searchForProducts,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.mic_none_rounded,
                    color: AppColors.primaryOrange,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsPanel(ProductState state) {
    final selectedCategory = _categories[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedCategory.hasChildren) ...[
          SubcategoriesSection(
            key: ValueKey(selectedCategory.id),
            category: selectedCategory,
            selectedSubcategory: _selectedSubcategory,
            onSubcategoryChanged: _handleSubcategoryChanged,
          ),
          const SizedBox(height: 4),
        ],
        Expanded(child: _buildProductsGrid(state)),
      ],
    );
  }

  Widget _buildProductsGrid(ProductState state) {
    if (_isQuickDelivery && _quickLocation == null) {
      return QuickLocationNeededView(onSelectAddress: _pickQuickAddress);
    }

    if (_isQuickDelivery && state is ProductNotServiceable) {
      return QuickNotServiceableView(
        message: state.message,
        onChangeAddress: _pickQuickAddress,
      );
    }

    if (state is ProductListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductError && _categories.isNotEmpty) {
      return ErrorView(message: state.message, onRetry: _retryFetchProducts);
    }

    if (state is! ProductListLoaded ||
        state.paginatedProducts.products.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noProductsFound));
    }

    // A short list may not fill the screen; keep loading pages until it does.
    if (!_isQuickDelivery && state.paginatedProducts.hasNextPage) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeLoadMoreProducts(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrowWidth = constraints.maxWidth < 300;
        final crossAxisCount = constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 250
            ? 2
            : 1;
        final mainAxisExtent = _homeDeliveryType == DeliveryType.quick
            ? (crossAxisCount == 1
                  ? 270.0
                  : crossAxisCount == 2
                  ? 236.0
                  : 226.0)
            : (crossAxisCount == 1
                  ? 250.0
                  : crossAxisCount == 2
                  ? 214.0
                  : 206.0);

        return GridView.builder(
          controller: _gridScroll,
          padding: EdgeInsets.fromLTRB(
            isNarrowWidth ? 8 : 12,
            8,
            isNarrowWidth ? 8 : 12,
            16,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            crossAxisSpacing: isNarrowWidth ? 8 : 12,
            mainAxisSpacing: isNarrowWidth ? 8 : 12,
          ),
          itemCount: state.paginatedProducts.products.length,
          itemBuilder: (context, index) => CategoryProductCard(
            product: state.paginatedProducts.products[index],
            showDeliveryTime: _homeDeliveryType == DeliveryType.quick,
          ),
        );
      },
    );
  }
}

class _SubcategoryMatch {
  final int parentIndex;
  final Category subcategory;

  const _SubcategoryMatch({
    required this.parentIndex,
    required this.subcategory,
  });
}
