import 'doors.dart';

class Member {
  const Member({
    required this.uid,
    required this.role,
    required this.myDoors,
    this.acceptsFlags = false,
    this.hygieneAlerts = false,
    this.points = 0,
  });

  final String uid;
  final String role;
  final Doors myDoors;
  final bool acceptsFlags;
  final bool hygieneAlerts;
  final int points;

  /// Builds a member from a `members` table row (snake_case columns).
  factory Member.fromRow(Map<String, dynamic> r) => Member(
        uid: r['user_id'] as String,
        role: (r['role'] as String?) ?? 'member',
        myDoors: Doors.fromMap((r['my_doors'] as Map?)?.cast<String, dynamic>()),
        acceptsFlags: r['accepts_flags'] == true,
        hygieneAlerts: r['hygiene_alerts'] == true,
        points: (r['points'] as num?)?.toInt() ?? 0,
      );
}
