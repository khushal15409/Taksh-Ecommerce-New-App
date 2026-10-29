import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taksh_e_commerce/core/di/injector.dart';
import 'package:taksh_e_commerce/features/reviews/domain/entities/review_entities.dart';
import 'package:taksh_e_commerce/features/reviews/domain/repositories/review_repository.dart';
import 'package:taksh_e_commerce/features/reviews/presentation/widgets/review_sheet.dart';

/// Asks the customer, from the bottom of the screen, to rate a product that was
/// delivered to them and that they have not rated yet.
///
/// "Later" (or swiping the sheet away) is remembered for [_snooze], so the same
/// product is not asked for again and again. Never throws: a failed request or a
/// customer with nothing to rate simply shows nothing.
class ReviewPrompt {
  ReviewPrompt._();

  static const String _prefsKey = 'review_prompt_snoozed';
  static const Duration _snooze = Duration(hours: 24);

  static bool _busy = false;

  /// Shows the sheet for the latest delivered, unrated product, if there is one.
  /// Call it only for a signed-in customer, from a screen that is on top.
  static Future<void> maybeShow(BuildContext context) async {
    if (_busy) return;
    _busy = true;
    try {
      final result = await getIt<ReviewRepository>().getPending();
      if (!context.mounted) return;

      final pending = result.fold<List<PendingReviewItem>>((_) => const [], (items) => items);
      if (pending.isEmpty) return;

      final snoozed = await _readSnoozed();
      final next = pending.where((item) => !snoozed.contains(item.productId));
      if (next.isEmpty || !context.mounted) return;

      // Something else (another page, a dialog) may have been opened meanwhile.
      if (ModalRoute.of(context)?.isCurrent == false) return;

      final item = next.first;
      final saved = await ReviewSheet.show(
        context,
        productId: item.productId,
        productName: item.productName,
        imageUrl: item.imageUrl,
      );
      if (!saved) await _snoozeProduct(item.productId);
    } catch (_) {
      // The prompt is a nicety: never let it break the screen it was opened from.
    } finally {
      _busy = false;
    }
  }

  static Future<Set<int>> _readSnoozed() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return <int>{};

      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final cutoff = DateTime.now().subtract(_snooze).millisecondsSinceEpoch;
      return map.entries
          .where((e) => (e.value as num) > cutoff)
          .map((e) => int.parse(e.key))
          .toSet();
    } catch (_) {
      return <int>{};
    }
  }

  static Future<void> _snoozeProduct(int productId) async {
    try {
      final prefs = getIt<SharedPreferences>();
      final raw = prefs.getString(_prefsKey);
      final map = raw == null || raw.isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(raw) as Map);

      final cutoff = DateTime.now().subtract(_snooze).millisecondsSinceEpoch;
      map.removeWhere((_, value) => (value as num) <= cutoff);
      map['$productId'] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(_prefsKey, jsonEncode(map));
    } catch (_) {
      // Not being able to remember only means it may be asked again.
    }
  }
}
