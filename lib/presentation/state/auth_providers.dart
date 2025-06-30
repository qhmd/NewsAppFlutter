import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsapp/services/bookmark_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _firestoreUserData;

  final BookmarkService _bookmarkService = BookmarkService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get user => _user;
  Map<String, dynamic>? get firestoreUserData => _firestoreUserData;

  bool get isLoggedIn => _user != null;

  void setUserData(Map<String, dynamic> newData) {
    _firestoreUserData = {..._firestoreUserData ?? {}, ...newData};
    notifyListeners();
  }

  Future<void> setUser({
    required User? user,
    required Map<String, dynamic>? userData,
    required BuildContext context,
  }) async {
    if (_user?.uid == user?.uid) return;

    _user = user;
    print(userData);
    print("Set userDataa: $userData");
    _firestoreUserData = userData;

    print("Set user: $_user");
    print("Firestore data: $_firestoreUserData");

    if (_user != null) {
      try {
        await _bookmarkService.syncFromCloud(_user!.uid);
      } catch (e) {
        debugPrint("Offline - sync skipped");
      }
    }

    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _firestoreUserData = null;
    notifyListeners();
  }
}
