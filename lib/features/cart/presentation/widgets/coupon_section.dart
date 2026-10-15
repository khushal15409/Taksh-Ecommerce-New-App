import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/utils/money_format.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/cart.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/extra_charge.dart';
import 'package:taksh_e_commerce/features/cart/presentation/cubit/cart_cubit.dart';

/// Coupon entry for the cart bill. The server decides whether a coupon is valid and what
/// it takes off: this widget only sends the code and shows the cart that comes back
/// (the coupon line and the new total are part of it). A coupon stays on the cart, so it
/// is still applied when the customer goes on to checkout.
class CouponSection extends StatefulWidget {
  const CouponSection({
    super.key,
    required this.cart,
    required this.deliveryType,
  });

  final Cart cart;

  /// 'normal' or '30_min' - the bucket whose total the coupon is judged on.
  final String deliveryType;

  @override
  State<CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<CouponSection> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The coupon line of the cart, when a coupon is applied (type `coupon`).
  ExtraCharge? get _applied {
    for (final charge in widget.cart.extraCharges) {
      if (charge.type == 'coupon') return charge;
    }
    return null;
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (_busy) return;
    if (code.isEmpty) {
      setState(() => _error = 'Enter a coupon code');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final message = await context.read<CartCubit>().applyCoupon(
      code,
      deliveryType: widget.deliveryType,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
      if (message == null) _controller.clear();
    });
  }

  Future<void> _remove() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    final message = await context.read<CartCubit>().removeCoupon(
      deliveryType: widget.deliveryType,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final applied = _applied;

    if (applied != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, size: 16, color: Color(0xFF2F9E55)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${applied.label} - you save ₹${formatRupees(applied.amount.abs())}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F9E55),
                ),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _remove,
              child: Text(_busy ? '...' : 'Remove'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _apply(),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Have a coupon code?',
                    prefixIcon: Icon(Icons.local_offer_outlined, size: 18),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _busy ? null : _apply,
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Apply'),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
