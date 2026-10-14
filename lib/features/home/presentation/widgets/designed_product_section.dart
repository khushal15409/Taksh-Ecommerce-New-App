import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/theme/app_spacing.dart';
import 'package:taksh_e_commerce/features/home/data/models/dashboard_section_model.dart';
import 'package:taksh_e_commerce/features/home/data/models/product_model.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/product_card.dart';

/// Template keys an admin can pick for a dashboard section.
class SectionDesign {
  SectionDesign._();

  static const premium = 'premium';
  static const hotDeals = 'hot_deals';
  static const freshPicks = 'fresh_picks';
  static const spotlight = 'spotlight';
  static const minimal = 'minimal';

  static const all = {premium, hotDeals, freshPicks, spotlight, minimal};

  /// True when [design] is one of the known templates (unknown keys fall back
  /// to the normal product row, so a newer admin never breaks an older app).
  static bool isKnown(String? design) => design != null && all.contains(design);
}

/// A dashboard section drawn with an admin-selected template.
///
/// Shows `rows x itemsPerRow` products (default 2 x 2) as a grid inside the
/// template's frame. Sections with no design use [ProductSection] instead.
class DesignedProductSection extends StatelessWidget {
  final DashboardSectionModel section;
  final Function(ProductModel)? onProductTap;
  final VoidCallback? onViewAllTap;
  final bool showDeliveryTime;

  const DesignedProductSection({
    super.key,
    required this.section,
    this.onProductTap,
    this.onViewAllTap,
    this.showDeliveryTime = false,
  });

  static const _gold = Color(0xFFFFC857);

  int get _perRow => (section.itemsPerRow ?? 2).clamp(1, 4);
  int get _rows => (section.rows ?? 2).clamp(1, 10);

  @override
  Widget build(BuildContext context) {
    final products = section.products;
    if (products.isEmpty) return const SizedBox.shrink();

    final shown = products.take(_rows * _perRow).toList();

    final Widget body;
    switch (section.design) {
      case SectionDesign.premium:
        body = _premium(shown);
      case SectionDesign.hotDeals:
        body = _hotDeals(shown);
      case SectionDesign.freshPicks:
        body = _freshPicks(shown);
      case SectionDesign.spotlight:
        body = _spotlight(shown);
      default:
        body = _minimal(shown);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: body,
    );
  }

  // ── Templates ──────────────────────────────────────────────────────────

  Widget _premium(List<ProductModel> items) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B1B0E), Color(0xFF55391A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            icon: Icons.workspace_premium_rounded,
            iconColor: _gold,
            titleColor: _gold,
            viewAllColor: _gold,
          ),
          const SizedBox(height: 10),
          _grid(items),
        ],
      ),
    );
  }

  Widget _hotDeals(List<ProductModel> items) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: const Color(0xFFFFF1E6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE5242B), Color(0xFFFF8A1F)],
                ),
              ),
              child: _header(
                icon: Icons.bolt_rounded,
                iconColor: Colors.white,
                titleColor: Colors.white,
                viewAllColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: _grid(items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _freshPicks(List<ProductModel> items) {
    const green = Color(0xFF1F7A3E);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDF3E1), Color(0xFFF3FBF4)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB9E2C2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            icon: Icons.eco_rounded,
            iconColor: green,
            titleColor: const Color(0xFF14532D),
            viewAllColor: green,
          ),
          const SizedBox(height: 10),
          _grid(items),
        ],
      ),
    );
  }

  Widget _spotlight(List<ProductModel> items) {
    final first = items.first;
    final rest = items.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          icon: Icons.auto_awesome_rounded,
          iconColor: AppColors.primaryOrange,
          titleColor: AppColors.black,
          viewAllColor: AppColors.black,
        ),
        const SizedBox(height: 10),
        // The first product gets a full-width, taller card.
        SizedBox(
          height: 250,
          child: _card(first, ProductCardVariant.standard),
        ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 10),
          _grid(rest),
        ],
      ],
    );
  }

  Widget _minimal(List<ProductModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          titleColor: AppColors.black,
          viewAllColor: AppColors.black,
          accentBar: true,
        ),
        const SizedBox(height: 10),
        _grid(items),
      ],
    );
  }

  // ── Building blocks ────────────────────────────────────────────────────

  Widget _header({
    IconData? icon,
    Color? iconColor,
    required Color titleColor,
    required Color viewAllColor,
    bool accentBar = false,
  }) {
    return Row(
      children: [
        if (accentBar)
          Container(
            width: 4,
            height: 20,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            section.key,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: titleColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (onViewAllTap != null)
          InkWell(
            onTap: onViewAllTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: viewAllColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: viewAllColor,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _card(ProductModel product, ProductCardVariant variant) {
    return ProductCard(
      product: product,
      variant: variant,
      showDeliveryTime: showDeliveryTime,
      onTap: () => onProductTap?.call(product),
    );
  }

  /// `itemsPerRow` columns, as many rows as the products need (the caller has
  /// already limited the list to rows x itemsPerRow).
  Widget _grid(List<ProductModel> items) {
    const spacing = 10.0;
    final perRow = _perRow;
    final variant =
        perRow >= 4 ? ProductCardVariant.compact : ProductCardVariant.standard;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        // Image area scales with the card width; the rest (name, rating,
        // price, optional delivery chip) is a fixed amount of text.
        final itemHeight =
            itemWidth * 0.95 + 122 + (showDeliveryTime ? 22 : 0);

        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: perRow,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemHeight,
          ),
          itemBuilder: (context, index) => _card(items[index], variant),
        );
      },
    );
  }
}
