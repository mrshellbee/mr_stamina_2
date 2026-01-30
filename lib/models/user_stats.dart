class UserStats {
  String name;
  String? profilePicturePath;
  // level и exp удалены, они вычисляются
  int strength;
  int endurance;
  int totalWorkouts;
  DateTime? lastWorkoutDate;
  int currentStreak;
  int maxStreak;
  List<String> unlockedAchievementIds;
  List<String> workoutDates;

  // 👇 НОВОЕ ПОЛЕ: Показали ли рейтинг?
  bool isRatingShown;

  UserStats({
    this.name = 'Боец',
    this.profilePicturePath,
    required this.strength,
    required this.endurance,
    required this.totalWorkouts,
    this.lastWorkoutDate,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.unlockedAchievementIds = const [],
    this.workoutDates = const [],
    this.isRatingShown = false, // По умолчанию false
  });

  // --- Геттеры уровней ---
  // Уровень зависит от количества тренировок
  int get level {
    if (totalWorkouts < 12) return 1;
    if (totalWorkouts < 24) return 2;
    if (totalWorkouts < 36) return 3;
    if (totalWorkouts < 50) return 4;
    return 5;
  }

  int get workoutsTargetForNextLevel {
    if (level == 1) return 12;
    if (level == 2) return 24;
    if (level == 3) return 36;
    if (level == 4) return 50;
    return 100;
  }

  int get strengthLevel => (strength / 100).floor() + 1;
  int get strengthProgress => strength % 100;
  int get enduranceLevel => (endurance / 100).floor() + 1;
  int get enduranceProgress => endurance % 100;

  UserStats copyWith({
    String? name,
    String? profilePicturePath,
    int? strength,
    int? endurance,
    int? totalWorkouts,
    DateTime? lastWorkoutDate,
    int? currentStreak,
    int? maxStreak,
    List<String>? unlockedAchievementIds,
    List<String>? workoutDates,
    bool? isRatingShown, // Добавили в copyWith
  }) {
    return UserStats(
      name: name ?? this.name,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      strength: strength ?? this.strength,
      endurance: endurance ?? this.endurance,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      workoutDates: workoutDates ?? this.workoutDates,
      isRatingShown: isRatingShown ?? this.isRatingShown, // Копируем
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profilePicturePath': profilePicturePath,
      'strength': strength,
      'endurance': endurance,
      'totalWorkouts': totalWorkouts,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'unlockedAchievementIds': unlockedAchievementIds,
      'workoutDates': workoutDates,
      'isRatingShown': isRatingShown, // Сохраняем в JSON
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> map) {
    return UserStats(
      name: map['name'] ?? 'Боец',
      profilePicturePath: map['profilePicturePath'],
      strength: map['strength'] ?? 0,
      endurance: map['endurance'] ?? 0,
      totalWorkouts: map['totalWorkouts'] ?? 0,
      lastWorkoutDate: map['lastWorkoutDate'] != null
          ? DateTime.parse(map['lastWorkoutDate'])
          : null,
      currentStreak: map['currentStreak'] ?? 0,
      maxStreak: map['maxStreak'] ?? 0,
      unlockedAchievementIds: List<String>.from(
        map['unlockedAchievementIds'] ?? [],
      ),
      workoutDates: List<String>.from(map['workoutDates'] ?? []),
      isRatingShown: map['isRatingShown'] ?? false, // Загружаем из JSON
    );
  }
}
