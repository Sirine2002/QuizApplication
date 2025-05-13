import 'package:flutter/material.dart';
import 'package:mini_projet/widgets/onBoarding_widget.dart';

class Intro2 extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  const Intro2({super.key, required this.controller, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return OnBoardingWidget(
      controller: controller,
      currentIndex: currentIndex,
      image: "assets/images/intro2.png",
      description: "Participate in educational quizzes designed to infuse enjoyment and enthusiasm into the learning process.",
    );
  }
}