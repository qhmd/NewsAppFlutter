import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/news/list_news.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/state/news_providers.dart';
import 'dart:async';
import 'package:newsapp/presentation/state/connection_providers.dart';

class AllNews extends StatefulWidget {
  const AllNews({super.key});

  @override
  State<AllNews> createState() => _AllNews();
}

class _AllNews extends State<AllNews> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print("✅ [AllNews] initState dijalankan");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConnectionProvider>(context, listen: false);
      debugPrint("${provider.isConnected}");
    });
    // Langsung fetch data saat awal
    Future.microtask(() async {
      try {
        print("🔍 Mencoba ambil NewsProvider...");
        final provider = Provider.of<NewsProvider>(context, listen: false);
        print("✅ NewsProvider ditemukan.");
        await provider.fetchNewsProv();
        print("✅ fetchNewsProv selesai.");
      } catch (e, s) {
        print("❌ Error saat ambil NewsProvider atau fetch: $e");
        print(s);
      }
    });
    // Listener untuk load more
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final provider = Provider.of<NewsProvider>(context, listen: false);
    debugPrint("scrollnya ${_scrollController.position.pixels}");
    debugPrint("maxntya ${_scrollController.position.maxScrollExtent}");
    debugPrint("masih ada ${provider.hasMore}");
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
    final provider = Provider.of<NewsProvider>(context);
    final isConnected = context.watch<ConnectionProvider>().isConnected;
    final newsList = provider.news;

    return NewsListSeparated(
      newsList: newsList,
      scrollController: _scrollController,
      isConnected: isConnected,
      hasMore: provider.hasMore,
      loading: provider.loading,
      onRefresh: provider.refreshRandom,
    );
  }
}
