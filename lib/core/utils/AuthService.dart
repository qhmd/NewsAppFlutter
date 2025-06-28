import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:newsapp/presentation/state/auth_providers.dart';

/// A service class to handle Google Sign-In
// and authentication using Firebase.
class AuthService {
  // FirebaseAuth instance to handle authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn instance to handle Google Sign-In.
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookSignIn = FacebookAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Signs in the user with Google and returns the authenticated Firebase [User].
  ///
  /// Returns `null` if the sign-in process is canceled or fails.
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the Google Sign-In flow.
      final googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in.
      if (googleUser == null) return null;

      // Retrieve the authentication details from the Google account.
      final googleAuth = await googleUser.authentication;

      // Create a new credential using the Google authentication details.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Ambil username dari displayName, jika null pakai email sebelum '@'
        String username =
            user.displayName ??
            (user.email != null
                ? user.email!.split('@')[0]
                : 'user${user.uid.substring(0, 6)}');

        // Simpan ke Firestore jika belum ada
        final userDoc = firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'username': username,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            // tambahkan field lain jika perlu
          });
        } else {
          // Jika sudah ada, update data jika perlu
          await userDoc.update({
            'email': user.email,
            'username': username,
            'photoURL': user.photoURL,
          });
        }
      }
      Provider.of<AuthProvider>(context, listen: false).setUser(user, context);
      return user;
    } catch (e) {
      // debugPrint the error and return null if an exception occurs.
      debugPrint("Sign-in error: $e");
      return null;
    }
  }

  Future<User?> signInWithFacebook() async {
    try {
      // Trigger the Google Sign-In flow.
      final facebookUser = await _facebookSignIn.login();
      if (facebookUser.status == LoginStatus.success) {
        final facebookAuthCredential = FacebookAuthProvider.credential(
          facebookUser.accessToken!.token,
        );
        debugPrint("isi facebook user ${facebookAuthCredential}");
        final userCredential = await _auth.signInWithCredential(
          facebookAuthCredential,
        );
        final user = userCredential.user;

        if (user != null) {
          // Ambil username dari displayName, jika null pakai email sebelum '@'
          String username =
              user.displayName ??
              (user.email != null
                  ? user.email!.split('@')[0]
                  : 'user${user.uid.substring(0, 6)}');

          // Simpan ke Firestore jika belum ada
          final userDoc = firestore.collection('users').doc(user.uid);
          final docSnapshot = await userDoc.get();
          if (!docSnapshot.exists) {
            await userDoc.set({
              'uid': user.uid,
              'email': user.email,
              'username': username,
              'photoURL': user.photoURL,
              'createdAt': FieldValue.serverTimestamp(),
            });
          } else {
            // Jika sudah ada, update data jika perlu
            await userDoc.update({
              'email': user.email,
              'username': username,
              'photoURL': user.photoURL,
            });
          }
        }

        return user;
      } else {
        debugPrint("lihat status ${facebookUser.status}");
      }
      // Sign in to Firebase with the Google credential.
    } catch (e) {
      // debugPrint the error and return null if an exception occurs.
      debugPrint("Sign-in error: $e");
      return null;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _facebookSignIn.logOut();
  }
}
