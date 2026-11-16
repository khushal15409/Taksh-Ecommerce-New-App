import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksh_e_commerce/features/app_update/data/app_update_info.dart';
import 'package:taksh_e_commerce/features/app_update/data/app_update_service.dart';
import 'package:taksh_e_commerce/features/app_update/presentation/cubit/app_update_cubit.dart';

class _FakeService implements AppUpdateService {
  _FakeService(this.answers);

  /// One answer per fetch(); the last one repeats.
  final List<AppUpdateInfo?> answers;
  int fetches = 0;
  int updates = 0;

  @override
  Future<AppUpdateInfo?> fetch() async {
    final i = fetches < answers.length ? fetches : answers.length - 1;
    fetches++;
    return answers[i];
  }

  @override
  Future<void> startUpdate(AppUpdateInfo info) async => updates++;
}

AppUpdateInfo _info(String type, {int build = 20}) => AppUpdateInfo(
      updateAvailable: type != 'none',
      updateRequired: type == 'force',
      updateType: type,
      latestVersion: '2.0.0',
      latestBuildNumber: build,
      title: 't',
      message: 'm',
      buttonText: 'Update Now',
      storeUrl: 'https://play.google.com/store/apps/details?id=in.example.app',
    );

void main() {
  group('AppUpdateInfo.tryParse', () {
    test('reads a full answer', () {
      final info = AppUpdateInfo.tryParse({
        'update_available': true,
        'update_required': true,
        'update_type': 'force',
        'latest_version': '2.0.0',
        'latest_build_number': 20,
        'title': 'Update Required',
        'message': 'Please update',
        'button_text': 'Update Now',
        'store_url': 'https://play.google.com/store/apps/details?id=a.b',
      })!;
      expect(info.isForce, isTrue);
      expect(info.isOptional, isFalse);
      expect(info.latestBuildNumber, 20);
    });

    test('missing or odd fields mean no update, never an exception', () {
      final info = AppUpdateInfo.tryParse({'update_available': 'yes', 'latest_build_number': 'x'})!;
      expect(info.isForce, isFalse);
      expect(info.isOptional, isFalse);
      expect(info.title, isNotEmpty);
      expect(info.storeUrl, isNull);
    });

    test('a force flag without a force type is not forced', () {
      final info = AppUpdateInfo.tryParse({'update_available': true, 'update_required': true, 'update_type': 'optional'})!;
      expect(info.isForce, isFalse);
    });
  });

  group('AppUpdateCubit', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<AppUpdateCubit> cubit(_FakeService service) async =>
        AppUpdateCubit(service, await SharedPreferences.getInstance());

    test('no update: stays quiet', () async {
      final c = await cubit(_FakeService([_info('none')]));
      await c.checkOnce();
      expect(c.state.prompt, AppUpdatePrompt.none);
    });

    test('a failed check never blocks or prompts', () async {
      final c = await cubit(_FakeService([null]));
      await c.checkOnce();
      expect(c.state.prompt, AppUpdatePrompt.none);
    });

    test('checks once per session', () async {
      final service = _FakeService([_info('optional')]);
      final c = await cubit(service);
      await c.checkOnce();
      await c.checkOnce();
      expect(service.fetches, 1);
    });

    test('optional: Later hides it and it is not asked again at once', () async {
      final c = await cubit(_FakeService([_info('optional')]));
      await c.checkOnce();
      expect(c.state.prompt, AppUpdatePrompt.optional);

      await c.later();
      expect(c.state.prompt, AppUpdatePrompt.none);

      final next = AppUpdateCubit(_FakeService([_info('optional')]), await SharedPreferences.getInstance());
      await next.checkOnce();
      expect(next.state.prompt, AppUpdatePrompt.none);
    });

    test('force cannot be skipped with Later', () async {
      final c = await cubit(_FakeService([_info('force')]));
      await c.checkOnce();
      await c.later();
      expect(c.state.prompt, AppUpdatePrompt.force);
    });

    test('force stays when the recheck cannot reach the server', () async {
      final c = await cubit(_FakeService([_info('force'), null]));
      await c.checkOnce();
      await c.recheckIfForced();
      expect(c.state.prompt, AppUpdatePrompt.force);
    });

    test('force lifts once the server says the build is current', () async {
      final c = await cubit(_FakeService([_info('force'), _info('none')]));
      await c.checkOnce();
      await c.recheckIfForced();
      expect(c.state.prompt, AppUpdatePrompt.none);
    });

    test('update now starts the update', () async {
      final service = _FakeService([_info('force')]);
      final c = await cubit(service);
      await c.checkOnce();
      await c.update();
      expect(service.updates, 1);
      expect(c.state.prompt, AppUpdatePrompt.force);
      expect(c.state.updating, isFalse);
    });
  });
}
