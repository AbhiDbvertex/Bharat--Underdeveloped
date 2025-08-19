// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:carousel_slider/carousel_slider.dart'; // ✅ Carousel slider ke liye
// import '../../../../Widgets/AppColors.dart';
// import '../../models/userModel/UserViewWorkerDetailsModel.dart';
// import 'HireScreen.dart';
//
// class UserViewWorkerDetails extends StatefulWidget {
//   final categreyId;
//   final subcategreyId;
//   final String workerId;
//
//   const UserViewWorkerDetails({super.key, required this.workerId, this.categreyId, this.subcategreyId});
//
//   @override
//   State<UserViewWorkerDetails> createState() => _UserViewWorkerDetailsState();
// }
//
// class _UserViewWorkerDetailsState extends State<UserViewWorkerDetails> {
//   bool isHisWork = true; // ✅ Default mein His Work selected
//   File? _pickedImage;
//   ServiceProviderDetailModel? workerData;
//   bool isLoading = true;
//
//   // 🔧 Helper to fix image path
//   String getFullImageUrl(String path) {
//     if (path.startsWith("http")) return path;
//     return "https://api.thebharatworks.com$path";
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchWorkerDetails();
//   }
//
//   Future<void> fetchWorkerDetails() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("No auth token found")));
//         return;
//       }
//
//       print("Abhi:- worker details screen :-- workerId  : ${widget.workerId}");
//
//       final response = await http.get(
//         Uri.parse(
//           "https://api.thebharatworks.com/api/user/getServiceProvider/${widget.workerId}",
//         ),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           setState(() {
//             workerData = ServiceProviderDetailModel.fromJson(data['data']);
//             isLoading = false;
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Worker data not found")),
//           );
//         }
//       } else {
//         throw Exception("Failed to load worker details");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error loading worker details")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
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
//         child: SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height,
//             ),
//             child: Column(
//               children: [
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     _buildHeader(context),
//                     Positioned(
//                       top: 100,
//                       left: 0,
//                       right: 0,
//                       child: _buildProfileImage(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 60),
//                 _buildProfileCard(),
//                 const SizedBox(height: 16),
//                 _buildTabButtons(),
//                 const SizedBox(height: 10),
//
//                 /// About My Skills
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "About MY Skills",
//                           style: GoogleFonts.roboto(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Colors.green.shade700,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             workerData?.skill ?? "No skill info",
//                             style: GoogleFonts.roboto(fontSize: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 /// Document Section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Container(
//                     height: 140,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Document",
//                           style: GoogleFonts.roboto(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Image.asset('assets/images/line2.png'),
//                             const SizedBox(width: 5),
//                             Text(
//                               "Aadhar Card",
//                               style: GoogleFonts.roboto(
//                                 color: Colors.black,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             const SizedBox(width: 70),
//                             Image.asset('assets/images/Aadhar2.png'),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 /// Reviews
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 10,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Customer Reviews",
//                         style: GoogleFonts.roboto(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       _buildCustomerReviews(),
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     if (widget.workerId != null &&
//                         widget.workerId!.isNotEmpty) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (_) =>
//                                   HireScreen(
//                                     firstProviderId:
//                                 widget.workerId?? "",
//                                 categreyId:
//                                 widget.categreyId,
//                                 subcategreyId:
//                                 widget.subcategreyId,
//                               ),
//                         ),
//                       );
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(15.0),
//                     child: Container(
//                       height: 45,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15),
//                         color: Colors.green
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Hire",
//                           style: GoogleFonts.roboto(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 40,)
//               ],
//             ),
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
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back, size: 25),
//               onPressed: () => Navigator.pop(context),
//             ),
//             const Spacer(),
//             Text(
//               "Worker Details",
//               style: GoogleFonts.roboto(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Spacer(flex: 2),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileImage() {
//     String? imageToShow;
//
//     if (workerData?.hisWork != null && workerData!.hisWork!.isNotEmpty) {
//       imageToShow = getFullImageUrl(workerData!.hisWork!.first);
//     } else if (workerData?.profilePic != null) {
//       imageToShow = getFullImageUrl(workerData!.profilePic!);
//     }
//
//     return Column(
//       children: [
//         const SizedBox(height: 30),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Message
//             Padding(
//               padding: const EdgeInsets.only(right: 18.0),
//               child: Container(
//                 height: 30,
//                 width: 85,
//                 padding: const EdgeInsets.all(5),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green.shade700, width: 1.5),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.message, color: Colors.green.shade700, size: 15),
//                     const SizedBox(width: 5),
//                     Text(
//                       'Message',
//                       style: GoogleFonts.roboto(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Avatar
//             CircleAvatar(
//               radius: 44,
//               backgroundColor: Colors.grey.shade300,
//               backgroundImage: (imageToShow != null && imageToShow.isNotEmpty)
//                   ? NetworkImage(imageToShow)
//                   : null,
//               child: (imageToShow == null || imageToShow.isEmpty)
//                   ? const Icon(Icons.person, size: 50, color: Colors.white)
//                   : null,
//             ),
//
//             // Call
//             Padding(
//               padding: const EdgeInsets.only(left: 18.0),
//               child: Container(
//                 height: 30,
//                 width: 80,
//                 padding: const EdgeInsets.all(5),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green.shade700, width: 1.4),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.call, color: Colors.green.shade700, size: 17),
//                     const SizedBox(width: 10),
//                     Text(
//                       'Call',
//                       style: GoogleFonts.roboto(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           workerData?.fullName ?? '',
//           style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 4),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_on, size: 17, color: Colors.green.shade700),
//             const SizedBox(width: 4),
//             Text(
//               workerData?.currentLocation ?? 'Location not available',
//               style: GoogleFonts.roboto(
//                 fontSize: 13,
//                 color: Colors.black,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProfileCard() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 80.0),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           width: double.infinity,
//           margin: const EdgeInsets.all(1),
//           decoration: BoxDecoration(
//             color: const Color(0xFF9DF89D),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               Text(
//                 "Category: ${workerData?.categoryName ?? 'N/A'}",
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   color: Colors.green.shade800,
//                 ),
//               ),
//               Text(
//                 "Sub-Category: ${workerData?.subCategoryName ?? 'N/A'}", // ✅ Join subcategories
//                 style: GoogleFonts.poppins(fontSize: 13),
//               ),
//               const SizedBox(height: 10),
//               // ✅ Carousel Slider for His Work or Customer Review images
//               Container(
//                 color: Colors.white,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 10,),
//                     CarouselSlider(
//                       options: CarouselOptions(
//                         height: 150.0,
//                         autoPlay: true,
//                         enlargeCenterPage: true,
//                         aspectRatio: 16 / 9,
//                         autoPlayInterval: Duration(seconds: 3),
//                         autoPlayAnimationDuration: Duration(milliseconds: 800),
//                         viewportFraction: 0.8,
//                       ),
//                       items: (isHisWork
//                           ? (workerData?.hisWork ?? [])
//                           : (workerData?.customerReview ?? []))
//                           .map((imageUrl) {
//                         return Builder(
//                           builder: (BuildContext context) {
//                             return Container(
//                               width: MediaQuery.of(context).size.width,
//                               margin: EdgeInsets.symmetric(horizontal: 5.0),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.network(
//                                   getFullImageUrl(imageUrl),
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Center(
//                                       child: Text(
//                                         'Image not available',
//                                         style: GoogleFonts.roboto(
//                                           color: Colors.red,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTabButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: () => setState(() => isHisWork = true),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF9DF89D),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: isHisWork ? Colors.green.shade700 : Colors.transparent,
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "His Work",
//                     style: GoogleFonts.roboto(
//                       color: isHisWork ? Colors.green.shade700 : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: GestureDetector(
//             onTap: () => setState(() => isHisWork = false),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF9DF89D),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color:
//                     !isHisWork ? Colors.green.shade700 : Colors.transparent,
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Customer Review",
//                     style: GoogleFonts.roboto(
//                       color: !isHisWork ? Colors.green.shade700 : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCustomerReviews() {
//     if ((workerData?.rateAndReviews?.isEmpty ?? true)) {
//       return const Padding(
//         padding: EdgeInsets.all(16),
//         child: Text("No reviews available yet."),
//       );
//     }
//
//     return Column(
//       children: workerData!.rateAndReviews!.map((review) {
//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: List.generate(
//                     review.rating.round(),
//                         (index) => const Icon(
//                       Icons.star,
//                       color: Colors.amber,
//                       size: 18,
//                     ),
//                   ),
//                 ),
//                 Text(review.review),
//                 const SizedBox(height: 6),
//                 if (review.images.isNotEmpty)
//                   SizedBox(
//                     height: 50,
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       children: review.images.map((img) {
//                         return Padding(
//                           padding: const EdgeInsets.only(right: 6),
//                           child: Image.network(
//                             getFullImageUrl(img),
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover,
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
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
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../models/userModel/UserViewWorkerDetailsModel.dart';
import '../comm/view_images_screen.dart';
import 'HireScreen.dart';

class UserViewWorkerDetails extends StatefulWidget {
  final categreyId;
  final subcategreyId;
  final String workerId;

  const UserViewWorkerDetails({
    super.key,
    required this.workerId,
    this.categreyId,
    this.subcategreyId,
  });

  @override
  State<UserViewWorkerDetails> createState() => _UserViewWorkerDetailsState();
}

class _UserViewWorkerDetailsState extends State<UserViewWorkerDetails> {
  bool isHisWork = true;
  File? _pickedImage;
  ServiceProviderDetailModel? workerData;
  bool isLoading = true;

  // Helper to fix image path
  String getFullImageUrl(String path) {
    if (path.startsWith("http")) return path;
    return "https://api.thebharatworks.com$path";
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWorkerDetails();
  }

  Future<void> fetchWorkerDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No auth token found")));
        return;
      }

      print("Abhi:- worker details screen :-- workerId  : ${widget.workerId}");

      final response = await http.get(
        Uri.parse(
          "https://api.thebharatworks.com/api/user/getServiceProvider/${widget.workerId}",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            workerData = ServiceProviderDetailModel.fromJson(data['data']);
            isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Worker data not found")),
          );
        }
      } else {
        throw Exception("Failed to load worker details");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading worker details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Profile image ka URL
    String? imageToShow =
    workerData?.profilePic != null
        ? getFullImageUrl(workerData!.profilePic!)
        : null;

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
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                // Header
                ClipPath(
                  clipper: BottomCurveClipper(),
                  child: Container(
                    color: const Color(0xFF9DF89D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    height: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10), // shift upwards
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, size: 25),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            Text(
                              "Worker Details",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(flex: 1),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Image, Message, Call, Name, Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Message Button
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Container(
                        height: 30,
                        width: 85,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.shade700,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message,
                              color: Colors.green.shade700,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Message',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Profile Image with Tap
                    GestureDetector(
                      onTap: () {
                        print("Profile image tapped: $imageToShow");
                        if (imageToShow != null && imageToShow.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  ViewImage(imageUrl: imageToShow!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No profile image available"),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                        imageToShow != null && imageToShow.isNotEmpty
                            ? NetworkImage(imageToShow)
                            : null,
                        child:
                        imageToShow == null || imageToShow.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),

                    // Call Button
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Container(
                        height: 30,
                        width: 80,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.shade700,
                            width: 1.4,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.call,
                              color: Colors.green.shade700,
                              size: 17,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Call',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  workerData?.fullName ?? '',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 17,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      workerData?.currentLocation ?? 'Location not available',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                _buildProfileCard(),
                const SizedBox(height: 16),
                _buildTabButtons(),
                const SizedBox(height: 10),

                // About My Skills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
                        Text(
                          "About MY Skills",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.green.shade700,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            workerData?.skill ?? "No skill info",
                            style: GoogleFonts.roboto(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Document Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
                        Text(
                          "Document",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Image.asset('assets/images/line2.png'),
                            const SizedBox(width: 5),
                            Text(
                              "Aadhar Card",
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 70),
                            Image.asset('assets/images/Aadhar2.png'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Reviews
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customer Reviews",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCustomerReviews(),
                    ],
                  ),
                ),

                // Hire Button
                GestureDetector(
                  onTap: () {
                    if (widget.workerId != null &&
                        widget.workerId!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => HireScreen(
                            firstProviderId: widget.workerId ?? "",
                            categreyId: widget.categreyId,
                            subcategreyId: widget.subcategreyId,
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.green,
                      ),
                      child: Center(
                        child: Text(
                          "Hire",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: const Color(0xFF9DF89D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Category: ${workerData?.categoryName ?? 'N/A'}",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.green.shade800,
              ),
            ),
            Text(
              "Sub-Category: ${workerData?.subCategoryName ?? 'N/A'}",
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 150.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      viewportFraction: 0.8,
                    ),
                    items:
                    (isHisWork
                        ? (workerData?.hisWork ?? [])
                        : (workerData?.customerReview ?? []))
                        .map((imageUrl) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ViewImage(
                                imageUrl: workerData?.hisWork ?? [],
                              ),
                            ),
                          );
                        },
                        child: Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  getFullImageUrl(imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                      ) {
                                    return Center(
                                      child: Text(
                                        'Image not available',
                                        style: GoogleFonts.roboto(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    })
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isHisWork = true),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9DF89D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                    isHisWork ? Colors.green.shade700 : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    "His Work",
                    style: GoogleFonts.roboto(
                      color: isHisWork ? Colors.green.shade700 : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isHisWork = false),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9DF89D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                    !isHisWork ? Colors.green.shade700 : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    "Customer Review",
                    style: GoogleFonts.roboto(
                      color: !isHisWork ? Colors.green.shade700 : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerReviews() {
    if ((workerData?.rateAndReviews?.isEmpty ?? true)) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No reviews available yet."),
      );
    }

    return Column(
      children:
      workerData!.rateAndReviews!.map((review) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    review.rating.round(),
                        (index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
                Text(review.review),
                const SizedBox(height: 6),
                if (review.images.isNotEmpty)
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                      review.images.map((img) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Image.network(
                            getFullImageUrl(img),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
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
