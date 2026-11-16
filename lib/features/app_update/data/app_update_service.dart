import 'dart:io' show Platform;

import 'package:dio/dio.dart';
// Prefixed: the plugin has its own AppUpdateInfo class.
import 'package:in_app_update/in_app_update.dart' as play;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taksh_e_commerce/features/app_update/data/app_update_info.dart';
import 'package:url_launcher/url_launcher.dart';

/// Asks the server whether this build needs an update, and starts the update.
///
/// It uses its own bare Dio on purpose: the version check is public, so it must
/// not carry the login token or run through the interceptors that react to a
/// failed login. Every method swallows its errors - an update problem must
/// never take the app down.
class AppUpdateService {
  AppUpdateService({required String baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: const {'Accept': 'application/json'},
            ));

  final Dio _dio;

  /// The server's verdict for the installed build, or null when it cannot be
  /// had (no network, server error, odd answer, not Android).
  Future<AppUpdateInfo?> fetch() async {
    if (!Platform.isAndroid) return null;

    try {
      final package = await PackageInfo.fromPlatform();
      final build = int.tryParse(package.buildNumber);
      if (build == null) return null;

      final response = await _dio.get<dynamic>(
        '/app/version-check',
        queryParameters: {
          'platform': 'android',
          'current_version': package.version,
          'current_build_number': build,
        },
      );

      final body = response.data;
      if (body is! Map || body['success'] != true) return null;
      final data = body['data'];
      if (data is! Map) return null;

      return AppUpdateInfo.tryParse(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  /// Update now. Google Play's in-app update when this install can use it,
  /// otherwise the Play Store page. A refusal inside the Play dialog is
  /// respected (nothing else opens); the caller decides what that means.
  Future<void> startUpdate(AppUpdateInfo info) async {
    try {
      final available = await play.InAppUpdate.checkForUpdate();

      if (available.updateAvailability == play.UpdateAvailability.updateAvailable) {
        if (info.isForce && available.immediateUpdateAllowed) {
          final result = await play.InAppUpdate.performImmediateUpdate();
          if (result == play.AppUpdateResult.inAppUpdateFailed) {
            await _openStore(info.storeUrl);
          }
          return;
        }

        if (!info.isForce && available.flexibleUpdateAllowed) {
          final result = await play.InAppUpdate.startFlexibleUpdate();
          if (result == play.AppUpdateResult.success) {
            await play.InAppUpdate.completeFlexibleUpdate();
          } else if (result == play.AppUpdateResult.inAppUpdateFailed) {
            await _openStore(info.storeUrl);
          }
          return;
        }
      }
    } catch (_) {
      // Not installed from Play, no Play services, etc.: use the store link.
    }

    await _openStore(info.storeUrl);
  }

  Future<void> _openStore(String? url) async {
    if (url == null) return;

    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Nothing more can be done; the update screen stays where it is.
    }
  }
}
