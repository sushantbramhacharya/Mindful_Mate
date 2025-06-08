import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds then navigate to login screen
    Timer(const Duration(seconds: 2), () {
      Navigator.pushNamed(context, '/login');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Center(
        child: Hero(
          tag: 'appLogo',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
