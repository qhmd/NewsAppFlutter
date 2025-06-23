import 'package:flutter/material.dart';
import 'package:newsapp/core/utils/urlConvert.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/connection_providers.dart';
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
      return item;
    }

    return Bookmark(
      id: item.url,
      title: item.title,
      source: item.byline ?? '',
      multimedia: item.multimedia?[2]?['url'] ?? '',
      date: item.published_date,
      url: item.url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkConnection = context.read<ConnectionProvider>().isConnected;

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: newsList.length + 1,
        itemBuilder: (context, index) {
          if (index == newsList.length) {

            // Loading saat load more
            if (hasMore && loading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Loading saat awal masuk tanpa data dan sedang loading
            else if (newsList.isEmpty && loading) {
              return const Padding(
                padding: EdgeInsets.all(50.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Pesan saat tidak ada koneksi dan tidak ada data
            else if (newsList.isEmpty && !isConnected && !loading) {
              return const Padding(
                padding: EdgeInsets.all(50.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada koneksi internet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Periksa koneksi internet Anda',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final item = newsList[index];
          final bookmark = _bookmark(item);
          return Material(
            color: Colors.transparent,
            child: NewsCard(
              newsBookmarkList: bookmark,
              onTap: () => openWebViewModal(context, item.url),
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(color: Colors.grey),
      ),
    );
  }
}