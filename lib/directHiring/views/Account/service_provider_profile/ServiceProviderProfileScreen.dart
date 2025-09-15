// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_svg/svg.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:get/get.dart';
// // import 'package:carousel_slider/carousel_slider.dart';
// // import '../../../../Emergency/Service_Provider/controllers/sp_emergency_service_controller.dart';
// // import '../../../../Emergency/utils/logger.dart';
// // import '../../../../Widgets/AppColors.dart';
// // import '../../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// // import '../../ServiceProvider/FullImageScreen.dart';
// // import '../../ServiceProvider/GalleryScreen.dart';
// // import '../../ServiceProvider/WorkerScreen.dart';
// // import '../../auth/RoleSelectionScreen.dart';
// // import '../../comm/home_location_screens.dart';
// // import '../user_profile/UserProfileScreen.dart';
// // import '../user_profile/user_role_profile_update.dart';
// // import 'EditProfileScreen.dart';
// //
// // class SellerScreen extends StatefulWidget {
// //   final iconsHide;
// //
// //   const SellerScreen({super.key, this.iconsHide});
// //
// //   @override
// //   State<SellerScreen> createState() => _SellerScreenState();
// // }
// //
// // class _SellerScreenState extends State<SellerScreen> {
// //   bool _isSwitched = false;
// //   bool _isToggling = false;
// //   File? _pickedImage;
// //   ServiceProviderProfileModel? profile;
// //   bool isLoading = true;
// //   bool _showReviews = true;
// //   String? address = "";
// //   final controller = Get.put(SpEmergencyServiceController());
// //   final GetXRoleController roleController = Get.put(GetXRoleController());
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadSavedLocation();
// //     _loadEmergencyTask();
// //     fetchProfile().then((_) {
// //       print(
// //           "Checking role: ${profile?.role}, verified: ${profile?.verified} request status: ${profile?.requestStatus}");
// //       if (profile?.verified == false) {
// //         print("Showing verification dialog for service_provider");
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           if (context.mounted) {
// //             showDialog(
// //               context: context,
// //               builder: (BuildContext context) {
// //                 print("Inside dialog builder");
// //                 return _buildServiceproviderVerification(
// //                     context,
// //                     profile?.role,
// //                     profile?.requestStatus,
// //                     profile?.verified ?? false,
// //                     profile?.categoryId);
// //               },
// //             );
// //           } else {
// //             print("Context not mounted");
// //           }
// //         });
// //       } else {
// //         print("Dialog not shown: Role or verified condition not met");
// //       }
// //     });
// //   }
// //
// //   Future<void> _loadEmergencyTask() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     bool saved = prefs.getBool("emergency_task") ?? false;
// //     setState(() {
// //       _isSwitched = saved;
// //     });
// //   }
// //
// //   Future<void> loadSavedLocation() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     String? savedLocation = prefs.getString('location');
// //     if (savedLocation != null) {
// //       setState(() {
// //         address = savedLocation;
// //       });
// //     }
// //   }
// //
// //   Future<void> updateLocationOnServer(
// //       String newAddress, double latitude, double longitude) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token') ?? '';
// //     final url =
// //         Uri.parse("https://api.thebharatworks.com/api/user/updateLocation");
// //     final response = await http.put(
// //       url,
// //       headers: {
// //         HttpHeaders.authorizationHeader: 'Bearer $token',
// //         'Content-Type': 'application/json',
// //       },
// //       body: json.encode({
// //         'location': {
// //           'latitude': latitude,
// //           'longitude': longitude,
// //           'address': newAddress,
// //         },
// //         'current_location': newAddress,
// //         'full_address': newAddress,
// //       }),
// //     );
// //     if (response.statusCode == 200) {
// //       await prefs.setString('location', newAddress);
// //       setState(() {
// //         address = newAddress;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("✅ Location updated to $newAddress")),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("❌ Failed to update location")),
// //       );
// //       print("Update Location Failed: ${response.body}");
// //     }
// //   }
// //
// //   Future<void> _pickImageFromCamera() async {
// //     final picker = ImagePicker();
// //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _pickedImage = File(pickedFile.path);
// //       });
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');
// //       if (token == null || token.isEmpty) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //               content: Text("🔐 Token not found. Please login again.")),
// //         );
// //         return;
// //       }
// //       final url =
// //           Uri.parse("https://api.thebharatworks.com/api/user/updateProfilePic");
// //       try {
// //         var request = http.MultipartRequest("PUT", url)
// //           ..headers['Authorization'] = 'Bearer $token'
// //           ..files.add(
// //               await http.MultipartFile.fromPath('profilePic', pickedFile.path));
// //         final response = await request.send();
// //         if (response.statusCode == 200) {
// //           final responseData = await response.stream.bytesToString();
// //           final jsonData = jsonDecode(responseData);
// //           debugPrint("✅ Response: $jsonData");
// //           if (jsonData['profilePic'] != null) {
// //             setState(() {
// //               profile?.profilePic = jsonData['profilePic'];
// //               profile?.fullName = jsonData['full_name'];
// //             });
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               const SnackBar(content: Text("✅ Profile picture updated")),
// //             );
// //           } else {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text(jsonData['message'] ?? "❌ Upload failed")),
// //             );
// //           }
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("❌ Upload failed! Try again.")),
// //           );
// //         }
// //       } catch (e) {
// //         debugPrint("Upload error: $e");
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("⚠️ Something went wrong!")),
// //         );
// //       }
// //     }
// //   }
// //
// //   Future<void> switchRoleRequest() async {
// //     final String url =
// //         "https://api.thebharatworks.com/api/user/request-role-upgrade";
// //     print("Abhi:- switchRoleRequest url :$url");
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token');
// //     try {
// //       var response = await http.post(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //       );
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         print("Abhi:- switchRoleRequest response ${response.body}");
// //         print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
// //       } else {
// //         print("Abhi:- else switchRoleRequest response ${response.body}");
// //         print(
// //             "Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
// //       }
// //     } catch (e) {
// //       print("Abhi:- get Exception $e");
// //     }
// //   }
// //
// //   Future<void> fetchProfile() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token') ?? '';
// //       final url = Uri.parse(
// //           "https://api.thebharatworks.com/api/user/getUserProfileData");
// //       final response = await http.get(
// //         url,
// //         headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
// //       );
// //       print("Full API Response: ${response.body}");
// //
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         print("Data: $data");
// //
// //         if (data['status'] == true) {
// //           final fetchedAddress =
// //               data['data'] != null && data['data']['location'] != null
// //                   ? (data['data']['location']['address'] ?? 'Select Location')
// //                   : 'Select Location';
// //
// //           await prefs.setString("address", fetchedAddress);
// //
// //           setState(() {
// //             profile = ServiceProviderProfileModel.fromJson(data['data']);
// //             isLoading = false;
// //             address = fetchedAddress;
// //           });
// //
// //           print("Saved address: $fetchedAddress");
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(data["message"] ?? "Profile fetch failed")),
// //           );
// //         }
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Server error, profile fetch failed!")),
// //         );
// //       }
// //     } catch (e) {
// //       print("Error: $e");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Something went wrong, try again!")),
// //       );
// //     }
// //   }
// //
// //   Future<void> _checkEmergencyTask() async {
// //     setState(() {
// //       _isToggling = true;
// //     });
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token') ?? '';
// //       final url =
// //           Uri.parse("https://api.thebharatworks.com/api/user/emergency");
// //
// //       final response = await http.post(
// //         url,
// //         headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
// //       );
// //
// //       bwDebug("Emergency API Response: ${response.body}");
// //
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //
// //         if (data["success"] == true) {
// //           setState(() {
// //             _isSwitched = data["emergency_task"] ?? false;
// //           });
// //           final prefs = await SharedPreferences.getInstance();
// //           await prefs.setBool("emergency_task", _isSwitched);
// //           if (mounted) {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text(data["message"] ?? "Updated")),
// //             );
// //           }
// //         } else {
// //           if (mounted) {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text("Error: ${response.statusCode}")),
// //             );
// //           }
// //         }
// //       }
// //     } catch (e) {
// //       bwDebug("Error in Emergency API: $e");
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text("An error occurred: $e")),
// //         );
// //       }
// //     } finally {
// //       controller.getEmergencySpOrderList();
// //       setState(() {
// //         _isToggling = false;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         //  backgroundColor: Colors.grey[100],
// //         appBar: AppBar(
// //           elevation: 0,
// //           backgroundColor: Color(0xFF9DF89D),
// //           centerTitle: true,
// //           title: const Text("Worker Profile",
// //               style:
// //                   TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// //           leading: const BackButton(color: Colors.black),
// //           actions: [],
// //           systemOverlayStyle: SystemUiOverlayStyle(
// //             statusBarColor: AppColors.primaryGreen,
// //             statusBarIconBrightness: Brightness.light,
// //           ),
// //         ),
// //         body: SafeArea(
// //           child: isLoading
// //               ? const Center(child: CircularProgressIndicator())
// //               : SingleChildScrollView(
// //                   child: Column(
// //                     children: [
// //                       _buildHeader(context, profile),
// //                       Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Stack(
// //                             clipBehavior: Clip.none,
// //                             children: [
// //                               InkWell(
// //                                 onTap: _pickImageFromCamera,
// //                                 child: Container(
// //                                   padding: EdgeInsets.all(3),
// //                                   decoration: BoxDecoration(
// //                                     shape: BoxShape.circle,
// //                                     border: Border.all(
// //                                         color: Colors.green.shade700,
// //                                         width: 3.0),
// //                                   ),
// //                                   child: CircleAvatar(
// //                                     radius: 50,
// //                                     backgroundColor: Colors.grey.shade300,
// //                                     backgroundImage: _pickedImage != null
// //                                         ? FileImage(_pickedImage!)
// //                                         : (profile?.profilePic != null
// //                                             ? NetworkImage(profile!.profilePic!)
// //                                             : null) as ImageProvider?,
// //                                     child: _pickedImage == null &&
// //                                             profile?.profilePic == null
// //                                         ? const Icon(Icons.person,
// //                                             size: 50, color: Colors.white)
// //                                         : null,
// //                                   ),
// //                                 ),
// //                               ),
// //                               profile?.verified == true
// //                                   ? Positioned(
// //                                       bottom: 4,
// //                                       right: 4,
// //                                       child: InkWell(
// //                                         onTap: _pickImageFromCamera,
// //                                         child: const Icon(Icons.camera_alt,
// //                                             size: 20, color: Colors.black),
// //                                       ),
// //                                     )
// //                                   : SizedBox(),
// //                             ],
// //                           ),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Text(
// //                                 '${profile?.fullName?[0].toUpperCase()}${profile?.fullName?.substring(1).toLowerCase() ?? ''}',
// //                                 style: GoogleFonts.roboto(
// //                                     fontSize: 16, fontWeight: FontWeight.bold),
// //                               ),
// //                               widget.iconsHide == 'hide'
// //                                   ? SizedBox()
// //                                   : GestureDetector(
// //                                       onTap: () async {
// //                                         final result = await Navigator.push(
// //                                           context,
// //                                           MaterialPageRoute(
// //                                             builder: (context) =>
// //                                                 EditProfileScreen(
// //                                               fullName: profile?.fullName,
// //                                               age: profile?.age,
// //                                               gender: profile?.gender,
// //                                               skill: profile?.skill,
// //                                               categoryId: profile?.categoryId,
// //                                               subCategoryIds: profile
// //                                                   ?.subCategoryIds
// //                                                   ?.map((e) => e.toString())
// //                                                   .toList(),
// //                                               documentUrl: profile?.documents,
// //                                             ),
// //                                           ),
// //                                         );
// //                                         if (result == true) {
// //                                           fetchProfile();
// //                                         }
// //                                       },
// //                                       child: profile?.verified == true
// //                                           ? Container(
// //                                               padding: const EdgeInsets.all(6),
// //                                               width: 32,
// //                                               height: 32,
// //                                               child: SvgPicture.asset(
// //                                                   "assets/svg_images/editicon.svg"))
// //                                           : SizedBox(),
// //                                     ),
// //                             ],
// //                           ),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Text(
// //                                 'Age: ${profile?.age ?? 0}',
// //                                 style: GoogleFonts.roboto(
// //                                     fontSize: 13, fontWeight: FontWeight.w600),
// //                               ),
// //                               SizedBox(width: 6),
// //                               Text(
// //                                 'Gender: ${profile?.gender?[0].toUpperCase() ?? "No data"}${profile?.gender?.substring(1).toLowerCase() ?? ''}',
// //                                 style: GoogleFonts.roboto(
// //                                     fontSize: 13, fontWeight: FontWeight.w600),
// //                               ),
// //                             ],
// //                           ),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Icon(Icons.location_on,
// //                                   color: Colors.green.shade700, size: 16),
// //                               const SizedBox(width: 4),
// //                               Flexible(
// //                                 child: GestureDetector(
// //                                   onTap: () async {
// //                                     final result = await Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) =>
// //                                             LocationSelectionScreen(
// //                                           onLocationSelected: (String) {},
// //                                         ),
// //                                       ),
// //                                     );
// //                                     if (result != null) {
// //                                       setState(() {
// //                                         address = result;
// //                                       });
// //                                       await updateLocationOnServer(
// //                                           result, 30.73508469999999, 79.0668788);
// //                                     }
// //                                   },
// //                                   child: Text(
// //                                     address ?? 'Select Location',
// //                                     maxLines: 1,
// //                                     overflow: TextOverflow.ellipsis,
// //                                     softWrap: false,
// //                                     style: GoogleFonts.roboto(
// //                                       fontSize: 12,
// //                                       color: Colors.black,
// //                                       fontWeight: FontWeight.w500,
// //                                     ),
// //
// //                                   ),
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 8),
// //                             ],
// //                           ),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Text(
// //                                 "${profile?.totalReview ?? 0} Reviews",
// //                                 style: GoogleFonts.roboto(
// //                                     fontSize: 13, fontWeight: FontWeight.bold),
// //                               ),
// //                               const SizedBox(width: 4),
// //                               Row(
// //                                 children: [
// //                                   Text(
// //                                     '(${profile?.rating ?? 0.0} ',
// //                                     style: GoogleFonts.roboto(
// //                                         fontSize: 13,
// //                                         fontWeight: FontWeight.bold),
// //                                   ),
// //                                   Icon(Icons.star,
// //                                       color: Colors.amber, size: 14),
// //                                   Text(
// //                                     ')',
// //                                     style: GoogleFonts.roboto(
// //                                         fontSize: 13,
// //                                         fontWeight: FontWeight.bold),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 10),
// //                       _buildProfileCard(),
// //                       const SizedBox(height: 16),
// //                       _buildHisWorkSection(),
// //                       const SizedBox(height: 12),
// //                       _buildDocumentCard(),
// //                       const SizedBox(height: 12),
// //                       widget.iconsHide == 'hide'
// //                           ? SizedBox()
// //                           : _buildAddAsapPersonTile(context),
// //                       const SizedBox(height: 12),
// //                       _buildCustomerReviews(),
// //                       const SizedBox(height: 30),
// //                     ],
// //                   ),
// //                 ),
// //         ));
// //   }
// //
// //   Widget _buildHeader(BuildContext context, dynamic profile) {
// //     final ServiceProviderProfileModel data =
// //         profile as ServiceProviderProfileModel;
// //     return ClipPath(
// //       clipper: BottomCurveClipper(),
// //       child: Container(
// //         color: const Color(0xFF9DF89D),
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //         height: 140,
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Row(
// //             //   children: [
// //             //     GestureDetector(
// //             //       onTap: () => Navigator.pop(context),
// //             //       child: const Padding(
// //             //         padding: EdgeInsets.only(left: 8.0),
// //             //         child: Icon(Icons.arrow_back, size: 25),
// //             //       ),
// //             //     ),
// //             //     Expanded(
// //             //       child: Center(
// //             //         child: Padding(
// //             //           padding: const EdgeInsets.only(right: 18.0),
// //             //           child: Text(
// //             //             "Worker Profile",
// //             //             style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
// //             //           ),
// //             //         ),
// //             //       ),
// //             //     ),
// //             //   ],
// //             // ),
// //             SizedBox(height: 16),
// //             Center(
// //                 child: data.verified == true
// //                     ? _buildRoleSwitcher(context, profile)
// //                     : SizedBox()),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildServiceproviderVerification(BuildContext context, String? role,
// //       String? requestStatus, bool status, String? categoryId) {
// //     print("Abhi:- print requestStatus : $requestStatus");
// //     if (categoryId == null && status == false) {
// //       return AlertDialog(
// //         title: const Center(child: Text("Verification Required")),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Image.asset("assets/images/confimationImage.png", height: 120),
// //             const SizedBox(height: 8),
// //             const Text(
// //               "Confirmation",
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
// //             ),
// //             const SizedBox(height: 2),
// //             const Text(
// //                 "If you’d like to become a service provider, kindly complete and submit the document form."),
// //             const SizedBox(height: 8),
// //           ],
// //         ),
// //         actions: [
// //           Center(
// //             child: Container(
// //               width: 100,
// //               height: 35,
// //               decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(8), color: Colors.green),
// //               child: TextButton(
// //                 child: const Text("Confirm",
// //                     style: TextStyle(color: Colors.white)),
// //                 onPressed: () async {
// //                   Navigator.of(context).pop();
// //                   Get.off(() => RoleEditProfileScreen(
// //                       updateBothrequest: true, role: profile?.role));
// //                 },
// //               ),
// //             ),
// //           ),
// //         ],
// //       );
// //     } else if (categoryId != null && status == false) {
// //       return AlertDialog(
// //         title: const Text("Request Submitted"),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Image.asset("assets/images/confimationImage.png", height: 120),
// //             const SizedBox(height: 8),
// //             const Text(
// //               "Request Status",
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
// //             ),
// //             const SizedBox(height: 2),
// //             const Text(
// //                 "Profile has been submitted\nwaiting for admin approval"),
// //             const SizedBox(height: 8),
// //           ],
// //         ),
// //         actions: [
// //           Center(
// //             child: Container(
// //               width: 100,
// //               height: 35,
// //               decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(8), color: Colors.green),
// //               child: TextButton(
// //                 child: const Text("OK", style: TextStyle(color: Colors.white)),
// //                 onPressed: () {
// //                   Navigator.of(context).pop();
// //                 },
// //               ),
// //             ),
// //           ),
// //         ],
// //       );
// //     }
// //     return const SizedBox.shrink();
// //   }
// //
// //   Widget _buildRoleSwitcher(BuildContext context, dynamic profile) {
// //     final ServiceProviderProfileModel data =
// //         profile as ServiceProviderProfileModel;
// //     const roleMap = {'User': 'user', 'Worker': 'service_provider'};
// //     final GetXRoleController roleController = Get.find<GetXRoleController>();
// //
// //     return Obx(() {
// //       final String selectedRole = roleController.role.value;
// //
// //       return Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           InkWell(
// //             child: _roleButton("User", selectedRole == "user", () async {
// //               if (selectedRole == "user") return;
// //               if (data.role == "both" &&
// //                   (data.requestStatus == null || data.requestStatus!.isEmpty)) {
// //                 await roleController.updateRole('user');
// //                 Get.off(() => ProfileScreen());
// //               } else {
// //                 if (data.requestStatus == null || data.requestStatus!.isEmpty) {
// //                   await switchRoleRequest();
// //                   await roleController.updateRole('user');
// //                   Get.off(() => ProfileScreen(swithcrole: ""));
// //                 } else {
// //                   showDialog(
// //                     context: context,
// //                     builder: (BuildContext context) {
// //                       return AlertDialog(
// //                         title: const Text("Request Submitted"),
// //                         content: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             SvgPicture.asset(
// //                                 "assets/svg_images/ConfirmationIcon.svg"),
// //                             const SizedBox(height: 8),
// //                             const Text(
// //                               "Request Status",
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 18),
// //                             ),
// //                             const SizedBox(height: 2),
// //                             const Text(
// //                                 "Your app request has been submitted, please wait 2–3 days."),
// //                             const SizedBox(height: 8),
// //                           ],
// //                         ),
// //                         actions: [
// //                           Container(
// //                             width: 100,
// //                             height: 35,
// //                             decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 color: Colors.green),
// //                             child: TextButton(
// //                               child: const Text("OK",
// //                                   style: TextStyle(color: Colors.white)),
// //                               onPressed: () {
// //                                 Navigator.of(context).pop();
// //                               },
// //                             ),
// //                           ),
// //                         ],
// //                       );
// //                     },
// //                   );
// //                 }
// //               }
// //             }),
// //           ),
// //           const SizedBox(width: 16),
// //           InkWell(
// //             child: _roleButton("Worker", selectedRole == "service_provider",
// //                 () async {
// //               if (selectedRole == "service_provider") return;
// //               if (data.role == "both" &&
// //                   (data.requestStatus == null || data.requestStatus!.isEmpty)) {
// //                 await roleController.updateRole('service_provider');
// //                 Get.off(() => SellerScreen());
// //               } else {
// //                 if (data.requestStatus == null || data.requestStatus!.isEmpty) {
// //                   showDialog(
// //                     context: context,
// //                     builder: (BuildContext context) {
// //                       return AlertDialog(
// //                         title: Center(child: const Text("Confirmation Box")),
// //                         content: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             SvgPicture.asset(
// //                                 "assets/svg_images/ConfirmationIcon.svg"),
// //                             const SizedBox(height: 8),
// //                             const Text(
// //                               "Confirmation",
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 18),
// //                             ),
// //                             const SizedBox(height: 2),
// //                             const Text(
// //                                 "Are you sure you want to switch\n                your profile?"),
// //                             const SizedBox(height: 8),
// //                           ],
// //                         ),
// //                         actions: [
// //                           Container(
// //                             width: 100,
// //                             height: 35,
// //                             decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 color: Colors.green),
// //                             child: TextButton(
// //                               child: const Text("Confirm",
// //                                   style: TextStyle(color: Colors.white)),
// //                               onPressed: () async {
// //                                 if (data.role == "both") {
// //                                   await roleController
// //                                       .updateRole('service_provider');
// //                                 } else {
// //                                   await switchRoleRequest();
// //                                 }
// //                                 Navigator.of(context).pop();
// //                                 Get.off(() => SellerScreen());
// //                               },
// //                             ),
// //                           ),
// //                           Container(
// //                             width: 100,
// //                             height: 35,
// //                             decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 border: Border.all(color: Colors.green)),
// //                             child: TextButton(
// //                               child: const Text("Cancel",
// //                                   style: TextStyle(color: Colors.black)),
// //                               onPressed: () {
// //                                 Navigator.of(context).pop();
// //                               },
// //                             ),
// //                           ),
// //                         ],
// //                       );
// //                     },
// //                   );
// //                 } else {
// //                   showDialog(
// //                     context: context,
// //                     builder: (BuildContext context) {
// //                       return AlertDialog(
// //                         title: const Text("Request Submitted"),
// //                         content: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Image.asset("assets/images/rolechangeConfim.png",
// //                                 height: 90),
// //                             const SizedBox(height: 8),
// //                             const Text(
// //                               "Request Status",
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 18),
// //                             ),
// //                             const SizedBox(height: 2),
// //                             const Text(
// //                                 "Your request has been submitted please for admin approval"),
// //                             const SizedBox(height: 8),
// //                           ],
// //                         ),
// //                         actions: [
// //                           Container(
// //                             width: 100,
// //                             height: 35,
// //                             decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 color: Colors.green),
// //                             child: TextButton(
// //                               child: const Text("OK",
// //                                   style: TextStyle(color: Colors.white)),
// //                               onPressed: () {
// //                                 Navigator.of(context).pop();
// //                               },
// //                             ),
// //                           ),
// //                         ],
// //                       );
// //                     },
// //                   );
// //                 }
// //               }
// //             }),
// //           ),
// //         ],
// //       );
// //     });
// //   }
// //
// //   Widget _roleButton(String title, bool isSelected, VoidCallback onTap) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         height: 35,
// //         width: 140,
// //         decoration: BoxDecoration(
// //           color: isSelected ? Colors.green.shade700 : Colors.white,
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(color: Colors.green.shade700),
// //         ),
// //         alignment: Alignment.center,
// //         child: Text(
// //           title,
// //           style: GoogleFonts.roboto(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 13,
// //             color: isSelected ? Colors.white : Colors.green.shade700,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProfileCard() {
// //     return Container(
// //       width: double.infinity,
// //       margin: const EdgeInsets.all(1),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFF9DF89D),
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //       child: Column(
// //         children: [
// //           const SizedBox(height: 10),
// //           Padding(
// //             padding: const EdgeInsets.all(8.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Center(
// //                   child: RichText(
// //                     text: TextSpan(
// //                       style: GoogleFonts.poppins(fontSize: 11),
// //                       children: [
// //                         TextSpan(
// //                           text: "Category: ",
// //                           style: GoogleFonts.roboto(
// //                             color: Colors.green.shade800,
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 12,
// //                           ),
// //                         ),
// //                         TextSpan(
// //                           text: profile?.categoryName ?? 'N/A',
// //                           style: const TextStyle(
// //                             color: Colors.black,
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 12,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Center(
// //                   child: Padding(
// //                     padding: const EdgeInsets.only(left: 18.0),
// //                     child: RichText(
// //                       text: TextSpan(
// //                         style: GoogleFonts.poppins(fontSize: 11),
// //                         children: [
// //                           TextSpan(
// //                             text: "Sub-Category: ",
// //                             style: GoogleFonts.roboto(
// //                               color: Colors.green.shade800,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 12,
// //                             ),
// //                           ),
// //                           TextSpan(
// //                             text:
// //                                 profile?.subCategoryNames?.join(', ') ?? 'N/A',
// //                             style: const TextStyle(
// //                               color: Colors.black,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 12,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 10),
// //           _buildEmergencyCard(),
// //           const SizedBox(height: 15),
// //           Container(
// //             decoration: const BoxDecoration(
// //               color: Color(0xffeaffea),
// //               borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(8.0),
// //               child: Column(
// //                 children: [
// //                   Padding(
// //                     padding: const EdgeInsets.only(bottom: 9, right: 8),
// //                     child: Align(
// //                       alignment: Alignment.topRight,
// //                       child: InkWell(
// //                         onTap: () {
// //                           Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                   builder: (context) => GalleryScreen(
// //                                       images: profile?.hisWork ?? [],
// //                                       serviceProviderId: profile?.id ?? "")));
// //                         },
// //                         child: Container(
// //                           width: 120,
// //                           height: 30,
// //                           child: Center(child: Text("Upload his work")),
// //                           decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(8),
// //                               border:
// //                                   Border.all(color: Colors.green, width: 3)),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   CarouselSlider(
// //                     options: CarouselOptions(
// //                       height: 160,
// //                       autoPlay: true,
// //                       enlargeCenterPage: true,
// //                       aspectRatio: 16 / 9,
// //                       autoPlayInterval: const Duration(seconds: 3),
// //                       autoPlayAnimationDuration:
// //                           const Duration(milliseconds: 800),
// //                       viewportFraction: 0.8,
// //                     ),
// //                     items: (_showReviews
// //                             ? (profile?.hisWork?.isNotEmpty ?? false)
// //                                 ? profile!.hisWork!
// //                                 : ['assets/images/d_png/No_Image_Available.jpg']
// //                             : (profile?.customerReview?.isNotEmpty ?? false)
// //                                 ? profile!.customerReview!
// //                                 : [
// //                                     'assets/images/d_png/No_Image_Available.jpg'
// //                                   ])
// //                         .map((imageUrl) {
// //                       return Builder(
// //                         builder: (BuildContext context) {
// //                           return GestureDetector(
// //                             onTap: imageUrl.startsWith('assets/')
// //                                 ? null
// //                                 : () {
// //                                     Get.to(() => FullImageScreen(
// //                                           imageUrl: imageUrl,
// //                                         )); /*_showReviews
// //                                   ? GalleryScreen(images: profile?.hisWork ?? [], serviceProviderId: profile?.id ?? "")
// //                                   : ReviewImagesScreen(images: profile?.customerReview ?? []));*/
// //                                   },
// //                             child: Container(
// //                               width: MediaQuery.of(context).size.width,
// //                               margin:
// //                                   const EdgeInsets.symmetric(horizontal: 5.0),
// //                               decoration: BoxDecoration(
// //                                   borderRadius: BorderRadius.circular(8)),
// //                               child: ClipRRect(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 child: imageUrl.startsWith('assets/')
// //                                     ? Image.asset(imageUrl, fit: BoxFit.cover)
// //                                     : Image.network(
// //                                         imageUrl,
// //                                         fit: BoxFit.cover,
// //                                         errorBuilder:
// //                                             (context, error, stackTrace) =>
// //                                                 Image.asset(
// //                                           'assets/images/d_png/No_Image_Available.jpg',
// //                                           fit: BoxFit.cover,
// //                                         ),
// //                                       ),
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       );
// //                     }).toList(),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16),
// //                     child: _buildTabButtons(),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmergencyCard() {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       margin: const EdgeInsets.symmetric(horizontal: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.green.shade200),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(Icons.warning_amber_rounded, color: Colors.red),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Text("Emergency task.",
// //                 style: GoogleFonts.roboto(fontWeight: FontWeight.w500)),
// //           ),
// //           SizedBox(
// //             width: 40,
// //             height: 20,
// //             child: Transform.scale(
// //               scale: 0.6,
// //               alignment: Alignment.centerLeft,
// //               child: Stack(
// //                 alignment: Alignment.center,
// //                 children: [
// //                   Switch(
// //                     value: _isSwitched,
// //                     onChanged: _isToggling
// //                         ? null
// //                         : (bool value) {
// //                             _checkEmergencyTask();
// //                           },
// //                     activeColor: Colors.red,
// //                     inactiveThumbColor: Colors.white,
// //                     inactiveTrackColor: Colors.grey.shade300,
// //                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //                   ),
// //                   if (_isToggling)
// //                     const CircularProgressIndicator(
// //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHisWorkSection() {
// //     return Container(
// //       width: double.infinity,
// //       margin: const EdgeInsets.symmetric(horizontal: 16),
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.only(bottom: 4),
// //             decoration: BoxDecoration(),
// //             child: Text("About My Skill",
// //                 style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
// //           ),
// //           const SizedBox(height: 8),
// //           Container(
// //             width: double.infinity,
// //             padding: const EdgeInsets.all(10),
// //             decoration: BoxDecoration(
// //               border: Border.all(color: Colors.green.shade700, width: 1.4),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Text(profile?.skill ?? '',
// //                 style: GoogleFonts.poppins(fontSize: 14)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDocumentCard() {
// //     return Container(
// //       height: 160,
// //       width: double.infinity,
// //       margin: const EdgeInsets.symmetric(horizontal: 16),
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey.shade300),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const SizedBox(height: 5),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text("Document",
// //                   style: GoogleFonts.roboto(
// //                       fontWeight: FontWeight.bold, fontSize: 16)),
// //               profile?.verified == true
// //                   ? Container(
// //                       width: 100,
// //                       decoration: BoxDecoration(
// //                           border: Border.all(color: Colors.green, width: 2),
// //                           borderRadius: BorderRadius.circular(10)),
// //                       child: Center(
// //                           child: Text("Verified",
// //                               style: TextStyle(
// //                                   color: Colors.green.shade700,
// //                                   fontWeight: FontWeight.w600))),
// //                     )
// //                   : SizedBox(),
// //             ],
// //           ),
// //           const SizedBox(height: 15),
// //           Row(
// //             children: [
// //               SvgPicture.asset("assets/svg_images/adharicon.svg"),
// //               const SizedBox(width: 20),
// //               Text("Valid Id Proof",
// //                   style: GoogleFonts.roboto(
// //                       fontWeight: FontWeight.w400, fontSize: 14)),
// //               const SizedBox(width: 50),
// //               if (profile?.documents != null && profile!.documents!.isNotEmpty)
// //                 InkWell(
// //                   onTap: () {
// //                     Get.to(FullImageScreen(imageUrl: profile?.documents ?? ""));
// //                   },
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(6),
// //                     child: Image.network(
// //                       profile!.documents!,
// //                       height: 90,
// //                       width: 105,
// //                       fit: BoxFit.cover,
// //                       errorBuilder: (_, __, ___) => Image.asset(
// //                         'assets/images/d_png/No_Image_Available.jpg',
// //                         height: 90,
// //                         width: 105,
// //                         fit: BoxFit.cover,
// //                       ),
// //                     ),
// //                   ),
// //                 )
// //               else
// //                 Text(
// //                   "(Not uploaded)",
// //                   style: TextStyle(
// //                       color: Colors.grey.shade600,
// //                       fontStyle: FontStyle.italic,
// //                       fontSize: 12),
// //                 ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildAddAsapPersonTile(BuildContext context) {
// //     return profile?.verified == true
// //         ? Container(
// //             margin: const EdgeInsets.symmetric(horizontal: 16),
// //             decoration: BoxDecoration(
// //                 color: Colors.white, borderRadius: BorderRadius.circular(12)),
// //             child: ListTile(
// //               leading: SvgPicture.asset(
// //                   'assets/svg_images/bottombar/profile-circle.svg'),
// //               title: Text("Add Assign Person",
// //                   style: GoogleFonts.roboto(fontSize: 13)),
// //               trailing: const Icon(Icons.arrow_forward, size: 20),
// //               onTap: () {
// //                 Get.to(() => const WorkerScreen());
// //               },
// //             ),
// //           )
// //         : SizedBox();
// //   }
// //
// //   Widget _buildTabButtons() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         _tabButton("His Work", _showReviews, () {
// //           setState(() => _showReviews = true);
// //         }),
// //         const SizedBox(width: 10),
// //         _tabButton("User Review", !_showReviews, () {
// //           setState(() => _showReviews = false);
// //         }),
// //       ],
// //     );
// //   }
// //
// //   Widget _tabButton(String title, bool selected, VoidCallback onTap) {
// //     return Expanded(
// //       child: GestureDetector(
// //         onTap: onTap,
// //         child: Container(
// //           height: 35,
// //           alignment: Alignment.center,
// //           decoration: BoxDecoration(
// //             color: selected ? Colors.green.shade700 : const Color(0xFFC3FBD8),
// //             borderRadius: BorderRadius.circular(10),
// //             border: Border.all(color: Colors.green.shade700),
// //           ),
// //           child: Text(
// //             title,
// //             style: GoogleFonts.poppins(
// //               fontWeight: FontWeight.w500,
// //               color: selected ? Colors.white : Colors.green.shade800,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget buildStarRating(double rating) {
// //     List<Widget> stars = [];
// //     int fullStars = rating.floor();
// //     bool hasHalfStar = (rating - fullStars) >= 0.5;
// //     for (int i = 0; i < 5; i++) {
// //       if (i < fullStars) {
// //         stars.add(const Icon(Icons.star, color: Colors.orange, size: 18));
// //       } else if (i == fullStars && hasHalfStar) {
// //         stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 18));
// //       } else {
// //         stars
// //             .add(const Icon(Icons.star_border, color: Colors.orange, size: 18));
// //       }
// //     }
// //     return Row(children: stars);
// //   }
// //
// //   Widget _buildCustomerReviews() {
// //     return Container(
// //       width: double.infinity,
// //       margin: const EdgeInsets.symmetric(horizontal: 16),
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Center(
// //             child: Text(
// //               "Rate & Reviews",
// //               style: GoogleFonts.poppins(
// //                   fontWeight: FontWeight.bold, fontSize: 16),
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           if (profile?.rateAndReviews?.isNotEmpty ?? false)
// //             ...profile!.rateAndReviews!.map(
// //               (r) => Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       buildStarRating(r.rating ?? 0),
// //                       const SizedBox(width: 6),
// //                       Text(
// //                         "(${r.rating?.toStringAsFixed(1)})",
// //                         style: const TextStyle(fontWeight: FontWeight.w500),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(r.review ?? ''),
// //                   const SizedBox(height: 6),
// //                   if ((r.images ?? []).isNotEmpty)
// //                     Wrap(
// //                       spacing: 8,
// //                       children: (r.images ?? [])
// //                           .map(
// //                             (img) => ClipRRect(
// //                               borderRadius: BorderRadius.circular(6),
// //                               child: Image.network(
// //                                 img,
// //                                 width: 50,
// //                                 height: 50,
// //                                 fit: BoxFit.cover,
// //                                 errorBuilder: (context, error, stackTrace) =>
// //                                     Image.asset(
// //                                   'assets/images/d_png/No_Image_Available.jpg',
// //                                   width: 50,
// //                                   height: 50,
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                               ),
// //                             ),
// //                           )
// //                           .toList(),
// //                     )
// //                   else
// //                     ClipRRect(
// //                       borderRadius: BorderRadius.circular(6),
// //                       child: Image.asset(
// //                         'assets/images/d_png/No_Image_Available.jpg',
// //                         width: 50,
// //                         height: 50,
// //                         fit: BoxFit.cover,
// //                       ),
// //                     ),
// //                   const Divider(),
// //                 ],
// //               ),
// //             )
// //           else
// //             Center(child: const Text("No reviews available.")),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class BottomCurveClipper extends CustomClipper<Path> {
// //   @override
// //   Path getClip(Size size) {
// //     return Path()
// //       ..lineTo(0, size.height - 40)
// //       ..quadraticBezierTo(
// //           size.width / 2, size.height, size.width, size.height - 30)
// //       ..lineTo(size.width, 0)
// //       ..close();
// //   }
// //
// //   @override
// //   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// // }
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import '../../../../Emergency/Service_Provider/controllers/sp_emergency_service_controller.dart';
// import '../../../../Emergency/utils/logger.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../../ServiceProvider/FullImageScreen.dart';
// import '../../ServiceProvider/GalleryScreen.dart';
// import '../../ServiceProvider/WorkerScreen.dart';
// import '../../auth/RoleSelectionScreen.dart';
// import '../../comm/home_location_screens.dart';
// import '../user_profile/UserProfileScreen.dart';
// import '../user_profile/user_role_profile_update.dart';
// import 'EditProfileScreen.dart';
//
// class SellerScreen extends StatefulWidget {
//   final iconsHide;
//
//   const SellerScreen({super.key, this.iconsHide});
//
//   @override
//   State<SellerScreen> createState() => _SellerScreenState();
// }
//
// class _SellerScreenState extends State<SellerScreen> {
//   bool _isSwitched = false;
//   bool _isToggling = false;
//   File? _pickedImage;
//   ServiceProviderProfileModel? profile;
//   bool isLoading = true;
//   bool _showReviews = true;
//   String? address = "";
//   final controller = Get.put(SpEmergencyServiceController());
//   final GetXRoleController roleController = Get.put(GetXRoleController());
//
//   @override
//   void initState() {
//     super.initState();
//     loadSavedLocation();
//     _loadEmergencyTask();
//     fetchProfile().then((_) {
//      print("Checking role: ${profile?.role}, verified: ${profile?.verificationStatus == 'pending'} request status: ${profile?.requestStatus}");
//       if (profile?.verificationStatus == 'pending') {
//         print("Showing verification dialog for service_provider");
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (context.mounted) {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 print("Inside dialog builder");
//                 return _buildServiceproviderVerification(
//                     context,
//                     profile?.role,
//                     profile?.requestStatus,
//                     profile?.verificationStatus ?? "",
//                     profile?.categoryId);
//               },
//             );
//           } else {
//             print("Context not mounted");
//           }
//         });
//       } else {
//         print("Dialog not shown: Role or verified condition not met");
//       }
//     });
//   }
//
//   Future<void> _loadEmergencyTask() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool saved = prefs.getBool("emergency_task") ?? false;
//     setState(() {
//       _isSwitched = saved;
//     });
//   }
//
//   Future<void> loadSavedLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? savedLocation = prefs.getString('location');
//     if (savedLocation != null) {
//       setState(() {
//         address = savedLocation;
//       });
//     }
//   }
//
//   Future<void> updateLocationOnServer(
//       String newAddress, double latitude, double longitude) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     final url =
//     Uri.parse("https://api.thebharatworks.com/api/user/updateLocation");
//     final response = await http.put(
//       url,
//       headers: {
//         HttpHeaders.authorizationHeader: 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'location': {
//           'latitude': latitude,
//           'longitude': longitude,
//           'address': newAddress,
//         },
//         'current_location': newAddress,
//         'full_address': newAddress,
//       }),
//     );
//     if (response.statusCode == 200) {
//       await prefs.setString('location', newAddress);
//       setState(() {
//         address = newAddress;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("✅ Location updated to $newAddress")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Failed to update location")),
//       );
//       print("Update Location Failed: ${response.body}");
//     }
//   }
//
//   Future<void> _pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//       });
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null || token.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text("🔐 Token not found. Please login again.")),
//         );
//         return;
//       }
//       final url =
//       Uri.parse("https://api.thebharatworks.com/api/user/updateProfilePic");
//       try {
//         var request = http.MultipartRequest("PUT", url)
//           ..headers['Authorization'] = 'Bearer $token'
//           ..files.add(
//               await http.MultipartFile.fromPath('profilePic', pickedFile.path));
//         final response = await request.send();
//         if (response.statusCode == 200) {
//           final responseData = await response.stream.bytesToString();
//           final jsonData = jsonDecode(responseData);
//           debugPrint("✅ Response: $jsonData");
//           if (jsonData['profilePic'] != null) {
//             setState(() {
//               profile?.profilePic = jsonData['profilePic'];
//               profile?.fullName = jsonData['full_name'];
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("✅ Profile picture updated")),
//             );
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(jsonData['message'] ?? "❌ Upload failed")),
//             );
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("❌ Upload failed! Try again.")),
//           );
//         }
//       } catch (e) {
//         debugPrint("Upload error: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("⚠️ Something went wrong!")),
//         );
//       }
//     }
//   }
//
//   Future<void> switchRoleRequest() async {
//     final String url =
//         "https://api.thebharatworks.com/api/user/request-role-upgrade";
//     print("Abhi:- switchRoleRequest url :$url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- switchRoleRequest response ${response.body}");
//         print("Abhi:- switchRoleRequest statusCode ${response.statusCode}");
//       } else {
//         print("Abhi:- else switchRoleRequest response ${response.body}");
//         print(
//             "Abhi:- else switchRoleRequest statusCode ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Abhi:- get Exception $e");
//     }
//   }
//
//   Future<void> fetchProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final url = Uri.parse(
//           "https://api.thebharatworks.com/api/user/getUserProfileData");
//       final response = await http.get(
//         url,
//         headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
//       );
//       print("Full API Response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("Data: $data");
//
//         if (data['status'] == true) {
//           final fetchedAddress =
//           data['data'] != null && data['data']['location'] != null
//               ? (data['data']['location']['address'] ?? 'Select Location')
//               : 'Select Location';
//
//           await prefs.setString("address", fetchedAddress);
//
//           setState(() {
//             profile = ServiceProviderProfileModel.fromJson(data['data']);
//             isLoading = false;
//             address = fetchedAddress;
//           });
//
//           print("Saved address: $fetchedAddress");
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(data["message"] ?? "Profile fetch failed")),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Server error, profile fetch failed!")),
//         );
//       }
//     } catch (e) {
//       print("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Something went wrong, try again!")),
//       );
//     }
//   }
//
//   Future<void> _checkEmergencyTask() async {
//     setState(() {
//       _isToggling = true;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final url =
//       Uri.parse("https://api.thebharatworks.com/api/user/emergency");
//
//       final response = await http.post(
//         url,
//         headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
//       );
//
//       bwDebug("Emergency API Response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data["success"] == true) {
//           setState(() {
//             _isSwitched = data["emergency_task"] ?? false;
//           });
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setBool("emergency_task", _isSwitched);
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(data["message"] ?? "Updated")),
//             );
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Error: ${response.statusCode}")),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       bwDebug("Error in Emergency API: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("An error occurred: $e")),
//         );
//       }
//     } finally {
//       controller.getEmergencySpOrderList();
//       setState(() {
//         _isToggling = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //  backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Color(0xFF9DF89D),
//           centerTitle: true,
//           title: const Text("Worker Profile",
//               style:
//               TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           leading: const BackButton(color: Colors.black),
//           actions: [],
//           systemOverlayStyle: SystemUiOverlayStyle(
//             statusBarColor: AppColors.primaryGreen,
//             statusBarIconBrightness: Brightness.light,
//           ),
//         ),
//         body: SafeArea(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//             child: Column(
//               children: [
//                 _buildHeader(context, profile),
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         InkWell(
//                           onTap: _pickImageFromCamera,
//                           child: Container(
//                             padding: EdgeInsets.all(3),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                   color: Colors.green.shade700,
//                                   width: 3.0),
//                             ),
//                             child: CircleAvatar(
//                               radius: 50,
//                               backgroundColor: Colors.grey.shade300,
//                               backgroundImage: _pickedImage != null
//                                   ? FileImage(_pickedImage!)
//                                   : (profile?.profilePic != null
//                                   ? NetworkImage(profile!.profilePic!)
//                                   : null) as ImageProvider?,
//                               child: _pickedImage == null &&
//                                   profile?.profilePic == null
//                                   ? const Icon(Icons.person,
//                                   size: 50, color: Colors.white)
//                                   : null,
//                             ),
//                           ),
//                         ),
//                         profile?.verificationStatus == 'pending'
//                             ? Positioned(
//                           bottom: 4,
//                           right: 4,
//                           child: InkWell(
//                             onTap: _pickImageFromCamera,
//                             child: const Icon(Icons.camera_alt,
//                                 size: 20, color: Colors.black),
//                           ),
//                         )
//                             : SizedBox(),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${profile?.fullName?[0].toUpperCase()}${profile?.fullName?.substring(1).toLowerCase() ?? ''}',
//                           style: GoogleFonts.roboto(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         widget.iconsHide == 'hide'
//                             ? SizedBox()
//                             : GestureDetector(
//                           onTap: () async {
//                             final result = await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     EditProfileScreen(
//                                       fullName: profile?.fullName,
//                                       age: profile?.age,
//                                       gender: profile?.gender,
//                                       skill: profile?.skill,
//                                       categoryId: profile?.categoryId,
//                                       subCategoryIds: profile
//                                           ?.subCategoryIds
//                                           ?.map((e) => e.toString())
//                                           .toList(),
//                                       documentUrl: profile?.documents,
//                                     ),
//                               ),
//                             );
//                             if (result == true) {
//                               fetchProfile();
//                             }
//                           },
//                           child:profile?.verificationStatus == 'pending'
//                               ? Container(
//                               padding: const EdgeInsets.all(6),
//                               width: 32,
//                               height: 32,
//                               child: SvgPicture.asset(
//                                   "assets/svg_images/editicon.svg"))
//                               : SizedBox(),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Age: ${profile?.age ?? 0}',
//                           style: GoogleFonts.roboto(
//                               fontSize: 13, fontWeight: FontWeight.w600),
//                         ),
//                         SizedBox(width: 6),
//                         Text(
//                           'Gender: ${profile?.gender?[0].toUpperCase() ?? "No data"}${profile?.gender?.substring(1).toLowerCase() ?? ''}',
//                           style: GoogleFonts.roboto(
//                               fontSize: 13, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.location_on,
//                             color: Colors.green.shade700, size: 16),
//                         const SizedBox(width: 4),
//                         Flexible(
//                           child: GestureDetector(
//                             onTap: () async {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       LocationSelectionScreen(
//                                         onLocationSelected: (String) {},
//                                       ),
//                                 ),
//                               );
//                               if (result != null) {
//                                 setState(() {
//                                   address = result;
//                                 });
//                                 await updateLocationOnServer(
//                                     result, 30.73508469999999, 79.0668788);
//                               }
//                             },
//                             child: Text(
//                               address ?? 'Select Location',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               softWrap: false,
//                               style: GoogleFonts.roboto(
//                                 fontSize: 12,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w500,
//                               ),
//
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "${profile?.totalReview ?? 0} Reviews",
//                           style: GoogleFonts.roboto(
//                               fontSize: 13, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(width: 4),
//                         Row(
//                           children: [
//                             Text(
//                               '(${profile?.rating ?? 0.0} ',
//                               style: GoogleFonts.roboto(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             Icon(Icons.star,
//                                 color: Colors.amber, size: 14),
//                             Text(
//                               ')',
//                               style: GoogleFonts.roboto(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 _buildProfileCard(),
//                 const SizedBox(height: 16),
//                 _buildHisWorkSection(),
//                 const SizedBox(height: 12),
//                 _buildDocumentCard(),
//                 const SizedBox(height: 12),
//                 widget.iconsHide == 'hide'
//                     ? SizedBox()
//                     : _buildAddAsapPersonTile(context),
//                 const SizedBox(height: 12),
//                 _buildCustomerReviews(),
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ));
//   }
//
//   Widget _buildHeader(BuildContext context, dynamic profile) {
//     final ServiceProviderProfileModel data =
//     profile as ServiceProviderProfileModel;
//     return ClipPath(
//       clipper: BottomCurveClipper(),
//       child: Container(
//         color: const Color(0xFF9DF89D),
//         padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
//         height: 130,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 16),
//             Center(
//                 child: /*data.verified == true
//                     ?*/ /*profile?.verificationStatus == 'pending' ?*/ _buildRoleSwitcher(context, profile),),
//                     /*: SizedBox()),*/
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceproviderVerification(BuildContext context, String? role,
//       String? requestStatus, String status, String? categoryId) {
//     print("Abhi:- print requestStatus : $requestStatus");
//     if (categoryId == null && status == false) {
//       return AlertDialog(
//         title: const Center(child: Text("Verification Required")),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset("assets/images/confimationImage.png", height: 120),
//             const SizedBox(height: 8),
//             const Text(
//               "Confirmation",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 2),
//             const Text(
//                 "If you’d like to become a service provider, kindly complete and submit the document form."),
//             const SizedBox(height: 8),
//           ],
//         ),
//         actions: [
//           Center(
//             child: Container(
//               width: 100,
//               height: 35,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8), color: Colors.green),
//               child: TextButton(
//                 child: const Text("Confirm",
//                     style: TextStyle(color: Colors.white)),
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   Get.off(() => RoleEditProfileScreen(
//                       updateBothrequest: true, role: profile?.role));
//                 },
//               ),
//             ),
//           ),
//         ],
//       );
//     } else if (categoryId != null && status == false) {
//       return AlertDialog(
//         title: const Text("Request Submitted"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset("assets/images/confimationImage.png", height: 120),
//             const SizedBox(height: 8),
//             const Text(
//               "Request Status",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 2),
//             const Text(
//                 "Profile has been submitted\nwaiting for admin approval"),
//             const SizedBox(height: 8),
//           ],
//         ),
//         actions: [
//           Center(
//             child: Container(
//               width: 100,
//               height: 35,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8), color: Colors.green),
//               child: TextButton(
//                 child: const Text("OK", style: TextStyle(color: Colors.white)),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//     return const SizedBox.shrink();
//   }
//
//   Widget _buildRoleSwitcher(BuildContext context, dynamic profile) {
//     final ServiceProviderProfileModel data =
//     profile as ServiceProviderProfileModel;
//     const roleMap = {'User': 'user', 'Worker': 'service_provider'};
//     final GetXRoleController roleController = Get.find<GetXRoleController>();
//
//     return Obx(() {
//       final String selectedRole = roleController.role.value;
//
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           InkWell(
//             child: _roleButton("User", selectedRole == "user", () async {
//               if (selectedRole == "user") return;
//               if (data.role == "both" &&
//                   (data.requestStatus == null || data.requestStatus!.isEmpty)) {
//                 await roleController.updateRole('user');
//                 Get.off(() => ProfileScreen());
//               } else {
//                 if (data.requestStatus == null || data.requestStatus!.isEmpty) {
//                   await switchRoleRequest();
//                   await roleController.updateRole('user');
//                   Get.off(() => ProfileScreen(swithcrole: ""));
//                 } else {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text("Request Submitted"),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SvgPicture.asset(
//                                 "assets/svg_images/ConfirmationIcon.svg"),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Request Status",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 18),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text("Your app request has been submitted, please wait 2–3 days."),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                         actions: [
//                           Container(
//                             width: 100,
//                             height: 35,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.green),
//                             child: TextButton(
//                               child: const Text("OK",
//                                   style: TextStyle(color: Colors.white)),
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
//               }
//             }),
//           ),
//           const SizedBox(width: 16),
//           InkWell(
//             child: _roleButton("Worker", selectedRole == "service_provider",
//                     () async {
//                   if (selectedRole == "service_provider") return;
//                   if (data.role == "both" &&
//                       (data.requestStatus == null || data.requestStatus!.isEmpty)) {
//                     await roleController.updateRole('service_provider');
//                     Get.off(() => SellerScreen());
//                   } else {
//                     if (data.requestStatus == null || data.requestStatus!.isEmpty) {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: Center(child: const Text("Confirmation Box")),
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SvgPicture.asset(
//                                     "assets/svg_images/ConfirmationIcon.svg"),
//                                 const SizedBox(height: 8),
//                                 const Text(
//                                   "Confirmation",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold, fontSize: 18),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 const Text(
//                                     "Are you sure you want to switch\n                your profile?"),
//                                 const SizedBox(height: 8),
//                               ],
//                             ),
//                             actions: [
//                               Container(
//                                 width: 100,
//                                 height: 35,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8),
//                                     color: Colors.green),
//                                 child: TextButton(
//                                   child: const Text("Confirm",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () async {
//                                     if (data.role == "both") {
//                                       await roleController
//                                           .updateRole('service_provider');
//                                     } else {
//                                       await switchRoleRequest();
//                                     }
//                                     Navigator.of(context).pop();
//                                     Get.off(() => SellerScreen());
//                                   },
//                                 ),
//                               ),
//                               Container(
//                                 width: 100,
//                                 height: 35,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(color: Colors.green)),
//                                 child: TextButton(
//                                   child: const Text("Cancel",
//                                       style: TextStyle(color: Colors.black)),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     } else {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: const Text("Request Submitted"),
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Image.asset("assets/images/rolechangeConfim.png",
//                                     height: 90),
//                                 const SizedBox(height: 8),
//                                 const Text(
//                                   "Request Status",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold, fontSize: 18),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 const Text(
//                                     "Your request has been submitted please for admin approval"),
//                                 const SizedBox(height: 8),
//                               ],
//                             ),
//                             actions: [
//                               Container(
//                                 width: 100,
//                                 height: 35,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8),
//                                     color: Colors.green),
//                                 child: TextButton(
//                                   child: const Text("OK",
//                                       style: TextStyle(color: Colors.white)),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     }
//                   }
//                 }),
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
//
//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.all(1),
//       decoration: BoxDecoration(
//         color: const Color(0xFF9DF89D),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(
//                   child: RichText(
//                     text: TextSpan(
//                       style: GoogleFonts.poppins(fontSize: 11),
//                       children: [
//                         TextSpan(
//                           text: "Category: ",
//                           style: GoogleFonts.roboto(
//                             color: Colors.green.shade800,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         TextSpan(
//                           text: profile?.categoryName ?? 'N/A',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 18.0),
//                     child: RichText(
//                       text: TextSpan(
//                         style: GoogleFonts.poppins(fontSize: 11),
//                         children: [
//                           TextSpan(
//                             text: "Sub-Category: ",
//                             style: GoogleFonts.roboto(
//                               color: Colors.green.shade800,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                           TextSpan(
//                             text:
//                             profile?.subCategoryNames?.join(', ') ?? 'N/A',
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           _buildEmergencyCard(),
//           const SizedBox(height: 15),
//           Container(
//             decoration: const BoxDecoration(
//               color: Color(0xffeaffea),
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 9, right: 8),
//                     child: Align(
//                       alignment: Alignment.topRight,
//                       child: InkWell(
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => GalleryScreen(
//                                       images: profile?.hisWork ?? [],
//                                       serviceProviderId: profile?.id ?? "")));
//                         },
//                         child: Container(
//                           width: 120,
//                           height: 30,
//                           child: Center(child: Text("Upload his work")),
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                               border:
//                               Border.all(color: Colors.green, width: 3)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   CarouselSlider(
//                     options: CarouselOptions(
//                       height: 160,
//                       autoPlay: true,
//                       enlargeCenterPage: true,
//                       aspectRatio: 16 / 9,
//                       autoPlayInterval: const Duration(seconds: 3),
//                       autoPlayAnimationDuration:
//                       const Duration(milliseconds: 800),
//                       viewportFraction: 0.8,
//                     ),
//                     items: (_showReviews
//                         ? (profile?.hisWork?.isNotEmpty ?? false)
//                         ? profile!.hisWork!
//                         : ['assets/images/d_png/No_Image_Available.jpg']
//                         : (profile?.customerReview?.isNotEmpty ?? false)
//                         ? profile!.customerReview!
//                         : [
//                       'assets/images/d_png/No_Image_Available.jpg'
//                     ])
//                         .map((imageUrl) {
//                       return Builder(
//                         builder: (BuildContext context) {
//                           return GestureDetector(
//                             onTap: imageUrl.startsWith('assets/')
//                                 ? null
//                                 : () {
//                               Get.to(() => FullImageScreen(
//                                 imageUrl: imageUrl,
//                               )); /*_showReviews
//                                   ? GalleryScreen(images: profile?.hisWork ?? [], serviceProviderId: profile?.id ?? "")
//                                   : ReviewImagesScreen(images: profile?.customerReview ?? []));*/
//                             },
//                             child: Container(
//                               width: MediaQuery.of(context).size.width,
//                               margin:
//                               const EdgeInsets.symmetric(horizontal: 5.0),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8)),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: imageUrl.startsWith('assets/')
//                                     ? Image.asset(imageUrl, fit: BoxFit.cover)
//                                     : Image.network(
//                                   imageUrl,
//                                   fit: BoxFit.cover,
//                                   errorBuilder:
//                                       (context, error, stackTrace) =>
//                                       Image.asset(
//                                         'assets/images/d_png/No_Image_Available.jpg',
//                                         fit: BoxFit.cover,
//                                       ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: _buildTabButtons(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmergencyCard() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.green.shade200),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.warning_amber_rounded, color: Colors.red),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text("Emergency task.",
//                 style: GoogleFonts.roboto(fontWeight: FontWeight.w500)),
//           ),
//           SizedBox(
//             width: 40,
//             height: 20,
//             child: Transform.scale(
//               scale: 0.6,
//               alignment: Alignment.centerLeft,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Switch(
//                     value: _isSwitched,
//                     onChanged: _isToggling
//                         ? null
//                         : (bool value) {
//                       _checkEmergencyTask();
//                     },
//                     activeColor: Colors.red,
//                     inactiveThumbColor: Colors.white,
//                     inactiveTrackColor: Colors.grey.shade300,
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   if (_isToggling)
//                     const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHisWorkSection() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.only(bottom: 4),
//             decoration: BoxDecoration(),
//             child: Text("About My Skill",
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.green.shade700, width: 1.4),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(profile?.skill ?? '',
//                 style: GoogleFonts.poppins(fontSize: 14)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDocumentCard() {
//     return Container(
//       height: 160,
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 5),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("Document",
//                   style: GoogleFonts.roboto(
//                       fontWeight: FontWeight.bold, fontSize: 16)),
//               profile?.verificationStatus == 'pending'
//                   ? Container(
//                 width: 100,
//                 decoration: BoxDecoration(
//                     border: Border.all(color: Colors.green, width: 2),
//                     borderRadius: BorderRadius.circular(10)),
//                 child: Center(
//                     child: Text("Verified",
//                         style: TextStyle(
//                             color: Colors.green.shade700,
//                             fontWeight: FontWeight.w600))),
//               )
//                   : SizedBox(),
//             ],
//           ),
//           const SizedBox(height: 15),
//           Row(
//             children: [
//               SvgPicture.asset("assets/svg_images/adharicon.svg"),
//               const SizedBox(width: 20),
//               Text("Valid Id Proof",
//                   style: GoogleFonts.roboto(
//                       fontWeight: FontWeight.w400, fontSize: 14)),
//               const SizedBox(width: 50),
//               if (profile?.documents != null && profile!.documents!.isNotEmpty)
//                 InkWell(
//                   onTap: () {
//                     Get.to(FullImageScreen(imageUrl: profile?.documents ?? ""));
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(6),
//                     child: Image.network(
//                       profile!.documents!,
//                       height: 90,
//                       width: 105,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => Image.asset(
//                         'assets/images/d_png/No_Image_Available.jpg',
//                         height: 90,
//                         width: 105,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 )
//               else
//                 Text(
//                   "(Not uploaded)",
//                   style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontStyle: FontStyle.italic,
//                       fontSize: 12),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddAsapPersonTile(BuildContext context) {
//     return profile?.verificationStatus == 'pending'
//         ? Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//           color: Colors.white, borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: SvgPicture.asset(
//             'assets/svg_images/bottombar/profile-circle.svg'),
//         title: Text("Add Assign Person",
//             style: GoogleFonts.roboto(fontSize: 13)),
//         trailing: const Icon(Icons.arrow_forward, size: 20),
//         onTap: () {
//           Get.to(() => const WorkerScreen());
//         },
//       ),
//     )
//         : SizedBox();
//   }
//
//   Widget _buildTabButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _tabButton("His Work", _showReviews, () {
//           setState(() => _showReviews = true);
//         }),
//         const SizedBox(width: 10),
//         _tabButton("User Review", !_showReviews, () {
//           setState(() => _showReviews = false);
//         }),
//       ],
//     );
//   }
//
//   Widget _tabButton(String title, bool selected, VoidCallback onTap) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           height: 35,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: selected ? Colors.green.shade700 : const Color(0xFFC3FBD8),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.green.shade700),
//           ),
//           child: Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w500,
//               color: selected ? Colors.white : Colors.green.shade800,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildStarRating(double rating) {
//     List<Widget> stars = [];
//     int fullStars = rating.floor();
//     bool hasHalfStar = (rating - fullStars) >= 0.5;
//     for (int i = 0; i < 5; i++) {
//       if (i < fullStars) {
//         stars.add(const Icon(Icons.star, color: Colors.orange, size: 18));
//       } else if (i == fullStars && hasHalfStar) {
//         stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 18));
//       } else {
//         stars
//             .add(const Icon(Icons.star_border, color: Colors.orange, size: 18));
//       }
//     }
//     return Row(children: stars);
//   }
//
//   Widget _buildCustomerReviews() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Text(
//               "Rate & Reviews",
//               style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ),
//           const SizedBox(height: 8),
//           if (profile?.rateAndReviews?.isNotEmpty ?? false)
//             ...profile!.rateAndReviews!.map(
//                   (r) => Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       buildStarRating(r.rating ?? 0),
//                       const SizedBox(width: 6),
//                       Text(
//                         "(${r.rating?.toStringAsFixed(1)})",
//                         style: const TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(r.review ?? ''),
//                   const SizedBox(height: 6),
//                   if ((r.images ?? []).isNotEmpty)
//                     Wrap(
//                       spacing: 8,
//                       children: (r.images ?? [])
//                           .map(
//                             (img) => ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: Image.network(
//                             img,
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) =>
//                                 Image.asset(
//                                   'assets/images/d_png/No_Image_Available.jpg',
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.cover,
//                                 ),
//                           ),
//                         ),
//                       )
//                           .toList(),
//                     )
//                   else
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(6),
//                       child: Image.asset(
//                         'assets/images/d_png/No_Image_Available.jpg',
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   const Divider(),
//                 ],
//               ),
//             )
//           else
//             Center(child: const Text("No reviews available.")),
//         ],
//       ),
//     );
//   }
// }
//
// class BottomCurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     return Path()
//       ..lineTo(0, size.height - 40)
//       ..quadraticBezierTo(
//           size.width / 2, size.height, size.width, size.height - 30)
//       ..lineTo(size.width, 0)
//       ..close();
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }