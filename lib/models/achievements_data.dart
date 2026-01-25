class Achievement {
  final String id;
  final String title;
  final String description;
  final int requiredValue;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredValue,
  });

  // Логика проверки условий
  bool checkCondition({
    required int totalWorkouts,
    required int currentStreak,
    required int maxStreak,
    required int level,
    required int strength,     // Добавили для проверки
    required int endurance,    // Добавили для проверки
    required int totalExp,
  }) {
    if (id == 'first_workout') return totalWorkouts >= requiredValue;
    
    // СТРИКИ (Проверяем по максимальному, чтобы ачивка не пропадала при срыве)
    if (id.startsWith('streak_')) return maxStreak >= requiredValue;
    
    // КОЛИЧЕСТВО ТРЕНИРОВОК
    if (id.startsWith('total_')) return totalWorkouts >= requiredValue;

    // УРОВЕНЬ
    if (id.startsWith('level_')) return level >= requiredValue;

    // СИЛА
    if (id.startsWith('strength_')) return strength >= requiredValue;

    // ВЫНОСЛИВОСТЬ
    if (id.startsWith('endurance_')) return endurance >= requiredValue;

    return false;
  }
}

class AchievementsData {
  static List<Achievement> allAchievements = [
    // --- СТАРЫЕ ---
    Achievement(
      id: 'first_workout',
      title: 'Первая Кровь',
      description: 'Завершите свою первую тренировку',
      requiredValue: 1,
    ),
    Achievement(
      id: 'streak_3',
      title: 'Дисциплина',
      description: 'Тренируйтесь 3 дня подряд',
      requiredValue: 3,
    ),
    Achievement(
      id: 'total_10',
      title: 'Боец',
      description: 'Выполните 10 тренировок',
      requiredValue: 10,
    ),
    Achievement(
      id: 'total_50',
      title: 'Ветеран', // Переименовал для красоты
      description: 'Выполните 50 тренировок',
      requiredValue: 50,
    ),

    // --- НОВЫЕ (10 ШТУК) ---
    
    // 1. Стрики
    Achievement(
      id: 'streak_7',
      title: 'Неделя Силы',
      description: 'Тренируйтесь 7 дней подряд без пропусков',
      requiredValue: 7,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Железная Воля',
      description: 'Держите стрик 30 дней. Это уже привычка!',
      requiredValue: 30,
    ),

    // 2. Общее количество
    Achievement(
      id: 'total_100',
      title: 'Центурион',
      description: 'Выполните 100 тренировок',
      requiredValue: 100,
    ),
    Achievement(
      id: 'total_500',
      title: 'Легенда',
      description: 'Выполните 500 тренировок',
      requiredValue: 500,
    ),

    // 3. Уровень (XP)
    Achievement(
      id: 'level_5',
      title: 'Проспект',
      description: 'Достигните 5 уровня персонажа',
      requiredValue: 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Сенсей',
      description: 'Достигните 10 уровня персонажа',
      requiredValue: 10,
    ),

    // 4. Характеристики (Сила)
    Achievement(
      id: 'strength_100',
      title: 'Халк',
      description: 'Наберите 100 очков силы',
      requiredValue: 100,
    ),
    Achievement(
      id: 'strength_500',
      title: 'Титан',
      description: 'Наберите 500 очков силы',
      requiredValue: 500,
    ),

    // 5. Характеристики (Выносливость)
    Achievement(
      id: 'endurance_100',
      title: 'Марафонец',
      description: 'Наберите 100 очков выносливости',
      requiredValue: 100,
    ),
    Achievement(
      id: 'endurance_500',
      title: 'Киборг',
      description: 'Наберите 500 очков выносливости',
      requiredValue: 500,
    ),
  ];
}