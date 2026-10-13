import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/delivery_type_selector.dart';

/// Centralised visual theme for the three Home modes
/// (Standard = orange, Quick = green, Services = purple).
///
/// Presentation only — no data or business logic lives here.
class HomeModeTheme {
  final String backgroundAsset;
  final Color accent;
  final Color accentDark;
  final Color accentSoft;
  final IconData tabIcon;
  final Color sparkle;

  const HomeModeTheme({
    required this.backgroundAsset,
    required this.accent,
    required this.accentDark,
    required this.accentSoft,
    required this.tabIcon,
    required this.sparkle,
  });

  static const standard = HomeModeTheme(
    backgroundAsset: 'assets/images/diwali/home_standard_diwali_bg.jpg',
    accent: Color(0xFFF26A0E),
    accentDark: Color(0xFFD94F00),
    accentSoft: Color(0xFFFFF1E4),
    tabIcon: Icons.local_shipping_rounded,
    sparkle: Color(0xFFFFE08A),
  );

  static const quick = HomeModeTheme(
    backgroundAsset: 'assets/images/diwali/home_quick_diwali_bg.jpg',
    accent: Color(0xFF138A4A),
    accentDark: Color(0xFF0B6B38),
    accentSoft: Color(0xFFE6F6EC),
    tabIcon: Icons.bolt_rounded,
    sparkle: Color(0xFFFFF3B0),
  );

  static const services = HomeModeTheme(
    backgroundAsset: 'assets/images/diwali/home_services_diwali_bg.jpg',
    accent: Color(0xFF6A1FD0),
    accentDark: Color(0xFF4F13A8),
    accentSoft: Color(0xFFF1E8FF),
    tabIcon: Icons.home_repair_service_rounded,
    sparkle: Color(0xFFFFD6F0),
  );

  static HomeModeTheme of(DeliveryType type) {
    switch (type) {
      case DeliveryType.standard:
        return standard;
      case DeliveryType.quick:
        return quick;
      case DeliveryType.services:
        return services;
    }
  }
}
