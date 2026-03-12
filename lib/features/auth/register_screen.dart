import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '';

    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 6) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      formatted =
          '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  bool get isFormFilled =>
      firstNameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty &&
      phoneController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmController.text.isNotEmpty;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await userCredential.user!.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.replaceAll('-', ''),
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "สมัครสมาชิกสำเร็จ 🎉 กรุณาตรวจสอบอีเมลเพื่อยืนยันบัญชี"),
            backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'email-already-in-use') {
        message = "อีเมลนี้ถูกใช้แล้ว";
      } else if (e.code == 'weak-password') {
        message = "รหัสผ่านต้องมีอย่างน้อย 6 ตัว";
      } else if (e.code == 'invalid-email') {
        message = "รูปแบบอีเมลไม่ถูกต้อง";
      } else {
        message = "เกิดข้อผิดพลาด กรุณาลองใหม่";
      }

      if (!mounted) return;

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
                    Image.asset(
                      'assets/images/logo/logo_with_name.png',
                      width: 100,
                      height: 100,
                    ),

                    const SizedBox(height: 45),

                    /// First Name
                    TextFormField(
                      controller: firstNameController,
                      decoration: _inputDecoration("ชื่อ"),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "กรุณากรอกชื่อ";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    /// Last Name
                    TextFormField(
                      controller: lastNameController,
                      decoration: _inputDecoration("นามสกุล"),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "กรุณากรอกนามสกุล";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    /// Phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("เบอร์โทร"),
                      inputFormatters: [
                        PhoneNumberFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "กรุณากรอกเบอร์โทร";
                        }
                        final digits = value.replaceAll('-', '');
                        if (digits.length != 10) {
                          return "เบอร์โทรต้องมี 10 หลัก";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    /// Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("อีเมล"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
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
                    const SizedBox(height: 12),

                    /// Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: _inputDecoration("รหัสผ่าน").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณากรอกรหัสผ่าน";
                        }
                        if (value.length < 6) {
                          return "รหัสผ่านต้องมีอย่างน้อย 6 ตัว";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),

                    /// Confirm Password
                    TextFormField(
                      controller: confirmController,
                      obscureText: obscurePassword,
                      decoration: _inputDecoration("ยืนยันรหัสผ่าน"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณายืนยันรหัสผ่าน";
                        }
                        if (value != passwordController.text) {
                          return "รหัสผ่านไม่ตรงกัน";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (!isFormFilled || isLoading) 
                          ? null 
                          : register,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color.fromARGB(255, 233, 233, 233); // ปุ่มยังใช้ไม่ได้
                            }
                            return Colors.teal; // ปุ่มพร้อมกด
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.black26; // สีตัวอักษรตอนปุ่มเทา
                            }
                            return Colors.white; // สีตัวอักษรตอนปุ่มเขียว
                          }),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        child: const Text(
                          "สมัครสมาชิก",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text("กลับไปยังหน้าเข้าสู่ระบบ"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
