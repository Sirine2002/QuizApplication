import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletedQuizPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int correct;
  final int wrong;
  final String? category;
  final int? categoryId; // Added
  final String? difficulty; // Added
  final String? type; // Added
  final int? amount; // Added

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
  });

  @override
  CompletedQuizPageState createState() => CompletedQuizPageState();
}

class CompletedQuizPageState extends State<CompletedQuizPage> {
  @override
  void initState() {
    super.initState();
    // Sauvegarde automatique du score après le rendu initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveOrUpdateScoreToFirestore(context);
    });
  }

  Future<void> _saveOrUpdateScoreToFirestore(BuildContext context) async {
    try {
      if (widget.category == null || widget.category!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : Catégorie non spécifiée')),
        );
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : Aucun utilisateur connecté')),
        );
        return;
      }

      final CollectionReference scores = FirebaseFirestore.instance.collection('scores');

      // Rechercher un document existant pour la catégorie et l'utilisateur
      final QuerySnapshot existingScores = await scores
          .where('category', isEqualTo: widget.category)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingScores.docs.isNotEmpty) {
        // Mettre à jour le document existant
        final docId = existingScores.docs.first.id;
        await scores.doc(docId).update({
          'score': widget.score,
          'totalQuestions': widget.totalQuestions,
          'correct': widget.correct,
          'wrong': widget.wrong,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Créer un nouveau document
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
      // Message d'erreur plus précis
      String errorMessage = 'Erreur lors de l\'enregistrement du score';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Erreur : Permission refusée. Vérifiez les règles Firestore.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Erreur : Problème de connexion réseau.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      debugPrint('Erreur Firestore : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double completion = widget.totalQuestions == 0 ? 0 : (widget.correct + widget.wrong) / widget.totalQuestions;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Quiz: ${widget.category ?? 'Unknown'}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Great job finishing the quiz!",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        "Quiz Completed!",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                                'Your Score',
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
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
                          _buildResultItem("Completed", "${(completion * 100).toInt()}%", Colors.amber),
                          _buildResultItem("Total", "${widget.totalQuestions}", Colors.black87),
                          _buildResultItem("Correct", "${widget.correct}", Colors.green),
                          _buildResultItem("Wrong", "${widget.wrong}", Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildActionButton(Icons.replay, "Play Again", context),
                          _buildActionButton(Icons.home, "Home", context),
                          _buildActionButton(Icons.military_tech, "Scores", context),
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

  Widget _buildResultItem(String label, String value, Color color) {
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
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == "Play Again") {
          // Navigate to QuestionPage with the same parameters
          Navigator.pushNamed(context, '/QuestionPage', arguments: {
            'category': widget.category,
            'categoryId': widget.categoryId,
            'difficulty': widget.difficulty,
            'type': widget.type,
            'amount': widget.amount,
          });
        } else if (label == "Home") {
          Navigator.pushNamed(context, '/HomePage');
        } else if (label == "Scores") {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Icon(icon, color: Colors.amber, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}