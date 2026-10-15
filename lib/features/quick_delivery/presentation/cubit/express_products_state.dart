import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/express_products_response.dart';

enum ExpressProductsStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,

  /// The server says Quick delivery cannot serve the location (message in
  /// [ExpressProductsState.notServiceableMessage]).
  notServiceable,
}

class ExpressProductsState extends Equatable {
  final ExpressProductsStatus status;
  final ExpressProductsResponse? response;
  final String? errorMessage;
  final int currentPage;

  /// Backend message / code of the not-serviceable verdict.
  final String? notServiceableMessage;
  final String? notServiceableCode;

  /// The last "next page" request failed; the loaded items are kept.
  final bool loadMoreFailed;

  const ExpressProductsState({
    required this.status,
    this.response,
    this.errorMessage,
    this.currentPage = 1,
    this.notServiceableMessage,
    this.notServiceableCode,
    this.loadMoreFailed = false,
  });

  const ExpressProductsState.initial()
      : this(status: ExpressProductsStatus.initial);

  bool get hasMorePages => response?.hasMorePages ?? false;

  ExpressProductsState copyWith({
    ExpressProductsStatus? status,
    ExpressProductsResponse? response,
    bool clearResponse = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? currentPage,
    String? notServiceableMessage,
    String? notServiceableCode,
    bool clearNotServiceable = false,
    bool? loadMoreFailed,
  }) {
    return ExpressProductsState(
      status: status ?? this.status,
      response: clearResponse ? null : (response ?? this.response),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      notServiceableMessage: clearNotServiceable
          ? null
          : (notServiceableMessage ?? this.notServiceableMessage),
      notServiceableCode: clearNotServiceable
          ? null
          : (notServiceableCode ?? this.notServiceableCode),
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }

  @override
  List<Object?> get props => [
        status,
        response,
        errorMessage,
        currentPage,
        notServiceableMessage,
        notServiceableCode,
        loadMoreFailed,
      ];
}
