import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/news/list_news.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
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
  bool _previousConnectionState = false; // Track previous connection state

  @override
  void initState() {
    super.initState();
    print("✅ [AllNews] initState dijalankan");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConnectionProvider>(context, listen: false);
      _previousConnectionState = provider.isConnected;
      debugPrint("Initial connection state: ${provider.isConnected}");
    });

    // Langsung fetch data saat awal jika ada koneksi
    final checkConnection = context.read<ConnectionProvider>().isConnected;
    if (checkConnection) {
      _fetchNewsData();
      // Listener untuk load more
      _scrollController.addListener(_handleScroll);
    }
  }

  void _fetchNewsData() {
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

  void _handleConnectionChange(bool isConnected) {
    // Jika sebelumnya offline dan sekarang online, fetch data
    if (!_previousConnectionState && isConnected) {
      print("🌐 Koneksi restored! Fetching data...");
      _fetchNewsData();
      // Tambahkan scroll listener jika belum ada
      if (!_scrollController.hasListeners) {
        _scrollController.addListener(_handleScroll);
      }
    }
    // Jika sekarang offline, hapus scroll listener untuk menghemat resource
    else if (_previousConnectionState && !isConnected) {
      print("📵 Koneksi terputus!");
      if (_scrollController.hasListeners) {
        _scrollController.removeListener(_handleScroll);
      }
    }

    _previousConnectionState = isConnected;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final isConnected = context.read<ConnectionProvider>().isConnected;

    if (!isConnected) {
      print("📵 Tidak bisa refresh - tidak ada koneksi internet");
      // Tampilkan snackbar atau toast untuk memberi tahu user
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

    // Jika ada koneksi, lakukan refresh
    try {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      await provider.refreshRandom();
      print("✅ Refresh berhasil");
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
    final provider = Provider.of<NewsProvider>(context);
    final newsList = provider.news;
    final isConnected = context.watch<ConnectionProvider>().isConnected;
    
    Future.microtask(() {
      final likeProvider = Provider.of<LikeProvider>(context, listen: false);
      for (var news in newsList) {
        likeProvider.fetchLikeStatus(news.url);
      }
    });
    // Handle connection state changes
    _handleConnectionChange(isConnected);

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
