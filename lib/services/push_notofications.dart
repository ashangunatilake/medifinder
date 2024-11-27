import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medifinder/main.dart';

class PushNotifications {
  // Create an instance of firebase messaging
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Function to initialize notifications
  static Future initNotifications() async {
    // Request permission from user
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true
    );
    final fCMToken = await _firebaseMessaging.getToken();
    print("device token: $fCMToken");
  }

  Future<String?> getDeviceToken() async {
    // Fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    return fCMToken;
  }

  Future addDeviceToken(String userRole, String userID) async {
    // Fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    print("device token: $fCMToken");

    late DocumentSnapshot<Map<String, dynamic>> userDoc;
    if(userRole == 'customer') {
      userDoc = await FirebaseFirestore.instance.collection('Users').doc(userID).get();
    } else if(userRole == 'pharmacy') {
      userDoc = await FirebaseFirestore.instance.collection('Pharmacies').doc(userID).get();
    }

    if(userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data();
      if(userData != null) {
        List<String> tokens =  List<String>.from(userData['FCMTokens']);
        if(!tokens.contains(fCMToken)) {
          tokens.add(fCMToken!);
          await userDoc.reference.update({'FCMTokens': tokens,});
        }
      }
      else{
        throw Exception('Error fetching user data.');
      }
    } else {
      throw Exception('Error fetching user.');
    }
  }

  // Initialize local notifications
  Future localNotiInit() async {
    // Initialize the plugin, app_icon needs to be added as a drawable resource
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Request notification permission for android 13 or above
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // On tap notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!.pushNamed('/message');
  }

  // Show a simple notification
  static Future showSimpleNotification({required String title, required  String body, required String payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker'
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails, payload: payload);
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  static Future<String> getAccessToken() async {
    // Load the serviceaccount.json file
    final file = File('lib/serviceaccount.json');

    if (!await file.exists()) {
      throw Exception("Service account JSON file not found.");
    }

    // Parse the JSON file
    final serviceAccountJson = jsonDecode(await file.readAsString());

    List<String> scopes =
    [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();
    return credentials.accessToken.data;
  }

  void sendNotificationToCustomer(String deviceToken, bool accepted, bool completed, String drugName, String pharmacyName, [String? reason]) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/medifinder-564fa/messages:send';

    if(!completed) {
      if(accepted) {
        final Map<String, dynamic> message =
        {
          'message':
          {
            'token': deviceToken,
            'notification':
            {
              'title': "Order Accepted",
              'body': "Your order for $drugName has been accepted by $pharmacyName."
            }
          }
        };

        final http.Response response = await http.post(
          Uri.parse(endpointFirebaseCloudMessaging),
          headers: <String, String>
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverAccessTokenKey'
          },
          body: jsonEncode(message),
        );

        if(response.statusCode == 200) {
          print('Notification sent successfully.');
        } else {
          print('Failed, to send FCM message: ${response.statusCode}');
        }
      }
      else {
        final Map<String, dynamic> message =
        {
          'message':
          {
            'token': deviceToken,
            'notification':
            {
              'title': "Order Canceled",
              'body': "Your order for $drugName has been cancelled by $pharmacyName due to $reason."
            }
          }
        };

        final http.Response response = await http.post(
          Uri.parse(endpointFirebaseCloudMessaging),
          headers: <String, String>
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverAccessTokenKey'
          },
          body: jsonEncode(message),
        );

        if(response.statusCode == 200) {
          print('Notification sent successfully.');
        } else {
          print('Failed, to send FCM message: ${response.statusCode}');
        }
      }
    } else {
      final Map<String, dynamic> message =
      {
        'message':
        {
          'token': deviceToken,
          'notification':
          {
            'title': "Order Completed",
            'body': "Your order for $drugName at $pharmacyName has been completed."
          }
        }
      };

      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessTokenKey'
        },
        body: jsonEncode(message),
      );

      if(response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Failed, to send FCM message: ${response.statusCode}');
      }
    }
  }

  void sendNotificationToPharmacy(String deviceToken, bool completed, String drugName, String customerName) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/medifinder-564fa/messages:send';

    if(!completed) {
      final Map<String, dynamic> message =
      {
        'message':
        {
          'token': deviceToken,
          'notification':
          {
            'title': "New Order Received",
            'body': "A new order for $drugName has been placed by $customerName."
          }
        }
      };

      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessTokenKey'
        },
        body: jsonEncode(message),
      );

      if(response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Failed, to send FCM message: ${response.statusCode}');
      }
    } else {
      final Map<String, dynamic> message =
      {
        'message':
        {
          'token': deviceToken,
          'notification':
          {
            'title': "Order Completed",
            'body': "The order for $drugName to $customerName has been completed."
          }
        }
      };

      final http.Response response = await http.post(
        Uri.parse(endpointFirebaseCloudMessaging),
        headers: <String, String>
        {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverAccessTokenKey'
        },
        body: jsonEncode(message),
      );

      if(response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Failed, to send FCM message: ${response.statusCode}');
      }
    }
  }

  void notifyLowStock(String deviceToken, String drugName) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/medifinder-564fa/messages:send';

    final Map<String, dynamic> message =
    {
      'message':
      {
        'token': deviceToken,
        'notification':
        {
          'title': "Low Stock Alert",
          'body': "The stock for $drugName is running low. Please restock soon."
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>
      {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if(response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed, to send FCM message: ${response.statusCode}');
    }
  }
}