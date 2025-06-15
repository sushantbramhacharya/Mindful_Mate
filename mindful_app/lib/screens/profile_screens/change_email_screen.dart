import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindful_app/config.dart'; // Assuming Config.baseUrl is defined here

/// A StatefulWidget for the Change Email Screen.
/// This screen allows users to update their email address.
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // For verification

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the email change process by sending an API request.
  Future<void> _changeEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    final String newEmail = _newEmailController.text.trim();
    final String password = _passwordController.text.trim();

    // Basic client-side validation
    if (newEmail.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'New email and password are required.';
      });
      _isLoading = false;
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(newEmail)) { // Simple email regex
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      _isLoading = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('user_id');

    if (userId == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Authentication error. Please log in again.';
      });
      _isLoading = false;
      return;
    }

    final url = Uri.parse('${Config.baseUrl}/api/change-email'); // Adjust endpoint
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'new_email': newEmail,
          'password': password, // Current password for verification
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Email changed successfully!')),
          );
          // Clear fields on success
          _newEmailController.clear();
          _passwordController.clear();
          // Optionally, navigate back
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = responseData['error'] ?? 'Failed to change email. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
      print('Error changing email: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Email',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700], // Themed AppBar
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.email, size: 80, color: Colors.purple[400]),
            const SizedBox(height: 20),
            Text(
              'Update Your Email Address',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple[900],
              ),
            ),
            const SizedBox(height: 30),
            // New Email Field
            TextField(
              controller: _newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'New Email Address',
                prefixIcon: const Icon(Icons.mail_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Password for verification Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Your Current Password (for verification)',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Error Message Display
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            // Submit Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _changeEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.purple[900]?.withOpacity(0.4),
                    ),
                    child: const Text(
                      'Change Email',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
