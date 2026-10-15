import 'package:dio/dio.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/error/exceptions.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/cart/data/models/cart_item_model.dart';
import 'package:taksh_e_commerce/features/cart/domain/entities/extra_charge.dart';
import 'package:taksh_e_commerce/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:taksh_e_commerce/features/checkout/data/models/checkout_summary_model.dart';
import 'package:taksh_e_commerce/features/checkout/data/models/delivery_option_model.dart';
import 'package:taksh_e_commerce/features/checkout/data/models/delivery_quote_model.dart';
import 'package:taksh_e_commerce/features/checkout/data/models/place_order_request_model.dart';
import 'package:taksh_e_commerce/features/checkout/data/models/place_order_response_model.dart';
import 'package:taksh_e_commerce/features/checkout/data/models/price_breakdown_model.dart';
import 'package:taksh_e_commerce/features/orders/data/models/order_model.dart';

/// Real API implementation of CheckoutRemoteDataSource
class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final ApiClient apiClient;

  CheckoutRemoteDataSourceImpl({required this.apiClient});

  final _log = loggerWithContext({
    'feature': 'checkout',
    'layer': 'datasource',
    'type': 'api',
  });

  // Store cart items - will be populated from bloc
  static final List<CartItemModel> _cartItems = [];

  // Method to set cart items (called by bloc)
  static void setCartItems(List<CartItemModel> items) {
    _cartItems.clear();
    _cartItems.addAll(items);
  }

  @override
  Future<CheckoutSummaryModel> calculateCheckout({
    required List<int> cartItemIds,
    required String deliveryType,
    String? addressId,
    String? couponCode,
  }) async {
    _log.infoWithContext('Calculating checkout from cart API', {
      'itemIds': cartItemIds,
      'deliveryType': deliveryType,
    });

    final response = await apiClient.get(
      ApiConstants.cart,
      queryParameters: {'delivery_type': deliveryType},
    );

    final root = (response.data as Map).cast<String, dynamic>();
    final data = (root['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final cart = (data['cart'] as Map?)?.cast<String, dynamic>() ?? const {};

    // Filter items based on selected IDs to preserve checkout selection UX.
    final selectedItems = _cartItems
        .where((item) => cartItemIds.contains(item.id))
        .toList();
    if (selectedItems.isEmpty) {
      throw const ServerException('No items selected for checkout');
    }

    final deliveryCharge = (cart['delivery_charge'] as Map?)
        ?.cast<String, dynamic>();
    final deliveryCode = (deliveryCharge?['code']?.toString() ?? deliveryType)
        .trim();
    // Quick delivery has no real ETA source: the server value is a static
    // placeholder, so it is never shown as a promise (0 = no estimate).
    final estimatedMinutes = deliveryCode == '30_min'
        ? 0
        : (_toInt(deliveryCharge?['estimated_minutes']) ??
              _defaultSlaFor(deliveryCode));
    final deliveryChargeRupees = _toDouble(deliveryCharge?['price']) ?? 0.0;

    final chargesRaw = (cart['charges'] as List?)?.whereType<Map>() ?? const [];
    // Amounts stay exact (paise are not rounded away).
    var cgstRupees = 0.0;
    var sgstRupees = 0.0;
    var discountRupees = 0.0;

    for (final raw in chargesRaw) {
      final charge = raw.cast<String, dynamic>();
      final type = (charge['type']?.toString() ?? '').trim().toLowerCase();
      final amount = _toDouble(charge['amount']) ?? 0.0;
      final isDiscount = _toBool(charge['is_discount']) ?? amount < 0;

      if (isDiscount || type == 'discount') {
        discountRupees += amount.abs();
        continue;
      }

      if (type == 'cgst') {
        cgstRupees += amount;
      } else if (type == 'sgst') {
        sgstRupees += amount;
      }
    }

    final itemTotalRupees =
        _toDouble(cart['total']) ??
        selectedItems.fold<double>(0, (sum, item) => sum + item.total);

    // Delivery is no longer charged — the Taksh charge already covers it.
    // Other fees (platform, quick delivery) arrive in `charges[]` and are
    // rendered separately, so they must not be folded into the delivery line.
    final deliveryChargesRupees = deliveryChargeRupees;

    // Only used when the server did not send a total: the server's
    // total_with_delivery is the authoritative payable amount.
    final computedGrandTotal =
        itemTotalRupees +
        deliveryChargesRupees +
        cgstRupees +
        sgstRupees -
        discountRupees;

    final grandTotalRupees =
        _toDouble(cart['total_with_delivery']) ?? computedGrandTotal;

    final priceBreakdown = PriceBreakdownModel(
      itemTotal: itemTotalRupees,
      deliveryCharges: deliveryChargesRupees,
      cgst: cgstRupees,
      sgst: sgstRupees,
      discount: discountRupees,
      grandTotal: grandTotalRupees,
    );

    final deliveryOption = _mapDeliveryOption(
      code: deliveryCode,
      estimatedMinutes: estimatedMinutes,
      chargeInRupees: deliveryChargeRupees,
    );

    return CheckoutSummaryModel(
      itemModels: selectedItems,
      priceBreakdownModel: priceBreakdown,
      deliveryOptionModel: deliveryOption,
      selectedAddressModel: null,
    );
  }

  @override
  Future<List<DeliveryOptionModel>> getDeliveryOptions({
    required String addressId,
  }) async {
    _log.infoWithContext('Getting delivery options (using hardcoded data)', {
      'addressId': addressId,
    });

    // TODO: Replace with actual API call when endpoint is available.
    // NOTE: Only two delivery types are supported:
    //   normal  → 1-day standard delivery (always available)
    //   30_min  → express delivery        (availability determined per pincode)
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      DeliveryOptionModel(
        type: 'normal',
        displayName: 'Standard Delivery',
        charges: 0,
        slaMinutes: 2880,
        isAvailable: true,
      ),
      DeliveryOptionModel(
        type: '1_day',
        displayName: '1-Day Delivery',
        charges: 0,
        slaMinutes: 1440,
        isAvailable: true,
      ),
      DeliveryOptionModel(
        type: '30_min',
        displayName: 'Quick Delivery',
        charges: 0,
        slaMinutes: 0,
        isAvailable: true,
      ),
    ];
  }

  @override
  Future<DeliveryQuoteModel> getDeliveryQuote({
    required String deliveryType,
    required String addressId,
  }) async {
    _log.infoWithContext('Requesting delivery quote', {
      'deliveryType': deliveryType,
      'addressId': addressId,
    });

    // Only the delivery type and the saved address id are sent: the server
    // owns the serviceability decision (no coordinates, no radius).
    final response = await apiClient.get(
      ApiConstants.cartQuote,
      queryParameters: {
        'delivery_type': deliveryType,
        'address_id': addressId,
      },
    );

    final root = response.data;
    final data = root is Map ? root['data'] : null;
    if (data is! Map) {
      throw const ServerException('Delivery quote not received');
    }
    return DeliveryQuoteModel.fromJson(
      data.cast<String, dynamic>(),
      deliveryType: deliveryType,
    );
  }

  DeliveryOptionModel _mapDeliveryOption({
    required String code,
    required int estimatedMinutes,
    required double chargeInRupees,
  }) {
    final normalized = code.trim();
    final displayName = switch (normalized) {
      '30_min' => 'Quick Delivery',
      '1_day' => '1-Day Delivery',
      _ => 'Standard Delivery',
    };

    return DeliveryOptionModel(
      type: normalized,
      displayName: displayName,
      charges: (chargeInRupees * 100).round(),
      slaMinutes: estimatedMinutes,
      isAvailable: true,
    );
  }

  int _defaultSlaFor(String code) {
    return switch (code.trim()) {
      '30_min' => 0,
      '1_day' => 1440,
      _ => 2880,
    };
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  @override
  Future<bool> validateCheckout({required DataMap orderRequest}) async {
    _log.infoWithContext('Validating checkout locally', orderRequest);

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock validation - always returns true
    // Add any local validation logic here if needed
    return true;
  }

  @override
  Future<OrderModel> createOrder({required DataMap orderRequest}) async {
    try {
      _log.infoWithContext('Creating order via API', orderRequest);

      final response = await apiClient.post(
        ApiConstants.placeOrder,
        data: orderRequest,
      );

      return OrderModel.fromJson(response.data['data'] as DataMap);
    } on AppException catch (e) {
      _log.errorWithContext('API error creating order', {
        'error': e.message,
        'statusCode': e.statusCode,
      });
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      _log.errorWithContext('Unexpected error creating order', {
        'error': e.toString(),
      });
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PlaceOrderResponseModel> placeOrder({
    required String addressId,
    required String warehouseId,
    required String deliveryType,
    required String paymentMethod,
    required String vendorId,
    required List<ExtraCharge> extraCharges,
  }) async {
    try {
      _log.infoWithContext('Placing order via API', {
        'addressId': addressId,
        'warehouseId': warehouseId,
        'deliveryType': deliveryType,
        'paymentMethod': paymentMethod,
        'vendorId': vendorId,
        'extraChargesCount': extraCharges.length,
      });

      final requestModel = PlaceOrderRequestModel(
        addressId: addressId,
        warehouseId: warehouseId,
        deliveryType: deliveryType,
        paymentMethod: paymentMethod,
        vendorId: vendorId,
        extraCharges: extraCharges,
      );

      final formData = FormData.fromMap(requestModel.toFormData());

      _log.debugWithContext('Form data for place order', {
        'formData': formData.fields,
      });

      final response = await apiClient.post(
        ApiConstants.placeOrder,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      // Handle flexible response structure
      final responseData = response.data;

      // If the response is directly the data without wrapping
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return PlaceOrderResponseModel.fromJson(
            responseData['data'] as DataMap,
          );
        } else {
          return PlaceOrderResponseModel.fromJson(responseData);
        }
      }

      throw const ServerException('Invalid response format');
    } on TimeoutException catch (e) {
      _log.errorWithContext('Timeout error placing order', {
        'error': e.message,
      });
      throw ServerException(e.message);
    } on NetworkException catch (e) {
      _log.errorWithContext('Network error placing order', {
        'error': e.message,
      });
      throw ServerException(e.message);
    } on CodedApiException {
      // quick_location_required / quick_not_serviceable keep their code.
      rethrow;
    } on BadRequestException catch (e) {
      _log.errorWithContext('Bad request error placing order', {
        'error': e.message,
        'statusCode': e.statusCode,
      });
      throw ServerException(e.message, e.statusCode);
    } on AppException catch (e) {
      _log.errorWithContext('API error placing order', {
        'error': e.message,
        'statusCode': e.statusCode,
      });
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      _log.errorWithContext('Unexpected error placing order', {
        'error': e.toString(),
      });
      throw ServerException(e.toString());
    }
  }
}
