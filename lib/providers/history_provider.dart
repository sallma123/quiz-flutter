import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_record.dart';

/// Provider de la box Hive "history"
/// Permet d’accéder aux données d’historique des quiz
final historyBoxProvider = Provider<Box<HistoryRecord>>((ref) {
  return Hive.box<HistoryRecord>('history');
});

/// Provider interne qui écoute les changements de la box Hive
/// Il sert uniquement à notifier Riverpod lorsque Hive est modifié
final _historyListenableProvider =
Provider<ValueListenable<Box<HistoryRecord>>>((ref) {

  final box = ref.watch(historyBoxProvider);

  // Retourne un objet écoutable lié à la box Hive
  return box.listenable();
});

/// Provider public utilisé par l’interface utilisateur
/// Fournit la liste des quiz joués, mise à jour automatiquement
final historyListProvider = Provider<List<HistoryRecord>>((ref) {

  // Accès à la box Hive
  final box = ref.watch(historyBoxProvider);

  // Écoute les changements pour forcer la reconstruction de l’UI
  ref.watch(_historyListenableProvider);

  // Retourne la liste des historiques du plus récent au plus ancien
  return box.values.toList().reversed.toList();
});
