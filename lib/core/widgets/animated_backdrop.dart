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

  /// Standard: soft peach-coral. Warm pastel with coral, amber and pink accents.
  static const saffron = BackdropPalette(
    top: Color(0xFFFFD3BF),
    mid: Color(0xFFFFF5EE),
    glowA: Color(0xFFFFE7B8),
    glowB: Color(0xFFFFB5C8),
    spark: Color(0xFFFF9F6B),
    blobs: [
      Color(0xFFFF7A59),
      Color(0xFFFFB84D),
      Color(0xFFFF8FB1),
    ],
  );

  /// Quick: fresh mint. Cool pastel with teal, sky and green accents.
  static const emerald = BackdropPalette(
    top: Color(0xFFC4F1E4),
    mid: Color(0xFFF2FCF8),
    glowA: Color(0xFFD8FFF0),
    glowB: Color(0xFFA9DCFF),
    spark: Color(0xFF3FCFA3),
    blobs: [
      Color(0xFF19B8A0),
      Color(0xFF5CC8FF),
      Color(0xFF7EE0B0),
    ],
  );

  /// Services: soft lilac. Dreamy pastel with violet, pink and sky accents.
  static const royal = BackdropPalette(
    top: Color(0xFFDCD0FF),
    mid: Color(0xFFF7F3FF),
    glowA: Color(0xFFF1E4FF),
    glowB: Color(0xFFFFC4E4),
    spark: Color(0xFF9A82FF),
    blobs: [
      Color(0xFF8B6BFF),
      Color(0xFFFF7AC6),
      Color(0xFF5CC8FF),
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

  /// Fade the artwork into transparent at its bottom edge (headers). Turn off
  /// for full-screen use such as the splash screen.
  final bool fadeBottom;

  const AnimatedBackdrop({
    super.key,
    this.palette = BackdropPalette.saffron,
    this.coverage = 0.42,
    this.fadeBottom = true,
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
              fadeBottom: widget.fadeBottom,
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
  final bool fadeBottom;

  _BackdropPainter({
    required this.t,
    required this.palette,
    required this.coverage,
    required this.fadeBottom,
  });

  static const int _starCount = 34;
  static const int _itemCount = 7;

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

  /// Draws shape [kind] (0 bag, 1 gift, 2 bolt, 3 tag) centred on the origin,
  /// roughly [s] wide, filled with [color] and outlined in white.
  void _item(Canvas canvas, int kind, double s, Color color, double opacity) {
    final fill = Paint()..color = color.withOpacity(0.55 * opacity);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, s * 0.06)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.9 * opacity);
    switch (kind) {
      case 0: // shopping bag
        final body = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, s * 0.08),
            width: s * 0.8,
            height: s * 0.82,
          ),
          Radius.circular(s * 0.14),
        );
        canvas.drawRRect(body, fill);
        canvas.drawRRect(body, line);
        final handle = Path()
          ..moveTo(-s * 0.2, -s * 0.3)
          ..quadraticBezierTo(-s * 0.2, -s * 0.58, 0, -s * 0.58)
          ..quadraticBezierTo(s * 0.2, -s * 0.58, s * 0.2, -s * 0.3);
        canvas.drawPath(handle, line);
        break;
      case 1: // gift box
        final box = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, s * 0.14),
            width: s * 0.78,
            height: s * 0.6,
          ),
          Radius.circular(s * 0.08),
        );
        canvas.drawRRect(box, fill);
        canvas.drawRRect(box, line);
        canvas.drawLine(Offset(0, -s * 0.16), Offset(0, s * 0.44), line);
        final lid = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -s * 0.2),
            width: s * 0.9,
            height: s * 0.2,
          ),
          Radius.circular(s * 0.06),
        );
        canvas.drawRRect(lid, fill);
        canvas.drawRRect(lid, line);
        final bow = Path()
          ..moveTo(0, -s * 0.3)
          ..quadraticBezierTo(-s * 0.3, -s * 0.62, -s * 0.22, -s * 0.3)
          ..moveTo(0, -s * 0.3)
          ..quadraticBezierTo(s * 0.3, -s * 0.62, s * 0.22, -s * 0.3);
        canvas.drawPath(bow, line);
        break;
      case 2: // bolt (express)
        final bolt = Path()
          ..moveTo(s * 0.12, -s * 0.5)
          ..lineTo(-s * 0.3, s * 0.08)
          ..lineTo(-s * 0.02, s * 0.08)
          ..lineTo(-s * 0.14, s * 0.5)
          ..lineTo(s * 0.3, -s * 0.12)
          ..lineTo(s * 0.02, -s * 0.12)
          ..close();
        canvas.drawPath(bolt, fill);
        canvas.drawPath(bolt, line);
        break;
      default: // price tag
        final tag = Path()
          ..moveTo(-s * 0.4, -s * 0.2)
          ..lineTo(s * 0.12, -s * 0.2)
          ..lineTo(s * 0.4, 0)
          ..lineTo(s * 0.12, s * 0.2)
          ..lineTo(-s * 0.4, s * 0.2)
          ..close();
        canvas.drawPath(tag, fill);
        canvas.drawPath(tag, line);
        canvas.drawCircle(Offset(-s * 0.26, 0), s * 0.05, line);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final h = size.height * coverage;
    final w = size.width;
    final rect = Rect.fromLTWH(0, 0, w, h);
    final tau = math.pi * 2;

    canvas.saveLayer(rect, Paint());

    // Light pastel gradient.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.top, palette.mid],
        ).createShader(rect),
    );

    // Soft colour blobs drifting slowly (mesh-gradient feel).
    final blobSpots = [
      (0.15, 0.15, 0, palette.glowA, 0.9),
      (0.88, 0.30, 1, palette.glowB, 0.6),
      (0.40, 0.70, 2, palette.glowA, 0.5),
    ];
    for (final b in blobSpots) {
      final ph = b.$3 / 3;
      final c = Offset(
        w * b.$1 + math.sin((t + ph) * tau) * w * 0.07,
        h * b.$2 + math.cos((t + ph) * tau) * h * 0.05,
      );
      final r = w * 0.55;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [b.$4.withOpacity(b.$5), b.$4.withOpacity(0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Soft wave ribbons.
    for (var k = 0; k < 3; k++) {
      final base = h * (0.52 + 0.14 * k);
      final amp = h * (0.045 + 0.015 * k);
      final dir = k.isEven ? 1.0 : -1.0;
      final path = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w + 6; x += 6) {
        path.lineTo(
          x,
          base +
              amp *
                  math.sin((x / w) * tau * (1 + 0.4 * k) + dir * t * tau),
        );
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = palette.blobs[k].withOpacity(0.10 + 0.03 * k),
      );
    }

    // Floating shopping icons: bob, sway and gently fade in/out.
    for (var i = 0; i < _itemCount; i++) {
      final r = math.Random(i * 211 + 3);
      final kind = i % 4;
      final x0 = w * (0.08 + 0.84 * ((i * 0.37 + 0.11) % 1.0));
      final y0 = h * (0.10 + 0.62 * ((i * 0.61 + 0.07) % 1.0));
      final size0 = w * (0.10 + 0.07 * r.nextDouble());
      final bob = math.sin((t * (1 + i % 2) + r.nextDouble()) * tau);
      final sway = math.sin((t * 2 + r.nextDouble()) * tau);
      final pulse = 0.65 + 0.35 * math.sin((t * 3 + r.nextDouble()) * tau);
      canvas.save();
      canvas.translate(x0 + sway * 8, y0 + bob * 10);
      canvas.rotate(sway * 0.18 + (i.isEven ? -0.12 : 0.12));
      _item(canvas, kind, size0, palette.blobs[i % 3], 0.55 + 0.45 * pulse);
      canvas.restore();
    }

    // Floating translucent bubbles.
    for (var i = 0; i < 6; i++) {
      final r = math.Random(i * 131 + 7);
      final prog = (t * (1 + r.nextInt(2)) + r.nextDouble()) % 1.0;
      final x = w * (0.05 + 0.9 * r.nextDouble()) +
          math.sin((t + r.nextDouble()) * tau) * 10;
      final y = h * (1.05 - prog * 1.1);
      final rad = 8 + r.nextDouble() * 22;
      final fade = math.sin(prog * math.pi);
      canvas.drawCircle(
        Offset(x, y),
        rad,
        Paint()..color = Colors.white.withOpacity(0.30 * fade),
      );
      canvas.drawCircle(
        Offset(x, y),
        rad,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withOpacity(0.8 * fade),
      );
    }

    // Twinkling stars: dim -> full -> dim.
    for (var i = 0; i < _starCount; i++) {
      final r = math.Random(i * 7919 + 13);
      final x = r.nextDouble() * w;
      final y = r.nextDouble() * h * 0.85;
      final freq = 4 + r.nextInt(7);
      final wave = 0.5 + 0.5 * math.sin((t * freq + r.nextDouble()) * tau);
      final twinkle = wave * wave * wave;
      final base = 2.5 + r.nextDouble() * 4.5;
      final p = Offset(x, y);
      final a = 0.1 + 0.9 * twinkle;
      canvas.drawCircle(
        p,
        base * (1.2 + 2.0 * twinkle),
        Paint()..color = palette.spark.withOpacity(0.2 * twinkle),
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

    if (fadeBottom) {
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
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) =>
      old.t != t ||
      old.palette != palette ||
      old.coverage != coverage ||
      old.fadeBottom != fadeBottom;
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
