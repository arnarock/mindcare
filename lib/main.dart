/*
* File: main.dart
* Description: Application entry point. Initializes Firebase and notification services, configures app theme, and launches the MindCare app with authentication gate.
*
* Responsibilities:
* - Initialize Firebase
* - Initialize Notification service
* - รันแอปพร้อม AuthGate เพื่อตรวจสอบสถานะผู้ใช้
*
* Authors: 
* - Anajak Chuamuangphan 650510692
* Course: Mobile App Development
*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:mindcare/features/auth/auth_gate.dart';
import 'package:mindcare/core/services/notification_service.dart';

/// Entry point of the application
Future<void> main() async {

  /// Ensures Flutter engine is initialized before using async services
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Initialize local notification service
  await NotificationService.init();

  /// Launch the root widget of the app
  runApp(const MyApp());
}

/// Root widget of the MindCare application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    /// MaterialApp configures the overall app design and navigation
    return MaterialApp(

      /// Hide debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      /// App title used by the system
      title: 'MindCare',

      /// Global theme configuration
      theme: ThemeData(

        /// Generate color scheme based on seed color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),

        /// Enable Material Design 3
        useMaterial3: true,
      ),

      /// First screen shown when app starts
      /// AuthGate decides whether user goes to login or home
      home: const AuthGate(),
    );
  }
}