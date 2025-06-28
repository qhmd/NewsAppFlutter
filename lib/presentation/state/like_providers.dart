import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsapp/core/utils/urlConvert.dart';

class LikeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Menyimpan status like dan count berdasarkan URL
  Map<String, bool> _likeStatus = {};
  Map<String, int> _likeCount = {};

  bool isLiked(String url) => _likeStatus[url] ?? false;
  int getLikeCount(String url) => _likeCount[url] ?? 0;

  void listenToLikeChanges(String url) {
    final encodedUrl = encodeUrl(url);

    _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .snapshots()
        .listen((doc) {
          final uid = _auth.currentUser?.uid;
          final likes = doc.data()?['likes'] as List? ?? [];
          _likeCount[url] = likes.length;
          _likeStatus[url] = uid != null && likes.contains(uid);
          notifyListeners();
        });
  }

  Future<void> toggleLike(String url) async {
    final uid = _auth.currentUser?.uid;
    print("isi uid dari toggle like ${uid}");
    if (uid == null) return;

    final encodedUrl = encodeUrl(url);
    final docRef = _firestore.collection('newsInteractions').doc(encodedUrl);
    final isCurrentlyLiked = _likeStatus[url] ?? false;
    print("isi currently like ${isCurrentlyLiked}");

    // ✅ Optimistic Update
    if (isCurrentlyLiked) {
      _likeStatus[url] = false;
      _likeCount[url] = (_likeCount[url] ?? 1) - 1;
    } else {
      _likeStatus[url] = true;
      _likeCount[url] = (_likeCount[url] ?? 0) + 1;
    }

    // ✅ Notify dulu sebelum Firestore selesai
    notifyListeners();

    // ✅ Sync ke Firestore (tanpa fetch ulang)
    try {
      if (isCurrentlyLiked) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await docRef.set({
          'likes': FieldValue.arrayUnion([uid]),
          'originalUrl': url,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Firestore error: $e");
      // ❗ Kalau mau, di sini kamu bisa rollback state
    }
  }

  void clear() {
    _likeStatus.clear();
    _likeCount.clear();
    notifyListeners();
  }
}
