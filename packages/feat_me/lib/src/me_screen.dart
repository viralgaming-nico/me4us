import 'package:core_points/core_points.dart';
import 'package:flutter/material.dart';

import '../l10n/me_localizations.dart';
import 'checkin_screen.dart';
import 'items_screen.dart';
import 'me_repository.dart';
import 'models.dart';
import 'starter_content.dart';

/// The Me home: today's self-care list, own points, and the daily check-in.
/// Free and complete on its own: no partner prompts, no "invite your partner" nags.
class MeScreen extends StatefulWidget {
  const MeScreen({super.key, required this.repo, this.clock = DateTime.now, this.actions});

  final MeRepository repo;
  final DateTime Function() clock;

  /// Extra app-bar actions supplied by the app (e.g. sign out).
  final List<Widget>? actions;

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  List<SelfcareItem>? _items;
  List<LogEntry> _logs = const [];
  List<CheckinAnswer>? _checkin;
  bool _failed = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _today => dayKey(widget.clock());

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final r = await Future.wait([widget.repo.items(), widget.repo.logs(), widget.repo.checkin(_today)]);
      if (!mounted) return;
      setState(() {
        _items = r[0] as List<SelfcareItem>;
        _logs = r[1] as List<LogEntry>;
        _checkin = r[2] as List<CheckinAnswer>?;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _guard(Future<void> Function() job) async {
    final l = MeLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await job();
    } catch (_) {
      if (mounted) setState(() => _error = l.saveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _doneToday(SelfcareItem i) => _logs.any((l) => l.itemId == i.id && l.day == _today && l.done);

  Future<void> _toggle(SelfcareItem item, bool done) => _guard(() async {
        await widget.repo.setDone(item, _today, done);
        if (!mounted) return;
        setState(() {
          _logs = [
            for (final l in _logs)
              if (!(l.itemId == item.id && l.day == _today)) l,
            LogEntry(itemId: item.id, day: _today, done: done, points: done ? item.pointValue : 0),
          ];
        });
      });

  Future<void> _useStarter() => _guard(() async {
        final l = MeLocalizations.of(context);
        await widget.repo.addItems([
          for (final s in starterItems)
            SelfcareItem(
              id: '',
              title: starterTitle(l, s.id),
              category: s.category,
              cadence: s.cadence,
              pointValue: s.points,
            ),
        ]);
        await _load();
      });

  Future<void> _openItems() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ItemsScreen(repo: widget.repo),
    ));
    await _load();
  }

  Future<void> _openCheckin() async {
    final saved = await Navigator.of(context).push<List<CheckinAnswer>>(MaterialPageRoute(
      builder: (_) => CheckinScreen(repo: widget.repo, day: _today, initial: _checkin),
    ));
    if (saved != null && mounted) setState(() => _checkin = saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = MeLocalizations.of(context);
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: Text(l.meTitle), actions: widget.actions),
      body: SafeArea(
        child: _failed
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(l.loadFailed),
                  TextButton(onPressed: _load, child: Text(l.retry)),
                ]),
              )
            : items == null
                ? const Center(child: CircularProgressIndicator())
                : _body(l, items),
      ),
    );
  }

  Widget _body(MeLocalizations l, List<SelfcareItem> items) {
    final now = widget.clock();
    final points = PointsSummary.from(_logs.map((e) => e.tick), now);
    final active = items.where((i) => i.active).toList();
    final today = active.where((i) => isDueToday(i, _logs, now)).toList();
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          key: const Key('me-points'),
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: Text(l.pointsTotal(points.total),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(l.pointsToday(points.today)),
                Text(l.pointsWeek(points.last7Days)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          key: const Key('me-checkin'),
          child: ListTile(
            title: Text(l.checkinTitle),
            subtitle: Text(_checkin == null ? l.checkinPrompt : l.checkinDone),
            trailing: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
              onPressed: _busy ? null : _openCheckin,
              child: Text(_checkin == null ? l.checkinStart : l.checkinEdit),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (active.isEmpty) ...[
          Text(l.emptyTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l.emptyBody),
          const SizedBox(height: 12),
          FilledButton(onPressed: _busy ? null : _useStarter, child: Text(l.useStarter)),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _busy ? null : _openItems, child: Text(l.addOwn)),
        ] else ...[
          Text(l.todayList, style: Theme.of(context).textTheme.titleMedium),
          if (today.every(_doneToday)) Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l.allDoneToday, key: const Key('me-all-done')),
          ),
          for (final i in today)
            CheckboxListTile(
              key: Key('item-${i.id}'),
              contentPadding: EdgeInsets.zero,
              value: _doneToday(i),
              onChanged: _busy ? null : (v) => _toggle(i, v ?? false),
              title: Text(i.title),
              secondary: Text(l.pointsPlus(i.pointValue)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _busy ? null : _openItems, child: Text(l.manageItems)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, key: const Key('me-error')),
        ],
      ],
    );
  }
}
