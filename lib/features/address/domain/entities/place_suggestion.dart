import 'package:equatable/equatable.dart';

/// One type-ahead suggestion ("Alpha One Mall" / "Vastrapur, Ahmedabad, Gujarat").
/// It has no coordinates yet: they come from the place details when it is picked.
class PlaceSuggestion extends Equatable {
  final String placeId;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    this.secondaryText = '',
  });

  @override
  List<Object?> get props => [placeId, mainText, secondaryText];
}
