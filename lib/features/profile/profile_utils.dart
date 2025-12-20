import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../../models/history_record.dart';

/// =====================
/// HASH PASSWORD
/// =====================
String hashPassword(String password, String userId) {
  final bytes = utf8.encode(userId + password);
  return sha256.convert(bytes).toString();
}

/// =====================
/// PROFILE STATS MODEL
/// (optionnel mais propre)
/// =====================
class ProfileStats {
  final int totalQuiz;
  final int totalScore;
  final int totalQuestions;
  final int percent;
  final int level;
  final double progress;

  ProfileStats({
    required this.totalQuiz,
    required this.totalScore,
    required this.totalQuestions,
    required this.percent,
    required this.level,
    required this.progress,
  });
}

/// =====================
/// CALCULATE PROFILE STATS
/// =====================
ProfileStats calculateProfileStats(List<HistoryRecord> history) {
  final totalQuiz = history.length;

  final totalScore =
  history.fold<int>(0, (sum, h) => sum + h.score);

  final totalQuestions =
  history.fold<int>(0, (sum, h) => sum + h.totalQuestions);

  final percent = totalQuestions == 0
      ? 0
      : ((totalScore / (totalQuestions * 10)) * 100).round();

  // LEVEL
  int level = 1;
  if (totalScore >= 700) {
    level = 4;
  } else if (totalScore >= 300) {
    level = 3;
  } else if (totalScore >= 100) {
    level = 2;
  }

  final levelSteps = [0, 100, 300, 700, 1200];
  final progress = level == 4
      ? 1.0
      : (totalScore - levelSteps[level - 1]) /
      (levelSteps[level] - levelSteps[level - 1]);

  return ProfileStats(
    totalQuiz: totalQuiz,
    totalScore: totalScore,
    totalQuestions: totalQuestions,
    percent: percent,
    level: level,
    progress: progress.clamp(0.0, 1.0),
  );
}

/// =====================
/// SHOW SNACKBAR
/// =====================
void showProfileSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}
/// =====================
/// ADVICE HELPER
/// =====================
String buildProfileAdvice({
  required int totalQuiz,
  required int percent,
}) {
  if (totalQuiz == 0) {
    return "Commence par jouer ton premier quiz pour débloquer l'analyse.";
  }
  if (percent >= 80) {
    return "Excellent niveau ! Essaie des catégories plus difficiles.";
  }
  if (percent >= 50) {
    return "Bon travail. Concentre-toi sur tes catégories les plus faibles.";
  }
  return "Prends ton temps, relis les réponses et rejoue régulièrement.";
}