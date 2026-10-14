import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/core/theme/app_spacing.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_carousel.dart';

/// Fetches the banners of type `service` managed from the admin panel.
///
/// Never throws: on any failure an empty list is returned so the services
/// screen keeps working without banners.
Future<List<BannerModel>> fetchServiceBanners() async {
  final log = loggerWithContext({
    'feature': 'home_service',
    'action': 'fetchServiceBanners',
  });
  try {
    final response = await getIt<ApiClient>().get(
      ApiConstants.ecommerceBanners,
      queryParameters: {'type': 'service'},
    );
    final body = response.data;
    final raw = body is Map ? body['data'] : null;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  } catch (e) {
    log.warnWithContext('Failed to load service banners', {
      'error': e.toString(),
    });
    return const [];
  }
}

/// A block of service banners for one position (top / middle / bottom).
///
/// One banner renders as a static card, several as a slider. Renders nothing
/// when [banners] is empty.
class ServiceBannersSection extends StatelessWidget {
  final List<BannerModel> banners;

  const ServiceBannersSection({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      // The parent already applies the screen padding.
      child: BannerCarousel(banners: banners, horizontalPadding: 0),
    );
  }
}
