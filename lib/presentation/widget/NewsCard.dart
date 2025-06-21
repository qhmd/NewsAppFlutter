import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/Api/news.dart';
import 'package:newsapp/core/constants/formattedDate.dart';
import 'package:newsapp/data/models/bookmark.dart';

class NewsCard extends StatelessWidget {
  final News item; // tipe bisa disesuaikan
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;
  final bool isBookmarked;

  const NewsCard({
    required this.item,
    required this.bookmark,
    required this.onTap,
    required this.onToggleBookmark,
    required this.isBookmarked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final datePublish = formatDate(item.published_date);

    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade700, width: 1),
        ),
        color: theme.colorScheme.primaryContainer,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                item.multimedia[2]['url'],
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 130,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                    child: Icon(Icons.broken_image, color: Colors.white),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.2,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${item.byline} - $datePublish",
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: onToggleBookmark,
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          color: isBookmarked ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
