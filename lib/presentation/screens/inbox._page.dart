import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsapp/main.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/widget/list_inbox.dart';
import 'package:newsapp/services/setupfcm.dart';
import 'package:provider/provider.dart';

class InboxPage extends StatefulWidget {
  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  Set<String> selectedIds = {};
  bool selectionMode = false;

  void _toggleSelection(String docId) {
    setState(() {
      if (selectedIds.contains(docId)) {
        selectedIds.remove(docId);
        if (selectedIds.isEmpty) selectionMode = false;
      } else {
        selectedIds.add(docId);
        selectionMode = true;
      }
    });
  }

  void _selectAll(List<QueryDocumentSnapshot> docs) {
    setState(() {
      selectedIds = docs.map((d) => d.id).toSet();
      selectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedIds.clear();
      selectionMode = false;
    });
  }

  Future<void> _deleteSelected(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final id in selectedIds) {
      batch.delete(
        FirebaseFirestore.instance
            .collection('notifications')
            .doc(uid)
            .collection('history')
            .doc(id),
      );
    }
    await batch.commit();
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Center(
        child: Text(
          "Login to accest this is page",
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .doc(user.uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        print("isi docs ${docs}");
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.primaryContainer,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primaryContainer,

            leading: selectionMode
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _clearSelection,
                  )
                : null,
            title: selectionMode
                ? Text(
                    '${selectedIds.length} selected',
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  )
                : Text(
                    'Inbox',
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
            actions: selectionMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () => _selectAll(docs),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSelected(user.uid),
                    ),
                  ]
                : [],
          ),
          body: docs.isEmpty
              ? Center(
                  child: Text(
                    'Nothing in inbox',
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                )
              : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final formattedTime = timestamp != null
                        ? TimeOfDay.fromDateTime(
                            timestamp.toDate(),
                          ).format(context)
                        : '';
                    final isSelected = selectedIds.contains(doc.id);

                    return GestureDetector(
                      onLongPress: () => _toggleSelection(doc.id),
                      onTap: selectionMode
                          ? () => _toggleSelection(doc.id)
                          : () {
                              // Aksi default jika tidak dalam mode select
                              final newsUrl = data['newsUrl'];
                              final commentId = data['commentId'];
                              if (newsUrl != null &&
                                  commentId != null &&
                                  navigatorKey.currentContext != null) {
                                navigateToComment(newsUrl, commentId);
                              }
                            },
                      child: Container(
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1)
                            : null,
                        child: InboxListItem(
                          title: data['title'] ?? '',
                          message: data['body'] ?? '',
                          time: formattedTime,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
