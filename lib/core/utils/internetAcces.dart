import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

Future<bool> hasInternetAccess() async {
  const List<String> testDomains = [
    'google.com',
    'cloudflare.com',
    'example.com',
  ];

  for (final domain in testDomains) {
    try {
      final result = await InternetAddress.lookup(domain)
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (e) {
      debugPrint("🔌 SocketException: $e");
    } on TimeoutException catch (e) {
      debugPrint("⏳ TimeoutException: $e");
    } catch (e) {
      debugPrint("❗ Unexpected: $e");
    }
  }

  return false;
}
