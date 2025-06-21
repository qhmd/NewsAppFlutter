import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsapp/services/bookmark_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final BookmarkService _bookmarkService = BookmarkService();

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(User? user, BuildContext context) async {
    _user = user;
    if (_user != null) {
      try {
        print("ekseksi setuser");
        await _bookmarkService.syncFromCloud(_user!.uid);
      } catch (e) {
        print("Offline - sync skipped");
      }
    }
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
