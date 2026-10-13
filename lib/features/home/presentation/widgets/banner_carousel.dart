import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';

/// Banner widget for displaying promotional banners.
///
/// A single banner is shown as a static card; multiple banners are shown as an
/// auto-playing slider with page indicators. Renders nothing when empty.
class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final Function(BannerModel)? onBannerTap;
  final double horizontalPadding;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
    this.horizontalPadding = 16,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoPlay;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _currentPage = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlay?.cancel();
    if (widget.banners.length < 2) return;
    _autoPlay = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    // Standard single banner: static card, no slider/indicator.
    if (widget.banners.length == 1) {
      final banner = widget.banners.first;
      return SizedBox(
        height: 180,
        child: _BannerItem(
          banner: banner,
          horizontalPadding: widget.horizontalPadding,
          onTap: () => widget.onBannerTap?.call(banner),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return _BannerItem(
                banner: banner,
                horizontalPadding: widget.horizontalPadding,
                onTap: () => widget.onBannerTap?.call(banner),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 12),
          _PageIndicator(
            itemCount: widget.banners.length,
            currentIndex: _currentPage,
          ),
        ],
      ],
    );
  }
}

/// Individual banner item
class _BannerItem extends StatelessWidget {
  final BannerModel banner;
  final double horizontalPadding;
  final VoidCallback? onTap;

  const _BannerItem({
    required this.banner,
    required this.horizontalPadding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Page indicator dots
class _PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const _PageIndicator({
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
          ),
        ),
      ),
    );
  }
}
