import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsapp/core/utils/format_time.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:provider/provider.dart';

Widget buildCommentTile({
  required BuildContext context,
  required dynamic comment,
  required Map<String, dynamic>? userData, // ⬅️ Data user dari cache parent
  required bool isReply,
  required bool highlight,
  required void Function(String, dynamic) onEditDelete,
  required void Function(dynamic) onReply,
}) {
  final data = comment is QueryDocumentSnapshot ? comment.data() as Map : comment;
  final userVersion = context.watch<AuthProvider>().firestoreUserData;

  final message = data['message'] ?? '';
  final isSending = data['sending'] == true;
  final theme = Theme.of(context);

  // Ambil nama dan foto dari userData
  final name = userData?['username'] ?? 'Anonim';
  final photoUrl = userData?['photoURL'] ?? '';

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
        title: Text(
          name,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
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
          final isOwner = data['uid'] == userVersion?['uid'];
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
}
