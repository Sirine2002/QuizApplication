import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSound(String path) async {
    // Check if sounds are enabled
    final prefs = await SharedPreferences.getInstance();
    final bool soundsEnabled = prefs.getBool('soundsEnabled') ?? true;

    if (!soundsEnabled) {
      print("Sounds are disabled, skipping playback: $path");
      return;
    }

    try {
      print("Attempting to play sound: $path");
      await _audioPlayer.play(AssetSource(path));
      print("Sound played successfully: $path");
    } catch (e) {
      print("Erreur lors de la lecture du son: $e");
    }
  }

  void dispose() {
    print("Disposing AudioService");
    _audioPlayer.dispose();
  }
}