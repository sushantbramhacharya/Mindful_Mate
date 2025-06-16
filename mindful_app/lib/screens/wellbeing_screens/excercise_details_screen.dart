import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}


class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isVideoLoading = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = widget.exercise['videoUrl'] as String? ?? '';
      if (videoUrl.isEmpty) throw Exception('No video URL provided');

      _videoController = VideoPlayerController.network(videoUrl);
      await _videoController.initialize();

      if (!mounted) return;

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoController.value.aspectRatio,
          placeholder: Container(
            color: Colors.deepPurple[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 50, color: Colors.deepPurple[300]),
                  const SizedBox(height: 10),
                  const Text('Loading exercise video...'),
                ],
              ),
            ),
          ),
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.deepPurple,
            handleColor: Colors.deepPurpleAccent,
            backgroundColor: Colors.deepPurple[100]!,
            bufferedColor: Colors.deepPurple[50]!,
          ),
        );
        _isVideoLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVideoLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load video: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_chewieController != null) {
      setState(() {
        _isPlaying = !_isPlaying;
        if (_isPlaying) {
          _chewieController!.play();
        } else {
          _chewieController!.pause();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise['name']),
        backgroundColor: Colors.deepPurple[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.deepPurple[800]),
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isVideoLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  )
                : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 50, color: Colors.deepPurple[300]),
                            const SizedBox(height: 10),
                            const Text('Video unavailable'),
                          ],
                        ),
                      ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(widget.exercise['duration'] ?? '10 min'),
                        backgroundColor: Colors.deepPurple[100],
                        labelStyle: TextStyle(color: Colors.deepPurple[800]),
                        avatar: Icon(Icons.timer, size: 18, color: Colors.deepPurple),
                      ),
                      Chip(
                        label: Text(widget.exercise['difficulty'] ?? 'Beginner'),
                        backgroundColor: _getDifficultyColor(widget.exercise['difficulty']).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _getDifficultyColor(widget.exercise['difficulty']),
                        ),
                      ),
                      Chip(
                        label: Text(widget.exercise['category'] ?? 'General'),
                        backgroundColor: Colors.deepPurple[50],
                        labelStyle: TextStyle(color: Colors.deepPurple[800]),
                        avatar: Icon(
                          _getCategoryIcon(widget.exercise['category']),
                          size: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 16, 
                      height: 1.5,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildInstructionSteps(widget.exercise['instructions'] ?? []),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _togglePlayPause,
        icon: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
        label: Text(
          _isPlaying ? 'Pause' : 'Start',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  List<Widget> _buildInstructionSteps(List<dynamic> instructions) {
    if (instructions.isEmpty) {
      return [
        Text(
          'No instructions provided',
          style: TextStyle(color: Colors.deepPurple[300]),
        ),
      ];
    }

    return instructions.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.deepPurple,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step.toString(),
                style: TextStyle(
                  fontSize: 16, 
                  height: 1.4,
                  color: Colors.deepPurple[700],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'yoga': return Icons.self_improvement;
      case 'core': return Icons.fitness_center;
      case 'cardio': return Icons.directions_run;
      default: return Icons.accessibility_new;
    }
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner': return Colors.green;
      case 'intermediate': return Colors.orange;
      case 'advanced': return Colors.red;
      default: return Colors.grey;
    }
  }
}