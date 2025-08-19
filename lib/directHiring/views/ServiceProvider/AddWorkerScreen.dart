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
//
//   @override
//   void initState() {
//     super.initState();
//     // Set today's date for Date of Joining field on initialization
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
//   OutlineInputBorder _customBorder() {
//     return OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: Colors.grey, width: 1),
//     );
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
//                           color: Colors.grey.shade400,
//                           width: 2,
//                         ),
//                       ),
//                       child: ClipOval(
//                         child:
//                         controller.selectedImage != null
//                             ? Image.file(
//                           controller.selectedImage!,
//                           fit: BoxFit.cover,
//                         )
//                             : Image.asset(
//                           'assets/images/vhaccoy1.png',
//                           fit: BoxFit.cover,
//                         ),
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
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(controller.nameController, 'Name', (value) {
//                 if (value!.trim().isEmpty) return 'Name is required';
//                 return null;
//               }),
//               IntlPhoneField(
//                 decoration: InputDecoration(
//                   hintText: 'Phone Number',
//                   border: _customBorder(),
//                   enabledBorder: _customBorder(),
//                   focusedBorder: _customBorder(),
//                 ),
//                 initialCountryCode: 'IN',
//                 disableLengthCheck: true,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(10),
//                 ],
//                 onChanged: (phone) => controller.phone = phone.number,
//                 validator: (phone) {
//                   final number = phone?.number ?? '';
//                   if (number.trim().isEmpty) return 'Phone number is required';
//                   if (!RegExp(r'^\d{10}$').hasMatch(number)) {
//                     return 'Enter 10-digit phone number';
//                   }
//                   return null;
//                 },
//               ),
//               _buildTextField(
//                 controller.aadhaarController,
//                 'Aadhaar Number',
//                     (value) {
//                   if (value!.isEmpty) return 'Aadhaar required';
//                   if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//                     return 'Must be 12 digits';
//                   }
//                   return null;
//                 },
//                 TextInputType.number,
//                 [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(12),
//                 ],
//               ),
//               // DOB TextFormField
//               _buildDateField(
//                 controller.dobController,
//                 'Date of Birth (YYYY-MM-DD)',
//                 'DOB required',
//               ),
//               _buildTextField(
//                 controller.addressController,
//                 'Address',
//                     (value) => value!.isEmpty ? 'Address required' : null,
//               ),
//               // Date of Joining TextFormField
//               _buildDateField(
//                 controller.dojController,
//                 'Date of Joining (YYYY-MM-DD)',
//                 'Date of Joining required',
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 height: 50,
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (controller.validateInputs()) {
//                       final success = await controller.submitWorkerToAPI(
//                         context,
//                       );
//                       if (success) {
//                         Navigator.pop(context, true); // For refresh
//                       }
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade700,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
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
//
//   Widget _buildTextField(
//       TextEditingController controller,
//       String hint,
//       String? Function(String?) validator, [
//         TextInputType type = TextInputType.text,
//         List<TextInputFormatter>? inputFormatters,
//       ]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: type,
//         validator: validator,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//           border: _customBorder(),
//           enabledBorder: _customBorder(),
//           focusedBorder: _customBorder(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDateField(
//       TextEditingController controller,
//       String hint,
//       String errorMessage,
//       ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: TextInputType.datetime,
//         validator: (value) {
//           if (value!.isEmpty) return errorMessage;
//           if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
//             return 'Enter valid date (YYYY-MM-DD)';
//           }
//           try {
//             final date = DateTime.parse(value);
//             final now = DateTime.now();
//             final earliest = DateTime(1900);
//             if (date.isAfter(now) || date.isBefore(earliest)) {
//               return 'Date out of range';
//             }
//           } catch (e) {
//             return 'Invalid date format';
//           }
//           return null;
//         },
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
//           LengthLimitingTextInputFormatter(10), // YYYY-MM-DD
//         ],
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
//           border: _customBorder(),
//           enabledBorder: _customBorder(),
//           focusedBorder: _customBorder(),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.calendar_today, color: Colors.grey),
//             onPressed: () => _selectDate(controller),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
    if (value == null || value.isEmpty) return 'Enter Date!';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return 'Date format galat hai, YYYY-MM-DD daal';
    }
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      final earliest = DateTime(1900);
      if (date.isAfter(now)) return 'future date accept';
      if (date.isBefore(earliest)) return 'Not use old date';
      final formatted =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (formatted != value) return 'Please check date';
      return null;
    } catch (e) {
      return 'Please currect Date format';
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
          suffixIcon:
          isDateField
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
                        child:
                        controller.selectedImage != null
                            ? Image.file(
                          controller.selectedImage!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                              _buildPlaceholder(),
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
                          errorBuilder:
                              (context, error, stackTrace) =>
                          const Icon(Icons.edit, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildFormField(
                controller: controller.nameController,
                hint: 'Name',
                validator:
                    (value) => value!.trim().isEmpty ? ' Enter Name' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: IntlPhoneField(
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
                  onChanged: (phone) => controller.phone = phone.number,
                  validator: (phone) {
                    final number = phone?.number ?? '';
                    if (number.trim().isEmpty)
                      return 'Enter your phone  number!';
                    if (!RegExp(r'^\d{10}$').hasMatch(number)) {
                      return 'Please enter 10 digit number';
                    }
                    return null;
                  },
                ),
              ),
              _buildFormField(
                controller: controller.aadhaarController,
                hint: 'Aadhaar Number',
                validator: (value) {
                  if (value!.isEmpty) return ' Enter Aadhaar number ';
                  if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
                    return '12 digit  Aadhaar  Number';
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
                controller: controller.addressController,
                hint: 'Address',
                validator: (value) => value!.isEmpty ? ' Enter Address!' : null,
              ),
              _buildFormField(
                controller: controller.dojController,
                hint: 'Date of Joining (YYYY-MM-DD)',
                validator: _validateDate,
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  DateInputFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                isDateField: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  _isSubmitting
                      ? null
                      : () async {
                    if (controller.validateInputs()) {
                      setState(() => _isSubmitting = true);
                      final success = await controller
                          .submitWorkerToAPI(context);
                      setState(() => _isSubmitting = false);
                      if (success) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                  _isSubmitting
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
        formatted +=
            '-' + text.substring(4, text.length >= 6 ? 6 : text.length);
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