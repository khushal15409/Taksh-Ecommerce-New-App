import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/features/notifications/data/notifications_repository.dart';
import 'package:taksh_e_commerce/features/notifications/domain/entities/app_notification.dart';

class NotificationsState extends Equatable {
  final bool loading;
  final bool loadingMore;
  final List<AppNotification> items;
  final int unreadCount;
  final int page;
  final bool hasMore;
  final String? error;

  const NotificationsState({
    this.loading = false,
    this.loadingMore = false,
    this.items = const [],
    this.unreadCount = 0,
    this.page = 0,
    this.hasMore = false,
    this.error,
  });

  NotificationsState copyWith({
    bool? loading,
    bool? loadingMore,
    List<AppNotification>? items,
    int? unreadCount,
    int? page,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) => NotificationsState(
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    items: items ?? this.items,
    unreadCount: unreadCount ?? this.unreadCount,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props =>
      [loading, loadingMore, items, unreadCount, page, hasMore, error];
}

/// Customer notification inbox. A lazy singleton so the home bell badge and
/// the notifications page share one unread count.
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(const NotificationsState());

  /// Loads page 1 (pull-to-refresh / opening the page).
  Future<void> refresh() async {
    // Keep showing the old list while refreshing; spinner only when empty.
    emit(state.copyWith(loading: state.items.isEmpty, clearError: true));

    final result = await _repository.fetch(page: 1);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (data) => emit(
        NotificationsState(
          items: data.items,
          unreadCount: data.unreadCount,
          page: data.currentPage,
          hasMore: data.hasMore,
        ),
      ),
    );
  }

  /// Unread count only (home bell badge); quietly ignores failures.
  Future<void> refreshBadge() async {
    final result = await _repository.fetch(page: 1, perPage: 1);
    if (isClosed) return;
    result.fold((_) {}, (data) => emit(state.copyWith(unreadCount: data.unreadCount)));
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    emit(state.copyWith(loadingMore: true));

    final result = await _repository.fetch(page: state.page + 1);
    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(loadingMore: false)),
      (data) => emit(
        state.copyWith(
          loadingMore: false,
          items: [...state.items, ...data.items],
          unreadCount: data.unreadCount,
          page: data.currentPage,
          hasMore: data.hasMore,
        ),
      ),
    );
  }

  /// Marks one notification read: the list updates at once, the server follows.
  Future<void> markRead(AppNotification notification) async {
    if (!notification.isUnread) return;

    final updated = [
      for (final n in state.items)
        n.id == notification.id ? n.copyWith(isUnread: false) : n,
    ];
    emit(
      state.copyWith(
        items: updated,
        unreadCount: (state.unreadCount - 1).clamp(0, 1 << 30),
      ),
    );

    final result = await _repository.markRead(notification.id);
    if (isClosed) return;
    result.fold((_) {}, (count) => emit(state.copyWith(unreadCount: count)));
  }

  Future<void> markAllRead() async {
    if (state.unreadCount == 0 && !state.items.any((n) => n.isUnread)) return;

    final previous = state;
    emit(
      state.copyWith(
        items: [for (final n in state.items) n.copyWith(isUnread: false)],
        unreadCount: 0,
      ),
    );

    final result = await _repository.markAllRead();
    if (isClosed) return;
    // Put the list back if the server refused.
    result.fold((_) => emit(previous), (_) {});
  }

  /// Signed out: drop the previous user's notifications.
  void clear() => emit(const NotificationsState());
}
