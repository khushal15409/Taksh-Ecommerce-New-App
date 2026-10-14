import 'package:equatable/equatable.dart';

/// Dashboard section entity representing a section in the dashboard
/// Sections can contain banners, products, or other data types
class DashboardSectionEntity extends Equatable {
  final String key;
  final List<dynamic> data;
  final String? message;

  /// Admin-configured layout. [design] is a template key (premium, hot_deals,
  /// fresh_picks, spotlight, minimal); null = the normal product row.
  /// [rows] x [itemsPerRow] is the size of the templated block.
  final int? id;
  final String? design;
  final int? rows;
  final int? itemsPerRow;

  const DashboardSectionEntity({
    required this.key,
    required this.data,
    this.message,
    this.id,
    this.design,
    this.rows,
    this.itemsPerRow,
  });

  /// Check if section has data
  bool get hasData => data.isNotEmpty;

  /// Check if section is empty with a message
  bool get isEmpty => data.isEmpty && message != null;

  @override
  List<Object?> get props => [key, data, message, id, design, rows, itemsPerRow];
}
