import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_projet/pages/home.pages.dart';
import 'package:mini_projet/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_projet/pages/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _appNotificationEnabled = true;
  bool _soundsEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'en'; // 'en' pour anglais, 'fr' pour français
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundsEnabled = prefs.getBool('soundsEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      _appNotificationEnabled = prefs.getBool('appNotificationEnabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _changeLanguage(String language) async {
    setState(() {
      _selectedLanguage = language;
    });
    await _saveSetting('language', language);
    // Ici vous pourriez ajouter une logique pour redémarrer l'app ou recharger les traductions
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_selectedLanguage == 'en' ? 'Select Language' : 'Choisir la langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Français'),
                leading: Radio<String>(
                  value: 'fr',
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      _changeLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _vibrate() async {
    if (_vibrationEnabled && (await Vibration.hasVibrator() ?? false)) {
      try {
        await Vibration.vibrate(duration: 50);
      } catch (e) {
        debugPrint('Vibration error: $e');
      }
    }
  }

  Future<bool?> _requestNotificationPermission() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return result;
  }

  Future<void> _scheduleDailyNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'daily_quiz_reminder',
      'Quiz Reminder',
      channelDescription: 'Daily reminder to play quiz',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      _selectedLanguage == 'en'
          ? 'Time to play Quizzo!'
          : 'C\'est l\'heure de jouer à Quizzo!',
      _selectedLanguage == 'en'
          ? 'Test your knowledge and improve your skills!'
          : 'Testez vos connaissances et améliorez vos compétences!',
      _nextInstanceOfTime(21, 0),
      const NotificationDetails(android: androidNotificationDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  void _toggleSetting(String key, bool value) async {
    await _vibrate();
    setState(() {
      switch (key) {
        case 'soundsEnabled':
          _soundsEnabled = value;
          break;
        case 'vibrationEnabled':
          _vibrationEnabled = value;
          break;
        case 'notificationsEnabled':
          _notificationsEnabled = value;
          break;
        case 'appNotificationEnabled':
          _appNotificationEnabled = value;
          if (value) {
            _scheduleDailyNotification();
          } else {
            flutterLocalNotificationsPlugin.cancelAll();
          }
          break;
      }
    });
    await _saveSetting(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    // Textes traduits
    final Map<String, Map<String, String>> translations = {
      'en': {
        'settings': 'Settings',
        'account': 'Account',
        'profile': 'Profile',
        'change_password': 'Change password',
        'preferences': 'Preferences',
        'sounds': 'Sounds',
        'vibration': 'Vibration',
        'dark_mode': 'Dark Mode',
        'notifications': 'Notifications',
        'daily_reminder': 'Daily Reminder',
        'more': 'More',
        'language': 'Language',
        'country': 'Country',
        'logout': 'Logout',
        'select_language': 'Select Language',
      },
      'fr': {
        'settings': 'Paramètres',
        'account': 'Compte',
        'profile': 'Profil',
        'change_password': 'Changer le mot de passe',
        'preferences': 'Préférences',
        'sounds': 'Sons',
        'vibration': 'Vibration',
        'dark_mode': 'Mode sombre',
        'notifications': 'Notifications',
        'daily_reminder': 'Rappel quotidien',
        'more': 'Plus',
        'language': 'Langue',
        'country': 'Pays',
        'logout': 'Déconnexion',
        'select_language': 'Choisir la langue',
      },
    };

    final t = translations[_selectedLanguage] ?? translations['en']!;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          t['settings']!,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () async {
            await _vibrate();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey.shade100,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(t['account']!, [
            _buildListItem(
              t['profile']!,
              Icons.person,
              onTap: () async {
                await _vibrate();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            _buildListItem(t['change_password']!, Icons.lock, onTap: _vibrate),
            _buildListItem("Facebook", Icons.facebook, onTap: _vibrate),
          ], isDarkMode),
          _buildSettingsSection(t['preferences']!, [
            _buildSwitchItem(
              t['sounds']!,
              _soundsEnabled,
                  (v) => _toggleSetting('soundsEnabled', v),
              isDarkMode,
            ),
            _buildSwitchItem(
              t['vibration']!,
              _vibrationEnabled,
                  (v) => _toggleSetting('vibrationEnabled', v),
              isDarkMode,
            ),
            _buildSwitchItem(
              t['dark_mode']!,
              isDarkMode,
                  (value) async {
                await _vibrate();
                await themeService.toggleTheme();
              },
              isDarkMode,
            ),
          ], isDarkMode),
          _buildSettingsSection(t['notifications']!, [
            _buildSwitchItem(
              t['notifications']!,
              _notificationsEnabled,
                  (v) => _toggleSetting('notificationsEnabled', v),
              isDarkMode,
            ),
            _buildSwitchItem(
              t['daily_reminder']!,
              _appNotificationEnabled,
                  (value) async {
                if (value) {
                  final bool? granted = await _requestNotificationPermission();
                  if (granted ?? false) {
                    _toggleSetting('appNotificationEnabled', value);
                  } else {
                    setState(() => _appNotificationEnabled = false);
                  }
                } else {
                  _toggleSetting('appNotificationEnabled', value);
                }
              },
              isDarkMode,
            ),
          ], isDarkMode),
          _buildSettingsSection(t['more']!, [
            _buildListItem(
              t['language']!,
              Icons.language,
              onTap: () async {
                await _vibrate();
                _showLanguageDialog();
              },
            ),
            _buildListItem(t['country']!, Icons.flag, onTap: _vibrate),
          ], isDarkMode),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () async {
                await _vibrate();
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/Quiz",
                      (route) => false,
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t['logout']!,
                    style: TextStyle(color: Colors.grey[200]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        ...items,
        Divider(
          height: 20,
          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildListItem(String title, IconData icon, {VoidCallback? onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkMode ? Colors.lightBlueAccent[100] : Colors.lightBlueAccent,
      ),
      onTap: () async {
        await _vibrate();
        if (onTap != null) onTap();
      },
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged, bool isDarkMode) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      value: value,
      activeColor: Colors.lightBlueAccent,
      inactiveTrackColor: isDarkMode ? Colors.grey[600] : null,
      onChanged: (bool newValue) async {
        await _vibrate();
        onChanged(newValue);
      },
    );
  }
}