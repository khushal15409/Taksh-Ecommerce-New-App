/// A singleton service to cache product variant IDs.
/// This ensures variant IDs persist across widget rebuilds and navigation.
class VariantCacheService {
  VariantCacheService._();

  static final VariantCacheService _instance = VariantCacheService._();
  static VariantCacheService get instance => _instance;

  /// Cache: productId -> variantId
  final Map<int, int> _variantCache = {};

  /// Cache: variantId -> human-readable variant label
  final Map<int, String> _variantLabelCache = {};

  /// Get cached variant ID for a product
  int? getVariantId(int productId) => _variantCache[productId];

  /// Cache a variant ID for a product
  void cacheVariantId(int productId, int variantId) {
    _variantCache[productId] = variantId;
  }

  /// Get the cached human-readable label for a variant.
  String? getVariantLabel(int variantId) => _variantLabelCache[variantId];

  /// Cache a human-readable label for a variant.
  void cacheVariantLabel(int variantId, String label) {
    if (label.trim().isEmpty) return;
    _variantLabelCache[variantId] = label;
  }

  /// Check if a variant ID is cached for a product
  bool hasVariantId(int productId) => _variantCache.containsKey(productId);

  /// Clear cache for a specific product
  void clearProduct(int productId) => _variantCache.remove(productId);

  /// Clear all cached variant IDs
  void clearAll() {
    _variantCache.clear();
    _variantLabelCache.clear();
  }
}
