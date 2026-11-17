import 'package:flutter/material.dart';

/// The app-wide page backdrop: one soft, slightly darker light-green/blue image behind
/// every screen. Purely decorative and static (no animation); ignores pointers and never
/// affects layout. Scaffolds are transparent so this shows through on every page.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  static const String asset = 'assets/images/backgrounds/app_background.jpg';

  /// Solid colour shown for the first frame and if the image cannot load.
  static const Color fallback = Color(0xFFF3F9F5);

  @override
  Widget build(BuildContext context) {
    // Dark theme keeps its solid dark surface (the image is a light-theme design).
    if (Theme.of(context).brightness == Brightness.dark) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: child,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: fallback),
        Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        child,
      ],
    );
  }
}

/// Page transition that keeps the background image on every route, so a transparent
/// Scaffold never shows the previous page through it while a route slides in.
class BackgroundPageTransitionsBuilder extends PageTransitionsBuilder {
  final PageTransitionsBuilder inner;

  const BackgroundPageTransitionsBuilder(this.inner);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      AppBackground(child: child),
    );
  }
}
