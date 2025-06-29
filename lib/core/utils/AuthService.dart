import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:newsapp/data/models/bookmark.dart';
import 'package:newsapp/presentation/state/bookmark_providers.dart';
import 'package:newsapp/presentation/state/like_providers.dart';
import 'package:newsapp/presentation/widget/bookmark_toast.dart';
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
        final userDocRef = firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDocRef.get();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final displayName = user.displayName;
        final email = user.email;
        final fallbackUsername = email != null
            ? email.split('@')[0]
            : 'user${user.uid.substring(0, 6)}';

        // Cek apakah username sudah dipakai user lain
        final usernameQuery = await firestore
            .collection('users')
            .where('username', isEqualTo: displayName)
            .get();

        Map<String, dynamic> userData;

        if (!docSnapshot.exists) {
          final isUsernameTaken = usernameQuery.docs.isNotEmpty;

          userData = {
            'uid': user.uid,
            'email': email,
            'username': isUsernameTaken ? fallbackUsername : displayName,
            'photoURL': user.photoURL,
            'fcmToken': fcmToken,
            'createdAt': FieldValue.serverTimestamp(),
          };

          await userDocRef.set(userData);
        } else {
          final existingUsername = docSnapshot['username'];
          final existingPhotoURL = docSnapshot['photoURL'];

          userData = {
            'uid': user.uid,
            'email': email,
            'username': existingUsername,
            'photoURL': existingPhotoURL,
            'fcmToken': fcmToken,
          };

          await userDocRef.set(userData, SetOptions(merge: true));
        }

        // Kirim ke AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUser(user : user,userData: userData, context: context);

      }
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
          final userDocRef = firestore.collection('users').doc(user.uid);
          final docSnapshot = await userDocRef.get();
          final fcmToken = await FirebaseMessaging.instance.getToken();
          final displayName = user.displayName;
          final email = user.email;
          final fallbackUsername = email != null
              ? email.split('@')[0]
              : 'user${user.uid.substring(0, 6)}';

          // Cek apakah username sudah dipakai user lain
          final usernameQuery = await firestore
              .collection('users')
              .where('username', isEqualTo: displayName)
              .get();

          if (!docSnapshot.exists) {
            final isUsernameTakenByOthers = usernameQuery.docs.isNotEmpty;

            final dataToSave = {
              'uid': user.uid,
              'email': email,
              'username': isUsernameTakenByOthers
                  ? fallbackUsername
                  : displayName,
              'photoURL': user.photoURL,
              'fcmToken': fcmToken,
              'createdAt': FieldValue.serverTimestamp(),
            };

            await userDocRef.set(dataToSave);
          } else {
            final existingUsername = docSnapshot['username'];
            final existingPhotoURL = docSnapshot['photoURL'];

            final dataToUpdate = {
              'username': existingUsername,
              'photoURL': existingPhotoURL,
              'fcmToken': fcmToken,
            };

            await userDocRef.set(dataToUpdate, SetOptions(merge: true));
          }
          // Optional: listen for token refresh
        }

        return user;
      } else {
        debugPrint("lihat status ${facebookUser.status}");
      }
      // Sign in to Firebase with the Google credential.
    } catch (e) {
      // debugPrint the error and return null if an exception occurs.
      debugPrint("Sign-in error: $e");
      showCustomToast("Error : ${e}");
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
