// import 'dart:convert';

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class EditWorkerController {
//   final nameController = TextEditingController();
//   final aadhaarController = TextEditingController();
//   final addressController = TextEditingController();
//   final dobController = TextEditingController();
//
//   String? phoneNumber;
//   File? selectedImage;
//
//   String? nameError;
//   String? phoneError;
//   String? aadhaarError;
//   String? dobError;
//   String? addressError;
//
//   bool validateFields() {
//     bool isValid = true;
//
//     nameError = nameController.text.trim().isEmpty ? 'Name is required' : null;
//     if (nameError != null) isValid = false;
//
//     phoneError =
//         (phoneNumber == null || phoneNumber!.isEmpty)
//             ? 'Phone is required'
//             : null;
//     if (phoneError != null) isValid = false;
//
//     aadhaarError =
//         aadhaarController.text.trim().isEmpty
//             ? 'Aadhaar is required'
//             : (!RegExp(r'^\d{12}$').hasMatch(aadhaarController.text.trim())
//                 ? 'Aadhaar must be 12 digits'
//                 : null);
//     if (aadhaarError != null) isValid = false;
//
//     dobError = dobController.text.trim().isEmpty ? 'DOB is required' : null;
//     if (dobError != null) isValid = false;
//
//     addressError =
//         addressController.text.trim().isEmpty ? 'Address is required' : null;
//     if (addressError != null) isValid = false;
//
//     return isValid;
//   }
//
//   Future<bool> submitUpdateWorkerAPI(
//     BuildContext context,
//     String workerId,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("🔐 Token not found. Please login again."),
//         ),
//       );
//       return false;
//     }
//
//     final url = Uri.parse(
//       "https://api.thebharatworks.com/api/worker/edit/$workerId",
//     );
//     final request = http.MultipartRequest('PUT', url);
//
//     request.headers['Authorization'] = 'Bearer $token';
//     request.headers['Accept'] = 'application/json';
//
//     request.fields.addAll({
//       'name': nameController.text.trim(),
//       'phone': phoneNumber ?? '',
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
//       final respStr = await response.stream.bytesToString();
//
//       print("Status: ${response.statusCode}");
//       print("Response: $respStr");
//
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("✅ Worker updated successfully")),
//         );
//         return true;
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("❌ Update failed: $respStr")));
//         return false;
//       }
//     } catch (e) {
//       print("Exception: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("❌ Something went wrong")));
//       return false;
//     }
//   }
//
//   Future<bool> fetchWorkerDetails(String workerId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       debugPrint("🔐 Token not found");
//       return false;
//     }
//
//     final url = Uri.parse(
//       "https://api.thebharatworks.com/api/worker/get/$workerId",
//     );
//     print("📡 GET Request URL: $url");
//
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );
//
//       print("📩 Response: ${response.body}");
//
//       final decoded = jsonDecode(response.body);
//
//       // ✅ Correct key check
//       if (response.statusCode == 200 && decoded['worker'] != null) {
//         final data = Map<String, dynamic>.from(decoded['worker']);
//
//         nameController.text = data['name'] ?? '';
//         phoneNumber = data['phone'] ?? '';
//         aadhaarController.text = data['aadharNumber'] ?? '';
//         dobController.text =
//             data['dob']?.split('T').first ?? ''; // clean ISO date
//         addressController.text = data['address'] ?? '';
//
//         return true;
//       } else {
//         debugPrint("❌ Worker not found or data is null");
//         return false;
//       }
//     } catch (e) {
//       debugPrint("❗ Error fetching worker details: $e");
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

// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class EditWorkerController {
//   final nameController = TextEditingController();
//   final aadhaarController = TextEditingController();
//   final addressController = TextEditingController();
//   final dobController = TextEditingController();
//
//   String? phoneNumber;
//   File? selectedImage;
//   String? imageUrl;
//
//   String? nameError;
//   String? phoneError;
//   String? aadhaarError;
//   String? dobError;
//   String? addressError;
//   File? aadhaarSelectedImage;
//   String? aadhaarImageUrl; // From API
//
//   // Helper method to determine MIME type based on file extension
//   String getMimeType(String path) {
//     final extension = path.split('.').last.toLowerCase();
//     switch (extension) {
//       case 'jpg':
//       case 'jpeg':
//         return 'image/jpeg';
//       case 'png':
//         return 'image/png';
//       default:
//         return 'image/jpeg'; // Fallback
//     }
//   }
//
//   bool validateFields() {
//     bool isValid = true;
//
//     nameError = nameController.text.trim().isEmpty ? 'Name is required' : null;
//     if (nameError != null) isValid = false;
//
//     phoneError =
//     (phoneNumber == null || phoneNumber!.isEmpty)
//         ? 'Phone is required'
//         : null;
//     if (phoneError != null) isValid = false;
//
//     aadhaarError =
//     aadhaarController.text.trim().isEmpty
//         ? 'Aadhaar is required'
//         : (!RegExp(r'^\d{12}$').hasMatch(aadhaarController.text.trim())
//         ? 'Aadhaar must be 12 digits'
//         : null);
//     if (aadhaarError != null) isValid = false;
//
//     dobError = dobController.text.trim().isEmpty ? 'DOB is required' : null;
//     if (dobError != null) isValid = false;
//
//     addressError =
//     addressController.text.trim().isEmpty ? 'Address is required' : null;
//     if (addressError != null) isValid = false;
//
//     return isValid;
//   }
//
//   Future<bool> submitUpdateWorkerAPI(
//       BuildContext context,
//       String workerId,
//       ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("🔐 Token not found. Please login again."),
//         ),
//       );
//       return false;
//     }
//
//     final url = Uri.parse(
//       "https://api.thebharatworks.com/api/worker/edit/$workerId",
//     );
//     final request = http.MultipartRequest('PUT', url);
//
//     request.headers['Authorization'] = 'Bearer $token';
//     request.headers['Accept'] = 'application/json';
//
//     request.fields.addAll({
//       'name': nameController.text.trim(),
//       'phone': phoneNumber ?? '',
//       'aadharNumber': aadhaarController.text.trim(),
//       'dob': dobController.text.trim(),
//       'address': addressController.text.trim(),
//     });
//
//     // Handle image upload with dynamic MIME type
//     if (selectedImage != null) {
//       if (selectedImage!.existsSync()) {
//         print("📷 Image path: ${selectedImage!.path}");
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'image', // Verify this field name with your API
//             selectedImage!.path,
//             contentType: MediaType.parse(getMimeType(selectedImage!.path)),
//           ),
//         );
//       } else {
//         print("❌ Image file does not exist at path: ${selectedImage!.path}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ Selected image file is invalid")),
//         );
//       }
//     }
//     if (aadhaarSelectedImage != null && aadhaarSelectedImage!.existsSync()) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'aadharImage', // confirm field name from backend
//           aadhaarSelectedImage!.path,
//           contentType: MediaType.parse(getMimeType(aadhaarSelectedImage!.path)),
//         ),
//       );
//     }
//
//     try {
//       final response = await request.send();
//       final respStr = await response.stream.bytesToString();
//       final decoded = jsonDecode(respStr);
//
//       print("Status: ${response.statusCode}");
//       print("Response: $respStr");
//
//       if (response.statusCode == 200) {
//         if (decoded['success'] == true || decoded['worker'] != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("✅ Worker updated successfully")),
//           );
//           return true;
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "❌ Image update failed: ${decoded['message'] ?? 'Unknown error'}",
//               ),
//             ),
//           );
//           return false;
//         }
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("❌ Update failed: $respStr")));
//         return false;
//       }
//     } catch (e) {
//       print("Exception: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("❌ Something went wrong")));
//       return false;
//     }
//   }
//
//   Future<bool> fetchWorkerDetails(String workerId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null || token.isEmpty) {
//       debugPrint("🔐 Token not found");
//       return false;
//     }
//
//     final url = Uri.parse(
//       "https://api.thebharatworks.com/api/worker/get/$workerId",
//     );
//     print("📡 GET Request URL: $url");
//
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );
//
//       print("📩 Response: ${response.body}");
//
//       final decoded = jsonDecode(response.body);
//
//       if (response.statusCode == 200 && decoded['worker'] != null) {
//         final data = Map<String, dynamic>.from(decoded['worker']);
//
//         nameController.text = data['name'] ?? '';
//         phoneNumber = data['phone'] ?? '';
//         aadhaarController.text = data['aadharNumber'] ?? '';
//         dobController.text = data['dob']?.split('T').first ?? '';
//         addressController.text = data['address'] ?? '';
//         imageUrl = data['image']; // Store the image URL from the API
//         aadhaarImageUrl = data['aadharImage'];
//
//         return true;
//       } else {
//         debugPrint("❌ Worker not found or data is null");
//         return false;
//       }
//     } catch (e) {
//       debugPrint("❗ Error fetching worker details: $e");
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


///////////////////////////////
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Emergency/utils/snack_bar_helper.dart';
import '../../../utility/custom_snack_bar.dart';

class EditWorkerController {
  final nameController = TextEditingController();
  final aadhaarController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();

  String? phoneNumber;
  File? selectedImage;
  String? imageUrl;

  String? nameError;
  String? phoneError;
  String? aadhaarError;
  String? dobError;
  String? addressError;

  /// Aadhaar Images
  List<File> aadhaarSelectedImages = []; // locally picked images
  List<String> aadhaarImageUrls = []; // from API
  bool isAadhaarLoading = false;
  bool isSubmitting = false;

