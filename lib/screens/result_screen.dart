import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_stats_provider.dart';
import '../widgets/celebration_dialog.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final int xpEarned;
  final int strengthEarned;
  final int enduranceEarned;

  // Старые показатели
  final int oldExp;
  final int oldStrength;
  final int oldEndurance;
  final int oldLevel;

  const ResultScreen({
    super.key,
    required this.xpEarned,
    required this.strengthEarned,
    required this.enduranceEarned,
    required this.oldExp,
    required this.oldStrength,
    required this.oldEndurance,
    required this.oldLevel,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleFinish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final provider = Provider.of<UserStatsProvider>(context, listen: false);

    // 1. Сохраняем
    await provider.completeWorkout(
      widget.xpEarned,
      widget.strengthEarned,
      widget.enduranceEarned,
    );

    if (!mounted) return;

    // 2. Проверяем рост уровней для поздравления
    int newLevel = provider.userStats.level;
    int newStrength = provider.userStats.strength;
    int newEndurance = provider.userStats.endurance;

    bool isMainLevelUp = newLevel > widget.oldLevel;
    bool isStrengthUp = (widget.oldStrength ~/ 100) < (newStrength ~/ 100);
    bool isEnduranceUp = (widget.oldEndurance ~/ 100) < (newEndurance ~/ 100);

    // 3. Текст поздравления
    String title = "ОТЛИЧНАЯ РАБОТА!";
    String message = "Тренировка завершена успешно.";

    if (isMainLevelUp) {
      title = "НОВЫЙ УРОВЕНЬ!";
      message = "Ты перешел на новый этап развития (Уровень $newLevel)!";
    } else if (isStrengthUp) {
      title = "РОСТ СИЛЫ!";
      message = "Твои мышцы стали крепче. Новый уровень силы!";
    } else if (isEnduranceUp) {
      title = "РОСТ ВЫНОСЛИВОСТИ!";
      message = "Твое дыхание стало глубже. Новый уровень выносливости!";
    }

    // 4. Праздник, если есть повод
    if (isMainLevelUp || isStrengthUp || isEnduranceUp) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CelebrationDialog(
          title: title,
          message: message,
          buttonText: "ИДЁМ ДАЛЬШЕ",
        ),
      );
    }

    // 5. Выход
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- ПОДГОТОВКА ДАННЫХ (Приводим к виду как на Дашборде) ---

    // 1. ОПЫТ (Он сбрасывается, но цель растет: 100, 200, 300...)
    int xpLevel = widget.oldLevel;
    int xpTarget = xpLevel * 100;
    int xpCurrent = widget.oldExp;
    // Если xpCurrent > xpTarget (из-за бага), ограничиваем визуально, но вообще логика provider должна была сбросить

    // 2. СИЛА (Копится вечно, уровень каждые 100)
    int strLevel = (widget.oldStrength ~/ 100) + 1;
    int strCurrent =
        widget.oldStrength % 100; // Остаток от деления на 100 (например, 70)
    int strTarget = 100;

    // 3. ВЫНОСЛИВОСТЬ (Аналогично)
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
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 10),
              const Text(
                "ТРЕНИРОВКА ЗАВЕРШЕНА",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Отличный прогресс!",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // 1. ОПЫТ
              _buildSimpleStatBar(
                label: "ОПЫТ",
                level: xpLevel,
                current: xpCurrent,
                max: xpTarget,
                added: widget.xpEarned,
                icon: Icons.star,
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
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "ЗАВЕРШИТЬ И СОХРАНИТЬ",
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

  // 👇 Упрощенный, но красивый виджет
  // Он просто рисует "Было + Добавили / Максимум"
  Widget _buildSimpleStatBar({
    required String label,
    required int level,
    required int current,
    required int max,
    required int added,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    // Рассчитываем проценты для анимации
    double startPercent = current / max;
    // Если уровень повышается (current + added > max), мы просто заполняем до конца (1.0)
    double targetPercent = (current + added) / max;
    if (targetPercent > 1.0) targetPercent = 1.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Анимированное значение от start до target
        double animatedPercent =
            startPercent + (targetPercent - startPercent) * _controller.value;
        // Текущее число (для текста)
        int displayedValue = (current + (added * _controller.value)).toInt();
        // Если переполнили бар, показываем Максимум (чтобы не было 105/100)
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
                        "$label (Ур. $level)",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Зеленый плюсик справа
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

              // Прогресс бар
              Stack(
                children: [
                  // Серый фон
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Старое значение (полупрозрачное)
                  FractionallySizedBox(
                    widthFactor: startPercent > 0 ? startPercent : 0.01,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: gradientColors.first.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Анимированное заполнение (яркое)
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
              // Текст снизу (240 / 400)
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
