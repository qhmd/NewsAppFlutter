import 'package:firebase_auth/firebase_auth.dart'hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:newsapp/presentation/screens/profile/sign_in_screen.dart';
import 'data_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            debugPrint("megeksekusi ini");
            return DataProfile(user: snapshot.data!);
          }
          return LoginScreen();
        },
      ),
    );
  }
}
