import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';

/// Diwali-themed backdrop shared by the login, OTP and guest-wall screens:
/// festive lanterns/fireworks fading into white, then into soft green.
class FestiveAuthBackground extends StatelessWidget {
  final Widget child;

  const FestiveAuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45, 1.0],
          colors: [
            Colors.white,
            Color(0xFFF1F8EC),
            Color(0xFFA9D9AC),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.6,
            child: IgnorePointer(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6, 1.0],
                  colors: [Colors.black, Colors.black, Colors.transparent],
                ).createShader(rect),
                child: Image.asset(
                  'assets/images/diwali/home_categories_diwali_bg.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

const LinearGradient festiveOrangeGradient = LinearGradient(
  colors: [Color(0xFFFF9F3A), Color(0xFFFF7A00)],
);

const LinearGradient festiveGreenGradient = LinearGradient(
  colors: [Color(0xFF2E9E4F), Color(0xFF49BC69)],
);

/// Orange gradient CTA used on the auth screens.
class FestiveGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient gradient;
  final Color shadowColor;

  const FestiveGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient = festiveOrangeGradient,
    this.shadowColor = AppColors.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: enabled ? gradient : null,
        color: enabled ? null : Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Festive artwork pinned to the top of a screen that fades into white.
/// Used behind transparent app bars (cart, checkout, orders, profile…).
class FestiveHeaderBackdrop extends StatelessWidget {
  final String asset;
  final Widget child;

  const FestiveHeaderBackdrop({
    super.key,
    required this.child,
    this.asset = festiveOrangeAsset,
  });

  static const String festiveOrangeAsset =
      'assets/images/diwali/home_categories_diwali_bg.jpg';
  static const String festiveGreenAsset =
      'assets/images/diwali/home_quick_diwali_bg.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                asset,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// White, softly shadowed rounded card used across redesigned screens.
BoxDecoration festiveCardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ],
);

/// Rounded white [Card] with a soft shadow, matching [festiveCardDecoration].
/// Drop-in replacement for `Card` (keeps ink splashes working for children).
Widget festiveCard({
  required Widget child,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  double radius = 16,
  Color color = Colors.white,
  BorderSide side = BorderSide.none,
}) {
  return Card(
    margin: margin,
    elevation: 3,
    color: color,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withOpacity(0.12),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: side,
    ),
    child: child,
  );
}
