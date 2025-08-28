// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../../../Widgets/AppColors.dart';
//
// class BiddingWorkerDisputeScreen extends StatefulWidget {
//   final String orderId;
//   final String flowType;
//
//   const BiddingWorkerDisputeScreen({
//     super.key,
//     required this.orderId,
//     required this.flowType,
//   });
//
//   @override
//   State<BiddingWorkerDisputeScreen> createState() =>
//       _BiddingWorkerDisputeScreenState();
// }
//
// class _BiddingWorkerDisputeScreenState
//     extends State<BiddingWorkerDisputeScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _requirementController = TextEditingController();
//
//   List<File> _selectedImages = [];
//   bool isLoading = false;
//
//   // 📸 Pick multiple images from gallery
//   Future<void> pickImages() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickMultiImage();
//     if (picked.isNotEmpty) {
//       setState(() {
//         _selectedImages.addAll(picked.map((xFile) => File(xFile.path)));
//       });
//     }
//   }
//
//   // 🗑️ Remove image at index
//   void removeImage(int index) {
//     setState(() {
//       _selectedImages.removeAt(index);
//     });
//   }
//
//   // 🏗️ UI BUILD
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: Text("Dispute",
//             style: GoogleFonts.roboto(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             )),
//         leading: const BackButton(color: Colors.black),
//         actions: [],
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryGreen,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 50),
//             _buildLabel("Enter Amount"),
//             _buildTextField(_amountController, TextInputType.number),
//             _buildLabel("Description"),
//             _buildTextField(_descriptionController, TextInputType.text,
//                 maxLines: 4),
//             _buildLabel("Requirement"),
//             _buildTextField(_requirementController, TextInputType.text,
//                 maxLines: 4),
//             _buildLabel("Upload Images"),
//             GestureDetector(
//               onTap: pickImages,
//               child: Container(
//                 height: 90,
//                 width: 320,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey, width: 1.4),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Center(
//                   child: Text(
//                     _selectedImages.isEmpty
//                         ? 'Upload Images'
//                         : '${_selectedImages.length} Image${_selectedImages.length > 1 ? 's' : ''} Selected',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.green.shade700,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Display selected images in a grid
//             _selectedImages.isNotEmpty
//                 ? SizedBox(
//                     height: 120,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _selectedImages.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: const EdgeInsets.only(right: 8.0),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 width: 100,
//                                 height: 100,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(5),
//                                   image: DecorationImage(
//                                     image: FileImage(_selectedImages[index]),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: () => removeImage(index),
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                       color: Colors.red,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 20,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                 : const SizedBox(),
//             const SizedBox(height: 30),
//             Center(
//               child: ElevatedButton(
//                 onPressed: isLoading
//                     ? null
//                     : () {}, // Empty callback as submitDispute is removed
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade700,
//                   minimumSize: const Size(180, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         "Dispute",
//                         style: TextStyle(fontSize: 20, color: Colors.white),
//                       ),
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             text,
//             style:
//                 GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//         ],
//       );
//
//   // 🧾 Input TextField
//   Widget _buildTextField(
//       TextEditingController controller, TextInputType keyboardType,
//       {int maxLines = 1}) {
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
//         keyboardType: keyboardType,
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
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';

class BiddingWorkerDisputeScreen extends StatefulWidget {
  final String orderId;
  final String flowType;

  const BiddingWorkerDisputeScreen({
    super.key,
    required this.orderId,
    required this.flowType,
  });

  @override
  State<BiddingWorkerDisputeScreen> createState() =>
      _BiddingWorkerDisputeScreenState();
}

class _BiddingWorkerDisputeScreenState
    extends State<BiddingWorkerDisputeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();

  List<File> _selectedImages = [];
  bool isLoading = false;

  // 📸 Pick multiple images from gallery
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked.map((xFile) => File(xFile.path)));
      });
    }
  }

  // 🗑️ Remove image at index
  void removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 📤 Submit dispute to API
  Future<void> submitDispute() async {
    if (_amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _requirementController.text.isEmpty ||
        _selectedImages.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Please fill all fields and upload at least one image"),
          ),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      final uri =
          Uri.parse("https://api.thebharatworks.com/api/dispute/create");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print('🔐 Token: $token');

      final request = http.MultipartRequest("POST", uri)
        ..headers['Authorization'] = "Bearer $token"
        ..fields['order_id'] = widget.orderId
        ..fields['flow_type'] = widget.flowType
        ..fields['amount'] = _amountController.text
        ..fields['description'] = _descriptionController.text
        ..fields['requirement'] = _requirementController.text;

      // Add multiple images to the request
      for (var image in _selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            image.path,
            contentType:
                MediaType('image', 'jpeg'), // Adjust based on image type
          ),
        );
      }

      debugPrint("🔐 Token: $token");
      debugPrint("📤 Sending request with order_id=${widget.orderId}");

      final response = await request.send();
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);
      print("Abhi:- dispute response ${res.body}");
      print("Abhi:- dispute response ${res.statusCode}");

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
        print("Abhi:- dispute response ${res.body}");
        print("Abhi:- dispute response ${res.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Failed to create dispute"),
            ),
          );
        }
      }
    } catch (e) {
      print("Abhi:- dispute response $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exception occurred: $e")),
        );
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
        title: Text(
          "Dispute",
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
            const SizedBox(height: 50),
            _buildLabel("Enter Amount"),
            _buildTextField(_amountController, TextInputType.number),
            _buildLabel("Description"),
            _buildTextField(_descriptionController, TextInputType.text,
                maxLines: 4),
            _buildLabel("Requirement"),
            _buildTextField(_requirementController, TextInputType.text,
                maxLines: 4),
            _buildLabel("Upload Images"),
            GestureDetector(
              onTap: pickImages,
              child: Container(
                height: 90,
                width: 320,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.4),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    _selectedImages.isEmpty
                        ? 'Upload Images'
                        : '${_selectedImages.length} Image${_selectedImages.length > 1 ? 's' : ''} Selected',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display selected images in a grid
            _selectedImages.isNotEmpty
                ? SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => removeImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
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
                child: isLoading
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
            style:
                GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
      );

  // 🧾 Input TextField
  Widget _buildTextField(
      TextEditingController controller, TextInputType keyboardType,
      {int maxLines = 1}) {
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
