import 'package:flutter/material.dart';

class WellbeingScreen extends StatelessWidget {
  const WellbeingScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, String activity) {
    // Placeholder for navigation or function
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$activity clicked!')),
    );
  }

  Widget _buildWellbeingButton({
    required BuildContext context,
    required String label,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: SizedBox(
        height: 130,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 30,),
          _buildWellbeingButton(
            context: context,
            label: 'Breathing Exercise',
            imagePath: 'assets/images/breathing.png',
            onPressed: () => _navigateTo(context, 'Breathing'),
          ),
          const SizedBox(height: 16),
          _buildWellbeingButton(
            context: context,
            label: 'Meditation',
            imagePath: 'assets/images/meditation.png',
            onPressed: () => _navigateTo(context, 'Meditation'),
          ),
          const SizedBox(height: 16),
          _buildWellbeingButton(
            context: context,
            label: 'Yoga',
            imagePath: 'assets/images/yoga.png',
            onPressed: () => _navigateTo(context, 'Yoga'),
          ),
          const SizedBox(height: 16),
          _buildWellbeingButton(
            context: context,
            label: 'Physical Exercise',
            imagePath: 'assets/images/excersize.png',
            onPressed: () => _navigateTo(context, 'Exercise'),
          ),
        ],
      ),
    );
  }
}
