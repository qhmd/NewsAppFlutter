// BookmarkProvider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/bookmark.dart';
import '../../services/bookmark_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _service = BookmarkService();
  final Set<String> _bookmarkedIds = {};
  List<Bookmark> _bookmarks = [];
  List<dynamic> _bookmarksHive = [];

  Future<dynamic> GetBox () async {
    final box = await BookmarkService().getBox();
    final all = box.values.toList();
    return all;
  }


  List<Bookmark> get bookmark => _bookmarks;
  List<dynamic> get bookmarksHive => _bookmarksHive;

  // List<Bookmark> get bookmarks => _bookmarks;

  Future<void> loadFromLocal() async {
    _bookmarks = await _service.getAllLocalBookmarks();
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

