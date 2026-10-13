import 'package:json_annotation/json_annotation.dart';
import 'package:taksh_e_commerce/core/utils/typedef.dart';
import 'package:taksh_e_commerce/features/home/domain/entities/banner_entity.dart';

part 'banner_model.g.dart';

/// Model for Banner data from API
@JsonSerializable(fieldRename: FieldRename.snake)
class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.position,
    super.type,
    required super.redirectType,
    super.redirectId,
  });

  // Older API responses have no `type`; default it so parsing never fails.
  factory BannerModel.fromJson(DataMap json) =>
      _$BannerModelFromJson({...json, 'type': json['type'] ?? 'standard'});

  DataMap toJson() => _$BannerModelToJson(this);

  /// Create from entity (for testing/mapping purposes)
  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      title: entity.title,
      imageUrl: entity.imageUrl,
      position: entity.position,
      type: entity.type,
      redirectType: entity.redirectType,
      redirectId: entity.redirectId,
    );
  }
}
