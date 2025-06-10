import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:mindful_app/config.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerWidget extends StatefulWidget {
  final String title;
  final String artist;
  final String audioUrl;

  const MusicPlayerWidget({
    Key? key,
    required this.title,
    required this.artist,
    required this.audioUrl,
  }) : super(key: key);

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
      duration = _player.duration ?? Duration.zero;

      // Position stream
      _player.positionStream.listen((pos) {
        setState(() => position = pos);
      });

      // Player state stream
      _player.playerStateStream.listen((state) {
        setState(() => isPlaying = state.playing);
      });

      // Duration stream for dynamically loaded audio
      _player.durationStream.listen((dur) {
        if (dur != null) {
          setState(() => duration = dur);
        }
      });
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    if (isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

          // Timer text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position)),
              Text(_formatDuration(duration)),
            ],
          ),

          // Progress slider
          Slider(
            value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
            min: 0,
            max: duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              _player.seek(Duration(milliseconds: value.toInt()));
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


// Main Music Screen with Categories, fetches from backend
class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String selectedCategory = 'All';
  List<dynamic> songs = [];
  bool isLoading = false;

  static const List<String> categories = [
    'All',
    'Meditation',
    'Focus',
    'Relaxation',
    'Sleep',
    'Mood Boost',
    // Add other categories dynamically if needed
  ];

  final String baseUrl = Config.baseUrl; // Change this to your backend URL

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    setState(() {
      isLoading = true;
    });
    try {
      final res = await http.get(Uri.parse('$baseUrl/music'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          songs = data;
          // You can update categories dynamically based on fetched data if you want
        });
      } else {
        print("Failed to load songs: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching songs: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get filteredSongs {
    if (selectedCategory == 'All') return songs;
    return songs.where((song) => song['category']?.toLowerCase() == selectedCategory.toLowerCase()).toList();
  }

  void _openMusicPlayer(BuildContext context, Map song) {
    final audioUrl = '$baseUrl/uploads/${song["file_path"]}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MusicPlayerWidget(
        title: song['music_name'] ?? 'Unknown',
        artist: song['author'] ?? 'Unknown',
        audioUrl: audioUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dynamicCategories = ['All', ...{for (var s in songs) s['category']}];

    return Scaffold(
      appBar: AppBar(title: const Text('🎵 Music Manager')),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Category selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: dynamicCategories.map((category) {
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

          // Songs list or loader
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSongs.isEmpty
                    ? const Center(child: Text('No songs in this category.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.music_note, color: Colors.purple),
                              title: Text(song['music_name'] ?? 'Unknown'),
                              subtitle: Text(song['author'] ?? 'Unknown'),
                              onTap: () => _openMusicPlayer(context, song),
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