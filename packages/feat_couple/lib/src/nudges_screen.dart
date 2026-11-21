import 'package:flutter/material.dart';

import '../l10n/couple_localizations.dart';
import 'couple_repository.dart';
import 'models.dart';
import 'paywall_stub.dart';

/// Send and read nudges. Opt-in: the "Accept nudges" switch is the person's own
/// members.accepts_flags, saved by the app through [onAcceptChanged].
class NudgesScreen extends StatefulWidget {
  const NudgesScreen({
    super.key,
    required this.repo,
    required this.unionId,
    required this.uid,
    required this.others,
    required this.accepting,
    required this.onAcceptChanged,
  });

  final CoupleRepository repo;
  final String unionId;
  final String uid;

  /// The other members: uid -> display label.
  final Map<String, String> others;
  final bool accepting;
  final Future<void> Function(bool) onAcceptChanged;

  @override
  State<NudgesScreen> createState() => _NudgesScreenState();
}

class _NudgesScreenState extends State<NudgesScreen> {
  late bool _accepting = widget.accepting;
  late String? _to = widget.others.keys.firstOrNull;
  NudgeKind _kind = NudgeKind.flag;
  final _text = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String _resultText(CoupleLocalizations l, NudgeResult r) => switch (r) {
        NudgeResult.ok => l.sent,
        NudgeResult.notAccepting => l.errNotAccepting,
        NudgeResult.rateLimited => l.errRateLimited,
        NudgeResult.notEntitled => l.errNotEntitled,
        NudgeResult.notMember || NudgeResult.invalid => l.errGeneric,
      };

  Future<void> _send() async {
    final l = CoupleLocalizations.of(context);
    final to = _to;
    if (to == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final r = await widget.repo.sendNudge(
        to,
        _kind,
        text: _kind == NudgeKind.presence ? null : _text.text.trim(),
      );
      if (!mounted) return;
      setState(() => _message = _resultText(l, r));
      if (r == NudgeResult.ok) _text.clear();
    } catch (_) {
      if (mounted) setState(() => _message = l.errGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setAccepting(bool v) async {
    final l = CoupleLocalizations.of(context);
    setState(() => _accepting = v);
    try {
      await widget.onAcceptChanged(v);
    } catch (_) {
      if (mounted) {
        setState(() {
          _accepting = !v;
          _message = l.saveFailed;
        });
      }
    }
  }

  String _body(CoupleLocalizations l, Nudge n) => n.kind == NudgeKind.presence
      ? l.presenceMessage
      : (n.text?.isNotEmpty ?? false)
          ? n.text!
          : l.nudgeFallback;

  @override
  Widget build(BuildContext context) {
    final l = CoupleLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.nudgesTitle)),
      body: EntitlementGate(
        entitled: widget.repo.watchEntitled(widget.unionId),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SwitchListTile(
              key: const Key('accept-nudges'),
              contentPadding: EdgeInsets.zero,
              title: Text(l.acceptNudges),
              subtitle: Text(l.acceptNudgesDesc),
              value: _accepting,
              onChanged: _setAccepting,
            ),
            const Divider(height: 32),
            if (widget.others.isEmpty)
              Text(l.nobodyToNudge)
            else ...[
              if (widget.others.length > 1)
                DropdownButtonFormField<String>(
                  initialValue: _to,
                  decoration: InputDecoration(labelText: l.sendTo),
                  items: [
                    for (final e in widget.others.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) => setState(() => _to = v),
                )
              else
                Text('${l.sendTo}: ${widget.others.values.first}'),
              const SizedBox(height: 12),
              SegmentedButton<NudgeKind>(
                segments: [
                  ButtonSegment(value: NudgeKind.flag, label: Text(l.kindFlag)),
                  ButtonSegment(value: NudgeKind.presence, label: Text(l.kindPresence)),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
              const SizedBox(height: 12),
              if (_kind == NudgeKind.flag)
                TextField(
                  key: const Key('nudge-text'),
                  controller: _text,
                  maxLength: 140,
                  decoration: InputDecoration(labelText: l.nudgeText),
                )
              else
                Text(l.presenceDesc),
              const SizedBox(height: 12),
              FilledButton(key: const Key('send-nudge'), onPressed: _busy ? null : _send, child: Text(l.send)),
            ],
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(_message!, key: const Key('nudge-message')),
            ],
            const Divider(height: 32),
            StreamBuilder<List<Nudge>>(
              stream: widget.repo.watchNudges(widget.uid),
              builder: (context, snap) {
                final all = snap.data ?? const <Nudge>[];
                final received = all.where((n) => n.toUid == widget.uid).toList();
                final sent = all.where((n) => n.fromUid == widget.uid).toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.received, style: Theme.of(context).textTheme.titleMedium),
                  if (received.isEmpty) Text(l.noNudges),
                  for (final n in received)
                    ListTile(
                      key: Key('nudge-${n.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(n.readAt == null ? Icons.favorite : Icons.favorite_border),
                      title: Text(_body(l, n)),
                      subtitle: Text(widget.others[n.fromUid] ?? ''),
                      trailing: n.readAt == null
                          ? TextButton(onPressed: () => widget.repo.markRead(n.id), child: Text(l.markRead))
                          : null,
                    ),
                  const SizedBox(height: 16),
                  Text(l.sentList, style: Theme.of(context).textTheme.titleMedium),
                  if (sent.isEmpty) Text(l.noNudges),
                  for (final n in sent)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_body(l, n)),
                      subtitle: Text(widget.others[n.toUid] ?? ''),
                    ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
