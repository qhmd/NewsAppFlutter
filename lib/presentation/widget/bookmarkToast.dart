import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

void toastBookmark(context, bool isAddBookmark) {
  showFlash(
    context: context,
    transitionDuration: Durations.short4,
    reverseTransitionDuration: Durations.short4,
    duration: const Duration(seconds: 3),
    builder: (context, controller) {
      return FlashBar(
        controller: controller,
        margin: EdgeInsets.only(left: 12,right: 12,top: 8),
        backgroundColor: const Color.fromARGB(255, 169, 40, 40),
        position: FlashPosition.top,
        reverseAnimationCurve: Curves.linear,
        forwardAnimationCurve: Curves.linear,
        dismissDirections: [FlashDismissDirection.vertical],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.red, width: 1),
        ),
        behavior: FlashBehavior.floating,
        content: Text(
          isAddBookmark ? "Berhasil Ditambahkan ke Bookmark" : "Berhasil Dihapus dari Bookmark",
          style: const TextStyle(color: Colors.white),
        ),
        icon: Icon(
          isAddBookmark ? Icons.bookmark_add : Icons.bookmark_remove_outlined,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      );
    },
  );
}