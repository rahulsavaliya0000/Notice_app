import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studentsapp/view/home_sc.dart';
import 'package:studentsapp/view/homepage_screen.dart';
import 'package:studentsapp/view/intro1_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    // Delay to show splash screen
    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (user != null) {
        // User is already logged in, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageScreen()),
        );
      } else {
        // User is not logged in, navigate to intro screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IntroScreen1()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/spbgimg.png",
            fit: BoxFit.cover,
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 96,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 70),
                child: Text(
                  "Welcome to \nStudent Club",
                  style: TextStyle(
                    fontFamily: "Klasik",
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff573353),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
