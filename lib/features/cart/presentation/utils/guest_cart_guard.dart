import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

/// Returns true when the user may add to the cart. Guests get a clear message
/// and are sent to login instead of the tap silently doing nothing.
bool ensureLoggedInForCart(BuildContext context) {
  if (context.read<AuthBloc>().state is Authenticated) return true;

  final l10n = AppLocalizations.of(context)!;
  AppToast.warning(
    context,
    l10n.loginRequiredTitle,
    message: l10n.loginToAddToCart,
  );
  context.push(
    '${AppRoutes.login}?redirectAfter=${Uri.encodeComponent(AppRoutes.home)}',
  );
  return false;
}
