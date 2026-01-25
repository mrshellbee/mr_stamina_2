import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_lib;
import '../models/user_stats.dart';
import '../models/achievements_data.dart';
import '../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Если у тебя были другие импорты (например dart:io), оставь их тоже.
class UserStatsProvider extends ChangeNotifier {
  UserStats _userStats = UserStats(
    name: 'Боец',
    level: 1,
    exp: 0,
    strength: 0,
    endurance: 0,
    totalWorkouts: 0,
  );

  final StorageService _storageService = StorageService();

  UserStats get userStats => _userStats;
  // --- GOOGLE AUTH ---
  User? _firebaseUser; // Тут хранится пользователь Google
  User? get firebaseUser => _firebaseUser;

  // ... (твои переменные _userStats, _storageService и т.д.)

  // 1. ОБНОВЛЕННЫЙ ВХОД (Теперь он еще и загружает данные)
  // Обновленный метод входа: возвращает true, если вход удался
  Future<bool> signInWithGoogle() async {
    try {
      final google_lib.GoogleSignInAccount? googleUser =
          await google_lib.GoogleSignIn().signIn();
      if (googleUser == null) return false; // Пользователь нажал "Отмена"

      final google_lib.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      _firebaseUser = userCredential.user;

      // Ждем, пока данные РЕАЛЬНО скачаются
      await _loadFromCloud();

      notifyListeners();
      return true; // Успех!
    } catch (e) {
      print("ОШИБКА ВХОДА: $e");
      return false; // Ошибка
    }
  }

  // 2. НОВЫЙ МЕТОД: Сохранение в облако
  // 2. ОБНОВЛЕННЫЙ МЕТОД: Сохранение ВСЕГО в облако
  // 2. ИСПРАВЛЕННЫЙ МЕТОД: Сохранение (под твои переменные)
  Future<void> _saveToCloud() async {
    if (_firebaseUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .set({
            // Основные статы
            'name': _userStats.name,
            'level': _userStats.level,
            'exp': _userStats.exp,
            'strength': _userStats.strength,
            'endurance': _userStats.endurance,
            'totalWorkouts': _userStats.totalWorkouts,
            'lastWorkoutDate': _userStats.lastWorkoutDate?.toIso8601String(),

            // 👇 ТВОИ ПЕРЕМЕННЫЕ 👇
            'currentStreak': _userStats.currentStreak,
            'maxStreak': _userStats.maxStreak,
            'workoutDates': _userStats
                .workoutDates, // Это уже список строк, конвертация не нужна
            'unlockedAchievementIds': _userStats.unlockedAchievementIds,
          }, SetOptions(merge: true));

      print("☁️ ДАННЫЕ (включая стрик и ачивки) СОХРАНЕНЫ!");
    } catch (e) {
      print("Ошибка сохранения в облако: $e");
    }
  }

