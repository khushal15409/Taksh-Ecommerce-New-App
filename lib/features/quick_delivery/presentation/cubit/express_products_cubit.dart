import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/error/failures.dart';
import 'package:taksh_e_commerce/core/utils/quick_serviceability.dart';
import 'package:taksh_e_commerce/core/utils/request_guard.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/express_products_response.dart';
import 'package:taksh_e_commerce/features/product/domain/usecases/get_express_products.dart';
import 'package:taksh_e_commerce/features/quick_delivery/presentation/cubit/express_products_state.dart';

class ExpressProductsCubit extends Cubit<ExpressProductsState> {
  final GetExpressProducts _getExpressProducts;

  ExpressProductsCubit({
    required GetExpressProducts getExpressProducts,
  })  : _getExpressProducts = getExpressProducts,
        super(const ExpressProductsState.initial());

  final _log = loggerWithContext({
    'feature': 'quick_delivery',
    'layer': 'presentation',
    'class': 'ExpressProductsCubit',
  });

  /// Drops late responses of an older category/page/address.
  final RequestGuard _guard = RequestGuard();

  /// Query (category + location) the loaded items belong to.
  String? _loadedQueryKey;

  Future<void> fetchProducts({
    required int categoryId,
    required double latitude,
    required double longitude,
    int page = 1,
  }) async {
    if (isClosed) return;

    final queryKey = RequestGuard.queryKey(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
    );
    final isNewQuery = queryKey != _loadedQueryKey;

    if (page > 1) {
      // A next page only makes sense for the query that is on screen, and
      // never while another request is running (no duplicate page requests).
      if (isNewQuery) return;
      if (state.status == ExpressProductsStatus.loading ||
          state.status == ExpressProductsStatus.loadingMore) {
        return;
      }
    }

    _log.infoWithContext(
      'Fetching express products',
      {
        'category_id': categoryId,
        'page': page,
      },
    );

    final token = _guard.begin(
      RequestGuard.listingKey(
        categoryId: categoryId,
        page: page,
        latitude: latitude,
        longitude: longitude,
      ),
    );

    if (page == 1) {
      // Pagination restarts whenever the query changes.
      emit(state.copyWith(
        status: ExpressProductsStatus.loading,
        clearErrorMessage: true,
        clearNotServiceable: true,
        clearResponse: isNewQuery,
        currentPage: 1,
        loadMoreFailed: false,
      ));
    } else {
      emit(state.copyWith(
        status: ExpressProductsStatus.loadingMore,
        clearErrorMessage: true,
        loadMoreFailed: false,
      ));
    }

    final result = await _getExpressProducts(
      GetExpressProductsParams(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        page: page,
      ),
    );

    if (isClosed || !_guard.isCurrent(token)) return;

    result.fold(
      (failure) {
        _log.errorWithContext(
          'Failed to fetch express products',
          {'category_id': categoryId, 'error': failure.message},
        );

        if (page > 1) {
          // Keep the items already loaded; only the next page failed.
          emit(state.copyWith(
            status: ExpressProductsStatus.loaded,
            errorMessage: failure.message,
            loadMoreFailed: true,
          ));
          return;
        }

        if (failure is ApiCodeFailure &&
            isQuickServiceabilityCode(failure.code)) {
          _loadedQueryKey = null;
          emit(state.copyWith(
            status: ExpressProductsStatus.notServiceable,
            clearResponse: true,
            notServiceableMessage: failure.message,
            notServiceableCode: failure.code,
          ));
          return;
        }

        emit(state.copyWith(
          status: ExpressProductsStatus.error,
          errorMessage: failure.message,
        ));
      },
      (response) {
        _log.infoWithContext(
          'Express products fetched successfully',
          {
            'category_id': categoryId,
            'products_count': response.products.length,
            'total': response.total,
            'page': response.currentPage,
          },
        );

        _loadedQueryKey = queryKey;

        // For pagination, append products to existing list (skipping repeats)
        if (page > 1 && state.response != null) {
          final existingProducts = state.response!.products;
          final knownIds = existingProducts.map((p) => p.id).toSet();
          final mergedResponse = ExpressProductsResponse(
            fulfillmentCenter: response.fulfillmentCenter,
            products: [
              ...existingProducts,
              ...response.products.where((p) => !knownIds.contains(p.id)),
            ],
            currentPage: response.currentPage,
            perPage: response.perPage,
            total: response.total,
            lastPage: response.lastPage,
            from: response.from,
            to: response.to,
          );
          emit(state.copyWith(
            status: ExpressProductsStatus.loaded,
            response: mergedResponse,
            currentPage: page,
          ));
        } else {
          emit(state.copyWith(
            status: ExpressProductsStatus.loaded,
            response: response,
            currentPage: page,
          ));
        }
      },
    );
  }

  Future<void> loadNextPage({
    required int categoryId,
    required double latitude,
    required double longitude,
    bool retry = false,
  }) async {
    if (!state.hasMorePages) return;
    if (state.status == ExpressProductsStatus.loading ||
        state.status == ExpressProductsStatus.loadingMore) {
      return;
    }
    // After a failed page, only an explicit retry asks again (no loops).
    if (state.loadMoreFailed && !retry) return;

    await fetchProducts(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      page: state.currentPage + 1,
    );
  }
}
