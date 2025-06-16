import 'package:flutter/material.dart';
import 'package:mindful_app/screens/wellbeing_screens/excercise_details_screen.dart';


class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String selectedCategory = 'All';
  bool isLoading = false;

  final List<Map<String, dynamic>> exercises = [
    {
      'name': 'Morning Stretch',
      'duration': '10 min',
      'category': 'Stretching',
      'difficulty': 'Beginner',
      'image': 'assets/breathing.jpg',
      'description': 'Gentle stretching routine to start your day',
      'instructions': [
        'Stand with feet shoulder-width apart',
        'Reach arms overhead and stretch',
        'Hold each stretch for 15-20 seconds'
      ],
      'videoUrl': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    },
    {
      'name': 'Core Workout',
      'duration': '15 min',
      'category': 'Core',
      'difficulty': 'Intermediate',
      'image': 'assets/breathing.jpg',
      'description': 'Strengthen your core muscles',
      'instructions': [
        'Perform 3 sets of planks (30 sec each)',
        'Do 20 crunches',
        'Finish with leg raises'
      ],
      'videoUrl': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    },
    {
      'name': 'Yoga Flow',
      'duration': '20 min',
      'category': 'Yoga',
      'difficulty': 'Beginner',
      'image': 'assets/breathing.jpg',
      'description': 'Relaxing yoga sequence for all levels',
      'instructions': [
        'Start in mountain pose',
        'Flow through sun salutations',
        'Hold each pose for 3-5 breaths'
      ],
      'videoUrl': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    },
  ];

  List<String> get categories => [
        'All',
        ...exercises.map((e) => e['category']).toSet().toList(),
      ];

  List<Map<String, dynamic>> get filteredExercises => selectedCategory == 'All'
      ? exercises
      : exercises.where((e) => e['category'] == selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️ Exercise Library'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[50],
        elevation: 0,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: categories.map((category) {
                final isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedCategory = category),
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.deepPurple[800],
                    ),
                    backgroundColor: Colors.deepPurple[100],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(exercise['category']),
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    title: Text(
                      exercise['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple[900],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise['duration']),
                        Text(
                          exercise['difficulty'],
                          style: TextStyle(
                            color: _getDifficultyColor(exercise['difficulty'])),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios, 
                      size: 16,
                      color: Colors.deepPurple[800],
                    ),
                    onTap: () => _openExerciseDetail(context, exercise),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Yoga': return Icons.self_improvement;
      case 'Core': return Icons.fitness_center;
      case 'Cardio': return Icons.directions_run;
      default: return Icons.accessibility_new;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner': return Colors.green;
      case 'Intermediate': return Colors.orange;
      case 'Advanced': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _openExerciseDetail(BuildContext context, Map<String, dynamic> exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }
}

