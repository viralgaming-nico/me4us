import 'dart:async';

import 'package:core_auth/core_auth.dart';
import 'package:core_union/core_union.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:me4us/app.dart';

class FakeAuth implements AuthRepository {
  FakeAuth({this._user});
  AuthUser? _user;
  final _ctrl = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get authState => _ctrl.stream;

  @override
  AuthUser? get currentUser => _user;

  void _set(AuthUser? u) {
    _user = u;
    _ctrl.add(u);
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    if (password == 'wrongpass') throw Exception('bad credentials');
    final u = AuthUser(uid: email.split('@').first, email: email);
    _set(u);
    return u;
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (email.startsWith('confirm')) throw const EmailConfirmationRequired();
    return signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() async => _set(null);
}

/// One shared in-memory "database" for every fake user.
class World {
  final members = <String, List<Member>>{};
  final unionOf = <String, String>{};
  final changes = StreamController<void>.broadcast();
  String? code;
  String? codeUnion;
  var _next = 0;

  void changed() => changes.add(null);
}

class FakeUnions extends UnionRepository {
  FakeUnions(this.world, this.uid);
  final World world;
  final String uid;

  @override
  Future<({String unionId, String inviteCode})> createUnion() async {
    if (world.unionOf.containsKey(uid)) throw const UnionException(UnionFailure.alreadyInUnion);
    final id = 'union${world._next++}';
    world.members[id] = [Member(uid: uid, role: 'owner', myDoors: Doors.closed)];
    world.unionOf[uid] = id;
    world.code = 'ABCD2345';
    world.codeUnion = id;
    return (unionId: id, inviteCode: world.code!);
  }

  @override
  Future<String> redeemInvite(String code) async {
    final normalised = code.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (normalised != world.code) throw const UnionException(UnionFailure.invalid);
    final id = world.codeUnion!;
    world.members[id]!.add(Member(uid: uid, role: 'member', myDoors: Doors.closed));
    world.unionOf[uid] = id;
    world.changed();
    return id;
  }

  @override
  Future<String?> myUnionId(String uid) async => world.unionOf[uid];

  @override
  Future<String> newInvite() async {
    final id = world.unionOf[uid]!;
    if (world.members[id]!.length >= 3) throw const UnionException(UnionFailure.full);
    world.code = 'WXYZ6789';
    world.codeUnion = id;
    return world.code!;
  }

  void _replace(String unionId, Member Function(Member) f) {
    final list = world.members[unionId]!;
    final i = list.indexWhere((m) => m.uid == uid);
    list[i] = f(list[i]);
    world.changed();
  }

  @override
  Future<void> markOnboarded(String unionId, String uid) async => _replace(
        unionId,
        (m) => Member(uid: m.uid, role: m.role, myDoors: m.myDoors, onboarded: true),
      );

  @override
  Future<void> setMyDoors(String unionId, String uid, Doors doors) async => _replace(
        unionId,
        (m) => Member(uid: m.uid, role: m.role, myDoors: doors, onboarded: m.onboarded),
      );

  @override
  Future<void> setPreferences(String unionId, String uid, {bool? acceptsFlags, bool? hygieneAlerts}) async {}

