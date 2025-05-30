// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../chat/screens/chat_screen.dart';

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    // ignore: non_constant_identifier_names
    final FCMToken = await _firebaseMessaging.getToken();

    print("Token: $FCMToken");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Handle background/terminated messages when app is opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Check for initial message (when app was terminated)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    print('got message from firebase');
    if (message.data['screen'] == 'chat') {
      final chatId = message.data['chatId'];
      // Get the navigator key from your app's context
      final context = navigatorKey.currentContext;
      if (context != null) {
        print('GOT MESSAGE');
        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ChatScreen(
                  chatId: message.data['chatId'],
                  chatName: message.data['chatName'],
                  photoUrl: message.data['photoLink'],
                  anotherUserId: message.data['anotherUserId'],
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }
    }
  }
}

// Add this to your global variables (usually in main.dart)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
