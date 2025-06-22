import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsapp/presentation/widget/app_icon.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:newsapp/services/action_icon_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

void shareButtomSheet(BuildContext context, url) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Clipboard.setData(ClipboardData(text: url));
                    showCustomToast("Link Berhasil Disalin");
                  },
                ),
                ActionIconService(
                  icon: Icons.bookmark,
                  label: 'Bookmark',
                  onTap: () {
                    /* simpan */
                  },
                ),
                ActionIconService(
                  icon: Icons.share,
                  label: 'Share via...',
                  onTap: () {
                    Share.share(url);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(),
            const SizedBox(height: 8),
            AppIcon(url: url),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
