import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:taksh_e_commerce/core/constants/app_constants.dart';
import 'package:taksh_e_commerce/core/routing/app_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/app_error_toast.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';
import 'package:taksh_e_commerce/core/utils/validators.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';

/// OTP verification page
class VerifyOtpPage extends StatefulWidget {
  final String phone;
  final String guestToken;

  /// Optional destination to navigate to after successful login.
  final String? redirectAfter;

  const VerifyOtpPage({
    super.key,
    required this.phone,
    required this.guestToken,
    this.redirectAfter,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleVerifyOtp() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();
      context.read<AuthBloc>().add(
        AuthVerifyOtpRequested(
          phone: widget.phone,
          otp: otp,
          guestToken: widget.guestToken,
        ),
      );
    }
  }

  void _handleResendOtp() {
    // Resend OTP logic
    context.read<AuthBloc>().add(AuthSendOtpRequested(widget.phone));
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryOrange),
            onPressed: () => context.go(AppRoutes.login),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is Authenticated) {
            // Navigate to home page or the original destination
            AppToastMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.loginSuccess),
                backgroundColor: AppColors.secondaryGreen,
              ),
            );
            // go(home) + push(destination) so back/swipe returns to home
            // instead of exiting the app (plain go replaces the whole stack).
            AppRouter.navigateAfterAuth(
              GoRouter.of(context),
              redirectAfter: widget.redirectAfter,
            );
          }

          if (state is AuthOtpSent) {
            AppToastMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.otpResentSuccess),
                backgroundColor: AppColors.secondaryGreen,
              ),
            );
          }

          if (state is AuthError) {
            AppErrorToast.show(context);
          }
        },
        builder: (context, state) {
          return FestiveAuthBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.03),

                      // Icon with tricolor circle
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryGreen.withOpacity(
                                  0.2,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.phonelink_ring_outlined,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // Title
                      Text(
                        AppLocalizations.of(context)!.verifyOtp,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),

                      // Description with tricolor dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.enterOtpDescription(widget.phone),
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: AppColors.grey700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.defaultPadding * 2),

                      // OTP Card
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // OTP input: transparent real field on top of
                            // visual digit boxes (keeps controller/validator).
                            Center(
                              child: SizedBox(
                                width: 4 * 58.0 + 3 * 12.0,
                                child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 58,
                                  child: IgnorePointer(
                                    child: ValueListenableBuilder<
                                      TextEditingValue
                                    >(
                                      valueListenable: _otpController,
                                      builder: (context, value, _) {
                                        return Row(
                                          children: List.generate(
                                            AppConstants.otpLength,
                                            (i) {
                                              final filled =
                                                  i < value.text.length;
                                              final active =
                                                  i == value.text.length;
                                              return Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    left: i == 0 ? 0 : 12,
                                                  ),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: filled
                                                        ? const Color(
                                                            0xFFFFF4E6,
                                                          )
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: Border.all(
                                                      color: active ||
                                                              filled
                                                          ? AppColors
                                                                .primaryOrange
                                                          : theme.dividerColor,
                                                      width:
                                                          active || filled
                                                          ? 2
                                                          : 1.2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    filled
                                                        ? value.text[i]
                                                        : '',
                                                    style: theme
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 24,
                                                          color: AppColors
                                                              .grey900,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: AppConstants.otpLength,
                                  enabled: !_isLoading,
                                  autofocus: true,
                                  showCursor: false,
                                  enableInteractiveSelection: false,
                                  autofillHints: const [
                                    AutofillHints.oneTimeCode,
                                  ],
                                  style: const TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 24,
                                    height: 1.0,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                      AppConstants.otpLength,
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    // The app theme fills inputs; without
                                    // this the field hides the digit boxes.
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 17,
                                    ),
                                  ),
                                  validator: (value) => Validators.getOtpError(
                                    context,
                                    value ?? '',
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleVerifyOtp(),
                                ),
                              ],
                            ),
                              ),
                            ),

                            const SizedBox(
                              height: AppConstants.defaultPadding * 1.5,
                            ),

                            // Verify button with green gradient
                            FestiveGradientButton(
                              gradient: festiveGreenGradient,
                              shadowColor: AppColors.secondaryGreen,
                              onPressed: _isLoading ? null : _handleVerifyOtp,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.verifyOtpButton,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // Resend OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.didNotReceiveCode,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grey700,
                            ),
                          ),
                          if (_resendTimer > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.resendIn(_resendTimer),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.grey800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _isLoading ? null : _handleResendOtp,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryOrange,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.resendOtp,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.defaultPadding * 2),

                      // Bottom tricolor stripe
                      Center(
                        child: Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: IndiaGradients.tricolorHorizontal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
