import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hiveService.dart';
import '../services/streakService.dart';
import '../models/quizResultModel.dart';
final dashboardProvider = Provider<DashboardData>((ref) {
  final raw = HiveService.getQuizResults();
  final results = raw.map((r) => QuizResultModel.fromJson(Map<String, dynamic>.from(r))).toList();
  return DashboardData(
    currentStreak: StreakService.currentStreak,
    longestStreak: StreakService.longestStreak,
    studyDates: StreakService.getStudyDates(),
    quizResults: results,
  );
});
class DashboardData {
  final int currentStreak;
  final int longestStreak;
  final List<String> studyDates;
  final List<QuizResultModel> quizResults;
  const DashboardData({
    required this.currentStreak,
    required this.longestStreak,
    required this.studyDates,
    required this.quizResults,
  });
}