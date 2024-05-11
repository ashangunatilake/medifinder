import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/firebase_options.dart';
import 'package:medifinder/pages/home.dart';
import 'package:medifinder/pages/login.dart';
import 'package:medifinder/pages/search.dart';
import 'package:medifinder/pages/signup.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
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
      home: const SignUpPage(),
      routes: {
        '/home': (context) => const Home(),
        '/login': (context) => const LoginPage()
      },
    );
  }
}
