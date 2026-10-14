import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/widgets/dashed_divider.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/checkout_section_card.dart';
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
        CheckoutSectionTitle(
          icon: Icons.description_rounded,
          iconColor: AppColors.grey900,
          title: AppLocalizations.of(context)!.priceDetails,
        ),
        Container(
          decoration: checkoutCardDecoration(),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 8),
          child: Column(
            children: [
              _buildPriceRow(
                context,
                'Item Total',
                priceBreakdown.itemTotalInRupees,
                isRegular: true,
              ),
              _buildPriceRow(
                context,
                'Delivery Charges',
                priceBreakdown.deliveryChargesInRupees,
                isRegular: true,
                isFree: priceBreakdown.deliveryCharges == 0,
              ),
              for (final charge in extraCharges)
                _buildPriceRow(
                  context,
                  charge.label,
                  charge.amount.toDouble(),
                  isRegular: true,
                  isDiscount: charge.isDiscount,
                ),
              if (priceBreakdown.discount > 0)
                _buildPriceRow(
                  context,
                  'Discount',
                  -priceBreakdown.discountInRupees,
                  isRegular: true,
                  isDiscount: true,
                ),
              const SizedBox(height: 2),
              const DashedDivider(),
              const SizedBox(height: 10),
              _buildPriceRow(
                context,
                'Grand Total',
                priceBreakdown.grandTotalInRupees,
                isTotal: true,
              ),
            ],
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
    return Padding(
      padding: EdgeInsets.only(bottom: isTotal ? 0 : 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  )
                : const TextStyle(fontSize: 11, color: AppColors.grey700),
          ),
          const SizedBox(width: 16),
          if (isFree)
            const Text(
              'FREE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryGreen,
              ),
            )
          else
            Text(
              '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
              style: isTotal
                  ? const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryOrange,
                    )
                  : TextStyle(
                      fontSize: 11,
                      color: isDiscount
                          ? AppColors.secondaryGreen
                          : AppColors.grey900,
                      fontWeight: isDiscount
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
            ),
        ],
      ),
    );
  }
}
