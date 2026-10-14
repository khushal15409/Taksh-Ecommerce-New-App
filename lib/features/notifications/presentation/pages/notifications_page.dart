import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:taksh_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:taksh_e_commerce/features/notifications/presentation/widgets/notification_visuals.dart';

const Color _accent = Color(0xFFFF7A00);

/// Notifications list with All / Unread / Offers / Orders tabs, backed by the
/// customer notification API (created from the admin panel).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

enum _Tab { all, unread, offers, orders }

class _NotificationsPageState extends State<NotificationsPage> {
  _Tab _tab = _Tab.all;
  final NotificationsCubit _cubit = getIt<NotificationsCubit>();
  final ScrollController _scroll = ScrollController();

  bool get _isLoggedIn => context.read<AuthBloc>().state is Authenticated;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Guests have no inbox; the page shows a login prompt instead.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isLoggedIn) _cubit.refresh();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      _cubit.loadMore();
    }
  }

  List<AppNotification> _filtered(List<AppNotification> items) {
    switch (_tab) {
      case _Tab.all:
        return items;
      case _Tab.unread:
        return items.where((n) => n.isUnread).toList();
      case _Tab.offers:
        return items.where((n) => n.isOffer).toList();
      case _Tab.orders:
        return items.where((n) => n.isOrder).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: _cubit,
      builder: (context, state) {
        final list = _filtered(state.items);
        final unread = state.items.where((n) => n.isUnread).length;

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
                        // Same width as the back button so the title stays centred.
                        SizedBox(
                          width: 48,
                          child: unread > 0
                              ? IconButton(
                                  tooltip: 'Mark all as read',
                                  onPressed: _cubit.markAllRead,
                                  icon: const Icon(Icons.done_all_rounded, size: 24),
                                  color: Colors.black87,
                                )
                              : null,
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
                          _buildTabs(unread),
                          Expanded(child: _buildBody(state, list)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(NotificationsState state, List<AppNotification> list) {
    if (!_isLoggedIn) {
      return _message(
        'Please log in to see your notifications',
        action: 'Log in',
        onAction: () => context.push(AppRoutes.login),
      );
    }
    if (state.loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (state.error != null && state.items.isEmpty) {
      return _message(
        state.error!,
        action: 'Retry',
        onAction: _cubit.refresh,
      );
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: _cubit.refresh,
      child: list.isEmpty
          // Scrollable so pull-to-refresh also works on an empty list.
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 140),
                Center(
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                12,
                4,
                12,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              itemCount: list.length + (state.loadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i >= list.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accent,
                        ),
                      ),
                    ),
                  );
                }
                final n = list[i];
                return _NotificationCard(
                  notification: n,
                  onTap: () {
                    _cubit.markRead(n);
                    context.push(
                      AppRoutes.notificationDetail,
                      extra: n.copyWith(isUnread: false),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _message(String text, {String? action, VoidCallback? onAction}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(action),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(int unreadCount) {
    final labels = {
      _Tab.all: 'All',
      _Tab.unread: 'Unread ($unreadCount)',
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
