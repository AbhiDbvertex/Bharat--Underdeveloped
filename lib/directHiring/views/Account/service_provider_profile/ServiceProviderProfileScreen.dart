// import 'dart:convert';
// import 'dart:io';
// import 'package:developer/views/ServiceProvider/GalleryScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../../Widgets/Bottombar.dart';
// import '../../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../../ServiceProvider/WorkerScreen.dart';
// import '../../auth/RoleSelectionScreen.dart';
// import '../../comm/home_location_screens.dart';
// import '../user_profile/UserProfileScreen.dart';
// import 'EditProfileScreen.dart';
// import 'HisWorkScreen.dart';
// import 'ReviewImagesScreen.dart';
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
//   File? _pickedImage;
//   ServiceProviderProfileModel? profile;
//   bool isLoading = true;
//   bool _showReviews = true;
//   String? address = "";
//   final GetXRoleController roleController = Get.put(
//     GetXRoleController(),
//   ); // Updated to GetXRoleController
//
//   @override
//   void initState() {
//     super.initState();
//     loadSavedLocation();
//     fetchProfile();
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
//       String newAddress,
//       double latitude,
//       double longitude,
//       ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     final url = Uri.parse(
//       "https://api.thebharatworks.com/api/user/updateLocation",
//     );
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
//             content: Text("🔐 Token not found. Please login again."),
//           ),
//         );
//         return;
//       }
//       final url = Uri.parse(
//         "https://api.thebharatworks.com/api/user/updateProfilePic",
//       );
//       try {
//         var request =
//         http.MultipartRequest("PUT", url)
//           ..headers['Authorization'] = 'Bearer $token'
//           ..files.add(
//             await http.MultipartFile.fromPath(
//               'profilePic',
//               pickedFile.path,
//             ),
//           );
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
//   Future<void> fetchProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final url = Uri.parse(
//         "https://api.thebharatworks.com/api/user/getUserProfileData",
//       );
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
//         child:
//         isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildHeader(context,profile),
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       InkWell(
//                         onTap: _pickImageFromCamera,
//                         child: Container(
//                           padding: EdgeInsets.all(3),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.green.shade700,
//                               width: 3.0,
//                             ),
//                           ),
//                           child: CircleAvatar(
//                             radius: 50,
//                             backgroundColor: Colors.grey.shade300,
//                             backgroundImage:
//                             _pickedImage != null
//                                 ? FileImage(_pickedImage!)
//                                 : (profile?.profilePic != null
//                                 ? NetworkImage(
//                               profile!.profilePic!,
//                             )
//                                 : null)
//                             as ImageProvider?,
//                             child:
//                             _pickedImage == null &&
//                                 profile?.profilePic == null
//                                 ? const Icon(
//                               Icons.person,
//                               size: 50,
//                               color: Colors.white,
//                             )
//                                 : null,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 4,
//                         right: 4,
//                         child: InkWell(
//                           onTap: _pickImageFromCamera,
//                           child: const Icon(
//                             Icons.camera_alt,
//                             size: 20,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     // profile?.fullName ?? '',
//                     '${profile?.fullName?[0].toUpperCase()}${profile?.fullName?.substring(1).toLowerCase()}',
//                     style: GoogleFonts.roboto(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: Colors.green.shade700,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       GestureDetector(
//                         onTap: () async {
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (context) => LocationSelectionScreen(
//                                 onLocationSelected: (String) {},
//                               ),
//                             ),
//                           );
//                           if (result != null) {
//                             setState(() {
//                               address = result;
//                             });
//                             await updateLocationOnServer(
//                               result,
//                               30.73508469999999,
//                               79.0668788,
//                             );
//                           }
//                         },
//                         child: Text(
//                           address ?? 'Select Location',
//                           style: GoogleFonts.roboto(
//                             fontSize: 12,
//                             color: Colors.black,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       widget.iconsHide == 'hide'
//                           ? SizedBox()
//                           : GestureDetector(
//                         onTap: () async {
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (context) => EditProfileScreen(
//                                 fullName: profile?.fullName,
//                                 skill: profile?.skill,
//                                 categoryId: profile?.categoryId,
//                                 subCategoryIds:
//                                 profile?.subCategoryIds
//                                     ?.map(
//                                       (e) => e.toString(),
//                                 )
//                                     .toList(),
//                                 documentUrl: profile?.documents,
//                               ),
//                             ),
//                           );
//                           if (result == true) {
//                             fetchProfile();
//                           }
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           width: 32,
//                           height: 32,
//                           child:/* Image.asset(
//                             'assets/images/edit1.png',
//                             height: 18,
//                           ),*/SvgPicture.asset("assets/svg_images/editicon.svg")
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "${profile?.totalReview ?? 0} Reviews",
//                         style: GoogleFonts.roboto(
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Row(
//                         children: [
//                           Text(
//                             '(${profile?.rating ?? 0.0} ',
//                             style: GoogleFonts.roboto(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 14,
//                           ),
//                           Text(
//                             ')',
//                             style: GoogleFonts.roboto(
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               _buildProfileCard(),
//               const SizedBox(height: 16),
//               _buildHisWorkSection(),
//               const SizedBox(height: 12),
//               const SizedBox(height: 10),
//               _buildDocumentCard(),
//               const SizedBox(height: 12),
//               widget.iconsHide == 'hide'
//                   ? SizedBox()
//                   : _buildAddAsapPersonTile(context),
//               const SizedBox(height: 12),
//               _buildCustomerReviews(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context, dynamic profile) {
//     final ServiceProviderProfileModel data = profile as ServiceProviderProfileModel;
//     return ClipPath(
//         clipper: BottomCurveClipper(),
//         child: Container(
//           color: const Color(0xFF9DF89D),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           height: 140,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Padding(
//                       padding: EdgeInsets.only(left: 8.0),
//                       child: Icon(Icons.arrow_back, size: 25),
//                     ),
//                   ),
//                   const SizedBox(width: 100),
//                   Text(
//                     "Profile",
//                     style: GoogleFonts.roboto(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               Center(child: _buildRoleSwitcher(context, profile)),
//             ],
//           ),
//         ),
//     );
//   }
//
//   Widget _buildRoleSwitcher(BuildContext context, dynamic profile) {
//     final ServiceProviderProfileModel data = profile as ServiceProviderProfileModel;
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
//               // Agar selectedRole already "user" hai, toh kuch nahi karna
//               if (selectedRole == "user") {
//                 return;
//               }
//               // Agar role "both" hai aur requestStatus null ya empty hai
//               if (data.role == "both" && (data.requestStatus == null || data.requestStatus!.isEmpty)) {
//                 await roleController.updateRole('user');
//                 Get.off(() => ProfileScreen());
//               } else {
//                 // Agar requestStatus null ya empty hai
//                 if (data.requestStatus == null || data.requestStatus!.isEmpty) {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Center(child: const Text("Confirmation Box")),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset(
//                               "assets/images/rolechangeConfim.png",
//                               height: 90,
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Confirmation",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text("Are you sure you want to switch\n                your profile?"),
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
//                                 // if (data.role == "both") {
//                                 //   await roleController.updateRole('user');              //  <<<<---------<-     this code is currect show please dont change without permission!!!!
//                                 // }
//                                 // Navigator.of(context).pop();
//                                 // Get.off(() => ProfileScreen(swithcrole: "serviceroleSwitch",));
//                                 await switchRoleRequest();
//                                 if (data.role == "both") {
//                                   await roleController.updateRole('user');              //  <<<<---------<-     this code is currect show please dont change without permission!!!!
//                                 }
//                                 Navigator.of(context).pop();
//                                 Get.off(() => ProfileScreen(swithcrole: "",));
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
//                   // Jab requestStatus null ya empty nahi hai
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text("Request Submitted"),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset(
//                               "assets/images/rolechangeConfim.png",
//                               height: 90,
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Request Status",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text(
//                               "App ki request submit ho gayi hai, 2-3 din ka wait kariye.",
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
//                                 "OK",
//                                 style: TextStyle(color: Colors.white),
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
//               }
//             }),
//           ),
//           const SizedBox(width: 16),
//           InkWell(
//             child: _roleButton("Worker", selectedRole == "service_provider", () async {
//               // Agar selectedRole already "service_provider" hai, toh kuch nahi karna
//               if (selectedRole == "service_provider") {
//                 return;
//               }
//               // Agar role "both" hai aur requestStatus null ya empty hai
//               if (data.role == "both" && (data.requestStatus == null || data.requestStatus!.isEmpty)) {
//                 await roleController.updateRole('service_provider');
//                 Get.off(() => SellerScreen());
//               } else {
//                 // Agar requestStatus null ya empty hai
//                 if (data.requestStatus == null || data.requestStatus!.isEmpty) {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Center(child: const Text("Confirmation Box")),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset(
//                               "assets/images/rolechangeConfim.png",
//                               height: 90,
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Confirmation",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text("Are you sure you want to switch\n                your profile?"),
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
//                                 if (data.role == "both") {
//                                   await roleController.updateRole('service_provider');
//                                 } else {
//                                   await switchRoleRequest();
//                                 }
//                                 Navigator.of(context).pop();
//                                 Get.off(() => SellerScreen());
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
//                   // Jab requestStatus null ya empty nahi hai
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text("Request Submitted"),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset(
//                               "assets/images/rolechangeConfim.png",
//                               height: 90,
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Request Status",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text(
//                               "App ki request submit ho gayi hai, 2-3 din ka wait kariye.",
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
//                                 "OK",
//                                 style: TextStyle(color: Colors.white),
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
//               }
//             }),
//           ),
//         ],
//       );
//     });
//   }
//
// /*  Widget _buildHeader(BuildContext context,dynamic profile) {
//     final ServiceProviderProfileModel data = profile as ServiceProviderProfileModel;
//     return ClipPath(
//       clipper: BottomCurveClipper(),
//       child: Container(
//         color: const Color(0xFF9DF89D),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         height: 140,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Padding(
//                     padding: EdgeInsets.only(left: 8.0),
//                     child: Icon(Icons.arrow_back, size: 25),
//                   ),
//                 ),
//                 const SizedBox(width: 100),
//                 Text(
//                   "Profile",
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//             data.requestStatus == null ? Center(child: _buildRoleSwitcher(context,profile)) : Container(child: Text("No role found!"),),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildRoleSwitcher(BuildContext context, dynamic profile) {
//     final ServiceProviderProfileModel data = profile as ServiceProviderProfileModel;
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
//               // Agar role "both" hai aur requestStatus null ya empty hai
//               if (data.role == "both" && (data.requestStatus == null || data.requestStatus!.isEmpty)) {
//                 if (selectedRole != "user") {
//                   await roleController.updateRole('user');
//                   Get.off(() => ProfileScreen());
//                 }
//               } else {
//                 // Agar requestStatus null ya empty hai
//                 if (data.requestStatus == null || data.requestStatus!.isEmpty) {
//                   if (selectedRole != "user") {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           title: Center(child: const Text("Confirmation Box")),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Image.asset(
//                                 "assets/images/rolechangeConfim.png",
//                                 height: 90,
//                               ),
//                               const SizedBox(height: 8),
//                               const Text(
//                                 "Confirmation",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               const Text("Do you want to change your role?"),
//                               const SizedBox(height: 8),
//                             ],
//                           ),
//                           actions: [
//                             Container(
//                               width: 100,
//                               height: 35,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.green,
//                               ),
//                               child: TextButton(
//                                 child: const Text(
//                                   "Confirm",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 onPressed: () async {
//                                   if(data.role == "both"){
//                                     await roleController.updateRole('user');
//                                     Navigator.of(context).pop();
//                                     return;
//                                   }else{
//                                     await roleController.updateRole('user');
//                                     Navigator.of(context).pop();
//                                     switchRoleRequest();
//                                     Get.off(() => ProfileScreen());
//                                   }
//                                 },
//                               ),
//                             ),
//                             Container(
//                               width: 100,
//                               height: 35,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Colors.green),
//                               ),
//                               child: TextButton(
//                                 child: const Text(
//                                   "Cancel",
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 },
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   }
//                 } else {
//                   // Jab requestStatus null ya empty nahi hai
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text("Request Submitted"),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset(
//                               "assets/images/rolechangeConfim.png",
//                               height: 90,
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Request Status",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text(
//                               "App ki request submit ho gayi hai, 2-3 din ka wait kariye.",
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
//                                 "OK",
//                                 style: TextStyle(color: Colors.white),
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
//               }
//             }),
//           ),
//           const SizedBox(width: 16),
//           InkWell(
//             child: _roleButton("Worker", selectedRole == "service_provider", () async {
//               // Agar role "both" hai aur requestStatus null ya empty hai
//               if (data.role == "both" && (data.requestStatus == null || data.requestStatus!.isEmpty)) {
//                 if (selectedRole != "service_provider") {
//                   await roleController.updateRole('service_provider');
//                   Get.off(() => SellerScreen());
//                 }
//               } else {
//                 // Agar requestStatus null ya empty hai
//                 if (data.requestStatus == null || data.requestStatus!.isEmpty) {
//                   if (selectedRole != "service_provider") {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           title: Center(child: const Text("Confirmation Box")),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Image.asset(
//                                 "assets/images/rolechangeConfim.png",
//                                 height: 90,
//                               ),
//                               const SizedBox(height: 8),
//                               const Text(
//                                 "Confirmation",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               const Text("Do you want to change your role?"),
//                               const SizedBox(height: 8),
//                             ],
//                           ),
//                           actions: [
//                             Container(
//                               width: 100,
//                               height: 35,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.green,
//                               ),
//                               child: TextButton(
//                                 child: const Text(
//                                   "Confirm",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 onPressed: () async {
//                                   await roleController.updateRole('service_provider');
//                                   Navigator.of(context).pop();
//                                   Get.off(() => SellerScreen());
//                                 },
//                               ),
//                             ),
//                             Container(
//                               width: 100,
//                               height: 35,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Colors.green),
//                               ),
//                               child: TextButton(
//                                 child: const Text(
//                                   "Cancel",
//                                   style: TextStyle(color: Colors.black),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 },
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   }
//                 } else {
//                   // Jab requestStatus null ya empty nahi hai
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text("Request Submitted"),
//                         content: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Image.asset(
//                               "assets/images/rolechangeConfim.png",
//                               height: 90,
//                             ),
//                             const SizedBox(height: 8),
//                             const Text(
//                               "Request Status",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 18,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             const Text(
//                               "App ki request submit ho gayi hai, 2-3 din ka wait kariye.",
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
//                                 "OK",
//                                 style: TextStyle(color: Colors.white),
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
//               }
//             }),
//           ),
//         ],
//       );
//     });
//   }*/
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
//           const SizedBox(height: 10),
//           Container(
//             decoration: const BoxDecoration(
//               color: Color(0xffeaffea),
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
//             ),
//             child: Column(
//               children: [
//                 Image.asset(
//                   "assets/images/task.png",
//                   height: 160,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: _buildTabButtons(),
//                 ),
//               ],
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
//             child: Text(
//               "Emergency task.",
//               style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
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
//             child: Text(
//               "About My Skill",
//               style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.green.shade700, width: 1.4),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               profile?.skill ?? '',
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
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
//           Text(
//             "Document",
//             style: GoogleFonts.roboto(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Row(
//             children: [
//               // Image.asset('assets/images/line2.png', height: 24),
//               SvgPicture.asset("assets/svg_images/adharicon.svg"),
//               const SizedBox(width: 20),
//               Text(
//                 "Aadhar card",
//                 style: GoogleFonts.roboto(
//                   fontWeight: FontWeight.w400,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(width: 50),
//               if (profile?.documents != null && profile!.documents!.isNotEmpty)
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: Image.network(
//                     profile!.documents!,
//                     height: 80,
//                     width: 80,
//                     fit: BoxFit.cover,
//                     errorBuilder:
//                         (_, __, ___) => const Icon(Icons.broken_image),
//                   ),
//                 )
//               else
//                 Text(
//                   "(Not uploaded)",
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontStyle: FontStyle.italic,
//                     fontSize: 12,
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddAsapPersonTile(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         // leading: Image.asset('assets/svg_images/assign.png'),
//       leading: SvgPicture.asset('assets/svg_images/bottombar/profile-circle.svg'),
//         title: Text("Assign Person", style: GoogleFonts.roboto(fontSize: 13)),
//         trailing: const Icon(Icons.arrow_forward, size: 20),
//         onTap: () {
//           Get.to(() => const WorkerScreen());
//         },
//       ),
//     );
//   }
//
//   Widget _buildTabButtons() {
//     return Row(
//       children: [
//         _tabButton("His Work", _showReviews, () {
//           setState(() => _showReviews = true);
//           Get.to(() => GalleryScreen(images: profile?.hisWork ?? [], serviceProviderId: profile?.id ?? ""));
//         }),
//         const SizedBox(width: 10),
//         _tabButton("User Review", !_showReviews, () {
//           Get.to(
//                 () => ReviewImagesScreen(images: profile?.customerReview ?? []),
//           );
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
//             color: const Color(0xFFC3FBD8),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w300,
//               color: Colors.green.shade800,
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
//         stars.add(
//           const Icon(Icons.star_border, color: Colors.orange, size: 18),
//         );
//       }
//     }
//     return Row(children: stars);
//   }
//
//   Widget _buildCustomerReviews() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Rate & Reviews",
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 8),
//           if (_showReviews)
//             if (profile?.rateAndReviews?.isNotEmpty ?? false)
//               ...profile!.rateAndReviews!.map(
//                     (r) => Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         buildStarRating(r.rating ?? 0),
//                         const SizedBox(width: 6),
//                         Text(
//                           "(${r.rating?.toStringAsFixed(1)})",
//                           style: const TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(r.review ?? ''),
//                     const SizedBox(height: 6),
//                     if ((r.images ?? []).isNotEmpty)
//                       Wrap(
//                         spacing: 8,
//                         children:
//                         (r.images ?? [])
//                             .map(
//                               (img) => ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: Image.network(
//                               img,
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         )
//                             .toList(),
//                       ),
//                     const Divider(),
//                   ],
//                 ),
//               )
//             else
//               const Text("No reviews available.")
//           else
//             const Text("No customer review images available."),
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
//         size.width / 2,
//         size.height,
//         size.width,
//         size.height - 30,
//       )
//       ..lineTo(size.width, 0)
//       ..close();
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../../ServiceProvider/GalleryScreen.dart';
import '../../ServiceProvider/WorkerScreen.dart';
import '../../auth/RoleSelectionScreen.dart';
import '../../comm/home_location_screens.dart';
import '../user_profile/UserProfileScreen.dart';
import 'EditProfileScreen.dart';
import 'HisWorkScreen.dart';
import 'ReviewImagesScreen.dart';
class SellerScreen extends StatefulWidget {
  final iconsHide;

  const SellerScreen({super.key, this.iconsHide});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  File? _pickedImage;
  ServiceProviderProfileModel? profile;
  bool isLoading = true;
  bool _showReviews = true;
  String? address = "";
  final GetXRoleController roleController = Get.put(
    GetXRoleController(),
  ); // Updated to GetXRoleController

  @override
  void initState() {
    super.initState();
    loadSavedLocation();
    fetchProfile();
  }

  Future<void> loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLocation = prefs.getString('location');
    if (savedLocation != null) {
      setState(() {
        address = savedLocation;
      });
    }
  }

  Future<void> updateLocationOnServer(
      String newAddress,
      double latitude,
      double longitude,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = Uri.parse(
      "https://api.thebharatworks.com/api/user/updateLocation",
    );
    final response = await http.put(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'address': newAddress,
        },
        'current_location': newAddress,
        'full_address': newAddress,
      }),
    );
    if (response.statusCode == 200) {
      await prefs.setString('location', newAddress);
      setState(() {
        address = newAddress;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Location updated to $newAddress")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to update location")),
      );
      print("Update Location Failed: ${response.body}");
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🔐 Token not found. Please login again."),
          ),
        );
        return;
      }
      final url = Uri.parse(
        "https://api.thebharatworks.com/api/user/updateProfilePic",
      );
      try {
        var request =
        http.MultipartRequest("PUT", url)
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(
            await http.MultipartFile.fromPath(
              'profilePic',
              pickedFile.path,
            ),
          );
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final jsonData = jsonDecode(responseData);
          debugPrint("✅ Response: $jsonData");
          if (jsonData['profilePic'] != null) {
            setState(() {
              profile?.profilePic = jsonData['profilePic'];
              profile?.fullName = jsonData['full_name'];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Profile picture updated")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonData['message'] ?? "❌ Upload failed")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Upload failed! Try again.")),
          );
        }
      } catch (e) {
        debugPrint("Upload error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Something went wrong!")),
        );
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

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = Uri.parse(
        "https://api.thebharatworks.com/api/user/getUserProfileData",
      );
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      print("Full API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Data: $data");

        if (data['status'] == true) {
          final fetchedAddress =
          data['data'] != null && data['data']['location'] != null
              ? (data['data']['location']['address'] ?? 'Select Location')
              : 'Select Location';

          await prefs.setString("address", fetchedAddress);

          setState(() {
            profile = ServiceProviderProfileModel.fromJson(data['data']);
            isLoading = false;
            address = fetchedAddress;
          });

          print("Saved address: $fetchedAddress");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Profile fetch failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error, profile fetch failed!")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong, try again!")),
      );
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
        child:
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context,profile),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: _pickImageFromCamera,
                        child: Container(
                          padding: EdgeInsets.all(3),
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
                            backgroundImage:
                            _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (profile?.profilePic != null
                                ? NetworkImage(
                              profile!.profilePic!,
                            )
                                : null)
                            as ImageProvider?,
                            child:
                            _pickedImage == null &&
                                profile?.profilePic == null
                                ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: InkWell(
                          onTap: _pickImageFromCamera,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    // profile?.fullName ?? '',
                    '${profile?.fullName?[0].toUpperCase()}${profile?.fullName?.substring(1).toLowerCase()}',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => LocationSelectionScreen(
                                onLocationSelected: (String) {},
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              address = result;
                            });
                            await updateLocationOnServer(
                              result,
                              30.73508469999999,
                              79.0668788,
                            );
                          }
                        },
                        child: Text(
                          address ?? 'Select Location',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      widget.iconsHide == 'hide'
                          ? SizedBox()
                          : GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditProfileScreen(
                                fullName: profile?.fullName,
                                skill: profile?.skill,
                                categoryId: profile?.categoryId,
                                subCategoryIds:
                                profile?.subCategoryIds
                                    ?.map(
                                      (e) => e.toString(),
                                )
                                    .toList(),
                                documentUrl: profile?.documents,
                              ),
                            ),
                          );
                          if (result == true) {
                            fetchProfile();
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.all(6),
                            width: 32,
                            height: 32,
                            child:/* Image.asset(
                            'assets/images/edit1.png',
                            height: 18,
                          ),*/SvgPicture.asset("assets/svg_images/editicon.svg")
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${profile?.totalReview ?? 0} Reviews",
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          Text(
                            '(${profile?.rating ?? 0.0} ',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          Text(
                            ')',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildHisWorkSection(),
              const SizedBox(height: 12),
              const SizedBox(height: 10),
              _buildDocumentCard(),
              const SizedBox(height: 12),
              widget.iconsHide == 'hide'
                  ? SizedBox()
                  : _buildAddAsapPersonTile(context),
              const SizedBox(height: 12),
              _buildCustomerReviews(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic profile) {
    final ServiceProviderProfileModel data = profile as ServiceProviderProfileModel;
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        color: const Color(0xFF9DF89D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.arrow_back, size: 25),
                  ),
                ),
                // const SizedBox(width: 100),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text(
                        "Worker Profile",
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
            SizedBox(height: 16),
            Center(child: _buildRoleSwitcher(context, profile)),
          ],
        ),
      ),
    );
  }
  // Widget _buildHeader(BuildContext context, dynamic profile) {
  //   return ClipPath(
  //     clipper: BottomCurveClipper(),
  //     child: Container(
  //       color: const Color(0xFF9DF89D),
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //       height: 140,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               IconButton(
  //                 padding: EdgeInsets.zero,
  //                 icon: const Icon(Icons.arrow_back, size: 25),
  //                 onPressed: () => Navigator.pop(context),
  //               ),
  //               Expanded(
  //                 child: Center(
  //                   child: Padding(
  //                     padding: const EdgeInsets.only(right: 18.0),
  //                     child: Text(
  //                       "Worker Profile",
  //                       style: GoogleFonts.roboto(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           // const SizedBox(height: 5),
  //           // (role == "both")
  //           //     ? SizedBox()
  //           //     : (requestStatus == null || requestStatus.isEmpty)
  //           //     ? Center(child: _buildRoleSwitcher(context,role,requestStatus))
  //           //     : Container(child: Text("No role found!"))
  //           Center(child: _buildRoleSwitcher(context, profile)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRoleSwitcher(BuildContext context, dynamic profile) {
    final ServiceProviderProfileModel data = profile as ServiceProviderProfileModel;
    const roleMap = {'User': 'user', 'Worker': 'service_provider'};
    final GetXRoleController roleController = Get.find<GetXRoleController>();

    return Obx(() {
      final String selectedRole = roleController.role.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: _roleButton("User", selectedRole == "user", () async {
              // Agar selectedRole already "user" hai, toh kuch nahi karna
              if (selectedRole == "user") {
                return;
              }
              // Agar role "both" hai aur requestStatus null ya empty hai
              if (data.role == "both" && (data.requestStatus == null || data.requestStatus!.isEmpty)) {
                await roleController.updateRole('user');
                Get.off(() => ProfileScreen());
              } else {
                // Agar requestStatus null ya empty hai
                if (data.requestStatus == null || data.requestStatus!.isEmpty) {

                /*  await switchRoleRequest();
                  if (data.role == "both") {
                    await roleController.updateRole('user');              //  <<<<---------<-     this code is currect show please dont change without permission!!!!
                  }
                  Navigator.of(context).pop();
                  Get.off(() => ProfileScreen(swithcrole: "",));*/

                  await switchRoleRequest();

                  // yaha turant role update kar do
                  await roleController.updateRole('user');

                  // fir navigation karo
                  // Navigator.of(context).pop();
                  Get.off(() => ProfileScreen(swithcrole: "",));

                  /* showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: const Text("Confirmation Box")),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/images/rolechangeConfim.png",
                              height: 90,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Confirmation",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text("Are you sure you want to switch\n                your profile?"),
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
                                // if (data.role == "both") {
                                //   await roleController.updateRole('user');              //  <<<<---------<-     this code is currect show please dont change without permission!!!!
                                // }
                                // Navigator.of(context).pop();
                                // Get.off(() => ProfileScreen(swithcrole: "serviceroleSwitch",));
                                await switchRoleRequest();
                                if (data.role == "both") {
                                  await roleController.updateRole('user');              //  <<<<---------<-     this code is currect show please dont change without permission!!!!
                                }
                                Navigator.of(context).pop();
                                Get.off(() => ProfileScreen(swithcrole: "",));
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
                  );*/
                } else {
                  // Jab requestStatus null ya empty nahi hai
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Request Submitted"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /*Image.asset(
                              "assets/images/rolechangeConfim.png",
                              height: 90,
                            ),*/
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
                            const Text(
                              "App ki request submit ho gayi hai, 2-3 din ka wait kariye.",
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
                                "OK",
                                style: TextStyle(color: Colors.white),
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
              }
            }),
          ),
          const SizedBox(width: 16),
          InkWell(
            child: _roleButton("Worker", selectedRole == "service_provider", () async {
              // Agar selectedRole already "service_provider" hai, toh kuch nahi karna
              if (selectedRole == "service_provider") {
                return;
              }
              // Agar role "both" hai aur requestStatus null ya empty hai
              if (data.role == "both" && (data.requestStatus == null || data.requestStatus!.isEmpty)) {
                await roleController.updateRole('service_provider');
                Get.off(() => SellerScreen());
              } else {
                // Agar requestStatus null ya empty hai
                if (data.requestStatus == null || data.requestStatus!.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: const Text("Confirmation Box")),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /*Image.asset(
                              "assets/images/rolechangeConfim.png",
                              height: 90,
                            ),*/
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
                            const Text("Are you sure you want to switch\n                your profile?"),
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
                                if (data.role == "both") {
                                  await roleController.updateRole('service_provider');
                                } else {
                                  await switchRoleRequest();
                                }
                                Navigator.of(context).pop();
                                Get.off(() => SellerScreen());
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
                  // Jab requestStatus null ya empty nahi hai
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Request Submitted"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/images/rolechangeConfim.png",
                              height: 90,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Request Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "App ki request submit ho gayi hai, 2-3 din ka wait kariye.",
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
                                "OK",
                                style: TextStyle(color: Colors.white),
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
              }
            }),
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

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color(0xFF9DF89D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(fontSize: 11),
                      children: [
                        TextSpan(
                          text: "Category: ",
                          style: GoogleFonts.roboto(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: profile?.categoryName ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 11),
                        children: [
                          TextSpan(
                            text: "Sub-Category: ",
                            style: GoogleFonts.roboto(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text:
                            profile?.subCategoryNames?.join(', ') ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildEmergencyCard(),
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xffeaffea),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/task.png",
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabButtons(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Emergency task.",
              style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHisWorkSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(),
            child: Text(
              "About My Skill",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.shade700, width: 1.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              profile?.skill ?? '',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard() {
    return Container(
      height: 160,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            "Document",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              // Image.asset('assets/images/line2.png', height: 24),
              SvgPicture.asset("assets/svg_images/adharicon.svg"),
              const SizedBox(width: 20),
              Text(
                "Aadhar card",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 50),
              if (profile?.documents != null && profile!.documents!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    profile!.documents!,
                    // profile?.documents ?? "",
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                )
              else
                Text(
                  "(Not uploaded)",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAsapPersonTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // leading: Image.asset('assets/svg_images/assign.png'),
        leading: SvgPicture.asset('assets/svg_images/bottombar/profile-circle.svg'),
        title: Text("Add Assign Person", style: GoogleFonts.roboto(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward, size: 20),
        onTap: () {
          Get.to(() => const WorkerScreen());
        },
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        _tabButton("His Work", _showReviews, () {
          setState(() => _showReviews = true);
          Get.to(() => GalleryScreen(images: profile?.hisWork ?? [], serviceProviderId: profile?.id ?? ""));
        }),
        const SizedBox(width: 10),
        _tabButton("User Review", !_showReviews, () {
          Get.to(
                () => ReviewImagesScreen(images: profile?.customerReview ?? []),
          );
        }),
      ],
    );
  }

  Widget _tabButton(String title, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFC3FBD8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.orange, size: 18));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 18));
      } else {
        stars.add(
          const Icon(Icons.star_border, color: Colors.orange, size: 18),
        );
      }
    }
    return Row(children: stars);
  }

  Widget _buildCustomerReviews() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rate & Reviews",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_showReviews)
            if (profile?.rateAndReviews?.isNotEmpty ?? false)
              ...profile!.rateAndReviews!.map(
                    (r) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        buildStarRating(r.rating ?? 0),
                        const SizedBox(width: 6),
                        Text(
                          "(${r.rating?.toStringAsFixed(1)})",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r.review ?? ''),
                    const SizedBox(height: 6),
                    if ((r.images ?? []).isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children:
                        (r.images ?? [])
                            .map(
                              (img) => ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              img,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    const Divider(),
                  ],
                ),
              )
            else
              const Text("No reviews available.")
          else
            const Text("No customer review images available."),
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 30,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
