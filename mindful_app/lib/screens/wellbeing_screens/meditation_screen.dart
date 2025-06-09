import 'package:flutter/material.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> meditationTypes = const [
    {'title': 'Mindfulness', 'description': 'Focus on your breath and body.'},
    {'title': 'Body Scan', 'description': 'Relax each part of your body.'},
    {'title': 'Loving Kindness', 'description': 'Develop compassion and love.'},
    {'title': 'Mantra', 'description': 'Repeat a calming word or phrase.'},
    {'title': 'Visualization', 'description': 'Imagine peaceful scenes or goals.'},
  ];

  void _onMeditationSelected(BuildContext context, String title) {
    // You can later navigate to a player screen or start the sound
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$title Meditation'),
        content: const Text('Sound and guidance coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
        itemCount: meditationTypes.length,
        itemBuilder: (context, index) {
          final type = meditationTypes[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.self_improvement, color: Colors.purple, size: 32),
              title: Text(
                type['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(type['description']!),
              onTap: () => _onMeditationSelected(context, type['title']!),
            ),
          );
        },
      ),
    );
  }
}
