import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;
        final displayName = user.displayName?.trim();
        final email = user.email?.trim() ?? '';
        final fallbackName =
            email.contains('@') ? email.split('@').first : 'User';
        final userName = (displayName != null && displayName.isNotEmpty)
            ? displayName
            : fallbackName;

        return HomePage(userName: userName);
      },
    );
  }
}
