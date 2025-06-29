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
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Minta permission iOS (Android auto)
  await messaging.requestPermission();
  // Dapatkan token perangkat
  try {
    final token = await messaging.getToken();
    print("Token Fcm: $token");

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }

    // yang dieksekusi ketika tanpa onbackground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received foreground message: ${message.data}');

      if (message.notification != null) {
        final newsUrl = message.data['newsUrl'] ?? '';
        final commentId = message.data['commentUid'] ?? '';

        final title = message.notification?.title;
        final body = message.notification?.body;

        print("Judul: $title");
        print("Isi: $body");
        print("URL Berita: $newsUrl");
        print("UID Komentar: $commentId");

        // Tampilkan notifikasi lokal
        await LocalNotificationService().showNotificationWithPayload(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: title ?? 'Komentar Baru',
          body: body ?? '',
          newsUrl: newsUrl,
          commentId: commentId,
        );

        // Simpan notifikasi ke Firestore
        final data = {
          'title': title ?? '',
          'body': body ?? '',
          'newsUrl': newsUrl,
          'commentId': commentId,
          'timestamp': Timestamp.now(),
        };
        print("simpan datanya");

        await firestore
            .collection('notifications')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('history')
            .add(data);
      }
    });
  } catch (e) {
    throw Exception("Failed to get token ${e}");
  }

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
  final news = await CommentService().fetchNewsCommentData(newsUrl);
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
