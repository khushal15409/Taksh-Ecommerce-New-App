import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colour recipe for [AnimatedBackdrop].
class BackdropPalette {
  final Color top;
  final Color mid;
  final Color glowA;
  final Color glowB;
  final Color spark;

  const BackdropPalette({
    required this.top,
    required this.mid,
    required this.glowA,
    required this.glowB,
    required this.spark,
  });

  /// Standard / default (warm saffron).
  static const saffron = BackdropPalette(
    top: Color(0xFFE8590C),
    mid: Color(0xFFFF9A3D),
    glowA: Color(0xFFFFD27A),
    glowB: Color(0xFFFF5E8A),
    spark: Color(0xFFFFF3C4),
  );

  /// Quick delivery (fresh green).
  static const emerald = BackdropPalette(
    top: Color(0xFF0B6B38),
    mid: Color(0xFF32B766),
    glowA: Color(0xFFB8F5C9),
    glowB: Color(0xFF36D1DC),
    spark: Color(0xFFF2FFD8),
  );

  /// Services (royal purple).
  static const royal = BackdropPalette(
    top: Color(0xFF4F13A8),
    mid: Color(0xFF9B5CF0),
    glowA: Color(0xFFE2C8FF),
    glowB: Color(0xFFFF7EB6),
    spark: Color(0xFFFFE9FA),
  );
}

/// Code-drawn, continuously animated header backdrop: a rich gradient with
/// slowly drifting glow orbs, twinkling sparkles and a soft light sweep,
/// fading into white. Replaces the old static festival artwork.
///
/// Purely decorative: ignores pointers and never affects layout.
class AnimatedBackdrop extends StatefulWidget {
  final BackdropPalette palette;

  /// Fraction of the available height that the artwork covers.
  final double coverage;

  const AnimatedBackdrop({
    super.key,
    this.palette = BackdropPalette.saffron,
    this.coverage = 0.42,
  });

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _BackdropPainter(
              t: _controller.value,
              palette: widget.palette,
              coverage: widget.coverage,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final double t;
  final BackdropPalette palette;
  final double coverage;

  _BackdropPainter({
    required this.t,
    required this.palette,
    required this.coverage,
  });

  static const int _sparkCount = 26;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final h = size.height * coverage;
    final rect = Rect.fromLTWH(0, 0, size.width, h);
    final tau = math.pi * 2;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, h), Paint());

    // Base gradient (fades out at the bottom edge via the mask below).
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.top, palette.mid],
        ).createShader(rect),
    );

    // Drifting glow orbs.
    void orb(Color c, double cx, double cy, double r, double phase, double a) {
      final dx = math.sin((t + phase) * tau) * size.width * 0.06;
      final dy = math.cos((t + phase) * tau) * h * 0.05;
      final center = Offset(size.width * cx + dx, h * cy + dy);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [c.withOpacity(a), c.withOpacity(0)],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    orb(palette.glowA, 0.85, 0.15, size.width * 0.55, 0.0, 0.75);
    orb(palette.glowB, 0.10, 0.55, size.width * 0.50, 0.33, 0.45);
    orb(palette.glowA, 0.55, 0.85, size.width * 0.45, 0.66, 0.35);

    // Light sweep: a soft diagonal band travelling across.
    final sweepX = (t * 1.6 - 0.3) * size.width;
    final sweep = Path()
      ..moveTo(sweepX, 0)
      ..lineTo(sweepX + size.width * 0.18, 0)
      ..lineTo(sweepX + size.width * 0.18 - h * 0.35, h)
      ..lineTo(sweepX - h * 0.35, h)
      ..close();
    canvas.drawPath(
      sweep,
      Paint()
        ..color = Colors.white.withOpacity(0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Twinkling sparkles rising slowly.
    for (var i = 0; i < _sparkCount; i++) {
      final r = math.Random(i * 7919 + 13);
      final speed = 0.4 + r.nextDouble() * 0.6;
      final prog = (t * speed + r.nextDouble()) % 1.0;
      final x = r.nextDouble() * size.width +
          math.sin((t + r.nextDouble()) * tau) * 8;
      final y = h * (1 - prog);
      final twinkle = 0.5 + 0.5 * math.sin((t * 3 + r.nextDouble()) * tau);
      final fade = math.sin(prog * math.pi);
      final radius = 1.2 + r.nextDouble() * 2.6;
      final alpha = (0.15 + 0.75 * twinkle) * fade;
      final p = Offset(x, y);
      canvas.drawCircle(
        p,
        radius * 3,
        Paint()..color = palette.spark.withOpacity(alpha * 0.25),
      );
      canvas.drawCircle(
        p,
        radius,
        Paint()..color = palette.spark.withOpacity(alpha),
      );
    }

    // Fade the whole artwork into transparent at the bottom.
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 1.0],
          colors: [Colors.black, Colors.black, Colors.transparent],
        ).createShader(rect),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) =>
      old.t != t || old.palette != palette || old.coverage != coverage;
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
