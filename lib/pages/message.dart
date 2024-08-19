import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationMessage extends StatefulWidget {
  const NotificationMessage({super.key});

  @override
  State<NotificationMessage> createState() => _NotificationMessageState();
}

class _NotificationMessageState extends State<NotificationMessage> {
  List<Map<String, dynamic>> notifications = [];
  String role = "";

  @override
  void initState() {
    super.initState();
    checkRole();
    _loadNotifications();  // Load stored notifications on initialization
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleIncomingData();  // Handle any new incoming data
  }

  @override
  void dispose() {
    super.dispose();
    _removeReadNotifications(notifications);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

  Future<void> _removeReadNotifications(List<Map<String, dynamic>> notifications) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('notifications');
    notifications.removeWhere((element) => element['read'] == true);
    print(notifications.length);
    final List<String> jsonList = notifications.map((e) => jsonEncode(e)).toList();
    prefs.setStringList('notifications', jsonList);
  }

  void _handleIncomingData() {
    final data = ModalRoute.of(context)!.settings.arguments;
    if (data != null) {
      Map<String, dynamic> newNotification = {};

      // For background and terminated state
      if (data is RemoteMessage) {
        newNotification = {
          'title': data.notification?.title ?? "No Title",
          'body': data.notification?.body ?? "No Body",
          'timestamp': data.sentTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'read': false,
        };
      }
      // For foreground state
      if (data is NotificationResponse) {
        final decodedPayload = jsonDecode(data.payload!);
        newNotification = {
          'title': decodedPayload['title'] ?? "No Title",
          'body': decodedPayload['body'] ?? "No Body",
          'timestamp': decodedPayload['timestamp'] ?? DateTime.now().toIso8601String(),
          'read': false,
        };
      }

      setState(() {
        notifications.insert(0, newNotification);  // Add new notification at the top
      });
    }
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
        title: Text('Notifications'),
        backgroundColor: Colors.white38,
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
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
                    setState(() {
                      notifications[index]['read'] = true;
                      
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: notification['read'] ? 0.6 : 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: notification['read'] ? Colors.grey[200] : Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
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
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            notification['body'],
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _formatTimestamp(DateTime.parse(notification['timestamp'])),
                                style: TextStyle(
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
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Activities"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: 2,
        onTap: (int n) {
          if (n == 0) {
            if (role == 'customer') {
              _removeReadNotifications(notifications);
              Navigator.pushNamedAndRemoveUntil(context, '/customer_home', (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_home', (route) => false);
            }
          }
          if (n == 1) {
            if (role == 'customer') {
              Navigator.pushNamedAndRemoveUntil(context, '/activities', (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
            }
          }
          if (n == 3) {
            if (role == 'customer') {
              Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_profile', (route) => false);
            }
          }
        },
        selectedItemColor: const Color(0xFF0CAC8F),
      ),
    );
  }
}
