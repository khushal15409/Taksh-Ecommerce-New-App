import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/features/reviews/domain/entities/review_entities.dart';
import 'package:taksh_e_commerce/features/reviews/domain/repositories/review_repository.dart';
import 'package:taksh_e_commerce/features/reviews/presentation/widgets/review_sheet.dart';

/// "Rate this product" on the product page. Shown only to a signed-in customer who
/// had the product delivered (the server decides); nothing is drawn otherwise, so
/// the page is exactly as before for everyone else.
class ProductRateAction extends StatefulWidget {
  final int productId;
  final String productName;
  final String? imageUrl;

  /// Called after a rating was saved, e.g. to reload the product's rating.
  final VoidCallback? onSubmitted;

  const ProductRateAction({
    super.key,
    required this.productId,
    required this.productName,
    this.imageUrl,
    this.onSubmitted,
  });

  @override
  State<ProductRateAction> createState() => _ProductRateActionState();
}

class _ProductRateActionState extends State<ProductRateAction> {
  ReviewStatus? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProductRateAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _status = null;
      _load();
    }
  }

  Future<void> _load() async {
    final productId = widget.productId;
    final result = await getIt<ReviewRepository>().getStatus(productId);
    if (!mounted || productId != widget.productId) return;
    result.fold((_) {}, (status) => setState(() => _status = status));
  }

  Future<void> _open() async {
    final status = _status;
    if (status == null) return;

    final saved = await ReviewSheet.show(
      context,
      productId: widget.productId,
      productName: widget.productName,
      imageUrl: widget.imageUrl,
      initialRating: status.rating ?? 0,
      initialTitle: status.title,
      initialText: status.text,
    );
    if (saved && mounted) {
      await _load();
      widget.onSubmitted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null || !status.canReview) return const SizedBox.shrink();

    final rated = status.hasReviewed;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryOrange.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF7B500), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rated
                      ? 'You rated this ${status.rating ?? ''}★. Tap to edit your review'
                      : 'You received this product. Rate it and share your review',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grey600),
            ],
          ),
        ),
      ),
    );
  }
}
