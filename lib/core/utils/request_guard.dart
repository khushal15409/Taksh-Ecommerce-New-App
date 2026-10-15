/// Drops stale async responses: every new request gets a token built from its
/// query key; only the response whose token is still the latest is applied.
class RequestGuard {
  int _epoch = 0;
  String? _key;

  /// Key of the latest request (null before the first one).
  String? get currentKey => _key;

  /// Starts a new request for [key] and returns its token.
  int begin(String key) {
    _key = key;
    return ++_epoch;
  }

  /// Invalidates any in-flight request without starting a new one.
  void invalidate() {
    _epoch++;
  }

  /// Whether [token] still identifies the latest request.
  bool isCurrent(int token) => token == _epoch;

  /// Key of a Quick listing query (everything except the page number). A new
  /// query key means pagination must restart from page 1.
  static String queryKey({
    required int categoryId,
    required double latitude,
    required double longitude,
  }) =>
      '$categoryId|${latitude.toStringAsFixed(5)}|${longitude.toStringAsFixed(5)}';

  /// Key of one page request of a Quick listing.
  static String listingKey({
    required int categoryId,
    required int page,
    required double latitude,
    required double longitude,
  }) =>
      '${queryKey(categoryId: categoryId, latitude: latitude, longitude: longitude)}|$page';
}
