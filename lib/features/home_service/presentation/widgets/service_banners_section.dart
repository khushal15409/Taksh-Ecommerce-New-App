import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/core/constants/api_constants.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/network/api_client.dart';
import 'package:taksh_e_commerce/core/theme/app_spacing.dart';
import 'package:taksh_e_commerce/core/utils/logger/logger.dart';
import 'package:taksh_e_commerce/features/home/data/models/banner_model.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/banner_carousel.dart';

/// Banners of type `service`, managed from the admin panel.
///
/// One banner renders as a static card, several as a slider. The section is
/// hidden while loading, on error, or when admin has no service banners.
class ServiceBannersSection extends StatefulWidget {
  const ServiceBannersSection({super.key});

  @override
  State<ServiceBannersSection> createState() => _ServiceBannersSectionState();
}

class _ServiceBannersSectionState extends State<ServiceBannersSection> {
  final _log = loggerWithContext({
    'feature': 'home_service',
    'widget': 'ServiceBannersSection',
  });

  List<BannerModel> _banners = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await getIt<ApiClient>().get(
        ApiConstants.ecommerceBanners,
        queryParameters: {'type': 'service'},
      );
      final body = response.data;
      final raw = body is Map ? body['data'] : null;
      if (raw is! List) return;
      final banners = raw
          .whereType<Map>()
          .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (mounted) setState(() => _banners = banners);
    } catch (e) {
      _log.warnWithContext('Failed to load service banners', {
        'error': e.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      // The parent already applies the screen padding.
      child: BannerCarousel(banners: _banners, horizontalPadding: 0),
    );
  }
}
