import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_projet/pages/home.pages.dart';
import 'package:mini_projet/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _appNotificationEnabled = true;
  bool _soundsEnabled = true; // New state for sound toggle
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load saved settings on initialization
  }

  // Load saved settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundsEnabled = prefs.getBool('soundsEnabled') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      _appNotificationEnabled = prefs.getBool('appNotificationEnabled') ?? true;
    });
  }

  // Save sound setting to SharedPreferences
  Future<void> _saveSoundSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundsEnabled', value);
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    // Optionally save notification setting
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('notificationsEnabled', value);
    });
  }

  void _toggleAppNotifications(bool value) {
    setState(() {
      _appNotificationEnabled = value;
    });
    // Optionally save app notification setting
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('appNotificationEnabled', value);
    });
  }

  void _toggleSounds(bool value) {
    setState(() {
      _soundsEnabled = value;
    });
    _saveSoundSetting(value); // Save sound setting
  }

  // Function to play sound, respecting the sound setting
  Future<void> playSound(String soundPath) async {
    if (_soundsEnabled) {
      try {
        await _audioPlayer.play(AssetSource(soundPath));
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection("Account", [
            _buildListItem(
              "Profile",
              Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            _buildListItem("Change password", Icons.lock),
            _buildListItem("Facebook", Icons.facebook),
          ]),
          _buildSettingsSection("Notifications", [
            _buildSwitchItem("Notifications", _notificationsEnabled, _toggleNotifications),
            _buildSwitchItem("App notification", _appNotificationEnabled, _toggleAppNotifications),
            _buildSwitchItem("Sounds", _soundsEnabled, _toggleSounds), // New sound toggle
          ]),
          _buildSettingsSection("More", [
            _buildListItem("Language", Icons.language),
            _buildListItem("Country", Icons.flag),
          ]),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () async {
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
                    "Logout",
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

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...items,
        const Divider(),
      ],
    );
  }

  Widget _buildListItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.lightBlueAccent),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSwitchItem(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins()),
      value: value,
      activeColor: Colors.lightBlueAccent,
      onChanged: onChanged,
    );
  }
}