import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  Future<void> makeAdmin(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"role": "admin"});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {

            final data = users[index].data();
            final uid = users[index].id;

            return Card(
              child: ListTile(
                title: Text("${data['firstName']} ${data['lastName']}"),
                subtitle: Text(data['email']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == "admin") {
                      makeAdmin(uid);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "admin",
                      child: Text("Make Admin"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}