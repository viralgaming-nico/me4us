import 'package:flutter/material.dart';

import '../l10n/me_localizations.dart';
import 'me_repository.dart';
import 'models.dart';
import 'starter_content.dart';

/// Daily multiple-choice check-in with an optional note. Pops with the saved answers.
class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key, required this.repo, required this.day, this.initial});

  final MeRepository repo;
  final String day;
  final List<CheckinAnswer>? initial;

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  late final Map<String, String> _choices = {
    for (final a in widget.initial ?? const <CheckinAnswer>[])
      if (a.choiceId != null) a.qId: a.choiceId!,
  };
  late final _note = TextEditingController(
    text: widget.initial?.where((a) => a.qId == 'note').firstOrNull?.note ?? '',
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = MeLocalizations.of(context);
    final note = _note.text.trim();
    final answers = [
      for (final q in checkinQuestions)
        if (_choices[q.id] != null) CheckinAnswer(qId: q.id, choiceId: _choices[q.id]),
      if (note.isNotEmpty) CheckinAnswer(qId: 'note', note: note),
    ];
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repo.saveCheckin(widget.day, answers);
      if (mounted) Navigator.of(context).pop(answers);
    } catch (_) {
      if (mounted) setState(() => _error = l.saveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = MeLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.checkinTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            for (final q in checkinQuestions) ...[
              Text(questionLabel(l, q.id), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in q.choices)
                    ChoiceChip(
                      key: Key('choice-${q.id}-$c'),
                      label: Text(choiceLabel(l, q.id, c)),
                      selected: _choices[q.id] == c,
                      onSelected: _busy
                          ? null
                          : (on) => setState(() => on ? _choices[q.id] = c : _choices.remove(q.id)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              key: const Key('checkin-note'),
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.checkinNote),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, key: const Key('checkin-error')),
            ],
            const SizedBox(height: 20),
            FilledButton(onPressed: _busy ? null : _save, child: Text(l.checkinSave)),
          ],
        ),
      ),
    );
  }
}
