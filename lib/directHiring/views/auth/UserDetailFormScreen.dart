// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
// import '../../Widgets/Bottombar.dart';
// import '../../Widgets/CustomButton.dart';
// import '../../controllers/authController/UserDetailsController.dart';
// import '../../models/RoleModel.dart';
// import 'AddressDetailScreen.dart';
// import 'RoleSelectionScreen.dart';
//
// class UserDetailFormScreen extends StatefulWidget {
//   final String role;
//
//   const UserDetailFormScreen({super.key, required this.role});
//
//   @override
//   State<UserDetailFormScreen> createState() => _UserDetailFormScreenState();
// }
//
// class _UserDetailFormScreenState extends State<UserDetailFormScreen> {
//   late final RoleModel model;
//   // late final UserDetailsController controller;
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController referralController = TextEditingController();
//   final TextEditingController roleController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     model = RoleModel();
//     // controller = UserDetailsController();
//     // controller.setRole(widget.role);
//     model.selectedRole = widget.role;
//     // debugPrint(
//     //   "🔧 Initial Role: ${widget.role}, Controller Role: ${controller.roleController.text}",
//     // );
//   }
//
//   @override
//   void dispose() {
//     // controller.dispose();
//     super.dispose();
//   }
//
//   InputDecoration getInputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
//       fillColor: AppColors.white,
//       filled: true,
//       contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
//       enabledBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.red, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.red, width: 1.5),
//         borderRadius: BorderRadius.circular(15),
//       ),
//     );
//   }
//
// /*  Widget buildCustomField({
//     required String fieldKey,
//     required TextEditingController controllerField,
//     required String hint,
//     List<TextInputFormatter>? formatters,
//     TextInputType keyboardType = TextInputType.text,
//     bool readOnly = false,
//     VoidCallback? onTap,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 50,
//           child: TextFormField(
//             controller: controllerField,
//             textAlign: TextAlign.center,
//             inputFormatters: formatters,
//             readOnly: readOnly,
//             onTap: onTap,
//             decoration: getInputDecoration(hint).copyWith(
//               errorText: controller.errorTexts[fieldKey],
//             ),
//             style: const TextStyle(fontSize: 13),
//             keyboardType: keyboardType,
//           ),
//         ),
//         const SizedBox(height: 15),
//       ],
//     );
//   }*/
//   Widget buildCustomField({
//     required String fieldKey,
//     required TextEditingController controllerField,
//     required String hint,
//     List<TextInputFormatter>? formatters,
//     TextInputType keyboardType = TextInputType.text,
//     bool readOnly = false,
//     VoidCallback? onTap,
//   }) {
//     final hasError = errorTexts[fieldKey] != null;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 50,
//           child: TextFormField(
//             controller: controllerField,
//             textAlign: TextAlign.center,
//             inputFormatters: formatters,
//             readOnly: readOnly,
//             onTap: onTap,
//             decoration: getInputDecoration(hint).copyWith(
//               // ❌ errorText ko hata diya (yahi shrink cause karta tha)
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: hasError ? AppColors.red : AppColors.greyBorder,
//                   width: 1.5,
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: hasError ? AppColors.red : AppColors.greyBorder,
//                   width: 1.5,
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             style: const TextStyle(fontSize: 13),
//             keyboardType: keyboardType,
//           ),
//         ),
//         // ✅ Fixed height error message (layout jump nahi karega)
//         SizedBox(
//           height: 18,
//           child: hasError
//               ? Text(
//             errorTexts[fieldKey]!,
//             style: const TextStyle(color: AppColors.red, fontSize: 11),
//           )
//               : null,
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
//
//
//   Widget buildLabel(String label) {
//     return Center(
//       child: Text(
//         label,
//         style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//   bool validateForm() {
//     _errorTexts.clear();
//
//     // Validate Name
//     if (nameController.text.trim().isEmpty) {
//       _errorTexts['name'] = 'Please enter your full name.';
//     } else if (nameController.text.trim().length < 3) {
//       _errorTexts['name'] = 'Full name must be at least 3 characters long.';
//     }
//
//     // Validate Role
//     if (roleController.text.isEmpty) {
//       _errorTexts['role'] = 'Please select a role.';
//     }
//
//     // Validate Referral Code (optional)
//     final referral = referralController.text.trim();
//     if (referral.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(referral)) {
//       _errorTexts['referral'] = 'Referral code can only contain letters and numbers.';
//     }
//
//     debugPrint("🔍 Validation Errors: $_errorTexts");
//     return _errorTexts.isEmpty;
//   }
//   void onSubmit() async {
//     final isValid = validateForm();
//     if (!isValid) {
//       setState(() {}); // Refresh UI to show error messagesScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please fill in all required fields correctly.'),
//         duration: Duration(seconds: 2),
//       );
//       return;
//     }
//
//     // Call submitUserProfile from controller
//     final result = await submitUserProfile(context);
//     if (mounted) {
//       if (result['success']) {
//         // Navigate to AddressDetailScreen after successful profile update
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => AddressDetailScreen(
//               name: ,
//               initialAddress: null, // Pass if available
//               initialLocation: null, // Pass if available
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message']),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.green,
//         elevation: 0,
//         toolbarHeight: 10,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(Icons.arrow_back_outlined, size: 22),
//                   ),
//                   const SizedBox(width: 60),
//                   Text(
//                     'Complete Profile',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 50),
//               buildLabel("Enter Your Name"),
//               const SizedBox(height: 5),
//               buildCustomField(
//                 fieldKey: 'name',
//                 controllerField: nameController,
//                 hint: 'Enter Your Name',
//                 formatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]+")),
//                   LengthLimitingTextInputFormatter(20),
//                 ],
//               ),
//               buildLabel('Referral Code (Optional)'),
//               const SizedBox(height: 5),
//               buildCustomField(
//                 fieldKey: 'referral',
//                 controllerField: referralController,
//                 hint: 'Enter Referral Code',
//                 formatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]+')),
//                   LengthLimitingTextInputFormatter(15),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               CustomButton(label: 'Submit', onPressed: onSubmit),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widgets/AppColors.dart';
import '../../Widgets/Bottombar.dart';
import '../../Widgets/CustomButton.dart';
import '../../controllers/authController/UserDetailsController.dart';
import '../../models/RoleModel.dart';
import 'AddressDetailScreen.dart';
import 'RoleSelectionScreen.dart';

class UserDetailFormScreen extends StatefulWidget {
  final String role;

  const UserDetailFormScreen({super.key, required this.role});

  @override
  State<UserDetailFormScreen> createState() => _UserDetailFormScreenState();
}

class _UserDetailFormScreenState extends State<UserDetailFormScreen> {
  late final RoleModel model;
  // late final UserDetailsController controller;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  @override
  void initState() {
    super.initState();
    model = RoleModel();
    // controller = UserDetailsController();
    // controller.setRole(widget.role);
    model.selectedRole = widget.role;
    // debugPrint(
    //   "🔧 Initial Role: ${widget.role}, Controller Role: ${controller.roleController.text}",
    // );
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  InputDecoration getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
      fillColor: AppColors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }


  Widget buildCustomField({
    required String fieldKey,
    required TextEditingController controllerField,
    required String hint,
    List<TextInputFormatter>? formatters,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final hasError = errorTexts[fieldKey] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: controllerField,
            textAlign: TextAlign.center,
            inputFormatters: formatters,
            readOnly: readOnly,
            onTap: onTap,
            decoration: getInputDecoration(hint).copyWith(
              // ❌ errorText ko hata diya (yahi shrink cause karta tha)
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? AppColors.red : AppColors.greyBorder,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? AppColors.red : AppColors.greyBorder,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: keyboardType,
          ),
        ),
        // ✅ Fixed height error message (layout jump nahi karega)
        SizedBox(
          height: 18,
          child: hasError
              ? Text(
            errorTexts[fieldKey]!,
            style: const TextStyle(color: AppColors.red, fontSize: 11),
          )
              : null,
        ),
        const SizedBox(height: 10),
      ],
    );
  }


  Widget buildLabel(String label) {
    return Center(
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
  bool validateForm() {
    _errorTexts.clear();

    // Validate Name
    if (nameController.text.trim().isEmpty) {
      _errorTexts['name'] = 'Please enter your full name.';
    } else if (nameController.text.trim().length < 3) {
      _errorTexts['name'] = 'Full name must be at least 3 characters long.';
    }

    // Validate Role
    if (roleController.text.isEmpty) {
      _errorTexts['role'] = 'Please select a role.';
    }

    // Validate Referral Code (optional)
    final referral = referralController.text.trim();
    if (referral.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(referral)) {
      _errorTexts['referral'] = 'Referral code can only contain letters and numbers.';
    }

    debugPrint("🔍 Validation Errors: $_errorTexts");
    return _errorTexts.isEmpty;
  }
  void onSubmit() async {
    final isValid = validateForm();
    if (!isValid) {
      setState(() {}); // Refresh UI to show error messagesScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in all required fields correctly.'),
        duration: Duration(seconds: 2),
      );
      return;
    }

    // Call submitUserProfile from controller
    final result = await submitUserProfile(context);
    if (mounted) {
      if (result['success']) {
        // Navigate to AddressDetailScreen after successful profile update
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddressDetailScreen(
              name: nameController.text,
              refralCode: referralController.text,
              role: widget.role,
              initialAddress: null, // Pass if available
              initialLocation: null, // Pass if available
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        toolbarHeight: 10,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_outlined, size: 22),
                  ),
                  const SizedBox(width: 60),
                  Text(
                    'Complete Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              buildLabel("Enter Your Name"),
              const SizedBox(height: 5),
              buildCustomField(
                fieldKey: 'name',
                controllerField: nameController,
                hint: 'Enter Your Name',
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]+")),
                  LengthLimitingTextInputFormatter(20),
                ],
              ),
              buildLabel('Referral Code (Optional)'),
              const SizedBox(height: 5),
              buildCustomField(
                fieldKey: 'referral',
                controllerField: referralController,
                hint: 'Enter Referral Code',
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]+')),
                  LengthLimitingTextInputFormatter(15),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(label: 'Submit', onPressed: onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/CustomButton.dart';
import '../../models/RoleModel.dart';
import 'AddressDetailScreen.dart';


class UserDetailFormScreen extends StatefulWidget {
  final String role;

  const UserDetailFormScreen({super.key, required this.role});

  @override
  State<UserDetailFormScreen> createState() => _UserDetailFormScreenState();
}

class _UserDetailFormScreenState extends State<UserDetailFormScreen> {
  late final RoleModel model;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final Map<String, String> _errorTexts = {}; // Added missing errorTexts map

  @override
  void initState() {
    super.initState();
    model = RoleModel();

    model.selectedRole = widget.role;
    roleController.text = widget.role; // Set role in controller
    debugPrint("🔧 Initial Role: ${widget.role}");
  }

  @override
  void dispose() {
    nameController.dispose();
    referralController.dispose();
    roleController.dispose();
    super.dispose();
  }

  InputDecoration getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B)),
      fillColor: AppColors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget buildCustomField({
    required String fieldKey,
    required TextEditingController controllerField,
    required String hint,
    List<TextInputFormatter>? formatters,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final hasError = _errorTexts[fieldKey] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: controllerField,
            textAlign: TextAlign.center,
            inputFormatters: formatters,
            readOnly: readOnly,
            onTap: onTap,
            decoration: getInputDecoration(hint).copyWith(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? AppColors.red : AppColors.greyBorder,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? AppColors.red : AppColors.greyBorder,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: keyboardType,
          ),
        ),
        SizedBox(
          height: 18,
          child: hasError
              ? Text(
            _errorTexts[fieldKey]!,
            style: const TextStyle(color: AppColors.red, fontSize: 11),
          )
              : null,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildLabel(String label) {
    return Center(
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  bool validateForm() {
    _errorTexts.clear();

    // Validate Name
    if (nameController.text.trim().isEmpty) {
      _errorTexts['name'] = 'Please enter your full name.';
    } else if (nameController.text.trim().length < 3) {
      _errorTexts['name'] = 'Full name must be at least 3 characters long.';
    }

    // Validate Role
    if (roleController.text.isEmpty) {
      _errorTexts['role'] = 'Please select a role.';
    }

    // Validate Referral Code (optional)
    final referral = referralController.text.trim();
    if (referral.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(referral)) {
      _errorTexts['referral'] = 'Referral code can only contain letters and numbers.';
    }

    debugPrint("🔍 Validation Errors: $_errorTexts");
    return _errorTexts.isEmpty;
  }


  void onSubmit() async {
    if (!validateForm()) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // final result = await submitUserProfile(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressDetailScreen(
          name: nameController.text,
          refralCode: referralController.text,
          role: widget.role,
          initialAddress: null,
          initialLocation: null,
        ),
      ),
    );


    // if (mounted) {
    //   if (result['success']) {
    //
    //   } else {
    //     // ScaffoldMessenger.of(context).showSnackBar(
    //     //   SnackBar(
    //     //     content: Text(result['message']),
    //     //     duration: const Duration(seconds: 2),
    //     //   ),
    //     // );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        toolbarHeight: 10,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_outlined, size: 22),
                  ),
                  const SizedBox(width: 60),
                  Text(
                    'Complete Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              buildLabel("Enter Your Name"),
              const SizedBox(height: 5),
              buildCustomField(
                fieldKey: 'name',
                controllerField: nameController,
                hint: 'Enter Your Name',
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]+")),
                  LengthLimitingTextInputFormatter(20),
                ],
              ),
              buildLabel('Referral Code (Optional)'),
              const SizedBox(height: 5),
              buildCustomField(
                fieldKey: 'referral',
                controllerField: referralController,
                hint: 'Enter Referral Code',
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]+')),
                  LengthLimitingTextInputFormatter(15),
                ],
              ),
              // buildLabel('Selected Role'),
              // const SizedBox(height: 5),
              // buildCustomField(
              //   fieldKey: 'role',
              //   controllerField: roleController,
              //   hint: 'Selected Role',
              //   readOnly: true,
              // ),
              const SizedBox(height: 20),
              CustomButton(label: 'Submit', onPressed: onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}