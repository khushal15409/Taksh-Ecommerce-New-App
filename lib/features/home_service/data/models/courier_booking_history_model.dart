import 'package:taksh_e_commerce/features/home_service/data/models/courier_json.dart';
import 'package:taksh_e_commerce/features/home_service/domain/entities/courier_booking_history.dart';

CourierBookingSummary courierSummaryFromJson(Map<String, dynamic> j) {
  return CourierBookingSummary(
    id: cInt(j['id']),
    bookingNumber: cStr(j['booking_number']),
    status: cStr(j['status']),
    paymentStatus: cStr(j['payment_status']).isEmpty
        ? 'pending'
        : cStr(j['payment_status']),
    customerName: cStr(j['customer_name']),
    pickupPincode: cStr(j['pickup_pincode']),
    deliveryPincode: cStr(j['delivery_pincode']),
    totalAmount: cDouble(j['total_amount']),
    courierName: cStr(j['courier_name'] ?? cMap(j['partner'])['name']),
    awbCode: cNullStr(j['awb_code']),
    shipmentStatus: cNullStr(j['shipment_status']),
    shipmentStatusLabel: cNullStr(j['shipment_status_label']),
    createdAt: cDate(j['created_at']),
  );
}

CourierBookingsPage courierPageFromJson(Map<String, dynamic> json) {
  final list = json['bookings'] is List ? json['bookings'] as List : const [];
  final p = cMap(json['pagination']);
  return CourierBookingsPage(
    bookings: list
        .whereType<Map>()
        .map((e) => courierSummaryFromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false),
    currentPage: cInt(p['current_page']),
    lastPage: cInt(p['last_page']),
    total: cInt(p['total']),
  );
}

CourierBookingDetail courierDetailFromJson(Map<String, dynamic> j) {
  final pricing = cMap(j['pricing']);
  final payment = cMap(j['payment']);
  final cancel = cMap(j['cancellation']);
  final refund = cMap(j['refund']);
  final shipment = cMap(j['shipment']);
  final events = j['tracking_timeline'] is List
      ? j['tracking_timeline'] as List
      : const [];

  return CourierBookingDetail(
    id: cInt(j['id']),
    bookingNumber: cStr(j['booking_number']),
    status: cStr(j['status']),
    paymentStatus: cStr(j['payment_status']).isEmpty
        ? 'pending'
        : cStr(j['payment_status']),
    customerName: cStr(j['customer_name']),
    customerMobile: cStr(j['customer_mobile']),
    pickupAddress: cStr(j['pickup_address']),
    pickupPincode: cStr(j['pickup_pincode']),
    deliveryName: cStr(j['delivery_name']),
    deliveryMobile: cStr(j['delivery_mobile']),
    deliveryAddress: cStr(j['delivery_address']),
    deliveryPincode: cStr(j['delivery_pincode']),
    weightGrams: cDouble(j['weight_grams']),
    chargeableWeightGrams: cDouble(j['chargeable_weight_grams']),
    dimensionUnit: cStr(j['dimension_unit']),
    length: cDouble(j['length']),
    width: cDouble(j['width']),
    height: cDouble(j['height']),
    productDetails: cNullStr(j['product_details']),
    packagingDetails: cNullStr(j['packaging_details']),
    customerNotes: cNullStr(j['customer_notes']),
    itemPhotoPath: cNullStr(j['item_photo_path']),
    courierName: cStr(j['courier_name'] ?? cMap(j['delivery_partner'])['name']),
    awbCode: cNullStr(j['awb_code']),
    trackingUrl: cNullStr(j['tracking_url']),
    estimatedDeliveryDays: cNullInt(j['estimated_delivery_days']),
    shipmentStatus: cNullStr(j['shipment_status']),
    shipmentStatusLabel: cNullStr(shipment['status_label']),
    totalAmount: cDouble(j['total_amount']),
    courierRate: cNullDouble(pricing['shiprocket_cost']),
    serviceCharge: cNullDouble(pricing['service_charge']),
    paidAmount: cNullDouble(payment['paid_amount']),
    paidAt: cDate(payment['paid_at']),
    createdAt: cDate(j['created_at']),
    cancelledAt: cDate(cancel['cancelled_at']),
    cancellationReason: cNullStr(cancel['reason']),
    refundStatus: cNullStr(refund['status']),
    refundAmount: cNullDouble(refund['amount']),
    timeline: events
        .whereType<Map>()
        .map((e) {
          final m = Map<String, dynamic>.from(e);
          return CourierTrackingEvent(
            title: cStr(m['title']).isEmpty
                ? cStr(m['status'])
                : cStr(m['title']),
            description: cNullStr(m['description']),
            location: cNullStr(m['location']),
            eventTime: cDate(m['event_time']),
          );
        })
        .toList(growable: false),
  );
}

CourierCancelResult courierCancelFromJson(Map<String, dynamic> j) {
  return CourierCancelResult(
    message: cStr(j['message']),
    refundStatus: cNullStr(j['refund_status']),
    refundAmount: cNullDouble(j['refund_amount']),
  );
}
