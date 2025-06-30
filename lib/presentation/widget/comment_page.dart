import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:newsapp/presentation/widget/comment_input_bar.dart';
import 'package:newsapp/presentation/widget/comment_tile.dart';
import 'package:newsapp/presentation/widget/modal_web_view.dart';
import 'package:newsapp/presentation/widget/comment_news_header.dart';
import 'package:newsapp/presentation/widget/news_card.dart';
import 'package:newsapp/services/getUserForEdit.dart';
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
  final ScrollController _scrollController = ScrollController();

  bool hasScrolledToTarget = false;
  String? replyingToCommentId;
  String? replyingToUserId;
  String? replyingToUserName;
  String? editingCommentId;

  List<Map<String, dynamic>> localPendingComments = [];
  Map<String, int> commentIndexMap = {};
  Map<String, Map<String, dynamic>> userCache = {};

  bool get isEditing => editingCommentId != null;

  Future<void> _sendComment() async {
    final auth = context.read<AuthProvider>().firestoreUserData;
    // final uid = _auth.currentUser?.uid;
    final uid = auth?['uid'];

    if (uid == null) {
      if (!mounted) return;
      final toProfile = context.read<PageIndexProvider>();
      showCustomToast("You have to login first");
      toProfile.changePage(2);
      return;
    }
    if (_controller.text.trim().isEmpty) return;

    final userDoc = await UserForEdit().getUserByUid(uid);
    final userData = userDoc?.data();
    final userName = userData?['username'] ?? 'Anonim';

    final message = _controller.text.trim();
    final encodedUrl = base64Url.encode(utf8.encode(widget.news.url));

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

    final mention = replyingToUserName != null ? "@$replyingToUserName " : "";
    final fullMessage = mention + message;
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

    final newComment = {
      'id': tempId,
      'message': fullMessage,
      'uid': uid,
      'name': userName,
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
          'parentId': newComment['parentId'],
          'replyToUid': newComment['replyToUid'],
          'createdAt': FieldValue.serverTimestamp(),
        });

    // Pastikan dokumen interaksi berita ada untuk URL ini
    await _firestore.collection('newsInteractions').doc(encodedUrl).set({
      'originalUrl': widget.news.url,
      'title': widget.news.title,
      'urlImage': widget.news.multimedia,
      'source': widget.news.source,
      'time': widget.news.date,
    }, SetOptions(merge: true));

    setState(() {
      localPendingComments.removeWhere((c) => c['id'] == tempId);
    });

    if (newComment['replyToUid'] != null && newComment['replyToUid'] != uid) {
      final userDoc = await _firestore
          .collection('users')
          .doc(newComment['replyToUid'] as String)
          .get();
      final token = userDoc['fcmToken'];
      if (token != null) {
        await sendPushNotification(
          token: token,
          title: "$userName membalas komentarmu",
          body: message, // Gunakan 'message' asli tanpa mention
          newsUrl: widget.news.url,
          commendUid: docRef.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text(
          "Komentar",
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Map<String?, List>>(
              stream: getGroupedCommentStream(widget.news.url),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final grouped = snapshot.data!;
                final allComments = grouped.values.expand((e) => e).toList();

                final uids = {
                  for (var c in allComments)
                    if (c is DocumentSnapshot) c['uid'] else c['uid'],
                };

                return FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: fetchUsers(uids.whereType<String>().toList()),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData)
                      return const Center(child: CircularProgressIndicator());

                    userCache = userSnap.data!;
                    final parents = grouped[null] ?? [];

                    commentIndexMap.clear();
                    int globalIdx = 2;

                    for (var parent in parents) {
                      final parentId = parent is DocumentSnapshot
                          ? parent.id
                          : parent['id'];
                      commentIndexMap[parentId] = globalIdx++;
                      final replies = grouped[parentId] ?? [];
                      for (var reply in replies) {
                        final replyId = reply is DocumentSnapshot
                            ? reply.id
                            : reply['id'];
                        commentIndexMap[replyId] = globalIdx++;
                      }
                    }

                    if (widget.targetCommentId != null &&
                        !hasScrolledToTarget) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToTarget();
                        hasScrolledToTarget = true;
                      });
                    }

                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: parents.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0)
                            return NewsHeaderWidget(news: widget.news);
                          if (index == 1)
                            return const Divider(color: Colors.grey);

                          final parent = parents[index - 2];
                          final parentId = parent is DocumentSnapshot
                              ? parent.id
                              : parent['id'];
                          final parentUid = parent is DocumentSnapshot
                              ? parent['uid']
                              : parent['uid'];
                          final replies = grouped[parentId] ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildCommentTile(
                                context: context,
                                comment: parent,
                                userData: userCache[parentUid],
                                isReply: false,
                                highlight: widget.targetCommentId == parentId,
                                onEditDelete: _handleEditDelete,
                                onReply: _handleReply,
                              ),
                              ...replies.map((reply) {
                                final replyId = reply is DocumentSnapshot
                                    ? reply.id
                                    : reply['id'];
                                final replyUid = reply is DocumentSnapshot
                                    ? reply['uid']
                                    : reply['uid'];
                                return buildCommentTile(
                                  context: context,
                                  comment: reply,
                                  userData: userCache[replyUid],
                                  isReply: true,
                                  highlight: widget.targetCommentId == replyId,
                                  onEditDelete: _handleEditDelete,
                                  onReply: _handleReply,
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          CommentInputBar(
            controller: _controller,
            isEditing: isEditing,
            replyingToUserName: replyingToUserName,
            onCancelEdit: () {
              setState(() {
                editingCommentId = null;
                _controller.clear();
              });
            },
            onCancelReply: () {
              setState(() {
                replyingToCommentId = null;
                replyingToUserId = null;
                replyingToUserName = null;
              });
            },
            onSend:
                _sendComment, // Panggil method _sendComment yang baru dibuat
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      hasScrolledToTarget = false;
    });
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

  Future<Map<String, Map<String, dynamic>>> fetchUsers(
    List<String> uids,
  ) async {
    if (uids.isEmpty) return {};
    final snapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids.toSet().toList())
        .get();

    final result = <String, Map<String, dynamic>>{};
    for (var doc in snapshot.docs) {
      result[doc.id] = doc.data();
    }
    return result;
  }

  void _handleEditDelete(String action, dynamic comment) async {
    if (action == 'edit') {
      final data = comment is DocumentSnapshot
          ? comment.data() as Map
          : comment;
      _controller.text = data['message'];
      setState(() {
        editingCommentId = comment is DocumentSnapshot
            ? comment.id
            : data['id'];
        replyingToCommentId = null;
        replyingToUserId = null;
        replyingToUserName = null;
      });
    } else if (action == 'delete') {
      final encodedUrl = base64Url.encode(utf8.encode(widget.news.url));
      final id = comment is DocumentSnapshot ? comment.id : comment['id'];
      await _firestore
          .collection('newsInteractions')
          .doc(encodedUrl)
          .collection('comments')
          .doc(id)
          .delete();
      if (!mounted) return;
      setState(() {});
    }
  }

  void _handleReply(dynamic comment) {
    final data = comment is DocumentSnapshot ? comment.data() as Map : comment;
    final originalParentId = data['parentId'];
    setState(() {
      replyingToCommentId =
          originalParentId ??
          (comment is DocumentSnapshot ? comment.id : data['id']);
      replyingToUserId = data['uid'];
      replyingToUserName = data['name'];
    });
  }
}
