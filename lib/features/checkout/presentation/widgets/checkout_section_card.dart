import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';

/// White rounded card with a coloured icon tile + title header, used for every
/// checkout section. Pass [expanded] + [onToggle] to make the body collapsible.
class CheckoutSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool? expanded;
  final VoidCallback? onToggle;
  final EdgeInsetsGeometry bodyPadding;

  const CheckoutSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor = AppColors.secondaryGreen,
    this.actionLabel,
    this.onAction,
    this.expanded,
    this.onToggle,
    this.bodyPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = expanded ?? true;

    return Container(
      decoration: festiveCardDecoration(radius: 22),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                  if (actionLabel != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAction,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  if (onToggle != null)
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey900,
                      size: 26,
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: isOpen
                ? Padding(
                    padding: bodyPadding,
                    child: SizedBox(width: double.infinity, child: child),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
