// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../controllers/AccountController/EditWorkerController.dart';
//
// class EditWorkerScreen extends StatefulWidget {
//   final String workerId;
//
//   const EditWorkerScreen({super.key, required this.workerId});
//
//   @override
//   _EditWorkerScreenState createState() => _EditWorkerScreenState();
// }
//
// class _EditWorkerScreenState extends State<EditWorkerScreen> {
//   final EditWorkerController controller = EditWorkerController();
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadWorkerData();
//   }
//
//   Future<void> loadWorkerData() async {
//     final success = await controller.fetchWorkerDetails(widget.workerId);
//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//     });
//     if (!success) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to load worker details")),
//         );
//         Navigator.pop(context);
//       }
//     }
//   }
//
//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedImage != null && mounted) {
//       setState(() {
//         controller.selectedImage = File(pickedImage.path);
//       });
//     }
//   }
//
//   OutlineInputBorder _customBorder() {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: Colors.grey, width: 1),
//     );
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null && mounted) {
//       setState(() {
//         controller.dobController.text =
//             '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
//       });
//     }
//   }
//
//   Widget _buildTextField(
//     String hint,
//     TextEditingController controller,
//     String? error, {
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//             border: _customBorder(),
//             enabledBorder: _customBorder(),
//             focusedBorder: _customBorder(),
//           ),
//         ),
//         if (error != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text(
//               error,
//               style: const TextStyle(color: Colors.red, fontSize: 12),
//             ),
//           ),
//       ],
//     );
//   }
//
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
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: const Icon(
//                               Icons.arrow_back_outlined,
//                               size: 22,
//                             ),
//                           ),
//                           const SizedBox(width: 80),
//                           Text(
//                             "Edit Worker Details",
//                             style: GoogleFonts.roboto(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       GestureDetector(
//                         onTap: pickImage,
//                         child: Stack(
//                           alignment: Alignment.bottomRight,
//                           children: [
//                             ClipOval(
//                               child:
//                                   controller.selectedImage != null
//                                       ? Image.file(
//                                         controller.selectedImage!,
//                                         width: 120,
//                                         height: 120,
//                                         fit: BoxFit.cover,
//                                       )
//                                       : Image.asset(
//                                         'assets/images/No_image_available.png',
//                                         width: 120,
//                                         height: 120,
//                                         fit: BoxFit.cover,
//                                       ),
//                             ),
//                             Image.asset(
//                               'assets/images/edit1.png',
//                               height: 30,
//                               width: 30,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       _buildTextField(
//                         'Name',
//                         controller.nameController,
//                         controller.nameError,
//                       ),
//                       const SizedBox(height: 10),
//                       IntlPhoneField(
//                         initialValue: controller.phoneNumber ?? '',
//                         decoration: InputDecoration(
//                           hintText: 'Phone Number',
//                           border: _customBorder(),
//                           enabledBorder: _customBorder(),
//                           focusedBorder: _customBorder(),
//                         ),
//                         initialCountryCode: 'IN',
//                         disableLengthCheck: true,
//                         onChanged: (phone) {
//                           controller.phoneNumber = phone.number;
//                         },
//                       ),
//                       if (controller.phoneError != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Text(
//                             controller.phoneError!,
//                             style: const TextStyle(
//                               color: Colors.red,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       const SizedBox(height: 10),
//                       _buildTextField(
//                         'Aadhaar Number',
//                         controller.aadhaarController,
//                         controller.aadhaarError,
//                         keyboardType: TextInputType.number,
//                       ),
//                       const SizedBox(height: 10),
//                       GestureDetector(
//                         onTap: () => _selectDate(context),
//                         child: AbsorbPointer(
//                           child: _buildTextField(
//                             'Date of Birth (YYYY-MM-DD)',
//                             controller.dobController,
//                             controller.dobError,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       _buildTextField(
//                         'Address',
//                         controller.addressController,
//                         controller.addressError,
//                       ),
//                       const SizedBox(height: 30),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             if (!mounted) return;
//
//                             setState(() {
//                               controller.nameError = null;
//                               controller.phoneError = null;
//                               controller.aadhaarError = null;
//                               controller.dobError = null;
//                               controller.addressError = null;
//                             });
//
//                             if (controller.validateFields()) {
//                               final success = await controller
//                                   .submitUpdateWorkerAPI(
//                                     context,
//                                     widget.workerId,
//                                   );
//                               if (!mounted) return;
//
//                               if (success) {
//                                 // Show SnackBar and wait for it to complete
//                                 await ScaffoldMessenger.of(context)
//                                     .showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           "Worker updated successfully",
//                                         ),
//                                         duration: Duration(seconds: 2),
//                                       ),
//                                     )
//                                     .closed;
//
//                                 if (mounted) {
//                                   Navigator.pop(context, true);
//                                 }
//                               } else {
//                                 if (mounted) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text("Failed to update worker"),
//                                     ),
//                                   );
//                                 }
//                               }
//                             } else {
//                               if (mounted) {
//                                 setState(() {}); // Show validation errors
//                               }
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green.shade700,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'Update',
//                             style: TextStyle(fontSize: 15, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../Widgets/AppColors.dart';
import '../../controllers/AccountController/EditWorkerController.dart';

class EditWorkerScreen extends StatefulWidget {
  final String workerId;

  const EditWorkerScreen({super.key, required this.workerId});

  @override
  _EditWorkerScreenState createState() => _EditWorkerScreenState();
}

class _EditWorkerScreenState extends State<EditWorkerScreen> {
  final EditWorkerController controller = EditWorkerController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  ScaffoldMessengerState? _scaffoldMessengerState; //

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessengerState = ScaffoldMessenger.of(context); //
  }

  @override
  void initState() {
    super.initState();
    loadWorkerData();
  }

  Future<void> loadWorkerData() async {
    final success = await controller.fetchWorkerDetails(widget.workerId);
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    if (!success && mounted) {
      _scaffoldMessengerState?.showSnackBar(
        const SnackBar(content: Text("Failed to load worker details")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null && mounted) {
      setState(() {
        controller.selectedImage = File(pickedImage.path);
      });
    }
  }

  OutlineInputBorder _customBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        controller.dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    String? error, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            border: _customBorder(),
            enabledBorder: _customBorder(),
            focusedBorder: _customBorder(),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_outlined,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 80),
                        Text(
                          "Edit Worker Details",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipOval(
                            child: controller.selectedImage != null
                                ? Image.file(
                                    controller.selectedImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) =>
                                        Image.asset(
                                      'assets/images/No_image_available.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : controller.imageUrl != null &&
                                        controller.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        controller.imageUrl!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) =>
                                            Image.asset(
                                          'assets/images/No_image_available.png',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/No_image_available.png',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                          Image.asset(
                            'assets/images/edit1.png',
                            height: 30,
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      'Name',
                      controller.nameController,
                      controller.nameError,
                    ),
                    const SizedBox(height: 10),
                    IntlPhoneField(
                      initialValue: controller.phoneNumber ?? '',
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: _customBorder(),
                        enabledBorder: _customBorder(),
                        focusedBorder: _customBorder(),
                      ),
                      initialCountryCode: 'IN',
                      disableLengthCheck: true,
                      onChanged: (phone) {
                        controller.phoneNumber = phone.number;
                      },
                    ),
                    if (controller.phoneError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          controller.phoneError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      'Aadhaar Number',
                      controller.aadhaarController,
                      controller.aadhaarError,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField(
                          'Date of Birth (YYYY-MM-DD)',
                          controller.dobController,
                          controller.dobError,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      'Address',
                      controller.addressController,
                      controller.addressError,
                    ),
                    const SizedBox(height: 10),
                    // Aadhaar Images Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Aadhaar Images",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (controller.aadhaarSelectedImages.length +
                                    controller.aadhaarImageUrls.length >=
                                2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "⚠️ You can upload max 2 Aadhaar images")),
                              );
                              return;
                            }
                            _showImagePickerBottomSheet(context);
                          },
                          child: const Text("Update Aadhaar"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

// Aadhaar Images Grid
                    controller.isAadhaarLoading
                        ? const Center(child: CircularProgressIndicator())
                        : controller.aadhaarSelectedImages.isEmpty &&
                                controller.aadhaarImageUrls.isEmpty
                            ? const Text("No Aadhaar images uploaded")
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  // Local selected images
                                  ...controller.aadhaarSelectedImages.map(
                                    (file) => _buildAadhaarImageTile(
                                      Image.file(file,
                                          fit: BoxFit.cover,
                                          width: controller
                                                      .aadhaarSelectedImages
                                                      .length ==
                                                  1
                                              ? double.infinity
                                              : 150,
                                          height: 150,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      size: 50)),
                                      () {
                                        setState(() {
                                          controller.aadhaarSelectedImages
                                              .remove(file);
                                        });
                                      },
                                    ),
                                  ),
                                  // API images
                                  // API images with loader
                                  ...controller.aadhaarImageUrls.map(
                                    (url) => _buildAadhaarImageTile(
                                      Image.network(
                                        url,
                                        fit: BoxFit.fill,
                                        width: controller
                                                    .aadhaarImageUrls.length ==
                                                1
                                            ? double.infinity
                                            : 150,
                                        height: 150,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: 150,
                                            height: 150,
                                            alignment: Alignment.center,
                                            child:
                                                const CircularProgressIndicator(
                                                    strokeWidth: 2),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 50),
                                      ),
                                      () {
                                        setState(() {
                                          controller.aadhaarImageUrls
                                              .remove(url);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!mounted) return;

                          setState(() {
                            controller.nameError = null;
                            controller.phoneError = null;
                            controller.aadhaarError = null;
                            controller.dobError = null;
                            controller.addressError = null;
                          });

                          if (controller.validateFields()) {
                            final success =
                                await controller.submitUpdateWorkerAPI(
                              context,
                              widget.workerId,
                            );
                            if (!mounted) return;

                            if (success) {
                              _scaffoldMessengerState?.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Worker updated successfully",
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              await Future.delayed(
                                const Duration(seconds: 2),
                              ); // Wait for SnackBar to show
                              if (mounted) {
                                Navigator.pop(context, true);
                              }
                            } else {
                              _scaffoldMessengerState?.showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to update worker"),
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              setState(() {}); // Show validation errors
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildAadhaarImageTile(Widget imageWidget, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  final picked =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    setState(() {
                      controller.aadhaarSelectedImages.add(File(picked.path));
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      controller.aadhaarSelectedImages.add(File(picked.path));
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
