import 'package:dio/dio.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/features/address/data/models/address_model.dart';

/// Remote data source for address operations
abstract class AddressRemoteDataSource {
  /// Add a new address to the server
  Future<void> addAddress(AddressModel address);

  /// Get all addresses from the server
  Future<List<AddressModel>> getAddresses();

  /// Update an existing address on the server
  Future<void> updateAddress(AddressModel address);

  /// Delete an address from the server
  Future<void> deleteAddress(String id);

  /// Set an address as default on the server
  Future<void> setDefaultAddress(String id);
}

/// Implementation of [AddressRemoteDataSource]
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient apiClient;

  AddressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> addAddress(AddressModel address) async {
    // State, city and area are NOT sent: the server works them out from the pincode (and
    // answers 422 for a pincode it does not know) instead of the app inventing ids. The
    // pincode is the one the customer entered or picked; a missing one is sent empty so
    // the server rejects it, never replaced by a made-up value.
    final formData = <String, dynamic>{
      'name': address.recipientName,
      'mobile': address.recipientPhone,
      'address_line_1': address.addressLine1,
      'pincode': address.location.postalCode ?? '',
      'address_type': address.type.name, // Send 'home', 'work', or 'other'
      'is_default': address.isDefault ? '1' : '0',
    };

    // Add optional fields
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      formData['address_line_2'] = address.addressLine2;
    }
    if (address.landmark != null && address.landmark!.isNotEmpty) {
      formData['landmark'] = address.landmark;
    }
    _addCoordinates(formData, address);

    // API returns 201 with no body on success
    await apiClient.post(
      ApiConstants.addAddress,
      data: formData,
    );
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await apiClient.get(ApiConstants.addresses);

    // The API returns the default address separately (data.default_address)
    // and only the other addresses under data.addresses, so both are needed
    // to get the user's full list (a user with one address has an empty
    // data.addresses). The default address comes first.
    final dataWrapper = response.data['data'] as Map<String, dynamic>;
    final defaultJson = dataWrapper['default_address'];
    final addressesList = (dataWrapper['addresses'] as List?) ?? const [];
    return [
      if (defaultJson is Map<String, dynamic>) AddressModel.fromJson(defaultJson),
      ...addressesList.map((json) => AddressModel.fromJson(json)),
    ];
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    // state_id / city_id / area_id are deliberately not sent: the server keeps
    // the ones already saved, instead of overwriting them with placeholders.
    final formData = <String, dynamic>{
      'name': address.recipientName,
      'mobile': address.recipientPhone,
      'address_line_1': address.addressLine1,
      'address_type': address.type.name, // Send 'home', 'work', or 'other'
      'is_default': address.isDefault ? '1' : '0',
    };

    // An edit without a pincode keeps the one already saved.
    final pincode = address.location.postalCode;
    if (pincode != null && pincode.isNotEmpty) {
      formData['pincode'] = pincode;
    }

    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      formData['address_line_2'] = address.addressLine2;
    }
    if (address.landmark != null && address.landmark!.isNotEmpty) {
      formData['landmark'] = address.landmark;
    }

    _addCoordinates(formData, address);

    await apiClient.put(
      ApiConstants.updateAddress(address.id),
      data: formData,
    );
  }

  /// Sends the picked location when there is one (0,0 means "not set").
  void _addCoordinates(Map<String, dynamic> formData, AddressModel address) {
    final latitude = address.location.latitude;
    final longitude = address.location.longitude;
    if (latitude != 0.0 || longitude != 0.0) {
      formData['latitude'] = latitude.toString();
      formData['longitude'] = longitude.toString();
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    await apiClient.post(
      ApiConstants.deleteAddress(id),
      data: FormData.fromMap({'address_id': id}),
    );
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    // The backend sets the default through this existing POST route.
    await apiClient.post(
      ApiConstants.setDefaultAddress(id),
      data: FormData.fromMap({'address_id': id}),
    );
  }
}
