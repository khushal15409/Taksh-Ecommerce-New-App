import 'package:taksh_e_commerce/features/checkout/domain/entities/delivery_quote.dart';

/// Quick checkout fails closed: it may only proceed when the server quote for
/// the selected address says `serviceable == true`. A missing quote (not
/// requested yet, request failed, no address) blocks it.
bool isQuickCheckoutBlocked({
  required bool quickSelected,
  required DeliveryQuote? quote,
}) {
  if (!quickSelected) return false;
  if (quote == null) return true;
  return !quote.serviceable;
}

/// Quote used when the quote request itself failed (fail closed).
DeliveryQuote failedQuote({String? message}) => DeliveryQuote(
      deliveryType: '30_min',
      checked: false,
      serviceable: false,
      code: 'quote_unavailable',
      message: message,
    );
