import 'package:feat_me/feat_me.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMe implements MeRepository {
  final items_ = <SelfcareItem>[];
  final logs_ = <LogEntry>[];
  final checkins = <String, List<CheckinAnswer>>{};
  var _next = 0;

  @override
  Future<List<SelfcareItem>> items() async => List.of(items_);

  @override
  Future<void> addItems(List<SelfcareItem> items) async {
    for (final i in items) {
      items_.add(SelfcareItem(
        id: 'i${_next++}',
        title: i.title,
        category: i.category,
        cadence: i.cadence,
        pointValue: i.pointValue,
      ));
    }
  }

  @override
  Future<void> updateItem(SelfcareItem item) async =>
      items_[items_.indexWhere((i) => i.id == item.id)] = item;

  @override
  Future<List<LogEntry>> logs() async => List.of(logs_);

  @override
  Future<void> setDone(SelfcareItem item, String day, bool done) async {
    logs_.removeWhere((l) => l.itemId == item.id && l.day == day);
    logs_.add(LogEntry(itemId: item.id, day: day, done: done, points: done ? item.pointValue : 0));
  }

  @override
  Future<List<CheckinAnswer>?> checkin(String day) async => checkins[day];

  @override
  Future<void> saveCheckin(String day, List<CheckinAnswer> answers) async => checkins[day] = answers;
}

final now = DateTime(2026, 11, 21, 9);

Future<void> pumpMe(WidgetTester t, FakeMe repo, {Locale locale = const Locale('en')}) async {
  await t.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: MeLocalizations.localizationsDelegates,
    supportedLocales: MeLocalizations.supportedLocales,
    home: MeScreen(repo: repo, clock: () => now),
  ));
  await t.pumpAndSettle();
}

SelfcareItem item(String id, {Cadence cadence = Cadence.daily, int points = 1}) =>
    SelfcareItem(id: id, title: id, category: SelfcareCategory.basic, cadence: cadence, pointValue: points);

void main() {
  group('isDueToday', () {
    test('daily items are always due', () {
      expect(isDueToday(item('a'), [const LogEntry(itemId: 'a', day: '2026-11-20', done: true, points: 1)], now), isTrue);
    });
    test('weekly item hides until 7 days after the last tick', () {
      final w = item('w', cadence: Cadence.weekly);
      expect(isDueToday(w, const [], now), isTrue);
      expect(isDueToday(w, const [LogEntry(itemId: 'w', day: '2026-11-18', done: true, points: 1)], now), isFalse);
      expect(isDueToday(w, const [LogEntry(itemId: 'w', day: '2026-11-14', done: true, points: 1)], now), isTrue);
    });
    test('ticked today stays visible; unticked ticks are ignored', () {
      final m = item('m', cadence: Cadence.monthly);
      expect(isDueToday(m, const [LogEntry(itemId: 'm', day: '2026-11-21', done: true, points: 1)], now), isTrue);
      expect(isDueToday(m, const [LogEntry(itemId: 'm', day: '2026-11-10', done: false, points: 0)], now), isTrue);
    });
  });

  test('CheckinAnswer JSON leaves out empty fields', () {
    expect(const CheckinAnswer(qId: 'mood', choiceId: 'good').toJson(), {'qId': 'mood', 'choiceId': 'good'});
    expect(const CheckinAnswer(qId: 'note', note: 'hi').toJson(), {'qId': 'note', 'note': 'hi'});
  });

  test('starter content has unique, permanent-style IDs and labels for every choice', () {
    final ids = starterItems.map((s) => s.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(checkinQuestions.map((q) => q.id), ['mood', 'energy', 'stress', 'sleep', 'need']);
  });

  testWidgets('empty list: starter list fills it, no partner nags', (t) async {
    final repo = FakeMe();
    await pumpMe(t, repo);
    expect(find.text('Your self-care list is empty'), findsOneWidget);
    expect(find.textContaining(RegExp('partner|invite', caseSensitive: false)), findsNothing);
    await t.tap(find.text('Use the starter list'));
    await t.pumpAndSettle();
    expect(repo.items_.length, 6);
    expect(find.text('Brush teeth'), findsOneWidget);
    // Monthly haircut is due (never done).
    expect(find.text('Haircut'), findsOneWidget);
  });

  testWidgets('ticking items adds points; unticking removes them', (t) async {
    final repo = FakeMe()..items_.addAll([item('teeth', points: 1), item('meds', points: 2)]);
    await pumpMe(t, repo);
    expect(find.text('0 points'), findsOneWidget);
    await t.tap(find.byKey(const Key('item-meds')));
    await t.pumpAndSettle();
    expect(find.text('2 points'), findsOneWidget);
    expect(find.text('2 today'), findsOneWidget);
    await t.tap(find.byKey(const Key('item-teeth')));
    await t.pumpAndSettle();
    expect(find.text('3 points'), findsOneWidget);
    expect(find.byKey(const Key('me-all-done')), findsOneWidget);
    await t.tap(find.byKey(const Key('item-meds')));
    await t.pumpAndSettle();
    expect(find.text('1 points'), findsOneWidget);
    expect(repo.logs_.where((l) => l.done).length, 1);
  });

  testWidgets('hidden items are not on today\'s list', (t) async {
    final repo = FakeMe()..items_.addAll([item('a'), item('b').copyWith(active: false)]);
    await pumpMe(t, repo);
    expect(find.byKey(const Key('item-a')), findsOneWidget);
    expect(find.byKey(const Key('item-b')), findsNothing);
  });

  testWidgets('daily check-in: pick choices, add a note, saved for today', (t) async {
    final repo = FakeMe()..items_.add(item('a'));
    await pumpMe(t, repo);
    expect(find.text('How are you today?'), findsOneWidget);
    await t.tap(find.text('Check in'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('choice-mood-good')));
    await t.tap(find.byKey(const Key('choice-sleep-poor')));
    await t.pump();
    await t.enterText(find.byKey(const Key('checkin-note')), 'long day');
    await t.scrollUntilVisible(find.text('Save'), 200, scrollable: find.byType(Scrollable).last);
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    final saved = repo.checkins['2026-11-21']!;
    expect(saved.map((a) => a.toJson()), [
      {'qId': 'mood', 'choiceId': 'good'},
      {'qId': 'sleep', 'choiceId': 'poor'},
      {'qId': 'note', 'note': 'long day'},
    ]);
    expect(find.text('Checked in today'), findsOneWidget);
  });

  testWidgets('add your own item', (t) async {
    final repo = FakeMe();
    await pumpMe(t, repo);
    await t.tap(find.text('Add my own'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('add-item')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('item-title')), 'Stretch');
    await t.tap(find.byIcon(Icons.add).last);
    await t.pump();
    expect(find.text('2'), findsOneWidget);
    await t.tap(find.byKey(const Key('item-save')));
    await t.pumpAndSettle();
    expect(repo.items_.single.title, 'Stretch');
    expect(repo.items_.single.pointValue, 2);
  });

  testWidgets('Spanish labels', (t) async {
    await pumpMe(t, FakeMe(), locale: const Locale('es'));
    expect(find.text('Usar la lista inicial'), findsOneWidget);
    expect(find.text('Registro diario'), findsOneWidget);
  });
}
