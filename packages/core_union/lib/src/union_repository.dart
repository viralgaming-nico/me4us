import 'package:supabase_flutter/supabase_flutter.dart';

import 'doors.dart';
import 'member.dart';

/// Why create_union / redeem_invite did not succeed. Matches the `status` the SQL functions return.
enum UnionFailure { alreadyInUnion, invalid, tooManyAttempts }

class UnionException implements Exception {
  const UnionException(this.failure);
  final UnionFailure failure;

  @override
  String toString() => 'UnionException($failure)';
}

abstract class UnionRepository {
  /// Creates a union with the caller as owner. Returns the first invite code.
  /// Throws [UnionException] if the caller is already in a union.
  Future<({String unionId, String inviteCode})> createUnion();

  /// Joins the union an invite code belongs to. Returns the union id.
  /// Throws [UnionException] for a bad/expired code, an existing union, or too many attempts.
  Future<String> redeemInvite(String code);

  Stream<List<Member>> watchMembers(String unionId);

  /// Effective doors for the union: open only where every member opted in.
  Stream<Doors> watchEffectiveDoors(String unionId) =>
      watchMembers(unionId).map((ms) => Doors.effective(ms.map((m) => m.myDoors)));

  Future<void> setMyDoors(String unionId, String uid, Doors doors);

  Future<void> setPreferences(
    String unionId,
    String uid, {
    bool? acceptsFlags,
    bool? hygieneAlerts,
  });
}

UnionFailure _failureOf(Object? status) => switch (status) {
      'already_in_union' => UnionFailure.alreadyInUnion,
      'too_many_attempts' => UnionFailure.tooManyAttempts,
      _ => UnionFailure.invalid,
    };

class SupabaseUnionRepository extends UnionRepository {
  SupabaseUnionRepository(this._client);

  final SupabaseClient _client;

  Map<String, dynamic> _row(Object? rpcResult) {
    final rows = rpcResult as List;
    return (rows.first as Map).cast<String, dynamic>();
  }

  @override
  Future<({String unionId, String inviteCode})> createUnion() async {
    final r = _row(await _client.rpc('create_union'));
    if (r['status'] != 'ok') throw UnionException(_failureOf(r['status']));
    return (unionId: r['union_id'] as String, inviteCode: r['invite_code'] as String);
  }

  @override
  Future<String> redeemInvite(String code) async {
    final r = _row(await _client.rpc('redeem_invite', params: {'p_code': code}));
    if (r['status'] != 'ok') throw UnionException(_failureOf(r['status']));
    return r['union_id'] as String;
  }

  @override
  Stream<List<Member>> watchMembers(String unionId) => _client
      .from('members')
      .stream(primaryKey: ['union_id', 'user_id'])
      .eq('union_id', unionId)
      .map((rows) => [for (final r in rows) Member.fromRow(r)]);

  @override
  Future<void> setMyDoors(String unionId, String uid, Doors doors) => _client
      .from('members')
      .update({'my_doors': doors.toMap()})
      .eq('union_id', unionId)
      .eq('user_id', uid);

  @override
  Future<void> setPreferences(
    String unionId,
    String uid, {
    bool? acceptsFlags,
    bool? hygieneAlerts,
  }) =>
      _client
          .from('members')
          .update({
            'accepts_flags': ?acceptsFlags,
            'hygiene_alerts': ?hygieneAlerts,
          })
          .eq('union_id', unionId)
          .eq('user_id', uid);
}
