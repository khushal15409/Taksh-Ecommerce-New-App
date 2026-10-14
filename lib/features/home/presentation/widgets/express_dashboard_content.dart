import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';
import 'package:taksh_e_commerce/features/home/data/models/dashboard_section_model.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/express_dashboard_entity.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_carousel.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_slots.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/category_catalog_section.dart';
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
    this.latitude = 23.0225,
    this.longitude = 72.5714,
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
        productWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductSection(
              section: section,
              gridColumns: 3,
              showDeliveryTime: true,
              onProductTap: (product) {
                _log.infoWithContext('Express product tapped', {
                  'product_id': product.id,
                  'name': product.name,
                });
                onProductTap?.call(product);
              },
              onViewAllTap: () {
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
              },
            ),
          ),
        );
      }
    }

    // Middle banners sit between the product sections (after the first half).
    final middleBanners = _bannerBlock(bannerSlots[BannerSlot.middle]!);
    if (middleBanners != null) {
      productWidgets.insert(productWidgets.length ~/ 2, middleBanners);
    }
    final topBanners = _bannerBlock(bannerSlots[BannerSlot.top]!);
    final bottomBanners = _bannerBlock(bannerSlots[BannerSlot.bottom]!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topBanners != null) topBanners,
        ...productWidgets,
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
