import 'package:equatable/equatable.dart';

/// A delivered product the customer has not rated yet.
class PendingReviewItem extends Equatable {
  final int productId;
  final String productName;
  final String? imageUrl;
  final int orderId;
  final String? orderNumber;

  const PendingReviewItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.orderId,
    this.orderNumber,
  });

  @override
  List<Object?> get props => [productId, productName, imageUrl, orderId, orderNumber];
}

/// Whether the customer may rate a product, and what they already wrote.
class ReviewStatus extends Equatable {
  final bool canReview;
  final bool hasReviewed;
  final int? rating;
  final String? title;
  final String? text;

  const ReviewStatus({
    required this.canReview,
    required this.hasReviewed,
    this.rating,
    this.title,
    this.text,
  });

  @override
  List<Object?> get props => [canReview, hasReviewed, rating, title, text];
}

/// What the server answers to a submitted rating.
class SubmittedReview extends Equatable {
  final int rating;
  final double averageRating;
  final int totalReviews;
  final String message;

  const SubmittedReview({
    required this.rating,
    required this.averageRating,
    required this.totalReviews,
    required this.message,
  });

  @override
  List<Object?> get props => [rating, averageRating, totalReviews, message];
}
