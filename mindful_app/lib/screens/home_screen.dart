import 'package:flutter/material.dart';
import 'package:mindful_app/screens/chat_screen.dart';
import 'package:mindful_app/screens/post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 3; // Default: Home

  final List<Widget> _screens = [
    const Center(child: Text('Songs / Posts', style: TextStyle(fontSize: 24))),
    const Center(child: PostsScreen()),
    const SizedBox(), // Empty center for FAB
    const Center(child: Text('Games', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Home', style: TextStyle(fontSize: 24))),
  ];

  void _onTabSelected(int index) {
    if (index != 2) {
      // index 2 is reserved for FAB
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: Colors.purple,
        shape: const CircleBorder(),
        child: const Icon(Icons.bolt, size: 36, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple[100],
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Music
              Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(Icons.library_music),
                  color: 
                       Colors.purple[800]
                      ,
                  onPressed: () => _onTabSelected(0),
                ),
              ),

              // Posts
              Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(Icons.article),
                  color: Colors.purple[800],
                  onPressed: () => _onTabSelected(1),
                ),
              ),

              const SizedBox(width: 48), // For FAB spacing
              // Games
              Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 3
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(Icons.videogame_asset),
                  color: Colors.purple[800],
                  onPressed: () => _onTabSelected(3),
                ),
              ),

              // Home
              Container(
                decoration: BoxDecoration(
                  color: _selectedIndex == 4
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(Icons.home),
                  color: Colors.purple[800],
                  onPressed: () => _onTabSelected(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
