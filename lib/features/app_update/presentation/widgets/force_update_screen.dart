import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/features/app_update/data/app_update_info.dart';

/// Full-screen, cannot be dismissed: shown while the installed build is below
/// what admin allows. It sits above the whole app, so nothing behind it can be
/// reached until the update is done.
class ForceUpdateScreen extends StatelessWidget {
  final AppUpdateInfo info;
  final bool updating;
  final VoidCallback onUpdate;

  const ForceUpdateScreen({
    super.key,
    required this.info,
    required this.updating,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(Icons.system_update_rounded,
                        size: 48, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    info.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    info.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (info.latestVersion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Version ${info.latestVersion}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: updating ? null : onUpdate,
                      child: updating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Text(info.buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
