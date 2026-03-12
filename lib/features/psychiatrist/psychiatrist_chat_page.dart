import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment.dart';
import 'package:mindcare/features/psychiatrist/psychiatrist_self_assessment _result.dart';

class PsychiatristChatPage extends StatefulWidget {
  const PsychiatristChatPage({super.key});

  @override
  State<PsychiatristChatPage> createState() => _PsychiatristChatPageState();
}

class _PsychiatristChatPageState extends State<PsychiatristChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Psychiatrist Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
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
          // Chat Area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(user!.uid)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index];
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

          // Input Area
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

  Future<void> _openAssessment(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("self_assessment_results")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PsychiatristSelfAssessmentResultPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PsychiatristSelfAssessmentPage(),
        ),
      );
    }
  }

  // Send Message
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatRef =
      FirebaseFirestore.instance.collection('chats').doc(user!.uid);

    await chatRef.collection('messages').add({
      'senderId': user!.uid,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      'userId': user!.uid,
      'lastMessage': _messageController.text.trim(),
      'lastTimestamp': FieldValue.serverTimestamp(),
      'unreadForAdmin': true,
    });

    _messageController.clear();
  }

  // Chat Bubble 
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