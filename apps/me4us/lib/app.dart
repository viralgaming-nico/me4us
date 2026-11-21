import 'package:core_auth/core_auth.dart';
import 'package:core_union/core_union.dart';
import 'package:feat_couple/feat_couple.dart';
import 'package:feat_me/feat_me.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

import 'screens/auth_screen.dart';
import 'screens/doors_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pairing_screen.dart';
import 'theme.dart';

/// Builds the signed-in person's own Me repository.
typedef MeRepositoryFor = MeRepository Function(String uid);

class Me4UsApp extends StatelessWidget {
  const Me4UsApp({
    super.key,
    required this.auth,
    required this.unions,
    required this.meFor,
    required this.couple,
  });

  final AuthRepository auth;
  final UnionRepository unions;
  final MeRepositoryFor meFor;
  final CoupleRepository couple;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'me4us',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        MeLocalizations.delegate,
        CoupleLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: SessionGate(auth: auth, unions: unions, meFor: meFor, couple: couple),
    );
  }
}

/// Signed out -> sign in. Signed in -> [MainShell].
class SessionGate extends StatelessWidget {
  const SessionGate({
    super.key,
    required this.auth,
    required this.unions,
    required this.meFor,
    required this.couple,
  });

  final AuthRepository auth;
  final UnionRepository unions;
  final MeRepositoryFor meFor;
  final CoupleRepository couple;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      initialData: auth.currentUser,
      stream: auth.authState,
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) return AuthScreen(auth: auth);
        return MainShell(
          key: ValueKey(user.uid),
          user: user,
          unions: unions,
          me: meFor(user.uid),
          couple: couple,
          onSignOut: auth.signOut,
        );
      },
    );
  }
}

/// Me | Us. Me is free and works solo, so it is the first tab and never waits on a union.
/// Us holds pairing, doors and the union home.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.user,
    required this.unions,
    required this.me,
    required this.onSignOut,
    required this.couple,
  });

  final AuthUser user;
  final UnionRepository unions;
  final MeRepository me;
  final VoidCallback onSignOut;
  final CoupleRepository couple;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          MeScreen(
            repo: widget.me,
            actions: [TextButton(onPressed: widget.onSignOut, child: Text(l.signOut))],
          ),
          UnionGate(
            user: widget.user,
            unions: widget.unions,
            onSignOut: widget.onSignOut,
            couple: widget.couple,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            key: const Key('tab-me'),
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l.tabMe,
          ),
          NavigationDestination(
            key: const Key('tab-us'),
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l.tabUs,
          ),
        ],
      ),
    );
  }
}

/// Finds the user's union. None -> pairing. One -> [MemberGate].
class UnionGate extends StatefulWidget {
  const UnionGate({
    super.key,
    required this.user,
    required this.unions,
    required this.onSignOut,
    required this.couple,
  });

  final AuthUser user;
  final UnionRepository unions;
  final VoidCallback onSignOut;
  final CoupleRepository couple;

  @override
  State<UnionGate> createState() => _UnionGateState();
}

class _UnionGateState extends State<UnionGate> {
  String? _unionId;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final id = await widget.unions.myUnionId(widget.user.uid);
      if (mounted) setState(() => _unionId = id);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _Loading();
    if (_failed) {
      final l = AppLocalizations.of(context);
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.loadAccountFailed),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _load,
                style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                child: Text(l.tryAgain),
              ),
              TextButton(onPressed: widget.onSignOut, child: Text(l.signOut)),
            ],
          ),
        ),
      );
    }
    final id = _unionId;
    if (id == null) {
      return PairingScreen(
        unions: widget.unions,
        onJoined: (unionId) => setState(() => _unionId = unionId),
        onSignOut: widget.onSignOut,
      );
    }
    return MemberGate(
      couple: widget.couple,
      unionId: id,
      uid: widget.user.uid,
      unions: widget.unions,
      onSignOut: widget.onSignOut,
    );
  }
}

/// Watches the union's members. Not yet onboarded -> doors. Otherwise -> home.
class MemberGate extends StatelessWidget {
  const MemberGate({
    super.key,
    required this.unionId,
    required this.uid,
    required this.unions,
    required this.onSignOut,
    required this.couple,
  });

  final String unionId;
  final String uid;
  final UnionRepository unions;
  final VoidCallback onSignOut;
  final CoupleRepository couple;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Member>>(
      stream: unions.watchMembers(unionId),
      builder: (context, snap) {
        final members = snap.data;
        if (snap.hasError) {
          final l = AppLocalizations.of(context);
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.loadUnionFailed),
                  TextButton(onPressed: onSignOut, child: Text(l.signOut)),
                ],
              ),
            ),
          );
        }
        if (members == null) return const _Loading();
        final me = members.where((m) => m.uid == uid).firstOrNull;
        if (me == null) return const _Loading();
        if (!me.onboarded) {
          return DoorsScreen(
            unions: unions,
            unionId: unionId,
            uid: uid,
            initial: me.myDoors,
            firstTime: true,
          );
        }
        return HomeScreen(
          couple: couple,
          unions: unions,
          unionId: unionId,
          me: me,
          members: members,
          onSignOut: onSignOut,
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Me4UsColors.dusk)),
      );
}
