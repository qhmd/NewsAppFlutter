import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newsapp/main.dart';
import 'local_notif.dart';

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Minta permission iOS (Android auto)
  await messaging.requestPermission();
  // Dapatkan token perangkat
  final token = await messaging.getToken();
  print("🔔 FCM Token: $token");

  final user = FirebaseAuth.instance.currentUser;
  if (user != null && token != null) {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({'fcmToken': token}, SetOptions(merge: true));
  }

  // Notifikasi saat app foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.notification != null) {
  LocalNotificationService().flutterLocalNotificationsPlugin.show(
    0,
    message.notification!.title,
    message.notification!.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id', // ganti ini sesuai ID channel kamu
        'Komentar',   // nama channel
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

});

}