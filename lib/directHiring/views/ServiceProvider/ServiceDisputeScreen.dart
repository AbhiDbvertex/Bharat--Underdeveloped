//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
//
// import '../../Widgets/AppColors.dart';
//
// class ServiceDisputeScreen extends StatefulWidget {
//   final String orderId;
//   final String flowType;
//   final String token;
//
//   const ServiceDisputeScreen({
//     super.key,
//     required this.orderId,
//     required this.flowType,
//     required this.token,
//   });
//
//   @override
//   State<ServiceDisputeScreen> createState() => _ServiceDisputeScreenState();
// }
//
// class _ServiceDisputeScreenState extends State<ServiceDisputeScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _requirementController = TextEditingController();
//
//   File? _selectedImage;
//   bool isLoading = false;
//
//   // 📸 Pick image from gallery
//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _selectedImage = File(picked.path);
//       });
//     }
//   }
//
//   // 🚀 Submit dispute to API
//   Future<void> submitDispute() async {
//     if (_amountController.text.isEmpty ||
//         _descriptionController.text.isEmpty ||
//         _requirementController.text.isEmpty ||
//         _selectedImage == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Please fill all fields and upload an image"),
//           ),
//         );
//       }
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       final uri = Uri.parse(
//         "https://api.thebharatworks.com/api/dispute/create",
//       );
//
//       final request =
//       http.MultipartRequest("POST", uri)
//         ..headers['Authorization'] = "Bearer ${widget.token}"
//         ..fields['order_id'] = widget.orderId
//         ..fields['flow_type'] = widget.flowType
//         ..fields['amount'] = _amountController.text
//         ..fields['description'] = _descriptionController.text
//         ..fields['requirement'] = _requirementController.text
//         ..files.add(
//           await http.MultipartFile.fromPath('image', _selectedImage!.path),
//         );
//
//       debugPrint("🔐 Token: ${widget.token}");
//       debugPrint("📤 Sending request with order_id=${widget.orderId}");
//
//       final response = await request.send();
//
//       final res = await http.Response.fromStream(response);
//       final data = json.decode(res.body);
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(data['message'] ?? "Dispute created successfully"),
//             ),
//           );
//           Navigator.pop(context);
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(data['message'] ?? "Failed to create dispute"),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Exception occurred: $e")));
//       }
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   // 🏗️ UI BUILD
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Padding(
//                     padding: EdgeInsets.only(left: 18.0),
//                     child: Icon(Icons.arrow_back_outlined, size: 22),
//                   ),
//                 ),
//                 const SizedBox(width: 100),
//                 Text(
//                   "Dispute",
//                   style: GoogleFonts.roboto(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 50),
//
//             _buildLabel("Enter Amount"),
//             _buildTextField(_amountController),
//
//             _buildLabel("Description"),
//             _buildTextField(_descriptionController, maxLines: 4),
//
//             _buildLabel("Requirement"),
//             _buildTextField(_requirementController, maxLines: 4),
//
//             _buildLabel("Upload"),
//             GestureDetector(
//               onTap: pickImage,
//               child: Container(
//                 height: 90,
//                 width: 320,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey, width: 1.4),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Center(
//                   child: Text(
//                     _selectedImage == null ? 'Upload Image' : 'Image Selected',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.green.shade700,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             Center(
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : submitDispute,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade700,
//                   minimumSize: const Size(180, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child:
//                 isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                   "Dispute",
//                   style: TextStyle(fontSize: 20, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🔤 LABEL builder
//   Widget _buildLabel(String text) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         text,
//         style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       const SizedBox(height: 10),
//     ],
//   );
//
//   // 🧾 Input TextField
//   Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
//     return Container(
//       width: 320,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey, width: 1.4),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         decoration: const InputDecoration(border: InputBorder.none),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';

class ServiceDisputeScreen extends StatefulWidget {
  final String orderId;
  final String flowType;
  // final String token;

  const ServiceDisputeScreen({
    super.key,
    required this.orderId,
    required this.flowType,
    // required this.token,
  });

  @override
  State<ServiceDisputeScreen> createState() => _ServiceDisputeScreenState();
}

class _ServiceDisputeScreenState extends State<ServiceDisputeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();

  File? _selectedImage;
  bool isLoading = false;

  // 📸 Pick image from gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // 🚀 Submit dispute to API
  Future<void> submitDispute() async {
    if (_amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _requirementController.text.isEmpty ||
        _selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all fields and upload an image"),
          ),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(
        "https://api.thebharatworks.com/api/dispute/create",
      );
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print('🔐 Token: $token');

      final request =
      http.MultipartRequest("POST", uri)
        ..headers['Authorization'] = "Bearer ${token}"
        ..fields['order_id'] = widget.orderId
        ..fields['flow_type'] = widget.flowType
        ..fields['amount'] = _amountController.text
        ..fields['description'] = _descriptionController.text
        ..fields['requirement'] = _requirementController.text
        ..files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );

      debugPrint("🔐 Token: ${token}");
      debugPrint("📤 Sending request with order_id=${widget.orderId}");

      final response = await request.send();

      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Dispute created successfully"),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Failed to create dispute"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exception occurred: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🏗️ UI BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Dispute",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 20),
            // Row(
            //   children: [
            //     GestureDetector(
            //       onTap: () => Navigator.pop(context),
            //       child: const Padding(
            //         padding: EdgeInsets.only(left: 18.0),
            //         child: Icon(Icons.arrow_back_outlined, size: 22),
            //       ),
            //     ),
            //     const SizedBox(width: 100),
            //     Text(
            //       "Dispute",
            //       style: GoogleFonts.roboto(
            //         fontSize: 22,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 50),

            _buildLabel("Enter Amount"),
            _buildTextField(_amountController),

            _buildLabel("Description"),
            _buildTextField(_descriptionController, maxLines: 4),

            _buildLabel("Requirement"),
            _buildTextField(_requirementController, maxLines: 4),

            _buildLabel("Upload"),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 90,
                width: 320,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    _selectedImage == null ? 'Upload Image' : 'Image Selected',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : submitDispute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size(180, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Dispute",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔤 LABEL builder
  Widget _buildLabel(String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
    ],
  );

  // 🧾 Input TextField
  Widget _buildTextField(TextEditingController controller, {int maxLines = 1}) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}