import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mini_projet/pages/services/theme_service.dart';

class CompletedQuizPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int correct;
  final int wrong;
  final String? category;
  final int? categoryId;
  final String? difficulty;
  final String? type;
  final int? amount;
  final List<dynamic>? questions;

  const CompletedQuizPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    this.category,
    this.categoryId,
    this.difficulty,
    this.type,
    this.amount,
    this.questions,
  }) : assert(score != null, 'Score cannot be null'),
        assert(totalQuestions != null, 'TotalQuestions cannot be null'),
        assert(correct != null, 'Correct cannot be null'),
        assert(wrong != null, 'Wrong cannot be null');

  @override
  CompletedQuizPageState createState() => CompletedQuizPageState();
}

class CompletedQuizPageState extends State<CompletedQuizPage> {
  late AudioPlayer _audioPlayer;

  // Dictionnaire pour la localisation
  Map<String, Map<String, String>> localizedValues = {
    'en': {
      'quizTitle': 'Quiz',
      'subtitle': 'Great job finishing the quiz!',
      'quizCompleted': 'Quiz Completed!',
      'yourScore': 'Your Score',
      'completed': 'Completed',
      'total': 'Total',
      'correct': 'Correct',
      'wrong': 'Wrong',
      'playAgain': 'Play Again',
      'home': 'Home',
      'scores': 'Scores',
      'errorSound': 'Error playing sound',
      'errorCategory': 'Error: Category not specified',
      'errorUser': 'Error: No user logged in',
      'errorFirestore': 'Error saving score',
      'errorPermission': 'Error: Permission denied. Check Firestore rules.',
      'errorNetwork': 'Error: Network connection issue.',
    },
    'fr': {
      'quizTitle': 'Quiz',
      'subtitle': 'Excellent travail pour avoir terminé le quiz!',
      'quizCompleted': 'Quiz Terminé!',
      'yourScore': 'Votre Score',
      'completed': 'Terminé',
      'total': 'Total',
      'correct': 'Correct',
      'wrong': 'Incorrect',
      'playAgain': 'Rejouer',
      'home': 'Accueil',
      'scores': 'Scores',
      'errorSound': 'Erreur de lecture du son',
      'errorCategory': 'Erreur: Catégorie non spécifiée',
      'errorUser': 'Erreur: Aucun utilisateur connecté',
      'errorFirestore': 'Erreur lors de la sauvegarde du score',
      'errorPermission': 'Erreur: Permission refusée. Vérifiez les règles Firestore.',
      'errorNetwork': 'Erreur: Problème de connexion réseau.',
    },
  };

  String get currentLanguage => 'fr'; // Vous pouvez changer cette valeur ou la récupérer d'un provider

  String _translate(String key) {
    return localizedValues[currentLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playBellSound();
      _saveOrUpdateScoreToFirestore(context);
    });
  }

  Future<void> _playBellSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/done.mp3'));
    } catch (e) {
      debugPrint('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translate('errorSound')),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
        ),
      );
    }
  }

  Future<void> _saveOrUpdateScoreToFirestore(BuildContext context) async {
    try {
      if (widget.category == null || widget.category!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translate('errorCategory')),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
          ),
        );
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_translate('errorUser')),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
          ),
        );
        return;
      }

      final CollectionReference scores = FirebaseFirestore.instance.collection('scores');

      final QuerySnapshot existingScores = await scores
          .where('category', isEqualTo: widget.category)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingScores.docs.isNotEmpty) {
        final docId = existingScores.docs.first.id;
        await scores.doc(docId).update({
          'score': widget.score,
          'totalQuestions': widget.totalQuestions,
          'correct': widget.correct,
          'wrong': widget.wrong,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await scores.add({
          'category': widget.category,
          'userId': userId,
          'score': widget.score,
          'totalQuestions': widget.totalQuestions,
          'correct': widget.correct,
          'wrong': widget.wrong,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      String errorMessage = _translate('errorFirestore');
      if (e.toString().contains('permission-denied')) {
        errorMessage = _translate('errorPermission');
      } else if (e.toString().contains('network')) {
        errorMessage = _translate('errorNetwork');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
        ),
      );
      debugPrint('Firestore error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;

    double completion = 0.0;
    if (widget.totalQuestions == 0) {
      debugPrint('Warning: totalQuestions is 0, setting completion to 0');
      completion = 0.0;
    } else if (widget.correct == null || widget.wrong == null) {
      debugPrint('Warning: correct or wrong is null, setting completion to 0');
      completion = 0.0;
    } else {
      completion = (widget.correct + widget.wrong) / widget.totalQuestions;
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey.shade100,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${_translate('quizTitle')}: ${widget.category ?? 'Unknown'}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    _translate('subtitle'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _translate('quizCompleted'),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Text(
                                _translate('yourScore'),
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${widget.score} pts',
                                style: GoogleFonts.poppins(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildResultItem(_translate('completed'), "${(completion * 100).toInt()}%",
                              Colors.amber, isDarkMode),
                          _buildResultItem(_translate('total'), "${widget.totalQuestions}",
                              isDarkMode ? Colors.white : Colors.black87, isDarkMode),
                          _buildResultItem(_translate('correct'), "${widget.correct}",
                              Colors.green, isDarkMode),
                          _buildResultItem(_translate('wrong'), "${widget.wrong}",
                              Colors.red, isDarkMode),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildActionButton(Icons.replay, _translate('playAgain'), context, isDarkMode),
                          _buildActionButton(Icons.home, _translate('home'), context, isDarkMode),
                          _buildActionButton(Icons.military_tech, _translate('scores'), context, isDarkMode),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color, bool isDarkMode) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, BuildContext context, bool isDarkMode) {
    return InkWell(
      onTap: () {
        if (label == _translate('playAgain')) {
          Navigator.pushNamed(context, '/QuestionPage', arguments: {
            'category': widget.category,
            'categoryId': widget.categoryId,
            'difficulty': widget.difficulty,
            'type': widget.type,
            'amount': widget.amount,
            'questions': widget.questions,
          });
        } else if (label == _translate('home')) {
          Navigator.pushNamed(context, '/HomePage');
        } else if (label == _translate('scores')) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      child: Semantics(
        label: label,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Icon(icon, color: Colors.amber, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: isDarkMode ? Colors.white : Colors.black87
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}