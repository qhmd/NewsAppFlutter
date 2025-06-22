import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void toastBookmark(context, bool isAddBookmark) {
  showOverlayNotification(
    (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 169, 40, 40),
            child: ListTile(
              leading: Icon(
                isAddBookmark ? Icons.bookmark_add : Icons.bookmark_remove_outlined,
                color: Colors.white,
              ),
              title: Text(
                isAddBookmark
                    ? "Berhasil Ditambahkan ke Bookmark"
                    : "Berhasil Dihapus dari Bookmark",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    },
    duration: const Duration(seconds: 3),
    position: NotificationPosition.top,
    key: ValueKey('bookmark_toast'),
  );
}


void showCustomToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.CENTER, // posisi: bawah
    backgroundColor: const Color.fromARGB(221, 152, 30, 30),
    textColor: Colors.white,
    fontSize: 16.0,
    timeInSecForIosWeb: 3,
  );
}