import 'package:core_union/core_union.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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

  String _messageFor(AppLocalizations l, UnionFailure f) => switch (f) {
        UnionFailure.alreadyInUnion => l.errAlreadyInUnion,
        UnionFailure.tooManyAttempts => l.errTooManyAttempts,
        UnionFailure.invalid => l.errInvalidCode,
        UnionFailure.notOwner || UnionFailure.full => l.errGeneric,
      };

  Future<void> _run(Future<void> Function() job) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await job();
    } on UnionException catch (e) {
      if (mounted) setState(() => _error = _messageFor(l, e.failure));
    } catch (_) {
      if (mounted) setState(() => _error = l.errConnection);
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
        actions: [TextButton(onPressed: widget.onSignOut, child: Text(AppLocalizations.of(context).signOut))],
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
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.unionReady, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l.shareCode),
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
          child: Text(l.copyCode),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => widget.onJoined(created.unionId),
          child: Text(l.continueButton),
        ),
      ],
    );
  }

  Widget _chooseView() {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.linkUp, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l.unionExplainer),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: Text(l.startUnion),
        ),
        const SizedBox(height: 28),
        Text(l.haveCode),
        const SizedBox(height: 8),
        TextField(
          controller: _code,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          decoration: InputDecoration(labelText: l.inviteCode),
          onSubmitted: (_) => _busy ? null : _join(),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _busy ? null : _join,
          child: Text(l.join),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, key: const Key('pairing-error')),
        ],
      ],
    );
  }
}
