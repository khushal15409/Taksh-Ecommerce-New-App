/// What GET /api/app/version-check says about this build of the app.
///
/// Parsing is deliberately forgiving: a missing or odd field never throws, it
/// just means "no update", so a bad response can never lock the app.
class AppUpdateInfo {
  final bool updateAvailable;
  final bool updateRequired;
  final String updateType; // none | optional | force
  final String latestVersion;
  final int latestBuildNumber;
  final String title;
  final String message;
  final String buttonText;
  final String? storeUrl;

  const AppUpdateInfo({
    required this.updateAvailable,
    required this.updateRequired,
    required this.updateType,
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.storeUrl,
  });

  /// The app must be updated before it can be used.
  bool get isForce => updateAvailable && updateRequired && updateType == 'force';

  /// An update is offered, and the person may say later.
  bool get isOptional =>
      updateAvailable && !updateRequired && updateType == 'optional';

  /// Null when [json] is not a usable answer.
  static AppUpdateInfo? tryParse(Map<String, dynamic> json) {
    try {
      String text(String key, String fallback) {
        final value = json[key];
        return value is String && value.trim().isNotEmpty ? value : fallback;
      }

      final store = json['store_url'];
      final build = json['latest_build_number'];

      return AppUpdateInfo(
        updateAvailable: json['update_available'] == true,
        updateRequired: json['update_required'] == true,
        updateType: json['update_type'] is String
            ? json['update_type'] as String
            : 'none',
        latestVersion: text('latest_version', ''),
        latestBuildNumber: build is int ? build : int.tryParse('$build') ?? 0,
        title: text('title', 'Update Available'),
        message: text('message', 'A new version of the app is available.'),
        buttonText: text('button_text', 'Update Now'),
        storeUrl: store is String && store.trim().isNotEmpty ? store : null,
      );
    } catch (_) {
      return null;
    }
  }
}
