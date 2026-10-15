import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

/// Shown on the Quick tab when no delivery address with a valid map location
/// is available. No Quick request is made in this state.
class QuickLocationNeededView extends StatelessWidget {
  final VoidCallback onSelectAddress;

  const QuickLocationNeededView({super.key, required this.onSelectAddress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _QuickMessageView(
      icon: Icons.location_on_outlined,
      title: l10n.quickLocationNeededTitle,
      message: l10n.quickLocationNeededBody,
      actionLabel: l10n.selectAddress,
      onAction: onSelectAddress,
    );
  }
}

/// Shown when the server says Quick delivery cannot serve the address. The
/// backend message is displayed as is; there is no automatic redirect.
class QuickNotServiceableView extends StatelessWidget {
  final String? message;
  final VoidCallback onChangeAddress;

  const QuickNotServiceableView({
    super.key,
    this.message,
    required this.onChangeAddress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = (message != null && message!.trim().isNotEmpty)
        ? message!
        : l10n.quickNotServiceableDefault;
    return _QuickMessageView(
      icon: Icons.location_off_outlined,
      title: l10n.quickNotServiceableTitle,
      message: text,
      actionLabel: l10n.changeAddress,
      onAction: onChangeAddress,
    );
  }
}

class _QuickMessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _QuickMessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
