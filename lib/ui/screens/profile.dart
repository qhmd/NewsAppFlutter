import 'package:flutter/material.dart';

class Profile extends StatelessWidget{
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Ini adalah Profile"),
            ),
        ],
      );
    }
}