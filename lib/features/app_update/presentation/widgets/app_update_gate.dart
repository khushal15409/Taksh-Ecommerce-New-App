import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/core/routing/app_router.dart';
import 'package:taksh_e_commerce/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:taksh_e_commerce/features/app_update/presentation/widgets/force_update_screen.dart';
import 'package:taksh_e_commerce/features/app_update/presentation/widgets/optional_update_sheet.dart';

/// Wraps the whole app (MaterialApp.router `builder`). Normally it is just the
/// app. When an update is forced it covers everything with the update screen
/// and swallows the system back button; when one is optional it opens the
/// bottom sheet once.
class AppUpdateGate extends StatefulWidget {
  final Widget? child;

  const AppUpdateGate({super.key, required this.child});

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate>
    with WidgetsBindingObserver {
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back must not leave a forced update.
  @override
  Future<bool> didPopRoute() async {
    final cubit = context.read<AppUpdateCubit>();
    return cubit.state.prompt == AppUpdatePrompt.force;
  }

  /// Back from the Play Store: lift the screen if the update was done.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AppUpdateCubit>().recheckIfForced();
    }
  }

  Future<void> _showOptional({int attempt = 0}) async {
    if (_sheetOpen) return;

    final navigator = getIt<AppRouter>()
        .router
        .routerDelegate
        .navigatorKey
        .currentState
        ?.overlay
        ?.context;

    if (navigator == null || !navigator.mounted) {
      // The app is still setting up its navigator: try again shortly.
      if (attempt < 10 && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (mounted) await _showOptional(attempt: attempt + 1);
      }
      return;
    }

    final cubit = context.read<AppUpdateCubit>();
    final info = cubit.state.info;
    if (info == null) return;

    _sheetOpen = true;
    final update = await showModalBottomSheet<bool>(
      context: navigator,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => OptionalUpdateSheet(info: info),
    );
    _sheetOpen = false;

    if (update == true) {
      await cubit.update();
      cubit.later(); // do not ask again straight away
    } else {
      await cubit.later();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppUpdateCubit, AppUpdateState>(
      listenWhen: (previous, current) =>
          previous.prompt != current.prompt &&
          current.prompt == AppUpdatePrompt.optional,
      listener: (context, state) => _showOptional(),
      builder: (context, state) {
        final info = state.info;

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child ?? const SizedBox.shrink(),
            if (state.prompt == AppUpdatePrompt.force && info != null)
              Positioned.fill(
                child: ForceUpdateScreen(
                  info: info,
                  updating: state.updating,
                  onUpdate: () => context.read<AppUpdateCubit>().update(),
                ),
              ),
          ],
        );
      },
    );
  }
}
