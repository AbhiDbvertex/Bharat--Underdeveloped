import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/OnboardingModel.dart';
import '../../views/auth/LoginScreen.dart';

class OnboardingController {
  final PageController pageController = PageController();
  int currentIndex = 0;
  double buttonScale = 1.0;
  final OnboardingModel model = OnboardingModel();

  void goToLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true); // Set flag here

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void nextSlide(BuildContext context) {
    goToLogin(context);
  }

  void onPageChanged(int index) {
    currentIndex = index;
  }

  void dispose() {
    pageController.dispose();
  }
}
