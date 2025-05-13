import 'package:flutter/material.dart';
import 'package:mini_projet/pages/introPages/intro1.introPages.dart';
import 'package:mini_projet/pages/introPages/intro2.introPages.dart';
import 'package:mini_projet/pages/introPages/intro3.introPages.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController controller = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      int newPage = controller.page?.round() ?? 0;
      if (newPage != currentIndex) {
        setState(() {
          currentIndex = newPage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Intro1(controller: controller, currentIndex: currentIndex),
          Intro2(controller: controller, currentIndex: currentIndex),
          Intro3(controller: controller, currentIndex: currentIndex),
        ],
      ),
    );
  }
}