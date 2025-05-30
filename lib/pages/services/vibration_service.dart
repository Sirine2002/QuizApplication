import 'package:flutter/cupertino.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VibrationService {
  static bool _enabled = true;
  static bool _soundEffectsEnabled = true;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('vibrationEnabled') ?? true;
    _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
  }

  static Future<void> toggleVibration(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', value);
    if (value) await vibrate();
  }

  static Future<void> toggleSoundEffects(bool value) async {
    _soundEffectsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffectsEnabled', value);
  }

  static Future<void> vibrate() async {
    if (_enabled && (await Vibration.hasVibrator() ?? false)) {
      try {
        await Vibration.vibrate(duration: 50);
      } catch (e) {
        debugPrint('Vibration error: $e');
      }
    }
  }

  static bool get vibrationEnabled => _enabled;
  static bool get soundEffectsEnabled => _soundEffectsEnabled;
}