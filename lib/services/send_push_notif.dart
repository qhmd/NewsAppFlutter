// lib/services/send_push_notif.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
  required String newsUrl,
  required String commendUid, // commentId
}) async {
  final url = Uri.parse(
    'https://push-notif-api-production.up.railway.app/send',
  );

  print("Sending notification:");
  print("Token: ${token.substring(0, 20)}...");
  print("Title: $title");
  print("Body: $body");
  print("NewsUrl: $newsUrl");
  print("CommentId: $commendUid");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "token": token,
      "title": title,
      "body": body,
      "newsUrl": newsUrl,
      "commendUid": commendUid,
    }),
  );

  print("Notif response status: ${response.statusCode}");
  print("Notif response body: ${response.body}");

  if (response.statusCode != 200) {
    print("Failed to send notification: ${response.body}");
  }
}
