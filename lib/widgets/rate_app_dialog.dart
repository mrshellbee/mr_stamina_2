import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppDialog extends StatelessWidget {
  const RateAppDialog({super.key});

  // 👇 ЗАМЕНИ НА СВОИ ССЫЛКИ (когда выложишь приложение)
  final String _androidUrl =
      'https://play.google.com/store/apps/details?id=com.mrshellbee.mr_stamina_2';
  final String _iosUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';

  Future<void> _openStore() async {
    final String url = Platform.isIOS ? _iosUrl : _androidUrl;
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Не удалось открыть магазин: $url");
      }
    } catch (e) {
      debugPrint("Ошибка открытия ссылки: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 60),
            const SizedBox(height: 16),

            const Text(
              "Нравится прогресс?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Ты завершил уже больше 4 тренировок! 💪\nЕсли тебе нравится приложение, поддержи нас оценкой. Это поможет нам развиваться!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _openStore();
                  Navigator.pop(context, true); // true = Оценил
                },
                child: const Text(
                  "ПОСТАВИТЬ 5 ЗВЕЗД",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // false = Позже
              },
              child: const Text(
                "Напомнить позже",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
