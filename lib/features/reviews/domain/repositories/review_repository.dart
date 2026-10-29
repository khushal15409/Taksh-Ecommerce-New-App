import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/reviews/domain/entities/review_entities.dart';

/// Ratings and reviews of products the customer received.
abstract class ReviewRepository {
  /// Delivered products still waiting for a rating (latest first).
  ResultFuture<List<PendingReviewItem>> getPending();

  /// Whether [productId] can be rated by the customer and what they wrote.
  ResultFuture<ReviewStatus> getStatus(int productId);

  /// Rate a delivered product (a second submit updates the first).
  ResultFuture<SubmittedReview> submit({
    required int productId,
    required int rating,
    String? title,
    String? text,
  });
}
