import 'dart:async';

import 'package:feat_couple/feat_couple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in that enforces the same rules as the database.
class FakeCouple implements CoupleRepository {
  FakeCouple({this.entitled = true, this.accepting = const {'b'}});

  bool entitled;
  Set<String> accepting;
  final events = <CalendarEvent>[];
  final nudges = <Nudge>[];
  final _changes = StreamController<void>.broadcast();
  var _next = 0;
  final String me = 'a';

  Stream<T> _live<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  @override
  Stream<bool> watchEntitled(String unionId) => _live(() => entitled);

  @override
  Stream<List<CalendarEvent>> watchEvents(String unionId) => _live(() => List.of(events));

  @override
  Future<void> saveEvent(String unionId, CalendarEvent e) async {
    if (e.id.isEmpty) {
      events.add(CalendarEvent(
        id: 'e${_next++}',
        title: e.title,
        startAt: e.startAt,
        endAt: e.endAt,
        allDay: e.allDay,
        ownerUid: e.ownerUid,
        reminders: e.reminders,
      ));
    } else {
      events[events.indexWhere((x) => x.id == e.id)] = e;
    }
    _changes.add(null);
  }

  @override
  Future<void> deleteEvent(String id) async {
    events.removeWhere((e) => e.id == id);
    _changes.add(null);
  }

  @override
  Stream<List<Nudge>> watchNudges(String uid) => _live(() => List.of(nudges));

  @override
  Future<NudgeResult> sendNudge(String to, NudgeKind kind, {String? text}) async {
    if (!entitled) return NudgeResult.notEntitled;
    if (!accepting.contains(to)) return NudgeResult.notAccepting;
    if (nudges.where((n) => n.fromUid == me).length >= 3) return NudgeResult.rateLimited;
    nudges.add(Nudge(
      id: 'n${_next++}',
      fromUid: me,
      toUid: to,
      kind: kind,
      text: kind == NudgeKind.presence ? null : text,
      at: DateTime(2026, 11, 21),
    ));
    _changes.add(null);
    return NudgeResult.ok;
  }

  @override
  Future<void> markRead(String id) async {}
}

final now = DateTime(2026, 11, 21, 9);

Future<void> pump(WidgetTester t, Widget home, {Locale locale = const Locale('en')}) async {
  await t.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      ...CoupleLocalizations.localizationsDelegates,
      GlobalMaterialLocalizations.delegate,
    ],
    supportedLocales: CoupleLocalizations.supportedLocales,
    home: home,
  ));
  await t.pumpAndSettle();
}

CalendarScreen calendar(FakeCouple repo) =>
    CalendarScreen(repo: repo, unionId: 'u', uid: 'a', clock: () => now);

NudgesScreen nudgesFor(FakeCouple repo, {bool accepting = false, List<bool>? saved}) => NudgesScreen(
      repo: repo,
      unionId: 'u',
      uid: 'a',
      others: const {'b': 'Member 2'},
      accepting: accepting,
      onAcceptChanged: (v) async => saved?.add(v),
    );

