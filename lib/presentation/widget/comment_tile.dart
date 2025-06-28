import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsapp/core/utils/format_time.dart';
import 'package:newsapp/presentation/widget/news_card.dart';
import 'package:newsapp/presentation/widget/modal_web_view.dart';
import 'package:newsapp/services/getUserForEdit.dart';

Widget buildNewsBox(BuildContext context, dynamic news) {
  return NewsCard(
    newsBookmarkList: news,
    onTap: () => openWebViewModal(context, news.url),
    showActions: false,
  );
}

Map<String, Future<DocumentSnapshot<Map<String, dynamic>>?>> _userCache = {};

Future<DocumentSnapshot<Map<String, dynamic>>?> getUserCached(String uid) {
  if (!_userCache.containsKey(uid)) {
    _userCache[uid] = UserForEdit().getUserByUid(uid);
  }
  return _userCache[uid]!;
}

Widget buildCommentTile({
  required BuildContext context,
  required dynamic comment,
  required bool isReply,
  required bool highlight,
  required String? currentUid,
  required void Function(String, dynamic) onEditDelete,
  required void Function(dynamic) onReply,
}) {
  final data = comment is QueryDocumentSnapshot
      ? comment.data() as Map
      : comment;
      print(data['uid']);
  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
    future: getUserCached(data['uid']),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Tes");
      }
      final userDoc = snapshot.data!.data()!;
      final photoUrl = userDoc['photoURL'] ?? '';
      final name = userDoc['username'] ?? 'No Name';
      final message = data['message'] ?? '';
      final isSending = data['sending'] == true;
      final theme = Theme.of(context);

      return Padding(
        padding: EdgeInsets.only(left: isReply ? 16.0 : 0.0, bottom: 8),
        child: Container(
          decoration: highlight
              ? BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: (photoUrl != '') ? NetworkImage(photoUrl) : null,
              child: (photoUrl == '') ? const Icon(Icons.person) : null,
            ),
            title: Text(name,style: TextStyle(color: theme.colorScheme.onPrimary),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message,style: TextStyle(color: theme.colorScheme.onPrimary)),
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
              
              final isOwner = data['uid'] == currentUid;
              final isPending = data['sending'] == true;
              
              if (isOwner && !isPending) {
                return PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: theme.colorScheme.onPrimary),
                  onSelected: (value) => onEditDelete(value, comment),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                );
              } else {
                return TextButton(
                  onPressed: () => onReply(comment),
                  child: const Text("Balas", style: TextStyle(fontSize: 12)),
                );
              }
            })(),
          ),
        ),
      );
    },
  );
}
