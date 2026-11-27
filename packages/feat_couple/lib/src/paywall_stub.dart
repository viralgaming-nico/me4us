import 'package:flutter/material.dart';

import '../l10n/couple_localizations.dart';

/// Placeholder until billing exists. Never grants access itself: us_entitled is set
/// server-side only (by a future purchase check, or by hand in the dashboard for testing).
class PaywallStub extends StatelessWidget {
  const PaywallStub({super.key});

  @override
  Widget build(BuildContext context) {
    final l = CoupleLocalizations.of(context);
    return Center(
      key: const Key('paywall'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l.paywallTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(l.paywallBody, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(l.paywallNote, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

/// Shows [child] only while the union is entitled; otherwise the paywall.
class EntitlementGate extends StatelessWidget {
  const EntitlementGate({super.key, required this.entitled, required this.child});

  final Stream<bool> entitled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: entitled,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return snap.data! ? child : const PaywallStub();
      },
    );
  }
}
