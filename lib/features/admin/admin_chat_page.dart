/*
* File: admin_chat_page.dart
* Description: Admin chat interface for the MindCare app, allowing administrators to communicate with users in real-time. Includes message sending, viewing chat history, marking messages as read, and accessing user self-assessment results directly from the chat.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment _result.dart';

class AdminChatPage extends StatefulWidget {
  final String chatId;

  const AdminChatPage({super.key, required this.chatId});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final TextEditingController controller = TextEditingController();
  final admin = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.chatId)
      .set({
        'unreadForAdmin': false,
      }, SetOptions(merge: true));
  }

  void sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final message = controller.text.trim();

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    await chatRef.collection('messages').add({
      'senderId': admin!.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatRef.set({
      'lastMessage': message,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'unreadForAdmin': false, // admin อ่านแล้ว
    }, SetOptions(merge: true));

    controller.clear();
  }

  void _markAsRead() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'unreadForAdmin': false,
    });
  }

  Future<void> _openAssessment(BuildContext context) async {
    final doc = await FirebaseFirestore.instance
        .collection("self_assessment_results")
        .doc(widget.chatId)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PsychiatristSelfAssessmentResultPage(
            userId: widget.chatId,
            isAdminView: true,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User has no assessment result")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.chatId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }

            final userData =
              snapshot.data!.data() as Map<String, dynamic>;

            final firstName = userData['firstName'] ?? '';
            final lastName = userData['lastName'] ?? '';
            final fullName = "$firstName $lastName";

            return Text(
              fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: "Self Assessment",
            onPressed: () {
              _openAssessment(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // chat area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(widget.chatId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index];
                    final isAdmin = data['senderId'] == admin!.uid;
                    return Align(
                      alignment: isAdmin 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.symmetric(vertical: 4),

                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.teal
                              : Colors.grey.shade300,

                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isAdmin
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isAdmin
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),

                        child: Text(
                          data['message'],
                          style: TextStyle(
                            color: isAdmin ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type message here...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}