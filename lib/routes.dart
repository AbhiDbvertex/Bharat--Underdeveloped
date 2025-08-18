// routes.dart

import 'package:flutter/material.dart';

import 'directHiring/views/auth/LoginScreen.dart';
import 'directHiring/views/auth/OnboardingScreen.dart';
import 'directHiring/views/auth/OtpVerificationScreen.dart';



class AppRoutes {
  static const String loginScreen = '/';
  static const String otpVerificationScreen = '/otpVerification';
  static const String onboardingScreen = '/onboarding';

  static Map<String, WidgetBuilder> routes = {
    loginScreen: (context) => const LoginScreen(),
    otpVerificationScreen: (context) => const  OtpVerificationScreen(phoneNumber: '',),
    onboardingScreen: (context) => const OnboardingScreen(),
  };
}
