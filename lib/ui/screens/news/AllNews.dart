import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/core/providers/NewsProvider.dart';
import 'package:newsapp/ui/screens/news/WebViewModal.dart';
import '../../../core/constants/formattedDate.dart';

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

    // Langsung fetch data saat awal
    Future.microtask(() {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      provider.fetchNewsProv();
    });

    // Listener untuk load more
    _scrollController.addListener(() {
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
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openWebViewModal(BuildContext context, String url) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.onPrimary,
      useSafeArea: true,
      enableDrag: false,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        child: WebViewModal(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<NewsProvider>(context);
    final newsList = provider.news;

    return RefreshIndicator(
      onRefresh: provider.refreshRandom,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: newsList.length + 1, // +1 untuk loading indicator di bawah
        itemBuilder: (context, index) {
          if (index == newsList.length) {
            if (provider.hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text("No more news")),
              );
            }
          }

          final item = newsList[index];
          final datePublish = formatDate(item.published_date);

          return InkWell(
            onTap: () => _openWebViewModal(context, item.url),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade700, width: 1),
              ),
              color: theme.colorScheme.primaryContainer,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      item.multimedia[2]['url'],
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${item.byline} - $datePublish",
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(color: Colors.grey),
      ),
    );
  }
}
