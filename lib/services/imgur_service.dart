// lib/services/imgur_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgurService {
  static const String _clientId = 'f7b7863506393c0';

  static Future<Map<String, String>?> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse("https://api.imgur.com/3/image"),
        headers: {"Authorization": "Client-ID $_clientId"},
        body: {"image": base64Image, "type": "base64"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'link': data['data']['link'],
          'deleteHash': data['data']['deletehash'],
        };
      } else {
        print("Upload gagal: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Imgur: $e");
      return null;
    }
  }

  static Future<void> deleteImage(String deleteHash) async {
    try {
      await http.delete(
        Uri.parse("https://api.imgur.com/3/image/$deleteHash"),
        headers: {"Authorization": "Client-ID $_clientId"},
      );
    } catch (e) {
      print("Gagal menghapus gambar dari Imgur: $e");
    }
  }
}
