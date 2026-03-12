import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<int> getUserCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserCount(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userCount = snapshot.data;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              _statCard(
                "Total Users",
                userCount.toString(),
                Icons.people,
              ),

              const SizedBox(height: 16),

              _statCard(
                "Assessments",
                "View Results",
                Icons.analytics,
              ),

              const SizedBox(height: 16),

              _statCard(
                "Chat Requests",
                "Open Chat",
                Icons.chat,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.teal),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}