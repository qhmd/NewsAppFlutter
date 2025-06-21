import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/AuthProviders.dart';
import 'package:newsapp/presentation/widget/NewsCard.dart';
import 'package:newsapp/presentation/widget/checkAvailable.dart';
import 'package:newsapp/presentation/widget/modalWebView.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/state/NewsProvider.dart';
import 'package:newsapp/presentation/screens/news/WebViewModal.dart';
import '../../../core/constants/formattedDate.dart';
import 'package:newsapp/services/bookmark_service.dart';
import 'package:newsapp/presentation/state/BookmarkProvider.dart';
import 'dart:async';
import 'package:newsapp/presentation/state/ConnectionProvider.dart';

class AllNews extends StatefulWidget {
  const AllNews({super.key});

  @override
  State<AllNews> createState() => _AllNews();
}

class _AllNews extends State<AllNews> {
  final ScrollController _scrollController = ScrollController();
  final BookmarkService _bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConnectionProvider>(context, listen: false);
      print(provider.isConnected);
    });
    // Langsung fetch data saat awal
    Future.microtask(() {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      provider.fetchNewsProv();
    });

    // Listener untuk load more
    _scrollController.addListener(_handleScroll);
  }

  Bookmark _bookmark(item) {
    return Bookmark(
      id: item.url,
      title: item.title,
      source: item.byline,
      multimedia: item.multimedia[2]['url'] ?? '',
      date: item.published_date,
      url: item.url,
    );
  }

  void _handleScroll() {
    final provider = Provider.of<NewsProvider>(context, listen: false);
    print("scrollnya ${_scrollController.position.pixels}");
    print("maxntya ${_scrollController.position.maxScrollExtent}");
    print("masih ada ${provider.hasMore}");
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !provider.loading &&
        provider.hasMore) {
      provider.fetchNewsProv();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<NewsProvider>(context);
    final isConnected = context.watch<ConnectionProvider>().isConnected;
    final newsList = provider.news;

    return RefreshIndicator(
      onRefresh: provider.refreshRandom,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: newsList.length + 1,
        itemBuilder: (context, index) {
          if (index == newsList.length) {
            loaderNews(provider, isConnected);
          }

          final item = newsList[index];
          final bookmark = _bookmark(item);
          final isBookmarked = context.watch<BookmarkProvider>().isBookmarked(
            item.url,
          );
          return NewsCard(
            item: item,
            bookmark: bookmark,
            isBookmarked: isBookmarked,
            onTap: () => openWebViewModal(context, item.url),
            onToggleBookmark: () {
              final auth = context.read<AuthProvider>();
              if (!auth.isLoggedIn) return;
              context.read<BookmarkProvider>().toggleBookmark(
                bookmark,
                auth.user!.uid,
                context,
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(color: Colors.grey),
      ),
    );
  }
}
