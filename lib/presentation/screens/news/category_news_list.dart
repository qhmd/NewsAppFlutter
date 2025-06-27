import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/news/news_list_separated.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/state/news_providers.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:newsapp/presentation/state/comment_providers.dart';
import 'dart:async';

class CategoryNewsList extends StatefulWidget {
  final String category;
  final String searchQuery;
  final ScrollController scrollController;

  const CategoryNewsList({
    super.key,
    required this.category,
    this.searchQuery = '',
    required this.scrollController,
  });

  @override
  State<CategoryNewsList> createState() => _CategoryNewsListState();
}

class _CategoryNewsListState extends State<CategoryNewsList> {
  bool _previousConnectionState = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConnectionProvider>(context, listen: false);
      _previousConnectionState = provider.isConnected;
      if (provider.isConnected) {
        _fetchNewsData();
        if (!widget.scrollController.hasListeners) {
          widget.scrollController.addListener(_handleScroll);
        }
      }
    });
  }

  void _fetchNewsData() async {
    try {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.fetchNews(widget.category);

      final likeProvider = Provider.of<LikeProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(
        context,
        listen: false,
      );

      for (var news in newsProvider.getNews(widget.category)) {
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
      if (widget.scrollController.position.pixels >=
              widget.scrollController.position.maxScrollExtent - 100 &&
          !provider.isLoading(widget.category) &&
          provider.hasMore(widget.category)) {
        provider.fetchNews(widget.category);
      }
    });
  }

  void _handleConnectionChange(bool isConnected) {
    if (!_previousConnectionState && isConnected) {
      _fetchNewsData();
      if (!widget.scrollController.hasListeners) {
        widget.scrollController.addListener(_handleScroll);
      }
    } else if (_previousConnectionState && !isConnected) {
      if (widget.scrollController.hasListeners) {
        widget.scrollController.removeListener(_handleScroll);
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
    // Jangan dispose scrollController di sini karena dikirim dari luar!
    Provider.of<CommentProvider>(context, listen: false).disposeListeners();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final isConnected = context.read<ConnectionProvider>().isConnected;
    if (!isConnected) {
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
      await provider.refreshNews(widget.category);

      final likeProvider = Provider.of<LikeProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(
        context,
        listen: false,
      );

      for (var news in provider.getNews(widget.category)) {
        likeProvider.listenToLikeChanges(news.url);
        commentProvider.ListenToCommentCount(news.url);
      }
      // Scroll ke atas setelah refresh
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } catch (e) {
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
    List newsList = provider.getNews(widget.category);
    final isConnected = context.watch<ConnectionProvider>().isConnected;
    final isLoading = provider.isLoading(widget.category);

    if (widget.searchQuery.isNotEmpty && widget.category == 'all') {
      newsList = newsList
          .where(
            (item) => item.title.toLowerCase().contains(
              widget.searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    return Stack(
      children: [
        NewsListSeparated(
          newsList: newsList,
          scrollController: widget.scrollController,
          isConnected: isConnected,
          hasMore: provider.hasMore(widget.category),
          loading: isLoading,
          onRefresh: _handleRefresh,
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // Overlay kehitaman
            ),
          ),
      ],
    );
  }
}
