import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

/// The signed-in person's own Me data. Row-level security keeps all of it owner-only.
abstract class MeRepository {
  Future<List<SelfcareItem>> items();

  Future<void> addItems(List<SelfcareItem> items);

  Future<void> updateItem(SelfcareItem item);

  /// Every tick (for the points total). Small per person in v0.
  Future<List<LogEntry>> logs();

  Future<void> setDone(SelfcareItem item, String day, bool done);

  Future<List<CheckinAnswer>?> checkin(String day);

  Future<void> saveCheckin(String day, List<CheckinAnswer> answers);
}

class SupabaseMeRepository implements MeRepository {
  SupabaseMeRepository(this._client, this._uid);

  final SupabaseClient _client;
  final String _uid;

  Map<String, dynamic> _itemRow(SelfcareItem i) => {
        'user_id': _uid,
        'title': i.title,
        'category': i.category.name,
        'cadence': i.cadence.name,
        'point_value': i.pointValue,
        'active': i.active,
      };

  @override
  Future<List<SelfcareItem>> items() async {
    final rows = await _client.from('selfcare_items').select().eq('user_id', _uid).order('title');
    return [for (final r in rows) SelfcareItem.fromRow(r)];
  }

  @override
  Future<void> addItems(List<SelfcareItem> items) =>
      _client.from('selfcare_items').insert([for (final i in items) _itemRow(i)]);

  @override
  Future<void> updateItem(SelfcareItem item) =>
      _client.from('selfcare_items').update(_itemRow(item)).eq('id', item.id).eq('user_id', _uid);

  @override
  Future<List<LogEntry>> logs() async {
    final rows = await _client.from('selfcare_log').select('item_id, date, done, points').eq('user_id', _uid);
    return [
      for (final r in rows)
        LogEntry(
          itemId: r['item_id'] as String,
          day: r['date'] as String,
          done: r['done'] == true,
          points: (r['points'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  @override
  Future<void> setDone(SelfcareItem item, String day, bool done) => _client.from('selfcare_log').upsert(
        {
          'user_id': _uid,
          'item_id': item.id,
          'date': day,
          'done': done,
          'points': done ? item.pointValue : 0,
          'at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,date,item_id',
      );

  @override
  Future<List<CheckinAnswer>?> checkin(String day) async {
    final row = await _client.from('checkins').select('answers').eq('user_id', _uid).eq('date', day).maybeSingle();
    if (row == null) return null;
    return [for (final a in row['answers'] as List) CheckinAnswer.fromJson((a as Map).cast<String, dynamic>())];
  }

  @override
  Future<void> saveCheckin(String day, List<CheckinAnswer> answers) => _client.from('checkins').upsert(
        {'user_id': _uid, 'date': day, 'answers': [for (final a in answers) a.toJson()]},
        onConflict: 'user_id,date',
      );
}
