import 'package:flutter/material.dart';
import 'package:medifinder/pages/home.dart';
import 'package:medifinder/pages/loading.dart';
import 'package:medifinder/pages/login.dart';
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

    // Simulate a delay for the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()),);
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

