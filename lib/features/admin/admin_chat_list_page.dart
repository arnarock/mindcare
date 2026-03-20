/*
* File: admin_chat_list_page.dart
* Description: Displays a list of all user chats for administrators in the MindCare app. Shows user names, last messages, and unread indicators, allowing admins to quickly access individual chat conversations.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/admin/admin_chat_page.dart';

/// Displays a list of user chat sessions for admin support.
///
/// This page retrieves chat documents from Firestore in real time
/// and shows them in a scrollable list ordered by the latest activity.
///
/// Each list item displays:
/// - The user's full name
/// - The most recent message
/// - An unread indicator (if applicable)
///
/// Tapping a chat opens the corresponding [AdminChatPage]
/// for conversation management.
///
/// Notes:
/// - Uses StreamBuilder for real-time updates
/// - Fetches user profile data separately via FutureBuilder
/// - Designed for admin-only access
class AdminChatListPage extends StatelessWidget {

  /// Creates an [AdminChatListPage].
  const AdminChatListPage({super.key});

  @override
  Widget build(BuildContext context) {

    /// Builds the main UI containing an AppBar and
    /// a real-time list of chat conversations.
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