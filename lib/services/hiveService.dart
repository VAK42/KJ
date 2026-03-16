import 'package:hive_flutter/hive_flutter.dart';
import '../appConfig.dart';
class HiveService {
  HiveService._();
  static Future<void> openBoxes() async {
    await Hive.openBox<Map>(AppConfig.hiveBoxQuiz);
    await Hive.openBox<Map>(AppConfig.hiveBoxStreak);
    await Hive.openBox(AppConfig.hiveBoxPrefs);
  }
  static Box get quizBox => Hive.box<Map>(AppConfig.hiveBoxQuiz);
  static Box get streakBox => Hive.box<Map>(AppConfig.hiveBoxStreak);
  static Box get prefsBox => Hive.box(AppConfig.hiveBoxPrefs);
  static Future<void> saveQuizResult(String level, int score, int total) async {
    await quizBox.add({'level': level, 'score': score, 'total': total, 'date': DateTime.now().toIso8601String()});
  }
  static List<Map> getQuizResults() => quizBox.values.cast<Map>().toList();
  static Future<void> clearAll() async {
    await quizBox.clear();
    await streakBox.clear();
    await prefsBox.clear();
  }
}