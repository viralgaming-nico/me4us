import 'package:core_union/core_union.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Start a new union, or join one with an invite code.
class PairingScreen extends StatefulWidget {
  const PairingScreen({
    super.key,
    required this.unions,
    required this.onJoined,
    required this.onSignOut,
  });

  final UnionRepository unions;
  final void Function(String unionId) onJoined;
  final VoidCallback onSignOut;

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;
  ({String unionId, String inviteCode})? _created;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  String _messageFor(UnionFailure f) => switch (f) {
        UnionFailure.alreadyInUnion => 'You are already in a union.',
        UnionFailure.tooManyAttempts => 'Too many attempts. Please try again in an hour.',
        UnionFailure.invalid => "That code isn't valid. Check it and try again.",
        UnionFailure.notOwner || UnionFailure.full => 'That did not work. Please try again.',
      };

  Future<void> _run(Future<void> Function() job) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await job();
    } on UnionException catch (e) {
      if (mounted) setState(() => _error = _messageFor(e.failure));
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() => _run(() async {
        final r = await widget.unions.createUnion();
        if (mounted) setState(() => _created = r);
      });

  Future<void> _join() => _run(() async {
        final id = await widget.unions.redeemInvite(_code.text);
        widget.onJoined(id);
      });

  @override
  Widget build(BuildContext context) {
    final created = _created;
    return Scaffold(
      appBar: AppBar(
        title: const Wordmark(size: 24),
        actions: [TextButton(onPressed: widget.onSignOut, child: const Text('Sign out'))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: created != null ? _codeView(created) : _chooseView(),
        ),
      ),
    );
  }

  Widget _codeView(({String unionId, String inviteCode}) created) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Your union is ready', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Share this code with the other person. It works for 7 days.'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Me4UsColors.lavender,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SelectableText(
            created.inviteCode,
            key: const Key('invite-code'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 4),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: created.inviteCode)),
          child: const Text('Copy code'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => widget.onJoined(created.unionId),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _chooseView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Link up', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('A union is 2 or 3 people on their own phones.'),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: const Text('Start a union'),
        ),
        const SizedBox(height: 28),
        const Text('Have a code?'),
        const SizedBox(height: 8),
        TextField(
          controller: _code,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'Invite code'),
          onSubmitted: (_) => _busy ? null : _join(),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _busy ? null : _join,
          child: const Text('Join'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, key: const Key('pairing-error')),
        ],
      ],
    );
  }
}
