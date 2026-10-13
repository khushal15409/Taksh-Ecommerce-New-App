import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/features/notifications/domain/entities/app_notification.dart';

/// Icon + tint pair used for a notification type.
class NotificationVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const NotificationVisual(this.icon, this.color, this.background);

  static NotificationVisual of(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return const NotificationVisual(
          Icons.card_giftcard_rounded,
          Color(0xFFE8412C),
          Color(0xFFFFEDE6),
        );
      case NotificationType.order:
        return const NotificationVisual(
          Icons.local_shipping_rounded,
          Color(0xFFFF8A00),
          Color(0xFFFFF1DF),
        );
      case NotificationType.delivery:
        return const NotificationVisual(
          Icons.local_shipping_rounded,
          Color(0xFF3CAE5C),
          Color(0xFFE6F6EA),
        );
      case NotificationType.promotion:
        return const NotificationVisual(
          Icons.percent_rounded,
          Color(0xFFE8412C),
          Color(0xFFFFE9E9),
        );
      case NotificationType.review:
        return const NotificationVisual(
          Icons.star_rounded,
          Color(0xFFFFB400),
          Color(0xFFFFF4D6),
        );
      case NotificationType.payment:
        return const NotificationVisual(
          Icons.account_balance_wallet_rounded,
          Color(0xFF2F6FE4),
          Color(0xFFE4EEFF),
        );
      case NotificationType.app:
        return const NotificationVisual(
          Icons.settings_rounded,
          Color(0xFF2F6FE4),
          Color(0xFFE4EEFF),
        );
    }
  }
}

/// Festive header artwork shared by the list and detail screens.
class NotificationHeaderBackground extends StatelessWidget {
  final double height;

  const NotificationHeaderBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        'assets/images/diwali/home_standard_diwali_bg.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8412C), Color(0xFFFFA340)],
            ),
          ),
        ),
      ),
    );
  }
}
