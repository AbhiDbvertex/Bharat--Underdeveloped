//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:developer/directHiring/views/Account/user_profile/user_role_profile_update.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../auth/RoleSelectionScreen.dart';
// import '../service_provider_profile/EditProfileScreen.dart';
// import '../service_provider_profile/ServiceProviderProfileScreen.dart';
// import '../user_profile/UserProfileScreen.dart';
// import '../user_profile/both_profile_screen.dart';
//
// class FirstTimeServiceProviderProfileScreen extends StatefulWidget {
//   final swithcrole;
//   const FirstTimeServiceProviderProfileScreen({super.key, this.swithcrole});
//
//   @override
//   State<FirstTimeServiceProviderProfileScreen> createState() => _FirstTimeServiceProviderProfileScreenState();
// }
//
// class _FirstTimeServiceProviderProfileScreenState extends State<FirstTimeServiceProviderProfileScreen> {
//   File? _image;
//   String selectedRole = '';
//   String? profilePicUrl;
//   String? fullName = 'Your Name';
//   String? age = 'Your age';
//   String? gender = 'Your gender';
//   String? requestStatus;
//   String? verifiedSataus;
//   String? role = 'No role';
//   String? category_name = 'No role';
//   String? rejectionReason = 'No role';
//   String? aboutUs = '';
//   String? phone;
//   String? selectedGender;
//   late TextEditingController aboutController;
//   final GetXRoleController roleController = Get.put(GetXRoleController()); // Updated to GetXRoleController
//   @override
//   void initState() {
//     super.initState();
//     aboutController = TextEditingController();
//     _fetchProfileFromAPI();
//     _loadSelectedRole();
//     _initializeWithChecks();  // Naya function call karenge yahan
//   }
//   Future<void> _loadSelectedRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedRole = prefs.getString('role') ?? 'user'; // Default to 'user'
//     });
//     print("Abhi:- get user role selected : $selectedRole");
//   }
//
//   Future<void> _fetchProfileFromAPI() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null) {
//         print("Abhi:- No token found, skipping fetch");
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse('https://api.thebharatworks.com/api/user/getUserProfileData'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final body = json.decode(response.body);
//         if (body['status'] == true) {
//           final data = body['data'];
//           final userAge = data['age']?.toString() ?? '';
//           final userGender = (data['gender'] ?? '').toString().toLowerCase();
//
//           setState(() {
//             fullName = data['full_name'] ?? 'Your Name';
//             age = userAge;
//             gender = userGender;
//             selectedGender = userGender;
//             role = data['role'] ?? 'role';
//             profilePicUrl = data['profilePic'];
//             aboutUs = data['aboutUs'] ?? '';
//             phone = data['phone'] ?? '';
//             requestStatus = data['requestStatus'] ?? '';
//             verifiedSataus = data['verificationStatus'] ?? '';
//             category_name = data['category_name'] ?? '';
//             rejectionReason = data['rejectionReason'] ?? '';
//             aboutController.text = aboutUs!;
//           });
//
//           print("Abhi:- User Profile Fetched - Age: $userAge, Gender: $userGender, VerifiedStatus: $verifiedSataus, Category: $category_name, RejectionReason: $rejectionReason");
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(body['message'] ?? 'Failed to fetch profile')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Server error, profile fetch failed!')),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ fetchProfileFromAPI Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Something went wrong, try again!')),
//       );
//     }
//   }
//
//   Future<void> _uploadCombinedProfileData(
//       String name,
//       String aboutText,
//       File? imageFile,
//       ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) return;
//
//     if (imageFile != null) {
//       // 👉 Update profile with image
//       final uri = Uri.parse(
//         'https://api.thebharatworks.com/api/user/updateProfilePic',
//       );
//       final request = http.MultipartRequest('PUT', uri)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['full_name'] = name
//         ..fields['aboutUs'] = aboutText
//         ..fields['age'] = age ?? ''   // ✅ Age
//         ..fields['gender'] = selectedGender ?? 'other'; // ✅ Gender
//
//       request.files.add(
//         await http.MultipartFile.fromPath('profilePic', imageFile.path),
//       );
//
//       final response = await request.send();
//       final resBody = await http.Response.fromStream(response);
//       final body = json.decode(resBody.body);
//
//       if (body['status'] == true) {
//         setState(() {
//           fullName = name;
//           aboutUs = aboutText;
//           _image = imageFile;
//           profilePicUrl = null;
//         });
//         await _fetchProfileFromAPI();
//       }
//     } else {
//       // 👉 Update profile without image
//       final uri = Uri.parse(
//         'https://api.thebharatworks.com/api/user/updateUserDetails',
//       );
//       final request = http.MultipartRequest('PUT', uri)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['full_name'] = name
//         ..fields['aboutUs'] = aboutText
//         ..fields['age'] = age ?? ''   // ✅ Age
//         ..fields['gender'] = selectedGender ?? 'other'; // ✅ Gender
//
//       final response = await request.send();
//       final resBody = await http.Response.fromStream(response);
//       final body = json.decode(resBody.body);
//
//       if (body['status'] == true) {
//         setState(() {
//           fullName = name;
//           aboutUs = aboutText;
//           aboutController.text = aboutText;
//         });
//         await _fetchProfileFromAPI();
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile updated successfully")),
//         );
//         Navigator.pop(context);
//       }
//     }
//   }
//
//   Future<void> switchRoleRequest() async{
//     final String url = "https://api.thebharatworks.com/api/user/request-role-upgrade";
//     print("Abhi:- switchRoleRequest url :$url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     try{
//
//       var response = await http.post(Uri.parse(url), headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },);
//       if(response.statusCode ==200 || response.statusCode ==201){
//         print("Abhi:- switchRoleRequest response ${response.body}");
//         print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
//       }else{
//         print("Abhi:- else switchRoleRequest response ${response.body}");
//         print("Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
//       }
//     }
//     catch(e){print("Abhi:- get Exception $e");}
//   }
//
//
//   void _showEditProfileBottomSheet() {
//     final nameController = TextEditingController(text: fullName ?? '');
//     final ageController  = TextEditingController(text: age ?? '');
//     String tempGender = (selectedGender ?? '').toLowerCase(); // 👈 API se jo aaya wahi
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return SafeArea(
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom,
//                   left: 16, right: 16, top: 24,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(child: Text("Edit Profile", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold))),
//                       const SizedBox(height: 16),
//
//                       TextField(
//                         controller: nameController,
//                         maxLength: 20,
//                         decoration: const InputDecoration(
//                           labelText: 'Full Name',
//                           border: OutlineInputBorder(),
//                           counterText: '',
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//
//                       TextField(
//                         controller: ageController,
//                         keyboardType: TextInputType.number,
//                         maxLength: 3,
//                         decoration: const InputDecoration(
//                           labelText: 'Age',
//                           border: OutlineInputBorder(),
//                           counterText: '',
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//
//                       Text("Gender", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Row(mainAxisSize: MainAxisSize.min, children: [
//                             Radio<String>(
//                               value: 'male',
//                               groupValue: tempGender,
//                               onChanged: (v) => setModalState(() => tempGender = v!),
//                             ),
//                             const Text('Male'),
//                           ]),
//                           Row(mainAxisSize: MainAxisSize.min, children: [
//                             Radio<String>(
//                               value: 'female',
//                               groupValue: tempGender,
//                               onChanged: (v) => setModalState(() => tempGender = v!),
//                             ),
//                             const Text('Female'),
//                           ]),
//                           Row(mainAxisSize: MainAxisSize.min, children: [
//                             Radio<String>(
//                               value: 'other',
//                               groupValue: tempGender,
//                               onChanged: (v) => setModalState(() => tempGender = v!),
//                             ),
//                             const Text('Other'),
//                           ]),
//                         ],
//                       ),
//
//                       const SizedBox(height: 20),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.save, color: Colors.white),
//                         label: const Text("Save", style: TextStyle(color: Colors.white)),
//                         onPressed: () async {
//                           Navigator.pop(context);
//
//                           // UI state update
//                           setState(() {
//                             fullName = nameController.text;
//                             age = ageController.text;
//                             gender = tempGender;
//                             selectedGender = tempGender; // 👈 persist selection
//                           });
//
//                           // backend call (agar gender/age bhi bhejna hai to yahan add kar do)
//                           await _uploadCombinedProfileData(
//                             nameController.text,
//                             aboutUs ?? '',
//                             null,
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryGreen,
//                           minimumSize: const Size(double.infinity, 45),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showEditAboutBottomSheet() {
//     final aboutEditController = TextEditingController(text: aboutUs ?? '');
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 24,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Edit About",
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: aboutEditController,
//                   maxLines: 5,
//                   maxLength: 400,
//                   decoration: const InputDecoration(
//                     hintText: 'Write about yourself...',
//                     border: OutlineInputBorder(),
//                     counterText: '',
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.save, color: Colors.white),
//                   label: const Text(
//                     "Update",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   onPressed: () async {
//                     Navigator.pop(context);
//                     await _uploadCombinedProfileData(
//                       fullName ?? '',
//                       aboutEditController.text,
//                       null,
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryGreen,
//                     minimumSize: const Size(double.infinity, 45),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _selectAndUploadImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       final file = File(picked.path);
//       await _uploadCombinedProfileData(fullName ?? '', aboutUs ?? '', file);
//     }
//   }
//
//
//   Widget _buildProfileImage() {
//     ImageProvider? imageProvider;
//
//     if (_image != null) {
//       imageProvider = FileImage(_image!);
//     } else if (profilePicUrl != null && profilePicUrl!.isNotEmpty) {
//       imageProvider = NetworkImage(profilePicUrl!);
//     }
//
//     return Stack(
//       children: [
//         InkWell(
//           onTap: _selectAndUploadImage,
//           child: Container(
//             padding: EdgeInsets.all(3), // border width
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.green.shade700,
//                 width: 3.0,
//               ),
//             ),
//             child: CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.grey.shade300,
//               backgroundImage: imageProvider,
//               child: imageProvider == null
//                   ? const Icon(Icons.person, size: 50, color: Colors.white)
//                   : null,
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 14,
//           right: 4,
//           child: GestureDetector(
//             onTap: _selectAndUploadImage,
//             child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHeader(BuildContext context, String? selectedRole, String? requestStatus , String verifiedSataus ,String category_name) {
//     print("Abhi:- tab button print data : ----> role : $selectedRole requestStatus : $requestStatus verifiedStatus : $verifiedSataus category_name : $category_name");
//     return ClipPath(
//       clipper: BottomCurveClipper(),
//       child: Container(
//         color: const Color(0xFF9DF89D),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         height: 140,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 IconButton(
//                   padding: EdgeInsets.zero,
//                   icon: const Icon(Icons.arrow_back, size: 25),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 18.0),
//                       child: Text(
//                         "User Profile Abhi",
//                         style: GoogleFonts.roboto(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             // const SizedBox(height: 5),
//             // (role == "both")
//             //     ? SizedBox()
//             //     : (requestStatus == null || requestStatus.isEmpty)
//             //     ? Center(child: _buildRoleSwitcher(context,role,requestStatus))
//             //     : Container(child: Text("No role found!"))
//             Center(child: _buildRoleSwitcher(context,role,requestStatus,verifiedSataus,category_name,rejectionReason!))
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildRoleSwitcher(BuildContext context, String? role, String? requestStatus, String? verifiedSataus, String? category_name ,String rejectionrestion) {
//
//     print("Abhi:- roleSwitcher role :$role , requestStatus: $requestStatus , verifiedStataus : $verifiedSataus ,rejectionrestion : $rejectionReason");
//
//     final GetXRoleController roleController = Get.find<GetXRoleController>();
//
//     return Obx(() {
//       final String selectedRole = roleController.role.value;
//
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkWell(
//             child: _roleButton("User", true, () async {
//               // User button action if needed
//             }),
//           ),
//           const SizedBox(width: 16),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 8,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: InkWell(
//               child: _roleButton("Worker", false, () async {
//                 if(verifiedSataus == 'rejected'){
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Center(child: const Text("Confirmation Box")),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Admin rejectionrestion",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               // "If you’d like to become a service provider, kindly complete and submit the document form."
//                                 rejectionrestion ?? ""
//                             ),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                         actions: [
//                           Container(
//                             width: 100,
//                             height: 35,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               color: Colors.green,
//                             ),
//                             child: TextButton(
//                               child: const Text(
//                                 "Confirm",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                               onPressed: () async {
//                                 Get.off(() => RoleEditProfileScreen(updateBothrequest: true,comeEditScreen: "editScreen",));
//                               },
//                             ),
//                           ),
//                           Container(
//                             width: 100,
//                             height: 35,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.green),
//                             ),
//                             child: TextButton(
//                               child: const Text(
//                                 "Cancel",
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }
//                 else if (category_name == null || category_name.isEmpty) {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Center(child: const Text("Confirmation Box")),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Confirmation",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text(
//                                 "If you’d like to become a service provider, kindly complete and submit the document form.",
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                         actions: [
//                           Container(
//                             width: 100,
//                             height: 35,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               color: Colors.green,
//                             ),
//                             child: TextButton(
//                               child: const Text(
//                                 "Confirm",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                               onPressed: () async {
//                                 Get.off(() => RoleEditProfileScreen(updateBothrequest: true,comeEditScreen: "editScreen",));
//                               },
//                             ),
//                           ),
//                           Container(
//                             width: 100,
//                             height: 35,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.green),
//                             ),
//                             child: TextButton(
//                               child: const Text(
//                                 "Cancel",
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 } else {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text("Request Submitted"),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Request Status",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                              Text(
//                                 "Your request has been submitted to the admin and will be reverted within 2 to 3 days",
//                                textAlign: TextAlign.center,
//                              ),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                         actions: [
//                           Center(
//                             child: Container(
//                               width: 100,
//                               height: 35,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.green,
//                               ),
//                               child: TextButton(
//                                 child: const Text(
//                                   "OK",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }
//               }),
//             ),
//           ),
//         ],
//       );
//     });
//   }
//
//   Widget _roleButton(String title, bool isSelected, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 35,
//         width: 140,
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green.shade700 : Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.green.shade700),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           title,
//           style: GoogleFonts.roboto(
//             fontWeight: FontWeight.bold,
//             fontSize: 13,
//             color: isSelected ? Colors.white : Colors.green.shade700,
//           ),
//         ),
//       ),
//     );
//   }
//   bool isLoading = true;
//   Future<void> _onRefresh() async {
//     print("Abhi:- Refresh triggered");
//     setState(() {
//       isLoading = true; // Loader on
//     });
//     await _fetchProfileFromAPI(); // Re-fetch
//     await _initializeWithChecks(); // Re-check conditions
//     print("Abhi:- Refresh completed");
//   }
//
//   Future<void> _initializeWithChecks() async {
//     await _fetchProfileFromAPI(); // Profile fetch kar
//     final roleController = Get.find<GetXRoleController>();
//     final String currentRole = roleController.role.value; // Current role
//
//     print("Abhi:- Checking in _initializeWithChecks - Role: $currentRole, VerifiedStatus: $verifiedSataus");
//
//     // Conditions check kar
//     if (currentRole == "service_provider" && verifiedSataus != null) {
//       if (verifiedSataus == 'pending' || verifiedSataus == 'rejected') {
//         // Pending ya rejected: FirstTime pe reh (no navigation)
//         print("Abhi:- Staying on FirstTimeServiceProviderProfileScreen (pending/rejected)");
//       } else if (verifiedSataus == 'verified') {
//         // Verified service_provider: ServiceProviderProfileScreen pe bhej
//         print("Abhi:- Navigating to ServiceProviderProfileScreen (verified)");
//         Get.off(() => SellerScreen());
//         return; // Navigation ke baad return
//       }
//     } else if (currentRole == "user") {
//       // User role: ProfileScreen pe bhej
//       print("Abhi:- Navigating to ProfileScreen (user)");
//       Get.off(() => ProfileScreen());
//       return;
//     } else if (role == "both" && (requestStatus == null || requestStatus!.isEmpty)) {
//       // Role 'both' aur requestStatus empty: ServiceProviderProfileScreen pe bhej
//       print("Abhi:- Role 'both' with no requestStatus, navigating to ServiceProviderProfileScreen");
//       Get.off(() => SellerScreen());
//       return;
//     }
//
//     // Agar koi condition match nahi, toh FirstTime pe reh aur UI build kar
//     setState(() {
//       isLoading = false; // Loader off
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: _onRefresh,
//           child: SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: MediaQuery.of(context).size.height,
//               ),
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   // _buildHeader(context,requestStatus),
//                   _buildHeader(context, selectedRole,requestStatus,verifiedSataus ?? "",category_name!),
//
//                   Positioned(
//                     top: 180,
//                     left: 0,
//                     right: 0,
//                     child: Column(
//                       children: [
//                         _buildProfileImage(),
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               '${fullName?[0].toUpperCase()}${fullName?.substring(1).toLowerCase()}',
//                               // fullName ?? 'Your Name',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             GestureDetector(
//                                 onTap: _showEditProfileBottomSheet,
//                                 child: /*Image.asset('assets/images/edit1.png'),*/ SvgPicture.asset("assets/svg_images/editicon.svg")
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Age: ${age ?? 0}',
//                               // fullName ?? 'Your Name',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ), SizedBox(width: 6,),
//                             Text(
//                               'Gender: ${ (gender != null && gender!.isNotEmpty)
//                                   ? "${gender?[0].toUpperCase()}${gender?.substring(1).toLowerCase()}"
//                                   : "No data"}',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (phone != null && phone!.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(
//                               phone!,
//                               style: GoogleFonts.roboto(
//                                 fontSize: 14,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ),
//
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24.0,
//                             vertical: 16,
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black12,
//                                   blurRadius: 4,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 widget.swithcrole == 'serviceroleSwitch' ?   Text("Note: If you want to change your role, please fill out the About Us form.",style: TextStyle(color: Colors.red,fontSize: 12),) : SizedBox() ,
//                                 Row(
//                                   children: [
//                                     Text(
//                                       "About Us",
//                                       style: GoogleFonts.roboto(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 5),
//                                     GestureDetector(
//                                         onTap: _showEditAboutBottomSheet,
//                                         child: /*Image.asset(
//                                         'assets/images/edit1.png',
//                                       ),*/SvgPicture.asset("assets/svg_images/editicon.svg")
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 12),
//                                 Container(
//                                   width: double.infinity,
//                                   height: 140,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.green,
//                                       width: 1.5,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: TextField(
//                                     controller: aboutController,
//                                     readOnly: true,
//                                     maxLines: null,
//                                     style: GoogleFonts.roboto(fontSize: 14),
//                                     decoration: const InputDecoration.collapsed(
//                                       hintText: 'Write about yourself...',
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     aboutController.dispose();
//     super.dispose();
//   }
// }
//
// class BottomCurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height - 20);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height,
//       size.width,
//       size.height - 20,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }


