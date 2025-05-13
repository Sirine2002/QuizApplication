import 'package:flutter/material.dart';
class OnBoardingWidget extends StatelessWidget {
  const OnBoardingWidget({
    super.key,
    required this.controller,
    required this.image,
    required this.description,
    required this.currentIndex,
    this.imageWidth = 300,
    this.imageHeight = 300,
  });

  final String image;
  final String description;
  final PageController controller;
  final int currentIndex;
  final double? imageWidth;
  final double? imageHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/onboarding_background.png"),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              image,
              width: imageWidth,
              height: imageHeight,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentIndex ? Colors.white : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, fontFamily: "Roboto"),
                  ),
                  const Spacer(flex: 1),
                  MaterialButton(
                    elevation: 6,
                    onPressed: () {
                      if (currentIndex < 2) {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/GetStartedPage');
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.amber,
                    minWidth: MediaQuery.of(context).size.width * 0.78,
                    height: 50,
                    child: Text(
                      currentIndex < 2 ? "Next" : "Get Started",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  if (currentIndex < 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already Have An Account? ",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/LogInPage');
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 15,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
