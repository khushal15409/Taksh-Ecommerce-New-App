import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/routing/app_routes.dart';
import 'package:taksh_e_commerce/core/theme/app_colors.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taksh_e_commerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:taksh_e_commerce/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:taksh_e_commerce/features/wishlist/presentation/cubit/wishlist_state.dart';

/// Heart toggle backed by the existing [WishlistCubit]. Guests are sent to
/// login. The icon pops when toggled.
class WishlistHeartButton extends StatelessWidget {
  final int productId;
  final double size;

  const WishlistHeartButton({
    super.key,
    required this.productId,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<WishlistCubit>();
    return BlocBuilder<WishlistCubit, WishlistState>(
      bloc: cubit,
      builder: (context, state) {
        final wishlisted = cubit.isWishlisted(productId);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (context.read<AuthBloc>().state is! Authenticated) {
              context.push(
                '${AppRoutes.login}?redirectAfter=${Uri.encodeComponent(AppRoutes.home)}',
              );
              return;
            }
            cubit.toggleWishlist(productId: productId);
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedSwitcher(
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
                child: child,
              ),
              child: Icon(
                wishlisted
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(wishlisted),
                size: size,
                color: wishlisted ? Colors.red : AppColors.grey600,
              ),
            ),
          ),
        );
      },
    );
  }
}
