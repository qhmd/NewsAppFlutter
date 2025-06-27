import 'package:flutter/material.dart';
import 'package:newsapp/presentation/state/news_providers.dart';

loaderNews(NewsProvider provider, bool isConnected, String category) {
  if (!isConnected) {
    return const Center(child: Text("Tidak ada jaringan", style: TextStyle(color: Colors.white)));
  }
  if (provider.hasMore(category)) {
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