import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_uee/auth/auth.dart';
import 'package:flutter_application_uee/auth/login_or_register.dart';
import 'package:flutter_application_uee/firebase_options.dart'; 
import 'package:flutter_application_uee/pages/start_page.dart';
import 'package:flutter_application_uee/pages/user_login_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  // Initialize the FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Configure Android notification settings 
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background'); 
  final InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:StartPage()
    );
  }
}