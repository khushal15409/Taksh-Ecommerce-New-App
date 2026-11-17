import 'package:flutter/material.dart';

/// Colour recipe for [AnimatedBackdrop]: a flat two-stop light gradient.
class BackdropPalette {
  final Color top;
  final Color mid;
  final Color glowA;
  final Color glowB;
  final Color spark;
  final List<Color> blobs;

  const BackdropPalette({
    required this.top,
    required this.mid,
    required this.glowA,
    required this.glowB,
    required this.spark,
    required this.blobs,
  });

  /// Standard: light blue-grey with a faint warm tint.
  static const saffron = BackdropPalette(
    top: Color(0x40FFFFFF),
    mid: Color(0x00FFFFFF),
    glowA: Color(0xFFFFEDDD),
    glowB: Color(0xFFFFEDDD),
    spark: Color(0xFFF97316),
    blobs: [Color(0xFFF97316), Color(0xFFFB923C), Color(0xFFFDBA74)],
  );

  /// Quick: light blue-grey with a faint eco-green tint.
  static const emerald = BackdropPalette(
    top: Color(0x382F7A4B),
    mid: Color(0x002F7A4B),
    glowA: Color(0xFFDCEBE1),
    glowB: Color(0xFFDCEBE1),
    spark: Color(0xFF2F7A4B),
    blobs: [Color(0xFF2F7A4B), Color(0xFF6FB383), Color(0xFF2D5A3D)],
  );

  /// Services: light blue-grey, cool tint.
  static const royal = BackdropPalette(
    top: Color(0x40FFFFFF),
    mid: Color(0x00FFFFFF),
    glowA: Color(0xFFE6ECF2),
    glowB: Color(0xFFE6ECF2),
    spark: Color(0xFF2D5A3D),
    blobs: [Color(0xFF2D5A3D), Color(0xFF2F7A4B), Color(0xFFF97316)],
  );
}

/// Static header backdrop: a light gradient that fades into the page
/// background. (Name kept for existing call sites; it no longer animates.)
///
/// Purely decorative: ignores pointers and never affects layout.
class AnimatedBackdrop extends StatelessWidget {
  final BackdropPalette palette;

  /// Fraction of the available height that the backdrop covers.
  final double coverage;

  /// Fade the backdrop into transparent at its bottom edge (headers).
  final bool fadeBottom;

  const AnimatedBackdrop({
    super.key,
    this.palette = BackdropPalette.saffron,
    this.coverage = 0.42,
    this.fadeBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: coverage.clamp(0.0, 1.0),
        widthFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: fadeBottom
                  ? [palette.top, palette.mid, palette.mid.withOpacity(0)]
                  : [palette.top, palette.mid],
              stops: fadeBottom ? const [0.0, 0.62, 1.0] : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// One-shot entrance animation (fade + slide up) for cards and sections.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offset = 24,
  });

  @override
  Widget build(BuildContext context) {
    final total = duration + delay;
    final startFraction = total.inMilliseconds == 0
        ? 0.0
        : delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(startFraction, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * offset),
          child: child,
        ),
      ),
    );
  }
}
