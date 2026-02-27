import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelfAssessmentPage extends StatefulWidget {
  const SelfAssessmentPage({super.key});

  @override
  State<SelfAssessmentPage> createState() => _SelfAssessmentPageState();
}

class _SelfAssessmentPageState extends State<SelfAssessmentPage> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'male';
  int _score = 1;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Self Assessment"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Info text
            const Text(
              "แบบประเมินสุขภาพจิตนี้จะถูกบันทึกไว้ในระบบ "
              "เพื่อใช้ในการติดตามสุขภาพจิตของคุณในอนาคต",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "ชื่อ",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Birth date
            Row(
              children: [
                Expanded(
                  child: Text(
                    _birthDate == null
                        ? "วันเกิด: ยังไม่ได้เลือก"
                        : "วันเกิด: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text("เลือกวันเกิด"),
                )
              ],
            ),

            const SizedBox(height: 16),

            // Gender
            const Text("เพศ"),
            Row(
              children: [
                Radio<String>(
                  value: 'male',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() => _gender = value!);
                  },
                ),
                const Text("ชาย"),
                Radio<String>(
                  value: 'female',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() => _gender = value!);
                  },
                ),
                const Text("หญิง"),
                Radio<String>(
                  value: 'other',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() => _gender = value!);
                  },
                ),
                const Text("อื่น ๆ"),
              ],
            ),

            const SizedBox(height: 20),

            // Score
            const Text("ระดับความรู้สึกโดยรวม (1 = แย่มาก, 4 = ดีมาก)"),
            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              value: _score,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text("1")),
                DropdownMenuItem(value: 2, child: Text("2")),
                DropdownMenuItem(value: 3, child: Text("3")),
                DropdownMenuItem(value: 4, child: Text("4")),
              ],
              onChanged: (value) {
                setState(() => _score = value!);
              },
            ),

            const SizedBox(height: 30),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAssessment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("บันทึกแบบประเมิน"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() => _birthDate = selected);
    }
  }

  Future<void> _submitAssessment() async {
    if (_nameController.text.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบ")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('assessments').add({
      'userId': user!.uid,
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'gender': _gender,
      'score': _score,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("บันทึกแบบประเมินเรียบร้อย")),
    );

    Navigator.pop(context);
  }
}