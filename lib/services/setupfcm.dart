// lib/services/setupfcm.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newsapp/main.dart';
import 'package:newsapp/services/local_notif.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/widget/comment_page.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/services/bookmark_service.dart';
import 'comment_service.dart';

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Minta permission iOS (Android auto)
  await messaging.requestPermission();
  // Dapatkan token perangkat
  final token = await messaging.getToken();
  print("🔔 FCM Token: $token");

  final user = FirebaseAuth.instance.currentUser;
  if (user != null && token != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  // yang dieksekusi ketika tanpa onbackground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received foreground message: ${message.data}');

    if (message.notification != null) {
      final newsUrl = message.data['newsUrl'] ?? '';
      final commentId = message.data['commentUid'] ?? '';

      final title = message.notification?.title;
      final body = message.notification?.body;

      final commentUid = message.data['commentUid'];

      print("Judul: $title");
      print("Isi: $body");
      print("URL Berita: $newsUrl");
      print("UID Komentar: $commentUid");
      // Show local notification dengan payload
      LocalNotificationService().showNotificationWithPayload(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification!.title ?? 'Komentar Baru',
        body: message.notification!.body ?? '',
        newsUrl: newsUrl,
        commentId: commentId,
      );
    }
  });

  // // Handle when app is opened from notification (background/terminated)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📱 App opened from notification: ${message.data}');
    _handleNotificationNavigation(message);
  });

  // Check for initial message when app starts from terminated state
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print('📱 App started from notification: ${initialMessage.data}');
    // Delay untuk memastikan app sudah fully loaded
    Future.delayed(Duration(seconds: 2), () {
      _handleNotificationNavigation(initialMessage);
    });
  }
}

void _handleNotificationNavigation(RemoteMessage message) {
  final newsUrl = message.data['newsUrl'];
  final commentId = message.data['commentUid'];

  print('🔄 Handling navigation: newsUrl=$newsUrl, commentId=$commentId');

  if (newsUrl != null &&
      commentId != null &&
      navigatorKey.currentContext != null) {
    navigateToComment(newsUrl, commentId);
  }
}

Future<void> navigateToComment(String newsUrl, String commentId) async {
  final context = navigatorKey.currentContext!;
  final news =await CommentService().fetchNewsCommentData(newsUrl);
  // Navigasi ke CommentPage dengan targetCommentId
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CommentPage(
        news:
            news ??
            Bookmark(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Berita tidak ditemukan',
              source: '',
              date: '',
              multimedia: '',
              url: newsUrl,
            ),
        targetCommentId: commentId,
      ),
    ),
  );
}
