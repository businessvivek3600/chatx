import 'package:chatx/view/auth/login_screen.dart';
import 'package:chatx/view/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the connection is active, check the auth state
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          
          if (user == null) {
            // User is not logged in, show Login Screen
            return const UserLoginScreen();
          } else {
            // User is logged in, show Home Screen
            return const HomeScreen();
          }
        }

        // Showing a loading indicator while waiting for the connection
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
