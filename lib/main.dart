import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore_interface;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medifinder/pages/changepassword.dart';
import 'package:medifinder/pages/customer/home.dart';
import 'package:medifinder/pages/customer/activities.dart';
import 'package:medifinder/pages/customer/addreview.dart';
import 'package:medifinder/pages/customer/order.dart';
import 'package:medifinder/pages/customer/pharamacydetails.dart';
import 'package:medifinder/pages/customer/profile.dart';
import 'package:medifinder/pages/customer/reviews.dart';
import 'package:medifinder/pages/customer/search.dart';
import 'package:medifinder/pages/customer/signup.dart';
import 'package:medifinder/pages/customer/login.dart';
import 'package:medifinder/pages/customer/splashscreen.dart';
import 'package:medifinder/pages/forgotpassword.dart';
import 'package:medifinder/pages/pharmacy/add_item.dart';
import 'package:medifinder/pages/pharmacy/drugs_stock.dart';
import 'package:medifinder/pages/pharmacy/pharmacyprofile.dart';
import 'package:medifinder/pages/pharmacy/inventory.dart';
import 'package:medifinder/pages/pharmacy/orderDetails.dart';
import 'package:medifinder/pages/pharmacy/orders.dart';
import 'package:medifinder/pages/resetpassword.dart';
import 'package:medifinder/services/push_notofications.dart';
import 'package:medifinder/pages/message.dart';

import 'pages/mapview.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print('Some notification received in background...');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  firestore_interface.FirebaseFirestore.instance.settings =
      const firestore_interface.Settings(
    persistenceEnabled: true,
  );

  // Initialize firebase messaging
  await PushNotifications.initNotifications();

  // Initialize local notifications
  await PushNotifications().localNotiInit();

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // On background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Background notification tapped');
      navigatorKey.currentState!.pushNamed('/message', arguments: message);
    }
  });

  // To handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print('Got a message in foreground');
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  // For handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print('Launched in terminated state');
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed('/message', arguments: message);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medi Finder',
      theme: ThemeData(
        fontFamily: "Poppins",
      ),
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/customer_home': (context) => const CustomerHome(),
        '/pharmacy_home': (context) => Inventory(),
        '/search': (context) => const Search(),
        '/pharmacydetails': (context) => const PharmacyDetails(),
        '/reviews': (context) => const Reviews(),
        '/addreview': (context) => const AddReview(),
        '/order': (context) => const Order(),
        '/profile': (context) => const Profile(),
        '/activities': (context) => const Activities(),
        '/mapview': (context) => MapView(),
        '/orders': (context) => Orders(),
        '/order_details': (context) => OrderDetails(),
        '/pharmacy_profile': (context) => const PharmacyProfile(),
        '/stock': (context) => DrugStock(),
        '/adddrug': (context) => AddItem(),
        '/changepassword': (context) => const ChangePassword(),
        '/forgotpassword': (context) => const ForgotPassword(),
        '/resetpassword': (context) => const ResetPassword(),
        '/message': (context) => const NotificationMessage(),
      },
    );
  }
}
