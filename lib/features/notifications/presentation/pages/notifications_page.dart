import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:taksh_e_commerce/features/notifications/presentation/widgets/notification_visuals.dart';

const Color _accent = Color(0xFFFF7A00);

/// Notifications list with All / Unread / Offers / Orders tabs.
/// Currently backed by static data.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

enum _Tab { all, unread, offers, orders }

class _NotificationsPageState extends State<NotificationsPage> {
  _Tab _tab = _Tab.all;
  final List<AppNotification> _items = AppNotification.sample;

  int get _unreadCount => _items.where((n) => n.isUnread).length;

  List<AppNotification> get _filtered {
    switch (_tab) {
      case _Tab.all:
        return _items;
      case _Tab.unread:
        return _items.where((n) => n.isUnread).toList();
      case _Tab.offers:
        return _items.where((n) => n.isOffer).toList();
      case _Tab.orders:
        return _items.where((n) => n.isOrder).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final list = _filtered;

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
                          'Notifications',
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
                  child: Column(
                    children: [
                      _buildTabs(),
                      Expanded(
                        child: list.isEmpty
                            ? const Center(
                                child: Text(
                                  'No notifications',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  12,
                                  4,
                                  12,
                                  MediaQuery.of(context).padding.bottom + 16,
                                ),
                                itemCount: list.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) =>
                                    _NotificationCard(
                                  notification: list[i],
                                  onTap: () => context.push(
                                    AppRoutes.notificationDetail,
                                    extra: list[i],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final labels = {
      _Tab.all: 'All',
      _Tab.unread: 'Unread ($_unreadCount)',
      _Tab.offers: 'Offers',
      _Tab.orders: 'Orders',
    };
    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        children: [
          for (final t in _Tab.values)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _tab = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == t ? _accent : const Color(0xFFF6F2EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    labels[t]!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _tab == t ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visual = NotificationVisual.of(notification.type);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1ECE6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            notification.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 14, left: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black54,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          if (notification.isUnread)
            Positioned(
              left: -5,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: notification.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
