import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

abstract class CoupleRepository {
  /// Whether Me + You is unlocked for the union (unions.us_entitled).
  Stream<bool> watchEntitled(String unionId);

  /// Live union calendar (Realtime).
  Stream<List<CalendarEvent>> watchEvents(String unionId);

  Future<void> saveEvent(String unionId, CalendarEvent event);

  Future<void> deleteEvent(String eventId);

  /// Live nudges the signed-in person sent or received.
  Stream<List<Nudge>> watchNudges(String uid);

  Future<NudgeResult> sendNudge(String toUid, NudgeKind kind, {String? text});

  Future<void> markRead(String nudgeId);
}

class SupabaseCoupleRepository implements CoupleRepository {
  SupabaseCoupleRepository(this._client);
  final SupabaseClient _client;

  @override
  Stream<bool> watchEntitled(String unionId) => _client
      .from('unions')
      .stream(primaryKey: ['id'])
      .eq('id', unionId)
      .map((rows) => rows.isNotEmpty && rows.first['us_entitled'] == true);

  @override
  Stream<List<CalendarEvent>> watchEvents(String unionId) => _client
      .from('events')
      .stream(primaryKey: ['id'])
      .eq('union_id', unionId)
      .order('start_at')
      .map((rows) => [for (final r in rows) CalendarEvent.fromRow(r)]);

  @override
  Future<void> saveEvent(String unionId, CalendarEvent event) async {
    final row = event.toRow(unionId);
    if (event.id.isEmpty) {
      await _client.from('events').insert(row);
    } else {
      row.remove('union_id');
      await _client.from('events').update(row).eq('id', event.id);
    }
  }

  @override
  Future<void> deleteEvent(String eventId) => _client.from('events').delete().eq('id', eventId);

  // RLS returns only rows where the caller is sender or recipient.
  @override
  Stream<List<Nudge>> watchNudges(String uid) => _client
      .from('nudges')
      .stream(primaryKey: ['id'])
      .order('at', ascending: false)
      .map((rows) => [for (final r in rows) Nudge.fromRow(r)]);

  @override
  Future<NudgeResult> sendNudge(String toUid, NudgeKind kind, {String? text}) async {
    final rows = await _client.rpc('send_nudge', params: {'p_to': toUid, 'p_kind': kind.name, 'p_text': text});
    return nudgeResultOf(((rows as List).first as Map)['status']);
  }

  @override
  Future<void> markRead(String nudgeId) => _client
      .from('nudges')
      .update({'read_at': DateTime.now().toUtc().toIso8601String()})
      .eq('id', nudgeId);
}
