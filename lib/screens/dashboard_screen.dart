import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_stats_provider.dart';
import 'level_selection_screen.dart';
import 'achievements_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'dart:io';
import '../widgets/rate_app_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// 👇 ВСЯ ЛОГИКА ДОЛЖНА БЫТЬ ВНУТРИ ЭТОГО КЛАССА (State)
class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Ждем построения экрана и проверяем условие
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRatingCondition();
    });
  }

  void _checkRatingCondition() {
    final provider = Provider.of<UserStatsProvider>(context, listen: false);

    // Условие:
    // 1. Тренировок >= 4
    // 2. Мы еще НЕ показывали диалог
    if (provider.userStats.totalWorkouts >= 4 && !provider.isRatingShown) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const RateAppDialog(),
      ).then((userResult) {
        if (userResult == true) {
          provider.markRatingAsShown();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStatsProvider>(
      builder: (context, provider, child) {
        final stats = provider.userStats;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            title: const Text(
              'Mr.Stamina 2.0',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: stats.currentStreak > 0
                        ? Colors.orange
                        : Colors.grey,
                  ),
                  Text(
                    '${stats.currentStreak} ДН.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.cyanAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_events, color: Colors.amber),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Аватар и Имя
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // --- АВАТАР ---
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        // Если есть фото - показываем, нет - иконка
                        backgroundImage: stats.profilePicturePath != null
                            ? FileImage(File(stats.profilePicturePath!))
                            : null,
                        child: stats.profilePicturePath == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      // --------------,
                      const SizedBox(height: 10),
                      Text(
                        stats.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Боец ${stats.level} уровня",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- НОВЫЕ ГРАДИЕНТНЫЕ ШКАЛЫ ---

                // 1. ОПЫТ (Голубой)
                _buildGradientStatBar(
                  label: "ОПЫТ",
                  level: stats.level,
                  current: stats.exp,
                  max: stats.expToNextLevel,
                  icon: Icons.star,
                  colors: [
                    const Color(0xFF2193b0),
                    const Color(0xFF6dd5ed),
                  ], // Голубой градиент
                ),

                const SizedBox(height: 16),

                // 2. СИЛА (Красный)
                _buildGradientStatBar(
                  label: "СИЛА",
                  level: stats.strengthLevel,
                  current: stats.strengthProgress,
                  max: 100,
                  icon: Icons.fitness_center,
                  colors: [
                    const Color(0xFFcb2d3e),
                    const Color(0xFFef473a),
                  ], // Красный градиент
                ),

                const SizedBox(height: 16),

                // 3. ВЫНОСЛИВОСТЬ (Оранжевый)
                _buildGradientStatBar(
                  label: "ВЫНОСЛИВОСТЬ",
                  level: stats.enduranceLevel,
                  current: stats.enduranceProgress,
                  max: 100,
                  icon: Icons.favorite,
                  colors: [
                    const Color(0xFFff9966),
                    const Color(0xFFff5e62),
                  ], // Оранжевый градиент
                ),

                const SizedBox(height: 40),

                // Кнопка В БОЙ
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LevelSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "В БОЙ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Виджет для рисования красивой полоски
  Widget _buildGradientStatBar({
    required String label,
    required int level,
    required int current,
    required int max,
    required IconData icon,
    required List<Color> colors,
  }) {
    double progress = current / max;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: colors.last, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "$label (Ур. $level)",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "$current / $max",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: colors.last.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
