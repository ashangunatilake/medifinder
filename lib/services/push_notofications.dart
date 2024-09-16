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
    print("device token: $fCMToken");
    return fCMToken;
  }

  Future addDeviceToken(String userRole, String userID) async {
    // Fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    print("device token: $fCMToken");

    late DocumentSnapshot<Map<String, dynamic>> userDoc;
    if(userRole == 'customer') {
      userDoc = await FirebaseFirestore.instance.collection('Users').doc(userID).get();

      // _firebaseMessaging.onTokenRefresh.listen((event) async {
      //   DocumentReference userDoc = FirebaseFirestore.instance.collection('Users').doc(userID);
      //   await userDoc.update({'FCMTokens': FieldValue.arrayUnion([fCMToken])});
      // });

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

    //await _firebaseMessaging.deleteToken();
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
    final serviceAccountJson =
    {
      "type": "service_account",
      "project_id": "medifinder-564fa",
      "private_key_id": "c1b805af62997137bd2710eb0ef3eefbbab6a684",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCuIWGViQ1TelqW\nKSAqdUVGbetRhAYrqV5HLcgq7b2bwHXYsQkZEpkgWd9kvDv3+x6ioKaffZdUD5oc\nmMqMOZ1wgRgJafXanQS9JC+7Cu9q2mNR0q0Cw1wTUw7/BJSWLFAz9X8hrhE7brBh\nhHMK9+c8Pb0t9PVu/z36wKQ8mx+QvVTKkyzvKClMwtpurAaFGFKJUTMYa7QadM7m\nq2ct8Sbie8b4CdcDgEUSH4hlv37xdrHXxaDsH8O6B65odQ0Jgt7gs+msB9V8sy4Q\nYt8da2htdTJafSf1QdkME83lh2GAjaAgs/XLKIw9g+cp+AobRtTzp8970gAEnMOX\nU8vJ9wj5AgMBAAECggEAE1RbS8kx9IFRive3vV7VONM82win0rLzZz1aygEoGiEM\nM+i7FNButRuk477NfWKf7PeeZ3f+k3ND7Ua8vUIsCvAZpfngM8tYWlKpBb9aAmeJ\nvOyBDhx3nSGMOZzdjaoPoSTwXuG+wfUwmTKlvqL0RUipNm/Jyu+EhtBZquyhXWSo\nFOj3FHkmr9tfeOMilKp36Ssl/sT+WBnnTHft2NedZBdv2rL1dYxsh3iJT9rcagfw\nrvaviJ2fYKKDCqFCOuv3kkh2zgOGLxxI8qQFXvYfTNtcB+wvRpXAoOgVYuxyND/h\n4qnrHNJqDk338eueNBMOu0s9OQAjdxvkTE6Jux3AcQKBgQDd+m12XJErOtK5Bmpv\nF8ycdkTQ3umChdWeF+lZKi64fCRtfBSwE1joT11twiRUNWQuiFZx2D8ZoC8Z4EeQ\n64wakcPTZ0FsLDSVoz/5Piw9vviPk2HJbg3r6A3V9QLpa0ljrTMfdY8BUkttUGTP\nIdlt+lRBTP1I/WQwDHqJKIORPQKBgQDI0ZaikeC+M6WfsQF17xszUykgmZwxwM99\nt7yE2yKYNvKa91Y7pYWhhhcO1kWu8YwQ2AZoouFVUlQI3J7nZudfM5hAjIyNv3bR\nDEwalfdEMcD6El5ctNeMNP6ajDMSic86WxbJE8cd4MTECEBJGI941muAPVnsk8DZ\nWbIF8RoabQKBgAHuPal74J9ZoZ+OWLqioFr0BGE0rx89fsAjQRpPbZyZJ8/z9lIZ\nuPo8Rnm/6IT6+eYVtXrEALh+ViqJctXl1pAcmHFsQntoXwS2KMZILiZTVOIazAzu\nchyNJiGoQeA52KePSBSL9zRxvMo0msvaZYO5W6Y9vy41Vfu9AAvVWF+ZAoGBAI6l\n2oPGbceN9lNWL7xvSXoO04MVuo7Y8ErULjSNWKiZN4H+uaGK9T6EenKOoFchu6Xn\nXb4MHVY3MfxNgw7K2QWWJ8uKSvkRjTv3qUOlTUyCrxqz25Ws3AP7TPPJLSo4/Bvu\nwmO5CdLea8b4OXny2U8zuI8ShYL4fZ+nCD8SQcGNAoGAfYV+zFaLYEdzRACZOgV8\ndsJmku8Dy9aTdjnkysKFgVBDC4D5yqtau+HZbF21yo4mhvGaxwfTi1xRwaUkPddK\non6DljX5v09yTdZvYwU+9jkhwQ9po4tpniedWEnsZghDC3xyM8GqYXcigu+7z111\naBkEcPx5QTKO1TtCH6JBeNY=\n-----END PRIVATE KEY-----\n",
      "client_email": "medifindernotifications@medifinder-564fa.iam.gserviceaccount.com",
      "client_id": "112457958599880813026",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/medifindernotifications%40medifinder-564fa.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes =
    [
      "https://www.googleapis.com/auth/firebase.messaging",
      //"https://www.googleapis.com/auth/userinfo.email",
      //"https://www.googleapis.com/auth/firebase.database",
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
}