import 'package:flutter/material.dart';

class InboxListItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final VoidCallback? onTap;

  const InboxListItem({
    Key? key,
    required this.title,
    required this.message,
    required this.time,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    if (title.isEmpty && message.isEmpty && time.isEmpty) {
      return Center(child: Text("Tidak ada notif"));
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: theme.onPrimary),
      ),
      color: theme.primaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Pastikan bentuknya lingkaran
                  border: Border.all(
                    color: theme.primary, // Warna border
                    width: 1.5, // Ketebalan border
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: theme.primaryContainer,
                  radius: 24,
                  child: Icon(Icons.notifications, color: theme.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Center(
                child: Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
