// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsapp/presentation/widget/comment_tile.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<DocumentSnapshot> getUserDoc() async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");
    return await _firestore.collection('users').doc(user.uid).get();
  }

  Future<bool> isUsernameUnique(String username) async {
    final user = currentUser;
    if (user == null) return false;

    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return query.docs.isEmpty ||
        (query.docs.length == 1 && query.docs.first.id == user.uid);
  }

  Future<void> updateProfile({
    required String username,
    String? photoURL,
    String? deleteHash,
  }) async {
    final user = currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update({
      'updatedAt': DateTime.now().toIso8601String(),
      'username': username,
      if (photoURL != null) 'photoURL': photoURL,
      if (deleteHash != null) 'deleteHash': deleteHash,
    });
  }

  Future<void> deleteUserData() async {
    final user = currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
