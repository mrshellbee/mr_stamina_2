import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  // Метод для воспроизведения звука
  Future<void> play(String fileName) async {
    try {
      // Останавливаем предыдущий звук, если он еще идет (чтобы не было каши)
      await _player.stop(); 
      // audioplayers сам ищет внутри папки assets, но нужно указать путь
      // Source - это путь внутри assets.
      await _player.play(AssetSource('audio/$fileName'));
    } catch (e) {
      print("Ошибка воспроизведения звука: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}