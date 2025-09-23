// import 'dart:convert';
//
// import 'package:developer/NotificationService.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../../Consent/ApiEndpoint.dart';
// import '../../Consent/app_constants.dart';
// import '../../views/auth/OtpVerificationScreen.dart';
//
// class LoginController {
//   final TextEditingController phoneController;
//   final FocusNode focusNode = FocusNode();
//
//   LoginController(this.phoneController);
//
//   void dispose() {
//     phoneController.dispose();
//     focusNode.dispose();
//   }
//
//   Future<void> login(BuildContext context) async {
//     final phone = phoneController.text.trim();
//
//     if (phone.length != 10) {
//       _showSnackBar(context, 'Please enter a valid 10-digit phone number');
//       return;
//     }
//
//     final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.loginScreen}');
//     final fcmToken =
//         await NotificationService.getTokenFromPrefs(); // Await here
//
//     print(" Phone: $phone,  FCM Token: $fcmToken");
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'phone': phone,
//           'firebase_token': fcmToken ?? '', // Handle null case
//         }),
//       );
//
//       final responseData = jsonDecode(response.body);
//       print(
//         " anjalii Login API Response: ${response.statusCode} - $responseData",
//       );
//
//       if (response.statusCode == 200 && responseData['status'] == true) {
//         final String? tempOtp = responseData['temp_otp'];
//
//         Future.delayed(Duration.zero, () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (_) => OtpVerificationScreen(
//                     phoneNumber: phone,
//                     receivedOtp: tempOtp,
//                   ),
//             ),
//           );
//         });
//       } else {
//         final errorMsg = responseData['message'] ?? 'Failed to send OTP';
//         _showSnackBar(context, errorMsg);
//         print("❌ Error: $errorMsg");
//       }
//     } catch (e) {
//       _showSnackBar(context, 'Network error: $e');
//       print("❌ Network error: $e");
//     }
//   }
//
//   void _showSnackBar(BuildContext context, String message) {
//     Future.delayed(Duration.zero, () {
//       if (context.mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(message)));
//       }
//     });
//   }
// }

import 'dart:convert';

import 'package:developer/NotificationService.dart';
import 'package:developer/utility/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../views/auth/OtpVerificationScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginController {
  final TextEditingController phoneController;
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  LoginController(this.phoneController);

  void dispose() {
    phoneController.dispose();
    focusNode.dispose();
    isLoading.dispose();
  }

  Future<void> login(BuildContext context) async {
    final phone = phoneController.text.trim();

    // Validate phone number
    if (phone.length != 10) {
      // _showSnackBar(context, 'Please enter a valid 10-digit phone number');
      CustomSnackBar.show(context,
          message: "Please enter a valid 10-digit phone number",
          type: SnackBarType.error);
      return;
    }
    isLoading.value = true;
    // API URL
    final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.loginScreen}');

    // Fetch FCM token with retry logic
    final fcmToken = await NotificationService.getTokenFromPrefs();
    print("Phone: $phone, FCM Token: $fcmToken");

    // Check if token is null
    if (fcmToken == null) {
      // _showSnackBar(context, 'Unable to fetch FCM token. Please try again.');
      CustomSnackBar.show(context,
          message: "Unable to fetch FCM token. Please try again.",
          type: SnackBarType.error);
      print("❌ FCM Token is null, retry failed!");
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'firebase_token': fcmToken, // No need for null check, handled above
        }),
      );

      print("Abhi:- print on success ${fcmToken}");

      final responseData = jsonDecode(response.body);
      print(
        "anjalii Login API Response: ${response.statusCode} - $responseData",
      );

      print("Abhi:- print on success 1 ${fcmToken}");

      if (response.statusCode == 200 && responseData['status'] == true) {
        final String? tempOtp = responseData['temp_otp']?.toString();
        if (tempOtp == null) {
          // _showSnackBar(context, 'OTP not received from server');
          CustomSnackBar.show(context, message: 'OTP not received from server' ,type: SnackBarType.warning);
          print("❌ OTP is null in response: $responseData");
          isLoading.value = false;
          return;
        }
        // _showSnackBar(context, "OTP sent successfully");
        // CustomSnackBar.show(context, message: "OTP sent successfully",type: SnackBarType.success);
        print("Abhi:- 2 print on success ${fcmToken}");
        // Navigate to OTP screen
        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: phone,
                receivedOtp: tempOtp,
              ),
            ),
          );
        });
        Fluttertoast.showToast(
          msg: "OTP sent successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14,
        );
      } else {
        final errorMsg = responseData['message'] ?? 'Failed to send OTP';
        // _showSnackBar(context, errorMsg);
        CustomSnackBar.show(context, message: errorMsg,type: SnackBarType.error);
        print("❌ Error: $errorMsg");
      }
    } catch (e) {
      // _showSnackBar(context, 'Network error: $e');
      CustomSnackBar.show(context, message: 'Network error' ,type: SnackBarType.error);

      print("❌ Network error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
