import 'dart:async';

import 'package:developer/Widgets/AppColors.dart';
import 'package:developer/testingfile.dart';
import 'package:developer/utility/network_dialog_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Emergency/utils/logger.dart';
import 'NotificationService.dart';
import 'chat/chatScreen.dart';
import 'chat/chat_user_list_screen.dart';
import 'directHiring/views/auth/RoleSelectionScreen.dart';
import 'directHiring/views/auth/SplashScreen.dart';


final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> bwGlobalContext = GlobalKey<NavigatorState>();
bool isBwGlobalContextMounted() {
  return bwGlobalContext.currentContext != null && bwGlobalContext.currentContext!.mounted;
}

BuildContext? getBwGlobalContext() {
  final context = bwGlobalContext.currentContext;
  if (context != null && context.mounted) {
    return context;
  }
  return null;
}
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

class MyApp extends StatefulWidget {
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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  late final StreamSubscription<InternetStatus> listener;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay listener until the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bwDebug('Starting network listener after first frame', tag: "InternetCheck");
      AutomaticNoConnectionDialog.startListening();
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: bwGlobalContext,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ThemeData(
          useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
    ),),
    debugShowCheckedModeBanner: false,
      title: 'The Bharat Works',
      home: SplashScreen(),
      // home: ChatScreen(),
      // home: DragToPayScreen(),
      // YourWidget(buddingOderId: '68ae9954d57712243b24df60',),
    );
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
   switch (state) {
      case AppLifecycleState.resumed:

        if (getBwGlobalContext() != null) {
          AutomaticNoConnectionDialog.startListening();
        } else {
          bwDebug('Context not available on resume, delaying listener', tag: "InternetCheck");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AutomaticNoConnectionDialog.startListening();
          });
        }
             break;

      case AppLifecycleState.detached:
              AutomaticNoConnectionDialog.dispose(); // Dispose of connection dialog resources
        break;
      case AppLifecycleState.paused:
            AutomaticNoConnectionDialog.dispose(); // Dispose of connection dialog resources

        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  void dispose() {
    bwDebug('dispose callllllllllllll', tag: " gadgeeeeeeeee");
    WidgetsBinding.instance.removeObserver(this);
    AutomaticNoConnectionDialog.dispose();
    super.dispose();
  }
}