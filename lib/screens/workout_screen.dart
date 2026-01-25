import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/difficulty.dart';
import '../providers/user_stats_provider.dart';
import 'result_screen.dart';
import '../services/sound_service.dart';

class WorkoutScreen extends StatefulWidget {
  final Difficulty difficulty;
  const WorkoutScreen({super.key, required this.difficulty});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late int _remainingTime;
  late int _maxTimeForPhase;
  late int _currentRound;
  
  String _phase = 'Prep'; 
  
  Timer? _timer;
  bool _isPaused = false;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _currentRound = 1;
    _startPrepPhase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundService.dispose();
    super.dispose();
  }

  // --- ЛОГИКА ---

  void _startPrepPhase() {
    setState(() {
      _phase = 'Prep';
      _remainingTime = 3;
      _maxTimeForPhase = 3;
    });
    _startTimer();
  }

  void _startWorkPhase() {
    setState(() {
      _phase = 'Work';
      _remainingTime = widget.difficulty.workTime;
      _maxTimeForPhase = widget.difficulty.workTime;
    });
    _soundService.play('whistle.mp3');
    _startTimer();
  }

  void _startRestPhase() {
    setState(() {
      _phase = 'Rest';
      _remainingTime = widget.difficulty.restTime;
      _maxTimeForPhase = widget.difficulty.restTime;
    });
    _soundService.play('gong.mp3');
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          if (_remainingTime > 0 && _remainingTime <= 3) {
             _soundService.play('beep.mp3');
          }
        } else {
          _timer?.cancel();
          _nextPhase();
        }
      });
    });
  }

  void _nextPhase() {
    if (_phase == 'Prep') {
      _startWorkPhase();
    } else if (_phase == 'Work') {
      if (_currentRound < widget.difficulty.rounds) {
        _startRestPhase();
      } else {
        _finishWorkout();
      }
    } else if (_phase == 'Rest') {
      setState(() {
        _currentRound++;
      });
      _startWorkPhase();
    }
  }

  void _finishWorkout() {
    _soundService.play('gong.mp3');
    final provider = Provider.of<UserStatsProvider>(context, listen: false);
    
    // 1. ЗАПОМИНАЕМ СТАРЫЕ СТАТЫ (ДО НАГРАДЫ)
    final oldStats = provider.userStats;
    
    int xpEarned = widget.difficulty.rounds * 10;
    int strengthEarned = widget.difficulty.rounds * 2;
    int enduranceEarned = widget.difficulty.rounds * 3;

    // 2. НАЧИСЛЯЕМ НОВЫЕ
    provider.completeWorkout(xpEarned, strengthEarned, enduranceEarned);

    // 3. ПЕРЕДАЕМ И СТАРОЕ, И НОВОЕ В ЭКРАН РЕЗУЛЬТАТА
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          xpEarned: xpEarned,
          strengthEarned: strengthEarned,
          enduranceEarned: enduranceEarned,
          oldExp: oldStats.exp,             // Старый опыт
          oldStrength: oldStats.strength,   // Старая сила
          oldEndurance: oldStats.endurance, // Старая выносливость
          oldLevel: oldStats.level,
        ),
      ),
    );
  }

  void _togglePause() {
    setState(() { _isPaused = !_isPaused; });
  }

  Future<void> _showExitDialog() async {
    if (!_isPaused) _togglePause();

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Сдаешься?", style: TextStyle(color: Colors.white)),
        content: const Text("Прогресс этой тренировки будет потерян.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("НЕТ", style: TextStyle(color: Colors.greenAccent))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ВЫЙТИ", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (shouldExit == true) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    String phaseText;
    
    if (_phase == 'Prep') {
      primaryColor = Colors.amber; // Подготовка всегда желтая
      phaseText = "ГОТОВЬСЯ";
    } else if (_phase == 'Work') {
      // ИСПРАВЛЕНИЕ: Цвет зависит от сложности!
      primaryColor = widget.difficulty.color; 
      phaseText = "РАБОТА";
    } else {
      primaryColor = Colors.blueAccent; // Отдых всегда синий
      phaseText = "ОТДЫХ";
    }

    double progress = _remainingTime / _maxTimeForPhase; 
    double scale = 0.6 + (progress * 0.4); 

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _showExitDialog,
        ),
      ),
      extendBodyBehindAppBar: true, 

      body: Column(
        children: [
          // ВИДЕО
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                     'assets/images/burpee_placeholder.png', 
                     fit: BoxFit.cover,
                     errorBuilder: (context, error, stackTrace) => const Center(
                       child: Icon(Icons.videocam_off, color: Colors.white24, size: 50),
                     ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      phaseText,
                      style: TextStyle(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        "Раунд $_currentRound / ${widget.difficulty.rounds}",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ТАЙМЕР
          Expanded(
            flex: 6, 
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                // Тень берет цвет текущей фазы (и сложности)
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 1)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: scale, 
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 8),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "$_remainingTime",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  if (_phase != 'Prep')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isPaused)
                          IconButton(
                            iconSize: 70,
                            icon: const Icon(Icons.pause_circle_filled, color: Colors.white54),
                            onPressed: _togglePause,
                          )
                        else
                          Row(
                            children: [
                              IconButton(
                                iconSize: 60,
                                icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                onPressed: _showExitDialog,
                              ),
                              const SizedBox(width: 30),
                              IconButton(
                                iconSize: 80,
                                icon: const Icon(Icons.play_circle_fill, color: Colors.greenAccent),
                                onPressed: _togglePause,
                              ),
                            ],
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}