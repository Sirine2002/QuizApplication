import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_projet/menu/drawer.widget.dart';
import 'package:mini_projet/pages/profile.dart';
import 'package:mini_projet/pages/quiz_page.dart';
import 'package:mini_projet/pages/services/vibration_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static String id = "/HomePage";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> entertainmentCategories = [];
  List<String> scienceCategories = [];
  List<String> popularCategories = [];
  Map<String, int> categoryNameToId = {};
  Map<String, Color> categoryColors = {
    'General Knowledge': Colors.blueGrey.shade800,
    'Entertainment': Colors.orangeAccent,
    'Science': Colors.greenAccent,
    'Books': Colors.redAccent,
    'Music': Colors.blueAccent,
    'Film': Colors.purpleAccent,
    'Sports': Colors.amberAccent,
    'Video Games': Colors.deepPurple,
    'Board Games': Colors.cyan,
    'Science: Computers': Colors.teal,
    'Science: Gadgets': Colors.green,
    'Mathematics': Colors.yellow,
    'Geography': Colors.brown,
    'History': Colors.orange,
    'Politics': Colors.blue,
    'Art': Colors.pink,
    'Celebrities': Colors.purple,
    'Animals': Colors.green,
    'Vehicles': Colors.red,
    'Anime & Manga': Colors.blue,
    'Cartoon & Animations': Colors.yellow,
    'Mythology': Colors.indigo,
    'Computers': Colors.teal,
    'Gadgets': Colors.green,
  };

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String? username;
  String selectedCategory = '';
  int? selectedCategoryId;
  String _currentLanguage = 'en'; // 'en' ou 'fr'

  // Dictionnaire pour les traductions
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'hello': 'Hello',
      'lets_test': "Let's test your knowledge",
      'search': 'Search',
      'popular': 'Popular',
      'entertainment': 'Entertainment',
      'science': 'Science',
      'start_quiz': 'Start Quiz',
      'select_category': 'Please select a category to start the quiz',
    },
    'fr': {
      'hello': 'Bonjour',
      'lets_test': "Testons vos connaissances",
      'search': 'Rechercher',
      'popular': 'Populaire',
      'entertainment': 'Divertissement',
      'science': 'Science',
      'start_quiz': 'Commencer le quiz',
      'select_category': 'Veuillez sélectionner une catégorie pour commencer le quiz',
    },
  };

  String _translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    VibrationService.init();
    fetchCategories();
    getUsernameFromFirestore();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> getUsernameFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      username = doc.data()?['username'] ?? "Quizzo";
    });
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> categoryList = data['trivia_categories'];

      for (var category in categoryList) {
        String categoryName = category['name'];
        int categoryId = category['id'];

        categoryNameToId[categoryName] = categoryId;

        if (categoryName.contains('Entertainment')) {
          entertainmentCategories.add(categoryName);
        } else if (categoryName.contains('Science')) {
          scienceCategories.add(categoryName);
        } else {
          popularCategories.add(categoryName);
        }

        if (!categoryColors.containsKey(categoryName)) {
          categoryColors[categoryName] = _getFixedColor(categoryName.contains(':') ? categoryName.split(':')[1].trim() : categoryName);
        }
      }

      setState(() {});
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Color _getFixedColor(String categoryName) {
    switch (categoryName) {
      case 'General Knowledge':
        return Colors.blueGrey.shade800;
      case 'Entertainment':
        return Colors.orangeAccent;
      case 'Science':
        return Colors.greenAccent;
      case 'Books':
        return Colors.redAccent;
      case 'Music':
        return Colors.blueAccent;
      case 'Film':
        return Colors.purpleAccent;
      case 'Sports':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey.shade100,
        drawer: CustomDrawer(
          username: username,
          email: FirebaseAuth.instance.currentUser?.email ?? "quizzo@example.com",
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context, isDarkMode),
              _buildSearchAndTabs(isDarkMode),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCategoryList(popularCategories, isDarkMode),
                    _buildCategoryList(entertainmentCategories, isDarkMode),
                    _buildCategoryList(scienceCategories, isDarkMode),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await VibrationService.vibrate();
                      if (selectedCategory.isNotEmpty && selectedCategoryId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              category: selectedCategory,
                              categoryId: selectedCategoryId!,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_translate('select_category')),
                            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                          ),
                        );
                      }
                    },
                    child: Text(
                      _translate('start_quiz'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.amber,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.amber, size: 30),
                onPressed: () async {
                  await VibrationService.vibrate();
                  Scaffold.of(context).openDrawer();
                }
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_translate('hello')}, ${username ?? 'Guest'}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  _translate('lets_test'),
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.amber,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  await VibrationService.vibrate();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndTabs(bool isDarkMode) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: _translate('search'),
              hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
        TabBar(
          indicatorColor: Colors.lightBlueAccent,
          labelColor: Colors.lightBlueAccent,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: _translate('popular')),
            Tab(text: _translate('entertainment')),
            Tab(text: _translate('science')),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<String> categories, bool isDarkMode) {
    final filteredCategories = categories
        .where((cat) => cat.toLowerCase().contains(searchQuery))
        .toList();

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        String category = filteredCategories[index];
        bool isSelected = selectedCategory == category;

        return InkWell(
          onTap: () async {
            await VibrationService.vibrate();
            setState(() {
              selectedCategory = category;
              selectedCategoryId = categoryNameToId[category];
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? categoryColors[category]?.withOpacity(0.1)
                  : isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? categoryColors[category]!
                    : isDarkMode ? Colors.grey[700]! : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category.contains(':') ? category.split(':')[1].trim() : category),
                  color: categoryColors[category.contains(':') ? category.split(':')[1].trim() : category],
                  size: 32,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.contains(':') ? category.split(':')[1].trim() : category,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'film':
        return Icons.movie;
      case 'music':
        return Icons.music_note;
      case 'video games':
        return Icons.videogame_asset;
      case 'books':
        return Icons.book;
      case 'board games':
        return Icons.extension;
      case 'computers':
        return Icons.computer;
      case 'gadgets':
        return Icons.science;
      case 'mathematics':
        return Icons.calculate;
      case 'geography':
        return Icons.public;
      case 'history':
        return Icons.history_edu;
      case 'politics':
        return Icons.gavel;
      case 'art':
        return Icons.brush;
      case 'celebrities':
        return Icons.star;
      case 'animals':
        return Icons.pets;
      case 'vehicles':
        return Icons.directions_car;
      case 'sports':
        return Icons.sports_soccer;
      case 'anime & manga':
        return Icons.animation;
      case 'cartoon & animations':
        return Icons.tv;
      case 'mythology':
        return Icons.account_balance;
      case 'general knowledge':
        return Icons.lightbulb;
      default:
        return Icons.category;
    }
  }
}