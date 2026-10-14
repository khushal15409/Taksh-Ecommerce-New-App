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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionTitle(
          icon: Icons.credit_card_rounded,
          title: AppLocalizations.of(context)!.paymentMethod,
        ),
        Container(
          decoration: checkoutCardDecoration(),
          padding: const EdgeInsets.fromLTRB(6, 1, 6, 6),
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
              const SizedBox(height: 6),
              // Online Payment Method
              _buildPaymentMethodTile(
                method: PaymentMethodSelection.online,
                icon: Icons.credit_card_rounded,
                title: PaymentMethodType.online.displayName,
                subtitle: PaymentMethodSelection.online.description,
                isSelected: _selectedMethod.type == PaymentMethodType.online,
                onTap: () =>
                    _selectPaymentMethod(PaymentMethodSelection.online),
                trailing: _buildPaymentLogos(),
              ),
            ],
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 8, 12, 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF4E6) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : Colors.black.withOpacity(0.06),
            width: isSelected ? 1.1 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: trailing != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 39,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange.withOpacity(0.18)
                    : const Color(0xFFEDEDED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.grey900,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.grey600,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 7),
                    trailing,
                  ],
                ],
              ),
            ),
            // Radio indicator (the whole tile is tappable)
            Padding(
              padding: EdgeInsets.only(top: trailing != null ? 4 : 10),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 17,
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
        _buildPaymentLogo('Razorpay', Icons.bolt_rounded, Colors.blue.shade700),
        _buildPaymentLogo('Cards', Icons.credit_card, Colors.green.shade700),
        _buildPaymentLogo(
          'UPI',
          Icons.account_balance_outlined,
          Colors.orange.shade700,
        ),
        _buildPaymentLogo(
          'Wallets',
          Icons.account_balance_wallet_rounded,
          Colors.purple.shade700,
        ),
      ],
    );
  }

  Widget _buildPaymentLogo(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
