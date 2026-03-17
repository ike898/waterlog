import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/water_entry.dart';

const _defaultGoalMl = 2000;

final dailyGoalProvider = StateProvider<int>((ref) => _defaultGoalMl);

final waterEntriesProvider =
    AsyncNotifierProvider<WaterEntriesNotifier, List<WaterEntry>>(
        WaterEntriesNotifier.new);

final todayTotalProvider = Provider<int>((ref) {
  final entries = ref.watch(waterEntriesProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return entries
      .where((e) => e.timestamp.isAfter(today))
      .fold(0, (sum, e) => sum + e.amountMl);
});

final todayProgressProvider = Provider<double>((ref) {
  final total = ref.watch(todayTotalProvider);
  final goal = ref.watch(dailyGoalProvider);
  return (total / goal).clamp(0.0, 1.5);
});

final todayEntriesProvider = Provider<List<WaterEntry>>((ref) {
  final entries = ref.watch(waterEntriesProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return entries.where((e) => e.timestamp.isAfter(today)).toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
});

class WaterEntriesNotifier extends AsyncNotifier<List<WaterEntry>> {
  @override
  Future<List<WaterEntry>> build() async => _load();

  Future<io.File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return io.File('${dir.path}/water_entries.json');
  }

  Future<List<WaterEntry>> _load() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString()) as List;
        return json
            .map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _save(List<WaterEntry> entries) async {
    final file = await _file;
    await file
        .writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<void> addEntry(int amountMl, {String? containerName}) async {
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
      containerName: containerName,
    );
    final current = [...(state.valueOrNull ?? []), entry];
    state = AsyncData(current);
    await _save(current);
  }

  Future<void> deleteEntry(String id) async {
    final current =
        (state.valueOrNull ?? []).where((e) => e.id != id).toList();
    state = AsyncData(current);
    await _save(current);
  }
}
