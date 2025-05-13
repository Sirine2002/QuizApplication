import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart'; // ✅ Ajout de l'import
import 'package:mini_projet/pages/logIn.pages.dart';
import 'package:mini_projet/pages/signUp.pages.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});
  static String id = "/GetStartedPage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              const Spacer(flex: 11),
              Image.asset(
                  "assets/images/logo.png",
                  width: 240,

              ),
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Text(
                      "LogIn Or Sign up",
                      style: TextStyle(
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                        fontSize: 20,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(flex: 2),
                    MaterialButton(
                      elevation: 6,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: LogInPage(),
                            type: PageTransitionType.fade,
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.amber,
                      minWidth: MediaQuery.of(context).size.width * 0.78,
                      height: 50,
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Roboto",
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    MaterialButton(
                      elevation: 6,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: SignUpPage(),
                            type: PageTransitionType.fade,
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.lightBlueAccent,
                      minWidth: MediaQuery.of(context).size.width * 0.78,
                      height: 50,
                      child: const Text(
                        "Create an Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Roboto",
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
