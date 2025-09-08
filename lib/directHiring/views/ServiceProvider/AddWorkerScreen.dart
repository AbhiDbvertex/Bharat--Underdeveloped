//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../controllers/AccountController/AddWorkerController.dart';
//
// class AddWorkerScreen extends StatefulWidget {
//   const AddWorkerScreen({super.key});
//
//   @override
//   State<AddWorkerScreen> createState() => _AddWorkerScreenState();
// }
//
// class _AddWorkerScreenState extends State<AddWorkerScreen> {
//   final controller = AddWorkerController();
//   bool _isSubmitting = false;
//
//   static const _textFieldBorder = OutlineInputBorder(
//     borderRadius: BorderRadius.all(Radius.circular(10)),
//     borderSide: BorderSide(color: Colors.grey, width: 1),
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     controller.dojController.text = _formatTodayDate();
//   }
//
//   String _formatTodayDate() {
//     final now = DateTime.now();
//     return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   void _selectDate(TextEditingController dateController) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         dateController.text =
//         '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
//       });
//     }
//   }
//
//   Widget _buildPlaceholder() {
//     return Container(
//       color: Colors.grey.shade200,
//       child: const Icon(Icons.person, size: 80, color: Colors.grey),
//     );
//   }
//
//   String? _validateDate(String? value) {
//     if (value == null || value.isEmpty) return 'Enter Date!';
//     if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
//       return 'Date format galat hai, YYYY-MM-DD daal';
//     }
//     try {
//       final date = DateTime.parse(value);
//       final now = DateTime.now();
//       final earliest = DateTime(1900);
//
//       if (date.isAfter(now)) return 'future date accept';
//       if (date.isBefore(earliest)) return 'Not use old date';
//       final formatted =
//           '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//       if (formatted != value) return 'Please check date';
//       return null;
//     } catch (e) {
//       return 'Please currect Date format';
//
//     }
//   }
//
//   Widget _buildFormField({
//     required TextEditingController controller,
//     required String hint,
//     required String? Function(String?) validator,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//     bool isDateField = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         validator: validator,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//           border: _textFieldBorder,
//           enabledBorder: _textFieldBorder,
//           focusedBorder: _textFieldBorder,
//           suffixIcon:
//           isDateField
//               ? IconButton(
//             icon: const Icon(Icons.calendar_today, color: Colors.grey),
//             onPressed: () => _selectDate(controller),
//           )
//               : null,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: controller.formKey,
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Padding(
//                       padding: EdgeInsets.only(left: 8.0),
//                       child: Icon(Icons.arrow_back, size: 25),
//                     ),
//                   ),
//                   const SizedBox(width: 70),
//                   Text(
//                     "Add Worker Details",
//                     style: GoogleFonts.roboto(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () => controller.pickImage(() => setState(() {})),
//                 child: Stack(
//                   alignment: Alignment.bottomRight,
//                   children: [
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.green.shade700,
//                           width: 2.7,
//                         ),
//                       ),
//                       child: ClipOval(
//                         child:
//                         controller.selectedImage != null
//                             ? Image.file(
//                           controller.selectedImage!,
//                           fit: BoxFit.cover,
//                           errorBuilder:
//                               (context, error, stackTrace) =>
//                               _buildPlaceholder(),
//                         )
//                             : _buildPlaceholder(),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 4,
//                       right: 4,
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                         ),
//                         padding: const EdgeInsets.all(4),
//                         child: Image.asset(
//                           'assets/images/edit1.png',
//                           width: 24,
//                           height: 24,
//                           errorBuilder:
//                               (context, error, stackTrace) =>
//                           const Icon(Icons.edit, size: 24),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildFormField(
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'[a-z A-Z]')),
//                 ],
//                 controller: controller.nameController,
//                 hint: 'Name',
//                 validator:
//                     (value) => value!.trim().isEmpty ? ' Enter Name' : null,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: IntlPhoneField(
//                   decoration: const InputDecoration(
//                     hintText: 'Phone Number',
//                     hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
//                     border: _textFieldBorder,
//                     enabledBorder: _textFieldBorder,
//                     focusedBorder: _textFieldBorder,
//                   ),
//                   initialCountryCode: 'IN',
//                   disableLengthCheck: true,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(10),
//                   ],
//                   onChanged: (phone) => controller.phone = phone.number,
//                   validator: (phone) {
//                     final number = phone?.number ?? '';
//                     if (number.trim().isEmpty)
//                       return 'Enter your phone  number!';
//                     if (!RegExp(r'^\d{10}$').hasMatch(number)) {
//                       return 'Please enter 10 digit number';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               _buildFormField(
//                 controller: controller.aadhaarController,
//                 hint: 'Aadhaar Number',
//                 validator: (value) {
//                   if (value!.isEmpty) return ' Enter Aadhaar number ';
//                   if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//                     return '12 digit  Aadhaar  Number';
//                   }
//                   return null;
//                 },
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(12),
//                 ],
//               ),
//               _buildFormField(
//                 controller: controller.dobController,
//                 hint: 'Date of Birth (YYYY-MM-DD)',
//                 validator: _validateDate,
//                 keyboardType: TextInputType.datetime,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
//                   DateInputFormatter(),
//                   LengthLimitingTextInputFormatter(10),
//                 ],
//                 isDateField: true,
//               ),
//               _buildFormField(
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'[a-z,/.0-9A-Z]')),
//                 ],
//                 controller: controller.addressController,
//                 hint: 'Address',
//                 validator: (value) => value!.isEmpty ? ' Enter Address!' : null,
//               ),
//               // _buildFormField(
//               //   controller: controller.dojController,
//               //   hint: 'Date of Joining (YYYY-MM-DD)',
//               //   validator: _validateDate,
//               //   keyboardType: TextInputType.datetime,
//               //   inputFormatters: [
//               //     FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
//               //     DateInputFormatter(),
//               //     LengthLimitingTextInputFormatter(10),
//               //   ],
//               //   isDateField: true,
//               // ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 height: 50,
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed:
//                   _isSubmitting
//                       ? null
//                       : () async {
//                     if (controller.validateInputs()) {
//                       setState(() => _isSubmitting = true);
//                       final success = await controller
//                           .submitWorkerToAPI(context);
//                       setState(() => _isSubmitting = false);
//                       if (success) {
//                         Navigator.pop(context, true);
//                       }
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade700,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child:
//                   _isSubmitting
//                       ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation(Colors.white),
//                     ),
//                   )
//                       : const Text(
//                     'Add',
//                     style: TextStyle(fontSize: 15, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class DateInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
//     if (text.length > 8) text = text.substring(0, 8);
//     String formatted = '';
//     if (text.isNotEmpty) {
//       formatted += text.substring(0, text.length >= 4 ? 4 : text.length);
//       if (text.length > 4) {
//         formatted +=
//             '-' + text.substring(4, text.length >= 6 ? 6 : text.length);
//       }
//       if (text.length > 6) {
//         formatted += '-' + text.substring(6);
//       }
//     }
//     return newValue.copyWith(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../Widgets/AppColors.dart';
import '../../controllers/AccountController/AddWorkerController.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final controller = AddWorkerController();
  bool _isSubmitting = false;

  static const _textFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: Colors.grey, width: 1),
  );

  @override
  void initState() {
    super.initState();
    controller.dojController.text = _formatTodayDate();
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _selectDate(TextEditingController dateController) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateController.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 80, color: Colors.grey),
    );
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a date!';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return 'Date format should be YYYY-MM-DD';
    }
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      final earliest = DateTime(1900);

      if (date.isAfter(now)) return 'Future dates are not allowed';
      if (date.isBefore(earliest)) return 'Date is too old';
      final formatted =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (formatted != value) return 'Invalid date format';
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isDateField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          border: _textFieldBorder,
          enabledBorder: _textFieldBorder,
          focusedBorder: _textFieldBorder,
          suffixIcon: isDateField
              ? IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.grey),
            onPressed: () => _selectDate(controller),
          )
              : null,
        ),
      ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.arrow_back, size: 25),
                    ),
                  ),
                  const SizedBox(width: 70),
                  Text(
                    "Add Worker Details",
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
                onTap: () => controller.pickImage(() => setState(() {})),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade700,
                          width: 2.7,
                        ),
                      ),
                      child: ClipOval(
                        child: controller.selectedImage != null
                            ? Image.file(
                          controller.selectedImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                            : _buildPlaceholder(),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/edit1.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.edit, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z A-Z]')),
                ],
                controller: controller.nameController,
                hint: 'Name',
                validator: (value) => value!.trim().isEmpty ? 'Please enter a name' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: IntlPhoneField(
                  controller: controller.phoneController, // New controller for phone
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    border: _textFieldBorder,
                    enabledBorder: _textFieldBorder,
                    focusedBorder: _textFieldBorder,
                  ),
                  initialCountryCode: 'IN',
                  disableLengthCheck: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (phone) {
                    controller.phone = phone.number;
                    // Trigger validation on change
                    if (controller.formKey.currentState != null) {
                      controller.formKey.currentState!.validate();
                    }
                  },
                  validator: (phone) {
                    final number = phone?.number ?? '';
                    if (number.trim().isEmpty) {
                      return 'Please enter a phone number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(number)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
              ),
              _buildFormField(
                controller: controller.aadhaarController,
                hint: 'Aadhaar Number',
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter Aadhaar number';
                  if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
                    return 'Please enter a valid 12-digit Aadhaar number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              _buildFormField(
                controller: controller.dobController,
                hint: 'Date of Birth (YYYY-MM-DD)',
                validator: _validateDate,
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  DateInputFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                isDateField: true,
              ),
              _buildFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z,/.0-9A-Z]')),
                ],
                controller: controller.addressController,
                hint: 'Address',
                validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
              ),
              // Aadhaar Upload Button
              // const SizedBox(height: 16),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     "Upload Aadhaar Card",
              //     style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
              //   ),
              // ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Aadhaar Card"),
                onPressed: () {
                  controller.pickAadhaarImages(context, () => setState(() {}));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

// Selected Aadhaar Images
              if (controller.aadhaarImages.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(controller.aadhaarImages.length, (index) {
                    final file = controller.aadhaarImages[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(file.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              controller.removeAadhaarImage(index, () => setState(() {}));
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                    setState(() => _isSubmitting = true);
                    if (controller.validateInputs()) {
                      final success = await controller.submitWorkerToAPI(context);
                      if (success) {
                        Navigator.pop(context, true);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please file all required filed")),
                      );
                    }
                    setState(() => _isSubmitting = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'Add',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) text = text.substring(0, 8);
    String formatted = '';
    if (text.isNotEmpty) {
      formatted += text.substring(0, text.length >= 4 ? 4 : text.length);
      if (text.length > 4) {
        formatted += '-' + text.substring(4, text.length >= 6 ? 6 : text.length);
      }
      if (text.length > 6) {
        formatted += '-' + text.substring(6);
      }
    }
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}