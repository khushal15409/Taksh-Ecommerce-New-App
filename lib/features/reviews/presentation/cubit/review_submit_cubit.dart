import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/features/reviews/domain/entities/review_entities.dart';
import 'package:taksh_e_commerce/features/reviews/domain/repositories/review_repository.dart';

enum ReviewSubmitStatus { idle, submitting, success, failure }

class ReviewSubmitState extends Equatable {
  final ReviewSubmitStatus status;
  final SubmittedReview? result;
  final String? errorMessage;

  const ReviewSubmitState({
    this.status = ReviewSubmitStatus.idle,
    this.result,
    this.errorMessage,
  });

  bool get isSubmitting => status == ReviewSubmitStatus.submitting;

  @override
  List<Object?> get props => [status, result, errorMessage];
}

/// Submits one rating. Created per sheet, so it never carries state between products.
class ReviewSubmitCubit extends Cubit<ReviewSubmitState> {
  final ReviewRepository _repository;

  ReviewSubmitCubit({required ReviewRepository repository})
      : _repository = repository,
        super(const ReviewSubmitState());

  Future<void> submit({
    required int productId,
    required int rating,
    String? title,
    String? text,
  }) async {
    // A double tap must not send the rating twice.
    if (isClosed || state.isSubmitting) return;
    emit(const ReviewSubmitState(status: ReviewSubmitStatus.submitting));

    final result = await _repository.submit(
      productId: productId,
      rating: rating,
      title: title,
      text: text,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        ReviewSubmitState(
          status: ReviewSubmitStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (review) => emit(
        ReviewSubmitState(status: ReviewSubmitStatus.success, result: review),
      ),
    );
  }
}
