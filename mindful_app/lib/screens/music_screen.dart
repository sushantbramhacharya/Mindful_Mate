import 'package:flutter/material.dart';

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
  double progress = 0.0; // placeholder for slider

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Styling the popup
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and close button
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

          const SizedBox(height: 8),

          // Track title and artist
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

          // Progress slider (non-functional placeholder)
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

class MusicScreen extends StatelessWidget {
  const MusicScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> songs = [
    {'title': 'Sunshine', 'artist': 'John Doe'},
    {'title': 'Moonlight', 'artist': 'Jane Smith'},
    {'title': 'Waves', 'artist': 'Ocean Band'},
    {'title': 'Mountains', 'artist': 'High Peak'},
  ];

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
      appBar: AppBar(
        title: const Text('Songs'),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.music_note, color: Colors.purple),
              title: Text(song['title']!),
              subtitle: Text(song['artist']!),
              onTap: () => _openMusicPlayer(context, song['title']!, song['artist']!),
            ),
          );
        },
      ),
    );
  }
}
