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

  /// "Day sky": pale blue sky, warm sun, soft blue hills.
  static const saffron = BackdropPalette(
    top: Color(0xFFA9D9FF),
    mid: Color(0xFFEEF8FF),
    glowA: Color(0xFFFFF0B8),
    glowB: Color(0xFFFFD3E0),
    spark: Color(0xFF6FB6F5),
    blobs: [
      Color(0xFF9CCBFF),
      Color(0xFFC6E4FF),
      Color(0xFFFFDCD0),
    ],
  );

  /// "Mint dawn": pale mint sky, cream sun, aqua hills.
  static const emerald = BackdropPalette(
    top: Color(0xFFA0EBD4),
    mid: Color(0xFFE9FBF5),
    glowA: Color(0xFFFFF8C4),
    glowB: Color(0xFFB2E2FF),
    spark: Color(0xFF3FCFA3),
    blobs: [
      Color(0xFF8FE3C8),
      Color(0xFFBEF2E0),
      Color(0xFFAAD9FF),
    ],
  );

  /// "Lilac twilight": pale lavender sky, pink sun, lilac hills.
  static const royal = BackdropPalette(
    top: Color(0xFFCBBEFF),
    mid: Color(0xFFF3EEFF),
    glowA: Color(0xFFFFE2F3),
    glowB: Color(0xFFFFC4E4),
    spark: Color(0xFF9A82FF),
    blobs: [
      Color(0xFFB8A8FF),
      Color(0xFFD9CEFF),
      Color(0xFFFFCCE5),
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

  static const int _starCount = 40;

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

    // Sky: deep tint at the top melting into a pale horizon.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.top, palette.mid],
        ).createShader(rect),
    );

    // Sun / moon orb: slowly breathing glow with a soft halo.
    final breathe = 0.5 + 0.5 * math.sin(t * tau);
    final sun = Offset(w * 0.78 + math.sin(t * tau) * 6, h * 0.30);
    final halo = w * (0.46 + 0.06 * breathe);
    canvas.drawCircle(
      sun,
      halo,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.glowA.withOpacity(0.85),
            palette.glowA.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: halo)),
    );
    canvas.drawCircle(
      sun,
      w * (0.085 + 0.008 * breathe),
      Paint()..color = palette.glowA.withOpacity(0.95),
    );

    // Drifting clouds: blurred pill shapes sliding left to right.
    for (var i = 0; i < 4; i++) {
      final r = math.Random(i * 53 + 5);
      final cw = w * (0.32 + r.nextDouble() * 0.22);
      final ch = cw * 0.22;
      final x = ((t + r.nextDouble()) % 1.0) * (w + cw * 2) - cw;
      final y = h * (0.10 + 0.4 * r.nextDouble());
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: cw, height: ch),
          Radius.circular(ch),
        ),
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // Layered rolling hills, each swaying at its own pace.
    for (var k = 0; k < palette.blobs.length; k++) {
      final base = h * (0.46 + 0.12 * k);
      final amp = h * (0.05 + 0.015 * k);
      final dir = k.isEven ? 1.0 : -1.0;
      final path = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w + 6; x += 6) {
        final y = base +
            amp * math.sin((x / w) * tau * (0.9 + 0.35 * k) + dir * t * tau) +
            amp * 0.35 * math.sin((x / w) * tau * 2.3 - dir * t * tau * 2);
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..close();
      final hill = Rect.fromLTWH(0, base - amp * 1.4, w, h - base + amp * 1.4);
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.blobs[k].withOpacity(0.75),
              palette.blobs[k].withOpacity(0.25),
            ],
          ).createShader(hill),
      );
    }

    // Twinkling stars: dim -> full -> dim, each on its own beat.
    for (var i = 0; i < _starCount; i++) {
      final r = math.Random(i * 7919 + 13);
      final x = r.nextDouble() * w;
      final y = r.nextDouble() * h * 0.7;
      final freq = 4 + r.nextInt(7);
      final wave = 0.5 + 0.5 * math.sin((t * freq + r.nextDouble()) * tau);
      final twinkle = wave * wave * wave;
      final base = 2.5 + r.nextDouble() * 5.0;
      final p = Offset(x, y);
      final a = 0.08 + 0.92 * twinkle;
      canvas.drawCircle(
        p,
        base * (1.2 + 2.2 * twinkle),
        Paint()..color = palette.spark.withOpacity(0.22 * twinkle),
      );
      _star(
        canvas,
        p,
        base * (0.45 + 1.0 * twinkle),
        Paint()..color = palette.spark.withOpacity(a),
      );
      canvas.drawCircle(
        p,
        base * 0.2 * (0.5 + twinkle),
        Paint()..color = Colors.white.withOpacity(a),
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
          stops: [0.0, 0.62, 1.0],
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
