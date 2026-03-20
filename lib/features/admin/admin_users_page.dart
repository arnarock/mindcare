/*
* File: admin_users_page.dart
* Description: Admin interface for managing users in the MindCare app. Allows viewing all registered users, searching by name or email, and updating user roles to grant or revoke admin privileges in real time.
*
* Note:
* - Uses Firestore real-time stream to display user data.
* - Assumes each user document contains firstName, lastName, email, phone, and role fields.
* - Role values are expected to be either "user" or "admin".
*
* Lifecycle:
* - build(): Initializes UI and subscribes to user data via StreamBuilder.
* - Stream updates trigger UI rebuild when user data changes.
* - setState(): Updates search text and filters displayed users in real-time.
* - makeAdmin()/removeAdmin(): Updates user role in Firestore.
*
* Responsibilities:
* - Display a list of all registered users.
* - Provide search functionality by name or email.
* - Show user details including name, email, phone, and role.
* - Allow admin role assignment and removal.
*
* Authors:
* - Atitaya Khangtan 650510650
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String searchText = "";

  Future<void> makeAdmin(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"role": "admin"});
  }

  Future<void> removeAdmin(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"role": "user"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Manage Users",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search user...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          // user list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  final data =
                    doc.data() as Map<String, dynamic>;

                  final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? '-'}";
                  final email = (data['email'] ?? "-");

                  return name.contains(searchText) || email.contains(searchText);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final data = users[index].data() as Map<String, dynamic>;
                    final uid = users[index].id;
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),

                        title: Text(
                          "${data['firstName']} ${data['lastName']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        subtitle: Text(
                          "Email : ${data['email']}\n"
                          "Phone : ${data['phone']}\n"
                          "Role : ${data['role'] ?? 'user'}",
                        ),

                        trailing:
                          PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "admin") {
                              makeAdmin(uid);
                            }

                            if (value == "removeAdmin") {
                              removeAdmin(uid);
                            }
                          },

                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "admin",
                              child: Text("Make Admin"),
                            ),

                            PopupMenuItem(
                              value: "removeAdmin",
                              child: Text("Remove Admin"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}