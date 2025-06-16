import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback

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
  bool _isPaused = false;

  // Customizable durations (in seconds)
  final int _inhaleDuration = 4;
  final int _exhaleDuration = 4;
  final int _holdDuration = 2; // Optional hold between phases

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startBreathingCycle();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: Duration(seconds: _inhaleDuration),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 100.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine, // Smoother curve
      ),
    );
  }

  void _startBreathingCycle() {
    _timer = Timer.periodic(
      Duration(seconds: _inhaleDuration + _exhaleDuration + (_holdDuration * 2)), 
      (timer) {
        if (!_isPaused) {
          _updateInstruction("Inhale");
          Future.delayed(Duration(seconds: _inhaleDuration), () {
            _updateInstruction("Hold");
            Future.delayed(Duration(seconds: _holdDuration), () {
              _updateInstruction("Exhale");
              Future.delayed(Duration(seconds: _exhaleDuration), () {
                _updateInstruction("Hold");
              });
            });
          });
        }
      },
    );
  }

  void _updateInstruction(String newInstruction) {
    if (!_isPaused) {
      setState(() {
        instruction = newInstruction;
      });
      HapticFeedback.lightImpact(); // Tactile feedback
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
        _controller.stop();
      } else {
        _startBreathingCycle();
        _controller.repeat(reverse: true);
      }
    });
  }

  void _resetExercise() {
    setState(() {
      _timer?.cancel();
      _controller.reset();
      instruction = "Inhale";
      _isPaused = false;
      _startBreathingCycle();
      _controller.repeat(reverse: true);
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
      appBar: AppBar(
        title: const Text("Mindful Breathing"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Breathing Circle
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                Color circleColor;
                switch (instruction) {
                  case "Inhale":
                    circleColor = Colors.blue[300]!;
                    break;
                  case "Exhale":
                    circleColor = Colors.green[300]!;
                    break;
                  default:
                    circleColor = Colors.orange[300]!;
                }

                return Container(
                  width: _animation.value,
                  height: _animation.value,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: circleColor.withOpacity(0.4),
                        blurRadius: _animation.value / 2,
                        spreadRadius: _animation.value / 8,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Instructions
            Text(
              instruction,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isPaused ? "Paused" : "Follow the circle rhythm",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 40),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    size: 36,
                  ),
                  onPressed: _togglePause,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.replay, size: 36),
                  onPressed: _resetExercise,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}