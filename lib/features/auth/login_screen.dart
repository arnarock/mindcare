/*
* File: login_screen.dart
* Description: Login screen for the MindCare app that allows users to sign in using their email and password. It includes input validation, password visibility toggle, Firebase Authentication handling, loading indicator, error messages, a password reset dialog, and navigation to the registration screen for new users.
*
* Responsibilities:
* - กรอกอีเมลและรหัสผ่านเพื่อเข้าสู่ระบบ
* - ตรวจสอบความถูกต้องของอีเมลและรหัสผ่าน
* - สลับการมองเห็นรหัสผ่าน
* - แสดงปุ่ม Forgot Password และเปิด dialog สำหรับรีเซ็ตรหัสผ่าน
* - ใช้ Firebase Authentication เพื่อเข้าสู่ระบบ
* - แสดง loading indicator ขณะรอสถานะ
* - แสดงข้อความข้อผิดพลาดผ่าน SnackBar
* - ปุ่มนำทางไปหน้า Register สำหรับผู้ใช้ใหม่
*
* Authors: <Anajak Chuamuangphan / zoozoo>
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mindcare/features/auth/register_screen.dart';

/// Login screen that allows users to authenticate using
/// email and password via Firebase Authentication.
///
/// Features:
/// - Form validation for email and password
/// - Password visibility toggle
/// - Forgot password functionality
/// - Loading overlay during authentication
/// - Navigation to registration screen
///
/// Notes:
/// - Displays error messages for authentication failures
/// - Prevents submission when form is invalid
class LoginScreen extends StatefulWidget {

  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// State class for [LoginScreen].
///
/// Manages form state, input controllers,
/// authentication actions, and UI updates.
class _LoginScreenState extends State<LoginScreen> {

  /// Key used to validate the login form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the email input field.
  final emailController = TextEditingController();

  /// Controller for the password input field.
  final passwordController = TextEditingController();

  /// Controls whether the password is obscured.
  bool obscurePassword = true;

  /// Indicates whether a login operation is in progress.
  bool isLoading = false;

  /// Returns true if both email and password fields are filled.
  bool get isFormFilled =>
    emailController.text.trim().isNotEmpty &&
    passwordController.text.isNotEmpty;

  /// Attempts to sign in the user using Firebase Authentication.
  ///
  /// Validates the form before submission.
  /// Displays appropriate error messages for known failures.
  ///
  /// Async behavior:
  /// - Performs network authentication
  ///
  /// Side effects:
  /// - Shows loading indicator
  /// - Displays SnackBar on error
  /// - Navigates automatically upon successful login
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
          message = "Invalid email or password";
          break;
        case 'invalid-email':
          message = "Invalid email format";
          break;
        case 'too-many-requests':
          message = "Too many failed attempts. Please try again later.";
          break;
        default:
          message = "An error occurred. Please try again.";
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

  /// Displays a dialog for password reset via email.
  ///
  /// Allows the user to enter their email address and
  /// sends a password reset link using Firebase Authentication.
  ///
  /// Validates email format before submission.
  ///
  /// Side effects:
  /// - Shows dialog UI
  /// - Sends password reset email
  /// - Displays success or error messages
  void resetPasswordDialog() {
    final resetController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: resetController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Enter Email",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
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
                      content: Text("Invalid email format"),
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
                        Text("Password reset link sent to your email 📩"),
                        backgroundColor: Colors.green,
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  if (!dialogContext.mounted) return;

                  String message =
                    e.code == 'user-not-found'
                      ? "User not found"
                      : "An error occurred";

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

  /// Disposes controllers when the widget is removed
  /// to prevent memory leaks.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// Builds the login interface with form fields,
    /// actions, and loading overlay.
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              /// Login form containing input fields and buttons.
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 115),

                    /// App logo.
                    Image.asset(
                      'assets/images/logo/logo_with_name.png',
                      width: 175,
                      height: 175,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 115),

                    /// EMAIL INPUT FIELD
                    TextFormField(
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: _inputDecoration("Email"),

                      /// Validates email input.
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return "Please enter your email";
                        }

                        final email = value.trim();
                        final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                        if (!emailRegex.hasMatch(email)) {
                          return "Invalid email format";
                        }

                        return null;
                      },

                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD INPUT FIELD
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration:
                          _inputDecoration("Password")
                              .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),

                          /// Toggles password visibility.
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                      ),

                      /// Validates password input.
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },

                      onChanged: (_) => setState(() {}),
                    ),

                    /// Forgot password action.
                    Align(
                      alignment:
                          Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            resetPasswordDialog,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(

                        /// Disabled if form incomplete or loading.
                        onPressed: (!isFormFilled || isLoading)
                          ? null
                          : login,
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
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Navigate to registration screen.
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Loading overlay shown during login.
          if (isLoading)
            Container(
              color:
                  Colors.black.withValues(alpha: 0.4),
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

  /// Returns a standard input decoration used by form fields.
  ///
  /// Applies consistent styling across inputs.
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