import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/core/utils/urlConvert.dart';
import 'package:newsapp/services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _service = CommentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, int> _commentsCounts = {};
  final Map<String, StreamSubscription<QuerySnapshot>> _subscriptions = {};

  int getCount(String url) => _commentsCounts[url] ?? 0;
  int getCommentCount(String newsUrl) => _commentsCounts[newsUrl] ?? 0;

  void ListenToCommentCount(String url) {
    if (_subscriptions.containsKey(url)) return;

    final encodeurl = encodeUrl(url);
    final subscription = _firestore
        .collection('newsInteractions')
        .doc(encodeurl)
        .collection('comments')
        .snapshots()
        .listen((snapshot) {
      _commentsCounts[url] = snapshot.docs.length;
      notifyListeners();
    });

    _subscriptions[url] = subscription; // ✅ simpan untuk kontrol listener
  }

  Future<void> sendComment({
    required String newsUrl,
    required String message,
    required String userName,
    required String uid,
    String? parentId,
    String? replyToUid,
  }) async {
    if (message.trim().isEmpty) return;
    await _service.addComment(
      newsUrl: newsUrl,
      message: message.trim(),
      userName: userName,
      uid: uid,
      parentId: parentId,
      replyToUid: replyToUid,
    );
  }

  Stream<List<QueryDocumentSnapshot>> getMainComments(String newsUrl) {
    return _service.getComments(newsUrl);
  }

  Stream<List<QueryDocumentSnapshot>> getReplies(
    String newsUrl,
    String parentId,
  ) {
    return _service.getReplies(newsUrl, parentId);
  }

  void clear() {
    _commentsCounts.clear();
    notifyListeners();
  }

  // ✅ Tambahan: membersihkan semua listener
  void disposeListeners() {
    for (var sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}
