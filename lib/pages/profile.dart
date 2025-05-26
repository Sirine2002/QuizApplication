import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_projet/pages/home.pages.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? username = "Loading...";
  String? email = "Loading...";
  bool _showHistory = false; // Contrôle l'affichage de la section historique

  // Map des couleurs par catégorie
  static const Map<String, Color> categoryColors = {
    'General Knowledge': Colors.blueGrey,
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

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          username = doc.data()?['username'] ?? "Utilisateur inconnu";
          email = doc.data()?['email'] ?? "email@exemple.com";
        });
      }
    }
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
      case 'science: computers':
        return Icons.computer;
      case 'gadgets':
      case 'science: gadgets':
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

  Color _getCategoryColor(String categoryName) {
    return categoryColors[categoryName] ?? categoryColors[categoryName.split(':').first.trim()] ?? Colors.grey;
  }

  Widget buildCategoryCard(String title, int correct, int totalQuestions, IconData icon, Color color, {String? timestamp}) {
    // Calcul du pourcentage : (nombre de réponses correctes / total des questions) * 100
    double scorePercent = totalQuestions > 0 ? (correct / totalQuestions) * 100 : 0;
    int scorePercentRounded = scorePercent.round(); // Arrondi pour l'affichage

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Cercle autour de l'icône
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 24, color: color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('$correct / $totalQuestions', style: const TextStyle(color: Colors.grey)),
                  if (timestamp != null)
                    Text(
                      'Date: $timestamp',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            CircularPercentIndicator(
              radius: 30.0,
              lineWidth: 8.0,
              percent: scorePercent / 100, // Pourcentage pour l'indicateur
              center: Text(
                "$scorePercentRounded%",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
              progressColor: color,
              backgroundColor: color.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // En-tête
          Container(
            height: 230,
            decoration: const BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                // Bouton retour
                Positioned(
                  top: 30,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    ),
                  ),
                ),
                // Contenu centré : avatar + nom + email
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 70), // Move the avatar down by 10 pixels
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 45, color: Colors.lightBlueAccent),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        username ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bouton pour afficher/masquer l'historique
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "History",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Liste des scores dynamiques depuis Firestore
          Expanded(
            child: uid == null
                ? const Center(child: Text('Veuillez vous connecter'))
                : _showHistory
                ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scores')
                  .where('userId', isEqualTo: uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('Erreur Firestore: ${snapshot.error}');
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No history found'));
                }

                final scores = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final scoreData = scores[index].data() as Map<String, dynamic>;
                    final category = scoreData['category'] as String;
                    final correct = scoreData['correct'] as int;
                    final totalQuestions = scoreData['totalQuestions'] as int;
                    final timestamp = (scoreData['timestamp'] as Timestamp?)?.toDate();
                    final formattedTimestamp = timestamp != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp)
                        : 'Inconnu';

                    return buildCategoryCard(
                      category,
                      correct,
                      totalQuestions,
                      _getCategoryIcon(category),
                      _getCategoryColor(category),
                      timestamp: formattedTimestamp,
                    );
                  },
                );
              },
            )
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scores')
                  .where('userId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint('Erreur Firestore: ${snapshot.error}');
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No score found'));
                }

                // Regrouper les scores par catégorie et garder le plus récent
                final scores = snapshot.data!.docs;
                final Map<String, Map<String, dynamic>> latestScores = {};
                for (var doc in scores) {
                  final data = doc.data() as Map<String, dynamic>;
                  final category = data['category'] as String;
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                  if (!latestScores.containsKey(category) ||
                      (timestamp != null &&
                          timestamp.isAfter((latestScores[category]!['timestamp'] as DateTime?) ?? DateTime(0)))) {
                    latestScores[category] = {
                      'correct': data['correct'] as int,
                      'totalQuestions': data['totalQuestions'] as int,
                      'timestamp': timestamp,
                    };
                  }
                }

                return ListView.builder(
                  itemCount: latestScores.length,
                  itemBuilder: (context, index) {
                    final category = latestScores.keys.elementAt(index);
                    final scoreData = latestScores[category]!;
                    final correct = scoreData['correct'] as int;
                    final totalQuestions = scoreData['totalQuestions'] as int;

                    return buildCategoryCard(
                      category,
                      correct,
                      totalQuestions,
                      _getCategoryIcon(category),
                      _getCategoryColor(category),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}