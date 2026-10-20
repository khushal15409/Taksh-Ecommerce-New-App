import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:taksh_e_commerce/features/notifications/presentation/widgets/notification_visuals.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

const Color _accent = Color(0xFFFF7A00);

/// Notification detail screen: the title, time and full message of the notification the
/// customer opened (sent from the admin panel).
class NotificationDetailPage extends StatelessWidget {
  final AppNotification? notification;

  const NotificationDetailPage({super.key, this.notification});

  void _shopNow(BuildContext context) => context.go(AppRoutes.home);

  void _viewOrders(BuildContext context) => context.go(AppRoutes.orders);

  /// Offers lead to shopping, order / delivery / payment / review notifications to the
  /// customer's orders; a general notification has no action.
  static bool _isOffer(AppNotification n) => n.isOffer;

  static bool _hasOrdersAction(AppNotification n) =>
      n.isOrder ||
      n.type == NotificationType.payment ||
      n.type == NotificationType.review;


  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final n = notification;
    if (n == null) return _buildUnavailable(context);
    final visual = NotificationVisual.of(n.type);

    return Scaffold(
      backgroundColor: const Color(0xFFFFEFD9),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NotificationHeaderBackground(height: 260),
          ),
          Column(
            children: [
              SizedBox(height: top),
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, size: 26),
                      color: Colors.black87,
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48),
                        child: Text(
                          'Notification Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      16,
                      14,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isOffer(n)) ...[
                          _buildHero(context, n),
                          const SizedBox(height: 16),
                        ],
                        _buildBody(context, n, visual),
                        if (_isOffer(n)) ...[
                          const SizedBox(height: 18),
                          _buildActionButton(
                            context,
                            label: 'Shop Now',
                            onTap: () => _shopNow(context),
                          ),
                        ] else if (_hasOrdersAction(n)) ...[
                          const SizedBox(height: 18),
                          _buildActionButton(
                            context,
                            label: AppLocalizations.of(context)!.viewMyOrders,
                            onTap: () => _viewOrders(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppNotification n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/diwali/home_standard_diwali_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFB3172B)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF9E0F25).withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    n.title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1.15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFE7A3),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _shopNow(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9A8),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward,
                              size: 16, color: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppNotification n,
    NotificationVisual visual,
  ) {
    final sentAt = n.sentAt;
    final when = sentAt != null
        ? DateFormat('d MMM yyyy, h:mm a').format(sentAt)
        : n.timeAgo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1ECE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(visual.icon, color: visual.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    if (when.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        when,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SelectableText(
            n.message,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Shown when the screen is opened without a notification (for example after the app
  /// was restored): nothing is invented, the customer is sent back to the list.
  Widget _buildUnavailable(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This notification is not available.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.notifications),
                child: const Text('Back to notifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA340), _accent],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
