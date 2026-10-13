import 'package:flutter/material.dart';

/// Festive promo banner shown at the top of each Home mode.
///
/// The artwork carries its own copy and CTA; [onTap] makes it interactive.
class ModePromoBanner extends StatelessWidget {
  final String asset;
  final Color shadowColor;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const ModePromoBanner({
    super.key,
    required this.asset,
    required this.shadowColor,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 10),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
      duration: Duration(milliseconds: reduceMotion ? 0 : 450),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
      ),
      child: _buildBanner(),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          // Artwork already contains the copy, so it is shown as-is at its
          // natural aspect ratio (no cropping, no overlaid text).
          child: Image.asset(
            asset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
