import 'package:core_points/core_points.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 21, 15);

  test('dayKey pads and round-trips', () {
    expect(dayKey(DateTime(2026, 3, 4, 23, 59)), '2026-03-04');
    expect(parseDayKey('2026-03-04'), DateTime(2026, 3, 4));
  });

  test('summary: total, today and last 7 days', () {
    final s = PointsSummary.from(const [
      PointTick(day: '2026-11-21', points: 2),
      PointTick(day: '2026-11-21', points: 1),
      PointTick(day: '2026-11-15', points: 3), // 6 days ago: inside the week
      PointTick(day: '2026-11-14', points: 5), // 7 days ago: outside
      PointTick(day: '2026-11-20', points: 4, done: false), // unticked
    ], now);
    expect(s.total, 11);
    expect(s.today, 3);
    expect(s.last7Days, 6);
  });

  test('week window crosses a month boundary', () {
    final s = PointsSummary.from(const [PointTick(day: '2026-11-28', points: 1)], DateTime(2026, 12, 2));
    expect(s.last7Days, 1);
  });

  test('empty is zero', () {
    final s = PointsSummary.from(const [], now);
    expect([s.total, s.today, s.last7Days], [0, 0, 0]);
  });

  test('daysBetween counts calendar days', () {
    expect(daysBetween(DateTime(2026, 10, 31, 23), DateTime(2026, 11, 1, 1)), 1);
    expect(daysBetween(now, now), 0);
  });
}
