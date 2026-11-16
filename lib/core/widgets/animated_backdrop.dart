import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colour recipe for [AnimatedBackdrop].
class BackdropPalette {
  final Color top;
  final Color mid;
  final Color glowA;
  final Color glowB;
  final Color spark;

  /// Large blurred colour blobs that drift around (mesh-gradient look).
  final List<Color> blobs;

  const BackdropPalette({
    required this.top,
    required this.mid,
    required this.glowA,
    required this.glowB,
    required this.spark,
    required this.blobs,
  });

  /// "Sunset candy": coral, amber, hot pink and a touch of violet.
  static const saffron = BackdropPalette(
    top: Color(0xFFFF6F61),
    mid: Color(0xFFFFD2A8),
    glowA: Color(0xFFFFF1C9),
    glowB: Color(0xFFFF7EC0),
    spark: Color(0xFFFFFFFF),
    blobs: [
      Color(0xFFFF7A6B),
      Color(0xFFFFB45E),
      Color(0xFFFF5FA8),
      Color(0xFFB28CFF),
      Color(0xFFFFE08A),
    ],
  );

  /// "Aurora lagoon": teal, mint, sky blue and indigo.
  static const emerald = BackdropPalette(
    top: Color(0xFF0FB5A4),
    mid: Color(0xFFCFF8E8),
    glowA: Color(0xFFE6FFF4),
    glowB: Color(0xFF6CC8FF),
    spark: Color(0xFFFFFFFF),
    blobs: [
      Color(0xFF12C2B0),
      Color(0xFF9BF0A8),
      Color(0xFF5CC6FF),
      Color(0xFF7C8CFF),
      Color(0xFFB8FFE0),
    ],
  );

  /// "Cosmic orchid": violet, magenta, cyan and peach.
  static const royal = BackdropPalette(
    top: Color(0xFF8B6BFF),
    mid: Color(0xFFEBDDFF),
    glowA: Color(0xFFF6E4FF),
    glowB: Color(0xFFF472D0),
    spark: Color(0xFFFFFFFF),
    blobs: [
      Color(0xFF8B6BFF),
      Color(0xFFF472D0),
      Color(0xFF6FD3FF),
      Color(0xFFFFB6A0),
      Color(0xFFC9B3FF),
    ],
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

  static const int _sparkCount = 22;
  static const int _ringCount = 6;

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final h = size.height * coverage;
    final w = size.width;
    final rect = Rect.fromLTWH(0, 0, w, h);
    final tau = math.pi * 2;

    canvas.saveLayer(rect, Paint());

    // Base: strong tint at the very top easing into a soft pastel.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.top, palette.mid],
        ).createShader(rect),
    );

    // Mesh-gradient blobs drifting on slow Lissajous paths.
    for (var i = 0; i < palette.blobs.length; i++) {
      final c = palette.blobs[i];
      final fx = 1 + (i % 3);
      final fy = 1 + ((i + 1) % 2);
      final ph = i / palette.blobs.length;
      final cx = w * (0.15 + 0.7 * ((i * 0.37) % 1.0)) +
          math.sin((t * fx + ph) * tau) * w * 0.12;
      final cy = h * (0.12 + 0.7 * ((i * 0.53) % 1.0)) +
          math.cos((t * fy + ph) * tau) * h * 0.08;
      final r = w * (0.5 + 0.08 * math.sin((t + ph) * tau));
      final center = Offset(cx, cy);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [c.withOpacity(0.78), c.withOpacity(0)],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    // Soft top-left sheen so white header text keeps contrast.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 1.1,
          colors: [palette.top.withOpacity(0.35), palette.top.withOpacity(0)],
        ).createShader(rect),
    );

    // Floating glass rings that rise, breathe and fade.
    for (var i = 0; i < _ringCount; i++) {
      final r0 = math.Random(i * 131 + 7);
      final speed = 0.25 + r0.nextDouble() * 0.35;
      final prog = (t * speed * 2 + r0.nextDouble()) % 1.0;
      final x = w * (0.08 + r0.nextDouble() * 0.84) +
          math.sin((t + r0.nextDouble()) * tau) * 10;
      final y = h * (1.05 - prog * 1.1);
      final radius = (14 + r0.nextDouble() * 34) * (0.85 + 0.3 * prog);
      final fade = math.sin(prog * math.pi);
      final center = Offset(x, y);
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = Colors.white.withOpacity(0.10 * fade),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withOpacity(0.55 * fade),
      );
      canvas.drawCircle(
        center.translate(-radius * 0.35, -radius * 0.35),
        radius * 0.18,
        Paint()..color = Colors.white.withOpacity(0.55 * fade),
      );
    }

    // Light sweep: soft diagonal band travelling across.
    final sweepX = (t * 1.6 - 0.3) * w;
    final sweep = Path()
      ..moveTo(sweepX, 0)
      ..lineTo(sweepX + w * 0.16, 0)
      ..lineTo(sweepX + w * 0.16 - h * 0.35, h)
      ..lineTo(sweepX - h * 0.35, h)
      ..close();
    canvas.drawPath(
      sweep,
      Paint()
        ..color = Colors.white.withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Flowing aurora ribbons.
    for (var k = 0; k < 3; k++) {
      final base = h * (0.46 + 0.15 * k);
      final amp = h * (0.05 + 0.02 * k);
      final path = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w + 6; x += 6) {
        final y = base +
            amp *
                math.sin((x / w) * tau * (1 + k * 0.4) +
                    (t * (k.isEven ? 1 : -1)) * tau);
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = (k == 1 ? palette.glowB : Colors.white)
              .withOpacity(k == 1 ? 0.14 : 0.12),
      );
    }

    // Twinkling four-point stars.
    for (var i = 0; i < _sparkCount; i++) {
      final r = math.Random(i * 7919 + 13);
      final x = r.nextDouble() * w;
      final y = r.nextDouble() * h * 0.9;
      final twinkle = 0.5 + 0.5 * math.sin((t * 3 + r.nextDouble()) * tau);
      final size0 = 2.0 + r.nextDouble() * 5.5;
      final p = Offset(x, y);
      canvas.drawCircle(
        p,
        size0 * 1.6,
        Paint()..color = palette.spark.withOpacity(0.12 * twinkle),
      );
      _star(
        canvas,
        p,
        size0 * (0.6 + 0.6 * twinkle),
        Paint()..color = palette.spark.withOpacity(0.35 + 0.6 * twinkle),
      );
    }

    // Fade into transparent at the bottom.
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
