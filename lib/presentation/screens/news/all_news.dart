import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/news/list_news.dart';
import 'package:newsapp/presentation/state/comment_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/state/news_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'dart:async';

class AllNews extends StatefulWidget {
  const AllNews({super.key});

  @override
  State<AllNews> createState() => _AllNews();
}

class _AllNews extends State<AllNews> {
  final ScrollController _scrollController = ScrollController();
  bool _previousConnectionState = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    print("✅ [AllNews] initState dijalankan");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConnectionProvider>(context, listen: false);
      _previousConnectionState = provider.isConnected;
      debugPrint("Initial connection state: ${provider.isConnected}");

      if (provider.isConnected) {
        _fetchNewsData();
        if (!_scrollController.hasListeners) {
          _scrollController.addListener(_handleScroll);
        }
      }
    });
  }

  void _fetchNewsData() async {
    try {
      print("🔍 Mencoba ambil NewsProvider...");
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.fetchNewsProv();
      print("✅ fetchNewsProv selesai");

      // Fetch status like setelah berhasil ambil berita
      final likeProvider = Provider.of<LikeProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(
        context,
        listen: false,
      );

      for (var news in newsProvider.news) {
        likeProvider.listenToLikeChanges(news.url);
        commentProvider.ListenToCommentCount(news.url);
      }
    } catch (e, s) {
      print("❌ Error saat ambil berita: $e");
      print(s);
    }
  }

  void _handleScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !provider.loading &&
          provider.hasMore) {
        provider.fetchNewsProv();
      }
    });
  }

  void _handleConnectionChange(bool isConnected) {
    if (!_previousConnectionState && isConnected) {
      print("🌐 Koneksi restored! Fetching data...");
      _fetchNewsData();
      if (!_scrollController.hasListeners) {
        _scrollController.addListener(_handleScroll);
      }
    } else if (_previousConnectionState && !isConnected) {
      print("📵 Koneksi terputus!");
      if (_scrollController.hasListeners) {
        _scrollController.removeListener(_handleScroll);
      }
    }
    _previousConnectionState = isConnected;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isConnected = context.watch<ConnectionProvider>().isConnected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleConnectionChange(isConnected);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    Provider.of<CommentProvider>(context, listen: false).disposeListeners();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final isConnected = context.read<ConnectionProvider>().isConnected;

    if (!isConnected) {
      print("📵 Tidak bisa refresh - tidak ada koneksi internet");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada koneksi internet'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      await provider.refreshRandom();
      print("✅ Refresh berhasil");

      // Refresh status like juga
      final likeProvider = Provider.of<LikeProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(
        context,
        listen: false,
      );

      for (var news in provider.news) {
        likeProvider.listenToLikeChanges(news.url);
        commentProvider.ListenToCommentCount(news.url);
      }
    } catch (e) {
      print("❌ Error saat refresh: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat ulang data'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();
    final newsList = provider.news;
    final isConnected = context.watch<ConnectionProvider>().isConnected;

    return NewsListSeparated(
      newsList: newsList,
      scrollController: _scrollController,
      isConnected: isConnected,
      hasMore: provider.hasMore,
      loading: provider.loading,
      onRefresh: _handleRefresh,
    );
  }
}
