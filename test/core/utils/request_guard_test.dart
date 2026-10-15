import 'package:flutter_test/flutter_test.dart';
import 'package:taksh_e_commerce/core/utils/request_guard.dart';

void main() {
  test('only the latest request token is current', () {
    final guard = RequestGuard();
    final first = guard.begin('a');
    final second = guard.begin('b');
    expect(guard.isCurrent(first), isFalse);
    expect(guard.isCurrent(second), isTrue);
    expect(guard.currentKey, 'b');
  });

  test('invalidate drops the in-flight request', () {
    final guard = RequestGuard();
    final token = guard.begin('a');
    guard.invalidate();
    expect(guard.isCurrent(token), isFalse);
  });

  test('query key ignores the page, listing key includes it', () {
    final q1 = RequestGuard.queryKey(
      categoryId: 5,
      latitude: 23.0225,
      longitude: 72.5714,
    );
    final q2 = RequestGuard.queryKey(
      categoryId: 6,
      latitude: 23.0225,
      longitude: 72.5714,
    );
    final q3 = RequestGuard.queryKey(
      categoryId: 5,
      latitude: 23.5,
      longitude: 72.5714,
    );
    expect(q1, isNot(q2));
    expect(q1, isNot(q3));

    final p1 = RequestGuard.listingKey(
      categoryId: 5,
      page: 1,
      latitude: 23.0225,
      longitude: 72.5714,
    );
    final p2 = RequestGuard.listingKey(
      categoryId: 5,
      page: 2,
      latitude: 23.0225,
      longitude: 72.5714,
    );
    expect(p1, isNot(p2));
    expect(p1.startsWith(q1), isTrue);
  });
}
