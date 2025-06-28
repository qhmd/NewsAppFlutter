import 'package:flutter/material.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/screens/news/news_list_separated.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:provider/provider.dart';

class ListBookmark extends StatelessWidget {
  const ListBookmark({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = context.watch<ConnectionProvider>().isConnected;
    return Consumer<BookmarkProvider>(
      builder: (context, provider, _) {
        final List<Bookmark> bookmarks = provider.bookmark;
        print("ini dicetak gak");
        return Scaffold(
          backgroundColor: theme.colorScheme.primaryContainer,
          appBar: AppBar(
            title: Text(
              "Bookmark",
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
            backgroundColor: theme.colorScheme.primaryContainer,
          ),
          body: bookmarks.isEmpty
              ? Center(
                  child: Text(
                    "Bookmark news will show here",
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                )
              : NewsListSeparated(
                  newsList: bookmarks,
                  isConnected: isConnected,
                ),
        );
      },
    );
  }
}