void main() {
  test('byDay groups and sorts by local day', () {
    final g = byDay([
      CalendarEvent(id: '2', title: 'late', startAt: DateTime(2026, 11, 22, 20)),
      CalendarEvent(id: '1', title: 'early', startAt: DateTime(2026, 11, 22, 8)),
      CalendarEvent(id: '0', title: 'today', startAt: DateTime(2026, 11, 21, 12)),
    ]);
    expect(g.keys, [DateTime(2026, 11, 21), DateTime(2026, 11, 22)]);
    expect(g[DateTime(2026, 11, 22)]!.map((e) => e.title), ['early', 'late']);
  });

  test('event row round trip keeps owner, reminders and times', () {
    final e = CalendarEvent(id: 'x', title: 't', startAt: DateTime(2026, 11, 21, 10), ownerUid: 'a', reminders: const [10, 60]);
    final back = CalendarEvent.fromRow({...e.toRow('u'), 'id': 'x'});
    expect(back.startAt, e.startAt);
    expect(back.ownerUid, 'a');
    expect(back.reminders, [10, 60]);
    expect(back.canEdit('a'), isTrue);
    expect(back.canEdit('b'), isFalse);
  });

  testWidgets('not entitled: calendar and nudges show the paywall', (t) async {
    final repo = FakeCouple(entitled: false);
    await pump(t, calendar(repo));
    expect(find.byKey(const Key('paywall')), findsOneWidget);
    expect(find.byKey(const Key('add-event')), findsNothing);
    await pump(t, nudgesFor(repo));
    expect(find.byKey(const Key('paywall')), findsOneWidget);
  });

  testWidgets('add a shared event with a reminder; it appears live', (t) async {
    final repo = FakeCouple();
    await pump(t, calendar(repo));
    expect(find.byKey(const Key('no-events')), findsOneWidget);
    await t.tap(find.byKey(const Key('add-event')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('event-title')), 'Dinner');
    await t.tap(find.byKey(const Key('reminder-60')));
    await t.pump();
    await t.scrollUntilVisible(find.byKey(const Key('event-save')), 200, scrollable: find.byType(Scrollable).last);
    await t.tap(find.byKey(const Key('event-save')));
    await t.pumpAndSettle();
    final e = repo.events.single;
    expect(e.title, 'Dinner');
    expect(e.shared, isTrue);
    expect(e.reminders, [60]);
    expect(e.startAt, DateTime(2026, 11, 21, 10)); // next full hour
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets("a partner's own event is shown but not editable; past events hidden", (t) async {
    final repo = FakeCouple()
      ..events.addAll([
        CalendarEvent(id: 'p', title: 'Their dentist', startAt: DateTime(2026, 11, 22, 15), ownerUid: 'b'),
        CalendarEvent(id: 'm', title: 'My yoga', startAt: DateTime(2026, 11, 23, 7), ownerUid: 'a'),
        CalendarEvent(id: 'old', title: 'Last week', startAt: DateTime(2026, 11, 14, 7)),
      ]);
    await pump(t, calendar(repo));
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('Last week'), findsNothing);
    expect(t.widget<ListTile>(find.byKey(const Key('event-p'))).onTap, isNull);
    expect(t.widget<ListTile>(find.byKey(const Key('event-m'))).onTap, isNotNull);
  });

  testWidgets('edit then delete an event', (t) async {
    final repo = FakeCouple()..events.add(CalendarEvent(id: 's', title: 'Movie', startAt: DateTime(2026, 11, 21, 20)));
    await pump(t, calendar(repo));
    await t.tap(find.byKey(const Key('event-s')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('event-title')), 'Movie night');
    await t.scrollUntilVisible(find.byKey(const Key('event-save')), 200, scrollable: find.byType(Scrollable).last);
    await t.tap(find.byKey(const Key('event-save')));
    await t.pumpAndSettle();
    expect(repo.events.single.title, 'Movie night');
    await t.tap(find.byKey(const Key('event-s')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('delete-event')));
    await t.pumpAndSettle();
    expect(repo.events, isEmpty);
    expect(find.byKey(const Key('no-events')), findsOneWidget);
  });

  testWidgets('nudges: send, presence has no text, 4th is rate limited', (t) async {
    final repo = FakeCouple();
    await pump(t, nudgesFor(repo));
    await t.enterText(find.byKey(const Key('nudge-text')), 'hug?');
    await t.tap(find.byKey(const Key('send-nudge')));
    await t.pumpAndSettle();
    expect(find.text('Sent.'), findsOneWidget);
    expect(repo.nudges.single.text, 'hug?');

    await t.tap(find.text('Be present'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('nudge-text')), findsNothing);
    await t.tap(find.byKey(const Key('send-nudge')));
    await t.pumpAndSettle();
    expect(repo.nudges.last.kind, NudgeKind.presence);
    expect(repo.nudges.last.text, isNull);

    await t.tap(find.byKey(const Key('send-nudge')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('send-nudge')));
    await t.pumpAndSettle();
    expect(find.textContaining('3 nudges'), findsOneWidget);
    expect(repo.nudges.length, 3);
  });

  testWidgets('nudges: recipient not opted in; my own opt-in switch saves', (t) async {
    final repo = FakeCouple(accepting: {});
    final saved = <bool>[];
    await pump(t, nudgesFor(repo, saved: saved));
    await t.tap(find.byKey(const Key('send-nudge')));
    await t.pumpAndSettle();
    expect(find.text("They haven't turned on nudges."), findsOneWidget);
    await t.tap(find.byKey(const Key('accept-nudges')));
    await t.pumpAndSettle();
    expect(saved, [true]);
  });

  testWidgets('received presence nudge never shows a reason', (t) async {
    final repo = FakeCouple()
      ..nudges.add(Nudge(id: 'r', fromUid: 'b', toUid: 'a', kind: NudgeKind.presence, at: DateTime(2026, 11, 21)));
    await pump(t, nudgesFor(repo));
    await t.scrollUntilVisible(find.byKey(const Key('nudge-r')), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Go be present for a moment.'), findsOneWidget);
  });

  testWidgets('Spanish labels', (t) async {
    await pump(t, calendar(FakeCouple()), locale: const Locale('es'));
    expect(find.text('Nuestro calendario'), findsOneWidget);
    expect(find.text('Agregar evento'), findsOneWidget);
  });
}
