import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/utils/quick_serviceability.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/paginated_products.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/product.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/product_variant.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_categories.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_ecommerce_product_details.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_express_products.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_product_details.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_products.dart';
import 'package:taksh_e_commerce/features/product/presentation/cubit/product_state.dart';

/// Cubit for managing product and category state
class ProductCubit extends Cubit<ProductState> {
  final GetCategories getCategories;
  final GetProducts getProducts;
  final GetProductDetails getProductDetails;
  final GetEcommerceProductDetails getEcommerceProductDetails;
  final GetExpressProducts getExpressProducts;

  ProductCubit({
    required this.getCategories,
    required this.getProducts,
    required this.getProductDetails,
    required this.getEcommerceProductDetails,
    required this.getExpressProducts,
  }) : super(const ProductInitial());

  /// Incremented by every [fetchProducts] so a slow response for a previous
  /// category/search can never overwrite (or be appended to) the current list.
  int _listRequestId = 0;
  bool _loadingMore = false;

  /// Fetch all categories
  Future<void> fetchCategories({
    String deliveryType = 'standard_delivery',
  }) async {
    if (isClosed) return;
    // Any page still loading belongs to the previous list; drop it.
    _listRequestId++;
    _loadingMore = false;
    emit(const CategoryLoading());

    final result = await getCategories(
      GetCategoriesParams(deliveryType: deliveryType),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  /// Fetch products with optional filters
  Future<void> fetchProducts({
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    print(
      '📦 ProductCubit: Fetching products for category: $categoryId, page: $page, limit: $limit, search: $search',
    );
    if (isClosed) return;
    final requestId = ++_listRequestId;
    _loadingMore = false;
    emit(const ProductListLoading());

    final result = await getProducts(
      GetProductsParams(
        categoryId: categoryId,
        search: search,
        page: page,
        limit: limit,
      ),
    );

    if (isClosed || requestId != _listRequestId) return;

    result.fold(
      (failure) {
        print('❌ ProductCubit: Error fetching products: ${failure.message}');
        emit(ProductError(failure.message));
      },
      (paginatedProducts) {
        print(
          '✅ ProductCubit: Products loaded - Count: ${paginatedProducts.products.length}, Total: ${paginatedProducts.total}',
        );
        emit(ProductListLoaded(paginatedProducts));
      },
    );
  }

  /// Load the next page of the current product list (standard listing) and
  /// append it, skipping products that are already shown. Does nothing while a
  /// page is loading, when there is no next page, or when the list changed
  /// (new category/search) while the request was in flight. A failed page
  /// keeps the products already shown.
  Future<void> fetchMoreProducts({
    int? categoryId,
    String? search,
    int limit = 10,
  }) async {
    if (isClosed || _loadingMore) return;

    final current = state;
    if (current is! ProductListLoaded) return;

    final loaded = current.paginatedProducts;
    if (loaded.nextPageUrl == null || loaded.currentPage >= loaded.lastPage) {
      return;
    }

    _loadingMore = true;
    final requestId = _listRequestId;

    final result = await getProducts(
      GetProductsParams(
        categoryId: categoryId,
        search: search,
        page: loaded.currentPage + 1,
        limit: limit,
      ),
    );

    _loadingMore = false;
    if (isClosed || requestId != _listRequestId) return;

    result.fold(
      (failure) {
        print('❌ ProductCubit: Error loading next page: ${failure.message}');
      },
      (next) {
        final knownIds = loaded.products.map((product) => product.id).toSet();
        final merged = [
          ...loaded.products,
          ...next.products.where((product) => !knownIds.contains(product.id)),
        ];
        emit(
          ProductListLoaded(
            PaginatedProducts(
              currentPage: next.currentPage,
              products: merged,
              firstPageUrl: next.firstPageUrl,
              from: loaded.from,
              lastPage: next.lastPage,
              lastPageUrl: next.lastPageUrl,
              links: next.links,
              nextPageUrl: next.nextPageUrl,
              path: next.path,
              perPage: next.perPage,
              prevPageUrl: next.prevPageUrl,
              to: next.to,
              total: next.total,
            ),
          ),
        );
      },
    );
  }

  /// Fetch express products for a category (uses /express-30/products API)
  Future<void> fetchExpressProducts({
    required int categoryId,
    required double latitude,
    required double longitude,
    int page = 1,
  }) async {
    if (isClosed) return;
    // Any standard page still loading must not be appended to this list, and a
    // late response of an older category/page/address must be dropped: every
    // call takes a new request id and only the latest one may emit.
    final requestId = ++_listRequestId;
    _loadingMore = false;
    emit(const ProductListLoading());

    final result = await getExpressProducts(
      GetExpressProductsParams(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        page: page,
      ),
    );

    if (isClosed || requestId != _listRequestId) return;

    result.fold(
      (failure) {
        if (failure is ApiCodeFailure &&
            isQuickServiceabilityCode(failure.code)) {
          emit(ProductNotServiceable(
            message: failure.message,
            code: failure.code,
          ));
          return;
        }
        emit(ProductError(failure.message));
      },
      (response) {
        final paginatedProducts = PaginatedProducts(
          currentPage: response.currentPage,
          products: response.products,
          firstPageUrl: '',
          from: response.from,
          lastPage: response.lastPage,
          lastPageUrl: '',
          path: '',
          perPage: response.perPage,
          total: response.total,
          to: response.to,
          nextPageUrl:
              response.currentPage < response.lastPage ? 'next' : null,
        );
        emit(ProductListLoaded(paginatedProducts));
      },
    );
  }

  /// Fetch product details by ID
  Future<void> fetchProductDetails(int productId) async {
    if (isClosed) return;
    emit(const ProductDetailsLoading());

    final result = await getProductDetails(
      GetProductDetailsParams(productId: productId),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }

  /// Fetch ecommerce product details by ID.
  ///
  /// [initialInStock] and [initialOutOfStockMessage] are optional values
  /// sourced from the product listing (e.g. home page cards). When the product
  /// details API does not explicitly return `in_stock` (i.e. it defaults to
  /// `true`), but the listing said the product is out of stock, the passed
  /// values are used as a reliable fallback so the details page always shows
  /// the correct stock state.
  Future<void> fetchEcommerceProductDetails(
    int productId, {
    bool? initialInStock,
    String? initialOutOfStockMessage,
  }) async {
    if (isClosed) return;
    emit(const ProductDetailsLoading());

    final result = await getEcommerceProductDetails(
      GetEcommerceProductDetailsParams(productId: productId),
    );

    if (isClosed) return;

    Product? fetchedProduct;
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => fetchedProduct = product,
    );

    if (fetchedProduct == null || isClosed) {
      return;
    }

    var resolvedProduct = _applyListingStockFallback(
      fetchedProduct!,
      initialInStock: initialInStock,
      initialOutOfStockMessage: initialOutOfStockMessage,
    );

    // Standard product details already carry per-variant stock, so this
    // fallback only runs for payloads without it (e.g. express products). The
    // former GET /products/{id} fallback was removed: that route does not
    // exist on the backend, so it always failed.
    if (_needsVariantStockResolution(resolvedProduct)) {
      final catalogResult = await getProducts(
        GetProductsParams(search: resolvedProduct.name, limit: 20),
      );

      if (isClosed) return;

      resolvedProduct = catalogResult.fold(
        (_) => resolvedProduct,
        (paginatedProducts) {
          Product? catalogProduct;
          for (final product in paginatedProducts.products) {
            if (product.id == productId) {
              catalogProduct = product;
              break;
            }
          }

          if (catalogProduct == null) {
            return resolvedProduct;
          }

          return _mergeVariantStockInfo(
            primary: resolvedProduct,
            fallback: catalogProduct,
            initialInStock: initialInStock,
            initialOutOfStockMessage: initialOutOfStockMessage,
          );
        },
      );
    }

    emit(ProductDetailsLoaded(resolvedProduct));
  }

  Product _applyListingStockFallback(
    Product product, {
    bool? initialInStock,
    String? initialOutOfStockMessage,
  }) {
    if (initialInStock == false && product.inStock == true) {
      return product.copyWithStockStatus(
        inStock: false,
        outOfStockMessage:
            product.outOfStockMessage ?? initialOutOfStockMessage,
      );
    }

    return product;
  }

  bool _needsVariantStockResolution(Product product) {
    final variants = product.variants;
    if (variants == null || variants.isEmpty) return false;

    final activeVariants = variants.where((variant) => variant.isActive).toList();
    if (activeVariants.isEmpty) return false;

    return activeVariants.any((variant) => !variant.hasStockInfo);
  }

  Product _mergeVariantStockInfo({
    required Product primary,
    required Product fallback,
    bool? initialInStock,
    String? initialOutOfStockMessage,
  }) {
    final primaryVariants = primary.variants;
    final fallbackVariants = fallback.variants;

    List<ProductVariant>? mergedVariants;
    if ((primaryVariants == null || primaryVariants.isEmpty) &&
        fallbackVariants != null &&
        fallbackVariants.isNotEmpty) {
      mergedVariants = fallbackVariants;
    } else if (primaryVariants != null && primaryVariants.isNotEmpty) {
      final fallbackById = <int, ProductVariant>{
        for (final variant in fallbackVariants ?? const <ProductVariant>[])
          variant.id: variant,
      };
      final fallbackBySku = <String, ProductVariant>{
        for (final variant in fallbackVariants ?? const <ProductVariant>[])
          if (variant.sku.trim().isNotEmpty) variant.sku.trim(): variant,
      };

      mergedVariants = primaryVariants.map((variant) {
        if (variant.hasStockInfo) {
          return variant;
        }

        final fallbackVariant =
            fallbackById[variant.id] ?? fallbackBySku[variant.sku.trim()];
        if (fallbackVariant == null) {
          return variant;
        }

        return ProductVariant(
          id: variant.id,
          productId: variant.productId,
          sku: variant.sku,
          price: variant.price,
          salePrice: variant.salePrice,
          weight: variant.weight ?? fallbackVariant.weight,
          length: variant.length ?? fallbackVariant.length,
          width: variant.width ?? fallbackVariant.width,
          height: variant.height ?? fallbackVariant.height,
          status: variant.status.isNotEmpty ? variant.status : fallbackVariant.status,
          createdAt: variant.createdAt ?? fallbackVariant.createdAt,
          updatedAt: variant.updatedAt ?? fallbackVariant.updatedAt,
          variantAttributes:
              variant.variantAttributes != null &&
                  variant.variantAttributes!.isNotEmpty
              ? variant.variantAttributes
              : fallbackVariant.variantAttributes,
          images: variant.images != null && variant.images!.isNotEmpty
              ? variant.images
              : fallbackVariant.images,
          inStock: fallbackVariant.hasStockInfo
              ? fallbackVariant.inStock
              : variant.inStock,
          outOfStockMessage:
              fallbackVariant.outOfStockMessage ?? variant.outOfStockMessage,
          hasStockInfo: fallbackVariant.hasStockInfo || variant.hasStockInfo,
        );
      }).toList();
    }

    final resolvedVariants = mergedVariants ?? primaryVariants ?? fallbackVariants;
    final activeVariants =
        resolvedVariants?.where((variant) => variant.isActive).toList() ??
        const <ProductVariant>[];
    final hasResolvedStockForAllActive =
        activeVariants.isNotEmpty &&
        activeVariants.every((variant) => variant.hasStockInfo);
    final resolvedInStock = hasResolvedStockForAllActive
        ? activeVariants.any((variant) => variant.isAvailableForSale)
        : primary.inStock;
    final resolvedOutOfStockMessage = hasResolvedStockForAllActive &&
            !resolvedInStock
        ? activeVariants
                .map((variant) => variant.outOfStockMessage)
                .firstWhere(
                  (message) => message != null && message.trim().isNotEmpty,
                  orElse: () => primary.outOfStockMessage,
                ) ??
            primary.outOfStockMessage ??
            fallback.outOfStockMessage ??
            initialOutOfStockMessage
        : primary.outOfStockMessage ?? fallback.outOfStockMessage;

    return _applyListingStockFallback(
      Product(
        id: primary.id,
        categoryId: primary.categoryId,
        brandId: primary.brandId,
        fulfillmentCenterId: primary.fulfillmentCenterId,
        name: primary.name,
        slug: primary.slug,
        description: primary.description ?? fallback.description,
        shortDescription: primary.shortDescription ?? fallback.shortDescription,
        status: primary.status,
        isTrending: primary.isTrending,
        isLatest: primary.isLatest,
        isExpress30: primary.isExpress30,
        createdAt: primary.createdAt,
        updatedAt: primary.updatedAt,
        brand: primary.brand ?? fallback.brand,
        category: primary.category ?? fallback.category,
        variants: resolvedVariants,
        images: primary.images != null && primary.images!.isNotEmpty
            ? primary.images
            : fallback.images,
        ratingSummary: primary.ratingSummary ?? fallback.ratingSummary,
        reviews: primary.reviews ?? fallback.reviews,
        questionsAnswers: primary.questionsAnswers ?? fallback.questionsAnswers,
        originalPrice: primary.originalPrice ?? fallback.originalPrice,
        salePrice: primary.salePrice ?? fallback.salePrice,
        discountLabel: primary.discountLabel ?? fallback.discountLabel,
        saleId: primary.saleId ?? fallback.saleId,
        foodType: primary.foodType ?? fallback.foodType,
        returnDays: primary.returnDays ?? fallback.returnDays,
        inStock: resolvedInStock,
        outOfStockMessage: resolvedOutOfStockMessage,
      ),
      initialInStock: initialInStock,
      initialOutOfStockMessage: initialOutOfStockMessage,
    );
  }
}
