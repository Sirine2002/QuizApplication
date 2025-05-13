// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mini_projet/widgets/onBoarding_widget.dart';

class Intro3 extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  const Intro3({super.key, required this.controller, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return OnBoardingWidget(
      controller: controller,
      currentIndex: currentIndex,
      image: "assets/images/intro3.png",
      description: "Prove your expertise and become a quiz master by answering thought-provoking questions subjects. ",
    );
  }
}
