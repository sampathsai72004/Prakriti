import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prakriti/home_screen.dart';
import 'package:prakriti/main_screen.dart';


import 'LoginScreen.dart'; // Import LoginScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Check if user is logged in
  _checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If the user is logged in, navigate to HomeScreen
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      });
    } else {
      // If the user is not logged in, navigate to LoginScreen
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF39C12),
        ),
      ),
    );
  }
}
