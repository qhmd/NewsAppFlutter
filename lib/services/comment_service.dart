import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/core/utils/urlConvert.dart';

class CommentService with ChangeNotifier{
  final _firestore = FirebaseFirestore.instance;

  Future<void> addComment({
    required String newsUrl,
    required String message,
    required String userName,
    required String uid,
    String? parentId,
    String? replyToUid,
  }) async {
    final encodedUrl = encodeUrl(newsUrl);

    await _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .add({
          'uid': uid,
          'name': userName,
          'message': message,
          'parentId': parentId,
          'createdAt': FieldValue.serverTimestamp(),
        });

    if (parentId != null && replyToUid != null && uid != replyToUid) {
      await _firestore
          .collection('notifications')
          .doc(replyToUid)
          .collection('items')
          .add({
            'type': 'reply',
            'fromUser': userName,
            'newsUrl': newsUrl,
            'message': message,
            'createdAt': FieldValue.serverTimestamp(),
          });
    }
  }

  Stream<List<QueryDocumentSnapshot>> getComments(String newsUrl) {
    final encodedUrl = encodeUrl(newsUrl);
    return _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .where('parentId', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  Stream<List<QueryDocumentSnapshot>> getReplies(String newsUrl, String parentId) {
    final encodedUrl = encodeUrl(newsUrl);
    return _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs);
  }
}
