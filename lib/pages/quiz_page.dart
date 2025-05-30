import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_projet/pages/profile.dart';
import 'package:mini_projet/pages/services/vibration_service.dart';
import 'package:provider/provider.dart';

class QuizPage extends StatefulWidget {
  final String category;
  final int categoryId;

  QuizPage({required this.category, required this.categoryId});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String selectedDifficulty = 'easy';
  String selectedType = 'multiple';
  int selectedNumber = 10;

  final List<String> difficulties = ['hard', 'medium', 'easy'];
  final List<String> types = ['boolean', 'multiple'];
  final List<int> questionCounts = [5, 10, 15, 20];

  // Dictionnaire pour la localisation
  Map<String, Map<String, String>> localizedValues = {
    'en': {
      'quizTitle': 'Quiz',
      'subtitle': "Let's test your knowledge",
      'quizZone': 'Quiz zone',
      'difficulty': 'Choose difficulty mode:',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'questionType': 'Choose the Type of questions:',
      'boolean': 'True/false',
      'multiple': 'Multiple Choice',
      'questionNumber': 'Choose the Number of questions:',
      'startQuiz': 'Start Quiz',
    },
    'fr': {
      'quizTitle': 'Quiz',
      'subtitle': 'Testons vos connaissances',
      'quizZone': 'Zone de quiz',
      'difficulty': 'Choisissez le niveau de difficulté:',
      'easy': 'Facile',
      'medium': 'Moyen',
      'hard': 'Difficile',
      'questionType': 'Choisissez le type de questions:',
      'boolean': 'Vrai/faux',
      'multiple': 'Choix multiple',
      'questionNumber': 'Choisissez le nombre de questions:',
      'startQuiz': 'Commencer le quiz',
    },
  };

  String get currentLanguage => 'fr'; // Vous pouvez changer cette valeur ou la récupérer d'un provider

  String _translate(String key) {
    return localizedValues[currentLanguage]?[key] ?? key;
  }

  String _translateDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return _translate('easy');
      case 'medium':
        return _translate('medium');
      case 'hard':
        return _translate('hard');
      default:
        return difficulty;
    }
  }

  void _startQuiz() {
    Navigator.pushNamed(context, "/QuestionPage", arguments: {
      'category': widget.category,
      'categoryId': widget.categoryId,
      'difficulty': selectedDifficulty,
      'type': selectedType,
      'amount': selectedNumber,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final amber = Colors.amber;
    final lightBlue = Colors.lightBlueAccent;
    final bgColor = isDarkMode ? Colors.grey[900] : Colors.grey.shade100;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () async {
            await VibrationService.vibrate();
            Navigator.pushNamedAndRemoveUntil(context, '/HomePage', (route) => false);
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${_translate('quizTitle')}: ${widget.category}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  Text(
                    _translate('subtitle'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: secondaryTextColor,
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
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _translate('quizZone'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Difficulty Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: lightBlue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        _translate('difficulty'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: difficulties.map((diff) {
                      final isSelected = selectedDifficulty == diff;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () async {
                              await VibrationService.vibrate();
                              setState(() => selectedDifficulty = diff);
                            },
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? amber
                                    : isDarkMode ? Colors.grey[700] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _translateDifficulty(diff),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Question Type Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.question_answer, color: lightBlue, size: 24),
                      SizedBox(width: 8),
                      Text(
                        _translate('questionType'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: types.map((type) {
                      final isSelected = selectedType == type;
                      final label = type == 'boolean' ? _translate('boolean') : _translate('multiple');
                      return GestureDetector(
                        onTap: () async {
                          await VibrationService.vibrate();
                          setState(() => selectedType = type);
                        },
                        child: Container(
                          width: 150,
                          height: 70,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? lightBlue
                                : isDarkMode ? Colors.grey[700] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Number of Questions Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_list_numbered, color: lightBlue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        _translate('questionNumber'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: questionCounts.map((count) {
                      final isSelected = selectedNumber == count;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () async {
                              await VibrationService.vibrate();
                              setState(() => selectedNumber = count);
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? amber
                                    : isDarkMode ? Colors.grey[700] : Colors.grey[200],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "$count",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _startQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 50,
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _translate('startQuiz'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}