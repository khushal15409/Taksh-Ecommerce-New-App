import 'dart:async';

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

  /// True when the section should be drawn by [DesignedProductSection]: it has
  /// a template, or the admin set a rows / products-per-row layout for it.
  static bool usesLayout(DashboardSectionModel section) =>
      isKnown(section.design) ||
      section.rows != null ||
      section.itemsPerRow != null;
}

/// A dashboard section drawn from the admin's layout settings.
///
/// * `rows` x `itemsPerRow` (up to 10 x 10) decide how many products show.
///   Every row is a horizontal carousel when it holds more products than fit
///   on screen, so even 10 per row stays readable.
/// * `design` picks the frame (premium, hot deals, ...). With no design the
///   section looks like the normal one (plain header, no frame) but still
///   follows rows / products per row.
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

  bool get _hasDesign => SectionDesign.isKnown(section.design);

  // No layout saved: a designed section is 2 x 2, a normal one 1 row x 3
  // (what the plain section always showed).
  int get _perRow => (section.itemsPerRow ?? (_hasDesign ? 2 : 3)).clamp(1, 10);
  int get _rows => (section.rows ?? (_hasDesign ? 2 : 1)).clamp(1, 10);

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
      case SectionDesign.minimal:
        body = _minimal(shown, accentBar: true);
      default:
        body = _minimal(shown, accentBar: false);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: body,
    );
  }

  // ── Templates ──────────────────────────────────────────────────────────

  Widget _premium(List<ProductModel> items) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF241608), Color(0xFF4A3015), Color(0xFF2B1B0E)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft gold glow + faint crown watermark.
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_gold.withOpacity(0.28), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 8,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 64,
              color: _gold.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: _gold,
                  titleColor: _gold,
                  viewAllColor: _gold,
                  subtitle: 'Handpicked premium picks',
                  subtitleColor: Colors.white70,
                ),
                const SizedBox(height: 12),
                _rowsOf(items),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hotDeals(List<ProductModel> items) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5242B).withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0CC), Color(0xFFFFF4EC)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE5242B), Color(0xFFFF6A1F)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _header(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFFFD54F),
                      titleColor: Colors.white,
                      viewAllColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: _rowsOf(items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _freshPicks(List<ProductModel> items) {
    const green = Color(0xFF1F7A3E);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD5EFDA), Color(0xFFF3FBF4)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFA9DDB5)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -6,
            child: Icon(
              Icons.eco_rounded,
              size: 110,
              color: green.withOpacity(0.1),
            ),
          ),
          Positioned(
            left: -14,
            bottom: -10,
            child: Icon(
              Icons.eco_rounded,
              size: 80,
              color: green.withOpacity(0.07),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(
                  icon: Icons.eco_rounded,
                  iconColor: green,
                  titleColor: const Color(0xFF14532D),
                  viewAllColor: green,
                  subtitle: 'Fresh, handpicked for you',
                  subtitleColor: green,
                ),
                const SizedBox(height: 12),
                _rowsOf(items),
              ],
            ),
          ),
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
        // The first product gets a full-width, taller card with a glow.
        Container(
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE3C2), Color(0xFFFFF7EC)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            children: [
              Positioned.fill(child: _card(first)),
              Positioned(
                left: 0,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 4, 12, 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 12),
          _rowsOf(rest),
        ],
      ],
    );
  }

  Widget _minimal(List<ProductModel> items, {required bool accentBar}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          titleColor: AppColors.black,
          viewAllColor: AppColors.black,
          accentBar: accentBar,
        ),
        const SizedBox(height: 10),
        _rowsOf(items),
      ],
    );
  }

  // ── Building blocks ────────────────────────────────────────────────────

  Widget _header({
    IconData? icon,
    Color? iconColor,
    required Color titleColor,
    required Color viewAllColor,
    String? subtitle,
    Color? subtitleColor,
    bool accentBar = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          Icon(icon, size: 26, color: iconColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
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
              if (subtitle != null)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: subtitleColor ?? titleColor,
                  ),
                ),
            ],
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

  Widget _card(ProductModel product) {
    return ProductCard(
      product: product,
      showDeliveryTime: showDeliveryTime,
      onTap: () => onProductTap?.call(product),
    );
  }

  /// [items] split into rows of `itemsPerRow`. Each row is a carousel.
  Widget _rowsOf(List<ProductModel> items) {
    final perRow = _perRow;
    final rows = <List<ProductModel>>[];
    for (var i = 0; i < items.length; i += perRow) {
      rows.add(items.skip(i).take(perRow).toList());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        // At most 3 cards are visible at once; a longer row scrolls sideways
        // (with a peek of the next card) so 10 per row stays readable.
        final visible = perRow.clamp(1, 3);
        final scrolls = perRow > visible;
        final itemWidth =
            (constraints.maxWidth - spacing * (visible - 1)) /
            (scrolls ? visible + 0.3 : visible);
        // Image area follows the card width; the rest (name, rating, price,
        // optional delivery chip) is a fixed amount of text.
        final itemHeight = itemWidth * 0.95 + 112 + (showDeliveryTime ? 22 : 0);

        return Column(
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) const SizedBox(height: spacing),
              _CarouselRow(
                products: rows[r],
                itemWidth: itemWidth,
                itemHeight: itemHeight,
                spacing: spacing,
                scrolls: scrolls,
                // One row can slowly advance by itself, like a banner.
                autoPlay: scrolls && _rows == 1,
                builder: _card,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// One row of product cards. When [scrolls] it is a horizontal carousel with a
/// thin progress bar (and optional auto-advance); otherwise a plain row.
class _CarouselRow extends StatefulWidget {
  final List<ProductModel> products;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final bool scrolls;
  final bool autoPlay;
  final Widget Function(ProductModel) builder;

  const _CarouselRow({
    required this.products,
    required this.itemWidth,
    required this.itemHeight,
    required this.spacing,
    required this.scrolls,
    required this.autoPlay,
    required this.builder,
  });

  @override
  State<_CarouselRow> createState() => _CarouselRowState();
}

class _CarouselRowState extends State<_CarouselRow> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;
  DateTime _lastTouch = DateTime.fromMillisecondsSinceEpoch(0);
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    if (widget.autoPlay) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) => _advance());
    }
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final value = max <= 0 ? 0.0 : (_controller.offset / max).clamp(0.0, 1.0);
    if ((value - _progress).abs() > 0.01) setState(() => _progress = value);
  }

  void _advance() {
    if (!mounted || !_controller.hasClients) return;
    // Leave it alone for a while after the user touched it.
    if (DateTime.now().difference(_lastTouch) < const Duration(seconds: 8)) {
      return;
    }
    final step = widget.itemWidth + widget.spacing;
    final max = _controller.position.maxScrollExtent;
    final next = _controller.offset + step;
    _controller.animateTo(
      next >= max - 4 ? 0 : next,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.products;

    if (!widget.scrolls) {
      return SizedBox(
        height: widget.itemHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              SizedBox(width: widget.itemWidth, child: widget.builder(list[i])),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.itemHeight,
          child: Listener(
            onPointerDown: (_) => _lastTouch = DateTime.now(),
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: list.length,
              separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
              itemBuilder: (context, index) => SizedBox(
                width: widget.itemWidth,
                child: widget.builder(list[index]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Progress bar: how far along the row the user is.
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: 56,
            height: 3,
            child: Stack(
              children: [
                Container(color: Colors.black.withOpacity(0.12)),
                Align(
                  alignment: Alignment(_progress * 2 - 1, 0),
                  child: Container(
                    width: 22,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
