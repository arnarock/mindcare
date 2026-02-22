import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> refreshUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {});
  }

  Future<void> resendVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ส่งอีเมลยืนยันอีกครั้งแล้ว 📩"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Email
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("อีเมล"),
              subtitle: Text(user?.email ?? "-"),
            ),

            const SizedBox(height: 20),

            /// Verify Status
            if (user != null && !user.emailVerified)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "อีเมลของคุณยังไม่ได้ยืนยัน",
                      style: TextStyle(color: Colors.orange),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: resendVerification,
                      child: const Text("ส่งอีเมลยืนยันอีกครั้ง"),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "อีเมลของคุณได้รับการยืนยันแล้ว ✅",
                  style: TextStyle(color: Colors.green),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: refreshUser,
              child: const Text("รีเฟรชสถานะ"),
            ),
          ],
        ),
      ),
    );
  }
}
