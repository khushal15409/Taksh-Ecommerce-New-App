import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/features/app_update/data/app_update_info.dart';

/// The "a new version is available" bottom sheet. Pops `true` for Update now
/// and `false` for Later (or a swipe away).
class OptionalUpdateSheet extends StatelessWidget {
  final AppUpdateInfo info;

  const OptionalUpdateSheet({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.system_update_rounded,
                    color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    info.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(info.message, style: theme.textTheme.bodyMedium),
            if (info.latestVersion.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Version ${info.latestVersion}',
                  style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(info.buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
