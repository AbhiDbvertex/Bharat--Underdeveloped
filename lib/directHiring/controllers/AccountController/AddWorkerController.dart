//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AddWorkerController {
//   final formKey = GlobalKey<FormState>();
//
//   final nameController = TextEditingController();
//   final aadhaarController = TextEditingController();
//   final addressController = TextEditingController();
//   final dobController = TextEditingController();
//   final dojController =
//   TextEditingController(); // No default here, set in initState
//
//   String? phone;
//   File? selectedImage;
//
//   bool _isPickingImage = false;
//
//   Future<void> pickImage(Function updateUI) async {
//     if (_isPickingImage) return;
//     _isPickingImage = true;
//
//     try {
//       final picker = ImagePicker();
//       final pickedImage = await picker.pickImage(source: ImageSource.gallery);
//
//       if (pickedImage != null) {
//         selectedImage = File(pickedImage.path);
//         print("📸 Picked image path: ${selectedImage?.path}");
//         updateUI(); // Triggers setState()
//       }
//     } catch (e) {
//       print("❌ Error picking image: $e");
//     } finally {
//       _isPickingImage = false;
//     }
//   }
//
//   bool validateInputs() {
//     final isValid = formKey.currentState?.validate() ?? false;
//     if (!isValid) return false;
//     formKey.currentState?.save();
//     return true;
//   }
//
//   Future<bool> submitWorkerToAPI(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       if (!context.mounted) return false;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("🔐 Token not found. Please login again."),
//         ),
//       );
//       return false;
//     }
//
//     final url = Uri.parse("https://api.thebharatworks.com/api/worker/add");
//     final request = http.MultipartRequest('POST', url);
//     DateTime now = DateTime.now();
//     String formattedDate = DateFormat('yyyy-MM-dd').format(now);
//     print("Abhi pass current date : ${formattedDate}");
//
//     request.headers['Authorization'] = 'Bearer $token';
//     request.headers['Accept'] = 'application/json';
//
//     request.fields.addAll({
//       'name': nameController.text.trim(),
//       'phone': phone ?? '',
//       'aadharNumber': aadhaarController.text.trim(),
//       'dob': dobController.text.trim(),
//       'address': addressController.text.trim(),
//       'dateOfJoining': formattedDate,
//     });
//
//     if (selectedImage != null && selectedImage!.existsSync()) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'image',
//           selectedImage!.path,
//           contentType: MediaType('image', 'jpeg'),
//         ),
//       );
//     }
//
//     try {
//       final response = await request.send();
//       final body = await response.stream.bytesToString();
//
//       print("📤 Fields: ${request.fields}");
//       print("📡 Status: ${response.statusCode}");
//       print("📩 Response: $body");
//
//       if (!context.mounted) return false;
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return true;
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("❌ Failed: $body")));
//         return false;
//       }
//     } catch (e) {
//       if (!context.mounted) return false;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
//       return false;
//     }
//   }
//
//   void dispose() {
//     nameController.dispose();
//     aadhaarController.dispose();
//     addressController.dispose();
//     dobController.dispose();
//     dojController.dispose();
//   }
// }

import 'dart:io';

import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utility/custom_snack_bar.dart';

