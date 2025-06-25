import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
  required String newsUrl,
  required String commendUid,
}) async {
  final url = Uri.parse(
    'https://push-notif-api-production.up.railway.app/send',
  );
  print("isi dari ${token},${title},${body},${newsUrl},${commendUid},");
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "token": token,
      "title": title,
      "body": body,
      "newsUrl": newsUrl,
      "commentUid": commendUid,
    }),
  );

  print("🔔 Notif response: ${response.body}");
}
