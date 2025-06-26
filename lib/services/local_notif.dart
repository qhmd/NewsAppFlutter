// lib/services/local_notif.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newsapp/main.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/widget/comment_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'setupfcm.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // dibawah ini nama fungsi yg dieksekusi ketika notif di pencat (notif local)
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handler ketika notifikasi di-tap di dalam aplikasi
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    print('Notification tapped with payload: $payload');
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        final newsUrl = data['newsUrl'];
        final commentId = data['commentId'];
        
        
        // Navigasi ke CommentPage dengan targetCommentId
        if (navigatorKey.currentContext != null && newsUrl != null && commentId != null) {
          navigateToComment(newsUrl, commentId);
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  
  Future<void> showNotificationWithPayload({
    required int id,
    required String title,
    required String body,
    required String newsUrl,
    required String commentId,
  }) async {
    final payload = jsonEncode({
      'newsUrl': newsUrl,
      'commentId': commentId,
    });

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'comment_channel',
      'Komentar',
      channelDescription: 'Notifikasi untuk komentar baru',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}