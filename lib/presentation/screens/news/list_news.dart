import 'package:flutter/material.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/widget/news_card.dart';
import 'package:newsapp/presentation/widget/modal_web_view.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';

class NewsListSeparated extends StatelessWidget {
  final List newsList;
  final ScrollController? scrollController;
  final bool isConnected;
  final bool hasMore;
  final bool loading;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;

  const NewsListSeparated({
    super.key,
    required this.newsList,
    this.scrollController,
    required this.isConnected,
    this.hasMore = false,
    this.loading = false,
    this.onRefresh,
    this.onLoadMore,
  });

  Bookmark _bookmark(item) {
    print(item);
    if (item is Bookmark) {
      print(item.title);
      return item;
    }

    // Kalau News (misalnya New York Times API)
    return Bookmark(
      id: item.url,
      title: item.title,
      source: item.byline ?? '',
      multimedia: item.multimedia[2]['url'] ?? '',
      date: item.published_date,
      url: item.url,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: newsList.length + 1,
        itemBuilder: (context, index) {
          if (index == newsList.length) {
            // Loader
            return Center(
              child: hasMore && !loading
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            );
          }

          final item = newsList[index];
          final bookmark = _bookmark(item);
          final isBookmarked = context.watch<BookmarkProvider>().isBookmarked(
            item.url,
          );
          return Material(
            color: Colors.transparent,
            child: NewsCard(
              newsBookmarkList: bookmark,
              isBookmarked: isBookmarked,
              onTap: () => openWebViewModal(context, item.url),
              onToggleBookmark: () {
                final auth = context.read<AuthProvider>();
                if (!auth.isLoggedIn) {
                  context.read<PageIndexProvider>().changePage(2);
                  showCustomToast("Silahkan Login terlebih dahulu");
                  return;
                }
                context.read<BookmarkProvider>().toggleBookmark(
                  bookmark,
                  auth.user!.uid,
                  context,
                );
              },
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(color: Colors.grey),
      ),
    );
  }
}
