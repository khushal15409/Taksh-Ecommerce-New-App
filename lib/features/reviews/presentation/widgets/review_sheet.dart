import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/features/reviews/domain/repositories/review_repository.dart';
import 'package:taksh_e_commerce/features/reviews/presentation/cubit/review_submit_cubit.dart';

/// Bottom sheet to rate (1-5 stars) and optionally review a delivered product.
///
/// [show] completes with true once the rating was saved, false when the sheet
/// was closed without one.
class ReviewSheet extends StatefulWidget {
  final int productId;
  final String productName;
  final String? imageUrl;
  final int initialRating;
  final String? initialTitle;
  final String? initialText;

  const ReviewSheet({
    super.key,
    required this.productId,
    required this.productName,
    this.imageUrl,
    this.initialRating = 0,
    this.initialTitle,
    this.initialText,
  });

  static Future<bool> show(
    BuildContext context, {
    required int productId,
    required String productName,
    String? imageUrl,
    int initialRating = 0,
    String? initialTitle,
    String? initialText,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => ReviewSubmitCubit(repository: getIt<ReviewRepository>()),
        child: ReviewSheet(
          productId: productId,
          productName: productName,
          imageUrl: imageUrl,
          initialRating: initialRating,
          initialTitle: initialTitle,
          initialText: initialText,
        ),
      ),
    );
    return saved ?? false;
  }

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  late int _rating = widget.initialRating;
  late final TextEditingController _title =
      TextEditingController(text: widget.initialTitle);
  late final TextEditingController _text =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating < 1) return;
    FocusScope.of(context).unfocus();
    context.read<ReviewSubmitCubit>().submit(
          productId: widget.productId,
          rating: _rating,
          title: _title.text,
          text: _text.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewSubmitCubit, ReviewSubmitState>(
      listener: (context, state) {
        if (state.status == ReviewSubmitStatus.success) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text(
                state.result?.message ?? 'Thank you! Your rating has been submitted',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final busy = state.isSubmitting;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rate your product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProduct(),
                const SizedBox(height: 16),
                Center(child: _buildStars(busy)),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _labels[_rating],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _title,
                  enabled: !busy,
                  maxLength: 150,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration('Title (optional)'),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _text,
                  enabled: !busy,
                  maxLength: 2000,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration('Write your review (optional)'),
                ),
                if (state.status == ReviewSubmitStatus.failure) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Could not submit your rating',
                    style: const TextStyle(color: Colors.red, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            busy ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Later'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: busy || _rating < 1 ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  Widget _buildProduct() {
    final url = widget.imageUrl;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 52,
            height: 52,
            color: AppColors.grey100,
            child: url != null && url.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image_outlined, color: AppColors.grey400),
                  )
                : const Icon(Icons.image_outlined, color: AppColors.grey400),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStars(bool busy) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          onPressed: busy ? null : () => setState(() => _rating = star),
          iconSize: 38,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: Icon(
            star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: const Color(0xFFF7B500),
          ),
        );
      }),
    );
  }
}
