import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:mini_projet/pages/audio_service.dart';
import 'package:mini_projet/pages/completedQuiz_page.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  late List<dynamic> questions = [];
  bool isLoading = true;
  int currentQuestionIndex = 0;
  String? errorMessage;
  int selectedIndex = -1;
  int correctCount = 0;
  int incorrectCount = 0;
  String? categoryName = '';
  Map<String, dynamic>? quizArgs;

  Timer? _timer;
  int _timeRemaining = 30;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    quizArgs = args;
    categoryName = args['category'];

    // Check if questions are passed
    if (args.containsKey('questions') && args['questions'] != null) {
      setState(() {
        questions = args['questions'];
        isLoading = false;
      });
      _startTimer();
    } else {
      _fetchQuestions(
        category: args['categoryId'],
        difficulty: args['difficulty'],
        type: args['type'],
        amount: args['amount'],
      );
    }
  }

  Future<void> _fetchQuestions({
    required int category,
    required String difficulty,
    required String type,
    required int amount,
  }) async {
    final url = 'https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['response_code'] == 0) {
        setState(() {
          questions = data['results'];
          isLoading = false;
        });
        _startTimer();
      } else {
        setState(() {
          errorMessage = "No questions found for the selected parameters.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeRemaining = 30);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer?.cancel();
        _showAnswer(-1);
      }
    });
  }

  void _showAnswer(int index) {
    final correctAnswer = questions[currentQuestionIndex]['correct_answer'];
    final unescape = HtmlUnescape();
    final isCorrect = index != -1 &&
        unescape.convert(questions[currentQuestionIndex]['answers'][index]) ==
            unescape.convert(correctAnswer);

    setState(() {
      selectedIndex = index;
      if (isCorrect) {
        correctCount++;
        AudioService().playSound('sounds/vrai.mp3');
      } else {
        incorrectCount++;
        AudioService().playSound('sounds/faux.mp3');
      }
    });

    Future.delayed(Duration(seconds: 1), _nextQuestion);
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedIndex = -1;
      });
      _startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompletedQuizPage(
            category: categoryName,
            score: correctCount * 10,
            totalQuestions: questions.length,
            correct: correctCount,
            wrong: incorrectCount,
            categoryId: quizArgs?['categoryId'],
            difficulty: quizArgs?['difficulty'],
            type: quizArgs?['type'],
            amount: quizArgs?['amount'],
            questions: questions, // Pass the questions
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();
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
                    "Quiz: ${categoryName ?? ''}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Let's test your knowledge",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildScore("Correct", correctCount, Colors.green),
                            CircularPercentIndicator(
                              radius: 30.0,
                              lineWidth: 8.0,
                              percent: _timeRemaining / 30,
                              center: Text(
                                "$_timeRemaining",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              progressColor: Colors.amber,
                              backgroundColor: Colors.grey.shade200,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            _buildScore("Wrong", incorrectCount, Colors.red),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Question ${currentQuestionIndex + 1}/${questions.length}",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            unescape.convert(questions[currentQuestionIndex]['question']),
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 30),
                        ...(questions[currentQuestionIndex]['type'] == 'multiple'
                            ? _buildMultipleChoices()
                            : _buildBooleanChoices()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScore(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  List<Widget> _buildMultipleChoices() {
    final unescape = HtmlUnescape();
    final current = questions[currentQuestionIndex];
    List<String> answers = List<String>.from(current['incorrect_answers']);
    if (!answers.contains(current['correct_answer'])) {
      answers.add(current['correct_answer']);
    }

    current['answers'] = answers;

    return List.generate(answers.length, (index) {
      final answer = unescape.convert(answers[index]);
      final isSelected = selectedIndex == index;
      final isCorrect = answer == unescape.convert(current['correct_answer']);

      Color borderColor = Colors.amber;
      Color bgColor = Colors.white;
      IconData? icon;
      Color? iconColor;

      if (selectedIndex != -1) {
        if (isSelected && isCorrect) {
          bgColor = Colors.green.withOpacity(0.1);
          icon = Icons.check_circle;
          iconColor = Colors.green;
        } else if (isSelected && !isCorrect) {
          bgColor = Colors.red.withOpacity(0.1);
          icon = Icons.cancel;
          iconColor = Colors.red;
        } else if (isCorrect) {
          bgColor = Colors.green.withOpacity(0.1);
          icon = Icons.check_circle;
          iconColor = Colors.green;
        }
      }

      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(40),
        ),
        child: ListTile(
          onTap: selectedIndex == -1 ? () => _showAnswer(index) : null,
          title: Text(
            answer,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          trailing: icon != null ? Icon(icon, color: iconColor) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
    });
  }

  List<Widget> _buildBooleanChoices() {
    final current = questions[currentQuestionIndex];
    current['answers'] = ['True', 'False'];
    return _buildMultipleChoices();
  }
}