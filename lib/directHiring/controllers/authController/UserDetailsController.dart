//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/Bottombar.dart';
// import '../../views/auth/RoleSelectionScreen.dart';
//
// class UserDetailsController {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController referralController = TextEditingController();
//   final TextEditingController roleController = TextEditingController();
//
//   final Map<String, String?> _errorTexts = {};
//   Map<String, String?> get errorTexts => _errorTexts;
//
//   void setRole(String selectedLabel) {
//     const roleMap = {
//       'User': 'user',
//       'Service Provider': 'service_provider',
//       'Business': 'service_provider',
//     };
//     roleController.text = roleMap[selectedLabel] ?? selectedLabel.toLowerCase();
//     debugPrint("📍 Role set: ${roleController.text}");
//   }
//
//   bool validateForm() {
//     _errorTexts.clear();
//
//     // Validate Name
//     if (nameController.text.trim().isEmpty) {
//       _errorTexts['name'] = 'Please enter your full name.';
//     } else if (nameController.text.trim().length < 3) {
//       _errorTexts['name'] = 'Full name must be at least 3 characters long.';
//     }
//
//     // Validate Role
//     if (roleController.text.isEmpty) {
//       _errorTexts['role'] = 'Please select a role.';
//     }
//
//     // Validate Referral Code (optional)
//     final referral = referralController.text.trim();
//     if (referral.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(referral)) {
//       _errorTexts['referral'] = 'Referral code can only contain letters and numbers.';
//     }
//
//     debugPrint("🔍 Validation Errors: $_errorTexts");
//     return _errorTexts.isEmpty;
//   }
//
//   Future<Map<String, dynamic>> submitUserProfile(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       // if (context.mounted) {
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(
//       //       content: Text('Authentication failed. Please log in again.'),
//       //       duration: Duration(seconds: 2),
//       //     ),
//       //   );
//       // }
//       return {
//         "success": false,
//         "message": "Authentication failed. Please log in again.",
//       };
//     }
//
//     if (!validateForm()) {
//       // if (context.mounted) {
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     const SnackBar(
//       //       content: Text('Please fill in all required fields correctly.'),
//       //       duration: Duration(seconds: 2),
//       //     ),
//       //   );
//       // }
//       return {
//         "success": false,
//         "message": "Please fill in all required fields correctly.",
//       };
//     }
//
//     final url = Uri.parse(
//       'https://api.thebharatworks.com/api/user/updateUserProfile',
//     );
//
//     final body = {
//       "full_name": nameController.text.trim(),
//       "role": roleController.text,
//       "referral_code": referralController.text.trim().isEmpty
//           ? null
//           : referralController.text.trim(),
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(body),
//       );
//
//       debugPrint("📍 API Response: ${response.body}, Status: ${response.statusCode}");
//
//       final responseData = jsonDecode(response.body);
//       final success = responseData['status'] == true;
//       final message = responseData['message'] ??
//           (success ? "Profile updated successfully." : "Profile update failed.");
//
//       if (success) {
//         await prefs.setBool('isProfileComplete', true);
//         await prefs.setString('role', roleController.text);
//         await prefs.setBool('onboardingComplete', true);
//
//         // if (context.mounted) {
//         //   ScaffoldMessenger.of(context).showSnackBar(
//         //     SnackBar(
//         //       content: Text(message),
//         //       duration: const Duration(seconds: 2),
//         //     ),
//         //   );
//         // }
//       } else {
//         // if (context.mounted) {
//         //   ScaffoldMessenger.of(context).showSnackBar(
//         //     SnackBar(
//         //       content: Text(message),
//         //       duration: const Duration(seconds: 2),
//         //     ),
//         //   );
//         // }
//       }
//
//       return {"success": success, "message": message};
//     } catch (e) {
//       debugPrint("❌ Error: $e");
//       // if (context.mounted) {
//       //   ScaffoldMessenger.of(context).showSnackBar(
//       //     SnackBar(
//       //       content: Text("An error occurred: $e"),
//       //       duration: const Duration(seconds: 2),
//       //     ),
//       //   );
//       // }
//       return {"success": false, "message": "An error occurred: $e"};
//     }
//   }
//
//   void clearForm() {
//     nameController.clear();
//     referralController.clear();
//     roleController.clear();
//     _errorTexts.clear();
//   }
//
//   void dispose() {
//     nameController.dispose();
//     referralController.dispose();
//     roleController.dispose();
//   }
// }