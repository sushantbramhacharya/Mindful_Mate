import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'appLogo',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade700),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logging in as $email')),
                        );
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.purple[700]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    'Create a New Account',
                    style: TextStyle(color: Colors.purple[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
