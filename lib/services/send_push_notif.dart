import 'package:http/http.dart' as http;
import 'dart:convert';
Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
}) async {
  final url = Uri.parse('https://push-notif-api-production.up.railway.app/send');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "token": token,
      "title": title,
      "body": body,
    }),
  );

  print("🔔 Notif response: ${response.body}");
}
