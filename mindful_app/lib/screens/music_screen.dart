import 'package:flutter/material.dart';

// Bottom Sheet Music Player
class MusicPlayerWidget extends StatefulWidget {
  final String title;
  final String artist;

  const MusicPlayerWidget({
    Key? key,
    required this.title,
    required this.artist,
  }) : super(key: key);

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  bool isPlaying = false;
  double progress = 0.0;

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Now Playing',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Song title and artist
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.artist,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Progress slider
          Slider(
            value: progress,
            min: 0,
            max: 1,
            onChanged: (value) {
              setState(() {
                progress = value;
              });
            },
          ),

          // Play / Pause button
          IconButton(
            iconSize: 48,
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
            color: Colors.purple[800],
            onPressed: togglePlayPause,
          ),
        ],
      ),
    );
  }
}

// Main Music Screen with Categories
class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String selectedCategory = 'All';

  static const List<String> categories = [
    'All',
    'Meditation',
    'Focus',
    'Relaxation',
    'Sleep',
    'Mood Boost',
  ];

  static const List<Map<String, String>> songs = [
    {'title': 'Sunshine', 'artist': 'John Doe', 'category': 'Mood Boost'},
    {'title': 'Moonlight', 'artist': 'Jane Smith', 'category': 'Sleep'},
    {'title': 'Waves', 'artist': 'Ocean Band', 'category': 'Relaxation'},
    {'title': 'Mountains', 'artist': 'High Peak', 'category': 'Meditation'},
    {'title': 'Forest Rain', 'artist': 'Zen Sounds', 'category': 'Sleep'},
    {'title': 'Focus Beats', 'artist': 'Clarity', 'category': 'Focus'},
  ];

  List<Map<String, String>> get filteredSongs {
    if (selectedCategory == 'All') return songs;
    return songs.where((song) => song['category'] == selectedCategory).toList();
  }

  void _openMusicPlayer(BuildContext context, String title, String artist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MusicPlayerWidget(title: title, artist: artist),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          const SizedBox(height: 50),
          // Category selector
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
                    onSelected: (_) {
                      setState(() => selectedCategory = category);
                    },
                    selectedColor: Colors.purple.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Songs list
          Expanded(
            child: filteredSongs.isEmpty
                ? const Center(child: Text('No songs in this category.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading:
                              const Icon(Icons.music_note, color: Colors.purple),
                          title: Text(song['title']!),
                          subtitle: Text(song['artist']!),
                          onTap: () => _openMusicPlayer(
                              context, song['title']!, song['artist']!),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
