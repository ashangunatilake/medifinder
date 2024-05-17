import 'package:cloud_firestore/cloud_firestore.dart' as firestore_interface;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/pages/home.dart';
import 'package:medifinder/pages/activities.dart';
import 'package:medifinder/pages/addreview.dart';
import 'package:medifinder/pages/order.dart';
import 'package:medifinder/pages/pharamacydetails.dart';
import 'package:medifinder/pages/profile.dart';
import 'package:medifinder/pages/reviews.dart';
import 'package:medifinder/pages/search.dart';
import 'package:medifinder/pages/signup.dart';
import 'package:medifinder/pages/login.dart';
import 'package:medifinder/pages/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  firestore_interface.FirebaseFirestore.instance.settings =
      const firestore_interface.Settings(
    persistenceEnabled: true,
  );
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
        '/home': (context) => const Home(),
        '/search': (context) => const Search(),
        '/pharmacydetails': (context) => const PharmacyDetails(),
        '/reviews': (context) => const Reviews(),
        '/addreview': (context) => const AddReview(),
        '/order': (context) => const Order(),
        '/profile': (context) => const Profile(),
        '/activities': (context) => const Activities()
      },
    );
  }
}
