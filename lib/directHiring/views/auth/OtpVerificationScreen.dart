
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/CustomButton.dart';
import '../../../Widgets/CustomLogoWidget.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../controllers/authController/OtpController.dart';
import '../../models/OtpModel.dart';
import 'LoginScreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? receivedOtp; // for testing

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.receivedOtp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  late OtpController controller;
  double _resendScale = 1.0;
  final TextEditingController pinController = TextEditingController();
  String? _testingOtp; // Dynamic OTP for testing
  bool _isResending = false; // Loading state for resend button
  final FocusNode _pinFocusNode =
  FocusNode(); // Focus node for PinCodeTextField

  @override
  void initState() {
    super.initState();
    controller = OtpController(OtpModel(phoneNumber: widget.phoneNumber), this);
    _testingOtp = widget.receivedOtp; // Initialize with received OTP
    if (_testingOtp != null && _testingOtp!.length == 4) {
      controller.updateOtp(_testingOtp!);
    }
  }

  // Callback to refresh UI after resend
  void _refreshUI(String? newOtp) {
    setState(() {
      _testingOtp = newOtp; // Update with new OTP from API
      pinController.clear(); // Clear input field
      _pinFocusNode.requestFocus(); // Request focus to enable input
    });
  }

  // Reset input field after invalid OTP or verify attempt
  void _resetInputField() {
    setState(() {
      pinController.clear(); // Clear input field
      controller.updateOtp(''); // Reset model OTP
      _pinFocusNode.requestFocus(); // Request focus to enable input
    });
  }

  @override
  void dispose() {
    controller.dispose();
    pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safely get last 4 digits
    String lastFourDigits =
    widget.phoneNumber.length >= 4
        ? widget.phoneNumber.substring(widget.phoneNumber.length - 4)
        : widget.phoneNumber;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 10,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const CustomLogoWidget(
                  imagePath: 'assets/images/logo.png',
                  title: 'The Bharat Works',
                ),
                const SizedBox(height: 5),
                Text(
                  'Verify OTP',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Code has been sent to ',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: const Color(0xFF334247),
                        ),
                      ),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // For testing only: show OTP dynamically
                if (_testingOtp != null && _testingOtp!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      "Testing OTP: $_testingOtp",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: pinController,
                  focusNode: _pinFocusNode,
                  obscureText: false,
                  animationType: AnimationType.scale,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 52,
                    fieldWidth: 60,
                    activeFillColor: Colors.green.shade700,
                    selectedFillColor: Colors.green.shade700,
                    inactiveFillColor: Colors.grey.shade300,
                    activeColor: Colors.green.shade700,
                    selectedColor: Colors.green,
                    inactiveColor: Colors.grey.shade300,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: AppColors.white,
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => controller.updateOtp(value),
                ),

                const SizedBox(height: 6),
                Text(
                  "Didn't get OTP Code?",
                  style: GoogleFonts.roboto(fontSize: 13, color: Colors.black),
                ),
                const SizedBox(height: 10),

                GestureDetector(
                  onTapDown:
                  _isResending
                      ? null
                      : (_) => setState(() => _resendScale = 0.9),
                  onTapUp:
                  _isResending
                      ? null
                      : (_) async {
                    setState(() {
                      _resendScale = 1.0;
                      _isResending = true;
                    });
                    print("Resend OTP tapped...");
                    await controller.resendOtp(
                      context,
                      pinController,
                      _refreshUI,
                    );
                    setState(() {
                      _isResending = false;
                    });
                  },
                  onTapCancel:
                  _isResending
                      ? null
                      : () => setState(() => _resendScale = 1.0),
                  child: AnimatedScale(
                    scale: _resendScale,
                    duration: const Duration(milliseconds: 100),
                    child:
                    _isResending
                        ? const CircularProgressIndicator()
                        : Text(
                      "Resend Code",
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
    ValueListenableBuilder<bool>(
    valueListenable: controller.isVerifying,
    builder: (context, isVerifying, _) {
    return   CustomButton(
                  label: "Verify",
                  onPressed: () async {
                    final enteredOtp = pinController.text.trim();

                    if (enteredOtp.length != 4) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text("Please enter the 4-digit OTP"),
                      //     backgroundColor: Colors.black,
                      //   ),
                      // );
                       CustomSnackBar.show(
                      message: "Please enter the 4-digit OTP",
                      type: SnackBarType.error
    );
                      _resetInputField();
                      return;
                    }

                    print(
                      "Submitting OTP: $enteredOtp for phone: ${widget.phoneNumber}",
                    );
                 await   controller.verifyOtp(context).then((_) {
                      _resetInputField();
                    });
                  },
    isLoading: isVerifying,
    enabled: !isVerifying,
    );
    },

                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 4,
            left: 10,
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: AppColors.black,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
