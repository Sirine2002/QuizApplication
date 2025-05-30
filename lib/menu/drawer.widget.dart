import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_projet/pages/services/vibration_service.dart';
import 'package:provider/provider.dart';
import 'package:mini_projet/pages/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  final String? username;
  final String? email;

  const CustomDrawer({Key? key, this.username, this.email}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _currentLanguage = 'en';

  // Dictionnaire pour la localisation
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'guest': 'Guest',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
    },
    'fr': {
      'guest': 'Invité',
      'home': 'Accueil',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'logout': 'Déconnexion',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  String _translate(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    return Drawer(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.amber.shade800, Colors.orange.shade800]
                    : [Colors.amber, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(''),
            accountEmail: Text(
              widget.username ?? _translate('guest'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.amber,
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: _translate('home'),
            isDarkMode: isDarkMode,
            onTap: () async {
              await VibrationService.vibrate();
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: _translate('profile'),
            isDarkMode: isDarkMode,
            onTap: () async {
              await VibrationService.vibrate();
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: _translate('settings'),
            isDarkMode: isDarkMode,
            onTap: () async {
              await VibrationService.vibrate();
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          Divider(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            height: 1,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: _translate('logout'),
            isDarkMode: isDarkMode,
            onTap: () async {
              await VibrationService.vibrate();
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/Quiz",
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool isDarkMode,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      onTap: onTap,
      tileColor: isDarkMode ? Colors.grey[850] : Colors.white,
      hoverColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
    );
  }
}