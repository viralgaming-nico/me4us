import 'dart:async';

import 'package:feat_couple/feat_couple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:me4us/l10n/app_localizations.dart';
import 'package:me4us/reminders.dart';

class RecordingScheduler implements ReminderScheduler {
  final calls = <List<ReminderAlert>>[];
  @override
  Future<void> replaceAll(List<ReminderAlert> alerts) async => calls.add(alerts);
}

/// Entitlement and events are pushed by the test, like Realtime would.
class LiveCouple implements CoupleRepository {
  final entitled = StreamController<bool>.broadcast();
  final events = StreamController<List<CalendarEvent>>.broadcast();

  @override
  Stream<bool> watchEntitled(String unionId) => entitled.stream;
  @override
  Stream<List<CalendarEvent>> watchEvents(String unionId) => events.stream;
  @override
  Future<void> saveEvent(String unionId, CalendarEvent event) async {}
  @override
  Future<void> deleteEvent(String eventId) async {}
  @override
  Stream<List<Nudge>> watchNudges(String uid) => const Stream.empty();
  @override
  Future<NudgeResult> sendNudge(String toUid, NudgeKind kind, {String? text}) async => NudgeResult.ok;
  @override
  Future<void> markRead(String nudgeId) async {}
}

final now = DateTime(2026, 11, 21, 9);

Future<void> pumpSync(WidgetTester t, LiveCouple couple, RecordingScheduler s, {Locale? locale}) async {
  await t.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ReminderSync(
      couple: couple,
      unionId: 'u',
      uid: 'a',
      scheduler: s,
      clock: () => now,
      child: const SizedBox(),
    ),
  ));
  await t.pump();
}

void main() {
  testWidgets('every calendar change from any member reschedules this phone', (t) async {
    final couple = LiveCouple();
    final s = RecordingScheduler();
    await pumpSync(t, couple, s);
    couple.entitled.add(true);
    await t.pump();

    couple.events.add([
      CalendarEvent(id: '1', title: 'Dinner', startAt: DateTime(2026, 11, 21, 20), reminders: const [60]),
    ]);
    await t.pump();
    expect(s.calls.last.single.title, 'Dinner');
    expect(s.calls.last.single.at, DateTime(2026, 11, 21, 19));
    expect(s.calls.last.single.body, 'Starts in 1 hour');

    // Partner adds an event: it arrives through Realtime and joins the schedule.
    couple.events.add([
      CalendarEvent(id: '1', title: 'Dinner', startAt: DateTime(2026, 11, 21, 20), reminders: const [60]),
      CalendarEvent(id: '2', title: 'Movie', startAt: DateTime(2026, 11, 21, 22), reminders: const [10]),
      CalendarEvent(id: '3', title: 'Their gym', startAt: DateTime(2026, 11, 21, 18), ownerUid: 'b', reminders: const [10]),
    ]);
    await t.pump();
    expect(s.calls.last.map((a) => a.title), ['Dinner', 'Movie']);
    expect(s.calls.last.last.body, 'Starts in 10 min');
  });

  testWidgets('a locked union clears every alert', (t) async {
    final couple = LiveCouple();
    final s = RecordingScheduler();
    await pumpSync(t, couple, s);
    couple.entitled.add(false);
    await t.pump();
    expect(s.calls.single, isEmpty);
  });

  testWidgets('alert text follows the phone language', (t) async {
    final couple = LiveCouple();
    final s = RecordingScheduler();
    await pumpSync(t, couple, s, locale: const Locale('es'));
    couple.entitled.add(true);
    await t.pump();
    couple.events.add([
      CalendarEvent(id: '1', title: 'Cena', startAt: DateTime(2026, 11, 22, 20), reminders: const [1440]),
    ]);
    await t.pump();
    expect(s.calls.last.single.body, 'Empieza en 1 día');
  });
}
