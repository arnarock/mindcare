/*
* File: admin_chat_list_page.dart
* Description: Displays a list of all user chats for administrators in the MindCare app. Shows user names, last messages, and unread indicators, allowing admins to quickly access individual chat conversations.
*
* Note:
* - Uses Firestore real-time stream to keep chat list updated automatically.
* - Each chat item fetches user data separately from the 'users' collection.
* - Assumes chat documents contain userId, lastMessage, lastTimestamp, and unreadForAdmin fields.
*
* Lifecycle:
* - build(): Initializes UI and subscribes to Firestore stream via StreamBuilder.
* - Stream updates trigger widget rebuild automatically when chat data changes.
* - FutureBuilder fetches user info per chat item during build phase.
*
* Responsibilities:
* - Display list of all chats ordered by latest activity.
* - Show user name, last message, and unread indicator.
* - Handle loading and empty states gracefully.
* - Navigate to AdminChatPage when a chat is selected.
*
* Authors:
* - Atitaya Khangtan 650510650
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/admin/admin_chat_page.dart';

class AdminChatListPage extends StatelessWidget {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final chatId = chats[index].id;

              final userId = chat['userId'];
              final lastMessage = chat['lastMessage'] ?? "No messages yet";
              final isUnread = chat['unreadForAdmin'] ?? false;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String fullName = "Loading...";

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    final firstName = userData['firstName'] ?? '';
                    final lastName = userData['lastName'] ?? '';
                    fullName = "$firstName $lastName";
                  }
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Colors.teal
                      ),
                    ),

                    title: Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isUnread 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      ),
                    ),

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