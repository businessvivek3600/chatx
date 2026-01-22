import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  ///SIGNUP USER ---
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please enter all fields";
      }

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.updateDisplayName(name);

      await _firestore.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "name": name,
        "email": email,
        "photoURL": null,
        "isOnline": true,
        "provider": "email",
        "lastSeen": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("✅ SIGN UP SUCCESS: ${cred.user!.email}");
      return "success";
    }

    // 🔥 Firebase Auth Errors
    on FirebaseAuthException catch (e) {
      print("❌ SIGN UP ERROR");
      print("Code: ${e.code}");
      print("Message: ${e.message}");

      switch (e.code) {
        case 'email-already-in-use':
          return "Email is already registered";
        case 'invalid-email':
          return "Invalid email address";
        case 'weak-password':
          return "Password is too weak";
        case 'operation-not-allowed':
          return "Email/password accounts are not enabled";
        default:
          return "Something went wrong. Try again";
      }
    }

    // 🔥 Other Errors
    catch (e) {
      print("❌ UNKNOWN SIGN UP ERROR: $e");
      return "Unexpected error occurred";
    }
  }

  /// Login with online status update
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Please enter all fields";
      }

      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(cred.user!.uid).update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      print("✅ LOGIN SUCCESS: ${cred.user!.email}");
      return "success";
    }

    // 🔥 Firebase Auth Errors
    on FirebaseAuthException catch (e) {
      print("❌ LOGIN ERROR");
      print("Code: ${e.code}");
      print("Message: ${e.message}");

      switch (e.code) {
        case 'user-not-found':
          return "No user found with this email";
        case 'wrong-password':
          return "Incorrect password";
        case 'invalid-email':
          return "Invalid email address";
        case 'user-disabled':
          return "This account has been disabled";
        case 'too-many-requests':
          return "Too many attempts. Try again later";
        default:
          return "Login failed. Try again";
      }
    }

    catch (e) {
      print("❌ UNKNOWN LOGIN ERROR: $e");
      return "Unexpected error occurred";
    }
  }

  /// GOOGLE SIGN IN ---
  Future<String> signInWithGoogle() async {
    try {
      // In version 7.x, initialize must be called before authenticate
      await _googleSignIn.initialize();
      
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Access token is now obtained via authorizationClient in 7.x
      final GoogleSignInClientAuthorization authz = await googleUser.authorizationClient.authorizeScopes([]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);

      // Create user document if it doesn't exist
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(cred.user!.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection("users").doc(cred.user!.uid).set({
          "uid": cred.user!.uid,
          "name": cred.user!.displayName,
          "email": cred.user!.email,
          "photoURL": cred.user!.photoURL,
          "isOnline": true,
          "provider": "google",
          "lastSeen": FieldValue.serverTimestamp(),
          "createdAt": FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection("users").doc(cred.user!.uid).update({
          "isOnline": true,
          "lastSeen": FieldValue.serverTimestamp(),
        });
      }

      print("✅ GOOGLE LOGIN SUCCESS: ${cred.user!.email}");
      return "success";
    } catch (e) {
      print("❌ GOOGLE SIGN IN ERROR: $e");
      return "Google Sign-In failed";
    }
  }

  //Logout with online status update
  Future<void> signOut() async {
    if (_auth.currentUser != null) {
      // Set offline before signing out
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

final authMethodProvider = Provider<AuthMethod>((ref) {
  return AuthMethod();
});
