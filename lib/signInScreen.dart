import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './ui/screens/profile.dart';
import './signInWithGoogle.dart';

// A stateless widget for the Sign-In screen
class SignInScreen extends StatelessWidget {
  // Instance of GoogleAuthService to handle Google Sign-In
  final AuthService _authService = AuthService();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and styling
      appBar: AppBar(
        title: Text("GFG Sign In"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      // Main body of the screen
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            // Asynchronous function triggered on button press
            onPressed: () async {
              // Attempt to sign in with Google
              User? user = await _authService.signInWithGoogle();
              // If sign-in is successful, navigate to the HomeScreen
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Profile(user: user)),
                );
              }
            },
            // Text displayed on the button
            child: Text("Sign in with Google"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            // Asynchronous function triggered on button press
            onPressed: () async {
              // Attempt to sign in with Google
              User? user = await _authService.signInWithFacebook();
              // If sign-in is successful, navigate to the HomeScreen
              print("isi users $user");
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Profile(user: user)),
                );
              }
            },
            // Text displayed on the button
            child: Text("Sign in with Facebook"),
          ),
        ],
      ),
    );
  }
}
