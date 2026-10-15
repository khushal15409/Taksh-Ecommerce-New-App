import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/dashboard_section_entity.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/express_fulfillment_center_entity.dart';

/// Express dashboard entity
class ExpressDashboardEntity extends Equatable {
  final ExpressFulfillmentCenterEntity fulfillmentCenter;
  final List<DashboardSectionEntity> sections;

  /// Server verdict: false when Quick delivery cannot serve the location.
  /// A payload without a `serviceable` key is treated as serviceable.
  final bool serviceable;
  final String? code;
  final String? message;

  const ExpressDashboardEntity({
    required this.fulfillmentCenter,
    required this.sections,
    this.serviceable = true,
    this.code,
    this.message,
  });

  /// Get section by key
  DashboardSectionEntity? getSectionByKey(String key) {
    try {
      return sections.firstWhere((section) => section.key == key);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props =>
      [fulfillmentCenter, sections, serviceable, code, message];
}
