import 'package:core_union/core_union.dart';
import 'package:flutter/material.dart';
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

  static const _doorNames = {
    Door.kids: 'Kids',
    Door.thirdPerson: 'A third person',
    Door.alcohol: 'Alcohol',
    Door.lite: 'Lite fun',
  };

  Future<void> _invite() async {
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
            ? 'Your union is full.'
            : "Couldn't make a code. Please try again.");
      }
    } catch (_) {
      if (mounted) setState(() => _error = "Couldn't make a code. Check your connection.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.members;
    final effective = Doors.effective(members.map((m) => m.myDoors));
    final isOwner = widget.me.role == 'owner';
    final seatsLeft = 3 - members.length;
    return Scaffold(
      appBar: AppBar(
        title: const Wordmark(size: 24),
        actions: [TextButton(onPressed: widget.onSignOut, child: const Text('Sign out'))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Your union', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            for (var i = 0; i < members.length; i++)
              ListTile(
                key: Key('member-${members[i].uid}'),
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Me4UsColors.blush,
                  child: Icon(Icons.favorite, color: Me4UsColors.plum),
                ),
                title: Text(members[i].uid == widget.me.uid ? 'You' : 'Member ${i + 1}'),
                subtitle: members[i].role == 'owner' ? const Text('Started this union') : null,
              ),
            if (isOwner && seatsLeft > 0) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _busy ? null : _invite,
                child: Text(members.length < 2 ? 'Invite someone' : 'Invite a third person'),
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
                  child: const Text('Copy code'),
                ),
              ],
              if (_error != null) Text(_error!, key: const Key('home-error')),
            ],
            const SizedBox(height: 28),
            Text('Open for everyone', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final d in Door.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(effective.isOpen(d) ? Icons.lock_open : Icons.lock_outline),
                title: Text(_doorNames[d]!),
                trailing: Text(effective.isOpen(d) ? 'Open' : 'Closed'),
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
              child: const Text('Change my doors'),
            ),
          ],
        ),
      ),
    );
  }
}
