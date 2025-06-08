import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String title;
  final String content;
  final String timestamp;

  const PostWidget({
    super.key,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.purple[800],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                color: Colors.purple[700],
                fontSize: 16,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timestamp,
                style: TextStyle(
                  color: Colors.purple[400],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _postController = TextEditingController();

  final List<Map<String, String>> _posts = [
    {
      'title': 'Flutter is awesome!',
      'content': 'Let me tell you why Flutter is one of the best cross-platform frameworks...',
      'timestamp': 'June 8, 2025',
    },
    {
      'title': 'Purple is my favorite color',
      'content': 'I love purple because it is calm yet powerful. Here are some tips for purple-themed UI design...',
      'timestamp': 'June 7, 2025',
    },
  ];

  void _addPost() {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _posts.insert(0, {
        'title': 'New Post',
        'content': content,
        'timestamp': _formatCurrentDate(),
      });
    });

    _postController.clear();
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return "${now.month}/${now.day}/${now.year}";
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.0,),
        // Input field + submit button
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Write your post here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _addPost(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Post',style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),

        // Post list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return PostWidget(
                title: post['title']!,
                content: post['content']!,
                timestamp: post['timestamp']!,
              );
            },
          ),
        ),
      ],
    );
  }
}