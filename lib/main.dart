import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medifinder/pages/drugs_stock.dart';
import 'package:medifinder/pages/home.dart';
import 'package:medifinder/pages/login.dart';
import 'package:medifinder/pages/signup.dart';
import 'package:medifinder/pages/PharmacyRegister.dart';
import 'package:medifinder/pages/inventory.dart';
import 'package:medifinder/pages/orders.dart';
import 'package:medifinder/pages/orderDetails.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        //home: const LoginPage());
        home: RegisterPage());
  }
}
