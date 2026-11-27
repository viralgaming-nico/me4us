import 'package:core_auth/core_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.auth});
  final AuthRepository auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _creating = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _google() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.auth.signInWithGoogle();
      // The session arrives through the auth stream when the browser returns to the app.
    } catch (_) {
      if (mounted) setState(() => _message = l.authGoogleFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 6) {
      setState(() => _message = l.authNeedEmailPassword);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (_creating) {
        final name = _name.text.trim();
        await widget.auth.createAccount(
          email: email,
          password: password,
          displayName: name.isEmpty ? null : name,
        );
      } else {
        await widget.auth.signIn(email: email, password: password);
      }
      // The auth stream moves the app on from here.
    } on EmailConfirmationRequired {
      if (mounted) {
        setState(() {
          _creating = false;
          _message = l.authCheckEmail;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = _creating
            ? l.authCreateFailed
            : l.authSignInFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: Wordmark(size: 44)),
                  const SizedBox(height: 4),
                  Center(child: Text(l.tagline)),
                  const SizedBox(height: 32),
                  if (_creating) ...[
                    TextField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l.yourName),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l.email),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _busy ? null : _submit(),
                    decoration: InputDecoration(labelText: l.password),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!, key: const Key('auth-message')),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_creating ? l.createAccount : l.signIn),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _creating = !_creating;
                              _message = null;
                            }),
                    child: Text(_creating ? l.haveAccount : l.createAnAccount),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text(l.or)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('google-sign-in'),
                    onPressed: _busy ? null : _google,
                    icon: const Icon(Icons.account_circle_outlined),
                    label: Text(l.continueWithGoogle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
