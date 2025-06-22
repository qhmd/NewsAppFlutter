import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/formatted_date.dart';
import 'package:newsapp/data/models/bookmark.dart';

class NewsCard extends StatelessWidget {
  final Bookmark newsBookmarkList;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;
  final bool isBookmarked;

  const NewsCard({
    required this.newsBookmarkList,
    required this.onTap,
    required this.onToggleBookmark,
    required this.isBookmarked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print("start here");
    final title = newsBookmarkList.title.isNotEmpty
        ? newsBookmarkList.title
        : "Tanpa Judul";
    print(title);
    final source = newsBookmarkList.source.isNotEmpty
        ? newsBookmarkList.source
        : "Tanpa Sumber";
    print(source);
    final datePublish = newsBookmarkList.date.isNotEmpty
        ? formatDate(newsBookmarkList.date)
        : "Tanggal tidak tersedia";
    print(datePublish);
    // final imageUrl = (newsBookmarkList.multimedia.isNotEmpty)
    //     ? newsBookmarkList.multimedia
    //     : null;
    // print("🖼️ Apakah imageUrl null? ${imageUrl == null}");
    // print("🖼️ Nilai imageUrl: '$imageUrl'");
    // print("🖼️ Panjang string imageUrl: ${imageUrl.length}");
    // print("🖼️ Apakah imageUrl kosong? ${imageUrl.trim().isEmpty}");

    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade700, width: 1),
        ),
        color: theme.colorScheme.primaryContainer,
        child: Column(
          children: [
            // ClipRRect(
            //   borderRadius: const BorderRadius.vertical(
            //     top: Radius.circular(12),
            //   ),
            //   child: imageUrl != null
            //       ? Image.network(
            //           imageUrl,
            //           height: 130,
            //           width: double.infinity,
            //           fit: BoxFit.cover,
            //           errorBuilder: (context, error, stackTrace) {
            //             return _imagePlaceholder();
            //           },
            //         )
            //       : _imagePlaceholder(),
            // ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                          "$source - $datePublish",
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: onToggleBookmark,
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: isBookmarked ? Colors.red : Colors.grey,
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
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 130,
      width: double.infinity,
      color: Colors.grey.shade800,
      child: const Icon(Icons.broken_image, color: Colors.white),
    );
  }
}
