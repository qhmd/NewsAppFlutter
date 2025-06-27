import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:newsapp/presentation/state/pageindex_providers.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
import 'package:provider/provider.dart';

class Like extends StatelessWidget {
  final String newsUrl;
  final double buttonSize;

  const Like({required this.newsUrl, this.buttonSize = 24.0, super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Consumer<LikeProvider>(
      builder: (context, likeProvider, child) {
        return LikeButton(
          size: buttonSize,
          isLiked: likeProvider.isLiked(newsUrl),
          circleColor: const CircleColor(
            start: Color.fromARGB(255, 241, 45, 75),
            end: Color.fromARGB(255, 239, 28, 28),
          ),
          bubblesColor: const BubblesColor(
            dotPrimaryColor: Color.fromARGB(255, 238, 28, 25),
            dotSecondaryColor: Color.fromARGB(255, 255, 255, 255),
          ),
          likeBuilder: (bool isLiked) {
            return Icon(
              Icons.favorite,
              color: isLiked ? Colors.red : Colors.grey,
              size: buttonSize,
            );
          },
          likeCount: likeProvider.getLikeCount(newsUrl),
          countBuilder: (int? count, bool isLiked, String text) {
            var color = isLiked ? Colors.red : Colors.grey;
            Widget result;
            if (count == 0 || count == null) {
              result = Text("0", style: TextStyle(color: color));
            } else {
              result = Text(text, style: TextStyle(color: color));
            }
            return result;
          },
          onTap: (isLiked) async {
            if (auth.user?.uid == null) {
              final toProfile = context.read<PageIndexProvider>();
              showCustomToast("You have to login first");
              toProfile.changePage(2);
              return isLiked;
            }
            await likeProvider.toggleLike(newsUrl);
            return !isLiked;
          },
        );
      },
    );
  }
}
