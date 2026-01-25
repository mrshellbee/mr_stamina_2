import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_stats_provider.dart';
import '../models/achievements_data.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ЗАЛ СЛАВЫ'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Consumer<UserStatsProvider>(
        builder: (context, provider, child) {
          final userStats = provider.userStats; 
          final achievements = AchievementsData.allAchievements;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final isUnlocked = userStats.unlockedAchievementIds.contains(achievement.id);

              return Card(
                // Цвет фона: Открыто = темно-зеленый, Закрыто = почти прозрачный
                color: isUnlocked ? const Color(0xFF1B5E20).withOpacity(0.8) : const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isUnlocked ? const Color(0xFF00E676) : Colors.white10, 
                    width: isUnlocked ? 2 : 1
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked ? Colors.black26 : Colors.transparent,
                    ),
                    child: Icon(
                      // Если открыто - показываем тематическую иконку, если нет - замок
                      isUnlocked ? _getIconForAchievement(achievement.id) : Icons.lock,
                      color: isUnlocked ? _getColorForAchievement(achievement.id) : Colors.grey[700], 
                      size: 32,
                    ),
                  ),
                  title: Text(
                    achievement.title,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      // ТЕПЕРЬ ПОКАЗЫВАЕМ ОПИСАНИЕ ВСЕГДА (вместо ???)
                      achievement.description,
                      style: TextStyle(
                        color: isUnlocked ? Colors.white70 : Colors.white24, // Если закрыто - очень тусклый текст
                        fontStyle: isUnlocked ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),
                  trailing: isUnlocked 
                      ? const Icon(Icons.check_circle, color: Color(0xFF00E676))
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Временная функция для выбора иконок (пока ты не нарисовал свои)
  IconData _getIconForAchievement(String id) {
    if (id.startsWith('streak')) return Icons.local_fire_department;
    if (id.startsWith('strength')) return Icons.fitness_center;
    if (id.startsWith('endurance')) return Icons.favorite;
    if (id.startsWith('level')) return Icons.military_tech;
    if (id == 'first_workout') return Icons.star;
    return Icons.emoji_events; // Дефолтный кубок
  }

  // Временная функция для цветов иконок
  Color _getColorForAchievement(String id) {
    if (id.startsWith('streak')) return Colors.orange;
    if (id.startsWith('strength')) return Colors.redAccent;
    if (id.startsWith('endurance')) return Colors.blueAccent;
    if (id.startsWith('level')) return Colors.purpleAccent;
    return Colors.amber;
  }
}