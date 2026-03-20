/*
* File: psychiatrist_chat_page.dart
* Description: Chat interface for users to communicate with a psychiatrist, including sending and receiving messages and quick access to mental health self-assessments.
*
* Authors:
* -  
* - 
* - 
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment _result.dart';

/// Chat page that allows users to communicate with a psychiatrist
/// - Displays real-time chat messages from Firestore
/// - Allows sending new messages
/// - Provides access to self-assessment questionnaire
class PsychiatristChatPage extends StatefulWidget {
  const PsychiatristChatPage({super.key});

  @override
  State<PsychiatristChatPage> createState() => _PsychiatristChatPageState();
}

class _PsychiatristChatPageState extends State<PsychiatristChatPage> {

  /// Controller for the message input field
  final TextEditingController _messageController = TextEditingController();

  /// Currently logged-in Firebase user
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// App bar with title and self-assessment button
      appBar: AppBar(
        title: const Text(
          'Psychiatrist Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,

        /// Action button to open self-assessment
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

          // ================= CHAT AREA =================

          /// Displays chat messages in real time using StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(user!.uid)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                /// Show loading indicator while waiting for messages
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                /// Build list of chat bubbles
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index];

                    /// Check if message was sent by current user
                    final isMe = data['senderId'] == user!.uid;

                    return _chatBubble(
                      message: data['message'],
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // ================= INPUT AREA =================

          /// Message input field and send button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [

                /// Text input for typing messages
                Expanded(
                  child: TextField(
                    controller: _messageController,
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

                /// Send button
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(
                      Icons.send, 
                      color: Colors.white
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the self-assessment page or result page
  /// depending on whether the user already has results saved
  Future<void> _openAssessment(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("self_assessment_results")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    /// If assessment result exists → open result page
    if (doc.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PsychiatristSelfAssessmentResultPage(),
        ),
      );

    /// Otherwise → open assessment questionnaire page
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PsychiatristSelfAssessmentPage(),
        ),
      );
    }
  }

  /// Sends a new chat message to Firestore
  void _sendMessage() async {

    /// Prevent sending empty messages
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(user!.uid);

    // -------- Add message document --------
    await chatRef.collection('messages').add({
      'senderId': user!.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // -------- Update chat metadata --------
    await chatRef.set({
      'userId': user!.uid,
      'lastMessage': message,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'unreadForAdmin': true,
    }, SetOptions(merge: true));

    /// Clear input field after sending
    _messageController.clear();
  }

  /// Builds a chat bubble UI
  /// - Aligns right if sent by current user
  /// - Aligns left if received message
  Widget _chatBubble({required String message, required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe 
              ? const Radius.circular(16) 
              : const Radius.circular(0),
            bottomRight: isMe 
              ? const Radius.circular(0) 
              : const Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe 
              ? Colors.white 
              : Colors.black87,
          ),
        ),
      ),
    );
  }
}