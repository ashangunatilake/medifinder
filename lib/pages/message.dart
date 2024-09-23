import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medifinder/controllers/customercontroller.dart';
import 'package:medifinder/controllers/pharmacycontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

class NotificationMessage extends StatefulWidget {
  const NotificationMessage({super.key});

  @override
  State<NotificationMessage> createState() => _NotificationMessageState();
}

class _NotificationMessageState extends State<NotificationMessage> {
  List<Map<String, dynamic>> notifications = [];
  late SharedPreferences prefs;
  String role = "";
  PharmacyController? pharmacyController;
  CustomerController? customerController;

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
    if (role == 'customer') {
      customerController = Get.put(CustomerController());
    } else {
      pharmacyController = Get.put(PharmacyController());
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          (role == 'customer')
              ? BottomNavigationBarItem(
            icon: customerController != null ? Obx(() => badges.Badge(
              showBadge: customerController!.activitiesCount.value > 0,
              badgeContent: Text('${customerController!.activitiesCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.shopping_cart),
            )) : const Icon(Icons.shopping_cart),
            label: "Activities",
          )
              : BottomNavigationBarItem(
            icon: pharmacyController != null ? Obx(() => badges.Badge(
              showBadge: pharmacyController!.ordersCount.value > 0,
              badgeContent: Text('${pharmacyController!.ordersCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.shopping_cart),
            )) : const Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          (role == 'customer')
              ? BottomNavigationBarItem(
            icon: customerController != null ? Obx(() => badges.Badge(
              showBadge: customerController!.notificationCount.value > 0,
              badgeContent: Text('${customerController!.notificationCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.notifications),
            )) : const Icon(Icons.notifications),
            label: "Notifications",
          )
              : BottomNavigationBarItem(
            icon: pharmacyController != null ? Obx(() => badges.Badge(
              showBadge: pharmacyController!.notificationCount.value > 0,
              badgeContent: Text('${pharmacyController!.notificationCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.notifications),
            )) : const Icon(Icons.notifications),
            label: "Notifications",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: 2,
        onTap: (int n) {
          if (n == 0) {
            if (role == 'customer') {
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
