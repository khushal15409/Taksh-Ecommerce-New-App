import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
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
      // Branding only: the Taksh logo, no text. Navigation logic is unchanged.
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Image.asset(
                  'assets/images/logo/taksh_logo_mark.png',
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
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
            ],
          ),
        ),
      ),
    );
  }
}
