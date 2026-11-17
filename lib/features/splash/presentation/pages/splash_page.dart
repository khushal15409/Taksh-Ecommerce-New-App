import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      // Branding (reference design): light mint-white page, the Taksh logo with its
      // tagline, a shopping illustration and a green loading bar. Navigation logic
      // above is unchanged.
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeSlideIn(
                offset: -16,
                duration: const Duration(milliseconds: 700),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Image.asset(
                    'assets/images/logo/taksh_logo_mark.png',
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const FadeSlideIn(
                delay: Duration(milliseconds: 250),
                child: Text(
                  'All in One Ecommerce, Logistics & Services',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D4A5C),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Flexible(
                flex: 6,
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SvgPicture.asset(
                        'assets/images/illustrations/onboarding_shop.svg',
                        width: 360,
                        height: 300,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 5,
                    color: AppColors.secondaryGreen,
                    backgroundColor: Color(0xFFDDEFE3),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
