/// A calendar event. [ownerUid] null = shared (anyone in the union edits it);
/// set = that member's own event (everyone sees it, only they edit it).
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startAt,
    this.endAt,
    this.allDay = false,
    this.ownerUid,
    this.reminders = const [],
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final bool allDay;
  final String? ownerUid;

  /// Minutes before [startAt]. Each phone schedules its own local alerts (see planReminders).
  final List<int> reminders;

  bool get shared => ownerUid == null;
  bool canEdit(String uid) => ownerUid == null || ownerUid == uid;

  factory CalendarEvent.fromRow(Map<String, dynamic> r) => CalendarEvent(
        id: r['id'] as String,
        title: r['title'] as String,
        startAt: DateTime.parse(r['start_at'] as String).toLocal(),
        endAt: r['end_at'] == null ? null : DateTime.parse(r['end_at'] as String).toLocal(),
        allDay: r['all_day'] == true,
        ownerUid: r['owner_uid'] as String?,
        reminders: [for (final m in (r['reminders'] as List?) ?? const []) (m as num).toInt()],
      );

  Map<String, dynamic> toRow(String unionId) => {
        'union_id': unionId,
        'title': title,
        'start_at': startAt.toUtc().toIso8601String(),
        'end_at': endAt?.toUtc().toIso8601String(),
        'all_day': allDay,
        'owner_uid': ownerUid,
        'reminders': reminders,
      };
}

/// Choices offered in the editor, in minutes.
const reminderChoices = [10, 60, 1440];

enum NudgeKind { flag, presence }

class Nudge {
  const Nudge({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.kind,
    required this.at,
    this.text,
    this.readAt,
  });

  final String id;
  final String fromUid;
  final String toUid;
  final NudgeKind kind;
  final String? text;
  final DateTime at;
  final DateTime? readAt;

  factory Nudge.fromRow(Map<String, dynamic> r) => Nudge(
        id: r['id'] as String,
        fromUid: r['from_uid'] as String,
        toUid: r['to_uid'] as String,
        kind: r['kind'] == 'presence' ? NudgeKind.presence : NudgeKind.flag,
        text: r['text'] as String?,
        at: DateTime.parse(r['at'] as String).toLocal(),
        readAt: r['read_at'] == null ? null : DateTime.parse(r['read_at'] as String).toLocal(),
      );
}

/// Outcome of send_nudge, matching its `status`.
enum NudgeResult { ok, notAccepting, rateLimited, notEntitled, notMember, invalid }

NudgeResult nudgeResultOf(Object? status) => switch (status) {
      'ok' => NudgeResult.ok,
      'not_accepting' => NudgeResult.notAccepting,
      'rate_limited' => NudgeResult.rateLimited,
      'not_entitled' => NudgeResult.notEntitled,
      'not_member' => NudgeResult.notMember,
      _ => NudgeResult.invalid,
    };

/// Groups events by local start day, in order.
Map<DateTime, List<CalendarEvent>> byDay(Iterable<CalendarEvent> events) {
  final sorted = events.toList()..sort((a, b) => a.startAt.compareTo(b.startAt));
  final out = <DateTime, List<CalendarEvent>>{};
  for (final e in sorted) {
    final d = DateTime(e.startAt.year, e.startAt.month, e.startAt.day);
    (out[d] ??= []).add(e);
  }
  return out;
}

/// One phone alert to schedule for a calendar reminder.
class PlannedReminder {
  const PlannedReminder({required this.event, required this.minutesBefore, required this.at});
  final CalendarEvent event;
  final int minutesBefore;
  final DateTime at;
}

/// Which alerts this phone should have scheduled right now. Shared events alert everyone in
/// the union; a member's own event alerts only its owner. All-day events count from 09:00.
/// Only alerts after [now] and within [horizon] are kept, soonest first, at most [max]
/// (Android caps how many alarms one app may hold).
List<PlannedReminder> planReminders(
  Iterable<CalendarEvent> events,
  String uid,
  DateTime now, {
  Duration horizon = const Duration(days: 30),
  int max = 50,
}) {
  final out = <PlannedReminder>[];
  final until = now.add(horizon);
  for (final e in events) {
    if (!e.shared && e.ownerUid != uid) continue;
    final start = e.allDay ? DateTime(e.startAt.year, e.startAt.month, e.startAt.day, 9) : e.startAt;
    for (final m in e.reminders.toSet()) {
      final at = start.subtract(Duration(minutes: m));
      if (at.isAfter(now) && at.isBefore(until)) {
        out.add(PlannedReminder(event: e, minutesBefore: m, at: at));
      }
    }
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out.length > max ? out.sublist(0, max) : out;
}
