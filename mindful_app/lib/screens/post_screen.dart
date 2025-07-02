import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindful_app/config.dart'; // Assuming this holds your base URL
import 'package:shared_preferences/shared_preferences.dart';

/// A StatelessWidget that displays an individual post's information.
/// It includes the post's title, content, timestamp, category, upvotes,
/// and provides callbacks for comment and upvote actions.
class PostWidget extends StatelessWidget {
  final String postId; // Unique identifier for the post
  final String title;
  final String content;
  final String timestamp;
  final String category;
  final int upvotes;
  final VoidCallback onCommentPressed;
  final VoidCallback onUpvotePressed;

  const PostWidget({
    super.key,
    required this.postId,
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
            // Post Title
            Text(
              title,
              style: TextStyle(
                color: Colors.purple[800],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Post Content
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
                // Post Timestamp
                Text(
                  timestamp,
                  style: TextStyle(
                    color: Colors.purple[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // Post Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            // Action buttons (Upvote and Comment)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Upvote Button
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.purple),
                  onPressed: onUpvotePressed,
                ),
                Text(
                  '$upvotes',
                  style: TextStyle(
                      color: Colors.purple[700], fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                // Comment Button
                TextButton.icon(
                  onPressed: onCommentPressed,
                  icon: const Icon(Icons.comment, size: 20, color: Colors.purple),
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

/// A StatefulWidget that displays a list of posts,
/// allows users to create new posts, filter posts by category,
/// search posts, upvote posts, and view/add comments to posts.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  // Text editing controllers for input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // State variables for post creation/filtering
  String _selectedCategory = 'General';
  String _filterCategory = 'All';
  String _searchQuery = '';

  // Predefined list of categories
  final List<String> _categories = [
    'General',
    'Tech',
    'Lifestyle',
    'Health',
    'Education',
  ];

  // List to hold fetched post data. Each post includes its ID, and comments as a list of maps.
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true; // Tracks if posts are currently being loaded
  String? _error; // Stores error message if fetching fails

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // Fetch posts when the screen initializes
  }

  /// Formats a DateTime object into a "Month/Day/Year Hour:Minute" string.
  String _formatDate(DateTime dateTime) {
    return "${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  /// Fetches posts dynamically from the backend API.
  /// Handles loading state, error display, and sorts posts by creation date in descending order.
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${Config.baseUrl}/api/posts');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedPosts = jsonDecode(response.body);
        setState(() {
          _posts = fetchedPosts.map((post) {
            // Safely extract and type-cast data, providing default values if null
            final String postId = post['_id'] as String? ?? '';
            final String title = post['title'] as String? ?? 'No Title';
            final String content = post['content'] as String? ?? 'No Content';
            final String category = post['category'] as String? ?? 'Uncategorized';

            // Parse and format the timestamp from 'created_at' (ISO 8601 string)
            String timestamp;
            String? rawCreatedAtString; // To store the string for DateTime.parse

            // Check if 'created_at' is a Map and contains '$date'
            if (post['created_at'] != null && post['created_at'] is Map && post['created_at'].containsKey('\$date')) {
              rawCreatedAtString = post['created_at']['\$date'] as String?;
            } else if (post['created_at'] is String) {
              // Handle cases where 'created_at' might be a direct string
              rawCreatedAtString = post['created_at'] as String?;
            }

            if (rawCreatedAtString != null) {
              try {
                // Parse the UTC time from backend and convert to local time zone for display
                DateTime createdAt = DateTime.parse(rawCreatedAtString);
                timestamp = _formatDate(createdAt.toLocal());
              } catch (e) {
                print('Error parsing date for post $postId: $rawCreatedAtString - $e');
                timestamp = 'Invalid Date Format'; // Specific error message for parsing issues
              }
            } else {
              timestamp = 'No Date Available'; // Specific message for missing date
            }

            // Ensure comments are treated as a list of dynamic maps
            final List<dynamic> comments = post['comments'] is List
                ? List<dynamic>.from(post['comments'])
                : <dynamic>[]; // Default to empty list if not present or invalid
            final int upvotes = post['upvotes'] as int? ?? 0; // Default to 0 if not present

            return {
              'postId': postId,
              'title': title,
              'content': content,
              'timestamp': timestamp,
              'category': category,
              'comments': comments,
              'upvotes': upvotes,
              'raw_created_at': rawCreatedAtString, // Keep the actual date string for sorting
            };
          }).toList();

          // Sort posts by 'raw_created_at' in descending order (newest first)
          _posts.sort((a, b) {
            // Defensive check: Ensure 'raw_created_at' is a String before parsing
            if (a['raw_created_at'] is! String || b['raw_created_at'] is! String) {
              // Log a warning if the type is unexpected
              print('Warning: raw_created_at is not a String during sorting. '
                    'A: ${a['raw_created_at']?.runtimeType}, B: ${b['raw_created_at']?.runtimeType}');
              // Handle sorting for unexpected types:
              // Push non-string dates to the end of the list.
              if (a['raw_created_at'] is! String && b['raw_created_at'] is String) return 1; // a comes after b
              if (a['raw_created_at'] is String && b['raw_created_at'] is! String) return -1; // a comes before b
              return 0; // Both are not strings or both are null, treat as equal
            }

            final DateTime dateA = DateTime.parse(a['raw_created_at']);
            final DateTime dateB = DateTime.parse(b['raw_created_at']);
            return dateB.compareTo(dateA); // Compare B to A for descending order
          });
        });
      } else {
        setState(() {
          _error = 'Failed to load posts: ${response.statusCode} ${response.body}';
        });
        print('Failed to load posts: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching posts: $e';
      });
      print('Error fetching posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sends a new post's data (title, content, category) to the backend API.
  /// Refreshes the post list upon successful creation.
  Future<bool> sendPostToServer({
    required String title,
    required String content,
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${Config.baseUrl}/api/posts');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchPosts(); // Refresh posts after successful creation
        return true;
      } else {
        print('Failed to send post: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending post: $e');
      return false;
    }
  }

  /// Handles adding a new post from user input.
  /// Validates input and calls `sendPostToServer`.
  void _addPost() async {
    final title = _titleController.text.trim();
    final content = _postController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty.')),
      );
      return;
    }

    final success = await sendPostToServer(
      title: title,
      content: content,
      category: _selectedCategory,
    );

    if (success) {
      // Clear inputs and reset category on successful post
      _selectedCategory = 'General';
      _titleController.clear();
      _postController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post. Please try again.')),
      );
    }
  }

  /// Increments the upvote count for a specific post via an API call.
  /// Updates the local state upon successful response.
  Future<void> _incrementUpvote(int index) async {
    final String postId = _posts[index]['postId']; // Get post ID from the list
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${Config.baseUrl}/api/posts/$postId/upvote');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          // Update the local upvotes count with the value from the backend response
          _posts[index]['upvotes'] = responseData['upvotes'];
        });
      } else {
        print('Failed to upvote post: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upvote post.')),
        );
      }
    } catch (e) {
      print('Error upvoting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error upvoting post.')),
      );
    }
  }

  /// Opens the comments sheet for a specific post.
  /// Passes the post's ID to the CommentsSheet.
  void _openComments(int index) {
    final String postId = _posts[index]['postId']; // Get post ID from the list
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CommentsSheet(
        postId: postId, // Pass the post ID to CommentsSheet
      ),
    );
  }

  /// Computes the list of posts filtered by category and search query.
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
    // Dispose controllers to prevent memory leaks
    _titleController.dispose();
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
              const SizedBox(height: 20),
              // Search input field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val; // Update search query and trigger rebuild
                  });
                },
              ),
              const SizedBox(height: 12),
              // Filter by category dropdown
              Row(
                children: [
                  const Text('Filter by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _filterCategory,
                    items: ['All', ..._categories]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _filterCategory = val; // Update filter category and trigger rebuild
                        });
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              // Post title input field
              TextField(
                controller: _titleController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Post title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Post content input field
              TextField(
                controller: _postController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Write your post here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _addPost(),
              ),
              const SizedBox(height: 8),
              // Post category dropdown and Post button
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
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Display area for posts
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading indicator
              : _error != null
                  ? Center( // Show error message with retry button
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!),
                          ElevatedButton(
                            onPressed: _fetchPosts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredPosts.isEmpty
                      ? const Center(child: Text('No posts found.')) // Message if no posts
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 4),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = _filteredPosts[index];
                            // Pass all required data to PostWidget
                            return PostWidget(
                              postId: post['postId'],
                              title: post['title'],
                              content: post['content'],
                              timestamp: post['timestamp'],
                              category: post['category'],
                              upvotes: post['upvotes'],
                              onCommentPressed: () => _openComments(index),
                              onUpvotePressed: () => _incrementUpvote(index),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

/// A StatefulWidget that displays and allows adding comments to a specific post.
/// It fetches comments from the backend and sends new comments.
class CommentsSheet extends StatefulWidget {
  final String postId; // The ID of the post for which comments are being managed

  const CommentsSheet({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = []; // List to store fetched comments (each is a map)
  bool _isFetchingComments = true; // Tracks if comments are being loaded
  String? _commentError; // Stores error message if fetching comments fails

  @override
  void initState() {
    super.initState();
    _fetchComments(); // Fetch comments when the sheet initializes
  }

  /// Formats a DateTime object into a "Month/Day/Year Hour:Minute" string.
  String _formatDate(DateTime dateTime) {
    return "${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  /// Fetches comments for the current post from the backend.
  Future<void> _fetchComments() async {
    setState(() {
      _isFetchingComments = true;
      _commentError = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${Config.baseUrl}/api/posts/${widget.postId}/comments');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedComments = jsonDecode(response.body);
        setState(() {
          _comments = fetchedComments; // Update the comments list
        });
      } else {
        setState(() {
          _commentError = 'Failed to load comments: ${response.statusCode} ${response.body}';
        });
        print('Failed to load comments: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _commentError = 'Error fetching comments: $e';
      });
      print('Error fetching comments: $e');
    } finally {
      setState(() {
        _isFetchingComments = false;
      });
    }
  }

  /// Sends a new comment to the backend for the current post.
  /// Refreshes the comment list upon successful submission.
  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${Config.baseUrl}/api/posts/${widget.postId}/comments');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'comment_content': commentText}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentController.clear(); // Clear input field
        await _fetchComments(); // Re-fetch comments to show the new one
      } else {
        print('Failed to add comment: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment.')),
        );
      }
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding comment.')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // Adjusts for keyboard
      child: Container(
        height: 400, // Fixed height for the modal sheet
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            const SizedBox(height: 12),
            // Display area for comments
            _isFetchingComments
                ? const Center(child: CircularProgressIndicator()) // Show loading
                : _commentError != null
                    ? Center(child: Text(_commentError!)) // Show error
                    : Expanded(
                        child: _comments.isEmpty
                            ? const Center(child: Text('No comments yet.')) // No comments message
                            : ListView.builder(
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  final comment = _comments[index];
                                  final String commentContent = comment['content'] as String? ?? 'No content';
                                  final String commentUserId = comment['username'] as String? ?? 'Unknown User';
                                  // Parse and format comment timestamp
                                  String commentTimestamp;
                                  String? rawCommentCreatedAtString;

                                  // Check if 'created_at' is a Map and contains '$date'
                                  if (comment['created_at'] != null && comment['created_at'] is Map && comment['created_at'].containsKey('\$date')) {
                                    rawCommentCreatedAtString = comment['created_at']['\$date'] as String?;
                                  } else if (comment['created_at'] is String) {
                                    // Handle cases where 'created_at' might be a direct string
                                    rawCommentCreatedAtString = comment['created_at'] as String?;
                                  }

                                  if (rawCommentCreatedAtString != null) {
                                    try {
                                      commentTimestamp = _formatDate(DateTime.parse(rawCommentCreatedAtString).toLocal());
                                    } catch (e) {
                                      print('Error parsing comment date: $rawCommentCreatedAtString - $e');
                                      commentTimestamp = 'Invalid Date Format';
                                    }
                                  } else {
                                    commentTimestamp = 'N/A';
                                  }

                                  return ListTile(
                                    leading: const Icon(Icons.comment, color: Colors.purple),
                                    title: Text(commentContent),
                                    // Display user ID and timestamp for each comment
                                    subtitle: Text('by $commentUserId on $commentTimestamp'),
                                  );
                                },
                              ),
                      ),
            // Input field and button for adding new comments
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
