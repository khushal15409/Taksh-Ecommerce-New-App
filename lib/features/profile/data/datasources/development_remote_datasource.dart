import 'package:flutter/foundation.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/features/profile/data/models/development_request_model.dart';
import 'package:taksh_e_commerce/features/profile/data/models/development_response_model.dart';

/// Remote data source for development operations
abstract class DevelopmentRemoteDataSource {
  /// Submit a development request to the server
  Future<DevelopmentResponseModel> submitDevelopmentRequest(
    DevelopmentRequestModel request,
  );
}

/// Implementation of [DevelopmentRemoteDataSource]
class DevelopmentRemoteDataSourceImpl implements DevelopmentRemoteDataSource {
  final ApiClient apiClient;

  DevelopmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DevelopmentResponseModel> submitDevelopmentRequest(
    DevelopmentRequestModel request,
  ) async {
    // Convert request to form data
    final formData = request.toFormData();
    
    // The form carries the customer's contact details, so it is not printed.

    try {
      // Make API call
      final response = await apiClient.post(
        ApiConstants.developmentRequest,
        data: formData,
      );

      // Parse response
      final data = response.data['data'] as Map<String, dynamic>;
      return DevelopmentResponseModel.fromJson(data);
    } catch (e) {
      // The error text can echo the submitted form (contact details), so only its type
      // is printed, and only in debug builds.
      if (kDebugMode) {
        debugPrint('Development Request Error: ${e.runtimeType}');
      }
      rethrow;
    }
  }
}
