import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/core/routing/app_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/core/widgets/app_toast.dart';
import 'package:taksh_e_commerce/features/notifications/domain/entities/app_notification.dart';
import 'package:taksh_e_commerce/features/notifications/presentation/cubit/notifications_cubit.dart';

/// Runs when a push arrives while the app is in the background or closed. The system
/// already shows the notification itself (the server sends a `notification` payload), so
/// there is nothing to display here. It must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Not configured on this build: nothing to do in the background either.
  }
}

/// Where a tapped push leads, after its data has been validated: an order's details, or a
/// notification from the admin panel (opened from the app's notification section).
@immutable
class PushTarget {
  final int? orderId;
  final int? notificationId;

  const PushTarget.order(int this.orderId) : notificationId = null;

  const PushTarget.notification(int this.notificationId) : orderId = null;

  /// Where an order push goes; a notification push opens the inbox when its own item
  /// cannot be found (see [PushNotificationService]).
  String get path => orderId != null
      ? AppRoutes.orderDetails(orderId.toString())
      : AppRoutes.notifications;

  /// Push types the server sends for an order (see App\Services\Push\OrderPush).
  static const _orderTypes = {
    'order_placed',
    'payment_confirmed',
    'order_shipped',
    'order_out_for_delivery',
    'order_delivered',
    'order_cancelled',
    'refund_processed',
  };

  /// Type of a push sent from the admin panel's notification module.
  static const _notificationType = 'notification';

  /// Reads the message data defensively: an unknown type or an id that is not a positive
  /// integer opens nothing (the notification still shows; tapping just opens the app).
  static PushTarget? fromData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    if (type == null) return null;

    if (type == _notificationType) {
      final id = int.tryParse(data['notification_id']?.toString() ?? '');
      return id != null && id > 0 ? PushTarget.notification(id) : null;
    }

    final orderId = int.tryParse(data['order_id']?.toString() ?? '');
    if (!_orderTypes.contains(type)) return null;
    if (orderId == null || orderId <= 0) return null;
    return PushTarget.order(orderId);
  }
}

