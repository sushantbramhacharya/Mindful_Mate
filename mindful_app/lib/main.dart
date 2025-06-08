import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purple Theme App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) =>const RegisterScreen()
        // You can add other routes here, like register, etc.
      },
    );
  }
}
