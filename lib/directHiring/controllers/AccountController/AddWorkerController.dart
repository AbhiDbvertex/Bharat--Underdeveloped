// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AddWorkerController {
//   final formKey = GlobalKey<FormState>();
//
//   final nameController = TextEditingController();
//   final aadhaarController = TextEditingController();
//   final addressController = TextEditingController();
//   final dobController = TextEditingController();
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
//         updateUI(); // ← ye setState() trigger karega
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
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddWorkerController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final aadhaarController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final dojController =
  TextEditingController(); // No default here, set in initState

  String? phone;
  File? selectedImage;

  bool _isPickingImage = false;

  Future<void> pickImage(Function updateUI) async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        selectedImage = File(pickedImage.path);
        print("📸 Picked image path: ${selectedImage?.path}");
        updateUI(); // Triggers setState()
      }
    } catch (e) {
      print("❌ Error picking image: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  bool validateInputs() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;
    formKey.currentState?.save();
    return true;
  }

  Future<bool> submitWorkerToAPI(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔐 Token not found. Please login again."),
        ),
      );
      return false;
    }

    final url = Uri.parse("https://api.thebharatworks.com/api/worker/add");
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields.addAll({
      'name': nameController.text.trim(),
      'phone': phone ?? '',
      'aadharNumber': aadhaarController.text.trim(),
      'dob': dobController.text.trim(),
      'address': addressController.text.trim(),
      'dateOfJoining': dojController.text.trim(),
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

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      print("📤 Fields: ${request.fields}");
      print("📡 Status: ${response.statusCode}");
      print("📩 Response: $body");

      if (!context.mounted) return false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: $body")));
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
      return false;
    }
  }

  void dispose() {
    nameController.dispose();
    aadhaarController.dispose();
    addressController.dispose();
    dobController.dispose();
    dojController.dispose();
  }
}