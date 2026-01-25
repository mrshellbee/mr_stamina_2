class UserStats {
  String name;
  String? profilePicturePath; // НОВОЕ ПОЛЕ: Путь к фото
  int level;
  int exp;
  int strength;
  int endurance;
  int totalWorkouts;
  DateTime? lastWorkoutDate;
  int currentStreak;
  int maxStreak;
  List<String> unlockedAchievementIds;
  List<String> workoutDates;

  UserStats({
    this.name = 'Боец',
    this.profilePicturePath, // Добавили в конструктор
    required this.level,
    required this.exp,
    required this.strength,
    required this.endurance,
    required this.totalWorkouts,
    this.lastWorkoutDate,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.unlockedAchievementIds = const [],
    this.workoutDates = const [],
  });

  // --- Геттеры уровней ---
  int get strengthLevel => (strength / 100).floor() + 1;
  int get strengthProgress => strength % 100;
  int get enduranceLevel => (endurance / 100).floor() + 1;
  int get enduranceProgress => endurance % 100;
  int get expToNextLevel => level * 100;

  UserStats copyWith({
    String? name,
    String? profilePicturePath, // Добавили
    int? level,
    int? exp,
    int? strength,
    int? endurance,
    int? totalWorkouts,
    DateTime? lastWorkoutDate,
    int? currentStreak,
    int? maxStreak,
    List<String>? unlockedAchievementIds,
    List<String>? workoutDates,
  }) {
    return UserStats(
      name: name ?? this.name,
      profilePicturePath:
          profilePicturePath ?? this.profilePicturePath, // Сохраняем
      level: level ?? this.level,
      exp: exp ?? this.exp,
      strength: strength ?? this.strength,
      endurance: endurance ?? this.endurance,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      workoutDates: workoutDates ?? this.workoutDates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profilePicturePath': profilePicturePath, // Сохраняем в файл
      'level': level,
      'exp': exp,
      'strength': strength,
      'endurance': endurance,
      'totalWorkouts': totalWorkouts,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'unlockedAchievementIds': unlockedAchievementIds,
      'workoutDates': workoutDates,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> map) {
    return UserStats(
      name: map['name'] ?? 'Боец',
      profilePicturePath: map['profilePicturePath'], // Загружаем из файла
      level: map['level'] ?? 1,
      exp: map['exp'] ?? 0,
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
    );
  }
}
