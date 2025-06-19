import 'package:flutter/material.dart';

class Inbox extends StatelessWidget{
  const Inbox({super.key});

  @override
  Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Ini adalah inbox"),
            ),
        ],
      );
    }
}