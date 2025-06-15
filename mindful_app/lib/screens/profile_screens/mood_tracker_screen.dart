import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindful_app/config.dart'; // Assuming Config.baseUrl is defined here

/// Represents a single mood entry fetched from the backend.
/// This data class helps in type-safe handling of mood history.
class MoodEntry {
  final String id;
  final String mood;
  final String notes;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.notes,
    required this.createdAt,
  });

  // Factory constructor to create a MoodEntry from a JSON map (from backend response)
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    String? rawCreatedAtString;

    // Handle MongoDB's $date format or direct ISO string
    if (json['created_at'] != null && json['created_at'] is Map && json['created_at'].containsKey('\$date')) {
      rawCreatedAtString = json['created_at']['\$date'] as String?;
    } else if (json['created_at'] is String) {
      rawCreatedAtString = json['created_at'] as String?;
    }

    DateTime parsedDate;
    try {
      parsedDate = rawCreatedAtString != null ? DateTime.parse(rawCreatedAtString).toLocal() : DateTime.now();
    } catch (e) {
      print('Error parsing mood entry date: $rawCreatedAtString - $e');
      parsedDate = DateTime.now(); // Fallback to current time on parsing error
    }

    return MoodEntry(
      id: json['_id'] as String? ?? '',
      mood: json['mood'] as String? ?? 'Unknown Mood',
      notes: json['notes'] as String? ?? '',
      createdAt: parsedDate,
    );
  }
}

/// A StatefulWidget that represents the Mood Tracker screen.
/// It allows users to select their mood, add notes, log it,
/// and view their mood history fetched from the backend.
class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String? _selectedMood; // The currently selected mood for logging
  final TextEditingController _notesController = TextEditingController(); // Controller for mood notes

  List<MoodEntry> _moodHistory = []; // List to store fetched mood history
  bool _isLoadingHistory = true; // Tracks if mood history is loading
  String? _historyError; // Stores error message for history fetching

  // Predefined mood options with visual properties
  final List<Map<String, dynamic>> _moodOptions = [
    {'mood': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
    {'mood': 'Neutral', 'icon': Icons.sentiment_neutral, 'color': Colors.amber},
    {'mood': 'Sad', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.blue},
    {'mood': 'Anxious', 'icon': Icons.mood_bad, 'color': Colors.orange},
    {'mood': 'Angry', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.red},
    {'mood': 'Excited', 'icon': Icons.emoji_emotions, 'color': Colors.pink},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMoodHistory(); // Fetch mood history when the screen initializes
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Formats a DateTime object into a "Month/Day/Year Hour:Minute" string.
  String _formatDate(DateTime dateTime) {
    return "${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  /// Logs the selected mood to the backend API.
  /// Sends a POST request and refreshes the mood history upon success.
  Future<void> _logMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${Config.baseUrl}/api/moods');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mood': _selectedMood,
          'notes': _notesController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood "${_selectedMood!}" logged successfully!'),
            backgroundColor: Colors.purple[700],
          ),
        );
        setState(() {
          _selectedMood = null; // Clear selected mood
          _notesController.clear(); // Clear notes
        });
        _fetchMoodHistory(); // Refresh mood history after logging new mood
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log mood: ${response.statusCode}')),
        );
        print('Failed to log mood: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging mood: $e')),
      );
      print('Error logging mood: $e');
    }
  }

  /// Fetches the mood history for the authenticated user from the backend API.
  /// Updates `_moodHistory` list and manages loading/error states.
  Future<void> _fetchMoodHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${Config.baseUrl}/api/moods');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = jsonDecode(response.body);
        setState(() {
          _moodHistory = fetchedData.map((json) => MoodEntry.fromJson(json)).toList();
          // The backend sorts by 'created_at' in descending order, so no need to sort here
        });
      } else {
        setState(() {
          _historyError = 'Failed to load mood history: ${response.statusCode}';
        });
        print('Failed to load mood history: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _historyError = 'Error fetching mood history: $e';
      });
      print('Error fetching mood history: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mood Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How are you feeling today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[900],
              ),
            ),
            const SizedBox(height: 30),

            // Mood Selection Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _moodOptions.length,
                itemBuilder: (context, index) {
                  final moodOption = _moodOptions[index];
                  final String moodName = moodOption['mood'];
                  final IconData moodIcon = moodOption['icon'];
                  final Color moodColor = moodOption['color'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = moodName;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _selectedMood == moodName
                            ? moodColor.withOpacity(0.8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedMood == moodName
                              ? moodColor
                              : Colors.purple[100]!,
                          width: _selectedMood == moodName ? 3.0 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_selectedMood == moodName ? moodColor : Colors.purple[200]!).withOpacity(0.3),
                            spreadRadius: _selectedMood == moodName ? 3 : 1,
                            blurRadius: _selectedMood == moodName ? 10 : 4,
                            offset: _selectedMood == moodName ? const Offset(0, 6) : const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            moodIcon,
                            size: 48,
                            color: _selectedMood == moodName ? Colors.white : moodColor.withOpacity(0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            moodName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedMood == moodName ? Colors.white : Colors.purple[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Optional notes input field
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any notes about your mood...',
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
                ),
                prefixIcon: Icon(Icons.edit_note, color: Colors.purple[600]),
              ),
              cursorColor: Colors.purple[700],
            ),
            const SizedBox(height: 30),

            // Log Mood Button
            ElevatedButton(
              onPressed: _logMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: Colors.purple[900]?.withOpacity(0.4),
              ),
              child: const Text(
                'Log My Mood',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),

            // Mood History Section
            Text(
              'Your Mood History',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            const SizedBox(height: 15),

            _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _historyError != null
                    ? Center(
                        child: Column(
                          children: [
                            Text(_historyError!, style: const TextStyle(color: Colors.red)),
                            ElevatedButton(
                              onPressed: _fetchMoodHistory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _moodHistory.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.purple[300]!, width: 1),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'No mood entries yet. Log your first mood!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.purple[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Icon(
                                  Icons.history,
                                  size: 60,
                                  color: Colors.purple[400],
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Important for nested scroll
                            itemCount: _moodHistory.length,
                            itemBuilder: (context, index) {
                              final entry = _moodHistory[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mood: ${entry.mood}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.purple[800],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (entry.notes.isNotEmpty)
                                        Text(
                                          'Notes: ${entry.notes}',
                                          style: TextStyle(color: Colors.grey[700]),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(entry.createdAt),
                                        style: TextStyle(color: Colors.purple[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ],
        ),
      ),
    );
  }
}
