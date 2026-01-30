import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';

class StorageService {
  static const String _userStatsKey = 'user_stats';

  // Сохранение статистики пользователя
  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(stats.toJson());
    await prefs.setString(_userStatsKey, jsonString);
  }

  // Загрузка статистики пользователя
  Future<UserStats> loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userStatsKey);

    // Если данных нет (первый запуск), возвращаем новичка
    if (jsonString == null) {
      return UserStats(
        // level и exp удалены, так как они теперь вычисляются автоматически
        strength: 0,
        endurance: 0,
        totalWorkouts: 0,
        // Остальные поля (имя, стрик) заполнятся значениями по умолчанию из модели
      );
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserStats.fromJson(json);
    } catch (e) {
      // Если файл поврежден, тоже возвращаем новичка
      return UserStats(strength: 0, endurance: 0, totalWorkouts: 0);
    }
  }
}
