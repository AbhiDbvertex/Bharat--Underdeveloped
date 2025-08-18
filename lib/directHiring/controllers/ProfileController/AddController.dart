import 'package:flutter/material.dart';

import '../../models/ServiceProviderModel/AddModel.dart';

class AddController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? phoneNumber;

  String? nameError;
  String? phoneError;
  String? aadhaarError;
  String? dobError;
  String? addressError;

  bool validate() {
    bool valid = true;

    // Name validation
    if (nameController.text.trim().isEmpty) {
      nameError = 'Name is required';
      valid = false;
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(nameController.text.trim())) {
      nameError = 'Only alphabets allowed';
      valid = false;
    } else {
      nameError = null;
    }

    // Phone validation
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      phoneError = 'Phone number is required';
      valid = false;
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber!)) {
      phoneError = 'Phone number must be 10 digits';
      valid = false;
    } else {
      phoneError = null;
    }

    // Aadhaar validation
    if (aadhaarController.text.trim().isEmpty) {
      aadhaarError = 'Aadhaar number is required';
      valid = false;
    } else if (!RegExp(
      r'^[0-9]{12}$',
    ).hasMatch(aadhaarController.text.trim())) {
      aadhaarError = 'Aadhaar must be 12 digits';
      valid = false;
    } else {
      aadhaarError = null;
    }

    // DOB validation
    if (dobController.text.isEmpty) {
      dobError = 'Date of Birth is required';
      valid = false;
    } else {
      dobError = null;
    }

    // Address validation
    if (addressController.text.trim().isEmpty) {
      addressError = 'Address is required';
      valid = false;
    } else {
      addressError = null;
    }

    return valid;
  }

  AddModel getModel() {
    return AddModel(
      name: nameController.text.trim(),
      phoneNumber: phoneNumber ?? '',
      aadhaar: aadhaarController.text.trim(),
      dob: dobController.text,
      address: addressController.text.trim(),
    );
  }

  void dispose() {
    nameController.dispose();
    aadhaarController.dispose();
    addressController.dispose();
    dobController.dispose();
  }
}
