// Dalam file baru, misal: lib/presentation/widget/news_header_widget.dart
import 'package:flutter/material.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/widget/news_card.dart';
import 'package:newsapp/presentation/widget/modal_web_view.dart';

class NewsHeaderWidget extends StatelessWidget {
  final Bookmark news;

  const NewsHeaderWidget({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return NewsCard(
      newsBookmarkList: news,
      onTap: () => openWebViewModal(context, news.url),
      showActions: false,
    );
  }
}