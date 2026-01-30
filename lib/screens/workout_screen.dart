import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/difficulty.dart';
import '../providers/user_stats_provider.dart';
import 'result_screen.dart';
import '../services/sound_service.dart';

// --- ГЛАВНЫЙ ЭКРАН ТРЕНИРОВКИ ---
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

  // --- ЛОГИКА ТАЙМЕРА ---
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

  // ЗАВЕРШЕНИЕ (БЕЗ ОПЫТА, ТОЛЬКО СТАТЫ)
  // 👇 Сделали метод асинхронным (async), чтобы подождать результат
  Future<void> _finishWorkout() async {
    _soundService.play('gong.mp3');
    final provider = Provider.of<UserStatsProvider>(context, listen: false);

    final oldStats = provider.userStats;

    int strengthEarned = widget.difficulty.rounds * 2;
    int enduranceEarned = widget.difficulty.rounds * 3;

    // 👇 Ждем список новых ачивок
    List<String> newAchievements = await provider.completeWorkout(
      strengthEarned,
      enduranceEarned,
    );

    if (!mounted) return; // Проверка безопасности

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          strengthEarned: strengthEarned,
          enduranceEarned: enduranceEarned,
          oldTotalWorkouts: oldStats.totalWorkouts,
          oldStrength: oldStats.strength,
          oldEndurance: oldStats.endurance,
          newAchievements: newAchievements, // 👇 Передаем в ResultScreen
        ),
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _showExitDialog() async {
    if (!_isPaused) _togglePause();

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Сдаешься?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Прогресс этой тренировки будет потерян.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "НЕТ",
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "ВЫЙТИ",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
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

    // Определяем, отдых сейчас или нет (для затемнения)
    bool isResting = (_phase == 'Rest' || _phase == 'Prep');

    if (_phase == 'Prep') {
      primaryColor = Colors.amber;
      phaseText = "ГОТОВЬСЯ";
    } else if (_phase == 'Work') {
      primaryColor = widget.difficulty.color;
      phaseText = "РАБОТА";
    } else {
      primaryColor = Colors.blueAccent;
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
          // ВЕРХНЯЯ ЧАСТЬ: ВИДЕО
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. ВИДЕО (Играет всегда)
                  const SimpleVideoPlayer(
                    videoPath: 'assets/videos/pushups.mp4',
                  ),

                  // 2. ЗАТЕМНЕНИЕ (ШТОРКА)
                  // Если отдых или подготовка -> затемняем видео
                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 500,
                    ), // Плавное затемнение
                    color: isResting
                        ? Colors.black.withOpacity(
                            0.85,
                          ) // Сильное затемнение на отдыхе
                        : Colors.transparent, // Прозрачно во время работы
                    child: isResting
                        ? Center(
                            child: Icon(
                              _phase == 'Rest' ? Icons.nights_stay : Icons.bolt,
                              color: Colors.white12,
                              size: 100,
                            ),
                          )
                        : null,
                  ),

                  // 3. ГРАДИЕНТ (Для читаемости текста внизу)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),

                  // 4. ТЕКСТ ФАЗЫ
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      phaseText,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: const [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. СЧЕТЧИК РАУНДОВ
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Раунд $_currentRound / ${widget.difficulty.rounds}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // НИЖНЯЯ ЧАСТЬ: ТАЙМЕР
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
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
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
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
                            icon: const Icon(
                              Icons.pause_circle_filled,
                              color: Colors.white54,
                            ),
                            onPressed: _togglePause,
                          )
                        else
                          Row(
                            children: [
                              IconButton(
                                iconSize: 60,
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.redAccent,
                                ),
                                onPressed: _showExitDialog,
                              ),
                              const SizedBox(width: 30),
                              IconButton(
                                iconSize: 80,
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.greenAccent,
                                ),
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

// --- ОТДЕЛЬНЫЙ ВИДЖЕТ ПЛЕЕРА ---
class SimpleVideoPlayer extends StatefulWidget {
  final String videoPath;
  const SimpleVideoPlayer({super.key, required this.videoPath});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        widget.videoPath,
        // Разрешаем микширование, чтобы таймер не глушил видео
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0.0);
      await _controller.play();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Error loading video: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
