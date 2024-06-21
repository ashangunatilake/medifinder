import 'package:cloud_firestore/cloud_firestore.dart' as firestore_interface;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
import 'package:medifinder/pages/pharmacy/PharmacyRegister.dart';
import 'package:medifinder/pages/pharmacy/drugs_stock.dart';
import 'package:medifinder/pages/pharmacy/inventory.dart';
//import 'package:medifinder/pages/pharmacy/home.dart';
import 'package:medifinder/pages/pharmacy/orderDetails.dart';
import 'package:medifinder/services/push_notofications.dart';

import 'pages/mapview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  firestore_interface.FirebaseFirestore.instance.settings =
      const firestore_interface.Settings(
    persistenceEnabled: true,
  );
  await PushNotifications().initNotifications();
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

      home: const SplashScreen(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/customer_home': (context) => const CustomerHome(),
        '/pharmacy_home': (context) => RegisterPage(),
        '/search': (context) => const Search(),
        '/pharmacydetails': (context) => const PharmacyDetails(),
        '/reviews': (context) => const Reviews(),
        '/addreview': (context) => const AddReview(),
        '/order': (context) => const Order(),
        '/profile': (context) => const Profile(),
        '/activities': (context) => const Activities(),
        '/mapview': (context) => MapView(),
        '/inventory': (context) => Inventory(),
      },
    );
  }
}
