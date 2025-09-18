// import 'package:developer/Widgets/CustomButton.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
// import '../../Widgets/Bottombar.dart';
// import 'UserDetailFormScreen.dart';
//
// class RoleSelectionScreen extends StatefulWidget {
//   const RoleSelectionScreen({super.key});
//
//   @override
//   State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
// }
//
// class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
//   String selectedRole = 'user'; // Default selected role
//
//   // Map role label (UI) to actual backend values
//   static const roleMap = {'User': 'user', 'Business': 'service_provider'};
//
//   // ✅ Store selected role to SharedPreferences
//   Future<void> _saveSelectedRole(String role) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('role', role);
//     print("🔐 Role saved to prefs: $role");
//   }
//
//   Widget buildRole(BuildContext context, String label, String asset) {
//     final isSelected = selectedRole == roleMap[label];
//
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedRole = roleMap[label]!;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Column(
//             children: [
//               const SizedBox(height: 30),
//               Stack(
//                 children: [
//                   Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color:
//                             isSelected
//                                 ? AppColors.primaryGreen
//                                 : Colors.grey.shade400,
//                         width: 4,
//                       ),
//                     ),
//                     child: ClipOval(
//                       child: Image.asset(asset, fit: BoxFit.cover),
//                     ),
//                   ),
//                   if (isSelected)
//                     Positioned(
//                       bottom: 10,
//                       right: 10,
//                       child: Container(
//                         width: 25,
//                         height: 25,
//                         decoration: const BoxDecoration(
//                           color: AppColors.primaryGreen,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.check,
//                           size: 15,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 label,
//                 style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.bold,
//                   color: isSelected ? AppColors.green : AppColors.black87,
//                   fontSize: 18,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// ✅ Check if profile is already complete, then go to right screen
//   Future<void> navigateToForm(BuildContext context) async {
//     await _saveSelectedRole(selectedRole);
//
//     final prefs = await SharedPreferences.getInstance();
//     final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
//
//     if (isProfileComplete) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => Bottombar() /*UserHomeScreen()*/),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => UserDetailFormScreen(role: selectedRole),
//         ),
//       );
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
//         centerTitle: true,
//         toolbarHeight: 10,
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Text(
//               'Select your Role',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 children: [
//                   Text(
//                     'Please choose whether you are a Worker or a',
//                     style: GoogleFonts.roboto(
//                       fontSize: 14,
//                       color: Color(0xFF777777),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   Text(
//                     'User to proceed',
//                     style: GoogleFonts.roboto(
//                       fontSize: 14,
//                       color: AppColors.greyText,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               height: 260,
//               color: AppColors.backgroundLight,
//               child: Row(
//                 children: [
//                   buildRole(context, 'User', 'assets/images/Customer.png'),
//                   buildRole(context, 'Business', 'assets/images/Business.png'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             CustomButton(
//               onPressed: () => navigateToForm(context),
//               label: 'Continue',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class GetXRoleController extends GetxController {
//   // Reactive role variable
//   final RxString role = ''.obs;
//   // final RxString role = 'user'.obs;
//   final RxString categoryId = 'default_category_id'.obs;
//   final RxString subCategoryId = 'default_sub_category_id'.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadRole(); // Load role on initialization
//   }
//
//   // Load role from SharedPreferences
//   Future<void> loadRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     role.value = prefs.getString('role') ?? 'user';
//     categoryId.value = prefs.getString('category_id') ?? 'default_category_id';
//     subCategoryId.value = prefs.getString('sub_category_id') ?? 'default_sub_category_id';
//     print("Abhi:- Loaded role: ${role.value}, Category: ${categoryId.value}, SubCategory: ${subCategoryId.value}");
//   }
//
//   // Update role and save to SharedPreferences
//   Future<void> updateRole(String newRole) async {
//     role.value = newRole;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('role', newRole);
//     print("Abhi:- Role updated to: $newRole");
//   }
//
//   // Optionally update category and subcategory
//   Future<void> updateCategoryAndSubCategory(String catId, String subCatId) async {
//     categoryId.value = catId;
//     subCategoryId.value = subCatId;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('category_id', catId);
//     await prefs.setString('sub_category_id', subCatId);
//     print("Abhi:- Category updated to: $catId, SubCategory: $subCatId");
//   }
// }

                   ///     upar vala code allmost sahi hai

import 'dart:async';

import 'package:developer/Widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/Bottombar.dart';
import '../../../utility/custom_snack_bar.dart';
import 'UserDetailFormScreen.dart';

/*class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'user'; // Default selected role

  // Map role label (UI) to actual backend values
  static const roleMap = {'User': 'user', 'Business': 'service_provider'};

  // ✅ Store selected role to SharedPreferences
  Future<void> _saveSelectedRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    print("🔐 Role saved to prefs: $role");
  }

  Widget buildRole(BuildContext context, String label, String asset) {
    final isSelected = selectedRole == roleMap[label];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = roleMap[label]!;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                        isSelected
                            ? AppColors.primaryGreen
                            : Colors.grey.shade400,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(asset, fit: BoxFit.cover),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.green : AppColors.black87,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Check if profile is already complete, then go to right screen
  Future<void> navigateToForm(BuildContext context) async {
    await _saveSelectedRole(selectedRole);

    final prefs = await SharedPreferences.getInstance();
    final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;

    if (isProfileComplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Bottombar() *//*UserHomeScreen()*//*),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserDetailFormScreen(role: selectedRole),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Select your Role',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Please choose whether you are a Worker or a',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Color(0xFF777777),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'User to proceed',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AppColors.greyText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 260,
              color: AppColors.backgroundLight,
              child: Row(
                children: [
                  buildRole(context, 'User', 'assets/images/Customer.png'),
                  buildRole(context, 'Business', 'assets/images/Business.png'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () => navigateToForm(context),
              label: 'Continue',
            ),
          ],
        ),
      ),
    );
  }
}*/

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = ''; // Default khali rakho
  final GetXRoleController roleController = Get.find<GetXRoleController>();

  static const roleMap = {'User': 'user', 'Business': 'service_provider'};

  // Store selected role to SharedPreferences
  Future<void> _saveSelectedRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    roleController.role.value = role; // Sync with GetX controller
    print("🔐 Role saved to prefs: $role");
  }

  Widget buildRole(BuildContext context, String label, String asset) {
    final isSelected = selectedRole == roleMap[label];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = roleMap[label]!;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : Colors.grey.shade400,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(asset, fit: BoxFit.cover),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.green : AppColors.black87,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> navigateToForm(BuildContext context) async {
    if (selectedRole.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please select a role')),
      // );
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
      CustomSnackBar.show(
          context,
          message: "Please select a role.",
          type: SnackBarType.warning
      );
        }
      });
      return;
    }

    await _saveSelectedRole(selectedRole);

    final prefs = await SharedPreferences.getInstance();
    final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;

    if (isProfileComplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Bottombar()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserDetailFormScreen(role: selectedRole),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Select your Role",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: SizedBox(),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Text(
            //   'Select your Role',
            //   style: GoogleFonts.poppins(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Please choose whether you are a Worker or a',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Color(0xFF777777),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'User to proceed',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AppColors.greyText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 260,
              color: AppColors.backgroundLight,
              child: Row(
                children: [
                  buildRole(context, 'User', 'assets/images/Customer.png'),
                  buildRole(context, 'Business', 'assets/images/Business.png'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () => navigateToForm(context),
              label: 'Continue',
            ),
          ],
        ),
      ),
    );
  }
}

