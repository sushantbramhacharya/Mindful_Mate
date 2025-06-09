import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String title;
  final String content;
  final String timestamp;
  final String category;
  final int upvotes;
  final VoidCallback onCommentPressed;
  final VoidCallback onUpvotePressed;

  const PostWidget({
    super.key,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.category,
    required this.upvotes,
    required this.onCommentPressed,
    required this.onUpvotePressed,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timestamp,
                  style: TextStyle(
                    color: Colors.purple[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Colors.purple[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.purple),
                  onPressed: onUpvotePressed,
                ),
                Text(
                  '$upvotes',
                  style: TextStyle(
                      color: Colors.purple[700], fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: onCommentPressed,
                  icon: const Icon(Icons.comment,
                      size: 20, color: Colors.purple),
                  label: const Text(
                    'Comment',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
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
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'General';
  String _filterCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'General',
    'Tech',
    'Lifestyle',
    'Health',
    'Education',
  ];

  final List<Map<String, dynamic>> _posts = [
    {
      'title': 'Flutter is awesome!',
      'content': 'Let me tell you why Flutter is one of the best cross-platform frameworks...',
      'timestamp': '6/8/2025',
      'category': 'Tech',
      'comments': <String>[],
      'upvotes': 0,
    },
    {
      'title': 'Purple is my favorite color',
      'content': 'I love purple because it is calm yet powerful. Here are some tips for purple-themed UI design...',
      'timestamp': '6/7/2025',
      'category': 'Lifestyle',
      'comments': <String>[],
      'upvotes': 0,
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
        'category': _selectedCategory,
        'comments': <String>[],
        'upvotes': 0,
      });
      _selectedCategory = 'General';
    });

    _postController.clear();
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return "${now.month}/${now.day}/${now.year}";
  }

  void _incrementUpvote(int index) {
    setState(() {
      _posts[index]['upvotes'] = (_posts[index]['upvotes'] ?? 0) + 1;
    });
  }

  void _openComments(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CommentsSheet(
        postIndex: index,
        getComments: () => _posts[index]['comments'],
        addComment: (String comment) {
          setState(() {
            _posts[index]['comments'].add(comment);
          });
        },
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredPosts {
    return _posts.where((post) {
      final matchesCategory = _filterCategory == 'All' || post['category'] == _filterCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          post['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post['content'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _postController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              SizedBox(height: 20,),
              // 🟦 Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 12),

              // 🟩 Category Filter
              Row(
                children: [
                  const Text('Filter by: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _filterCategory,
                    items: ['All', ..._categories]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _filterCategory = val;
                        });
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),

              // 🟥 New Post Section
              Row(
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
                 
                ],
              ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
 DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
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
                    child: const Text('Post', style: TextStyle(color: Colors.white)),
                  ),
                ],)
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 🟨 Posts List
        Expanded(
          child: _filteredPosts.isEmpty
              ? const Center(child: Text('No posts found.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: _filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = _filteredPosts[index];
                    final realIndex = _posts.indexOf(post);
                    return PostWidget(
                      title: post['title'],
                      content: post['content'],
                      timestamp: post['timestamp'],
                      category: post['category'],
                      upvotes: post['upvotes'],
                      onCommentPressed: () => _openComments(realIndex),
                      onUpvotePressed: () => _incrementUpvote(realIndex),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class CommentsSheet extends StatefulWidget {
  final int postIndex;
  final List<String> Function() getComments;
  final void Function(String) addComment;

  const CommentsSheet({
    super.key,
    required this.postIndex,
    required this.getComments,
    required this.addComment,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    widget.addComment(comment);
    _commentController.clear();

    setState(() {}); // refresh to show new comment
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.getComments();

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple[800])),
            const SizedBox(height: 12),
            Expanded(
              child: comments.isEmpty
                  ? const Center(child: Text('No comments yet.'))
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const Icon(Icons.comment, color: Colors.purple),
                        title: Text(comments[index]),
                      ),
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.send),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
