import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/Api/news.dart';
import 'package:newsapp/core/constants/formatted_date.dart';
import 'package:newsapp/core/utils/urlConvert.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/comment_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:newsapp/presentation/widget/comment_page.dart';
import 'package:newsapp/presentation/widget/like.dart';
import 'package:newsapp/presentation/widget/share_buttom_sheet.dart'
    hide SizedBox, Text;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NewsCard extends StatelessWidget {
  final Bookmark newsBookmarkList;
  final VoidCallback onTap;
  final bool showActions;
  const NewsCard({
    required this.newsBookmarkList,
    required this.onTap,
    this.showActions = true, // default true
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
    final isConnected = Provider.of<ConnectionProvider>(context).isConnected;

    final encodeLink = encodeUrl(newsBookmarkList.url);
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
                          SizedBox(width: 20),
                          Like(newsUrl: newsBookmarkList.url),
                          SizedBox(width: 15),
                          if (showActions)
                            Row(
                              children: [
                                GestureDetector(
                                  child: Row(
                                    children: [
                                      Icon(Icons.comment, color: Colors.grey),
                                      SizedBox(width: 7),
                                      Consumer<CommentProvider>(
                                        builder: (context, commentprovider, _) {
                                          print("tes url ${newsBookmarkList.url}");
                                          final count = commentprovider
                                              .getCount(
                                                newsBookmarkList.url
                                              );
                                          return Text(
                                            "$count",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CommentPage(news: newsBookmarkList),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Consumer<BookmarkProvider>(
                            builder: (context, bookmarkProvider, _) {
                              final isBookmarkedNow = bookmarkProvider
                                  .isBookmarked(newsBookmarkList.id);
                              final uid = context
                                  .read<AuthProvider>()
                                  .user
                                  ?.uid;

                              return GestureDetector(
                                child: Icon(
                                  isBookmarkedNow
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color: isBookmarkedNow
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onTap: () {
                                  if (uid == null) {
                                    final toProfile = context
                                        .read<PageIndexProvider>();
                                    showCustomToast("You have to login first");
                                    toProfile.changePage(2);
                                    return;
                                  }

                                  bookmarkProvider.toggleBookmark(
                                    newsBookmarkList,
                                    uid,
                                    context,
                                  );
                                  toastBookmark(
                                    context,
                                    !isBookmarkedNow,
                                  ); // opsional notifikasi
                                },
                              );
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
                          SizedBox(width: 14),
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