import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsapp/core/utils/format_time.dart';
import 'package:newsapp/presentation/widget/news_card.dart';
import 'package:newsapp/presentation/widget/modal_web_view.dart';

Widget buildNewsBox(BuildContext context, dynamic news) {
  return NewsCard(
    newsBookmarkList: news,
    onTap: () => openWebViewModal(context, news.url),
    showActions: false,
  );
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
  final photoUrl = data['photoUrl'] ?? '';
  final name = data['name'] ?? 'No Name';
  final message = data['message'] ?? '';
  final isSending = data['sending'] == true;

  return Padding(
    padding: EdgeInsets.only(left: isReply ? 16.0 : 0.0, bottom: 8),
    child: Container(
      decoration: highlight
          ? BoxDecoration(
              color: Colors.yellow.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
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
          final isOwner = data['uid'] == currentUid;
          final isPending = data['sending'] == true;

          if (isOwner && !isPending) {
            return PopupMenuButton<String>(
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
}