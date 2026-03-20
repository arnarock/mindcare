/*
* File: register_screen.dart
* Description: User registration screen for the MindCare app that allows new users to create an account with first name, last name, phone number, email, and password. It includes input validation, password visibility toggle, phone number formatting, Firebase Authentication for account creation, email verification, and storing user data in Firestore.
*
* Authors: 
* - Anajak Chuamuangphan 650510692
* - Atitaya Khangtan 650510650
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Formats phone number input into XXX-XXX-XXXX pattern.
///
/// This formatter:
/// - Removes non-digit characters
/// - Limits input to 10 digits
/// - Automatically inserts hyphens
///
/// Example:
/// 0812345678 → 081-234-5678
class PhoneNumberFormatter extends TextInputFormatter {

  /// Applies formatting whenever the text field value changes.
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {

    /// Extract digits only.
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    /// Limit to 10 digits.
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    String formatted = '';

    /// Apply formatting based on length.
    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 6) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      formatted =
          '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    /// Return formatted value with cursor at end.
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Registration screen for creating a new user account.
///
/// Responsibilities:
/// - Collect user input (first name, last name, phone, email, password)
/// - Validate user input and enforce formatting rules
/// - Handle password visibility toggle
/// - Format phone number input
/// - Create user account via Firebase Authentication
/// - Send email verification
/// - Store user profile data in Firestore
/// - Provide user feedback via SnackBar
///
/// Notes:
/// - Uses Firebase Authentication and Firestore
/// - Newly registered users are assigned the "user" role
class RegisterScreen extends StatefulWidget {

  /// Creates a [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// State class for [RegisterScreen].
///
/// Manages form inputs, validation,
/// authentication, and UI state.
class _RegisterScreenState extends State<RegisterScreen> {

  /// Key used to validate the registration form.
  final _formKey = GlobalKey<FormState>();

  /// Controllers for user input fields.
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  /// Controls password visibility.
  bool obscurePassword = true;

  /// Indicates whether registration is in progress.
  bool isLoading = false;

  /// Returns true if all required fields are filled.
  bool get isFormFilled =>
      firstNameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty &&
      phoneController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmController.text.isNotEmpty;

  /// Creates a new user account using Firebase Authentication.
  ///
  /// Steps:
  /// 1. Validate form inputs
  /// 2. Create authentication account
  /// 3. Send email verification
  /// 4. Store user profile data in Firestore
  /// 5. Show success message
  ///
  /// Async behavior:
  /// - Performs network requests
  ///
  /// Side effects:
  /// - Shows loading overlay
  /// - Displays SnackBar messages
  /// - Navigates back to login screen on success
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      /// Send verification email.
      await userCredential.user!.sendEmailVerification();

      /// Save user profile data to Firestore.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.replaceAll('-', ''),
        'email': emailController.text.trim(),
        'role': "user",
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      /// Show success message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Registration successful 🎉 Please check your email to verify your account"),
            backgroundColor: Colors.green,
        ),
      );

      /// Return to login screen.
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      String message;

      if (e.code == 'email-already-in-use') {
        message = "Email is already in use";
      } else if (e.code == 'weak-password') {
        message = "Password must be at least 6 characters";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      } else {
        message = "An error occurred. Please try again.";
      }

      if (!mounted) return;

      /// Show error message.
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

    /// Builds the registration form UI.
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              /// Form containing all input fields.
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    /// App logo.
                    Image.asset(
                      'assets/images/logo/logo_with_name.png',
                      width: 100,
                      height: 100,
                    ),

                    const SizedBox(height: 45),

                    /// First Name input
                    TextFormField(
                      controller: firstNameController,
                      decoration: _inputDecoration("First Name"),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your first name";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    /// Last Name input
                    TextFormField(
                      controller: lastNameController,
                      decoration: _inputDecoration("Last Name"),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your last name";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    /// Phone Number input with formatter
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Phone Number"),
                      inputFormatters: [
                        PhoneNumberFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your phone number";
                        }
                        final digits = value.replaceAll('-', '');
                        if (digits.length != 10) {
                          return "Phone number must have 10 digits";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    /// Email input
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
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

                    const SizedBox(height: 12),

                    /// Password input
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: _inputDecoration("Password").copyWith(
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
                          return "Please enter your password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    /// Confirm Password input
                    TextFormField(
                      controller: confirmController,
                      obscureText: obscurePassword,
                      decoration: _inputDecoration("ยืนยันรหัสผ่าน"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm your password";
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 24),

                    /// Register button
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
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Back to login action
                    TextButton(
                      onPressed: () {
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text("Back to Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Loading overlay
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

  /// Returns a reusable input decoration for form fields.
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}