/// Firebase push notifications for the customer app.
///
/// Firebase is optional at runtime: when it is not configured for this build (no matching
/// google-services.json), [initialize] logs and returns, and every other method does
/// nothing, so the app starts and works exactly as before.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final _log = loggerWithContext({'feature': 'push', 'service': 'PushNotificationService'});

  ApiClient? _api;
  AppRouter? _router;

  bool _ready = false;
  bool _loggedIn = false;
  bool _listening = false;
  bool _permissionRequested = false;
  String? _registeredToken;
  PushTarget? _pendingTarget;
  String? _lastOpenedMessageId;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  /// Starts Firebase and the message listeners. Safe to call more than once; never throws.
  Future<void> initialize({
    required ApiClient apiClient,
    required AppRouter router,
  }) async {
    _api = apiClient;
    _router = router;
    if (_ready) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _ready = true;
    } catch (e) {
      _log.infoWithContext('Push notifications are off: Firebase is not configured', {
        'error': e.toString(),
      });
      // Also visible in a release build (adb logcat | grep "\[push\]"): the log level of a
      // production build hides the line above.
      debugPrint('[push] Firebase is not configured for this build, push is off: $e');
      return;
    }

    try {
      _listen();
      // The push that launched the app from a closed state, if any.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _remember(initial);
    } catch (e) {
      _log.errorWithContext('Push listeners failed to start', {'error': e.toString()});
    }
  }

  void _listen() {
    if (_listening) return;
    _listening = true;

    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForeground);
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => _register(token),
      onError: (Object e) => _log.errorWithContext('Token refresh failed', {'error': e.toString()}),
    );
  }

  /// Asks for the notification permission when the app opens (once per app start, and only
  /// while the customer has never decided), so the system "Allow notifications" dialog appears
  /// right away instead of after login. Called after the splash, whose location prompt has
  /// finished by then, so two system dialogs never overlap.
  Future<void> requestPermissionAtStart() async {
    if (!_ready || _permissionRequested) return;
    _permissionRequested = true;

    try {
      final granted = await _ensurePermission();
      debugPrint('[push] notification permission ${granted ? 'granted' : 'not granted'}');
    } catch (e) {
      debugPrint('[push] permission request failed: $e');
    }
  }

  /// The customer is logged in: ask for permission once, register this device with the
  /// server and open a push that launched the app.
  Future<void> onLogin() async {
    if (!_ready) return;
    _loggedIn = true;

    try {
      if (await _ensurePermission()) {
        final token = await FirebaseMessaging.instance.getToken();
        debugPrint('[push] FCM token ${token == null ? 'NOT available' : 'received'}');
        if (token != null) await _register(token);
      } else {
        debugPrint('[push] notification permission not granted, device not registered');
      }
    } catch (e) {
      debugPrint('[push] registration failed: $e');
      _log.errorWithContext('Push registration failed', {'error': e.toString()});
    }

    _openPending();
  }

  /// Stops pushes for the current customer on this device only. Call it BEFORE the login
  /// token is cleared, because the server removes the device for the logged-in user.
  /// Best effort: a failure must never block the logout.
  Future<void> unregisterDevice() async {
    final wasLoggedIn = _loggedIn;
    _loggedIn = false;
    final known = _registeredToken;
    _registeredToken = null;
    _pendingTarget = null;
    if (!_ready || !wasLoggedIn) return;

    try {
      final token = known ?? await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _api
          ?.delete(ApiConstants.deviceToken, data: {'token': token})
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      _log.errorWithContext('Push unregistration failed', {'error': e.toString()});
    }
  }

  /// Asks for the notification permission only while it has never been decided, so a
  /// customer who said no is not asked again.
  Future<bool> _ensurePermission() async {
    final messaging = FirebaseMessaging.instance;
    var settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await messaging.requestPermission();
    }
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _register(String token) async {
    if (!_loggedIn || token == _registeredToken) return;

    try {
      await _api?.post(
        ApiConstants.deviceToken,
        data: {
          'token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        },
      );
      _registeredToken = token;
      debugPrint('[push] device registered with the server');
    } catch (e) {
      debugPrint('[push] server rejected the device registration: $e');
      // Left unregistered: the next login or token refresh tries again.
      _log.errorWithContext('Device token registration failed', {'error': e.toString()});
    }
  }

  void _onForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // A notification from the admin panel is also in the app's notification section:
    // refresh it so the bell badge and the list show it at once.
    final target = PushTarget.fromData(message.data);
    if (target?.notificationId != null && _loggedIn) {
      getIt<NotificationsCubit>().refresh();
    }

    final context = _router?.router.routerDelegate.navigatorKey.currentContext;
    if (context == null) return;

    AppToast.show(
      context,
      type: AppToastType.info,
      title: notification.title ?? '',
      message: notification.body,
      actionLabel: target == null ? null : 'View',
      onAction: target == null ? null : () => _go(target),
    );
  }

  /// The app was in the background and the customer tapped the notification.
  void _onOpened(RemoteMessage message) {
    if (!_remember(message)) return;
    if (_loggedIn) _openPending();
  }

  /// Keeps the target of a tapped push; false for a push already handled or without a target.
  bool _remember(RemoteMessage message) {
    final id = message.messageId;
    if (id != null && id == _lastOpenedMessageId) return false;
    final target = PushTarget.fromData(message.data);
    if (target == null) return false;
    _lastOpenedMessageId = id;
    _pendingTarget = target;
    return true;
  }

  /// Opens the remembered target once. Waits a moment so the app's own start-up
  /// navigation (splash, home) has finished and does not replace it.
  void _openPending() {
    final target = _pendingTarget;
    if (target == null) return;
    _pendingTarget = null;
    Future<void>.delayed(const Duration(milliseconds: 800), () => _go(target));
  }

  void _go(PushTarget target) {
    if (!_loggedIn) return;
    final notificationId = target.notificationId;
    if (notificationId != null) {
      _openNotification(notificationId);
      return;
    }
    _router?.router.push(target.path);
  }

  /// Opens a notification of the admin panel in the app's notification section: the
  /// inbox is refreshed, then the item is shown (and marked read). If it is not in the
  /// inbox (for example it was removed), the inbox itself opens.
  Future<void> _openNotification(int id) async {
    try {
      final cubit = getIt<NotificationsCubit>();
      await cubit.refresh();

      AppNotification? found;
      for (final item in cubit.state.items) {
        if (item.id == id.toString()) {
          found = item;
          break;
        }
      }

      final router = _router?.router;
      if (router == null || !_loggedIn) return;
      if (found == null) {
        router.push(AppRoutes.notifications);
        return;
      }
      cubit.markRead(found);
      router.push(AppRoutes.notificationDetail, extra: found);
    } catch (e) {
      _log.errorWithContext('Opening a notification failed', {'error': e.toString()});
    }
  }

  @visibleForTesting
  Future<void> disposeForTest() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
  }
}
