import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/CustomButton.dart';
import '../../../Widgets/CustomLogoWidget.dart';
import '../../controllers/authController/LoginController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController(TextEditingController());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        CustomLogoWidget(
                          imagePath: 'assets/images/logo.png',
                          title: 'The Bharat Works',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enter Your Mobile Number',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: controller.focusNode.hasFocus
                                  ? AppColors.primaryGreen
                                  : AppColors.lightGrey,
                              width: controller.focusNode.hasFocus ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/images/flag.png', width: 24, height: 24),
                              const SizedBox(width: 8),
                              Text(
                                '+91',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: TextField(
                                  controller: controller.phoneController,
                                  focusNode: controller.focusNode,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    hintText: 'Mobile Number',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // CustomButton(
                        //   label: 'Send OTP',
                        //   onPressed: () => controller.login(context),
                        // ),
                        ValueListenableBuilder<bool>(
                          valueListenable: controller.isLoading,
                          builder: (context, isLoading, _) {
                            return CustomButton(
                              label: 'Send OTP',
                              onPressed: () async {
                                controller.login(context);
                                if(!mounted)return;

                              },
                              isLoading: isLoading,
                              enabled: !isLoading,
                            );
                          },
                        )

                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