  @override
  Stream<List<Member>> watchMembers(String unionId) async* {
    yield List.of(world.members[unionId]!);
    await for (final _ in world.changes.stream) {
      yield List.of(world.members[unionId]!);
    }
  }
}

Future<void> pumpApp(WidgetTester t, FakeAuth auth, FakeUnions unions) async {
  await t.pumpWidget(Me4UsApp(auth: auth, unions: unions));
  await t.pumpAndSettle();
}

Future<void> signIn(WidgetTester t, String who, {String password = 'secret1'}) async {
  await t.enterText(find.widgetWithText(TextField, 'Email'), '$who@test.dev');
  await t.enterText(find.widgetWithText(TextField, 'Password'), password);
  await t.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('wrong password shows a message and stays on sign in', (t) async {
    final world = World();
    await pumpApp(t, FakeAuth(), FakeUnions(world, 'a'));
    await signIn(t, 'a', password: 'wrongpass');
    expect(find.byKey(const Key('auth-message')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('short password is rejected before any request', (t) async {
    await pumpApp(t, FakeAuth(), FakeUnions(World(), 'a'));
    await signIn(t, 'a', password: '123');
    expect(find.byKey(const Key('auth-message')), findsOneWidget);
  });

  testWidgets('sign-up that needs email confirmation tells the user', (t) async {
    await pumpApp(t, FakeAuth(), FakeUnions(World(), 'a'));
    await t.tap(find.text('Create an account'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, 'Email'), 'confirm@test.dev');
    await t.enterText(find.widgetWithText(TextField, 'Password'), 'secret1');
    await t.tap(find.widgetWithText(FilledButton, 'Create account'));
    await t.pumpAndSettle();
    expect(find.textContaining('Check your email'), findsOneWidget);
  });

  testWidgets('owner path: sign in, start union, choose doors, reach home', (t) async {
    final world = World();
    final auth = FakeAuth();
    await pumpApp(t, auth, FakeUnions(world, 'a'));
    await signIn(t, 'a');

    expect(find.text('Link up'), findsOneWidget);
    await t.tap(find.text('Start a union'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('invite-code')), findsOneWidget);
    expect(find.text('ABCD2345'), findsOneWidget);
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();

    // First run: every door starts closed.
    expect(find.text('Your doors'), findsOneWidget);
    for (final d in Door.values) {
      expect(t.widget<SwitchListTile>(find.byKey(Key('door-${d.name}'))).value, isFalse);
    }
    await t.tap(find.byKey(const Key('door-alcohol')));
    await t.tap(find.byKey(const Key('door-lite')));
    await t.pump();
    await t.tap(find.widgetWithText(FilledButton, 'Continue'));
    await t.pumpAndSettle();

    expect(find.text('Your union'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(world.members['union0']!.single.myDoors.isOpen(Door.alcohol), isTrue);
    expect(world.members['union0']!.single.onboarded, isTrue);
  });

  testWidgets('joining: bad code errors, good code lands on doors, then home with both members', (t) async {
    final world = World();
    await FakeUnions(world, 'a').createUnion();
    await FakeUnions(world, 'a').setMyDoors('union0', 'a', Doors.closed.set(Door.alcohol, true));
    await FakeUnions(world, 'a').markOnboarded('union0', 'a');

    await pumpApp(t, FakeAuth(), FakeUnions(world, 'b'));
    await signIn(t, 'b');

    await t.enterText(find.widgetWithText(TextField, 'Invite code'), 'NOPE0000');
    await t.tap(find.widgetWithText(OutlinedButton, 'Join'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('pairing-error')), findsOneWidget);

    await t.enterText(find.widgetWithText(TextField, 'Invite code'), 'abcd-2345');
    await t.tap(find.widgetWithText(OutlinedButton, 'Join'));
    await t.pumpAndSettle();
    expect(find.text('Your doors'), findsOneWidget);

    // b leaves everything closed: the shared doors stay closed even though a opened alcohol.
    await t.tap(find.widgetWithText(FilledButton, 'Continue'));
    await t.pumpAndSettle();
    expect(find.text('Your union'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Member 1'), findsOneWidget);
    expect(find.text('Closed'), findsNWidgets(4));
    expect(find.text('Open'), findsNothing);
  });

  testWidgets('returning user with a finished account goes straight home', (t) async {
    final world = World();
    final u = FakeUnions(world, 'a');
    await u.createUnion();
    await u.markOnboarded('union0', 'a');
    await pumpApp(t, FakeAuth(user: const AuthUser(uid: 'a')), u);
    expect(find.text('Your union'), findsOneWidget);
  });

  testWidgets('owner can fetch a fresh invite code from home', (t) async {
    final world = World();
    final u = FakeUnions(world, 'a');
    await u.createUnion();
    await u.markOnboarded('union0', 'a');
    await pumpApp(t, FakeAuth(user: const AuthUser(uid: 'a')), u);
    await t.tap(find.text('Invite someone'));
    await t.pumpAndSettle();
    expect(find.text('WXYZ6789'), findsOneWidget);
  });

  testWidgets('a non-owner does not see the invite button', (t) async {
    final world = World();
    final owner = FakeUnions(world, 'a');
    await owner.createUnion();
    await owner.markOnboarded('union0', 'a');
    final b = FakeUnions(world, 'b');
    await b.redeemInvite('ABCD2345');
    await b.markOnboarded('union0', 'b');
    await pumpApp(t, FakeAuth(user: const AuthUser(uid: 'b')), b);
    expect(find.text('Your union'), findsOneWidget);
    expect(find.text('Invite a third person'), findsNothing);
    expect(find.text('Invite someone'), findsNothing);
  });

  testWidgets('sign out returns to the sign-in screen', (t) async {
    final world = World();
    final u = FakeUnions(world, 'a');
    await u.createUnion();
    await u.markOnboarded('union0', 'a');
    await pumpApp(t, FakeAuth(user: const AuthUser(uid: 'a')), u);
    await t.tap(find.text('Sign out'));
    await t.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });
}
