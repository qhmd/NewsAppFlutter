import 'dart:convert';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? replyingToCommentId;
  String? replyingToUserId;
  String? replyingToUserName;
  String? editingCommentId;

  List<Map<String, dynamic>> localPendingComments = [];

  bool get isEditing => editingCommentId != null;

  Stream<Map<String?, List>> getGroupedCommentStream(String newsUrl) {
    final encodedUrl = base64Url.encode(utf8.encode(newsUrl));
    final firestoreStream = _firestore
        .collection('newsInteractions')
        .doc(encodedUrl)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots();

    return firestoreStream.map((snap) {
      final grouped = <String?, List>{};

      for (var doc in snap.docs) {
        final parentId = doc['parentId'];
        grouped.putIfAbsent(parentId, () => []).add(doc);
      }

      for (var local in localPendingComments) {
        final parentId = local['parentId'];
        grouped.putIfAbsent(parentId, () => []).add(local);
      }

      return grouped;
    });
  }

  String formatTimestamp(
    BuildContext context,
    Timestamp? timestamp, {
    bool isEdited = false,
  }) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final formatted =
        "${TimeOfDay.fromDateTime(dt).format(context)} - ${dt.day} ${_monthName(dt.month)} ${dt.year % 100}";
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

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    final userName = _auth.currentUser?.displayName ?? 'Anonim';

    return Scaffold(
      appBar: AppBar(title: const Text("Komentar")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getGroupedCommentStream(widget.news.url),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final grouped = snapshot.data!;
                final parents = grouped[null] ?? [];

                return ListView.builder(
                  itemCount: parents.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildNewsBox(context);
                    if (index == 1) return const Divider();

                    final parent = parents[index - 2];
                    final parentId = parent is QueryDocumentSnapshot
                        ? parent.id
                        : parent['id'];
                    final replies = grouped[parentId] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommentTile(parent, isReply: false),
                        ...replies
                            .map(
                              (reply) =>
                                  _buildCommentTile(reply, isReply: true),
                            )
                            .toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (isEditing)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text("Mengedit komentar"),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        editingCommentId = null;
                        _controller.clear();
                      });
                    },
                    child: const Text("Batal"),
                  ),
                ],
              ),
            ),
          if (replyingToUserName != null)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 1)),
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
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

                    final message = _controller.text.trim();
                    final encodedUrl = base64Url.encode(
                      utf8.encode(widget.news.url),
                    );

                    if (isEditing) {
                      final commentRef = _firestore
                          .collection('newsInteractions')
                          .doc(encodedUrl)
                          .collection('comments')
                          .doc(editingCommentId);

                      await commentRef.update({
                        'message': message,
                        'editedAt': FieldValue.serverTimestamp(),
                      });

                      setState(() {
                        editingCommentId = null;
                        _controller.clear();
                      });
                      return;
                    }

                    final mention = replyingToUserName != null
                        ? "@$replyingToUserName "
                        : "";
                    final fullMessage = mention + message;
                    final tempId =
                        'temp-${DateTime.now().millisecondsSinceEpoch}';

                    final newComment = {
                      'id': tempId,
                      'message': fullMessage,
                      'name': userName,
                      'uid': uid,
                      'photoUrl': _auth.currentUser?.photoURL ?? '',
                      'parentId': replyingToCommentId,
                      'replyToUid': replyingToUserId,
                      'createdAt': Timestamp.now(),
                      'sending': true,
                    };

                    setState(() {
                      localPendingComments.add(newComment);
                      replyingToCommentId = null;
                      replyingToUserId = null;
                      replyingToUserName = null;
                      _controller.clear();
                    });

                    final docRef = await _firestore
                        .collection('newsInteractions')
                        .doc(encodedUrl)
                        .collection('comments')
                        .add({
                          'message': fullMessage,
                          'name': userName,
                          'uid': uid,
                          'photoUrl': _auth.currentUser?.photoURL ?? '',
                          'parentId': newComment['parentId'],
                          'replyToUid': newComment['replyToUid'],
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                    setState(() {
                      localPendingComments.removeWhere(
                        (c) => c['id'] == tempId,
                      );
                    });
                    print("ini di jlanankan");
                    if (newComment['replyToUid'] != null &&
                        newComment['replyToUid'] != uid) {
                      final userDoc = await _firestore
                          .collection('users')
                          .doc(newComment['replyToUid'] as String)
                          .get();
                      final token = userDoc['fcmToken'];
                      print("isi fcm skrn ${token}");
                      if (token != null) {
                        await sendPushNotification(
                          token: token,
                          title: "$userName membalas komentarmu",
                          body: message,
                          newsUrl: widget.news.url,
                          commendUid: docRef.id,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsBox(BuildContext context) {
    return NewsCard(
      newsBookmarkList: widget.news,
      onTap: () => openWebViewModal(context, widget.news.url),
      showActions: false,
    );
  }

  Widget _buildCommentTile(dynamic comment, {required bool isReply}) {
    final data = comment is QueryDocumentSnapshot
        ? comment.data() as Map
        : comment;
    final photoUrl = data['photoUrl'] ?? '';
    final name = data['name'] ?? 'No Name';
    final message = data['message'] ?? '';
    final uid = _auth.currentUser?.uid;
    final isSending = data['sending'] == true;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 16.0 : 0.0, bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (photoUrl != '') ? NetworkImage(photoUrl) : null,
          child: (photoUrl == '') ? const Icon(Icons.person) : null,
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            Text(
              isSending
                  ? "Sending..."
                  : formatTimestamp(
                      context,
                      data['editedAt'] ?? data['createdAt'],
                      isEdited: data.containsKey('editedAt'),
                    ),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        dense: true,
        trailing: (() {
          final data = comment is QueryDocumentSnapshot
              ? comment.data() as Map
              : comment as Map;

          final isOwner = data['uid'] == uid;
          final isPending = data['sending'] == true;

          if (isOwner && !isPending) {
            // Pemilik komentar yang bukan pending → bisa edit / hapus
            return PopupMenuButton<String>(
              onSelected: (value) => _handleEditDelete(value, comment),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            );
          } else {
            // Selain itu → hanya bisa balas
            return TextButton(
              onPressed: () {
                final originalParentId = data['parentId'];
                setState(() {
                  replyingToCommentId =
                      originalParentId ??
                      (comment is QueryDocumentSnapshot
                          ? comment.id
                          : data['id']);
                  replyingToUserId = data['uid'];
                  replyingToUserName = data['name'];
                });
              },
              child: const Text("Balas", style: TextStyle(fontSize: 12)),
            );
          }
        })(),
      ),
    );
  }

  void _handleEditDelete(String action, QueryDocumentSnapshot comment) async {
    if (action == 'edit') {
      _controller.text = comment['message'];
      setState(() {
        editingCommentId = comment.id;
        replyingToCommentId = null;
        replyingToUserId = null;
        replyingToUserName = null;
      });
    } else if (action == 'delete') {
      final encodedUrl = base64Url.encode(utf8.encode(widget.news.url));
      await _firestore
          .collection('newsInteractions')
          .doc(encodedUrl)
          .collection('comments')
          .doc(comment.id)
          .delete();
      setState(() {});
    }
  }
}
