import 'package:flutter/material.dart';

import '../l10n/me_localizations.dart';
import 'me_repository.dart';
import 'models.dart';

String categoryLabel(MeLocalizations l, SelfcareCategory c) => switch (c) {
      SelfcareCategory.basic => l.catBasic,
      SelfcareCategory.periodic => l.catPeriodic,
      SelfcareCategory.meds => l.catMeds,
      SelfcareCategory.nutrition => l.catNutrition,
    };

String cadenceLabel(MeLocalizations l, Cadence c) => switch (c) {
      Cadence.daily => l.cadDaily,
      Cadence.weekly => l.cadWeekly,
      Cadence.monthly => l.cadMonthly,
    };

/// The person's own self-care items: add, edit, hide. Items are never deleted, so past
/// ticks and points keep pointing at them.
class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key, required this.repo});
  final MeRepository repo;

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<SelfcareItem>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final items = await widget.repo.items();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _edit([SelfcareItem? item]) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ItemEditor(repo: widget.repo, item: item),
    ));
    if (changed == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = MeLocalizations.of(context);
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: Text(l.itemsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-item'),
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: Text(l.addItem),
      ),
      body: SafeArea(
        child: _failed
            ? Center(child: TextButton(onPressed: _load, child: Text(l.retry)))
            : items == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      for (final i in items)
                        ListTile(
                          key: Key('edit-${i.id}'),
                          title: Text(i.title,
                              style: i.active ? null : const TextStyle(decoration: TextDecoration.lineThrough)),
                          subtitle: Text(
                              '${categoryLabel(l, i.category)} · ${cadenceLabel(l, i.cadence)} · ${l.pointsPlus(i.pointValue)}'),
                          trailing: const Icon(Icons.edit_outlined),
                          onTap: () => _edit(i),
                        ),
                    ],
                  ),
      ),
    );
  }
}

/// Add or edit one item. Pops `true` after saving.
class ItemEditor extends StatefulWidget {
  const ItemEditor({super.key, required this.repo, this.item});
  final MeRepository repo;
  final SelfcareItem? item;

  @override
  State<ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<ItemEditor> {
  late final _title = TextEditingController(text: widget.item?.title ?? '');
  late var _category = widget.item?.category ?? SelfcareCategory.basic;
  late var _cadence = widget.item?.cadence ?? Cadence.daily;
  late var _points = widget.item?.pointValue ?? 1;
  late var _active = widget.item?.active ?? true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = MeLocalizations.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final existing = widget.item;
      if (existing == null) {
        await widget.repo.addItems([
          SelfcareItem(id: '', title: title, category: _category, cadence: _cadence, pointValue: _points),
        ]);
      } else {
        await widget.repo.updateItem(existing.copyWith(
            title: title, category: _category, cadence: _cadence, pointValue: _points, active: _active));
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _error = l.saveFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = MeLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? l.addItem : l.editItem)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('item-title'),
              controller: _title,
              decoration: InputDecoration(labelText: l.itemTitle),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SelfcareCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l.itemCategory),
              items: [
                for (final c in SelfcareCategory.values)
                  DropdownMenuItem(value: c, child: Text(categoryLabel(l, c))),
              ],
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Cadence>(
              initialValue: _cadence,
              decoration: InputDecoration(labelText: l.itemCadence),
              items: [
                for (final c in Cadence.values) DropdownMenuItem(value: c, child: Text(cadenceLabel(l, c))),
              ],
              onChanged: (c) => setState(() => _cadence = c ?? _cadence),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Text(l.itemPoints)),
              IconButton(
                onPressed: _points > 0 ? () => setState(() => _points--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_points', key: const Key('item-points')),
              IconButton(
                onPressed: _points < 10 ? () => setState(() => _points++) : null,
                icon: const Icon(Icons.add),
              ),
            ]),
            if (widget.item != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.itemActive),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            if (_error != null) Text(_error!),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('item-save'),
              onPressed: _busy ? null : _save,
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
