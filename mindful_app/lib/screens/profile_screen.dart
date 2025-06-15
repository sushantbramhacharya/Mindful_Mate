import 'package:flutter/material.dart';
import 'package:mindful_app/config.dart';
import 'package:mindful_app/screens/profile_screens/mood_tracker_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userId;
  String? name;
  String? email;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Loads user data from SharedPreferences and fetches detailed profile
  /// information from the backend API.
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('user_id'); // Get user ID from local storage
      
      if (storedUserId == null) {
        setState(() {
          error = 'No user ID found in preferences. Please log in again.';
          loading = false;
        });
        return;
      }
      userId = storedUserId;

      // Make API call to fetch user profile using the stored ID
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/users/$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'] ?? 'No name'; // Set name, provide default if null
          email = data['email'] ?? 'No email'; // Set email, provide default if null
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load user data: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading profile: $e'; // Catch network or parsing errors
        loading = false;
      });
    }
  }

  /// Logs out the user by clearing shared preferences and navigating
  /// to the login screen.
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences (including token, user_id)
    if (mounted) { // Ensure widget is still in the tree before navigating
      Navigator.pushReplacementNamed(context, '/login'); // Adjust route as needed for your login screen
    }
  }

  /// Handles tap events on the menu options.
  /// Navigates to the MoodTrackerScreen if 'Track Mood' is selected.
  void _onMenuTap(String option) {
    if (option == 'Track Mood') {
      // Navigate to the MoodTrackerScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
      );
    } else {
      // Show a snackbar for other options (for demonstration)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$option tapped')),
      );
      // Add your navigation or specific logic here for other menu items
    }
  }

  /// Builds a customizable menu item card.
  Widget _buildMenuItem(IconData icon, String label, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.6), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: () => _onMenuTap(label), // Call _onMenuTap with the label
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching user data
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show an error message if data loading failed
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }

    // Display the profile content
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
        iconTheme: const IconThemeData(color: Colors.white), // For back button
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Name
            Text('Name', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(name ?? 'N/A', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // User Email
            Text('Email', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(email ?? 'N/A', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),

            // List of menu options
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.mood, 'Track Mood', Colors.orange),
                  _buildMenuItem(Icons.call, 'Call Helpline', Colors.redAccent),
                  _buildMenuItem(Icons.notifications, 'Notifications', Colors.teal),
                  _buildMenuItem(Icons.lock, 'Change Password', Colors.blueAccent),
                  _buildMenuItem(Icons.email, 'Change Email', Colors.purple),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
