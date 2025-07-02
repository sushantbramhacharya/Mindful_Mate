import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindful_app/config.dart';
import 'dart:convert';

import 'package:mindful_app/screens/wellbeing_screens/excercise_details_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String selectedCategory = 'All';
  bool isLoading = true;
  List<dynamic> exercises = [];
  String? errorMessage;

  // API configuration
  final String apiUrl = Config.baseUrl; // Update with your actual server address

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$apiUrl/exercises'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          exercises = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load exercises. Please try again later.';
      });
    }
  }

  List<String> get categories {
    final allCategories = exercises.map((e) => e['category'] as String).toSet().toList();
    return ['All', ...allCategories];
  }

  List<dynamic> get filteredExercises {
    if (selectedCategory == 'All') {
      return exercises;
    }
    return exercises.where((e) => e['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️ Exercise Library'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchExercises,
          ),
        ],
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Column(
        children: [
          const SizedBox(height: 8),
          if (isLoading)
            const LinearProgressIndicator()
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (!isLoading && errorMessage == null) ...[
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
              child: RefreshIndicator(
                onRefresh: fetchExercises,
                child: filteredExercises.isEmpty
                    ? const Center(
                        child: Text('No exercises found'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                exercise['exercise_name'],
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
                                      color: _getDifficultyColor(
                                          exercise['difficulty']),
                                    ),
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
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Yoga':
        return Icons.self_improvement;
      case 'Core':
        return Icons.fitness_center;
      case 'Cardio':
        return Icons.directions_run;
      default:
        return Icons.accessibility_new;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openExerciseDetail(BuildContext context, Map<String, dynamic> exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exercise: {
            'name': exercise['exercise_name'],
            'duration': exercise['duration'],
            'category': exercise['category'],
            'difficulty': exercise['difficulty'],
            'description': exercise['description'] ?? 'No description available',
            'instructions': exercise['instructions'] ?? ['No instructions available'],
            'videoUrl': '$apiUrl/uploads/exercise_videos/${exercise['file_path']}',
          },
        ),
      ),
    );
  }
}