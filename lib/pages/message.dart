import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationMessage extends StatefulWidget {
  const NotificationMessage({super.key});

  @override
  State<NotificationMessage> createState() => _NotificationMessageState();
}

class _NotificationMessageState extends State<NotificationMessage> {
  Map payload = {};
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;
    // For background and terminated state
    if(data is RemoteMessage) {
      payload = data.data;
    }
    // For foreground state
    if(data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
    }


    return Scaffold(
      appBar: AppBar(title: Text('Your Message')),
      body: Center(child: Text(payload.toString()),)
    );
  }
}
