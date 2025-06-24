import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsapp/services/bookmark_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final BookmarkService _bookmarkService = BookmarkService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> setUser(User? user, BuildContext context) async {
    if (_user?.uid == user?.uid) return;
    _user = user;
    print("set user ${_user}");
    if (_user != null) {
      try {
        debugPrint("ekseksi setuser");
        await _bookmarkService.syncFromCloud(_user!.uid);
      } catch (e) {
        debugPrint("Offline - sync skipped");
      }
    }
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
