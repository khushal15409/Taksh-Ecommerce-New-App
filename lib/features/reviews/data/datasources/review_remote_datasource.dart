import 'package:taksh_e_commerce/core/error/exceptions.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/reviews/domain/entities/review_entities.dart';

/// Remote data source for ratings and reviews.
abstract class ReviewRemoteDataSource {
  Future<List<PendingReviewItem>> getPending();
  Future<ReviewStatus> getStatus(int productId);
  Future<SubmittedReview> submit({
    required int productId,
    required int rating,
    String? title,
    String? text,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSourceImpl({required this.apiClient});

  DataMap _data(dynamic body) {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    throw const ServerException('Unexpected response from the server');
  }

  @override
  Future<List<PendingReviewItem>> getPending() async {
    final response = await apiClient.get('/reviews/pending');
    final data = _data(response.data);
    final items = data['items'];
    if (items is! List) return const [];

    final result = <PendingReviewItem>[];
    for (final raw in items) {
      if (raw is! Map) continue;
      final json = Map<String, dynamic>.from(raw);
      final productId = (json['product_id'] as num?)?.toInt();
      if (productId == null) continue; // a malformed row is skipped, not fatal
      result.add(
        PendingReviewItem(
          productId: productId,
          productName: json['product_name'] as String? ?? '',
          imageUrl: json['image_url'] as String?,
          orderId: (json['order_id'] as num?)?.toInt() ?? 0,
          orderNumber: json['order_number']?.toString(),
        ),
      );
    }
    return result;
  }

  @override
  Future<ReviewStatus> getStatus(int productId) async {
    final response = await apiClient.get('/product/$productId/review');
    final data = _data(response.data);
    final review = data['review'];
    final reviewMap = review is Map ? Map<String, dynamic>.from(review) : null;

    return ReviewStatus(
      canReview: data['can_review'] == true,
      hasReviewed: data['has_reviewed'] == true,
      rating: (reviewMap?['rating'] as num?)?.toInt(),
      title: reviewMap?['title'] as String?,
      text: reviewMap?['review'] as String?,
    );
  }

  @override
  Future<SubmittedReview> submit({
    required int productId,
    required int rating,
    String? title,
    String? text,
  }) async {
    final body = <String, dynamic>{'rating': rating};
    if (title != null && title.trim().isNotEmpty) {
      body['review_title'] = title.trim();
    }
    if (text != null && text.trim().isNotEmpty) {
      body['review_text'] = text.trim();
    }

    final response = await apiClient.post(
      '/product/$productId/review',
      data: body,
    );
    final data = _data(response.data);
    final summary = data['rating_summary'];
    final summaryMap =
        summary is Map ? Map<String, dynamic>.from(summary) : const {};

    final body2 = response.data;
    final message = body2 is Map && body2['message'] is String
        ? body2['message'] as String
        : 'Thank you! Your rating has been submitted';

    return SubmittedReview(
      rating: rating,
      averageRating: (summaryMap['average_rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (summaryMap['total_reviews'] as num?)?.toInt() ?? 0,
      message: message,
    );
  }
}
