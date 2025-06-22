import 'package:flutter/material.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/screens/news/list_news.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:provider/provider.dart';

class ListBookmark extends StatelessWidget {
  const ListBookmark({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectionProvider>().isConnected;
    return Consumer<BookmarkProvider>(
      builder: (context, provider, _) {
        final List<Bookmark> bookmarks = provider.bookmark;

        if (bookmarks.isEmpty) {
          return const Center(child: Text("Belum ada bookmark"));
        }
        return NewsListSeparated(
          newsList: bookmarks,
          isConnected: isConnected,
        );
      },
    );
  }
}
