// BookmarkProvider.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:newsapp/core/utils/urlConvert.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
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
    final isAlreadyBookmarked = _bookmarkedIds.contains(b.id);

    if (isAlreadyBookmarked) {
      _bookmarkedIds.remove(b.id);
      _bookmarks.removeWhere((item) => item.id == b.id);
    } else {
      _bookmarkedIds.add(b.id);
      _bookmarks.add(b);
    }

    notifyListeners();

    // Sync ke layanan (Hive + Firestore)
    try {
      await _service.toggleBookmark(b, uid);
    } catch (e) {
      // ❗ rollback jika perlu
      print("Error syncing bookmark: $e");

      // Opsional: rollback
      if (isAlreadyBookmarked) {
        _bookmarkedIds.add(b.id);
        _bookmarks.add(b);
      } else {
        _bookmarkedIds.remove(b.id);
        _bookmarks.removeWhere((item) => item.id == b.id);
      }
      notifyListeners(); // update lagi
    }
  }
  void clear() {
    _bookmarkedIds.clear();
    _bookmarks.clear();
    notifyListeners();
  }
}
