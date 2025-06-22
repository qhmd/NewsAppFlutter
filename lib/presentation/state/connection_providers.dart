import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:newsapp/core/utils/internetAcces.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription _subscription;

  bool get isConnected => _isConnected;

  ConnectionProvider() {
    _initConnectivity();
  }

  void _initConnectivity() async {
    // Cek awal
    _isConnected = await hasInternetAccess();
    notifyListeners();

    // Dengarkan perubahan koneksi
    _subscription = Connectivity().onConnectivityChanged.listen((_) async {
      final hasInternet = await hasInternetAccess();
      if (hasInternet != _isConnected) {
        _isConnected = hasInternet;
        notifyListeners();
      }
    });
  }

  void disposeStream() {
    _subscription.cancel();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
