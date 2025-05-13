import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_projet/pages/logIn.pages.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpPage extends StatefulWidget {
  static String id = "/SignUpPage";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController txt_login = TextEditingController();
  TextEditingController txt_pwd = TextEditingController();
  late SharedPreferences prefs;

  String? username, email, password;
  bool isLoading = false;
  bool _obscureText = true;

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            "assets/images/background2.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 24),
            child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/GetStartedPage'),
                        child: const CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                  Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 35,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Username
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a username' : null,
                        onChanged: (data) => username = data,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: txt_login,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your email' : null,
                        onChanged: (data) => email = data,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Password avec visibility toggle
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: txt_pwd,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a password' : null,
                        onChanged: (data) => password = data,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Sign Up button
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: MaterialButton(
                        elevation: 5,
                        height: 50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onPressed: () {
                          _handleSignUp(context);
                        },
                        color: Colors.amber,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(width: 15),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login redirection
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: "Roboto",
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: LogInPage(),
                                type: PageTransitionType.rightToLeft,
                              ),
                            );
                          },
                          child: Text(
                            "LogIn",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Roboto",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: txt_login.text,
        password: txt_pwd.text,
      );

      // 🔐 Récupérer l'ID de l'utilisateur
      final userId = credential.user?.uid;

      // 📥 Ajouter les données dans Firestore
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'username': username,
          'email': email,

        });
      }

      setState(() {
        isLoading = false;
      });

      Navigator.pushNamed(context, '/HomePage');

    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      print(e);
    }
  }


}