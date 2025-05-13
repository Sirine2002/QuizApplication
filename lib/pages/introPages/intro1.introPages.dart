import 'package:flutter/material.dart';
import 'package:mini_projet/widgets/onBoarding_widget.dart';

class Intro1 extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  const Intro1({super.key, required this.controller, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return OnBoardingWidget(
      controller: controller,
      currentIndex: currentIndex,
      image: "assets/images/intro1.png",
      description: "Challenge yourself with our interactive quizzes and discover how much you know about various topics.",
    );
  }
}