import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:newsapp/presentation/widget/comment_tile.dart';
import 'package:newsapp/services/send_push_notif.dart';
import 'package:provider/provider.dart';

class CommentPage extends StatefulWidget {
  final Bookmark news;
  final String? targetCommentId;

  const CommentPage({super.key, required this.news, this.targetCommentId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool hasScrolledToTarget = false;
  final ScrollController _scrollController = ScrollController();

  String? replyingToCommentId;
  String? replyingToUserId;
  String? replyingToUserName;
  String? editingCommentId;

  List<Map<String, dynamic>> localPendingComments = [];

  bool get isEditing => editingCommentId != null;

  Map<String, int> commentIndexMap = {};

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

                commentIndexMap.clear();
                int globalIdx = 2;

                for (var parent in parents) {
                  final parentId = parent is QueryDocumentSnapshot
                      ? parent.id
                      : parent['id'];
                  commentIndexMap[parentId] = globalIdx++;
                  final replies = grouped[parentId] ?? [];
                  for (var reply in replies) {
                    final replyId = reply is QueryDocumentSnapshot
                        ? reply.id
                        : reply['id'];
                    commentIndexMap[replyId] = globalIdx++;
                  }
                }

                if (widget.targetCommentId != null && !hasScrolledToTarget) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToTarget();
                    hasScrolledToTarget = true;
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: parents.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) return buildNewsBox(context, widget.news);
                    if (index == 1) return const Divider();

                    final parent = parents[index - 2];
                    final parentId = parent is QueryDocumentSnapshot
                        ? parent.id
                        : parent['id'];
                    final replies = grouped[parentId] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCommentTile(
                          context: context,
                          comment: parent,
                          isReply: false,
                          highlight: widget.targetCommentId == parentId,
                          currentUid: uid,
                          onEditDelete: _handleEditDelete,
                          onReply: (comment) {
                            final data = comment is QueryDocumentSnapshot
                                ? comment.data() as Map
                                : comment;
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
                        ),
                        ...replies.map((reply) {
                          final replyId = reply is QueryDocumentSnapshot
                              ? reply.id
                              : reply['id'];
                          return buildCommentTile(
                            context: context,
                            comment: reply,
                            isReply: true,
                            highlight: widget.targetCommentId == replyId,
                            currentUid: uid,
                            onEditDelete: _handleEditDelete,
                            onReply: (comment) {
                              final data = comment is QueryDocumentSnapshot
                                  ? comment.data() as Map
                                  : comment;
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
                          );
                        }).toList(),
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
                    final uid = _auth.currentUser?.uid;
                    if (uid == null) {
                      final toProfile = context.read<PageIndexProvider>();
                      showCustomToast("You have to login first");
                      toProfile.changePage(2);
                      return;
                    }
                    final userName = _auth.currentUser?.displayName ?? 'Anonim';
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
                    await _firestore
                        .collection('newsInteractions')
                        .doc(encodedUrl)
                        .set({
                          'originalUrl': widget.news.url,
                          'title': widget.news.title,
                          'urlImage': widget.news.multimedia,
                          'source': widget.news.source,
                          'time': widget.news.date,
                        });

                    setState(() {
                      localPendingComments.removeWhere(
                        (c) => c['id'] == tempId,
                      );
                    });
                    if (newComment['replyToUid'] != null &&
                        newComment['replyToUid'] != uid) {
                      final userDoc = await _firestore
                          .collection('users')
                          .doc(newComment['replyToUid'] as String)
                          .get();
                      final token = userDoc['fcmToken'];
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

  void _scrollToTarget() {
    if (commentIndexMap.containsKey(widget.targetCommentId)) {
      final idx = commentIndexMap[widget.targetCommentId]!;
      _scrollController.animateTo(
        (idx * 100).toDouble(),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

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
        if (doc['createdAt'] != null) {
          final parentId = doc['parentId'];
          grouped.putIfAbsent(parentId, () => []).add(doc);
        }
      }

      for (var local in localPendingComments) {
        final parentId = local['parentId'];
        grouped.putIfAbsent(parentId, () => []).add(local);
      }

      return grouped;
    });
  }

  void _handleEditDelete(String action, dynamic comment) async {
    if (action == 'edit') {
      final data = comment is QueryDocumentSnapshot
          ? comment.data() as Map
          : comment;
      _controller.text = data['message'];
      setState(() {
        editingCommentId = comment is QueryDocumentSnapshot
            ? comment.id
            : data['id'];
        replyingToCommentId = null;
        replyingToUserId = null;
        replyingToUserName = null;
      });
    } else if (action == 'delete') {
      final encodedUrl = base64Url.encode(utf8.encode(widget.news.url));
      final id = comment is QueryDocumentSnapshot ? comment.id : comment['id'];
      await _firestore
          .collection('newsInteractions')
          .doc(encodedUrl)
          .collection('comments')
          .doc(id)
          .delete();
      setState(() {});
    }
  }
}
