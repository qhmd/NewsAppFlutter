import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service class to handle Google Sign-In
// and authentication using Firebase.
class AuthService {
  // FirebaseAuth instance to handle authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn instance to handle Google Sign-In.
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookSignIn = FacebookAuth.instance;

  /// Signs in the user with Google and returns the authenticated Firebase [User].
  ///
  /// Returns `null` if the sign-in process is canceled or fails.
  Future<User?> signInWithGoogle() async {
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

      // Sign in to Firebase with the Google credential.
      final userCredential = await _auth.signInWithCredential(credential);

      // Return the authenticated user.
      return userCredential.user;
    } catch (e) {
      // Print the error and return null if an exception occurs.
      print("Sign-in error: $e");
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
        print("isi facebook user ${facebookAuthCredential}");
        final userCredential = await _auth.signInWithCredential(
          facebookAuthCredential,
        );

        return userCredential.user;
      } else {
        print("lihat status ${facebookUser.status}");
      }
      // Sign in to Firebase with the Google credential.
    } catch (e) {
      // Print the error and return null if an exception occurs.
      print("Sign-in error: $e");
      return null;
    }
    return null;
  }


  Future<void> signOutFacebook() async {
    // Sign out from Google.
    await _facebookSignIn.logOut();

    // Sign out from Firebase.
    await _auth.signOut();
  }

  Future<void> signOutGoogle() async {
    // Sign out from Google.
    await _googleSignIn.signOut();

    // Sign out from Firebase.
    await _auth.signOut();
  }
  /// Signs out the user from both Google and Firebase.
}
