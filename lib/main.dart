import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mini_projet/pages/completedQuiz_page.dart';
import 'package:mini_projet/pages/home.pages.dart';
import 'package:mini_projet/pages/logIn.pages.dart';
import 'package:mini_projet/pages/profile.dart';
import 'package:mini_projet/pages/question_page.dart';
import 'package:mini_projet/pages/settings.dart';
import 'firebase_options.dart';
import 'package:mini_projet/pages/introPages/getStarted.introPages.dart';
import 'package:mini_projet/pages/page0.pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //les routes:
  final routes = {
    '/Quiz': (context) => Page0(),
    '/GetStartedPage': (context) => const GetStartedPage(),
    '/HomePage': (context) =>HomePage(),
    '/LogInPage':(context) =>LogInPage(),
    '/settings': (context) => const SettingsPage(),
    '/profile':(context) => ProfilePage(),
    '/QuestionPage':(context) =>QuestionPage(),
    '/completedQuiz': (context) {
      // Récupère les arguments passés via Navigator.pushNamed
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      return CompletedQuizPage(
        score: args?['score'] as int? ?? 0,
        totalQuestions: args?['totalQuestions'] as int? ?? 0,
        correct: args?['correct'] as int? ?? 0,
        wrong: args?['wrong'] as int? ?? 0,
        category: args?['category'] as String?,
      );
    },

  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes:routes,
      home:StreamBuilder<User?>(
          stream: FirebaseAuth. instance. authStateChanges () ,
          builder:(context,snapshot){
            if(snapshot.hasData){
              return HomePage();
            }
            else{
              return Page0();
            }
          }
      ) ,
      debugShowCheckedModeBanner: false,


    );
  }
}