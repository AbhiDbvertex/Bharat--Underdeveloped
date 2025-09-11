import 'package:developer/Widgets/AppColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotificationService.dart';
import 'directHiring/views/auth/RoleSelectionScreen.dart';
import 'directHiring/views/auth/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  Get.put(GetXRoleController());

  // Fetch SharedPreferences data
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getString('token') != null;
  final bool isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
  final String? role = prefs.getString('role');

  print("🔍 Main.dart - Token: ${prefs.getString('token')}, ProfileComplete: $isProfileComplete, Role: $role");

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    isProfileComplete: isProfileComplete,
    role: role,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isProfileComplete;
  final String? role;

  const MyApp({
    Key? key,
    required this.isLoggedIn,
    required this.isProfileComplete,
    this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
    ),),
    debugShowCheckedModeBanner: false,
      title: 'The Bharat Works',
      home: SplashScreen(),
      // home: DragToPayScreen(),
      // YourWidget(buddingOderId: '68ae9954d57712243b24df60',),
    );
  }
}