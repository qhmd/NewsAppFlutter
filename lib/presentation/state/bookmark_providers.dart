// BookmarkProvider.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:newsapp/core/utils/urlConvert.dart';
import '../../data/models/bookmark.dart';
import '../../services/bookmark_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _service = BookmarkService();
  final Set<String> _bookmarkedIds = {};
  List<Bookmark> _bookmarks = [];
  List<String> _bookmarksIdss = [];

  Future<dynamic> GetBox() async {
    final box = await BookmarkService().getBox();
    final all = box.values.toList();
    return all;
  }

  List<Bookmark> get bookmark => _bookmarks;
  List<String> get debugBookmarkedIds => _bookmarkedIds.toList();

  // List<Bookmark> get bookmarks => _bookmarks;

  Future<void> loadFromLocal() async {
    _bookmarks = await _service.getAllLocalBookmarks();
    _bookmarkedIds.clear();
    _bookmarkedIds.addAll(_bookmarks.map((b) => b.id));
    print("isi b adalah ${_bookmarkedIds.toList()}");
    _bookmarksIdss = debugBookmarkedIds;
    notifyListeners();
  }

  Future<void> syncFromCloud(String uid) async {
    await _service.syncFromCloud(uid);
    await loadFromLocal();
  }

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  Future<void> toggleBookmark(Bookmark b, String uid, context) async {
    // b.id = encodeUrl(b.id);
    print("isi id di toggle${b.id}");
    await _service.toggleBookmark(b, uid, context);
    if (_bookmarkedIds.contains(b.id)) {
      _bookmarkedIds.remove(b.id);
    } else {
      _bookmarkedIds.add(b.id);
    }
    await loadFromLocal();
  }
}
