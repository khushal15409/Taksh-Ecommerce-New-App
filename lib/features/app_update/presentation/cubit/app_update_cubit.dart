import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksh_e_commerce/features/app_update/data/app_update_info.dart';
import 'package:taksh_e_commerce/features/app_update/data/app_update_service.dart';

enum AppUpdatePrompt { none, optional, force }

class AppUpdateState extends Equatable {
  final AppUpdatePrompt prompt;
  final AppUpdateInfo? info;
  final bool updating;

  const AppUpdateState({
    this.prompt = AppUpdatePrompt.none,
    this.info,
    this.updating = false,
  });

  @override
  List<Object?> get props =>
      [prompt, info?.latestBuildNumber, info?.updateType, updating];
}

/// Decides when the update prompt shows. One check per app session; the only
/// repeat is when the app comes back to the front while an update is forced,
/// so the screen lifts once the person has updated. A failed check changes
/// nothing: it never blocks the app, and never lifts a forced update.
class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit(this._service, this._prefs) : super(const AppUpdateState());

  final AppUpdateService _service;
  final SharedPreferences? _prefs;

  bool _checked = false;
  bool _checking = false;

  /// How long "Later" is respected for the same update.
  static const Duration _laterFor = Duration(hours: 24);

  String _laterKey(int build) => 'app_update_later_$build';

  /// Called once the splash is done. Safe to call again; it only runs once.
  Future<void> checkOnce() async {
    if (_checked || _checking) return;
    _checking = true;
    try {
      final info = await _service.fetch();
      _checked = true;
      if (info == null) return;

      if (info.isForce) {
        emit(AppUpdateState(prompt: AppUpdatePrompt.force, info: info));
      } else if (info.isOptional && !_snoozed(info)) {
        emit(AppUpdateState(prompt: AppUpdatePrompt.optional, info: info));
      }
    } catch (_) {
      // never block the app
    } finally {
      _checking = false;
    }
  }

  /// The app came back to the front. Only matters while an update is forced.
  Future<void> recheckIfForced() async {
    if (state.prompt != AppUpdatePrompt.force || _checking) return;
    _checking = true;
    try {
      final info = await _service.fetch();
      // No answer (offline) keeps the restriction in place.
      if (info != null && !info.isForce) {
        emit(const AppUpdateState());
      } else if (info != null) {
        emit(AppUpdateState(prompt: AppUpdatePrompt.force, info: info));
      }
    } catch (_) {
      // keep the restriction
    } finally {
      _checking = false;
    }
  }

  /// "Update now".
  Future<void> update() async {
    final info = state.info;
    if (info == null || state.updating) return;

    emit(AppUpdateState(prompt: state.prompt, info: info, updating: true));
    try {
      await _service.startUpdate(info);
    } catch (_) {
      // the screen simply stays
    } finally {
      if (!isClosed) {
        emit(AppUpdateState(prompt: state.prompt, info: info));
      }
    }
  }

  /// "Later" on an optional update: not asked again for a day.
  Future<void> later() async {
    final info = state.info;
    if (state.prompt == AppUpdatePrompt.force) return; // cannot be skipped

    if (info != null) {
      try {
        await _prefs?.setInt(
            _laterKey(info.latestBuildNumber), DateTime.now().millisecondsSinceEpoch);
      } catch (_) {}
    }
    emit(const AppUpdateState());
  }

  bool _snoozed(AppUpdateInfo info) {
    try {
      final at = _prefs?.getInt(_laterKey(info.latestBuildNumber));
      if (at == null) return false;
      return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(at)) <
          _laterFor;
    } catch (_) {
      return false;
    }
  }
}
