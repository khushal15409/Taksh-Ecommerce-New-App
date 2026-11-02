import 'package:equatable/equatable.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/recent_view.dart';

/// Base state for recent views
abstract class RecentViewsState extends Equatable {
  const RecentViewsState();

  @override
  List<Object?> get props => [];
}

class RecentViewsInitial extends RecentViewsState {
  const RecentViewsInitial();
}

class RecentViewsLoading extends RecentViewsState {
  const RecentViewsLoading();
}

class RecentViewsLoaded extends RecentViewsState {
  final List<RecentView> recentViews;

  /// The delivery type these views were loaded for (null = all), so a screen
  /// never shows the other part's list while its own is loading.
  final String? deliveryType;

  const RecentViewsLoaded(this.recentViews, {this.deliveryType});

  @override
  List<Object?> get props => [recentViews, deliveryType];
}

class RecentViewsError extends RecentViewsState {
  final String message;

  const RecentViewsError(this.message);

  @override
  List<Object?> get props => [message];
}
