import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mini_projet/pages/completedQuiz_page.dart';
import 'package:mini_projet/pages/home.pages.dart';
import 'package:mini_projet/pages/localisation/LanguageProvider.dart';
import 'package:mini_projet/pages/logIn.pages.dart';
import 'package:mini_projet/pages/profile.dart';
import 'package:mini_projet/pages/question_page.dart';
import 'package:mini_projet/pages/services/theme_service.dart';
import 'package:mini_projet/pages/settings.dart';
import 'package:mini_projet/pages/services/vibration_service.dart';
import 'firebase_options.dart';
import 'package:mini_projet/pages/introPages/getStarted.introPages.dart';
import 'package:mini_projet/pages/page0.pages.dart';
import 'package:provider/provider.dart';

import 'pages/localisation/AppLocalizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VibrationService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(),
      child: MyApp(), // Retirez const ici
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key); // Retirez const ici

  final Map<String, Widget Function(BuildContext)> routes = {
    '/Quiz': (context) => Page0(),
    '/GetStartedPage': (context) => const GetStartedPage(),
    '/HomePage': (context) => HomePage(),
    '/LogInPage': (context) => LogInPage(),
    '/settings': (context) => const SettingsPage(),
    '/profile': (context) => ProfilePage(),
    '/QuestionPage': (context) => QuestionPage(),
    '/completedQuiz': (context) {
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
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(

      theme: ThemeData.light().copyWith(
        primaryColor: Colors.amber,
        colorScheme: ColorScheme.light(
          primary: Colors.grey,
          secondary: Colors.amberAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber[800],
        colorScheme: ColorScheme.dark(
          primary: Colors.grey,
          secondary: Colors.amber[600]!,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.grey[850],
      ),
      themeMode: themeService.themeMode,
      routes: routes,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return Page0();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}