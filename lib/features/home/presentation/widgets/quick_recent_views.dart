import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/recent_views_cubit.dart';
import 'package:taksh_e_commerce/features/home/presentation/bloc/recent_views_state.dart';
import 'package:taksh_e_commerce/features/home/presentation/widgets/recent_views_section.dart';

/// Recent views for the Quick (30 min) part of the home screen: only products
/// that are offered for Quick delivery are listed here.
class QuickRecentViews extends StatefulWidget {
  const QuickRecentViews({super.key});

  static const String deliveryType = 'express_30';

  @override
  State<QuickRecentViews> createState() => _QuickRecentViewsState();
}

class _QuickRecentViewsState extends State<QuickRecentViews> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<RecentViewsCubit>()
          .loadRecentViews(deliveryType: QuickRecentViews.deliveryType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentViewsCubit, RecentViewsState>(
      builder: (context, state) {
        if (state is RecentViewsLoaded &&
            state.deliveryType == QuickRecentViews.deliveryType &&
            state.recentViews.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RecentViewsSection(
              recentViews: state.recentViews,
              onProductTap: (productId) =>
                  context.push(AppRoutes.productDetails(productId)),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
