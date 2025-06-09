import 'dart:async';
import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({Key? key}) : super(key: key);

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String instruction = "Inhale";
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 100.0, end: 200.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startInstructionLoop();
  }

  void _startInstructionLoop() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        instruction = instruction == "Inhale" ? "Exhale" : "Inhale";
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: _animation.value,
                  height: _animation.value,
                  decoration: BoxDecoration(
                    color: Colors.purple[200],
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              instruction,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Follow the circle to breathe",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
