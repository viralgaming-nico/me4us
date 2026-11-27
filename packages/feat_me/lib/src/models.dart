import 'package:core_points/core_points.dart';

enum SelfcareCategory { basic, periodic, meds, nutrition }

/// How often an item comes back. Stored as its name in `selfcare_items.cadence`.
enum Cadence {
  daily(1),
  weekly(7),
  monthly(30);

  const Cadence(this.days);
  final int days;

  static Cadence parse(String? s) =>
      Cadence.values.firstWhere((c) => c.name == s, orElse: () => Cadence.daily);
}

class SelfcareItem {
  const SelfcareItem({
    required this.id,
    required this.title,
    required this.category,
    this.cadence = Cadence.daily,
    this.pointValue = 1,
    this.active = true,
  });

  final String id;
  final String title;
  final SelfcareCategory category;
  final Cadence cadence;
  final int pointValue;
  final bool active;

  factory SelfcareItem.fromRow(Map<String, dynamic> r) => SelfcareItem(
        id: r['id'] as String,
        title: r['title'] as String,
        category: SelfcareCategory.values.firstWhere(
          (c) => c.name == r['category'],
          orElse: () => SelfcareCategory.basic,
        ),
        cadence: Cadence.parse(r['cadence'] as String?),
        pointValue: (r['point_value'] as num?)?.toInt() ?? 0,
        active: r['active'] != false,
      );

  SelfcareItem copyWith({String? title, SelfcareCategory? category, Cadence? cadence, int? pointValue, bool? active}) =>
      SelfcareItem(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        cadence: cadence ?? this.cadence,
        pointValue: pointValue ?? this.pointValue,
        active: active ?? this.active,
      );
}

/// A tick in `selfcare_log`.
class LogEntry {
  const LogEntry({required this.itemId, required this.day, required this.done, required this.points});
  final String itemId;
  final String day;
  final bool done;
  final int points;

  PointTick get tick => PointTick(day: day, points: points, done: done);
}

/// Whether [item] belongs on today's list. Daily items always do; weekly / monthly items
/// come back once their period has passed since the last tick, and stay visible on the
/// day they were ticked so they can be unticked.
bool isDueToday(SelfcareItem item, Iterable<LogEntry> logs, DateTime now) {
  final today = dayKey(now);
  String? last;
  for (final l in logs) {
    if (l.itemId != item.id || !l.done) continue;
    if (last == null || l.day.compareTo(last) > 0) last = l.day;
  }
  if (last == null || last == today || item.cadence == Cadence.daily) return true;
  return daysBetween(parseDayKey(last), now) >= item.cadence.days;
}

/// One answer in a daily check-in. The optional free-text note is stored as its own
/// answer with `qId: 'note'`, matching the `answers[{qId, choiceId, note?}]` shape.
class CheckinAnswer {
  const CheckinAnswer({required this.qId, this.choiceId, this.note});
  final String qId;
  final String? choiceId;
  final String? note;

  Map<String, dynamic> toJson() => {
        'qId': qId,
        'choiceId': ?choiceId,
        'note': ?note,
      };

  factory CheckinAnswer.fromJson(Map<String, dynamic> j) =>
      CheckinAnswer(qId: j['qId'] as String, choiceId: j['choiceId'] as String?, note: j['note'] as String?);
}
