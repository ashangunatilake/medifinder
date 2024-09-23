import 'package:flutter/material.dart';
import 'package:medifinder/pages/customer/customerview.dart';
import 'package:medifinder/pages/customer/home.dart';
import 'package:medifinder/pages/customer/loading.dart';
import 'package:medifinder/pages/customer/login.dart';
import 'package:medifinder/pages/pharmacy/inventory.dart';
import 'package:medifinder/pages/pharmacy/pharmacyview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String role = prefs.getString('role') ?? 'customer';
    // Simulate a delay for the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      if(role == 'customer') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerView()),);
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PharmacyView(),));
      }

    }
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Loading();
  }
}