import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../main.dart'; // for navigatorKey

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  /// INIT – call once in main()
  static Future<void> init() async {
    const androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings();

    const settings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload);
      },
    );
  }

  /// Show local notification
  static Future<void> showChatNotification({
    required String title,
    required String body,
    required String chatId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Incoming chat messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: chatId,
    );
  }

  /// Handle notification tap
  static void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    navigatorKey.currentState?.pushNamed(
      '/chat',
      arguments: payload,
    );
  }

  /// Listen to foreground FCM messages
  static void listenForegroundMessages({
    required String? currentChatId,
  }) {
    FirebaseMessaging.onMessage.listen((message) {
      final data = message.data;

      // Do not show notification if chat is open
      if (currentChatId == data['chatId']) return;

      showChatNotification(
        title: data['senderName'] ?? 'New message',
        body: data['message'] ?? '',
        chatId: data['chatId'],
      );
    });
  }
}
