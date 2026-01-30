import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_lib;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_stats.dart';
import '../models/achievements_data.dart';
import '../services/storage_service.dart';

class UserStatsProvider extends ChangeNotifier {
  // Убрали отдельную переменную _isRatingShown, теперь она внутри модели
  // bool _isRatingShown = false;

  // Геттер берем из модели
  bool get isRatingShown => _userStats.isRatingShown;

  UserStats _userStats = UserStats(
    name: 'Боец',
    strength: 0,
    endurance: 0,
    totalWorkouts: 0,
  );

  final StorageService _storageService = StorageService();

  UserStats get userStats => _userStats;

  // --- GOOGLE AUTH ---
  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;

  Future<bool> signInWithGoogle() async {
    try {
      final google_lib.GoogleSignInAccount? googleUser =
          await google_lib.GoogleSignIn().signIn();
      if (googleUser == null) return false;

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

      await _loadFromCloud();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("ОШИБКА ВХОДА: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await google_lib.GoogleSignIn().signOut();
    _firebaseUser = null;
    notifyListeners();
  }

  Future<void> _saveToCloud() async {
    if (_firebaseUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .set({
            'name': _userStats.name,
            'strength': _userStats.strength,
            'endurance': _userStats.endurance,
            'totalWorkouts': _userStats.totalWorkouts,
            'lastWorkoutDate': _userStats.lastWorkoutDate?.toIso8601String(),
            'currentStreak': _userStats.currentStreak,
            'maxStreak': _userStats.maxStreak,
            'workoutDates': _userStats.workoutDates,
            'unlockedAchievementIds': _userStats.unlockedAchievementIds,
            // Берем из модели
            'isRatingShown': _userStats.isRatingShown,
          }, SetOptions(merge: true));

      debugPrint("☁️ ДАННЫЕ СОХРАНЕНЫ!");
    } catch (e) {
      debugPrint("Ошибка сохранения в облако: $e");
    }
  }

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
          _userStats = _userStats.copyWith(
            name: data['name'],
            strength: data['strength'],
            endurance: data['endurance'],
            totalWorkouts: data['totalWorkouts'],
            currentStreak: data['currentStreak'],
            maxStreak: data['maxStreak'],
            lastWorkoutDate: data['lastWorkoutDate'] != null
                ? DateTime.parse(data['lastWorkoutDate'])
                : null,
            workoutDates: data['workoutDates'] != null
                ? List<String>.from(data['workoutDates'])
                : null,
            unlockedAchievementIds: data['unlockedAchievementIds'] != null
                ? List<String>.from(data['unlockedAchievementIds'])
                : null,
            // Загружаем флаг в модель
            isRatingShown: data['isRatingShown'] ?? false,
          );

          await _storageService.saveUserStats(_userStats);
          notifyListeners();
          debugPrint("☁️ ДАННЫЕ ЗАГРУЖЕНЫ");
        }
      } else {
        await _saveToCloud();
      }
    } catch (e) {
      debugPrint("Ошибка загрузки из облака: $e");
    }
  }

  Future<void> loadUserStats() async {
    _userStats = await _storageService.loadUserStats();

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

  // 👇 Изменили тип возврата на Future<List<String>>
  Future<List<String>> completeWorkout(int strength, int endurance) async {
    int newStrength = _userStats.strength + strength;
    int newEndurance = _userStats.endurance + endurance;
    int newTotalWorkouts = _userStats.totalWorkouts + 1;

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

    // Временно сохраняем новые значения, но пока не записываем в _userStats полностью,
    // чтобы корректно проверить условия ачивок

    _userStats = _userStats.copyWith(
      strength: newStrength,
      endurance: newEndurance,
      totalWorkouts: newTotalWorkouts,
      lastWorkoutDate: now,
      currentStreak: newCurrentStreak,
      maxStreak: newMaxStreak,
      workoutDates: updatedHistory,
    );

    final newUnlockedIds = List<String>.from(_userStats.unlockedAchievementIds);
    List<String> justUnlocked = []; // 👇 Сюда будем складывать свежие ачивки

    for (final achievement in AchievementsData.allAchievements) {
      if (newUnlockedIds.contains(achievement.id)) continue;

      bool unlocked = achievement.checkCondition(
        totalWorkouts: newTotalWorkouts,
        currentStreak: newCurrentStreak,
        maxStreak: newMaxStreak,
        level: _userStats.level,
        strength: newStrength,
        endurance: newEndurance,
        totalExp: 0,
      );

      if (unlocked) {
        newUnlockedIds.add(achievement.id);
        justUnlocked.add(achievement.id); // 👇 Запоминаем "свежак"
      }
    }

    _userStats = _userStats.copyWith(unlockedAchievementIds: newUnlockedIds);

    await saveUserStats();
    notifyListeners();

    return justUnlocked; // 👇 Возвращаем список
  }

  // --- ИСПРАВЛЕННЫЙ МЕТОД ---
  // Теперь он меняет модель и сохраняет её
  void markRatingAsShown() {
    _userStats = _userStats.copyWith(isRatingShown: true);
    saveUserStats(); // Сохранит и локально, и в облако
    notifyListeners();
  }

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

  Future<void> resetProgress() async {
    _userStats = UserStats(
      name: _userStats.name,
      profilePicturePath: _userStats.profilePicturePath,
      strength: 0,
      endurance: 0,
      totalWorkouts: 0,
      currentStreak: 0,
      maxStreak: 0,
      unlockedAchievementIds: [],
      workoutDates: [],
      isRatingShown: false, // Сбрасываем флаг при ресете
    );
    await saveUserStats();
    notifyListeners();
  }

  Future<void> saveUserStats() async {
    await _storageService.saveUserStats(_userStats);
    await _saveToCloud();
  }
}
