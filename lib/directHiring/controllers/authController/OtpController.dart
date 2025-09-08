
import 'dart:convert';
import 'dart:math';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Added fluttertoast import

import '../../../Widgets/Bottombar.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/OtpModel.dart';
import '../../views/auth/RoleSelectionScreen.dart';

class OtpController {
  final OtpModel model;

  final List<TextEditingController> textControllers = List.generate(
    4,
        (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  final List<AnimationController> animControllers = [];
  final List<Animation<double>> scaleAnimations = [];

  OtpController(this.model, TickerProvider vsync) {
    for (int i = 0; i < 4; i++) {
      final animCtrl = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 200),
      );
      final animation = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeOut));

      animControllers.add(animCtrl);
      scaleAnimations.add(animation);
    }
  }

  void handleOtpInput(int index, String value, VoidCallback refreshUI) {
    if (value.length == 1) {
      model.otpDigits[index] = value;
      animControllers[index].forward().then(
            (_) => animControllers[index].reverse(),
      );
      if (index < 3) focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    } else {
      model.otpDigits[index] = '';
    }
    refreshUI();
  }

  void updateOtp(String value) {
    for (int i = 0; i < 4; i++) {
      model.otpDigits[i] = (i < value.length) ? value[i] : '';
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    final phone = model.phoneNumber.trim();
    final enteredOtp = model.otpDigits.join().trim();
    final GetXRoleController roleController = Get.find<GetXRoleController>();

    if (enteredOtp.length != 4 || !RegExp(r'^\d{4}$').hasMatch(enteredOtp)) {
      _showMessage("Please enter a valid 4-digit OTP.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.thebharatworks.com/api/user/verifyOtp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'entered_otp': enteredOtp}),
      );

      final data = jsonDecode(response.body);
      print("✅ Verify OTP API Response: ${response.body}");
      print("✅ Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final success = data['status'] == true;
        final token = data['token'];
        final isProfileComplete = data['isProfileComplete'] ?? false;
        final role = data['role'] ?? 'none';

        if (success && token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setBool('isProfileComplete', isProfileComplete);
          await prefs.setString('role', role);
          await prefs.setBool('onboardingComplete', true);
          await roleController.setRoleFromOtp(role);

          await fetchAndSaveProfileData(token);

          Widget nextScreen = const RoleSelectionScreen();
          if (isProfileComplete &&
              (role == 'user' || role == 'service_provider')) {
            nextScreen = const Bottombar();
          }
          _showMessage(data['message'] ?? "OTP verified successfully");

          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => nextScreen),
                (route) => false,
          );
        } else {
          _showMessage(data['message'] ?? "Invalid OTP or authentication failed.");
        }
      } else {
        _showMessage(data['message'] ?? "Server error occurred. Please try again.");
      }
    } catch (e) {
      print('❌ Network Error: $e');
      _showMessage("Network error. Please check your connection.");
    }
  }

  Future<void> resendOtp(
      BuildContext context,
      TextEditingController pinController,
      Function(String?) refreshUI,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.thebharatworks.com/api/user/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': model.phoneNumber.trim()}),
      );

      final data = jsonDecode(response.body);
      print('✅ Resend OTP API Response: ${response.body}');
      print('✅ Resend OTP Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final success = data['status'] == true;
        String? newOtp = data['temp_otp'];

        if (success) {
          model.otpDigits = ['', '', '', ''];
          pinController.clear();
          for (var controller in textControllers) {
            controller.clear();
          }
          if (newOtp != null && newOtp.length == 4) {
            model.otpDigits = newOtp.split('');
          } else {
            newOtp = (Random().nextInt(9000) + 1000).toString();
            model.otpDigits = newOtp.split('');
          }
          refreshUI(newOtp);
          _showMessage(data['message'] ?? "OTP sent successfully");
        } else {
          _showMessage(data['message'] ?? "Failed to resend OTP. Please try again.");
        }
      } else {
        _showMessage(data['message'] ?? "Server error occurred. Please try again.");
      }
    } catch (e) {
      print('❌ Resend OTP Error: $e');
      _showMessage("Network error. Please check your connection.");
    }
  }

  Future<void> fetchAndSaveProfileData(String token) async {
    bwDebug("[fetchAndSaveProfileData],  call: ",tag: "otp COntroller ");
    final profileUrl = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoint.otpVerificationScreen}',
    );

    final response = await http.get(
      profileUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('✅ Profile Fetch API Response: ${response.body}');
    print('✅ Profile Fetch Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final profileData = jsonDecode(response.body);
      final profile = profileData['data'];

      final categoryId = profile['category_id'];
      final subCategoryIds = profile['subcategory_ids'];

      if (categoryId != null &&
          subCategoryIds != null &&
          subCategoryIds.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('category_id', categoryId);
        await prefs.setString('sub_category_id', subCategoryIds[0]);
        print('✅ Saved category_id: $categoryId');
        print('✅ Saved sub_category_id: ${subCategoryIds[0]}');
      } else {
        print('⚠️ category_id or sub_category_id not found');
      }
    } else {
      print('❌ Profile fetch failed: ${response.statusCode}');
    }
  }

  void dispose() {
    for (final c in textControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    for (final a in animControllers) {
      a.dispose();
    }
  }

  void _showMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG, // Maps to ~2 seconds
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }
}