import 'dart:convert';
import 'dart:io';

import 'package:developer/directHiring/views/Account/user_profile/user_role_profile_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../auth/RoleSelectionScreen.dart';
import '../service_provider_profile/EditProfileScreen.dart';
import '../service_provider_profile/ServiceProviderProfileScreen.dart';
import '../user_profile/UserProfileScreen.dart';
import '../user_profile/both_profile_screen.dart';

class FirstTimeServiceProviderProfileScreen extends StatefulWidget {
  final swithcrole;
  const FirstTimeServiceProviderProfileScreen({super.key, this.swithcrole});

  @override
  State<FirstTimeServiceProviderProfileScreen> createState() => _FirstTimeServiceProviderProfileScreenState();
}

class _FirstTimeServiceProviderProfileScreenState extends State<FirstTimeServiceProviderProfileScreen> {
  File? _image;
  String selectedRole = '';
  String? profilePicUrl;
  String? fullName = 'Your Name';
  String? age = 'Your age';
  String? gender = 'Your gender';
  String? requestStatus;
  String? verifiedSataus;
  String? role = 'No role';
  String? category_name = 'No role';
  String? rejectionReason = 'No role';
  String? aboutUs = '';
  String? phone;
  String? selectedGender;
  late TextEditingController aboutController;
  final GetXRoleController roleController = Get.put(GetXRoleController());
  @override
  void initState() {
    super.initState();
    aboutController = TextEditingController();
    _fetchProfileFromAPI();
    _loadSelectedRole();
    _initializeWithChecks();
  }
  bool isLoading = true;

