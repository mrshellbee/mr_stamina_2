import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoWidget extends StatefulWidget {
  final String videoPath;
  final bool showControls; // Новый параметр

  const VideoWidget({
    super.key,
    required this.videoPath,
    this.showControls = true, // По умолчанию кнопки есть
  });

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Инициализируем контроллер
      _videoPlayerController = VideoPlayerController.asset(widget.videoPath);
      await _videoPlayerController.initialize();

      // Если экран ушел (юзер нажал назад), не продолжаем
      if (!mounted) return;

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: true,
          looping: true,

          // 👇 ГЛАВНОЕ ИЗМЕНЕНИЕ: Настройка интерфейса
          showControls: widget.showControls,
          showOptions: false, // Убираем троеточие
          allowFullScreen: false, // Запрещаем фулскрин (ломает верстку)
          allowPlaybackSpeedChanging: false,

          // Цвета
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF00E676),
            handleColor: Colors.white,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.white24,
          ),
        );
      });
    } catch (e) {
      debugPrint("Ошибка видео: $e");
    }
  }

  @override
  void dispose() {
    // Важно: сначала пауза, потом удаление
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null &&
        _videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      // Пока грузится - просто черный фон, без спиннера (чтобы не мелькало)
      return Container(color: Colors.black);
    }
  }
}
