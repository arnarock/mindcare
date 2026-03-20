/*
* File: admin_chat_list_page.dart
* Description: Displays a list of all user chats for administrators in the MindCare app. Shows user names, last messages, and unread indicators, allowing admins to quickly access individual chat conversations.
*
* Authors:
* - Atitaya Khangtan 650510650
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/admin/admin_chat_page.dart';

/// Displays a list of user chat sessions for admin support.
///
/// This page listens to Firestore in real time and shows chat
/// conversations ordered by latest activity.
///
/// Responsibilities:
/// - Display a list of chats ordered by latest activity
/// - Show user name, last message, and unread indicator
/// - Handle loading and empty states
/// - Navigate to [AdminChatPage] when a chat is selected
///
/// Notes:
/// - Uses Firestore real-time stream via StreamBuilder
/// - Each chat item fetches user data from the 'users' collection
/// - Assumes chat documents contain:
///   userId, lastMessage, lastTimestamp, unreadForAdmin
class AdminChatListPage extends StatelessWidget {

  /// Creates an [AdminChatListPage].
  const AdminChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chat Support',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),

      /// StreamBuilder listens to the 'chats' collection
      /// and rebuilds the UI whenever data changes.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          /// Shows a loading indicator while waiting for data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Displays a message when no chats exist.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          final chats = snapshot.data!.docs;

          /// Builds a scrollable list of chat items.
          return ListView.builder(
            itemCount: chats.length,

            itemBuilder: (context, index) {

              /// Extracts chat data for the current item.
              final chat = chats[index].data() as Map<String, dynamic>;
              final chatId = chats[index].id;

              final userId = chat['userId'];
              final lastMessage = chat['lastMessage'] ?? "No messages yet";
              final isUnread = chat['unreadForAdmin'] ?? false;

              /// FutureBuilder retrieves the user's profile
              /// to display their full name.
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),

                builder: (context, userSnapshot) {

                  String fullName = "Loading...";

                  /// If user data is available, construct full name.
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    final firstName = userData['firstName'] ?? '';
                    final lastName = userData['lastName'] ?? '';
                    fullName = "$firstName $lastName";
                  }

                  /// Displays a chat list tile with user info.
                  return ListTile(

                    /// Avatar icon representing the user.
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Colors.teal
                      ),
                    ),

                    /// Shows the user's full name.
                    title: Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isUnread 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      ),
                    ),

                    /// Displays the last message preview.
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isUnread 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      ),
                    ),

                    /// Shows an unread indicator dot if needed.
                    trailing: isUnread
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,

                    /// Navigates to the detailed chat page
                    /// when the item is tapped.
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminChatPage(chatId: chatId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}