import 'package:flutter/material.dart';

class Difficulty {
  final String id;
  final String name;
  final int workTime;
  final int restTime;
  final int rounds;
  final Color color; // НОВОЕ ПОЛЕ: Цвет сложности

  const Difficulty({
    required this.id,
    required this.name,
    required this.workTime,
    required this.restTime,
    required this.rounds,
    required this.color, // Обязательный параметр
  });
}