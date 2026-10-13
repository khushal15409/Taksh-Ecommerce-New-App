import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/dashed_divider.dart';
import 'package:taksh_e_commerce/core/widgets/festive_auth_background.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/extra_charge.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/price_breakdown.dart';

/// Widget for displaying price breakdown
class PriceBreakdownWidget extends StatelessWidget {
  final PriceBreakdown priceBreakdown;
  final List<ExtraCharge> extraCharges;

  const PriceBreakdownWidget({
    super.key,
    required this.priceBreakdown,
    this.extraCharges = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.grey900,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.priceDetails,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
      decoration: festiveCardDecoration(radius: 22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildPriceRow(
              context,
              'Item Total',
              priceBreakdown.itemTotalInRupees,
              isRegular: true,
            ),
            const SizedBox(height: 12),
            _buildPriceRow(
              context,
              'Delivery Charges',
              priceBreakdown.deliveryChargesInRupees,
              isRegular: true,
              isFree: priceBreakdown.deliveryCharges == 0,
            ),
            for (final charge in extraCharges) ...[
              const SizedBox(height: 12),
              _buildPriceRow(
                context,
                charge.label,
                charge.amount.toDouble(),
                isRegular: true,
                isDiscount: charge.isDiscount,
              ),
            ],
            if (priceBreakdown.discount > 0) ...[
              const SizedBox(height: 12),
              _buildPriceRow(
                context,
                'Discount',
                -priceBreakdown.discountInRupees,
                isRegular: true,
                isDiscount: true,
              ),
            ],
            const SizedBox(height: 14),
            const DashedDivider(),
            const SizedBox(height: 14),
            _buildPriceRow(
              context,
              'Grand Total',
              priceBreakdown.grandTotalInRupees,
              isTotal: true,
            ),
          ],
        ),
      ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isRegular = false,
    bool isTotal = false,
    bool isFree = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: isTotal
              ? const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)
              : const TextStyle(fontSize: 16, color: AppColors.grey700),
        ),
        const SizedBox(width: 16),
        if (isFree)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'FREE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        else
          Text(
            '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
            style: isTotal
                ? const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryOrange,
                  )
                : TextStyle(
                    fontSize: 16,
                    color: isDiscount
                        ? AppColors.secondaryGreen
                        : AppColors.grey900,
                    fontWeight: isDiscount ? FontWeight.bold : FontWeight.w500,
                  ),
          ),
      ],
    );
  }
}