  // 3. ИСПРАВЛЕННЫЙ МЕТОД: Загрузка (под твои переменные)
  Future<void> _loadFromCloud() async {
    if (_firebaseUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // ... (тут твой код распаковки данных: name, level, lists...) ...
          _userStats.name = data['name'] ?? _userStats.name;
          _userStats.level = data['level'] ?? 1;
          _userStats.exp = data['exp'] ?? 0;
          _userStats.strength = data['strength'] ?? 0;
          _userStats.endurance = data['endurance'] ?? 0;
          _userStats.totalWorkouts = data['totalWorkouts'] ?? 0;

          _userStats.currentStreak = data['currentStreak'] ?? 0;
          _userStats.maxStreak = data['maxStreak'] ?? 0;

          if (data['lastWorkoutDate'] != null) {
            _userStats.lastWorkoutDate = DateTime.parse(
              data['lastWorkoutDate'],
            );
          }

          if (data['workoutDates'] != null) {
            _userStats.workoutDates = List<String>.from(data['workoutDates']);
          }

          if (data['unlockedAchievementIds'] != null) {
            _userStats.unlockedAchievementIds = List<String>.from(
              data['unlockedAchievementIds'],
            );
          }

          // 👇👇👇 ДОБАВЬ ВОТ ЭТУ СТРОЧКУ 👇👇👇
          // Сразу сохраняем скачанное в память телефона!
          await _storageService.saveUserStats(_userStats);

          notifyListeners();
          print("☁️ ПОЛНЫЕ ДАННЫЕ ЗАГРУЖЕНЫ И СОХРАНЕНЫ ЛОКАЛЬНО!");
        }
      } else {
        await _saveToCloud();
      }
    } catch (e) {
      print("Ошибка загрузки из облака: $e");
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // 👇 Добавили google_lib.
    await google_lib.GoogleSignIn().signOut();
    _firebaseUser = null;
    notifyListeners();
  }

  // -------------------
  Future<void> loadUserStats() async {
    _userStats = await _storageService.loadUserStats();

    // Проверка стрика
    if (_userStats.lastWorkoutDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final last = DateTime(
        _userStats.lastWorkoutDate!.year,
        _userStats.lastWorkoutDate!.month,
        _userStats.lastWorkoutDate!.day,
      );

      final difference = today.difference(last).inDays;

      if (difference > 1) {
        _userStats = _userStats.copyWith(currentStreak: 0);
        await saveUserStats();
      }
    }
    notifyListeners();
  }

  // --- НОВОЕ: СМЕНА ИМЕНИ ---
  Future<void> updateName(String newName) async {
    _userStats = _userStats.copyWith(name: newName);
    await saveUserStats();
    notifyListeners();
  }

  Future<void> updateProfilePicture(String path) async {
    _userStats = _userStats.copyWith(profilePicturePath: path);
    await saveUserStats();
    notifyListeners();
  }

  // --- НОВОЕ: ПОЛНЫЙ СБРОС ---
  // --- ОБНОВЛЕННЫЙ СБРОС ---
  Future<void> resetProgress() async {
    _userStats = UserStats(
      name: _userStats.name,
      profilePicturePath: _userStats
          .profilePicturePath, // Фото можно оставить или сбросить (тут оставляем)
      level: 1,
      exp: 0,
      strength: 0,
      endurance: 0,
      totalWorkouts: 0,
      currentStreak: 0,
      maxStreak: 0,
      unlockedAchievementIds: [],
      workoutDates: [],
    );
    await saveUserStats();
    notifyListeners();
  }
  // ---------------------------

  Future<void> completeWorkout(int xp, int strength, int endurance) async {
    int newStrength = _userStats.strength + strength;
    int newEndurance = _userStats.endurance + endurance;
    int newTotalWorkouts = _userStats.totalWorkouts + 1;

    int currentExp = _userStats.exp + xp;
    int currentLevel = _userStats.level;
    int expToNextLevel = currentLevel * 100;

    if (currentExp >= expToNextLevel) {
      currentLevel++;
      currentExp = currentExp - expToNextLevel;
    }

    final now = DateTime.now();
    final todayString = now.toIso8601String().split('T')[0];

    bool isSameDay = false;
    if (_userStats.lastWorkoutDate != null) {
      final last = _userStats.lastWorkoutDate!;
      isSameDay =
          (last.year == now.year &&
          last.month == now.month &&
          last.day == now.day);
    }

    int newCurrentStreak = _userStats.currentStreak;
    if (!isSameDay) {
      newCurrentStreak++;
    }

    int newMaxStreak = newCurrentStreak > _userStats.maxStreak
        ? newCurrentStreak
        : _userStats.maxStreak;

    List<String> updatedHistory = List.from(_userStats.workoutDates);
    if (!updatedHistory.contains(todayString)) {
      updatedHistory.add(todayString);
    }

    _userStats = _userStats.copyWith(
      strength: newStrength,
      endurance: newEndurance,
      totalWorkouts: newTotalWorkouts,
      exp: currentExp,
      level: currentLevel,
      lastWorkoutDate: now,
      currentStreak: newCurrentStreak,
      maxStreak: newMaxStreak,
      workoutDates: updatedHistory,
    );

    final newUnlockedIds = List<String>.from(_userStats.unlockedAchievementIds);

    for (final achievement in AchievementsData.allAchievements) {
      if (newUnlockedIds.contains(achievement.id)) continue;

      bool unlocked = achievement.checkCondition(
        totalWorkouts: newTotalWorkouts,
        currentStreak: newCurrentStreak,
        maxStreak: newMaxStreak,
        level: currentLevel,
        // ДОБАВИЛИ ЭТИ ДВА ПАРАМЕТРА:
        strength: newStrength,
        endurance: newEndurance,
        totalExp: currentExp,
      );

      if (unlocked) {
        newUnlockedIds.add(achievement.id);
        // Тут можно будет потом добавить звук получения ачивки
      }
    }

    _userStats = _userStats.copyWith(unlockedAchievementIds: newUnlockedIds);

    await saveUserStats();
    notifyListeners();
  }

  Future<void> saveUserStats() async {
    await _storageService.saveUserStats(_userStats);
    await _saveToCloud();
  }
}
