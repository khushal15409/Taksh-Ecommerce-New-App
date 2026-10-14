import 'package:dartz/dartz.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/error/exceptions.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/notifications/domain/entities/app_notification.dart';

/// One page of the notification inbox.
class NotificationsPageData {
  final List<AppNotification> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  const NotificationsPageData({
    required this.items,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}

/// Talks to the customer notification API (`/notifications`).
class NotificationsRepository {
  final ApiClient _api;

  NotificationsRepository(this._api);

  ResultFuture<NotificationsPageData> fetch({int page = 1, int perPage = 20}) {
    return _guard(() async {
      final response = await _api.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = _data(response.data);
      final rawItems = data['items'];
      final pagination = data['pagination'] is Map
          ? Map<String, dynamic>.from(data['pagination'] as Map)
          : <String, dynamic>{};

      return NotificationsPageData(
        items: rawItems is List
            ? rawItems
                  .whereType<Map>()
                  .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
                  .toList()
            : const [],
        unreadCount: _asInt(data['unread_count']) ?? 0,
        currentPage: _asInt(pagination['current_page']) ?? page,
        lastPage: _asInt(pagination['last_page']) ?? page,
      );
    });
  }

  /// Returns the new unread count.
  ResultFuture<int> markRead(String id) {
    return _guard(() async {
      final response = await _api.post(ApiConstants.markAsRead(id));
      return _asInt(_data(response.data)['unread_count']) ?? 0;
    });
  }

  ResultVoid markAllRead() {
    return _guard(() async {
      await _api.post(ApiConstants.markAllAsRead);
    });
  }

  // ── helpers ──

  DataMap _data(dynamic body) {
    final raw = body is Map ? body['data'] : null;
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  int? _asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');

  ResultFuture<T> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load notifications: $e'));
    }
  }
}
