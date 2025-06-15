import 'package:flutter/material.dart';
import 'package:mindful_app/config.dart';
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

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('user_id');
      if (storedUserId == null) {
        setState(() {
          error = 'No user ID found in preferences.';
          loading = false;
        });
        return;
      }
      userId = storedUserId;

      final response = await http.get(Uri.parse('${Config.baseUrl}/api/users/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'] ?? 'No name';
          email = data['email'] ?? 'No email';
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
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login'); // adjust route as needed
  }

  void _onMenuTap(String option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$option tapped')),
    );
    // Add your navigation or logic here
  }

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
        onTap: () => _onMenuTap(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }

    return Scaffold(
     
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(name ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Email', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Text(email ?? '', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),

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
