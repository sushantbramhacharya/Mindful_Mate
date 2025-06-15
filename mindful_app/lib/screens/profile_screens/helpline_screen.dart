import 'package:flutter/material.dart';

/// A StatelessWidget for the Helpline Screen.
/// This screen provides information about a helpline and a button to simulate a call.
class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  // This method simulates initiating a call.
  // In a real app, you would use a package like 'url_launcher'
  // to open the phone dialer with a specific number.
  void _callHelpline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Simulating call to Helpline...'),
        backgroundColor: Colors.green[700],
      ),
    );
    // TODO: Implement actual phone call using a package like url_launcher
    // Example: launchUrl(Uri(scheme: 'tel', path: '123-456-7890'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Helpline & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
        iconTheme: const IconThemeData(color: Colors.white), // For back button
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon for visual emphasis
            Icon(
              Icons.headset_mic,
              size: 100,
              color: Colors.purple[400],
            ),
            const SizedBox(height: 20),
            // Title and description
            Text(
              'Need to talk to someone?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[900],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re here to support you. If you need immediate assistance or just someone to listen, please reach out to our dedicated helpline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            // Helpline Number Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.6), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Helpline Number:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '123-456-7890', // Replace with actual helpline number
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Call Button
            ElevatedButton.icon(
              onPressed: () => _callHelpline(context),
              icon: const Icon(Icons.phone, size: 24),
              label: const Text(
                'Call Helpline Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Red accent for urgency
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: Colors.redAccent[900]?.withOpacity(0.4),
              ),
            ),
            const Spacer(), // Pushes content to the top
            Text(
              'Available 24/7. Your privacy is important to us.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
