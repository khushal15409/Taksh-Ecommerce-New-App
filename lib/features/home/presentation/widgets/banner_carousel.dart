import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';

/// Banner widget for displaying promotional banners.
///
/// A single banner is shown as a static card; multiple banners are shown as an
/// auto-playing slider with page indicators. Renders nothing when empty.
///
/// The slider loops forward (after the last banner it slides on to the first
/// instead of rewinding), pauses while the customer is touching it, and stops
/// while the screen is not visible.
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
  /// The slider is endless: it starts far enough from 0 that swiping back
  /// never runs out of pages. The banner shown is `page % banners.length`.
  static const int _loopStart = 1000;
  static const Duration _autoPlayEvery = Duration(seconds: 4);

  late PageController _pageController;
  int _page = 0;
  Timer? _autoPlay;
  bool _touching = false;

  int get _count => widget.banners.length;
  int get _currentIndex => _count == 0 ? 0 : _page % _count;

  @override
  void initState() {
    super.initState();
    _resetPager();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sameBanners =
        oldWidget.banners.length == widget.banners.length &&
        List.generate(
          widget.banners.length,
          (i) => oldWidget.banners[i].id == widget.banners[i].id,
        ).every((same) => same);
    if (!sameBanners) {
      final old = _pageController;
      _resetPager();
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      _startAutoPlay();
    }
  }

  void _resetPager() {
    final start = _count < 2 ? 0 : _loopStart * _count;
    _page = start;
    _pageController = PageController(initialPage: start);
  }

  void _startAutoPlay() {
    _autoPlay?.cancel();
    if (_count < 2) return;
    _autoPlay = Timer.periodic(_autoPlayEvery, (_) {
      // Skip while the customer is touching the slider, or when this screen
      // is not the one being shown (e.g. another tab is open).
      if (!mounted || _touching || !_pageController.hasClients) return;
      if (!TickerMode.of(context)) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onTouch(bool down) {
    _touching = down;
    // After a manual swipe, wait a full interval before sliding on again.
    if (!down) _startAutoPlay();
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
          child: Listener(
            onPointerDown: (_) => _onTouch(true),
            onPointerUp: (_) => _onTouch(false),
            onPointerCancel: (_) => _onTouch(false),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, page) {
                final banner = widget.banners[page % _count];
                return _BannerItem(
                  banner: banner,
                  horizontalPadding: widget.horizontalPadding,
                  onTap: () => widget.onBannerTap?.call(banner),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PageIndicator(itemCount: _count, currentIndex: _currentIndex),
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
