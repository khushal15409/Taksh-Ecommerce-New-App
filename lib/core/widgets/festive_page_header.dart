import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';

/// White rounded-square icon button used on [FestivePageHeader].
class FestiveHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color color;

  const FestiveHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color = const Color(0xFF212121),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip ?? '',
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}

/// Festive orange header (lanterns, sparkles, diya/gift art) with a back
/// button, title and subtitle. Shared by the cart and checkout screens.
class FestivePageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  /// Places the title block to the right of the back button instead of below.
  final bool inlineTitle;

  /// Optional content under the title (e.g. a progress stepper).
  final Widget? bottom;

  /// Opacity of the lantern/sparkle artwork blended into the gradient.
  final double artOpacity;

  const FestivePageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.trailing,
    this.inlineTitle = false,
    this.bottom,
    this.artOpacity = 0.55,
  });

  static const Color _accent = Color(0xFFFF8A1F);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );

    final backButton = FestiveHeaderIconButton(
      icon: Icons.arrow_back_rounded,
      onPressed: onBack,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8431C), Color(0xFFFF8A1F)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Festive artwork (lanterns, sparkles) blended into the gradient.
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: artOpacity,
                child: Image.asset(
                  FestiveHeaderBackdrop.festiveOrangeAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          const Positioned(
            right: 4,
            bottom: 0,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 34,
                    color: Color(0xFFFFE08A),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.card_giftcard_rounded,
                    size: 46,
                    color: Color(0xFFB04BD6),
                  ),
                ],
              ),
            ),
          ),
          if (inlineTitle)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                backButton,
                const SizedBox(width: 16),
                Expanded(child: titleBlock),
                if (trailing != null) trailing!,
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [backButton, if (trailing != null) trailing!],
                ),
                const SizedBox(height: 8),
                titleBlock,
                if (bottom != null) ...[
                  const SizedBox(height: 12),
                  bottom!,
                ],
              ],
            ),
        ],
      ),
    );
  }
}
