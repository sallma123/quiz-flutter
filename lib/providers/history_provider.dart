import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_record.dart';

/// 1️⃣ Provider de la box Hive
final historyBoxProvider = Provider<Box<HistoryRecord>>((ref) {
  return Hive.box<HistoryRecord>('history');
});

/// 2️⃣ Provider interne qui écoute Hive
final _historyListenableProvider =
Provider<ValueListenable<Box<HistoryRecord>>>((ref) {
  final box = ref.watch(historyBoxProvider);
  return box.listenable();
});

/// 3️⃣ Provider PUBLIC utilisé par l’UI (réactif)
final historyListProvider = Provider<List<HistoryRecord>>((ref) {
  final box = ref.watch(historyBoxProvider);

  // 🔥 IMPORTANT : force Riverpod à rebuild quand Hive change
  ref.watch(_historyListenableProvider);

  return box.values.toList().reversed.toList();
});
