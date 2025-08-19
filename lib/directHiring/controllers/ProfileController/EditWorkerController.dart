import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/ServiceProviderModel/EditModel.dart';

class EditWorkerController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController(); // Optional backup
  final aadhaarController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();

  String? phoneNumber;
  File? selectedImage;

  String? nameError;
  String? phoneError;
  String? aadhaarError;
  String? dobError;
  String? addressError;

  /// ✅ Set data into controllers
  void setInitialData(EditWorkerModel model) {
    nameController.text = model.name ?? '';
    phoneNumber = model.phone ?? '';
    aadhaarController.text = model.aadhaar ?? '';
    dobController.text = model.dob?.split("T").first ?? ''; // Trim time
    addressController.text = model.address ?? '';
  }

  /// ✅ Fetch worker details from API
  Future<void> fetchWorkerDetails(String workerId) async {
    final url = Uri.parse(
      'https://api.thebharatworks.com/api/worker/get/$workerId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      debugPrint("📡 GET Request URL: $url");
      debugPrint("dfcdf:- ${response.body}");

      if (responseData['success'] == true && responseData['worker'] != null) {
        final worker = responseData['worker'];
        nameController.text = worker['name'] ?? '';
        aadhaarController.text = worker['aadharNumber'] ?? '';
        addressController.text = worker['address'] ?? '';
        dobController.text = worker['dob']?.split("T")[0] ?? '';
        phoneNumber = worker['phone'];

        print("✅ Worker data loaded");
      } else {
        print("❌ Worker not found or data is null");
      }
    } else {
      print("❌ Failed to load worker data");
    }
  }

  /// ✅ Form validation
  bool validateFields() {
    bool isValid = true;

    // Name
    if (nameController.text.trim().isEmpty) {
      nameError = 'Name is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(nameController.text.trim())) {
      nameError = 'Only alphabets allowed';
      isValid = false;
    } else {
      nameError = null;
    }

    // Phone
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      phoneError = 'Phone number is required';
      isValid = false;
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber!)) {
      phoneError = 'Must be 10 digits';
      isValid = false;
    } else {
      phoneError = null;
    }

    // Aadhaar
    if (aadhaarController.text.trim().isEmpty) {
      aadhaarError = 'Aadhaar number is required';
      isValid = false;
    } else if (!RegExp(
      r'^[0-9]{12}$',
    ).hasMatch(aadhaarController.text.trim())) {
      aadhaarError = 'Must be 12 digits';
      isValid = false;
    } else {
      aadhaarError = null;
    }

    // DOB
    if (dobController.text.trim().isEmpty) {
      dobError = 'DOB is required';
      isValid = false;
    } else {
      dobError = null;
    }

    // Address
    if (addressController.text.trim().isEmpty) {
      addressError = 'Address is required';
      isValid = false;
    } else {
      addressError = null;
    }

    return isValid;
  }

  /// ✅ Submit update to API
  Future<bool> submitUpdateWorkerAPI(BuildContext context, String id) async {
    try {
      final uri = Uri.parse(
        'https://api.thebharatworks.com/api/worker/edit/$id',
      );
      final request = http.MultipartRequest('PUT', uri);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🔒 Token missing, please login again."),
          ),
        );
        return false;
      }

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['name'] = nameController.text.trim();
      request.fields['phone'] = phoneNumber ?? '';
      request.fields['aadharNumber'] = aadhaarController.text.trim();
      request.fields['dob'] = dobController.text.trim();
      request.fields['address'] = addressController.text.trim();

      if (selectedImage != null && selectedImage!.existsSync()) {
        debugPrint("📷 Attaching image: ${selectedImage!.path}");
        request.files.add(
          await http.MultipartFile.fromPath('image', selectedImage!.path),
        );
      }

      debugPrint("📤 Sending PUT request to: $uri");
      debugPrint("🧾 Fields: ${request.fields}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("✅ Update Response Code: ${response.statusCode}");
      debugPrint("📩 anjali: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Worker updated successfully.")),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Update failed: ${response.body}")),
        );
        return false;
      }
    } catch (e) {
      debugPrint('❗ Exception during update: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Something went wrong.")));
      return false;
    }
  }

  /// ✅ Clean up
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    aadhaarController.dispose();
    dobController.dispose();
    addressController.dispose();
  }
}
