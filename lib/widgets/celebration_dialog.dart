import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;

  const CelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    // 👇 Поменяли текст по умолчанию
    this.buttonText = "Идём дальше",
  });

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    // Салют длится 3 секунды
    _controllerCenter = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _controllerCenter.play();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Используем Dialog вместо AlertDialog для полной кастомизации фона
    return Dialog(
      backgroundColor:
          Colors.transparent, // Прозрачный фон, чтобы виден был наш контейнер
      insetPadding: const EdgeInsets.all(20), // Отступы от краев экрана
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Чтобы салют мог вылетать за пределы
        children: [
          // 1. Основной контейнер с ГРАДИЕНТОМ
          Container(
            padding: const EdgeInsets.fromLTRB(
              24,
              48,
              24,
              24,
            ), // Сверху отступ под иконку
            decoration: BoxDecoration(
              // 👇 КРУГОВОЙ ГРАДИЕНТ (от золотого к темному)
              gradient: const RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFF423629), // Темно-золотой/коричневый в центре
                  Color(0xFF121212), // Почти черный по краям
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              // Золотая рамка и свечение
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ужимаемся по содержимому
              children: [
                const SizedBox(height: 20), // Место под иконку
                // ЗАГОЛОВОК
                Text(
                  widget.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD700), // Золотой текст
                    fontWeight: FontWeight.w900, // Жирный
                    fontSize: 26,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // СООБЩЕНИЕ
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4, // Межстрочный интервал
                  ),
                ),
                const SizedBox(height: 30),

                // 👇 ЗОЛОТАЯ КНОПКА
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700), // Золотой фон
                      foregroundColor: Colors.black, // Черный текст
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5, // Тень кнопки
                      shadowColor: Colors.amber.withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      widget.buttonText.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Иконка Кубка (вылезает сверху)
          Positioned(
            top: -40, // Поднимаем над границей
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Свечение позади иконки
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded, // Более округлый кубок
                color: Color(0xFFFFD700),
                size: 80,
              ),
            ),
          ),

          // 3. Взрыв конфетти (поверх всего)
          Positioned(
            top: -20,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.white,
                Color(0xFFFFD700),
              ],
              createParticlePath: drawStar, // Рисуем звездочки
              strokeWidth: 1,
              strokeColor: Colors.white30,
            ),
          ),
        ],
      ),
    );
  }

  // Функция для рисования звездочек (оставляем)
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }
}
