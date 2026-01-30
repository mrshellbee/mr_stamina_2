import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import 'workout_screen.dart';
import '../widgets/video_widget.dart'; // 1. Импортируем наш плеер

class InstructionScreen extends StatelessWidget {
  final Difficulty difficulty;

  const InstructionScreen({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("ИНСТРУКТАЖ"),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // --- ВСТАВИЛИ ВИДЕО ---
          SizedBox(
            width: double.infinity,
            height: 250, // Высота видео блока
            child: const VideoWidget(
              // Убедись, что файл pushups.mp4 лежит в папке assets/videos/
              videoPath: 'assets/videos/pushups.mp4',
            ),
          ),

          // ----------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Уровень: ${difficulty.name}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStep("1. Положи телефон на пол перед собой."),
                  _buildStep("2. Приготовься, будет 3 секунды на старт."),
                  _buildStep("3. Повторяй движения за видео."),
                  _buildStep(
                    "4. БУДЕМ ДЕЛАТЬ БЁРПИ: 20 СЕКУНД РАБОТЫ, 10 СЕКУНД ОТДЫХА.",
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkoutScreen(difficulty: difficulty),
                          ),
                        );
                      },
                      child: const Text(
                        "НАЧАТЬ ТРЕНИРОВКУ!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.white54, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
