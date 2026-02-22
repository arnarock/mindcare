import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindcare/features/home/home.dart';
import 'package:mindcare/features/profile/profile_screen.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool isHome;

  const AppLayout({
    super.key,
    required this.child,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(context, isHome: isHome),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ---------------- HEADER ----------------
Widget _header(BuildContext context, {bool isHome = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isHome
              ? null
              : () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomePage(),
                    ),
                    (route) => false,
                  );
                },
          child: Text(
            'MindCare+',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isHome ? Colors.grey : Colors.teal,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.notifications_none),
            const SizedBox(width: 12),

            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),

            const SizedBox(width: 12),

            
          ],
        ),
      ],
    ),
  );
}