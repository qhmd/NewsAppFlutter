import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  final double buttonSize = 30.0;
  final int LoveCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Inbox Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            
            // LikeButton Implementation
            LikeButton(
              size: buttonSize,
              circleColor: const CircleColor(
                start: Color.fromARGB(255, 241, 45, 75), 
                end: Color.fromARGB(255, 239, 28, 28)
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
              likeCount: LoveCount,
              countBuilder: (int? count, bool isLiked, String text) {
                var color = isLiked ? Colors.red : Colors.grey;
                Widget result;
                if (count == 0 || count == null) {
                  result = Text(
                    "0",
                    style: TextStyle(color: color),
                  );
                } else {
                  result = Text(
                    text,
                    style: TextStyle(color: color),
                  );
                }
                return result;
              },
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Tap the home icon above to like!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}