  // Future<void> _loadSelectedRole() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     selectedRole = prefs.getString('role') ?? 'user'; // Default to 'user'
  //   });
  //   print("Abhi:- get user role selected : $selectedRole");
  // }

  Future<void> _loadSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('role') ?? 'user';
    });
    print("Abhi:- get user role selected : $selectedRole");
  }

  Future<void> _fetchProfileFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("Abhi:- No token found, skipping fetch");
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUserProfileData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final data = body['data'];
          final userAge = data['age']?.toString() ?? '';
          final userGender = (data['gender'] ?? '').toString().toLowerCase();

          setState(() {
            fullName = data['full_name'] ?? 'Your Name';
            age = userAge;
            gender = userGender;
            selectedGender = userGender;
            role = data['role'] ?? 'role';
            profilePicUrl = data['profilePic'];
            aboutUs = data['aboutUs'] ?? '';
            phone = data['phone'] ?? '';
            requestStatus = data['requestStatus'] ?? '';
            verifiedSataus = data['verificationStatus'] ?? '';
            category_name = data['category_name'] ?? '';
            rejectionReason = data['rejectionReason'] ?? '';
            aboutController.text = aboutUs!;
          });

          print("Abhi:- User Profile Fetched - Age: $userAge, Gender: $userGender, VerifiedStatus: $verifiedSataus, Category: $category_name, RejectionReason: $rejectionReason");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Failed to fetch profile')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error, profile fetch failed!')),
        );
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromAPI Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong, try again!')),
      );
    }
  }

  Future<void> _uploadCombinedProfileData(
      String name,
      String aboutText,
      File? imageFile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    if (imageFile != null) {
      // 👉 Update profile with image
      final uri = Uri.parse(
        'https://api.thebharatworks.com/api/user/updateProfilePic',
      );
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['full_name'] = name
        ..fields['aboutUs'] = aboutText
        ..fields['age'] = age ?? ''   // ✅ Age
        ..fields['gender'] = selectedGender ?? 'other'; // ✅ Gender

      request.files.add(
        await http.MultipartFile.fromPath('profilePic', imageFile.path),
      );

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final body = json.decode(resBody.body);

      if (body['status'] == true) {
        setState(() {
          fullName = name;
          aboutUs = aboutText;
          _image = imageFile;
          profilePicUrl = null;
        });
        await _fetchProfileFromAPI();
      }
    } else {
      // 👉 Update profile without image
      final uri = Uri.parse(
        'https://api.thebharatworks.com/api/user/updateUserDetails',
      );
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['full_name'] = name
        ..fields['aboutUs'] = aboutText
        ..fields['age'] = age ?? ''   // ✅ Age
        ..fields['gender'] = selectedGender ?? 'other'; // ✅ Gender

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final body = json.decode(resBody.body);

      if (body['status'] == true) {
        setState(() {
          fullName = name;
          aboutUs = aboutText;
          aboutController.text = aboutText;
        });
        await _fetchProfileFromAPI();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> switchRoleRequest() async{
    final String url = "https://api.thebharatworks.com/api/user/request-role-upgrade";
    print("Abhi:- switchRoleRequest url :$url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try{

      var response = await http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },);
      if(response.statusCode ==200 || response.statusCode ==201){
        print("Abhi:- switchRoleRequest response ${response.body}");
        print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
      }else{
        print("Abhi:- else switchRoleRequest response ${response.body}");
        print("Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
      }
    }
    catch(e){print("Abhi:- get Exception $e");}
  }


  void _showEditProfileBottomSheet() {
    final nameController = TextEditingController(text: fullName ?? '');
    final ageController  = TextEditingController(text: age ?? '');
    String tempGender = (selectedGender ?? '').toLowerCase(); // 👈 API se jo aaya wahi

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16, right: 16, top: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text("Edit Profile", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 16),

                      TextField(
                        controller: nameController,
                        maxLength: 20,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text("Gender", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Radio<String>(
                              value: 'male',
                              groupValue: tempGender,
                              onChanged: (v) => setModalState(() => tempGender = v!),
                            ),
                            const Text('Male'),
                          ]),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Radio<String>(
                              value: 'female',
                              groupValue: tempGender,
                              onChanged: (v) => setModalState(() => tempGender = v!),
                            ),
                            const Text('Female'),
                          ]),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Radio<String>(
                              value: 'other',
                              groupValue: tempGender,
                              onChanged: (v) => setModalState(() => tempGender = v!),
                            ),
                            const Text('Other'),
                          ]),
                        ],
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Save", style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          Navigator.pop(context);

                          // UI state update
                          setState(() {
                            fullName = nameController.text;
                            age = ageController.text;
                            gender = tempGender;
                            selectedGender = tempGender; // 👈 persist selection
                          });

                          // backend call (agar gender/age bhi bhejna hai to yahan add kar do)
                          await _uploadCombinedProfileData(
                            nameController.text,
                            aboutUs ?? '',
                            null,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditAboutBottomSheet() {
    final aboutEditController = TextEditingController(text: aboutUs ?? '');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit About",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aboutEditController,
                  maxLines: 5,
                  maxLength: 400,
                  decoration: const InputDecoration(
                    hintText: 'Write about yourself...',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _uploadCombinedProfileData(
                      fullName ?? '',
                      aboutEditController.text,
                      null,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      await _uploadCombinedProfileData(fullName ?? '', aboutUs ?? '', file);
    }
  }


  Widget _buildProfileImage() {
    ImageProvider? imageProvider;

    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else if (profilePicUrl != null && profilePicUrl!.isNotEmpty) {
      imageProvider = NetworkImage(profilePicUrl!);
    }

    return Stack(
      children: [
        InkWell(
          onTap: _selectAndUploadImage,
          child: Container(
            padding: EdgeInsets.all(3), // border width
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.shade700,
                width: 3.0,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
        ),
        Positioned(
          bottom: 14,
          right: 4,
          child: GestureDetector(
            onTap: _selectAndUploadImage,
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String? selectedRole, String? requestStatus , String verifiedSataus ,String category_name) {
    print("Abhi:- tab button print data : ----> role : $selectedRole requestStatus : $requestStatus verifiedStatus : $verifiedSataus category_name : $category_name");
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        color: const Color(0xFF9DF89D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back, size: 25),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text(
                        "User Profile",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 5),
            // (role == "both")
            //     ? SizedBox()
            //     : (requestStatus == null || requestStatus.isEmpty)
            //     ? Center(child: _buildRoleSwitcher(context,role,requestStatus))
            //     : Container(child: Text("No role found!"))
            Center(child: _buildRoleSwitcher(context,role,requestStatus,verifiedSataus,category_name,rejectionReason!))
          ],
        ),
      ),
    );
  }
  Widget _buildRoleSwitcher(BuildContext context, String? role, String? requestStatus, String? verifiedSataus, String? category_name ,String rejectionrestion) {

    print("Abhi:- roleSwitcher role :$role , requestStatus: $requestStatus , verifiedStataus : $verifiedSataus ,rejectionrestion : $rejectionReason");

    final GetXRoleController roleController = Get.find<GetXRoleController>();

    return Obx(() {
      final String selectedRole = roleController.role.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: _roleButton("User", true, () async {
              // User button action if needed
            }),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              child: _roleButton("Worker", false, () async {
                if(verifiedSataus == 'rejected'){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: const Text("")),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                            const SizedBox(height: 8),
                            const Text(
                              "Admin has rejected your request",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              // "If you’d like to become a service provider, kindly complete and submit the document form."
                                rejectionrestion ?? ""
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        actions: [
                          Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green,
                            ),
                            child: TextButton(
                              child: const Text(
                                "Confirm",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                Get.off(() => RoleEditProfileScreen(updateBothrequest: true,comeEditScreen: "editScreen",));
                              },
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: TextButton(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                else if (category_name == null || category_name.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: const Text("Confirmation Box")),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                            const SizedBox(height: 8),
                            const Text(
                              "Confirmation",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "If you’d like to become a service provider, kindly complete and submit the document form.",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        actions: [
                          Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green,
                            ),
                            child: TextButton(
                              child: const Text(
                                "Confirm",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                Get.off(() => RoleEditProfileScreen(updateBothrequest: true,comeEditScreen: "editScreen",));
                              },
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: TextButton(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Request Submitted"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset("assets/svg_images/ConfirmationIcon.svg"),
                            const SizedBox(height: 8),
                            const Text(
                              "Request Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Your request has been submitted to the admin and will be reverted within 2 to 3 days",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        actions: [
                          Center(
                            child: Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.green,
                              ),
                              child: TextButton(
                                child: const Text(
                                  "OK",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              }),
            ),
          ),
        ],
      );
    });
  }

  Widget _roleButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 140,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade700),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.green.shade700,
          ),
        ),
      ),
    );
  }
  // bool isLoading = true;
  // Future<void> _onRefresh() async {
  //   print("Abhi:- Refresh triggered");
  //   setState(() {
  //     isLoading = true; // Loader on
  //   });
  //   await _fetchProfileFromAPI(); // Re-fetch
  //   await _initializeWithChecks(); // Re-check conditions
  //   print("Abhi:- Refresh completed");
  // }
  //
  // Future<void> _initializeWithChecks() async {
  //   await _fetchProfileFromAPI(); // Profile fetch kar
  //   final roleController = Get.find<GetXRoleController>();
  //   final String currentRole = roleController.role.value; // Current role
  //
  //   print("Abhi:- Checking in _initializeWithChecks - Role: $currentRole, VerifiedStatus: $verifiedSataus");
  //
  //   // Conditions check kar
  //   if (currentRole == "service_provider" && verifiedSataus != null) {
  //     if (verifiedSataus == 'pending' || verifiedSataus == 'rejected') {
  //       // Pending ya rejected: FirstTime pe reh (no navigation)
  //       print("Abhi:- Staying on FirstTimeServiceProviderProfileScreen (pending/rejected)");
  //     } else if (verifiedSataus == 'verified') {
  //       // Verified service_provider: ServiceProviderProfileScreen pe bhej
  //       print("Abhi:- Navigating to ServiceProviderProfileScreen (verified)");
  //       Get.off(() => SellerScreen());
  //       return; // Navigation ke baad return
  //     }
  //   } else if (currentRole == "user") {
  //     // User role: ProfileScreen pe bhej
  //     print("Abhi:- Navigating to ProfileScreen (user)");
  //     Get.off(() => ProfileScreen());
  //     return;
  //   } else if (role == "both" && (requestStatus == null || requestStatus!.isEmpty)) {
  //     // Role 'both' aur requestStatus empty: ServiceProviderProfileScreen pe bhej
  //     print("Abhi:- Role 'both' with no requestStatus, navigating to ServiceProviderProfileScreen");
  //     Get.off(() => SellerScreen());
  //     return;
  //   }
  //
  //   // Agar koi condition match nahi, toh FirstTime pe reh aur UI build kar
  //   setState(() {
  //     isLoading = false; // Loader off
  //   });
  // }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    print("Abhi:- FirstTime Refresh triggered");
    setState(() {
      isLoading = true;
    });
    await _fetchProfileFromAPI();
    await _initializeWithChecks();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    print("Abhi:- FirstTime Refresh completed");
  }

  Future<void> _initializeWithChecks() async {
    await _fetchProfileFromAPI();
    String currentRole = role ?? 'user'; // API se role le

    print("Abhi:- FirstTime _initializeWithChecks - API Role: $currentRole, VerifiedStatus: $verifiedSataus, Current Route: ${Get.currentRoute}");

    // Conditions check kar
    if (verifiedSataus != null && (verifiedSataus == 'pending' || verifiedSataus == 'rejected')) {
      // Pending ya rejected: FirstTime pe reh (no navigation)
      print("Abhi:- Staying on FirstTimeServiceProviderProfileScreen (pending/rejected, role: $currentRole)");
    } else if (verifiedSataus == 'verified' && (currentRole == 'service_provider' || currentRole == 'both')) {
      // Verified: ServiceProviderProfileScreen pe bhej
      print("Abhi:- Navigating to ServiceProviderProfileScreen (verified, role: $currentRole)");
      if (Get.currentRoute != '/ServiceProviderProfileScreen') {
        Get.off(() => ProfileScreen());
      }
      return;
    } else if (currentRole == 'user' && (verifiedSataus == null || verifiedSataus == '')) {
      // User role with no pending/rejected: ProfileScreen pe bhej
      print("Abhi:- Navigating to ProfileScreen (user, no pending/rejected)");
      if (Get.currentRoute != '/ProfileScreen') {
        Get.off(() => ProfileScreen());
      }
      return;
    } else {
      // Fallback: FirstTime pe reh
      print("Abhi:- Fallback staying on FirstTimeServiceProviderProfileScreen (unknown: $currentRole, $verifiedSataus)");
    }

    // UI build kar
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // _buildHeader(context,requestStatus),
                  _buildHeader(context, selectedRole,requestStatus,verifiedSataus ?? "",category_name!),

                  Positioned(
                    top: 180,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${fullName?[0].toUpperCase()}${fullName?.substring(1).toLowerCase()}',
                              // fullName ?? 'Your Name',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                                onTap: _showEditProfileBottomSheet,
                                child: /*Image.asset('assets/images/edit1.png'),*/ SvgPicture.asset("assets/svg_images/editicon.svg")
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Age: ${age ?? 0}',
                              // fullName ?? 'Your Name',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ), SizedBox(width: 6,),
                            Text(
                              'Gender: ${ (gender != null && gender!.isNotEmpty)
                                  ? "${gender?[0].toUpperCase()}${gender?.substring(1).toLowerCase()}"
                                  : "No data"}',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (phone != null && phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              phone!,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.swithcrole == 'serviceroleSwitch' ?   Text("Note: If you want to change your role, please fill out the About Us form.",style: TextStyle(color: Colors.red,fontSize: 12),) : SizedBox() ,
                                Row(
                                  children: [
                                    Text(
                                      "About Us",
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                        onTap: _showEditAboutBottomSheet,
                                        child: /*Image.asset(
                                        'assets/images/edit1.png',
                                      ),*/SvgPicture.asset("assets/svg_images/editicon.svg")
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 140,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: aboutController,
                                    readOnly: true,
                                    maxLines: null,
                                    style: GoogleFonts.roboto(fontSize: 14),
                                    decoration: const InputDecoration.collapsed(
                                      hintText: 'Write about yourself...',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    aboutController.dispose();
    super.dispose();
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
