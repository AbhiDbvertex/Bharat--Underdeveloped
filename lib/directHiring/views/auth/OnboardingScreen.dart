import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Widgets/AppColors.dart';
import '../../controllers/authController/OnboardingController.dart';
import 'LoginScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingController controller;

  @override
  void initState() {
    super.initState();
    controller = OnboardingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: controller.model.images.length,
              onPageChanged: (index) {
                setState(() {
                  controller.onPageChanged(index);
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (index < controller.model.images.length - 1) {
                      controller.nextSlide(context);
                    } else {
                      controller.goToLogin(context);
                    }
                  },
                  child: Image.asset(
                    controller.model.images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
              physics: const BouncingScrollPhysics(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.grey800,
                    AppColors.black,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.model.headings[controller.currentIndex],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.model.subtexts[controller.currentIndex],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      controller.model.subtextsLine2[controller.currentIndex],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(controller.model.images.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: controller.currentIndex == index ? 24 : 12,
                          height: 6,
                          decoration: BoxDecoration(
                            color: controller.currentIndex == index
                                ? AppColors.white
                                : AppColors.white30,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        splashColor: AppColors.white30,
                        onTap: () => controller.nextSlide(context),
                        onTapDown: (_) => setState(() => controller.buttonScale = 0.95),
                        onTapUp: (_) => setState(() => controller.buttonScale = 1.0),
                        onTapCancel: () => setState(() => controller.buttonScale = 1.0),
                        child: AnimatedScale(
                          scale: controller.buttonScale,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 12),
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
