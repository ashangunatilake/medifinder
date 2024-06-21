import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotifications {
  // Create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Function to initialize notifications
  Future<void> initNotifications() async {
    // Request permission from user
    await _firebaseMessaging.requestPermission();

    //Fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    //await _firebaseMessaging.deleteToken();
    print('Token: ${fCMToken} !!!');
  }
}