class AddWorkerController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final aadhaarController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final dojController = TextEditingController();
  final phoneController = TextEditingController(); // New controller for phone
  List<XFile> aadhaarImages = [];

  String? phone;
  File? selectedImage;

  bool _isPickingImage = false;

  Future<void> pickProfileImage(BuildContext context, VoidCallback onUpdate) async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedImage = await picker.pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    selectedImage = File(pickedImage.path);
                    print("📸 Picked profile image path: ${selectedImage?.path}");
                    onUpdate();
                  }
                  Navigator.of(context).pop();
                  _isPickingImage = false;
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    selectedImage = File(pickedImage.path);
                    print("📸 Picked profile image path: ${selectedImage?.path}");
                    onUpdate();
                  }
                  Navigator.of(context).pop();
                  _isPickingImage = false;
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isPickingImage = false;
    });
  }

  Future<void> pickImage(Function updateUI) async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        selectedImage = File(pickedImage.path);
        print("📸 Picked image path: ${selectedImage?.path}");
        updateUI();
      }
    } catch (e) {
      print("❌ Error picking image: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  // bool validateInputs() {
  //   // Validate phone field explicitly
  //   if (phone == null || phone!.trim().isEmpty) {
  //     return false;
  //   }
  //   if (!RegExp(r'^\d{10}$').hasMatch(phone!.trim())) {
  //     return false;
  //   }
  //   // Validate other form fields
  //   final isValid = formKey.currentState?.validate() ?? false;
  //   if (aadhaarImages.isEmpty) {
  //     return false;
  //   }
  //   return isValid;
  // }



  String? validateInputs() {
    // Validate name
    if (nameController.text.trim().isEmpty) {
      return 'Please enter a name';
    }
    if (nameController.text.trim().length < 3) {
      return 'Name should be at least 3 characters';
    }

    // Validate phone
    if (phone == null || phone!.trim().isEmpty) {
      return 'Please enter a phone number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone!.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }

    // Validate Aadhaar number
    if (aadhaarController.text.trim().isEmpty) {
      return 'Please enter an Aadhaar number';
    }
    if (!RegExp(r'^[0-9]{12}$').hasMatch(aadhaarController.text.trim())) {
      return 'Please enter a valid 12-digit Aadhaar number';
    }

    // Validate DOB
    if (dobController.text.trim().isEmpty) {
      return 'Please enter a date of birth';
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dobController.text.trim())) {
      return 'Date of birth format should be YYYY-MM-DD';
    }
    try {
      final date = DateTime.parse(dobController.text.trim());
      final now = DateTime.now();
      final earliest = DateTime(1900);
      if (date.isAfter(now)) return 'Date of birth cannot be in the future';
      if (date.isBefore(earliest)) return 'Date of birth is too old';
    } catch (e) {
      return 'Please enter a valid date of birth';
    }

    // Validate address
    if (addressController.text.trim().isEmpty) {
      return 'Please enter an address';
    }
    if (addressController.text.trim().length < 3) {
      return 'Please enter a valid address';
    }

    // Validate Aadhaar images
    if (aadhaarImages.isEmpty) {
      return 'Please upload at least one Aadhaar image';
    }

    // Validate other form fields via FormState
    if (!(formKey.currentState?.validate() ?? false)) {
      return 'Please correct the errors in the form';
    }

    return null; // All validations passed
  }

  Future<bool> submitWorkerToAPI(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      if (!context.mounted) return false;
      CustomSnackBar.show(
          context,
          message:"Token not found. Please login again." ,
          type: SnackBarType.warning
      );


      return false;
    }

    final url = Uri.parse("https://api.thebharatworks.com/api/worker/add");
    final request = http.MultipartRequest('POST', url);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    print("Abhi pass current date : ${formattedDate}");

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields.addAll({
      'name': nameController.text.trim(),
      'phone': phone ?? '',
      'aadharNumber': aadhaarController.text.trim(),
      'dob': dobController.text.trim(),
      'address': addressController.text.trim(),
      'dateOfJoining': formattedDate,
    });

    if (selectedImage != null && selectedImage!.existsSync()) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    // Aadhaar Image(s)
    if (aadhaarImages.isEmpty) {
      if (!context.mounted) return false;
           CustomSnackBar.show(
          context,
          message: "Please upload at least 1 Aadhaar image.",
          type: SnackBarType.error
      );

      return false;
    }
    for (int i = 0; i < aadhaarImages.length; i++) {
      final file = aadhaarImages[i];
      request.files.add(
        await http.MultipartFile.fromPath(
          'aadharImage',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      print("📤 Fields: ${request.fields}");
      bwDebug("📎 Files: ${request.files.map((f) => f.filename).toList()}");

      print("📡 Status: ${response.statusCode}");
      print("📩 Response: $body");

      if (!context.mounted) return false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackBar.show(
            context,
            message:"Worker added successfully" ,
            type: SnackBarType.success
        );

        return true;
      } else {

        CustomSnackBar.show(
            context,
            message:"Failed: $body" ,
            type: SnackBarType.error
        );

        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      CustomSnackBar.show(
          context,
          message: "Something went wrong.",
          type: SnackBarType.error
      );

      return false;
    }
  }
  Future<void> pickAadhaarImages(BuildContext context, VoidCallback onUpdate) async {
    if (aadhaarImages.length >= 2) {
      CustomSnackBar.show(
          context,
          message: 'You can upload up to 2 Aadhaar images only.',
          type: SnackBarType.warning
      );

      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext buildContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    aadhaarImages.add(pickedImage);
                    onUpdate();
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickMultiImage();
                  if (picked.isNotEmpty) {
                    final remaining = 2 - aadhaarImages.length;
                    aadhaarImages.addAll(picked.take(remaining));
                    onUpdate();
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void removeAadhaarImage(int index, VoidCallback onUpdate) {
    aadhaarImages.removeAt(index);
    onUpdate();
  }

  void dispose() {
    nameController.dispose();
    aadhaarController.dispose();
    addressController.dispose();
    dobController.dispose();
    dojController.dispose();
    phoneController.dispose();
  }
}