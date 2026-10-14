import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/features/checkout/domain/entities/payment_method_selection.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/widgets/checkout_section_card.dart';
import 'package:taksh_e_commerce/l10n/app_localizations.dart';

/// Widget for selecting payment method (COD or Online)
class PaymentMethodSelectorWidget extends StatefulWidget {
  const PaymentMethodSelectorWidget({super.key});

  @override
  State<PaymentMethodSelectorWidget> createState() =>
      _PaymentMethodSelectorWidgetState();
}

class _PaymentMethodSelectorWidgetState
    extends State<PaymentMethodSelectorWidget> {
  PaymentMethodSelection _selectedMethod = PaymentMethodSelection.cod;

  @override
  void initState() {
    super.initState();
    // Set initial selection from bloc
    _selectedMethod = context.read<CheckoutBloc>().selectedPaymentMethod;
  }

  void _selectPaymentMethod(PaymentMethodSelection method) {
    setState(() {
      _selectedMethod = method;
    });
    context.read<CheckoutBloc>().add(SelectPaymentMethodEvent(method));
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      icon: Icons.account_balance_wallet_outlined,
      title: AppLocalizations.of(context)!.paymentMethod,
      bodyPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: Column(
        children: [
          // COD Payment Method
          _buildPaymentMethodTile(
            method: PaymentMethodSelection.cod,
            icon: Icons.payments_outlined,
            title: PaymentMethodType.cod.displayName,
            subtitle: PaymentMethodSelection.cod.description,
            isSelected: _selectedMethod.type == PaymentMethodType.cod,
            onTap: () => _selectPaymentMethod(PaymentMethodSelection.cod),
          ),
          const SizedBox(height: 8),
          // Online Payment Method
          _buildPaymentMethodTile(
            method: PaymentMethodSelection.online,
            icon: Icons.credit_card_rounded,
            title: PaymentMethodType.online.displayName,
            subtitle: PaymentMethodSelection.online.description,
            isSelected: _selectedMethod.type == PaymentMethodType.online,
            onTap: () => _selectPaymentMethod(PaymentMethodSelection.online),
            trailing: _buildPaymentLogos(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentMethodSelection method,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : Colors.black.withOpacity(0.06),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: trailing != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange.withOpacity(0.18)
                    : const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.grey900,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.grey600,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 10),
                    trailing,
                  ],
                ],
              ),
            ),
            // Radio indicator (the whole tile is tappable)
            Padding(
              padding: EdgeInsets.only(top: trailing != null ? 14 : 0),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 32,
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.grey900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentLogos() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildPaymentLogo('Razorpay', Colors.blue.shade700),
        _buildPaymentLogo('Cards', Colors.green.shade700),
        _buildPaymentLogo('UPI', Colors.orange.shade700),
        _buildPaymentLogo('Wallets', Colors.purple.shade700),
      ],
    );
  }

  Widget _buildPaymentLogo(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
