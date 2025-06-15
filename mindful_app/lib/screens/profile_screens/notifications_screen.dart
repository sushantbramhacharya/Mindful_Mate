import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindful_app/config.dart'; // Assuming Config.baseUrl is defined here

/// Represents a single notification entry.
/// In a real app, this would be fetched from a backend.
class NotificationItem {
  final String id;
  final String type; // e.g., 'comment', 'upvote'
  final String message;
  final String relatedPostId; // ID of the post the notification is about
  final String? triggeringUserId; // User who commented/upvoted
  final DateTime createdAt;
  final bool isRead; // To mark as read/unread

  NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    required this.relatedPostId,
    this.triggeringUserId,
    required this.createdAt,
    this.isRead = false,
  });

  // Factory constructor to create a NotificationItem from a JSON map
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    String? rawCreatedAtString;

    // Handle MongoDB's $date format or direct ISO string
    if (json['created_at'] != null && json['created_at'] is Map && json['created_at'].containsKey('\$date')) {
      rawCreatedAtString = json['created_at']['\$date'] as String?;
    } else if (json['created_at'] is String) {
      rawCreatedAtString = json['created_at'] as String?;
    }

    DateTime parsedDate;
    try {
      parsedDate = rawCreatedAtString != null ? DateTime.parse(rawCreatedAtString).toLocal() : DateTime.now();
    } catch (e) {
      print('Error parsing notification date: $rawCreatedAtString - $e');
      parsedDate = DateTime.now(); // Fallback to current time on parsing error
    }

    return NotificationItem(
      id: json['_id'] as String? ?? UniqueKey().toString(), // Use UniqueKey as fallback for ID
      type: json['type'] as String? ?? 'general',
      message: json['message'] as String? ?? 'New activity on your post.',
      relatedPostId: json['related_post_id'] as String? ?? '',
      triggeringUserId: json['triggering_user_id'] as String?,
      createdAt: parsedDate,
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

/// A StatefulWidget that displays a list of notifications.
/// It fetches (or simulates fetching) notifications and displays them.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Fetch notifications when the screen initializes
  }

  /// Formats a DateTime object into a user-friendly string.
  String _formatDate(DateTime dateTime) {
    // Example: "Just now", "5 mins ago", "Yesterday 10:30 AM", "May 15, 2024"
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday ${_timeOfDay(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${_timeOfDay(dateTime)}';
    }
  }

  String _timeOfDay(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }


  /// Simulates fetching notifications from a backend.
  /// In a real application, this would make an HTTP GET request to your Flask backend.
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: In a real app, replace this simulated data with an actual API call
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('token') ?? '';
    // final url = Uri.parse('${Config.baseUrl}/api/notifications');
    // try {
    //   final response = await http.get(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Authorization': 'Bearer $token',
    //     },
    //   );
    //   if (response.statusCode == 200) {
    //     final List<dynamic> fetchedJson = jsonDecode(response.body);
    //     _notifications = fetchedJson.map((json) => NotificationItem.fromJson(json)).toList();
    //   } else {
    //     _error = 'Failed to load notifications: ${response.statusCode}';
    //     print('Failed to load notifications: ${response.statusCode} ${response.body}');
    //   }
    // } catch (e) {
    //   _error = 'Error fetching notifications: $e';
    //   print('Error fetching notifications: $e');
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }

    // --- Simulated Data for Demonstration ---
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    setState(() {
      _notifications = [
        NotificationItem(
          id: '1',
          type: 'comment',
          message: 'User A commented on your post "My First Post".',
          relatedPostId: 'post123',
          triggeringUserId: 'userA_id',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          type: 'upvote',
          message: 'User B upvoted your post "Thought for the Day".',
          relatedPostId: 'post456',
          triggeringUserId: 'userB_id',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        NotificationItem(
          id: '3',
          type: 'comment',
          message: 'User C replied to your comment on "Healthy Habits".',
          relatedPostId: 'post789',
          triggeringUserId: 'userC_id',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        NotificationItem(
          id: '4',
          type: 'upvote',
          message: 'Someone upvoted your post "Learning Flutter".',
          relatedPostId: 'post101',
          triggeringUserId: null, // Can be null if user is anonymous or not tracked
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
        NotificationItem(
          id: '5',
          type: 'general',
          message: 'Welcome to new Mindful App features!',
          relatedPostId: '',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          isRead: true,
        ),
      ];
      _isLoading = false;
    });
    // --- End Simulated Data ---
  }

  // Toggles the read status of a notification (client-side for now)
  void _toggleNotificationReadStatus(String id) {
    setState(() {
      final index = _notifications.indexWhere((item) => item.id == id);
      if (index != -1) {
        // Create a new NotificationItem with updated isRead status
        _notifications[index] = NotificationItem(
          id: _notifications[index].id,
          type: _notifications[index].type,
          message: _notifications[index].message,
          relatedPostId: _notifications[index].relatedPostId,
          triggeringUserId: _notifications[index].triggeringUserId,
          createdAt: _notifications[index].createdAt,
          isRead: !_notifications[index].isRead,
        );
      }
    });
    // TODO: In a real app, send API call to backend to update read status
  }

  // Icon based on notification type
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'comment':
        return Icons.comment;
      case 'upvote':
        return Icons.thumb_up;
      default:
        return Icons.info;
    }
  }

  // Color based on notification type
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'comment':
        return Colors.blueAccent;
      case 'upvote':
        return Colors.green;
      default:
        return Colors.purple[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No new notifications.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: notification.isRead ? 1 : 4, // Less elevation if read
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: notification.isRead
                                  ? Colors.grey[300]!
                                  : _getNotificationColor(notification.type),
                              width: notification.isRead ? 1 : 2, // Thicker border if unread
                            ),
                          ),
                          color: notification.isRead ? Colors.grey[50] : Colors.white, // Lighter background if read
                          child: ListTile(
                            leading: Icon(
                              _getNotificationIcon(notification.type),
                              color: _getNotificationColor(notification.type),
                              size: 30,
                            ),
                            title: Text(
                              notification.message,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                color: notification.isRead ? Colors.grey[700] : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              _formatDate(notification.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            trailing: notification.isRead
                                ? const Icon(Icons.check_circle_outline, color: Colors.green)
                                : const Icon(Icons.circle, color: Colors.purple), // Indicator for unread
                            onTap: () {
                              _toggleNotificationReadStatus(notification.id);
                              // TODO: Navigate to the related post using notification.relatedPostId
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
