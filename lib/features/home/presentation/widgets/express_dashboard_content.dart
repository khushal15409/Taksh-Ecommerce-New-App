import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';
import 'package:taksh_e_commerce/features/home/data/models/dashboard_section_model.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/express_dashboard_entity.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_carousel.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_slots.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/category_catalog_section.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/designed_product_section.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/product_section.dart';
import 'package:taksh_e_commerce/features/home/data/models/product_model.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/features/home/presentation/pages/view_all_products_page.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/category.dart';

/// Express dashboard content widget for quick delivery section
class ExpressDashboardContent extends StatelessWidget {
  final ExpressDashboardEntity dashboard;
  final void Function(ProductModel product)? onProductTap;
  final double latitude;
  final double longitude;

  const ExpressDashboardContent({
    super.key,
    required this.dashboard,
    this.onProductTap,
    required this.latitude,
    required this.longitude,
  });

  static final _log = loggerWithContext({
    'feature': 'home',
    'widget': 'ExpressDashboardContent',
  });

  @override
  Widget build(BuildContext context) {
    final sections = dashboard.sections as List<dynamic>;
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

      if (section.hasData && section.products.isNotEmpty) {
        productKeys.add(section.key);

        void onTap(ProductModel product) {
          _log.infoWithContext('Express product tapped', {
            'product_id': product.id,
            'name': product.name,
          });
          onProductTap?.call(product);
        }

        void onViewAllTap() {
          _log.infoWithContext('Express view all tapped', {
            'section': section.key,
          });
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
            child: SectionDesign.usesLayout(section)
                ? DesignedProductSection(
                    section: section,
                    showDeliveryTime: true,
                    onProductTap: onTap,
                    onViewAllTap: onViewAllTap,
                  )
                : ProductSection(
                    section: section,
                    gridColumns: 3,
                    showDeliveryTime: true,
                    onProductTap: onTap,
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
        ...orderedProducts,
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CategoryCatalogSection(
            categories: categoryData,
            deliveryType: 'quick',
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
          _log.infoWithContext('Express banner tapped', {
            'banner_id': banner.id,
            'title': banner.title,
          });
        },
      ),
    );
  }
}
