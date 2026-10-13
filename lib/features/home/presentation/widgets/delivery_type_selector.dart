import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/home_mode_theme.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

enum DeliveryType {
  quick,
  standard,
  services,
}

/// Delivery type selector with tabs for quick, standard, and services
/// Uses Indian flag tricolor theme
class DeliveryTypeSelector extends StatelessWidget {
  final DeliveryType selectedDeliveryType;
  final ValueChanged<DeliveryType> onDeliveryTypeChanged;

  const DeliveryTypeSelector({
    super.key,
    required this.selectedDeliveryType,
    required this.onDeliveryTypeChanged,
  });

  static final _log =
      loggerWithContext({'feature': 'home', 'widget': 'DeliveryTypeSelector'});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildDeliveryTab(
          DeliveryType.standard,
          l10n.standardDelivery.replaceAll(' ', '\n'),
        ),
        const SizedBox(width: 6),
        _buildDeliveryTab(
          DeliveryType.quick,
          l10n.quickDelivery.replaceAll(' ', '\n'),
        ),
        const SizedBox(width: 6),
        _buildDeliveryTab(
          DeliveryType.services,
          l10n.homeService.replaceAll(' ', '\n'),
        ),
      ],
    );
  }

  Widget _buildDeliveryTab(DeliveryType type, String label) {
    final isSelected = selectedDeliveryType == type;
    final theme = HomeModeTheme.of(type);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onDeliveryTypeChanged(type);
          _log.infoWithContext(
            'Delivery type changed',
            {'type': type.name},
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.accent, theme.accentDark],
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.55)
                  : theme.accent.withOpacity(0.14),
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? theme.accent : Colors.black)
                    .withOpacity(isSelected ? 0.45 : 0.08),
                blurRadius: isSelected ? 12 : 8,
                offset: Offset(0, isSelected ? 5 : 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withOpacity(0.22)
                      : theme.accentSoft,
                ),
                child: Icon(
                  theme.tabIcon,
                  size: 14,
                  color: isSelected ? Colors.white : theme.accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
