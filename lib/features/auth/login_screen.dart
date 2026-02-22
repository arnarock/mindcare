import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  bool get isFormFilled =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty;

  /// 🔐 LOGIN
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = "อีเมลหรือรหัสผ่านไม่ถูกต้อง";
          break;
        case 'invalid-email':
          message = "รูปแบบอีเมลไม่ถูกต้อง";
          break;
        case 'too-many-requests':
          message = "พยายามหลายครั้งเกินไป กรุณาลองใหม่ภายหลัง";
          break;
        default:
          message = "เกิดข้อผิดพลาด กรุณาลองใหม่";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  /// 🔁 RESET PASSWORD
  void resetPasswordDialog() {
    final resetController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("รีเซ็ตรหัสผ่าน"),
          content: TextField(
            controller: resetController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "กรอกอีเมล",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetController.text.trim();

                if (email.isEmpty) return;

                final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                if (!emailRegex.hasMatch(email)) {
                  if (!dialogContext.mounted) return;

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text("รูปแบบอีเมลไม่ถูกต้อง"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content:
                          Text("ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว 📩"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  if (!dialogContext.mounted) return;

                  String message =
                      e.code == 'user-not-found'
                          ? "ไม่พบบัญชีผู้ใช้นี้"
                          : "เกิดข้อผิดพลาด";

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("ส่ง"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.favorite,
                        size: 80, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      "WellCare",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),

                    /// EMAIL
                    TextFormField(
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: _inputDecoration("อีเมล"),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return "กรุณากรอกอีเมล";
                        }

                        final email = value.trim();
                        final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                        if (!emailRegex.hasMatch(email)) {
                          return "รูปแบบอีเมลไม่ถูกต้อง";
                        }

                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    /// PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration:
                          _inputDecoration("รหัสผ่าน")
                              .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return "กรุณากรอกรหัสผ่าน";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    Align(
                      alignment:
                          Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            resetPasswordDialog,
                        child:
                            const Text("ลืมรหัสผ่าน?"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            (!isFormFilled ||
                                    isLoading)
                                ? null
                                : login,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                          ),
                        ),
                        child: const Text(
                          "เข้าสู่ระบบ",
                          style:
                              TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                          "สมัครสมาชิก"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color:
                  Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child:
                    CircularProgressIndicator(
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    );
  }
}
