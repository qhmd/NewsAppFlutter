// lib/services/comment_service.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsapp/core/utils/urlConvert.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsapp/data/models/bookmark.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          'message': message,
          'name': userName,
          'uid': uid,
          'photoUrl': '',
          'parentId': parentId,
          'replyToUid': replyToUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> editComment({
    required String newsUrl,
    required String commentId,
    required String newMessage,
  }) async {
    final encodedUrl = encodeUrl(newsUrl);
    await _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .doc(commentId)
        .update({
          'message': newMessage,
          'editedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> deleteComment({
    required String newsUrl,
    required String commentId,
  }) async {
    final encodedUrl = encodeUrl(newsUrl);
    await _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  Stream<List<QueryDocumentSnapshot>> getComments(String newsUrl) {
    final encodedUrl = encodeUrl(newsUrl);
    return _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .where('parentId', isNull: true)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<QueryDocumentSnapshot>> getReplies(
    String newsUrl,
    String parentId,
  ) {
    final encodedUrl = encodeUrl(newsUrl);
    return _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<Bookmark?> fetchNewsCommentData(String newsUrl) async {
    final newsSnap = await FirebaseFirestore.instance
        .collection('newsInteractions')
        .where('originalUrl', isEqualTo: newsUrl)
        .limit(1)
        .get();

    if (newsSnap.docs.isNotEmpty) {
      final data = newsSnap.docs.first.data();
      return Bookmark(
        id: newsSnap.docs.first.id,
        title: data['title'] ?? 'Tanpa Judul',
        source: data['source'] ?? 'Tidak diketahui',
        date: data['time'] ?? '',
        multimedia: data['urlImage'] ?? '',
        url: data['originalUrl'] ?? newsUrl,
      );
    }

    return null; // tidak ditemukan
  }
}