import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/animated_backdrop.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:taksh_e_commerce/features/splash/presentation/cubit/splash_state.dart';

/// Splash screen that displays app branding while checking authentication
/// No business logic here - purely reactive to AuthBloc state changes
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _splashCompleted = false;
  bool _authResolved = false;
  AuthState? _authState;

  @override
  void initState() {
    super.initState();
    // Initialize splash cubit (permissions, location, minimum duration)
    context.read<SplashCubit>().initialize();
  }

  void _checkNavigationReady() async {
    // Only navigate when both splash and auth are complete
    if (!_splashCompleted || !_authResolved || _authState == null) return;

    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!seenOnboarding) {
      // First launch - show onboarding
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
      return;
    }

    if (_authState is Authenticated) {
      // User is authenticated, prefetch home data then navigate
      context.read<SplashCubit>().prefetchHomeData().then((_) {
        if (mounted) {
          context.go(AppRoutes.home);
        }
      });
    } else if (_authState is Unauthenticated) {
      // Guest users go directly to home; they can browse freely
      context.go(AppRoutes.home);
    }
    // If still loading, BlocListener will handle navigation
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to SplashCubit state
        BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is SplashCompleted) {
              setState(() => _splashCompleted = true);
              _checkNavigationReady();
            } else if (state is SplashError) {
              // Handle splash error - could show a retry dialog
              setState(() => _splashCompleted = true);
              _checkNavigationReady();
            }
          },
        ),
        // Listen to AuthBloc state
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated || state is Unauthenticated) {
              setState(() {
                _authResolved = true;
                _authState = state;
              });
              _checkNavigationReady();
            }
          },
        ),
      ],
      // Branding: festive light backdrop, the Taksh logo, a short promise and
      // three highlights. Navigation logic above is unchanged.
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7EA),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AnimatedBackdrop(
              palette: BackdropPalette.saffron,
              coverage: 1.0,
              fadeBottom: false,
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  FadeSlideIn(
                    offset: -20,
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 22,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 36),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.25),
                            blurRadius: 36,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo/taksh_logo_mark.png',
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 350),
                    child: Text(
                      'Everything you need, in one app',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2A44),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 500),
                    child: Text(
                      'Shopping  •  30-minute delivery  •  Services',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A4630),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 700),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SplashChip(Icons.shopping_bag_rounded, 'Shop'),
                        _SplashChip(Icons.bolt_rounded, 'Express'),
                        _SplashChip(Icons.home_repair_service_rounded, 'Services'),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Made with ♥ in India',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A4630),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SplashChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A44),
            ),
          ),
        ],
      ),
    );
  }
}
