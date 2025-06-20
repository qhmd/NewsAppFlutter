import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/AuthService.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              User? user = await _authService.signInWithGoogle();
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Google login gagal")),
                );
              }
            },
            child: Text("Sign in with Google"),
          ),
          ElevatedButton(
            onPressed: () async {
              User? user = await _authService.signInWithFacebook();
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Facebook login gagal")),
                );
              }
            },
            child: Text("Sign in with Facebook"),
          ),
        ],
      ),
    );
  }
}
