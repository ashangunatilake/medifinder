import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationMessage extends StatefulWidget {
  const NotificationMessage({super.key});

  @override
  State<NotificationMessage> createState() => _NotificationMessageState();
}

class _NotificationMessageState extends State<NotificationMessage> {
  List<Map<String, dynamic>> notifications = [];
  late SharedPreferences prefs;
  String role = "";

  @override
  void initState() {
    super.initState();
    checkRole();
    _loadNotifications();  // Load stored notifications on initialization
  }

  Future<void> checkRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    role = prefs.getString('role') ?? 'customer';
    if (!isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _loadNotifications() async {
    prefs = await SharedPreferences.getInstance();
    prefs.reload().then((value) {
      List<String> storedNotifications = prefs.getStringList('notifications') ?? [];
      print("Stored Noifications - ${storedNotifications.length}");
      // Decode stored notifications and add them to the list
      setState(() {
        notifications = storedNotifications.map((notification) {
          return jsonDecode(notification) as Map<String, dynamic>;
        }).toList();
      });
    });

  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return "Unknown Time";
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white38,
        elevation: 0.0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              print(notifications[index]['timestamp']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: () {
                    notifications[index]['read'] = true;
                    prefs.remove('notifications');
                    notifications.removeAt(index);
                    final List<String> jsonList = notifications.map((e) => jsonEncode(e)).toList();
                    prefs.setStringList('notifications', jsonList);
                    List<String> storedNotifications = prefs.getStringList('notifications') ?? [];
                    print("Stored Noifications - ${storedNotifications.length}");
                    setState(() {
                      notifications = storedNotifications.map((notification) {
                        return jsonDecode(notification) as Map<String, dynamic>;
                      }).toList();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          notification['body'],
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _formatTimestamp(DateTime.parse(notification['timestamp'])),
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}