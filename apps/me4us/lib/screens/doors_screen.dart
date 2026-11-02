import 'package:core_union/core_union.dart';
import 'package:flutter/material.dart';

/// Where each person chooses which doors they are open to. Everything starts closed.
/// Only what EVERY member opens is ever shown (see Doors.effective).
class DoorsScreen extends StatefulWidget {
  const DoorsScreen({
    super.key,
    required this.unions,
    required this.unionId,
    required this.uid,
    required this.initial,
    this.firstTime = false,
  });

  final UnionRepository unions;
  final String unionId;
  final String uid;
  final Doors initial;

  /// First run: saving also marks onboarding done and the gate moves on by itself.
  /// Otherwise the screen was pushed from Home and closes after saving.
  final bool firstTime;

  @override
  State<DoorsScreen> createState() => _DoorsScreenState();
}

class _DoorsScreenState extends State<DoorsScreen> {
  late Doors _doors = widget.initial;
  bool _busy = false;
  String? _error;

  static const _labels = <Door, (String, String)>{
    Door.kids: ('Kids', 'Calendars and tasks for children in your union.'),
    Door.thirdPerson: ('A third person', 'Include a third member in shared things.'),
    Door.alcohol: ('Alcohol', 'Content that mentions drinking.'),
    Door.lite: ('Lite fun', 'Mild, PG-13 playful content.'),
  };

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.unions.setMyDoors(widget.unionId, widget.uid, _doors);
      if (widget.firstTime) {
        await widget.unions.markOnboarded(widget.unionId, widget.uid);
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) setState(() => _error = "Couldn't save. Check your connection and try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your doors')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Choose what you are open to. Nothing is shown unless everyone in your '
              'union opens that door, and nobody sees your individual choices. '
              'You can change this any time.',
            ),
            const SizedBox(height: 12),
            for (final d in Door.values)
              SwitchListTile(
                key: Key('door-${d.name}'),
                contentPadding: EdgeInsets.zero,
                title: Text(_labels[d]!.$1),
                subtitle: Text(_labels[d]!.$2),
                value: _doors.isOpen(d),
                onChanged: _busy ? null : (v) => setState(() => _doors = _doors.set(d, v)),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, key: const Key('doors-error')),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(widget.firstTime ? 'Continue' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
