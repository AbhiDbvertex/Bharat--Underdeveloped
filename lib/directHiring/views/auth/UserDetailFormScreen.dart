import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/CustomButton.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../models/RoleModel.dart';
import 'AddressDetailScreen.dart';
import 'Signup_Address_Detail_Screen.dart';

class UserDetailFormScreen extends StatefulWidget {
  final String role;

  const UserDetailFormScreen({super.key, required this.role});

  @override
  State<UserDetailFormScreen> createState() => _UserDetailFormScreenState();
}

class _UserDetailFormScreenState extends State<UserDetailFormScreen> {
  late final RoleModel model;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final Map<String, String> _errorTexts = {};
  String? _selectedGender; // Added for gender selection

  @override
  void initState() {
    super.initState();
    model = RoleModel();
    model.selectedRole = widget.role;
    roleController.text = widget.role;
    debugPrint("🔧 Initial Role: ${widget.role}");
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
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
            textCapitalization: TextCapitalization.words,
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

  Widget buildGenderRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel("Select Your Gender"),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: 'male',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _errorTexts.remove('gender');
                });
              },
            ),
            const Text('Male'),
            Radio<String>(
              value: 'female',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _errorTexts.remove('gender');
                });
              },
            ),
            const Text('Female'),
            Radio<String>(
              value: 'other',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _errorTexts.remove('gender');
                });
              },
            ),
            const Text('Other'),
          ],
        ),
        SizedBox(
          height: 18,
          child: _errorTexts['gender'] != null
              ? Text(
            _errorTexts['gender']!,
            style: const TextStyle(color: AppColors.red, fontSize: 11),
          )
              : null,
        ),
        const SizedBox(height: 10),
      ],
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

    // Validate Age
    if (ageController.text.trim().isEmpty) {
      _errorTexts['age'] = 'Please enter your age.';
    } else if (int.tryParse(ageController.text.trim()) == null ||
        int.parse(ageController.text.trim()) <18) {
      _errorTexts['age'] = 'Age must be at least 18.';
    }

    // Validate Role
    if (roleController.text.isEmpty) {
      _errorTexts['role'] = 'Please select a role.';
    }

    // Validate Gender
    if (_selectedGender == null) {
      _errorTexts['gender'] = 'Please select your gender.';
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please fill in all required fields correctly.'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
      CustomSnackBar.show(
          context,
          message: 'Please fill in all required fields correctly.',
          type: SnackBarType.warning
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupAddressDetailScreen(
          name: nameController.text,
          refralCode: referralController.text,
          role: widget.role,
          gender: _selectedGender, // Pass gender
          age: ageController.text,
          initialAddress: null,
          initialLocation: null,
          dataHide: "hide",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar:  AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Complete Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 10),
              // Row(
              //   children: [
              //     GestureDetector(
              //       onTap: () => Navigator.pop(context),
              //       child: const Icon(Icons.arrow_back_outlined, size: 22),
              //     ),
              //     const SizedBox(width: 60),
              //     Text(
              //       'Complete Profile',
              //       style: GoogleFonts.poppins(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         color: AppColors.black,
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),
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
              buildLabel("Enter Your Age"),
              const SizedBox(height: 5),
              buildCustomField(
                fieldKey: 'age',
                controllerField: ageController,
                keyboardType: TextInputType.number,
                hint: 'Enter Your Age',
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
              buildGenderRadio(), // Added gender radio buttons
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
}