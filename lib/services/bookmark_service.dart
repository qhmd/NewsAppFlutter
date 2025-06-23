import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/core/utils/urlConvert.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';

class BookmarkService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Mendapatkan instance Box, pastikan box sudah dibuka
  Future<Box<Bookmark>> getBox() async {
    const boxName = 'bookmarks';

    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<Bookmark>(boxName);
    }

    return Hive.box<Bookmark>(boxName);
  }

  /// Menambahkan bookmark ke Hive dan Firebase
  Future<void> addBookmark(Bookmark bookmark, uid) async {
    final bId = encodeUrl(bookmark.id);
    final box = await getBox();
    final normalizedBookmark = bookmark.copyWith(
      id: bId,
    ); // 👈 ubah id Bookmark-nya

    await box.put(bId, normalizedBookmark);

    print("isi bookmark id ${bId}");
    final saved = box.get(bId);

    if (uid != null) {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(bId)
          .set({
            'urlPicture': bookmark.multimedia,
            'title': bookmark.title,
            'sourceNews': bookmark.source,
            'uploadDate': bookmark.date,
            'urlNews': bookmark.url,
          });
    }
  }

  /// Menghapus bookmark dari Hive dan Firebase
  Future<void> removeBookmark(String id, uid) async {
    final box = await getBox();
    await box.delete(id);
    if (uid != null) {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(id)
          .delete();
    }
  }

  /// Mengambil semua bookmark dari Hive
  Future<List<Bookmark>> getAllLocalBookmarks() async {
    final box = await getBox();
    return box.values.toList();
  }

  /// Menyinkronkan data dari Firebase ke Hive (cloud → lokal)
  Future<void> syncFromCloud(String uid) async {
    if (uid == null) return;
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .get();

      final box = await getBox();
      await box.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final bookmark = Bookmark(
          id: doc.id,
          multimedia: data['urlPicture'] ?? '',
          title: data['title'] ?? '',
          source: data['sourceNews'] ?? '',
          date: data['uploadDate'] ?? '',
          url: data['urlNews'] ?? '',
        );
        print("isi id saat lpoad ${bookmark.id}");
        await box.put(bookmark.id, bookmark);
      }
    } catch (e) {
      debugPrint('Gagal sync cloud (offline?): $e');
    }
  }

  /// Cek apakah bookmark sudah ada
  Future<bool> isBookmarked(String id) async {
    final box = await getBox();
    return box.containsKey(id);
  }

  Future<void> toggleBookmark(Bookmark bookmark, uid, context) async {
    final id = encodeUrl(bookmark.url);
    final bookmarked = await isBookmarked(id);

    if (bookmarked) {
      try {
        await removeBookmark(id, uid);

        toastBookmark(context, false);
      } catch (e) {
        debugPrint("gagal unbookmark ${e}");
      }
    } else {
      // await box.put(bookmark.url, bookmark);
      try {
        await addBookmark(bookmark, uid);
        toastBookmark(context, true);
        final box = await getBox();
        final all = box.values.toList();
        debugPrint("📦 Isi bookmarkBox saat di add: ${all.length} item");
        for (var item in all) {
          debugPrint(" tesss - ${item.id}");
        }
      } catch (e) {
        debugPrint("gagal meyimpan bookamrk ${e}");
      }
    }
  }
}
