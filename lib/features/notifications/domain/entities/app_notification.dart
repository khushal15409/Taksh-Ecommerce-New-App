import 'package:flutter/material.dart';

/// Category of a notification. Drives icon, tint and the filter tabs.
enum NotificationType { offer, order, delivery, promotion, review, payment, app }

/// A notification in the customer's inbox. Comes from `GET /notifications`
/// (created in the admin panel); [sample] is only a fallback for previews.
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final Color dotColor;

  /// When it was sent (null for the static [sample] items).
  final DateTime? sentAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
    this.dotColor = const Color(0xFFFF7A00),
    this.sentAt,
  });

  /// Parses one item of `GET /notifications`. Unknown types fall back to
  /// [NotificationType.app] so a newer admin never breaks the list.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final type = _typeFrom(json['type']?.toString());
    final sentAt = DateTime.tryParse(json['sent_at']?.toString() ?? '')?.toLocal();
    return AppNotification(
      id: json['id'].toString(),
      type: type,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timeAgo: sentAt == null ? '' : timeAgoFrom(sentAt),
      isUnread: json['is_read'] != true,
      dotColor: type == NotificationType.delivery
          ? const Color(0xFF3CAE5C)
          : const Color(0xFFFF7A00),
      sentAt: sentAt,
    );
  }

  AppNotification copyWith({bool? isUnread}) => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    timeAgo: timeAgo,
    isUnread: isUnread ?? this.isUnread,
    dotColor: dotColor,
    sentAt: sentAt,
  );

  static NotificationType _typeFrom(String? value) {
    for (final t in NotificationType.values) {
      if (t.name == value) return t;
    }
    return NotificationType.app;
  }

  /// "2m ago", "3h ago", "1d ago", or a date for older ones.
  static String timeAgoFrom(DateTime time, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
  }

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
