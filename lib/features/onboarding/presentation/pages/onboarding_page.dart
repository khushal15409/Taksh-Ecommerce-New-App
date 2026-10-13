import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

/// Onboarding screen shown only on first app launch.
///
/// Each step has its own background color so the page itself tints to match
/// the step's theme. The tint is interpolated as the user swipes so the
/// transition between pages feels continuous.
///
/// The illustration is rendered in a responsive, rounded-corner card whose
/// size is derived from the available screen width so the layout looks
/// consistent on small phones, large phones, and tablets.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const List<_OnboardingStep> _steps = [
    _OnboardingStep(
      image: 'assets/images/onboarding/onboarding_shop_bg.jpg',
      titleKey: _TitleKey.title1,
      subtitleKey: _TitleKey.subtitle1,
      backgroundColor: Color(0xFFFFF5E8), // Warm cream
    ),
    _OnboardingStep(
      image: 'assets/images/onboarding/onboarding_delivery_bg.jpg',
      titleKey: _TitleKey.title2,
      subtitleKey: _TitleKey.subtitle2,
      backgroundColor: Color(0xFFF0FAEC), // Soft green cream
    ),
    _OnboardingStep(
      image: 'assets/images/onboarding/onboarding_payment_bg.jpg',
      titleKey: _TitleKey.title3,
      subtitleKey: _TitleKey.subtitle3,
      backgroundColor: Color(0xFFF5EEFF), // Soft lavender
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (!_pageController.hasClients) return;
    final newOffset = _pageController.page ?? 0.0;
    if (newOffset != _pageOffset) {
      setState(() {
        _pageOffset = newOffset;
      });
    }
  }

  bool _isCompleting = false;

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    _isCompleting = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Linearly interpolate the page background color as the user swipes
  /// between steps so the color crossfades smoothly.
  Color _interpolatedBackgroundColor() {
    final clampedOffset = _pageOffset.clamp(
      0.0,
      (_steps.length - 1).toDouble(),
    );
    final lowerIndex = clampedOffset.floor();
    final upperIndex = (lowerIndex + 1).clamp(0, _steps.length - 1);
    final t = (clampedOffset - lowerIndex).clamp(0.0, 1.0);

    return Color.lerp(
      _steps[lowerIndex].backgroundColor,
      _steps[upperIndex].backgroundColor,
      t,
    )!;
  }

  String _titleFor(_TitleKey key) {
    final l10n = AppLocalizations.of(context)!;
    return switch (key) {
      _TitleKey.title1 => l10n.onboardingTitle1,
      _TitleKey.title2 => l10n.onboardingTitle2,
      _TitleKey.title3 => l10n.onboardingTitle3,
      _ => '',
    };
  }

  String _subtitleFor(_TitleKey key) {
    final l10n = AppLocalizations.of(context)!;
    return switch (key) {
      _TitleKey.subtitle1 => l10n.onboardingSubtitle1,
      _TitleKey.subtitle2 => l10n.onboardingSubtitle2,
      _TitleKey.subtitle3 => l10n.onboardingSubtitle3,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLastPage = _currentPage == _steps.length - 1;
    final backgroundColor = _interpolatedBackgroundColor();

    final bottomReserve = 8 + 8 + 24 + 54 + 24.0;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            // Swipeable content — full-bleed festive artwork fading into the
            // page tint, with the title/subtitle as real widgets below it.
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Column(
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              step.image,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              gaplessPlayback: true,
                            ),
                            // Fade the artwork into the page colour.
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 90,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      step.backgroundColor.withOpacity(0),
                                      step.backgroundColor,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _titleFor(step.titleKey),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.grey900,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _subtitleFor(step.subtitleKey),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.grey600,
                                      height: 1.45,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            bottomReserve +
                            MediaQuery.of(context).padding.bottom,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Skip button anchored top-right.
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    l10n.skip,
                    style: const TextStyle(
                      color: AppColors.grey900,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page indicator + primary action pinned to the bottom.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageIndicator(
                      count: _steps.length,
                      currentIndex: _currentPage,
                      activeColor: AppColors.primaryOrange,
                      inactiveColor: AppColors.grey300,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? l10n.getStarted : l10n.next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String image;
  final _TitleKey titleKey;
  final _TitleKey subtitleKey;
  final Color backgroundColor;

  const _OnboardingStep({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
    required this.backgroundColor,
  });
}

/// Discriminates which title/subtitle string to read from [AppLocalizations].
/// Keeping the key inside the step avoids two parallel lists.
enum _TitleKey { title1, subtitle1, title2, subtitle2, title3, subtitle3 }

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const _PageIndicator({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 22 : 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
