import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:newsapp/core/utils/internetAcces.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnected = false;
  late StreamSubscription _subscription;

  bool get isConnected => _isConnected;

  ConnectionProvider() {
    _initConnectivity();
  }

  Future<void> _checkInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isDeviceConnected = connectivityResult[0] != ConnectivityResult.none;
      final hasInternet = isDeviceConnected ? await hasInternetAccess() : false;

      // Hanya update jika status berubah
      if (hasInternet != _isConnected) {
        _isConnected = hasInternet;
        notifyListeners();

        // Tampilkan notifikasi hanya jika benar-benar berubah
        if (!_isConnected) {
          showCustomToast(isDeviceConnected ? "No internet access" : "You're offline");
        } else {
          showCustomToast("online!");
        }
      }
    } catch (e) {
      debugPrint("Connection error: $e");
      _isConnected = false;
      notifyListeners();
    }
  }

  void _initConnectivity() async {
    await _checkInternet(); // Cek status awal
    _subscription = Connectivity().onConnectivityChanged.listen((_) => _checkInternet());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}