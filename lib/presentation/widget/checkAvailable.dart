import 'package:flutter/material.dart';
import 'package:newsapp/presentation/state/NewsProvider.dart';

loaderNews(NewsProvider provider, bool isConnected) {
  if (!isConnected) {
    return Center(child: Text("Tidak ada jaringan", style: TextStyle(color: Colors.white)));
  }
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
