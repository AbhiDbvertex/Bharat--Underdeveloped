import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/Bottombar.dart';
import '../../../Widgets/CustomLogoWidget.dart';
import '../../../utility/network_dialog_manager.dart';
import 'LoginScreen.dart';
import 'OnboardingScreen.dart';
import 'RoleSelectionScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    // Navigate after 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      await _navigateToNextScreen();
    });
    //AutomaticNoConnectionDialog.startListening();
  }

  /// ✅ Core navigation logic after splash screen
  // Future<void> _navigateToNextScreen() async {
  //   _controller.stop();
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   final bool seenOnboarding = prefs.getBool('onboardingComplete') ?? false;
  //   final String? token = prefs.getString('token');
  //   final bool isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
  //   final String role = prefs.getString('role') ?? '';
  //
  //   Widget initialScreen;
  //
  //   if (!seenOnboarding) {
  //     initialScreen = const OnboardingScreen();
  //   } else if (token != null && isProfileComplete) {
  //     // Already logged in and profile complete
  //     if (role == 'user' || role == 'service_provider') {
  //       initialScreen = const Bottombar();
  //     } else if (role == 'both') {
  //       initialScreen = const RoleSelectionScreen();
  //     } else {
  //       initialScreen = const RoleSelectionScreen(); // fallback
  //     }
  //   } else {
  //     initialScreen =
  //         const LoginScreen(); // not logged in or profile incomplete
  //   }
  //
  //   if (mounted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => initialScreen),
  //     );
  //   }
  // }

  Future<void> _navigateToNextScreen() async {
    _controller.stop();
    final prefs = await SharedPreferences.getInstance();

    final bool seenOnboarding = prefs.getBool('onboardingComplete') ?? false;
    final String? token = prefs.getString('token');
    final bool isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
    final String role = prefs.getString('role') ?? '';

    Widget initialScreen;

    if (!seenOnboarding) {
      initialScreen = const OnboardingScreen();
    } else if (token != null && token.isNotEmpty && isProfileComplete) {
      // Already logged in and profile complete
      if (role == 'user' || role == 'service_provider') {
        initialScreen = const Bottombar(); // Role-based homepage
      } else if (role == 'both' || role.isEmpty) {
        initialScreen = const RoleSelectionScreen(); // Fallback for undefined role
      } else {
        initialScreen = const RoleSelectionScreen(); // Fallback
      }
    } else {
      initialScreen = const LoginScreen(); // Not logged in or profile incomplete
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => initialScreen),
            (route) => false, // Clear navigation stack
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Green diagonal stripes
          Positioned(
            top: 10,
            left: -100,
            child: Transform.rotate(
              angle: -0.785398, // -45 degrees
              child: Container(
                width: 500,
                height: 25,
                color: AppColors.lightGreenOverlay,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: -100,
            child: Transform.rotate(
              angle: -0.785398,
              child: Container(
                width: 400,
                height: 25,
                color: AppColors.lightGreenOverlay,
              ),
            ),
          ),
          // Center Logo animation
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _navigateToNextScreen, // logo tap = force continue
                    child: CustomLogoWidget(
                      imagePath: 'assets/images/logo.png',
                      title: 'The Bharat Works',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
