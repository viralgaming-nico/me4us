/// The four doors a person can open at onboarding.
enum Door { kids, thirdPerson, alcohol, lite }

/// One person's doors. Everything is closed unless explicitly opened.
class Doors {
  const Doors([this._open = const {}]);

  static const closed = Doors();

  final Map<Door, bool> _open;

  bool isOpen(Door d) => _open[d] ?? false;

  Doors set(Door d, bool open) => Doors({..._open, d: open});

  factory Doors.fromMap(Map<String, dynamic>? m) => Doors({
        for (final d in Door.values)
          if (m?[d.name] == true) d: true,
      });

  Map<String, bool> toMap() => {for (final d in Door.values) d.name: isOpen(d)};

  /// Effective door = ALL members opted in. No members means nothing is open,
  /// so content is never shown by default.
  static Doors effective(Iterable<Doors> members) {
    final list = members.toList();
    if (list.isEmpty) return closed;
    return Doors({
      for (final d in Door.values)
        if (list.every((m) => m.isOpen(d))) d: true,
    });
  }

  @override
  bool operator ==(Object other) =>
      other is Doors && Door.values.every((d) => isOpen(d) == other.isOpen(d));

  @override
  int get hashCode => Object.hashAll(Door.values.map(isOpen));
}
