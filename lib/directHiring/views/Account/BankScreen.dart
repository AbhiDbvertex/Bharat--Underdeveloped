import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Widgets/AppColors.dart';
import '../../controllers/AccountController/BankController.dart';
import 'AccountScreen.dart';

enum InputType { text, number, ifsc }

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final BankController controller = BankController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Bank Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 30),
                // Row(
                //   children: [
                //     GestureDetector(
                //       onTap:
                //           () => Navigator.pop(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => const AccountScreen(),
                //             ),
                //           ),
                //       child: const Icon(Icons.arrow_back_outlined),
                //     ),
                //     const SizedBox(width: 90),
                //     Text(
                //       "Bank Details",
                //       style: GoogleFonts.roboto(
                //         fontSize: 19,
                //         color: Colors.black,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Add your bank details",
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                _buildInputField(
                  "Enter Bank Name",
                  "Bank Name",
                  controller.bankNameController,
                  InputType.text,
                ),
                _buildInputField(
                  "Enter Account Number",
                  "Account Number",
                  controller.accountNumberController,
                  InputType.number,
                ),
                _buildInputField(
                  "Enter Account Holder Name",
                  "Account Holder Name",
                  controller.accountHolderNameController,
                  InputType.text,
                ),
                _buildInputField(
                  "Enter IFSC Code",
                  "Enter IFSC Code",
                  controller.ifscCodeController,
                  InputType.ifsc,
                ),
                _buildInputField(
                  "Enter UPI Id",
                  "UPI Id",
                  controller.upiIdController,
                  InputType.text,
                ),

                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 310,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => controller.submitBankDetails(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Add",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildInputField(
      String hint,
      String label,
      TextEditingController inputController,
      InputType type,
      ) {
    List<TextInputFormatter> formatters = [];
    TextInputType keyboardType = TextInputType.text;

    switch (type) {
      case InputType.text:
        keyboardType = TextInputType.name;
        // user name max 20 char
        formatters = [LengthLimitingTextInputFormatter(20)];
        break;

      case InputType.number:
        keyboardType = TextInputType.number;
        // account number max 18 digit
        formatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(18),
        ];
        break;

      case InputType.ifsc:
        keyboardType = TextInputType.text;
        // IFSC usually 11 character hota hai
        formatters = [LengthLimitingTextInputFormatter(11)];
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: 340,
        child: TextFormField(
          controller: inputController,
          inputFormatters: formatters,
          keyboardType: keyboardType,
          textCapitalization:
          type == InputType.ifsc
              ? TextCapitalization.characters
              : TextCapitalization.words,
          decoration: _inputDecoration(hint,label),
          validator: (value) => controller.validateField(label, value),
        ),
      ),
    );
  }


  InputDecoration _inputDecoration(String hint,String label) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
