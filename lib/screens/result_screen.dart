import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_stats_provider.dart';
import '../widgets/celebration_dialog.dart';
import 'dashboard_screen.dart';
import '../services/sound_service.dart';
import '../models/achievements_data.dart';

class ResultScreen extends StatefulWidget {
  final int strengthEarned;
  final int enduranceEarned;

  final int oldTotalWorkouts;
  final int oldStrength;
  final int oldEndurance;

  final List<String> newAchievements;

  const ResultScreen({
    super.key,
    required this.strengthEarned,
    required this.enduranceEarned,
    required this.oldTotalWorkouts,
    required this.oldStrength,
    required this.oldEndurance,
    this.newAchievements = const [],
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSaving = false;

  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _soundService.play('victory.mp3');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _soundService.dispose();
    super.dispose();
  }

  Future<void> _handleFinish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final provider = Provider.of<UserStatsProvider>(context, listen: false);
    final stats = provider.userStats;

    // --- 1. ПРОВЕРКА УРОВНЕЙ ---
    int newMainLevel = stats.level;
    int newStrLevel = stats.strengthLevel;
    int newEndLevel = stats.enduranceLevel;

    int oldMainLevel = _calculateLevel(widget.oldTotalWorkouts);
    int oldStrLevel = (widget.oldStrength / 100).floor() + 1;
    int oldEndLevel = (widget.oldEndurance / 100).floor() + 1;

    bool isMainUp = newMainLevel > oldMainLevel;
    bool isStrUp = newStrLevel > oldStrLevel;
    bool isEndUp = newEndLevel > oldEndLevel;

    String? dialogTitle;
    String? dialogMessage;

    if (isMainUp) {
      dialogTitle = "НОВЫЙ УРОВЕНЬ!";
      dialogMessage = "Ты достиг $newMainLevel уровня! Так держать!";
    } else if (isStrUp) {
      dialogTitle = "СИЛА ВЫРОСЛА!";
      dialogMessage =
          "Твои мышцы стали крепче. Теперь у тебя $newStrLevel уровень силы!";
    } else if (isEndUp) {
      dialogTitle = "ВЫНОСЛИВОСТЬ ВЫРОСЛА!";
      dialogMessage =
          "Дыхание стало глубже. Теперь у тебя $newEndLevel уровень выносливости!";
    }

    if (dialogTitle != null) {
      _soundService.play('levelup.mp3');
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CelebrationDialog(
          title: dialogTitle!,
          message: dialogMessage!,
          buttonText: "УРА!",
        ),
      );
    }

    // --- 2. ПРОВЕРКА НОВЫХ АЧИВОК ---
    if (widget.newAchievements.isNotEmpty) {
      for (String id in widget.newAchievements) {
        final achievement = AchievementsData.allAchievements.firstWhere(
          (a) => a.id == id,
          // 👇 ИСПРАВЛЕНО: Убрали icon/condition, добавили requiredValue
          orElse: () => Achievement(
            id: 'unknown',
            title: 'Достижение',
            description: '',
            requiredValue: 0,
          ),
        );

        _soundService.play('levelup.mp3');

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CelebrationDialog(
            title: "ДОСТИЖЕНИЕ!",
            message:
                "Открыто: ${achievement.title}\n${achievement.description}",
            buttonText: "КРУТО",
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  int _calculateLevel(int workouts) {
    if (workouts < 12) return 1;
    if (workouts < 24) return 2;
    if (workouts < 36) return 3;
    if (workouts < 50) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserStatsProvider>(context, listen: false);
    final stats = provider.userStats;

    int workoutsCurrent = widget.oldTotalWorkouts;
    int workoutsTarget = stats.workoutsTargetForNextLevel;
    int workoutsAdded = 1;

    int strLevel = (widget.oldStrength ~/ 100) + 1;
    int strCurrent = widget.oldStrength % 100;
    int strTarget = 100;

    int endLevel = (widget.oldEndurance ~/ 100) + 1;
    int endCurrent = widget.oldEndurance % 100;
    int endTarget = 100;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.greenAccent,
              ),
              const SizedBox(height: 10),
              const Text(
                "ТРЕНИРОВКА ЗАВЕРШЕНА",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // 1. ШКАЛА ТРЕНИРОВОК
              _buildSimpleStatBar(
                label: "ТРЕНИРОВКИ",
                level: stats.level,
                current: workoutsCurrent,
                max: workoutsTarget,
                added: workoutsAdded,
                icon: Icons.timer,
                gradientColors: [
                  const Color(0xFF2193b0),
                  const Color(0xFF6dd5ed),
                ],
              ),
              const SizedBox(height: 20),

              // 2. СИЛА
              _buildSimpleStatBar(
                label: "СИЛА",
                level: strLevel,
                current: strCurrent,
                max: strTarget,
                added: widget.strengthEarned,
                icon: Icons.fitness_center,
                gradientColors: [
                  const Color(0xFFcb2d3e),
                  const Color(0xFFef473a),
                ],
              ),
              const SizedBox(height: 20),

              // 3. ВЫНОСЛИВОСТЬ
              _buildSimpleStatBar(
                label: "ВЫНОСЛИВОСТЬ",
                level: endLevel,
                current: endCurrent,
                max: endTarget,
                added: widget.enduranceEarned,
                icon: Icons.favorite,
                gradientColors: [
                  const Color(0xFFff9966),
                  const Color(0xFFff5e62),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isSaving ? null : _handleFinish,
                  child: const Text(
                    "ОТЛИЧНО",
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
      ),
    );
  }

  Widget _buildSimpleStatBar({
    required String label,
    required int level,
    required int current,
    required int max,
    required int added,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    double startPercent = current / max;
    double targetPercent = (current + added) / max;
    if (targetPercent > 1.0) targetPercent = 1.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double animatedPercent =
            startPercent + (targetPercent - startPercent) * _controller.value;
        int displayedValue = (current + (added * _controller.value)).toInt();
        if (displayedValue > max) displayedValue = max;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: gradientColors.last, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        "$label",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "+$added",
                    style: TextStyle(
                      color: gradientColors.last,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: animatedPercent > 0 ? animatedPercent : 0.01,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.last.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "$displayedValue / $max",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