class GetXRoleController extends GetxController {
  final RxString role = ''.obs;
  final RxString categoryId = 'default_category_id'.obs;
  final RxString subCategoryId = 'default_sub_category_id'.obs;
  final RxBool isRoleLoading = true.obs;
  final RxBool isRoleSwitching = false.obs; // 👈 GetX reactive bool, Obx se sync hoga
  Timer? _debounce;
  @override
  void onInit() {
    super.onInit();
    loadRole();
  }

  Future<void> loadRole() async {
    isRoleLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    String? savedRole = prefs.getString('role');
    if (savedRole != null && savedRole.isNotEmpty) {
      role.value = savedRole;
    } else {
      role.value = ''; // Empty rakho jab tak explicit role na set ho
    }
    categoryId.value = prefs.getString('category_id') ?? 'default_category_id';
    subCategoryId.value = prefs.getString('sub_category_id') ?? 'default_sub_category_id';
    isRoleLoading.value = false;
    print("Abhi:- Loaded role: ${role.value}, Category: ${categoryId.value}, SubCategory: ${subCategoryId.value}");
  }

  Future<void> updateRole(String newRole) async {
    if (newRole.isNotEmpty && role.value != newRole) {
      role.value = newRole;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', newRole);
      print("Abhi:- Role updated to: $newRole");
    }
  }

  Future<void> setRoleFromOtp(String newRole) async {
    if (newRole.isNotEmpty) {
      role.value = newRole;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', newRole);
      isRoleLoading.value = false; // Loader band karo
      print("Abhi:- Role set from OTP: $newRole");
    }
  }

  Future<void> updateCategoryAndSubCategory(String catId, String subCatId) async {
    categoryId.value = catId;
    subCategoryId.value = subCatId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('category_id', catId);
    await prefs.setString('sub_category_id', subCatId);
    print("Abhi:- Category updated to: $catId, SubCategory: $subCatId");
  }
}
