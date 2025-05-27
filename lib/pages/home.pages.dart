import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_projet/menu/drawer.widget.dart';
import 'package:mini_projet/pages/profile.dart';
import 'package:mini_projet/pages/quiz_page.dart';


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

  @override
  void initState() {
    super.initState();
    fetchCategories();
    getUsernameFromFirestore();

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
        String categoryName = category['name']; // nom complet avec :
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
          categoryColors[categoryName] = _getFixedColor( categoryName.contains(':') ? categoryName.split(':')[1].trim() : categoryName);
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        drawer: CustomDrawer(
          username: username,
          email: FirebaseAuth.instance.currentUser?.email ?? "quizzo@example.com",
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              _buildSearchAndTabs(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCategoryList(popularCategories),
                    _buildCategoryList(entertainmentCategories),
                    _buildCategoryList(scienceCategories),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedCategory.isNotEmpty && selectedCategoryId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              category: selectedCategory, // nom complet ex: "Science: Computers"
                              categoryId: selectedCategoryId!,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a category to start the quiz")),
                        );
                      }
                    },
                    child: Text(
                      "Start Quiz",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
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

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.amber, size: 30),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello, ${username ?? 'Guest'}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                Text(
                  "Let's test your knowledge",
                  style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.amber,
            child: MouseRegion(
              cursor: SystemMouseCursors.click, // Curseur "main"
              child: GestureDetector(
                onTap: () {
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

  Widget _buildSearchAndTabs() {
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
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        TabBar(
          indicatorColor: Colors.lightBlueAccent,
          labelColor: Colors.lightBlueAccent,
          unselectedLabelColor: Colors.black54,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Popular'),
            Tab(text: 'Entertainment'),
            Tab(text: 'Science'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<String> categories) {
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
          onTap: () {
            setState(() {
              selectedCategory = category;
              selectedCategoryId = categoryNameToId[category];
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? categoryColors[category]?.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? categoryColors[category]! : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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
                      color: Colors.black87,
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
