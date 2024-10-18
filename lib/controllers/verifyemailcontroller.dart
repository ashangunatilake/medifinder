import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medifinder/snackbars/snackbar.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();
  BuildContext context;
  String email = "";

  VerifyEmailController(this.context);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    sendEmailVerification();
    setTimerForAutoRedirect();
  }

  Future<void> sendEmailVerification() async{
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      print("success");
      Snackbars.successSnackBar(message: "Email sent. Please check your inbox and verify your email.", context: context);
    } catch (e) {
      print("hello $e");
      Snackbars.errorSnackBar(message: "An error occurred. Please try again later", context: context);
    }
  }

  setTimerForAutoRedirect() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      print("Timer");
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        Snackbars.successSnackBar(message: "Email verified successfully.", context: context);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  checkEmailVerificationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    currentUser!.reload();
    if (currentUser.emailVerified) {
      Snackbars.successSnackBar(message: "Email verified successfully.", context: context);
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
    else {
      Snackbars.errorSnackBar(message: "Email address not verified", context: context);
    }
  }
}