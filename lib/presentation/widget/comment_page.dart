import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/widget/modal_web_view.dart';
import 'package:newsapp/presentation/widget/news_card.dart';
import 'package:newsapp/services/send_push_notif.dart';

class CommentPage extends StatefulWidget {
  final Bookmark news;

  const CommentPage({super.key, required this.news});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();

  String? replyingToCommentId;
  String? replyingToUserId;
  String? replyingToUserName;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<QueryDocumentSnapshot>> fetchAllComments(String newsUrl) async {
    final encodedUrl = base64Url.encode(utf8.encode(newsUrl));
    final snap = await _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .orderBy('createdAt')
        .get();

    return snap.docs;
  }

  String formatTimestamp(
    context,
    Timestamp? timestamp, {
    bool isEdited = false,
  }) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final formatted =
        "${TimeOfDay.fromDateTime(dt).format(context)} - "
        "${dt.day} ${_monthName(dt.month)} ${dt.year % 100}";
    return isEdited ? "Edited: $formatted" : formatted;
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  Future<void> sendComment({
    required String message,
    required String newsUrl,
    required String userName,
    required String uid,
    String? parentId,
    String? replyToUid,
  }) async {
    final encodedUrl = base64Url.encode(utf8.encode(newsUrl));
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL ?? '';

    final collection = _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments');

    if (replyingToCommentId != null && replyingToUserName == null) {
      // Ini edit
      final docRef = collection.doc(replyingToCommentId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({
          'message': message,
          'editedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // ❌ Dokumen sudah dihapus → reset state
        replyingToCommentId = null;
        replyingToUserId = null;
        replyingToUserName = null;
      }
    } else {
      // Ini komentar baru
      await collection.add({
        'message': message,
        'name': userName,
        'uid': uid,
        'photoUrl': photoUrl,
        'parentId': parentId,
        'replyToUid': replyToUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final uid = user?.uid;
    final userName = user?.displayName ?? 'Anonim';

    return Scaffold(
      appBar: AppBar(title: const Text("Komentar")),
      body: Column(
        children: [
          _buildNewsBox(context),
          const Divider(),
          Expanded(
            child: FutureBuilder(
              future: fetchAllComments(widget.news.url),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final comments = snapshot.data as List<QueryDocumentSnapshot>;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    final parentId = comment['parentId'];
                    final isReply = parentId != null;
                    String? photoUrl;
                    try {
                      photoUrl = comment['photoUrl'];
                    } catch (_) {
                      photoUrl = null;
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        left: isReply ? 16.0 : 0.0,
                        bottom: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              comment['photoUrl'] != null &&
                                  comment['photoUrl'] != ''
                              ? NetworkImage(comment['photoUrl'])
                              : null,
                          child:
                              comment['photoUrl'] == null ||
                                  comment['photoUrl'] == ''
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(comment['name'] ?? 'No Name'),
                        subtitle: Column(
                          // Use a Column to stack the message and timestamp
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the start
                          children: [
                            Text(
                              comment['message'] ?? '',
                            ), // The original message
                            Text(
                              formatTimestamp(
                                context,
                                (comment.data() as Map)['editedAt'] ??
                                    comment['createdAt'],
                                isEdited: (comment.data() as Map).containsKey(
                                  'editedAt',
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        dense: true,
                        trailing: _auth.currentUser?.uid == comment['uid']
                            ? PopupMenuButton<String>(
                                offset: const Offset(0, 50),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _controller.text = comment['message'];
                                    setState(() {
                                      replyingToCommentId = comment.id;
                                      replyingToUserId = comment['uid'];
                                      replyingToUserName =
                                          null; // kita edit bukan membalas
                                    });
                                  } else if (value == 'delete') {
                                    final encodedUrl = base64Url.encode(
                                      utf8.encode(widget.news.url),
                                    );
                                    await _firestore
                                        .collection('newsInteractions')
                                        .doc(encodedUrl)
                                        .collection('comments')
                                        .doc(comment.id)
                                        .delete();
                                    setState(() {}); // refresh komentar
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus'),
                                  ),
                                ],
                              )
                            : TextButton(
                                child: const Text(
                                  "Balas",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    replyingToCommentId = comment.id;
                                    replyingToUserId = comment['uid'];
                                    replyingToUserName = comment['name'];
                                  });
                                },
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Border Untuk Balas Ke Username
          if (replyingToUserName != null)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  // Use Border for specific sides
                  top: BorderSide(
                    color: Colors.grey, // Color of the top border
                    width: 1,
                    // Thickness of the top border
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Row(
                  children: [
                    Text("Balas ke $replyingToUserName"),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          replyingToCommentId = null;
                          replyingToUserId = null;
                          replyingToUserName = null;
                        });
                      },
                      child: const Text("Batal"),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Tulis komentar...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty || uid == null) return;
                    final mention = replyingToUserName != null
                        ? "@$replyingToUserName "
                        : "";

                    await sendComment(
                      newsUrl: widget.news.url,
                      message: mention + _controller.text.trim(),
                      userName: userName,
                      uid: uid,
                      parentId: replyingToCommentId,
                      replyToUid: replyingToUserId,
                    );
                    // Setelah komentar dikirim:
                    if (replyingToUserId != null && replyingToUserId != uid) {
                      // Hindari kirim notif ke diri sendiri
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(replyingToUserId)
                          .get();
                      

                      final targetToken = userDoc['fcmToken'];
                      if (targetToken != null) {
                        await sendPushNotification(
                          token: targetToken,
                          title: "$userName membalas komentarmu",
                          body: _controller.text.trim(),
                        );
                      }
                    }

                    _controller.clear();
                    setState(() {
                      replyingToCommentId = null;
                      replyingToUserId = null;
                      replyingToUserName = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsBox(context) {
    return NewsCard(
      newsBookmarkList: widget.news,
      onTap: () => openWebViewModal(context, widget.news.url),
      showActions: false,
    );
  }
}
