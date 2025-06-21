// BookmarkProvider.dart
import 'package:flutter/material.dart';
import '../../data/models/bookmark.dart';
import '../../services/bookmark_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _service = BookmarkService();
  final Set<String> _bookmarkedIds = {};
  List<Bookmark> _bookmarks = [];

  List<Bookmark> get bookmarks => _bookmarks;

  Future<void> loadFromLocal() async {
    _bookmarks = await _service.getAllLocalBookmarks();
    _bookmarkedIds
      ..clear()
      ..addAll(_bookmarks.map((b) => b.id));
    notifyListeners();
  }

  Future<void> syncFromCloud(String uid) async {
    await _service.syncFromCloud(uid);
    await loadFromLocal();
  }

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  Future<void> toggleBookmark(Bookmark b, String uid, context) async {
    await _service.toggleBookmark(b, uid, context);
    await loadFromLocal();
  }
}

