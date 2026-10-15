import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/address/domain/entities/address.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/address_header_widget.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/delivery_type_selector.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/home_mode_theme.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/category.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/product_cubit.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/product_state.dart';

/// Fixed Home header: logo/address/bell row, search bar, delivery-mode tabs and
/// the categories strip. Lives above the scroll view so scrolling starts at the
/// promo banner.
class HomeHeader extends StatefulWidget {
  final DeliveryType selectedDeliveryType;
  final ValueChanged<DeliveryType> onDeliveryTypeChanged;
  final Address? selectedAddress;
  final VoidCallback onAddressTap;

  const HomeHeader({
    super.key,
    required this.selectedDeliveryType,
    required this.onDeliveryTypeChanged,
    this.selectedAddress,
    required this.onAddressTap,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  static const String _homeLogoAssetPath = 'assets/images/logo/taksh_logo_tight.png';
  static final _log = loggerWithContext({
    'feature': 'home',
    'widget': 'HomeHeader',
  });

  List<Category> _categories = const [];
  bool _isLoading = false;
  late final AnimationController _petalController;
  late final List<_PetalConfig> _petals;

  bool _shouldShowProductCategories(DeliveryType type) {
    return type != DeliveryType.services;
  }

  void _fetchCategoriesForSelectedDeliveryType() {
    context.read<ProductCubit>().fetchCategories(
      deliveryType: _mapApiDeliveryType(widget.selectedDeliveryType),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_shouldShowProductCategories(widget.selectedDeliveryType)) {
      _fetchCategoriesForSelectedDeliveryType();
    }
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    final random = Random(7);
    _petals = List.generate(26, (index) {
      final size = 6.0 + random.nextDouble() * 6.0;
      return _PetalConfig(
        x: random.nextDouble(),
        size: size,
        speed: 0.6 + random.nextDouble() * 0.8,
        drift: 6 + random.nextDouble() * 10,
        opacity: 0.35 + random.nextDouble() * 0.45,
        color: _petalColors[index % _petalColors.length],
        phase: random.nextDouble() * pi * 2,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Single controller drives the sparkle overlay; paused when the user
    // prefers reduced motion.
    if (MediaQuery.of(context).disableAnimations) {
      _petalController.stop();
    } else if (!_petalController.isAnimating) {
      _petalController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDeliveryType != widget.selectedDeliveryType) {
      if (_shouldShowProductCategories(widget.selectedDeliveryType)) {
        _fetchCategoriesForSelectedDeliveryType();
      } else if (_categories.isNotEmpty || _isLoading) {
        setState(() {
          _categories = const [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _petalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final showCategoriesStrip = _shouldShowProductCategories(
      widget.selectedDeliveryType,
    );

    // --- Widget sizes (what you see) ---
    const double logoRowHeight = 48.0;
    const double searchBarHeight = 44.0;
    const double deliverySelectorHeight = 60.0;
    final double categoriesStripHeight = showCategoriesStrip ? 74.0 : 0.0;

    // --- Spacing / padding (gaps around widgets) ---
    const double logoSearchGap = 10.0;
    const double searchDeliveryGap = 6.0;
    const double deliveryPaddingV = 6.0;

    // Services tab: the address picker is hidden and its spot holds the search
    // box, so the separate search row below is dropped for this tab only.
    final isServices = widget.selectedDeliveryType == DeliveryType.services;

    final modeTheme = HomeModeTheme.of(widget.selectedDeliveryType);

    // Fixed (non-collapsing) header: the festive artwork painted by HomePage
    // shows through, only the content below it scrolls.
    return Stack(
      children: [
        Positioned.fill(child: _buildSparkles(modeTheme.sparkle)),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: topPadding + 2),
            // Logo + Address + Notification row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: logoRowHeight,
                child: Row(
                  children: [
                    _buildLogo(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: isServices
                          ? SizedBox(
                              height: 44,
                              child: _buildSearchBar(context, compact: true),
                            )
                          : AddressHeaderWidget(
                              selectedAddress: widget.selectedAddress,
                              onTap: widget.onAddressTap,
                            ),
                    ),
                    const SizedBox(width: 8),
                    _buildNotificationButton(),
                  ],
                ),
              ),
            ),
            if (!isServices) ...[
              const SizedBox(height: logoSearchGap),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: searchBarHeight,
                  child: _buildSearchBar(context),
                ),
              ),
            ],
            const SizedBox(height: searchDeliveryGap),
            // Delivery Type Selector
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: deliveryPaddingV,
              ),
              child: SizedBox(
                height: deliverySelectorHeight,
                child: DeliveryTypeSelector(
                  selectedDeliveryType: widget.selectedDeliveryType,
                  onDeliveryTypeChanged: widget.onDeliveryTypeChanged,
                ),
              ),
            ),
            // Categories horizontal strip
            if (showCategoriesStrip)
              SizedBox(
                height: categoriesStripHeight,
                child: _buildCategoriesStrip(),
              ),
            const SizedBox(height: 6),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo() {
    // Same Taksh logo, now a cleaned-up high-resolution copy cropped to the
    // artwork (the old file was a small image scaled down 8x, which made it
    // look soft). The box is a little wider so the wordmark is bigger and sharp.
    const double logoHeight = 44.0;
    const double logoWidth = 92.0;
    const double logoRadius = 12.0;

    return Container(
      height: logoHeight,
      width: logoWidth,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(logoRadius),
      ),
      child: Image.asset(
        _homeLogoAssetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text(
            'Taksh',
            style: TextStyle(
              color: AppColors.secondaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }

  bool _badgeRequested = false;

  Widget _buildNotificationButton() {
    final notifications = getIt<NotificationsCubit>();

    // Sync the badge with the signed-in user: load on login, clear on logout.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is Authenticated || current is Unauthenticated,
      listener: (context, state) {
        if (state is Authenticated) {
          notifications.refreshBadge();
        } else {
          notifications.clear();
        }
      },
      child: _notificationButtonBody(notifications),
    );
  }

  Widget _notificationButtonBody(NotificationsCubit notifications) {
    // Already signed in when the header is built (listener only sees changes).
    if (!_badgeRequested && context.read<AuthBloc>().state is Authenticated) {
      _badgeRequested = true;
      notifications.refreshBadge();
    }

    return GestureDetector(
      onTap: () {
        _log.infoWithContext('Notification button tapped', {
          'action': 'user_action',
        });
        context.push(AppRoutes.notifications);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
              size: 22,
            ),
            // Unread count from the notification API; hidden when there is none.
            BlocBuilder<NotificationsCubit, NotificationsState>(
              bloc: notifications,
              buildWhen: (a, b) => a.unreadCount != b.unreadCount,
              builder: (context, state) {
                if (state.unreadCount <= 0) return const SizedBox.shrink();
                return Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, {bool compact = false}) {
    return Container(
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
            _log.infoWithContext('Search bar tapped', {
              'action': 'user_action',
            });
            // Search inside the tab the user is on, so Quick products are
            // not offered on the Standard tab (and the other way round).
            final searchDeliveryType = switch (widget.selectedDeliveryType) {
              DeliveryType.quick => '30_min',
              DeliveryType.standard => 'normal',
              DeliveryType.services => null,
            };
            context.push(
              searchDeliveryType == null
                  ? AppRoutes.search
                  : '${AppRoutes.search}?delivery_type=$searchDeliveryType',
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: HomeModeTheme.of(widget.selectedDeliveryType).accent,
                  size: 22,
                ),
                SizedBox(width: compact ? 8 : 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.searchHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (!compact)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: HomeModeTheme.of(widget.selectedDeliveryType).accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.mic_none_rounded,
                    color: HomeModeTheme.of(widget.selectedDeliveryType).accent,
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

  Widget _buildSparkles(Color color) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SparklePainter(_petalController, _petals, color),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildFallingPetals() {
    return IgnorePointer(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return AnimatedBuilder(
              animation: _petalController,
              builder: (context, child) {
                final t = _petalController.value;
                return Stack(
                  children: _petals.map((petal) {
                    final y =
                        ((t * height * petal.speed) + (petal.phase * 10)) %
                            (height + petal.size) -
                        petal.size;
                    final x =
                        (petal.x * width) +
                        sin((t * pi * 2) + petal.phase) * petal.drift;

                    return Positioned(
                      left: x,
                      top: y,
                      child: Transform.rotate(
                        angle: (t * pi * 2) + petal.phase,
                        child: _buildFlower(petal),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlower(_PetalConfig petal) {
    final size = petal.size + 2;
    final petalSize = size * 0.5;
    final centerSize = size * 0.35;
    final petalColor = petal.color.withOpacity(petal.opacity);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: _flowerDot(petalSize, petalColor)),
          Positioned(bottom: 0, child: _flowerDot(petalSize, petalColor)),
          Positioned(left: 0, child: _flowerDot(petalSize, petalColor)),
          Positioned(right: 0, child: _flowerDot(petalSize, petalColor)),
          _flowerDot(centerSize, const Color(0xFFFFF3B0)),
        ],
      ),
    );
  }

  Widget _flowerDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildCategoriesStrip() {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is CategoryLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is CategoryLoaded) {
          setState(() {
            _isLoading = false;
            _categories = state.categories
                .where((category) => category.parentId == null)
                .toList();
          });
        } else if (state is ProductError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        if (_isLoading && _categories.isEmpty) {
          return const SizedBox.shrink();
        }

        if (_categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return InkWell(
              onTap: () {
                final delivery =
                    widget.selectedDeliveryType == DeliveryType.quick
                    ? 'quick'
                    : widget.selectedDeliveryType == DeliveryType.services
                    ? 'services'
                    : 'standard';
                context.go(
                  AppRoutes.categoriesToCategory(
                    category.id,
                    deliveryType: delivery,
                  ),
                );
                _log.infoWithContext('Category tapped', {
                  'category_id': category.id,
                  'name': category.name,
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCategoryIcon(category),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  Widget _buildCategoryIcon(Category category) {
    const double iconSize = 42.0;
    final iconUrl = category.iconUrl ?? category.imageUrl;

    final accent = HomeModeTheme.of(widget.selectedDeliveryType).accent;
    final fallback = Icon(
      _iconForCategoryName(category.name),
      size: 22,
      color: accent,
    );

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: (iconUrl == null || iconUrl.isEmpty)
            ? fallback
            : Padding(
                padding: const EdgeInsets.all(3),
                child: CachedNetworkImage(
                  imageUrl: iconUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => fallback,
                ),
              ),
      ),
    );
  }

  IconData _iconForCategoryName(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('pizza')) return Icons.local_pizza;
    if (lower.contains('fast')) return Icons.fastfood;
    if (lower.contains('burger')) return Icons.lunch_dining;
    if (lower.contains('restaurant') || lower.contains('dining')) {
      return Icons.restaurant;
    }
    if (lower.contains('dessert') || lower.contains('cake')) {
      return Icons.cake;
    }
    if (lower.contains('beverage') || lower.contains('drink')) {
      return Icons.local_cafe;
    }
    if (lower.contains('coffee') || lower.contains('tea')) {
      return Icons.coffee;
    }
    if (lower.contains('breakfast')) return Icons.breakfast_dining;
    if (lower.contains('snack')) return Icons.cookie;
    if (lower.contains('bakery') || lower.contains('bread')) {
      return Icons.bakery_dining;
    }
    if (lower.contains('seafood') || lower.contains('fish')) {
      return Icons.set_meal;
    }
    if (lower.contains('fruit')) return Icons.local_florist;
    if (lower.contains('vegetable') || lower.contains('vegg')) {
      return Icons.spa;
    }
    if (lower.contains('meat') || lower.contains('chicken')) {
      return Icons.set_meal;
    }
    if (lower.contains('grocery')) return Icons.storefront;

    return Icons.category_outlined;
  }
}

class _SparklePainter extends CustomPainter {
  final Animation<double> animation;
  final List<_PetalConfig> petals;
  final Color color;

  _SparklePainter(this.animation, this.petals, this.color)
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * pi * 2;
    final paint = Paint();
    for (final p in petals) {
      final twinkle = (sin(t * p.speed.round().clamp(1, 2) + p.phase) + 1) / 2;
      final dx = p.x * size.width;
      final dy = (p.phase / (pi * 2)) * size.height;
      paint.color = color.withOpacity(0.15 + 0.6 * twinkle * p.opacity);
      canvas.drawCircle(Offset(dx, dy), 0.8 + p.size * 0.18 * twinkle, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.color != color;
}

class _PetalConfig {
  final double x;
  final double size;
  final double speed;
  final double drift;
  final double opacity;
  final Color color;
  final double phase;

  const _PetalConfig({
    required this.x,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.color,
    required this.phase,
  });
}

const List<Color> _petalColors = [
  Color(0xFFFFB7D5),
  Color(0xFFFFC4A3),
  Color(0xFFFFE29A),
  Color(0xFFC9F2D2),
  Color(0xFFBFE7FF),
];
