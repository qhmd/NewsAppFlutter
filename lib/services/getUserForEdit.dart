import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserForEdit {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  /// Ambil data user dari Firestore berdasarkan UID
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserByUid(String uid) async {
    if (uid.isEmpty) return null;
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }
}