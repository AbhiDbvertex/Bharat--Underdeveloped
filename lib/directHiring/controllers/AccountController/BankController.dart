import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/AccountModel/BankModel.dart';

class BankController {
  final formKey = GlobalKey<FormState>();

  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountHolderNameController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final upiIdController = TextEditingController();

  /// ✅ Submit and update bank details to API
  void submitBankDetails(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final BankModel model = BankModel(
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        accountHolderName: accountHolderNameController.text.trim(),
        ifscCode: ifscCodeController.text.trim(),
        upiId: upiIdController.text.trim(), // ✅ Sahi
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.bankScreen}');

      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(model.toJson()),
        );

        final responseData = jsonDecode(response.body);
        debugPrint("API Response: $responseData");

        if (response.statusCode == 200 && responseData['status'] == true) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ??
                    'Bank details submitted successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Failed to update bank details',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// ✅ Input validation
  String? validateField(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    switch (label) {
      case 'Account Number':
        if (value.length < 9 || value.length > 18) {
          return 'Enter a valid account number';
        }
        break;
      case 'IFSC Code':
        // if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
        //   return 'Invalid IFSC code (e.g., SBIN0123456)';
        // }
        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value!)) {
          return 'Invalid IFSC code (only letters & numbers allowed)';
        }
        break;
      case 'UPI Id':
        if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(value)) {
          return 'Invalid UPI ID (e.g., name@upi)';
        }
        break;
    }

    return null;
  }

  /// ✅ Clean up controllers
  void dispose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderNameController.dispose();
    ifscCodeController.dispose();
    upiIdController.dispose();
  }
}
