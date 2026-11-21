/// One earned (or un-earned) tick. [day] is a local calendar day key, `yyyy-mm-dd`.
class PointTick {
  const PointTick({required this.day, required this.points, this.done = true});
  final String day;
  final int points;
  final bool done;
}

/// Summary of a person's own points. Me points stay private to their owner:
/// they are never written to the union ledger (partners can read that).
class PointsSummary {
  const PointsSummary({required this.total, required this.today, required this.last7Days});

  final int total;
  final int today;

  /// Today plus the 6 days before it.
  final int last7Days;

  static const zero = PointsSummary(total: 0, today: 0, last7Days: 0);

  factory PointsSummary.from(Iterable<PointTick> ticks, DateTime now) {
    final todayKey = dayKey(now);
    final weekStart = dayKey(DateTime(now.year, now.month, now.day - 6));
    var total = 0, today = 0, week = 0;
    for (final t in ticks) {
      if (!t.done || t.points <= 0) continue;
      total += t.points;
      if (t.day == todayKey) today += t.points;
      // yyyy-mm-dd keys sort as dates.
      if (t.day.compareTo(weekStart) >= 0 && t.day.compareTo(todayKey) <= 0) week += t.points;
    }
    return PointsSummary(total: total, today: today, last7Days: week);
  }
}

/// Local calendar day as `yyyy-mm-dd` (matches a Postgres `date`).
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Parses a `yyyy-mm-dd` key into a local midnight.
DateTime parseDayKey(String k) {
  final p = k.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// Whole calendar days from [from] to [to] (DST-safe).
int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
