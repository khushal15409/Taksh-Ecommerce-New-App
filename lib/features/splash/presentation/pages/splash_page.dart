import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
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
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFA43A),
                Color(0xFFFFD9A8),
                Color(0xFFFFF3E0),
                Color(0xFFEAF6E6),
                Color(0xFFBFE6BE),
              ],
              stops: [0, 0.18, 0.42, 0.75, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/redesign/lantern_l.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/redesign/lantern_r.png',
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildLogoCard(),
                    const SizedBox(height: 12),
                    _buildMadeInIndia(context),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Image.asset(
                          'assets/images/redesign/splash_art.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    _buildLoader(context),
                    const SizedBox(height: 18),
                    _buildTrustRow(context),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    // The logo artwork already has its own white background, so it fills the
    // whole card (no inner padding) instead of floating inside it.
    return Container(
      width: 286,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.18),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'docs/splash_logo.jpeg',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _buildMadeInIndia(BuildContext context) {
    Widget line(Color color) =>
        Container(width: 60, height: 3, color: color);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line(AppColors.primaryOrange),
        const SizedBox(width: 10),
        Text(
          AppLocalizations.of(context)!.madeInIndia,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(width: 10),
        line(AppColors.secondaryGreen),
      ],
    );
  }

  Widget _buildLoader(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 62,
          height: 62,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryOrange,
            ),
            backgroundColor: Colors.black.withOpacity(0.08),
          ),
        ),
        const SizedBox(height: 14),
        BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            String message = l10n.initializing;
            if (state is SplashLoading && state.message != null) {
              message = state.message!;
            } else if (state is SplashCompleted) {
              if (!_authResolved) {
                message = l10n.checkingAuthentication;
              } else if (_authState is Authenticated) {
                message = l10n.loadingData;
              }
            }
            return Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                    l10n.splashPreparing,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: AppColors.grey800,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrustRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget cell(IconData icon, String label) => Expanded(
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.secondaryGreen),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.25,
              color: AppColors.grey900,
            ),
          ),
        ],
      ),
    );
    Widget divider() => Container(
      width: 1,
      height: 44,
      color: Colors.black.withOpacity(0.1),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          cell(Icons.local_shipping_rounded, l10n.trustFastDelivery),
          divider(),
          cell(Icons.verified_user_rounded, l10n.trustSecureShopping),
          divider(),
          cell(Icons.workspace_premium_rounded, l10n.trustQualityProducts),
          divider(),
          cell(Icons.favorite_border_rounded, l10n.trustByIndia),
        ],
      ),
    );
  }
}
