import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsapp/core/utils/urlConvert.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';
import 'package:newsapp/presentation/widget/app_icon.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:newsapp/services/action_icon_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
void shareButtomSheet(BuildContext context, Bookmark b) {

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      final auth = context.read<AuthProvider>();
      final bookmarkAccess = context.read<BookmarkProvider>();

      return StatefulBuilder(
        builder: (context, setState) {
          void handleBookmark() async {
            if (!auth.isLoggedIn) {
              context.read<PageIndexProvider>().changePage(2);
              showCustomToast("Silahkan Login terlebih dahulu");
              return;
            }

            await bookmarkAccess.toggleBookmark(
              b,
              auth.user!.uid,
              context,
            );

            setState(() {}); // refresh UI
          }

          final isBookmarked = context
              .watch<BookmarkProvider>()
              .isBookmarked(encodeUrl(b.id));

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share post',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ActionIconService(
                      icon: Icons.link,
                      label: 'Copy Link',
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: b.url),
                        );
                        showCustomToast("Link Berhasil Disalin");
                      },
                    ),
                    ActionIconService(
                      icon: Icons.bookmark,
                      colors: isBookmarked ? Colors.red : Colors.black,
                      label: 'Bookmark',
                      onTap: handleBookmark,
                    ),
                    ActionIconService(
                      icon: Icons.share,
                      label: 'Share via...',
                      onTap: () {
                        Share.share(b.url);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(),
                const SizedBox(height: 8),
                AppIcon(url: b.url),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}
