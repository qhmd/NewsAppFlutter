import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _service = CommentService();

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

  Stream<List<QueryDocumentSnapshot>> getReplies(String newsUrl, String parentId) {
    return _service.getReplies(newsUrl, parentId);
  }
}
