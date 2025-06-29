// Contoh struktur:
import 'package:flutter/material.dart';

class CommentInputBar extends StatefulWidget {
  final TextEditingController controller;
  final String? replyingToUserName;
  final bool isEditing;
  final VoidCallback onCancelReply;
  final VoidCallback onCancelEdit;
  final VoidCallback onSend;

  const CommentInputBar({
    super.key,
    required this.controller,
    this.replyingToUserName,
    required this.isEditing,
    required this.onCancelReply,
    required this.onCancelEdit,
    required this.onSend,
  });

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  // Logic for TextField, buttons, etc.
  // Anda akan memindahkan semua logika UI dari bagian input bar di CommentPage ke sini
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (widget.isEditing)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text("Mengedit komentar"),
                TextButton(
                  onPressed: widget.onCancelEdit,
                  child: const Text("Batal"),
                ),
              ],
            ),
          ),
        if (widget.replyingToUserName != null)
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 1)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Row(
                children: [
                  Text(
                    "Balas ke ${widget.replyingToUserName}",
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                  TextButton(
                    onPressed: widget.onCancelReply,
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
                  controller: widget.controller,
                  maxLines: null,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Tulis komentar...",
                    border: OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintStyle: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: theme.colorScheme.onPrimary),
                onPressed: widget.onSend,
              ),
            ],
          ),
        ),
      ],
    );
  }
}