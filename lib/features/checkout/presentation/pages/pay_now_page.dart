import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/services/razorpay_service.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:taksh_e_commerce/features/checkout/presentation/bloc/checkout_state.dart';

/// Pays (or retries paying) for an order that already exists and is still unpaid.
///
/// Uses the same supported steps as checkout: POST /payments/create for the order (the
/// server reuses an open Razorpay order or creates a new one), the Razorpay sheet, then
/// POST /payments/verify. It never creates an order, and success is shown only after the
/// server has verified the payment. If the verification call fails the page does NOT offer
/// to pay again (the payment may have gone through): it points to My Orders, where the
/// server's order/payment status is shown.
class PayNowPage extends StatefulWidget {
  const PayNowPage({super.key, required this.orderId, this.orderNumber});

  final int orderId;
  final String? orderNumber;

  @override
  State<PayNowPage> createState() => _PayNowPageState();
}

enum _Phase { starting, paying, confirming, failed, unconfirmed }

class _PayNowPageState extends State<PayNowPage> {
  late final RazorpayService _razorpay;
  _Phase _phase = _Phase.starting;
  String? _message;

  @override
  void initState() {
    super.initState();
    _razorpay = RazorpayService();
    _razorpay.initialize(
      onSuccess: _onRazorpaySuccess,
      onFailure: _onRazorpayFailure,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _razorpay.dispose();
    super.dispose();
  }

  void _start() {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.starting;
      _message = null;
    });
    context.read<CheckoutBloc>().add(InitiatePaymentEvent(widget.orderId));
  }

  void _onRazorpaySuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    // Razorpay reporting success is not proof: the server verifies the signature.
    setState(() => _phase = _Phase.confirming);
    context.read<CheckoutBloc>().add(
      VerifyPaymentEvent(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      ),
    );
  }

  void _onRazorpayFailure(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.failed;
      _message = response.message ?? 'The payment was not completed.';
    });
  }

  void _onState(BuildContext context, CheckoutState state) {
    if (state is PaymentInitiated) {
      final key = state.razorpayKey;
      if (key == null || key.isEmpty) {
        setState(() {
          _phase = _Phase.failed;
          _message = 'Online payment is not available right now.';
        });
        return;
      }
      setState(() => _phase = _Phase.paying);
      _razorpay.openCheckout(
        razorpayOrderId: state.razorpayOrderId,
        amountInPaise: state.amountInPaise,
        razorpayKey: key,
        orderNumber: widget.orderNumber,
      );
    } else if (state is PaymentVerified) {
      context.go(
        AppRoutes.orderPlacedPath(
          orderId: widget.orderId,
          orderNumber: widget.orderNumber,
          paymentMethod: 'online',
        ),
      );
    } else if (state is CheckoutError) {
      setState(() {
        _message = state.message;
        // An error while confirming a payment that was made is "not confirmed yet", not "failed".
        _phase = _phase == _Phase.confirming ? _Phase.unconfirmed : _Phase.failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _phase == _Phase.starting ||
        _phase == _Phase.paying ||
        _phase == _Phase.confirming;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.orderNumber != null ? 'Pay for #${widget.orderNumber}' : 'Pay now',
        ),
      ),
      body: BlocListener<CheckoutBloc, CheckoutState>(
        listener: _onState,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: busy ? _buildBusy() : _buildResult(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBusy() {
    final text = switch (_phase) {
      _Phase.confirming => 'Confirming your payment…',
      _Phase.paying => 'Complete the payment in the payment window…',
      _ => 'Preparing your payment…',
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(text, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final unconfirmed = _phase == _Phase.unconfirmed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          unconfirmed ? Icons.hourglass_bottom : Icons.error_outline,
          size: 56,
          color: unconfirmed ? Colors.orange : Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          unconfirmed
              ? 'We could not confirm your payment yet. If money was deducted it will be '
                  'confirmed automatically; check My Orders for the latest status.'
              : (_message ?? 'The payment could not be started.'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // After an unconfirmed payment paying again could charge twice, so only My Orders is offered.
        if (!unconfirmed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.orders),
            icon: const Icon(Icons.receipt_long),
            label: const Text('My Orders'),
          ),
        ),
      ],
    );
  }
}
