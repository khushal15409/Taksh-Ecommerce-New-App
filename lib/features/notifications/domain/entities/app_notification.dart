import 'package:flutter/material.dart';

/// Category of a notification. Drives icon, tint and the filter tabs.
enum NotificationType { offer, order, delivery, promotion, review, payment, app }

/// Static (UI-only) notification model. Will be replaced by an API-backed
/// model once the notifications endpoint is available.
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final Color dotColor;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
    this.dotColor = const Color(0xFFFF7A00),
  });

  bool get isOffer =>
      type == NotificationType.offer || type == NotificationType.promotion;

  bool get isOrder =>
      type == NotificationType.order || type == NotificationType.delivery;

  static const List<AppNotification> sample = [
    AppNotification(
      id: '1',
      type: NotificationType.offer,
      title: 'Diwali Special Offer! 🎁',
      message: 'Get up to 50% OFF on groceries, electronics and more!',
      timeAgo: '2m ago',
      isUnread: true,
    ),
    AppNotification(
      id: '2',
      type: NotificationType.order,
      title: 'Your Order is Confirmed',
      message: 'Order #ORD5ENS6NCQ has been confirmed and is being processed.',
      timeAgo: '10m ago',
      isUnread: true,
    ),
    AppNotification(
      id: '3',
      type: NotificationType.delivery,
      title: 'Out for Delivery',
      message: 'Your order #ORDZAWT6MI is out for delivery and will arrive today.',
      timeAgo: '1h ago',
      isUnread: true,
      dotColor: Color(0xFF3CAE5C),
    ),
    AppNotification(
      id: '4',
      type: NotificationType.promotion,
      title: 'Special Deal for You',
      message: 'Flat 20% OFF on selected fashion items. Limited time offer!',
      timeAgo: '3h ago',
    ),
    AppNotification(
      id: '5',
      type: NotificationType.review,
      title: 'Rate Your Order',
      message:
          'How was your experience with Sony Basmati Rice 5kg? Give your rating and help us improve.',
      timeAgo: '5h ago',
    ),
    AppNotification(
      id: '6',
      type: NotificationType.payment,
      title: 'Payment Successful',
      message: 'Your payment for order #ORDZXF4XRI was successful.',
      timeAgo: '1d ago',
    ),
    AppNotification(
      id: '7',
      type: NotificationType.app,
      title: 'App Update Available',
      message:
          'A new version of Taksh app is available. Update now for a better experience.',
      timeAgo: '2d ago',
    ),
  ];
}
