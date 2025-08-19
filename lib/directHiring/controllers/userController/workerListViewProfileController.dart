import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkerListViewProfileController {
  File? selectedImage;
  TextEditingController nameController = TextEditingController();
  TextEditingController aadhaarController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? phoneNumber;
  String? imageUrl;

  String? nameError;
  String? phoneError;
  String? aadhaarError;
  String? dobError;
  String? addressError;

  Future<void> fetchWorkerProfile(String workerId) async {
    if (workerId.trim().isEmpty) {
      print('❌ ERROR: workerId is empty');
      return;
    }

    final url = Uri.parse(
      'https://api.thebharatworks.com/api/worker/get/$workerId',
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('anii Response status: ${response.statusCode}');
      print('anii Raw body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['worker'] != null) {
          final data = jsonData['worker'];

          nameController.text = data['name'] ?? '';
          aadhaarController.text = data['aadharNumber'] ?? '';
          dobController.text = data['dob']?.substring(0, 10) ?? '';
          addressController.text = data['address'] ?? '';
          phoneNumber = data['phone'] ?? '';

          // Use the image URL directly from API response
          imageUrl = data['image']?.isNotEmpty == true ? data['image'] : null;

          print('✅ Worker profile loaded successfully');
        } else {
          print('❌ Invalid format or worker not found');
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to fetch worker. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🚨 Error in fetchWorkerProfile: $e');
      rethrow;
    }
  }

  bool validateFields() {
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError = "Name is required";
      isValid = false;
    } else {
      nameError = null;
    }

    if (phoneNumber == null || phoneNumber!.trim().isEmpty) {
      phoneError = "Phone number is required";
      isValid = false;
    } else if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber!)) {
      phoneError = "Invalid phone number";
      isValid = false;
    } else {
      phoneError = null;
    }

    if (aadhaarController.text.trim().isEmpty) {
      aadhaarError = "Aadhaar number is required";
      isValid = false;
    } else if (!RegExp(r'^\d{12}$').hasMatch(aadhaarController.text.trim())) {
      aadhaarError = "Aadhaar number must be 12 digits";
      isValid = false;
    } else {
      aadhaarError = null;
    }

    if (dobController.text.trim().isEmpty) {
      dobError = "Date of Birth is required";
      isValid = false;
    } else {
      dobError = null;
    }

    if (addressController.text.trim().isEmpty) {
      addressError = "Address is required";
      isValid = false;
    } else {
      addressError = null;
    }

    return isValid;
  }

  void dispose() {
    nameController.dispose();
    aadhaarController.dispose();
    dobController.dispose();
    addressController.dispose();
  }
}
