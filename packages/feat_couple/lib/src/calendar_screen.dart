import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/couple_localizations.dart';
import 'couple_repository.dart';
import 'models.dart';
import 'paywall_stub.dart';

/// The union's shared calendar as a live agenda (Realtime keeps every phone in sync).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    required this.repo,
    required this.unionId,
    required this.uid,
    this.clock = DateTime.now,
  });

  final CoupleRepository repo;
  final String unionId;
  final String uid;
  final DateTime Function() clock;

  void _open(BuildContext context, [CalendarEvent? e]) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => EventEditor(repo: repo, unionId: unionId, uid: uid, event: e, clock: clock),
      ));

  @override
  Widget build(BuildContext context) {
    final l = CoupleLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.calendarTitle)),
      body: EntitlementGate(
        entitled: repo.watchEntitled(unionId),
        child: StreamBuilder<List<CalendarEvent>>(
          stream: repo.watchEvents(unionId),
          builder: (context, snap) {
            if (snap.hasError) return Center(child: Text(l.loadFailed));
            final events = snap.data;
            if (events == null) return const Center(child: CircularProgressIndicator());
            final now = clock();
            final today = DateTime(now.year, now.month, now.day);
            final upcoming = byDay(events.where((e) => !(e.endAt ?? e.startAt).isBefore(today)));
            return Stack(children: [
              if (upcoming.isEmpty)
                Center(child: Text(l.noEvents, key: const Key('no-events')))
              else
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    for (final day in upcoming.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(_dayLabel(context, l, day.key, today),
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      for (final e in day.value)
                        Card(
                          child: ListTile(
                            key: Key('event-${e.id}'),
                            leading: Icon(e.shared ? Icons.people_outline : Icons.person_outline),
                            title: Text(e.title),
                            subtitle: Text(_timeLabel(context, l, e)),
                            trailing: e.canEdit(uid) ? const Icon(Icons.edit_outlined) : null,
                            onTap: e.canEdit(uid) ? () => _open(context, e) : null,
                          ),
                        ),
                    ],
                  ],
                ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  key: const Key('add-event'),
                  onPressed: () => _open(context),
                  icon: const Icon(Icons.add),
                  label: Text(l.addEvent),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  static String _dayLabel(BuildContext context, CoupleLocalizations l, DateTime day, DateTime today) {
    final diff = DateTime.utc(day.year, day.month, day.day)
        .difference(DateTime.utc(today.year, today.month, today.day))
        .inDays;
    if (diff == 0) return l.today;
    if (diff == 1) return l.tomorrow;
    return DateFormat.MMMEd(Localizations.localeOf(context).toString()).format(day);
  }

  static String _timeLabel(BuildContext context, CoupleLocalizations l, CalendarEvent e) {
    if (e.allDay) return l.allDay;
    final f = DateFormat.Hm(Localizations.localeOf(context).toString());
    return e.endAt == null ? f.format(e.startAt) : '${f.format(e.startAt)} – ${f.format(e.endAt!)}';
  }
}

/// Create or edit one event.
class EventEditor extends StatefulWidget {
  const EventEditor({
    super.key,
    required this.repo,
    required this.unionId,
    required this.uid,
    this.event,
    this.clock = DateTime.now,
  });

  final CoupleRepository repo;
  final String unionId;
  final String uid;
  final CalendarEvent? event;
  final DateTime Function() clock;

  @override
  State<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  late final _title = TextEditingController(text: widget.event?.title ?? '');
  late DateTime _start = widget.event?.startAt ?? _nextHour(widget.clock());
  late DateTime? _end = widget.event?.endAt;
  late bool _allDay = widget.event?.allDay ?? false;
  late bool _shared = widget.event?.shared ?? true;
  late final Set<int> _reminders = {...?widget.event?.reminders};
  bool _busy = false;
  String? _error;

  static DateTime _nextHour(DateTime now) => DateTime(now.year, now.month, now.day, now.hour + 1);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(initial.year + 5),
    );
    if (d == null || !mounted) return null;
    if (_allDay) return DateTime(d.year, d.month, d.day);
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Future<void> _save() async {
    final l = CoupleLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final end = _end != null && _end!.isBefore(_start) ? null : _end;
    final e = CalendarEvent(
      id: widget.event?.id ?? '',
      title: title,
      startAt: _allDay ? DateTime(_start.year, _start.month, _start.day) : _start,
      endAt: _allDay ? null : end,
      allDay: _allDay,
      ownerUid: _shared ? null : widget.uid,
      reminders: (_reminders.toList()..sort()),
    );
    await _run(() => widget.repo.saveEvent(widget.unionId, e), l);
  }

  Future<void> _delete() => _run(() => widget.repo.deleteEvent(widget.event!.id), CoupleLocalizations.of(context));

  Future<void> _run(Future<void> Function() job, CoupleLocalizations l) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await job();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l.saveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _reminderLabel(CoupleLocalizations l, int m) => switch (m) {
        60 => l.remindHour,
        1440 => l.remindDay,
        _ => l.remindMinutes(m),
      };

  @override
  Widget build(BuildContext context) {
    final l = CoupleLocalizations.of(context);
    final loc = Localizations.localeOf(context).toString();
    final fmt = _allDay ? DateFormat.yMMMEd(loc) : DateFormat.yMMMEd(loc).add_Hm();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? l.addEvent : l.editEvent),
        actions: [
          if (widget.event != null)
            IconButton(
              key: const Key('delete-event'),
              tooltip: l.delete,
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('event-title'),
              controller: _title,
              decoration: InputDecoration(labelText: l.eventTitle),
            ),
            SwitchListTile(
              key: const Key('event-all-day'),
              contentPadding: EdgeInsets.zero,
              title: Text(l.allDay),
              value: _allDay,
              onChanged: (v) => setState(() => _allDay = v),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.starts),
              subtitle: Text(fmt.format(_start)),
              onTap: () async {
                final d = await _pick(_start);
                if (d != null) setState(() => _start = d);
              },
            ),
            if (!_allDay)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.ends),
                subtitle: Text(_end == null ? l.noEnd : fmt.format(_end!)),
                onTap: () async {
                  final d = await _pick(_end ?? _start.add(const Duration(hours: 1)));
                  if (d != null) setState(() => _end = d);
                },
              ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l.sharedEvent), icon: const Icon(Icons.people_outline)),
                ButtonSegment(value: false, label: Text(l.mineEvent), icon: const Icon(Icons.person_outline)),
              ],
              selected: {_shared},
              onSelectionChanged: (s) => setState(() => _shared = s.first),
            ),
            const SizedBox(height: 4),
            Text(_shared ? l.sharedEventDesc : l.mineEventDesc),
            const SizedBox(height: 16),
            Text(l.reminders, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final m in reminderChoices)
                FilterChip(
                  key: Key('reminder-$m'),
                  label: Text(_reminderLabel(l, m)),
                  selected: _reminders.contains(m),
                  onSelected: (on) => setState(() => on ? _reminders.add(m) : _reminders.remove(m)),
                ),
            ]),
            const SizedBox(height: 4),
            Text(l.remindersLater, style: Theme.of(context).textTheme.bodySmall),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, key: const Key('event-error')),
            ],
            const SizedBox(height: 20),
            FilledButton(key: const Key('event-save'), onPressed: _busy ? null : _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
