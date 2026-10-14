import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';
import 'package:taksh_e_commerce/features/home/data/models/dashboard_section_model.dart';
import 'package:taksh_e_commerce/features/home/data/models/product_model.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/recent_views_cubit.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/recent_views_state.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_carousel.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_slots.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/category_catalog_section.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/designed_product_section.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/product_section.dart';
import 'package:taksh_e_commerce/features/home/presentation/pages/view_all_products_page.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/recent_views_section.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/category.dart';

/// Dashboard content widget displaying banners and product sections
class DashboardContent extends StatefulWidget {
  final dynamic dashboard;

  const DashboardContent({
    super.key,
    required this.dashboard,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  static final _log =
      loggerWithContext({'feature': 'home', 'widget': 'DashboardContent'});

  @override
  void initState() {
    super.initState();
    // Load recent views when dashboard is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecentViewsCubit>().loadRecentViews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.dashboard.sections as List<dynamic>;
    Map<BannerSlot, List<BannerModel>> bannerSlots = groupBannersBySlot(const []);
    final productWidgets = <Widget>[];
    final productKeys = <String>[];
    List<Category>? categoryData;

    for (final item in sections) {
      final section = item as DashboardSectionModel;

      if (section.key == 'Logo') continue;

      if (section.key == 'Banners') {
        // Hide the whole banner section when admin has no banners for this type.
        if (section.banners.isEmpty) continue;
        bannerSlots = groupBannersBySlot(section.banners);
        continue;
      }

      if (section.key == 'Categories') {
        categoryData = section.categories;
        continue;
      }

      if (section.hasData) {
        productKeys.add(section.key);

        void onProductTap(ProductModel product) {
          _log.infoWithContext(
            'Product tapped',
            {'product_id': product.id, 'name': product.name},
          );
          context.push(
            AppRoutes.productDetails(product.id),
            extra: {
              'inStock': product.inStock,
              'outOfStockMessage': product.outOfStockMessage,
            },
          );
        }

        void onViewAllTap() {
          _log.infoWithContext(
            'View all tapped',
            {'section': section.key},
          );
          context.push(
            AppRoutes.viewAllProducts,
            extra: ViewAllProductsArgs(
              title: section.key,
              products: section.products,
            ),
          );
        }

        productWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            // A section with an admin-picked design uses that template;
            // no design = the normal product row.
            child: SectionDesign.usesLayout(section)
                ? DesignedProductSection(
                    section: section,
                    showDeliveryTime: false,
                    onProductTap: onProductTap,
                    onViewAllTap: onViewAllTap,
                  )
                : ProductSection(
                    section: section,
                    showDeliveryTime: false,
                    onProductTap: onProductTap,
                    onViewAllTap: onViewAllTap,
                  ),
          ),
        );
      }
    }

    // Middle banners: each goes right below the section chosen in the admin
    // panel. A banner with no (or an unavailable) section falls back to the
    // middle of the product sections.
    final middleByKey = <String, List<BannerModel>>{};
    final middleDefault = <BannerModel>[];
    for (final banner in bannerSlots[BannerSlot.middle]!) {
      final target = banner.afterSectionName;
      if (target != null && productKeys.contains(target)) {
        middleByKey.putIfAbsent(target, () => []).add(banner);
      } else {
        middleDefault.add(banner);
      }
    }
    final defaultBlock = _bannerBlock(middleDefault);
    final half = productWidgets.length ~/ 2;
    final orderedProducts = <Widget>[
      // No product sections to split: keep the banner at the top of the list.
      if (defaultBlock != null && half == 0) defaultBlock,
    ];
    for (var i = 0; i < productWidgets.length; i++) {
      orderedProducts.add(productWidgets[i]);
      final block = _bannerBlock(middleByKey[productKeys[i]] ?? const []);
      if (block != null) orderedProducts.add(block);
      if (defaultBlock != null && half > 0 && i == half - 1) {
        orderedProducts.add(defaultBlock);
      }
    }
    final topBanners = _bannerBlock(bannerSlots[BannerSlot.top]!);
    final bottomBanners = _bannerBlock(bannerSlots[BannerSlot.bottom]!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topBanners != null) topBanners,
        // Recent Views Section (moved near top, below banners)
        BlocBuilder<RecentViewsCubit, RecentViewsState>(
          builder: (context, state) {
            if (state is RecentViewsLoaded && state.recentViews.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecentViewsSection(
                  recentViews: state.recentViews,
                  onProductTap: (productId) {
                    _log.infoWithContext(
                      'Recent view tapped',
                      {'product_id': productId},
                    );
                    context.push(AppRoutes.productDetails(productId));
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        ...orderedProducts,
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CategoryCatalogSection(
            categories: categoryData,
            deliveryType: 'standard',
          ),
        ),
        if (bottomBanners != null) bottomBanners,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget? _bannerBlock(List<BannerModel> banners) {
    if (banners.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: BannerCarousel(
        banners: banners,
        onBannerTap: (banner) {
          _log.infoWithContext(
            'Banner tapped',
            {'banner_id': banner.id, 'title': banner.title},
          );
          // TODO: Handle banner tap navigation
        },
      ),
    );
  }
}
