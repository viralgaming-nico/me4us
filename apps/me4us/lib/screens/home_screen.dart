import 'package:core_union/core_union.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'doors_screen.dart';

/// Placeholder home until the Me and Us features land: shows who is in the union,
/// lets the owner fetch an invite code, and shows which doors are open for everyone.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.unions,
    required this.unionId,
    required this.me,
    required this.members,
    required this.onSignOut,
  });

  final UnionRepository unions;
  final String unionId;
  final Member me;
  final List<Member> members;
  final VoidCallback onSignOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _code;
  String? _error;
  bool _busy = false;

  Future<void> _invite() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final c = await widget.unions.newInvite();
      if (mounted) setState(() => _code = c);
    } on UnionException catch (e) {
      if (mounted) {
        setState(() => _error = e.failure == UnionFailure.full
            ? l.unionFull
            : l.inviteFailed);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l.inviteFailedConnection);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = doorLabels(l);
    final members = widget.members;
    final effective = Doors.effective(members.map((m) => m.myDoors));
    final isOwner = widget.me.role == 'owner';
    final seatsLeft = 3 - members.length;
    return Scaffold(
      appBar: AppBar(
        title: const Wordmark(size: 24),
        actions: [TextButton(onPressed: widget.onSignOut, child: Text(l.signOut))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l.yourUnion, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            for (var i = 0; i < members.length; i++)
              ListTile(
                key: Key('member-${members[i].uid}'),
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Me4UsColors.blush,
                  child: Icon(Icons.favorite, color: Me4UsColors.plum),
                ),
                title: Text(members[i].uid == widget.me.uid ? l.you : l.memberN(i + 1)),
                subtitle: members[i].role == 'owner' ? Text(l.startedUnion) : null,
              ),
            if (isOwner && seatsLeft > 0) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy ? null : _invite,
                child: Text(members.length < 2 ? l.inviteSomeone : l.inviteThird),
              ),
              if (_code != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Me4UsColors.lavender,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SelectableText(
                    _code!,
                    key: const Key('home-invite-code'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 3),
                  ),
                ),
                TextButton(
                  onPressed: () => Clipboard.setData(ClipboardData(text: _code!)),
                  child: Text(l.copyCode),
                ),
              ],
              if (_error != null) Text(_error!, key: const Key('home-error')),
            ],
            const SizedBox(height: 28),
            Text(l.openForEveryone, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final d in Door.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(effective.isOpen(d) ? Icons.lock_open : Icons.lock_outline),
                title: Text(labels[d]!.$1),
                trailing: Text(effective.isOpen(d) ? l.doorOpen : l.doorClosed),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => DoorsScreen(
                  unions: widget.unions,
                  unionId: widget.unionId,
                  uid: widget.me.uid,
                  initial: widget.me.myDoors,
                ),
              )),
              child: Text(l.changeDoors),
            ),
          ],
        ),
      ),
    );
  }
}
