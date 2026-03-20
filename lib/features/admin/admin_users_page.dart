/*
* File: admin_users_page.dart
* Description: Admin interface for managing users in the MindCare app. Allows viewing all registered users, searching by name or email, and updating user roles to grant or revoke admin privileges in real time.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Displays a management interface for administrators to
/// view and control user accounts.
///
/// This page shows a searchable list of users retrieved
/// from Firestore in real time. Admins can promote users
/// to admin role or revoke admin privileges.
///
/// Features:
/// - Real-time user list via StreamBuilder
/// - Search by name or email
/// - Promote user to admin
/// - Remove admin role
///
/// Notes:
/// - Intended for admin-role users only
/// - Updates are written directly to Firestore
class AdminUsersPage extends StatefulWidget {

  /// Creates an [AdminUsersPage].
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

/// State class for [AdminUsersPage].
///
/// Manages search input, Firestore interactions,
/// and UI updates.
class _AdminUsersPageState extends State<AdminUsersPage> {

  /// Stores the current search query entered by the admin.
  ///
  /// Used to filter users by name or email.
  String searchText = "";

  /// Promotes a user to admin role.
  ///
  /// Updates the user's document in Firestore by setting
  /// the role field to "admin".
  Future<void> makeAdmin(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"role": "admin"});
  }

  /// Removes admin privileges from a user.
  ///
  /// Updates the user's role back to "user".
  Future<void> removeAdmin(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"role": "user"});
  }

  @override
  Widget build(BuildContext context) {

    /// Builds the main user management interface.
    return Scaffold(
      backgroundColor: Colors.white,

      /// App bar with page title.
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

          /// Search field for filtering users by name or email.
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

              /// Updates search text and refreshes the UI.
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          /// Expanded section displaying the user list.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              /// Listens to all users in Firestore in real time.
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),

              builder: (context, snapshot) {

                /// Shows loading indicator while data is fetched.
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// Filters users based on search query.
                final users = snapshot.data!.docs.where((doc) {
                  final data =
                    doc.data() as Map<String, dynamic>;

                  final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? '-'}";
                  final email = (data['email'] ?? "-");

                  return name.contains(searchText) || email.contains(searchText);
                }).toList();

                /// Builds a scrollable list of user cards.
                return ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: users.length,

                  itemBuilder: (context, index) {

                    final data = users[index].data() as Map<String, dynamic>;
                    final uid = users[index].id;

                    return Card(
                      elevation: 2,

                      /// Displays user information and actions.
                      child: ListTile(
                        contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),

                        /// User full name.
                        title: Text(
                          "${data['firstName']} ${data['lastName']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        /// Additional user details.
                        subtitle: Text(
                          "Email : ${data['email']}\n"
                          "Phone : ${data['phone']}\n"
                          "Role : ${data['role'] ?? 'user'}",
                        ),

                        /// Action menu for role management.
                        trailing:
                          PopupMenuButton<String>(

                          /// Handles selected menu action.
                          onSelected: (value) {
                            if (value == "admin") {
                              makeAdmin(uid);
                            }

                            if (value == "removeAdmin") {
                              removeAdmin(uid);
                            }
                          },

                          /// Menu options for admin actions.
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