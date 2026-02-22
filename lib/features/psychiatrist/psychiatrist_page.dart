import 'package:flutter/material.dart';
import 'package:mindcare/core/layout/app_layout.dart';

class PsychiatristPage extends StatelessWidget {
  const PsychiatristPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),
            const Text(
              "Psychiatrist",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// Welcome Text
            const Text(
              "Welcome, User",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Take care of yourself with\nPsychological Counselling",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// My Inbox Card
            _optionCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: "My Inbox",
              subtitle: "Chat with Psychiatrist",
              onTap: () {
                // TODO: เปิดหน้า Chat จริงในอนาคต
              },
            ),

            const SizedBox(height: 20),

            /// Self Assessment Card
            _optionCard(
              context,
              icon: Icons.edit_note_outlined,
              title: "Self Assessments",
              subtitle: "Mental health evaluation",
              onTap: () {
                // TODO: เปิดหน้าแบบประเมิน
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ------------------------------
  /// Option Card Widget
  /// ------------------------------
  Widget _optionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F9FF),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.teal, size: 26),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}