  // Helper method to determine MIME type based on file extension
  String getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'image/jpeg'; // Fallback
    }
  }

  bool validateFields() {
    bool isValid = true;

    nameError = nameController.text.trim().isEmpty ? 'Name is required' : null;
    if (nameError != null) isValid = false;

    phoneError = (phoneNumber == null || phoneNumber!.isEmpty)
        ? 'Phone is required'
        : null;
    if (phoneError != null) isValid = false;

    aadhaarError = aadhaarController.text.trim().isEmpty
        ? (aadhaarSelectedImages.isEmpty && aadhaarImageUrls.isEmpty
        ? 'Aadhaar number or at least one Aadhaar image is required'
        : null)
        : (!RegExp(r'^\d{12}$').hasMatch(aadhaarController.text.trim())
        ? 'Aadhaar must be 12 digits'
        : null);
    if (aadhaarError != null) isValid = false;

    dobError = dobController.text.trim().isEmpty ? 'DOB is required' : null;
    if (dobError != null) isValid = false;

    addressError =
        addressController.text.trim().isEmpty ? 'Address is required' : null;
    if (addressError != null) isValid = false;

    return isValid;
  }

  Future<bool> submitUpdateWorkerAPI(
    BuildContext context,
    String workerId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      CustomSnackBar.show(
          context,
          message: "Token not found. Please login again.",
          type: SnackBarType.warning
      );
      return false;
    }

    isSubmitting = true; // loader start
    try {
      final url = Uri.parse(
        "https://api.thebharatworks.com/api/worker/edit/$workerId",
      );
      final request = http.MultipartRequest('PUT', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields.addAll({
        'name': nameController.text.trim(),
        'phone': phoneNumber ?? '',
        'aadharNumber': aadhaarController.text.trim(),
        'dob': dobController.text.trim(),
        'address': addressController.text.trim(),
      });

      if (selectedImage != null && selectedImage!.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            selectedImage!.path,
            contentType: MediaType.parse(getMimeType(selectedImage!.path)),
          ),
        );
      }

      for (var file in aadhaarSelectedImages) {
        if (file.existsSync()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'aadharImage',
              file.path,
              contentType: MediaType.parse(getMimeType(file.path)),
            ),
          );
        }
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final decoded = jsonDecode(respStr);

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response: $respStr");


      if (response.statusCode == 200) {
        if (decoded['success'] == true || decoded['worker'] != null) {
          CustomSnackBar.show(
              context,
              message: "Worker updated successfully",
              type: SnackBarType.success
          );
          return true;
        } else {
          CustomSnackBar.show(
              context,
              message: "Update failed: ${decoded['message'] ?? 'Unknown error'}",
              type: SnackBarType.error
          );
          return false;
        }
      } else {
        CustomSnackBar.show(
            context,
            message:"Update failed: $respStr" ,
            type: SnackBarType.error
        );
        return false;
      }
      isSubmitting = false;
    } catch (e) {
      isSubmitting = false; // loader stop
      debugPrint("Exception: $e");
      CustomSnackBar.show(
          context,
          message: "Something went wrong",
          type: SnackBarType.error
      );

      return false;
    }
    finally{
      isSubmitting = false;
    }
  }

  Future<bool> fetchWorkerDetails(String workerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      debugPrint("🔐 Token not found");
      return false;
    }

    final url = Uri.parse(
      "https://api.thebharatworks.com/api/worker/get/$workerId",
    );
    debugPrint("📡 GET Request URL: $url");

    try {
      isAadhaarLoading = true;

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("📩 Response: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['worker'] != null) {
        final data = Map<String, dynamic>.from(decoded['worker']);

        nameController.text = data['name'] ?? '';
        phoneNumber = data['phone'] ?? '';
        aadhaarController.text = data['aadharNumber'] ?? '';
        dobController.text = data['dob']?.split('T').first ?? '';
        addressController.text = data['address'] ?? '';
        imageUrl = data['image'];

        /// Aadhaar images
        aadhaarImageUrls = [];
        if (data['aadharImage'] != null) {
          if (data['aadharImage'] is List) {
            aadhaarImageUrls =
                (data['aadharImage'] as List).map((e) => e.toString()).toList();
          } else if (data['aadharImage'] is String &&
              (data['aadharImage'] as String).isNotEmpty) {
            aadhaarImageUrls.add(data['aadharImage']);
          }
        }

        isAadhaarLoading = false;
        return true;
      } else {
        isAadhaarLoading = false;
        debugPrint("❌ Worker not found or data is null");
        return false;
      }
    } catch (e) {
      isAadhaarLoading = false;
      debugPrint("❗ Error fetching worker details: $e");
      return false;
    }
  }

  void dispose() {
    nameController.dispose();
    aadhaarController.dispose();
    addressController.dispose();
    dobController.dispose();
  }
}
