import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import 'instruction_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  final List<Difficulty> levels = const [
    Difficulty(
      id: 'novice', 
      name: 'НОВИЧОК', 
      workTime: 20,
      restTime: 10,   
      rounds: 3,
      color: Colors.greenAccent, // Зеленый
    ),
    Difficulty(
      id: 'warrior', 
      name: 'ВОИН', 
      workTime: 20, 
      restTime: 10, 
      rounds: 5,
      color: Colors.orangeAccent, // Оранжевый
    ),
    Difficulty(
      id: 'legend', 
      name: 'ЛЕГЕНДА', 
      workTime: 20,  
      restTime: 10, 
      rounds: 10,
      color: Colors.redAccent, // Красный
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('ВЫБОР УРОВНЯ'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              // Используем цвет сложности для градиента
              gradient: LinearGradient(
                colors: [const Color(0xFF1E1E1E), level.color.withOpacity(0.2)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: level.color.withOpacity(0.3)), // Цветная рамка
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InstructionScreen(difficulty: level),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.name,
                            style: TextStyle(
                              color: level.color, // Цвет названия
                              fontSize: 28, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${level.rounds} раундов",
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          Text(
                            "${level.workTime} сек / ${level.restTime} сек",
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      Icon(Icons.play_circle_fill, color: level.color, size: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}