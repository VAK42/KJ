import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/kanjiData.dart';
import '../models/kanjiModel.dart';
final searchQueryProvider = StateProvider<String>((ref) => '');
final viewModeProvider = StateProvider<bool>((ref) => true);
final filteredKanjiProvider = Provider.family<AsyncValue<List<KanjiModel>>, String>((ref, level) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return ref.watch(kanjiByLevelProvider(level)).whenData((list) {
    if (query.isEmpty) return list;
    return list.where((k) =>
      k.character.contains(query) ||
      k.meanings.any((m) => m.toLowerCase().contains(query)) ||
      k.onReadings.any((r) => r.toLowerCase().contains(query)) ||
      k.kunReadings.any((r) => r.toLowerCase().contains(query))
    ).toList();
  });
});