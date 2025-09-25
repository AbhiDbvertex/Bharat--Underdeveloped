// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../Account/service_provider_profile/EditProfileScreen.dart';
// import '../Account/service_provider_profile/HisWorkScreen.dart';
// import '../Account/service_provider_profile/ReviewImagesScreen.dart';
// import '../ServiceProvider/WorkerScreen.dart';
// import '../comm/home_location_screens.dart';
//
// // ignore_for_file: use_build_context_synchronously
//
// class ViewServiceProviderProfileScreen extends StatefulWidget {
//   final String? iconsHide;
//   const ViewServiceProviderProfileScreen({super.key, this.iconsHide});
//
//   @override
//   State<ViewServiceProviderProfileScreen> createState() => _ViewServiceProviderProfileScreenState();
// }
//
// class _ViewServiceProviderProfileScreenState extends State<ViewServiceProviderProfileScreen> {
//   File? _pickedImage;
//   ServiceProviderProfileModel? profile;
//   bool isLoading = true;
//   bool _showReviews = true;
//   String? address = "";
//
//   // Utility function to clean URLs
//   String cleanImageUrl(String? url) {
//     if (url == null) return '';
//     // Remove any duplicate domain parts
//     final baseUrl = 'https://api.thebharatworks.com';
//     if (url.contains('${baseUrl}http')) {
//       url = url.replaceFirst('${baseUrl}http://api.thebharatworks.com', baseUrl);
//     }
//     return url;
//   }
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
//   Future<void> fetchProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       final url = Uri.parse(
//         "https://api.thebharatworks.com/api/user/getServiceProvider/685b7c588b57faa48a412034",
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
//         if (data['success'] == true) {
//           final fetchedAddress =
//           data['data'] != null && data['data']['location'] != null
//               ? (data['data']['location']['address'] ?? 'Select Location')
//               : 'Select Location';
//
//           // Save the address to SharedPreferences
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
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildHeader(context),
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: _pickedImage != null
//                             ? FileImage(_pickedImage!)
//                             : (profile?.profilePic != null
//                             ? NetworkImage(cleanImageUrl(profile!.profilePic))
//                             : null) as ImageProvider?,
//                         child: _pickedImage == null && profile?.profilePic == null
//                             ? const Icon(
//                           Icons.person,
//                           size: 50,
//                           color: Colors.white,
//                         )
//                             : null,
//                       ),
//                     ],
//                   ),
//                   Text(
//                     profile?.fullName ?? '',
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
//                               builder: (context) => EditProfileScreen(
//                                 fullName: profile?.fullName,
//                                 skill: profile?.skill,
//                                 categoryId: profile?.categoryId,
//                                 subCategoryIds: profile?.subCategoryIds
//                                     ?.map((e) => e.toString())
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
//                           child: Image.asset(
//                             'assets/images/edit1.png',
//                             height: 18,
//                           ),
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
//               widget.iconsHide == 'hide' ? SizedBox() : _buildAddAsapPersonTile(context),
//               const SizedBox(height: 12),
//               _buildCustomerReviews(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context) {
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
//             Center(child: _buildRoleSwitcher(context)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRoleSwitcher(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             "User",
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               color: Colors.green.shade800,
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.green.shade800,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const Text(
//             "Worker",
//             style: TextStyle(fontSize: 12, color: Colors.white),
//           ),
//         ),
//       ],
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
//                             text: profile?.subCategoryNames?.join(', ') ?? 'N/A',
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
//               Image.asset('assets/images/line2.png', height: 24),
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
//                     cleanImageUrl(profile!.documents),
//                     height: 80,
//                     width: 80,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
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
//         leading: Image.asset('assets/images/contact.png'),
//         title: Text("Assign Person", style: GoogleFonts.roboto(fontSize: 13)),
//         trailing: const Icon(Icons.arrow_forward, size: 20),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const WorkerScreen()),
//           );
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
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HisWorkScreen(
//                 images: (profile?.hisWork ?? []).map(cleanImageUrl).toList(),
//               ),
//             ),
//           );
//         }),
//         const SizedBox(width: 10),
//         _tabButton("User Review", !_showReviews, () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ReviewImagesScreen(
//                 images: (profile?.customerReview ?? []).map(cleanImageUrl).toList(),
//               ),
//             ),
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
//                         children: (r.images ?? [])
//                             .map(
//                               (img) => ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: Image.network(
//                               cleanImageUrl(img),
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
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

import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../Account/service_provider_profile/EditProfileScreen.dart';
import '../Account/service_provider_profile/HisWorkScreen.dart';
import '../Account/service_provider_profile/ReviewImagesScreen.dart';
import '../ServiceProvider/WorkerScreen.dart';
import '../comm/home_location_screens.dart';

// ignore_for_file: use_build_context_synchronously

class ViewServiceProviderProfileScreen extends StatefulWidget {
  final serviceProviderId;
  const ViewServiceProviderProfileScreen({super.key, this.serviceProviderId});

  @override
  State<ViewServiceProviderProfileScreen> createState() => _ViewServiceProviderProfileScreenState();
}

class _ViewServiceProviderProfileScreenState extends State<ViewServiceProviderProfileScreen> {
  File? _pickedImage;
  ServiceProviderProfileModel? profile;
  bool isLoading = true;
  bool _showReviews = true;
  String? address = "";
  String tag="ViewServiceProviderProfileScreen";

  // Utility function to clean URLs
  String cleanImageUrl(String? url) {
    if (url == null) return '';
    // Remove any duplicate domain parts
    final baseUrl = 'https://api.thebharatworks.com';
    if (url.contains('${baseUrl}http')) {
      url = url.replaceFirst('${baseUrl}http://api.thebharatworks.com', baseUrl);
    }
    return url;
  }

  @override
  void initState() {
    bwDebug("service provider Id : ${widget.serviceProviderId}",tag: tag);
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

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = Uri.parse(
        // "https://api.thebharatworks.com/api/user/getServiceProvider/685b7c588b57faa48a412034",
        "https://api.thebharatworks.com/api/user/getServiceProvider/${widget.serviceProviderId}",
      );
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      print("Full API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Data: $data");

        if (data['success'] == true) {
          final fetchedAddress =
          data['data'] != null && data['data']['location'] != null
              ? (data['data']['location']['address'] ?? 'Select Location')
              : 'Select Location';

          // Save the address to SharedPreferences
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
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF9DF89D),
        centerTitle: true,
        title: const Text("Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: Color(0xFF9DF89D),
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                    /*  CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        foregroundDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.shade700,
                            width: 3.0,
                          ),
                        ),
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (profile?.profilePic != null
                            ? NetworkImage(cleanImageUrl(profile!.profilePic))
                            : null) as ImageProvider?,
                        child: _pickedImage == null && profile?.profilePic == null
                            ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                            : null,
                      ),*/
                      Container(
                        padding: EdgeInsets.all(3), // border ka space
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
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : (profile?.profilePic != null
                              ? NetworkImage(cleanImageUrl(profile!.profilePic))
                              : null) as ImageProvider?,
                          child: _pickedImage == null && profile?.profilePic == null
                              ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                              : null,
                        ),
                      )

                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile?.fullName ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ), const SizedBox(height: 5),
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
                    ],
                  ),
                  const SizedBox(height: 5),
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
              //_buildAddAsapPersonTile(context),
              const SizedBox(height: 12),
              _buildCustomerReviews(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Container(
        color: const Color(0xFF9DF89D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        height: 140,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Row(
            //   children: [
            //     GestureDetector(
            //       onTap: () => Navigator.pop(context),
            //       child: const Padding(
            //         padding: EdgeInsets.only(left: 8.0),
            //         child: Icon(Icons.arrow_back, size: 25),
            //       ),
            //     ),
            //     const SizedBox(width: 100),
            //     Text(
            //       "Profile",
            //       style: GoogleFonts.roboto(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black,
            //       ),
            //     ),
            //   ],
            // ),
            // Center(child: _buildRoleSwitcher(context)),
          ],
        ),
      ),
    );
  }

  // Widget _buildRoleSwitcher(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Text(
  //           "User",
  //           style: GoogleFonts.poppins(
  //             fontSize: 12,
  //             color: Colors.green.shade800,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
  //         decoration: BoxDecoration(
  //           color: Colors.green.shade800,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: const Text(
  //           "Worker",
  //           style: TextStyle(fontSize: 12, color: Colors.white),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
                            text: profile?.subCategoryNames?.join(', ') ?? 'N/A',
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
              Image.asset('assets/images/line2.png', height: 24),
              const SizedBox(width: 20),
              Text(
                "Valid Id Proof",
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
                    cleanImageUrl(profile!.documents),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.image_not_supported_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildAddAsapPersonTile(BuildContext context) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: ListTile(
  //       leading: Image.asset('assets/images/contact.png'),
  //       title: Text("Assign Person", style: GoogleFonts.roboto(fontSize: 13)),
  //       trailing: const Icon(Icons.arrow_forward, size: 20),
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (_) => const WorkerScreen()),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildTabButtons() {
    return Row(
      children: [
        _buildTabButton("His Work", _showReviews, () {
          setState(() => _showReviews = true);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HisWorkScreen(
                images: (profile?.hisWork ?? []).map(cleanImageUrl).toList(),
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        _buildTabButton("User Review", !_showReviews, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewImagesScreen(
                images: (profile?.customerReview ?? []).map(cleanImageUrl).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTabButton(String title, bool selected, VoidCallback onTap) {
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
                        children: (r.images ?? [])
                            .map(
                              (img) => ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              cleanImageUrl(img),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
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