import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/core/utils/money_format.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

/// The items of one shop. Each shop's items become one order.
class VendorItemGroup {
  final int? vendorId;
  final String? vendorName;
  final List<CartItem> items;

  const VendorItemGroup({
    required this.vendorId,
    required this.vendorName,
    required this.items,
  });

  int get itemsCount => items.fold(0, (sum, item) => sum + item.qty);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
}

/// Splits items by shop, in the order the shops first appear. Items without a shop
/// (an older server) are kept together, so nothing is lost or reordered.
List<VendorItemGroup> groupItemsByVendor(List<CartItem> items) {
  final byVendor = <int?, List<CartItem>>{};
  final names = <int?, String?>{};
  for (final item in items) {
    byVendor.putIfAbsent(item.vendorId, () => []).add(item);
    names.putIfAbsent(item.vendorId, () => item.vendorName);
  }
  return [
    for (final entry in byVendor.entries)
      VendorItemGroup(
        vendorId: entry.key,
        vendorName: names[entry.key],
        items: entry.value,
      ),
  ];
}

/// Shown on checkout when the items come from several shops: says that one order is
/// placed per shop and lists each of them. Renders nothing for a single shop, so a
/// normal checkout looks exactly as before.
class MultiOrderNotice extends StatelessWidget {
  final List<CartItem> items;

  const MultiOrderNotice({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final groups = groupItemsByVendor(items);
    if (groups.length < 2) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.call_split,
                size: 18,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.checkoutSplitNotice(groups.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < groups.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        l10n.orderOfTotal(i + 1, groups.length),
                        if (groups[i].vendorName != null &&
                            groups[i].vendorName!.isNotEmpty)
                          groups[i].vendorName!,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '${l10n.itemsCount(groups[i].itemsCount)} · ₹${formatRupees(groups[i].subtotal)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
