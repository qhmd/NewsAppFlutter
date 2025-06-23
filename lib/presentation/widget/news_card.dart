import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/Api/news.dart';
import 'package:newsapp/core/constants/formatted_date.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:newsapp/presentation/widget/like.dart';
import 'package:newsapp/presentation/widget/share_buttom_sheet.dart'
    hide SizedBox, Text;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NewsCard extends StatelessWidget {
  final Bookmark newsBookmarkList;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;
  final bool isBookmarked;

  const NewsCard({
    required this.newsBookmarkList,
    required this.onTap,
    required this.onToggleBookmark,
    required this.isBookmarked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = newsBookmarkList.title.isNotEmpty
        ? newsBookmarkList.title
        : "Tanpa Judul";
    final source = newsBookmarkList.source.isNotEmpty
        ? newsBookmarkList.source
        : "Tanpa Sumber";
    final datePublish = newsBookmarkList.date.isNotEmpty
        ? formatDate(newsBookmarkList.date)
        : "Tanggal tidak tersedia";
    final imageUrl = newsBookmarkList.multimedia.isNotEmpty
        ? newsBookmarkList.multimedia
        : "Tanggal tidak tersedia";
    print("isBookmarked ? ${isBookmarked}");
    final isConnected = Provider.of<ConnectionProvider>(context).isConnected;
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),

              child: isConnected && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                          "$source - $datePublish",
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Like(newsUrl: newsBookmarkList.url),
                          SizedBox(width: 35),
                          GestureDetector(
                            child: Icon(
                              Icons.share_outlined,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              print("di news card ${newsBookmarkList.id}");
                              shareButtomSheet(context, newsBookmarkList);
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              color: isBookmarked ? Colors.red : Colors.grey,
                            ),
                            onTap: () {
                              onToggleBookmark();
                            },
                          ),
                          SizedBox(width: 10),

                          GestureDetector(
                            child: Icon(
                              Icons.share_outlined,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              print("di news card ${newsBookmarkList.id}");
                              shareButtomSheet(context, newsBookmarkList);
                            },
                          ),
                          SizedBox(
                            width: 14,
                          ),
                        ],
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

  Widget _imagePlaceholder() {
    return Container(
      height: 130,
      width: double.infinity,
      color: Colors.grey.shade800,
      child: const Icon(Icons.broken_image, color: Colors.white),
    );
  }
}
