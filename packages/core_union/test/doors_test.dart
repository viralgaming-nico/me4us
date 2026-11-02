import 'package:core_union/core_union.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const none = Doors.closed;
  final alc = none.set(Door.alcohol, true);
  final alcLite = alc.set(Door.lite, true);

  test('everything starts closed', () {
    for (final d in Door.values) {
      expect(none.isOpen(d), isFalse);
    }
  });

  test('effective door needs ALL members opted in', () {
    final e = Doors.effective([alcLite, alc]);
    expect(e.isOpen(Door.alcohol), isTrue);
    expect(e.isOpen(Door.lite), isFalse);
  });

  test('one vanilla member closes every door', () {
    expect(Doors.effective([alcLite, alcLite, none]), Doors.closed);
  });

  test('no members means nothing is shown', () {
    expect(Doors.effective([]), Doors.closed);
  });

  test('single member keeps own doors', () {
    expect(Doors.effective([alcLite]), alcLite);
  });

  test('map round trip; missing or non-true values stay closed', () {
    expect(Doors.fromMap(alcLite.toMap()), alcLite);
    expect(Doors.fromMap(null), Doors.closed);
    expect(Doors.fromMap({'alcohol': 'yes', 'lite': 1}), Doors.closed);
  });

  test('Member.fromRow tolerates a bare row', () {
    final m = Member.fromRow({'user_id': 'u', 'role': 'owner'});
    expect(m.myDoors, Doors.closed);
    expect(m.acceptsFlags, isFalse);
    expect(m.points, 0);
  });

  test('Member.fromRow reads snake_case columns', () {
    final m = Member.fromRow({
      'user_id': 'u',
      'role': 'member',
      'my_doors': {'alcohol': true, 'lite': true},
      'accepts_flags': true,
      'points': 7,
    });
    expect(m.myDoors, alcLite);
    expect(m.acceptsFlags, isTrue);
    expect(m.hygieneAlerts, isFalse);
    expect(m.points, 7);
  });
}
