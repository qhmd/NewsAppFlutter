import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

Future<bool> hasInternetAccess() async {
  const List<String> testDomains = [
    'google.com',
    'cloudflare.com',
    'example.com',
  ];

  try {
    // Timeout setelah 3 detik
    final result = await InternetAddress.lookup(testDomains.first)
      .timeout(const Duration(seconds: 3));

    return result.isNotEmpty;
  } on SocketException catch (e) {
    debugPrint("Internet check failed: $e");
    return false;
  } on TimeoutException catch (e) {
    debugPrint("Internet check timeout: $e");
    return false;
  } catch (e) {
    debugPrint("Unexpected error: $e");
    return false;
  }
}