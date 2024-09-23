import 'package:flutter/material.dart';

class Snackbars {
  static customToast({required String message, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey.withOpacity(0.9),
          ),
          child: Center(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }

  static successSnackBar({required String message, required BuildContext context, String title = "Success"}) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.lightGreen,
      icon: const Icon(Icons.check, color: Colors.white),
      context: context,
    );
  }

  static warningSnackBar({required String message, required BuildContext context, String title = "Warning"}) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
      context: context,
    );
  }

  static errorSnackBar({required String message, required BuildContext context, String title = "Error"}) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
      context: context,
    );
  }

  static void _showSnackBar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Icon icon,
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 6.0,
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}