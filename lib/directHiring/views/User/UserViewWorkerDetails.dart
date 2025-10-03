// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:carousel_slider/carousel_slider.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../../../Widgets/AppColors.dart';
// // import '../../../Bidding/Models/bidding_order.dart';
// // import '../../../Bidding/view/user/nagotiate_card.dart';
// // import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// // import '../../models/userModel/UserViewWorkerDetailsModel.dart';
// // import '../ServiceProvider/FullImageScreen.dart';
// // import '../comm/view_images_screen.dart';
// // import 'HireScreen.dart';
// //
// // class UserViewWorkerDetails extends StatefulWidget {
// //   final categreyId;
// //   final subcategreyId;
// //   final String workerId;
// //   final String? hirebuttonhide;
// //   final String? hideonly;
// //   // this is filed requirement for user negotiate
// //   final oderId;
// //   final biddingOfferId;
// //   final UserId;
// //
// //
// //   const UserViewWorkerDetails({
// //     super.key,
// //     required this.workerId,
// //     this.categreyId,
// //     this.subcategreyId, this.hirebuttonhide, this.oderId, this.biddingOfferId, this.UserId, this.hideonly,
// //   });
// //
// //   @override
// //   State<UserViewWorkerDetails> createState() => _UserViewWorkerDetailsState();
// // }
// //
// // class _UserViewWorkerDetailsState extends State<UserViewWorkerDetails> {
// //   bool isHisWork = true;
// //   File? _pickedImage;
// //   ServiceProviderDetailModel? workerData;
// //   bool isLoading = true;
// //   //        this code is add by abhishek for location according
// //
// //   bool _isSwitched = false;
// //   String userLocation = "Select Location";
// //   ServiceProviderProfileModel? profile;
// //   List<BiddingOrder> biddingOrders = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // _initializeLocation();
// //     fetchWorkerDetails();
// //   }
// //   // String getFullImageUrl(String path) {
// //   //   if (path.startsWith("http")) return path;
// //   //   return "https://api.thebharatworks.com$path";
// //   // }
// //
// //   Future<void> _pickImage() async {
// //     final pickedFile = await ImagePicker().pickImage(
// //       source: ImageSource.gallery,
// //       imageQuality: 80,
// //     );
// //     if (pickedFile != null) {
// //       setState(() {
// //         _pickedImage = File(pickedFile.path);
// //       });
// //     }}
// //
// //   Future<void> fetchWorkerDetails() async {
// //     print("Abhi:- serive providerId :- ${widget.workerId}");
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');
// //
// //       if (token == null) {
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(const SnackBar(content: Text("No auth token found")));
// //         return;
// //       }
// //
// //       print("Abhi:- worker details screen :-- workerId  : ${widget.workerId}");
// //
// //       final response = await http.get(
// //         Uri.parse(
// //           "https://api.thebharatworks.com/api/user/getServiceProvider/${widget.workerId}",
// //         ),
// //         headers: {'Authorization': 'Bearer $token'},
// //       );
// //
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         if (data['success'] == true && data['data'] != null) {
// //           setState(() {
// //             workerData = ServiceProviderDetailModel.fromJson(data['data']);
// //             isLoading = false;
// //           });
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text("Worker data not found")),
// //           );
// //         }
// //       } else {
// //         throw Exception("Failed to load worker details");
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Error loading worker details")),
// //       );
// //     }
// //   }
// //
// //   // Future<void> fetchWorkerDetails() async {
// //   //   print("Abhi:- serive providerId :- ${widget.workerId}");
// //   //   try {
// //   //     final prefs = await SharedPreferences.getInstance();
// //   //     final token = prefs.getString('token');
// //   //
// //   //     if (token == null) {
// //   //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No auth token found")));
// //   //       return;
// //   //     }
// //   //
// //   //     print("Abhi:- worker details screen :-- workerId  : ${widget.workerId}");
// //   //
// //   //     final response = await http.get(
// //   //       Uri.parse("https://api.thebharatworks.com/api/user/getServiceProvider/${widget.workerId}"),
// //   //       headers: {'Authorization': 'Bearer $token'},
// //   //     );
// //   //
// //   //     if (response.statusCode == 200) {
// //   //       final data = json.decode(response.body);
// //   //       if (data['status'] == true && data['data'] != null) {  // Yahan 'success' ki jagah 'status' use karo, jaise JSON mein hai
// //   //         setState(() {
// //   //           workerData = ServiceProviderDetailModel.fromJson(data['data']);
// //   //
// //   //           // User location set karo full_address se (last wala latest man lo)
// //   //           if (workerData?.fullAddress != null && workerData!.fullAddress!.isNotEmpty) {
// //   //             userLocation = workerData!.fullAddress!.last['address'] ?? 'Location not available';
// //   //           } else {
// //   //             userLocation = workerData?.location?['address'] ?? 'Location not available';  // Fallback to location.address
// //   //           }
// //   //
// //   //           isLoading = false;
// //   //         });
// //   //       } else {
// //   //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Worker data not found")));
// //   //       }
// //   //     } else {
// //   //       throw Exception("Failed to load worker details");
// //   //     }
// //   //   } catch (e) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error loading worker details")));
// //   //   }
// //   // }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final height = MediaQuery.of(context).size.height;
// //     final width = MediaQuery.of(context).size.width;
// //     if (isLoading) {
// //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
// //     }
// //     print("Profile image tapped: ${workerData?.profilePic}");
// //     // Profile image ka URL
// //     // String? imageToShow =
// //     // workerData?.profilePic != null
// //     //     ? getFullImageUrl(workerData!.profilePic!)
// //     //     : null;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         backgroundColor: AppColors.primaryGreen,
// //         centerTitle: true,
// //         elevation: 0,
// //         toolbarHeight: 20,
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           child: ConstrainedBox(
// //             constraints: BoxConstraints(
// //               minHeight: MediaQuery.of(context).size.height,
// //             ),
// //             child: Column(
// //               children: [
// //                 // Header
// //                 ClipPath(
// //                   clipper: BottomCurveClipper(),
// //                   child: Container(
// //                     color: const Color(0xFF9DF89D),
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 16,
// //                       vertical: 16,
// //                     ),
// //                     height: 120,
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const SizedBox(height: 10), // shift upwards
// //                         Row(
// //                           children: [
// //                             IconButton(
// //                               icon: const Icon(Icons.arrow_back, size: 25),
// //                               onPressed: () => Navigator.pop(context),
// //                             ),
// //                             const Spacer(),
// //                             Text(
// //                               "Worker Details",
// //                               style: GoogleFonts.roboto(
// //                                 fontSize: 18,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             const Spacer(flex: 1),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //
// //                 // Profile Image, Message, Call, Name, Location
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // Message Button
// //                     Padding(
// //                       padding: const EdgeInsets.only(right: 18.0),
// //                       child: Container(
// //                         height: 30,
// //                         width: 85,
// //                         padding: const EdgeInsets.all(5),
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(8),
// //                           border: Border.all(
// //                             color: Colors.green.shade700,
// //                             width: 1.5,
// //                           ),
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Icon(
// //                               Icons.message,
// //                               color: Colors.green.shade700,
// //                               size: 15,
// //                             ),
// //                             const SizedBox(width: 5),
// //                             Text(
// //                               'Message',
// //                               style: GoogleFonts.roboto(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.w500,
// //                                 color: Colors.green.shade700,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //
// //                     // Image.network(AutofillHints.birthday),
// //
// //                     // Profile Image with Tap
// //                     GestureDetector(
// //                       onTap: () {
// //                         print("Profile image tapped: ${workerData?.profilePic}");
// //                         if (workerData?.profilePic != null) {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder:
// //                                   (context) =>
// //                                   ViewImage(imageUrl: workerData?.profilePic!),
// //                             ),
// //                           );
// //                         } else {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(
// //                               content: Text("No profile image available"),
// //                             ),
// //                           );
// //                         }
// //                       },
// //                       child: CircleAvatar(
// //                         radius: 50,
// //                         backgroundColor: Colors.grey.shade300,
// //                         backgroundImage:
// //                         /*workerData?.profilePic != null *//*&& imageToShow.isNotEmpty*//*
// //                             ?*/ NetworkImage(workerData!.profilePic ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcGJegujCz3neLg3btfiVRfmV4dg52BBd38g&s"),
// //                             /*: null,*/
// //                         child:
// //                         workerData?.profilePic == null /*|| workerData?.profilePic.isEmpty*/
// //                             ? const Icon(
// //                           Icons.person,
// //                           size: 50,
// //                           color: Colors.white,
// //                         )
// //                             : null,
// //                       ),
// //                     ),
// //                     // Call Button
// //                     Padding(
// //                       padding: const EdgeInsets.only(left: 18.0),
// //                       child: Container(
// //                         height: 30,
// //                         width: 80,
// //                         padding: const EdgeInsets.all(5),
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(8),
// //                           border: Border.all(
// //                             color: Colors.green.shade700,
// //                             width: 1.4,
// //                           ),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             Icon(
// //                               Icons.call,
// //                               color: Colors.green.shade700,
// //                               size: 17,
// //                             ),
// //                             const SizedBox(width: 10),
// //                             Text(
// //                               'Call',
// //                               style: GoogleFonts.roboto(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.w500,
// //                                 color: Colors.green.shade700,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   // "Abhi",
// //                   workerData?.fullName ?? '',
// //                   style: GoogleFonts.roboto(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Center(
// //                       child: Icon(
// //                         Icons.location_on,
// //                         size: 17,
// //                         color: Colors.green.shade700,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 4),
// //                     Expanded(
// //                       child: Center(
// //                         child: Text(
// //                           workerData?.location?["address"] ?? "Location not available",
// //                           style: GoogleFonts.roboto(
// //                             fontSize: 13,
// //                             color: Colors.black,
// //                             fontWeight: FontWeight.w700,
// //                           ),
// //                           maxLines: 2,
// //                           textAlign: TextAlign.center,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 10),
// //                 _buildProfileCard(),
// //                 const SizedBox(height: 16),
// //                 _buildTabButtons(),
// //                 const SizedBox(height: 10),
// //
// //                 // About My Skills
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                   child: Container(
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(10),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black12,
// //                           blurRadius: 4,
// //                           offset: Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           "About MY Skills",
// //                           style: GoogleFonts.roboto(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 10),
// //                         Container(
// //                           width: double.infinity,
// //                           padding: const EdgeInsets.all(10),
// //                           decoration: BoxDecoration(
// //                             border: Border.all(
// //                               color: Colors.green.shade700,
// //                               width: 1,
// //                             ),
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Text(
// //                             workerData?.skill ?? "No skill info",
// //                             style: GoogleFonts.roboto(fontSize: 14),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // Document Section
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                   child: Container(
// //                     height: 140,
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(10),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black12,
// //                           blurRadius: 4,
// //                           offset: Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text(
// //                               "Document",
// //                               style: GoogleFonts.roboto(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             Container(
// //                               width: 82,
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(5),
// //                                 border: Border.all(color: Colors.green,width: 2)
// //                               ),
// //                               child: Center(child: Text("Verified",style: TextStyle(color: Colors.green.shade700,fontWeight: FontWeight.w600),)),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 20),
// //                         Row(
// //                           children: [
// //                             Image.asset('assets/images/line2.png'),
// //                             const SizedBox(width: 5),
// //                             Text(
// //                               "Valid Id Proof",
// //                               style: GoogleFonts.roboto(
// //                                 color: Colors.black,
// //                                 fontSize: 13,
// //                               ),
// //                             ),
// //                             // const SizedBox(width: 80),
// //                             Spacer(),
// //                             // Image.asset('assets/images/Aadhar2.png'),
// //                             InkWell(
// //                               onTap: (){
// //                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>  FullImageScreen(
// //                                   imageUrl: workerData?.documents ?? "No data",)));
// //                               },
// //                               child: Padding(
// //                                 padding: const EdgeInsets.only(right: 18.0),
// //                                 child: Align(
// //                                     alignment: Alignment.topRight,
// //                                     child: Image.network(workerData?.documents ?? "No data",height: 70,)),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         Container(
// //                           decoration: BoxDecoration(),
// //                         )
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 // Reviews
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 16.0,
// //                     vertical: 10,
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         "Customer Reviews",
// //                         style: GoogleFonts.roboto(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       _buildCustomerReviews(),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 // Hire Button
// //              widget.hirebuttonhide == 'hide' ?   NegotiationCardUser(
// //                workerId: widget.workerId,
// //                biddingOfferId: widget.biddingOfferId,
// //                oderId: widget.oderId,
// //                UserId: widget.UserId,
// //              ) : SizedBox(),
// //
// //                 widget.hideonly == 'hideOnly' ? SizedBox(): GestureDetector(
// //                   onTap: () {
// //                     if (widget.workerId != null &&
// //                         widget.workerId!.isNotEmpty) {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder:
// //                               (_) => HireScreen(
// //                             firstProviderId: widget.workerId ?? "",
// //                             categreyId: widget.categreyId,
// //                             subcategreyId: widget.subcategreyId,
// //                           ),
// //                         ),
// //                       );
// //                     }
// //                   },
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(15.0),
// //                     child: Container(
// //                       height: 45,
// //                       width: double.infinity,
// //                       decoration: BoxDecoration(
// //                         borderRadius: BorderRadius.circular(15),
// //                         color: Colors.green,
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           "Hire",
// //                           style: GoogleFonts.roboto(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.w500,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ) ,
// //                 const SizedBox(height: 40),
// //                 // NegotiationCardUser(
// //                 //   workerId: widget.workerId,
// //                 //   biddingOfferId: widget.biddingOfferId,
// //                 //   oderId: widget.oderId,
// //                 //   UserId: widget.UserId,
// //                 // ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProfileCard() {
// //     return Padding(
// //       padding: const EdgeInsets.all(8.0),
// //       child: Container(
// //         width: double.infinity,
// //         margin: const EdgeInsets.all(1),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFF9DF89D),
// //           borderRadius: BorderRadius.circular(14),
// //         ),
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 10),
// //             Text(
// //               "Category: ${workerData?.categoryName ?? 'N/A'}",
// //               style: GoogleFonts.poppins(
// //                 fontSize: 13,
// //                 color: Colors.green.shade800,
// //               ),
// //             ),
// //             /*Text(
// //               "Sub-Category: ${workerData?.subCategoryName ?? 'N/A'}",
// //               style: GoogleFonts.poppins(fontSize: 13),
// //             ),*/
// //             Padding(
// //               padding: const EdgeInsets.all(8.0),
// //               child: Text(
// //                 "Sub-Categories: ${workerData?.subcategoryNames?.join(', ') ?? 'N/A'}",  // Puri list comma se
// //                 style: GoogleFonts.poppins(fontSize: 13),
// //               ),
// //             ),
// //             const SizedBox(height: 10),
// //             Container(
// //               color: Colors.white,
// //               child: Column(
// //                 children: [
// //                   const SizedBox(height: 10),
// //                   CarouselSlider(
// //                     options: CarouselOptions(
// //                       height: 150.0,
// //                       autoPlay: true,
// //                       enlargeCenterPage: true,
// //                       aspectRatio: 16 / 9,
// //                       autoPlayInterval: const Duration(seconds: 3),
// //                       autoPlayAnimationDuration: const Duration(
// //                         milliseconds: 800,
// //                       ),
// //                       viewportFraction: 0.8,
// //                     ),
// //                     items:
// //                     (isHisWork
// //                         ? (workerData?.hisWork ?? [])
// //                         : (workerData?.customerReview ?? []))
// //                         .map((imageUrl) {
// //                       return InkWell(
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder:
// //                                   (context) => ViewImage(
// //                                 imageUrl: workerData?.hisWork ?? [],
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                         child: Builder(
// //                           builder: (BuildContext context) {
// //                             return Container(
// //                               width: MediaQuery.of(context).size.width,
// //                               margin: const EdgeInsets.symmetric(
// //                                 horizontal: 5.0,
// //                               ),
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                               child: ClipRRect(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 child: Image.network(
// //                                   // getFullImageUrl(imageUrl),
// //                                   workerData?.profilePic ?? "",
// //                                   fit: BoxFit.cover,
// //                                   errorBuilder: (
// //                                       context,
// //                                       error,
// //                                       stackTrace,
// //                                       ) {
// //                                     return Center(
// //                                       child: Text(
// //                                         'Image not available',
// //                                         style: GoogleFonts.roboto(
// //                                           color: Colors.red,
// //                                           fontSize: 12,
// //                                         ),
// //                                       ),
// //                                     );
// //                                   },
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                       );
// //                     })
// //                         .toList(),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTabButtons() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: GestureDetector(
// //             onTap: () => setState(() => isHisWork = true),
// //             child: Padding(
// //               padding: const EdgeInsets.all(8.0),
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(vertical: 12),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF9DF89D),
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(
// //                     color:
// //                     isHisWork ? Colors.green.shade700 : Colors.transparent,
// //                     width: 2,
// //                   ),
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     "His Work",
// //                     style: GoogleFonts.roboto(
// //                       color: isHisWork ? Colors.green.shade700 : Colors.black,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 10),
// //         Expanded(
// //           child: GestureDetector(
// //             onTap: () => setState(() => isHisWork = false),
// //             child: Padding(
// //               padding: const EdgeInsets.all(8.0),
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(vertical: 12),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF9DF89D),
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(
// //                     color:
// //                     !isHisWork ? Colors.green.shade700 : Colors.transparent,
// //                     width: 2,
// //                   ),
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     "Customer Review",
// //                     style: GoogleFonts.roboto(
// //                       color: !isHisWork ? Colors.green.shade700 : Colors.black,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildCustomerReviews() {
// //     if ((workerData?.rateAndReviews?.isEmpty ?? true)) {
// //       return const Padding(
// //         padding: EdgeInsets.all(16),
// //         child: Text("No reviews available yet."),
// //       );
// //     }
// //
// //     return Column(
// //       children:
// //       workerData!.rateAndReviews!.map((review) {
// //         return Card(
// //           margin: const EdgeInsets.symmetric(vertical: 6),
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: List.generate(
// //                     review.rating.round(),
// //                         (index) => const Icon(
// //                       Icons.star,
// //                       color: Colors.amber,
// //                       size: 18,
// //                     ),
// //                   ),
// //                 ),
// //                 Text(review.review),
// //                 const SizedBox(height: 6),
// //                 if (review.images.isNotEmpty)
// //                   SizedBox(
// //                     height: 50,
// //                     child: ListView(
// //                       scrollDirection: Axis.horizontal,
// //                       children:
// //                       review.images.map((img) {
// //                         return Padding(
// //                           padding: const EdgeInsets.only(right: 6),
// //                           child: Image.network(
// //                             // getFullImageUrl(img),
// //                             workerData?.profilePic ?? "",
// //                             width: 50,
// //                             height: 50,
// //                             fit: BoxFit.cover,
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         );
// //       }).toList(),
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
// //         size.width / 2,
// //         size.height,
// //         size.width,
// //         size.height - 30,
// //       )
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
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../../Bidding/Models/bidding_order.dart';
// import '../../../Bidding/view/user/nagotiate_card.dart';
// import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
// import '../../models/userModel/UserViewWorkerDetailsModel.dart';
// import '../ServiceProvider/FullImageScreen.dart';
// import '../comm/view_images_screen.dart';
// import 'HireScreen.dart';
//
// class UserViewWorkerDetails extends StatefulWidget {
//   final categreyId;
//   final subcategreyId;
//   final String workerId;
//   final String? hirebuttonhide;
//   final String? hideonly;
//   final oderId;
//   final biddingOfferId;
//   final UserId;
//
//   const UserViewWorkerDetails({
//     super.key,
//     required this.workerId,
//     this.categreyId,
//     this.subcategreyId,
//     this.hirebuttonhide,
//     this.oderId,
//     this.biddingOfferId,
//     this.UserId,
//     this.hideonly,
//   });
//
//   @override
//   State<UserViewWorkerDetails> createState() => _UserViewWorkerDetailsState();
// }
//
// class _UserViewWorkerDetailsState extends State<UserViewWorkerDetails> {
//   bool isHisWork = true;
//   File? _pickedImage;
//   ServiceProviderDetailModel? workerData;
//   bool isLoading = true;
//   bool _isSwitched = false;
//   String userLocation = "Select Location";
//   ServiceProviderProfileModel? profile;
//   List<BiddingOrder> biddingOrders = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchWorkerDetails();
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
//   Future<void> fetchWorkerDetails() async {
//     print("Abhi:- serive providerId :- ${widget.workerId}");
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("No auth token found")));
//         return;
//       }
//
//       print("Abhi:- worker details screen :-- workerId  : ${widget.workerId}");
//
//       final response = await http.get(
//         Uri.parse(
//             "https://api.thebharatworks.com/api/user/getServiceProvider/${widget.workerId}"),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       print("API Response: ${response.body}"); // Debug ke liye
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
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
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
//                 // Header
//                 ClipPath(
//                   clipper: BottomCurveClipper(),
//                   child: Container(
//                     color: const Color(0xFF9DF89D),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 16,
//                     ),
//                     height: 120,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.arrow_back, size: 25),
//                               onPressed: () => Navigator.pop(context),
//                             ),
//                             const Spacer(),
//                             Text(
//                               "Worker Details",
//                               style: GoogleFonts.roboto(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const Spacer(flex: 1),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Profile Image, Message, Call, Name, Location
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Message Button
//                     Padding(
//                       padding: const EdgeInsets.only(right: 18.0),
//                       child: Container(
//                         height: 30,
//                         width: 85,
//                         padding: const EdgeInsets.all(5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: Colors.green.shade700,
//                             width: 1.5,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.message,
//                               color: Colors.green.shade700,
//                               size: 15,
//                             ),
//                             const SizedBox(width: 5),
//                             Text(
//                               'Message',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.green.shade700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const Spacer(), // Centering ke liye
//
//                     // Profile Image with Tap
//                     GestureDetector(
//                       onTap: () {
//                         print("Profile image tapped: ${workerData?.profilePic}");
//                         if (workerData?.profilePic != null && workerData!.profilePic!.isNotEmpty) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ViewImage(imageUrl: workerData!.profilePic!),
//                             ),
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("No profile image available"),
//                             ),
//                           );
//                         }
//                       },
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: workerData?.profilePic != null && workerData!.profilePic!.isNotEmpty
//                             ? NetworkImage(workerData!.profilePic!)
//                             : null,
//                         child: workerData?.profilePic == null || workerData!.profilePic!.isEmpty
//                             ? const Icon(
//                           Icons.person,
//                           size: 50,
//                           color: Colors.white,
//                         )
//                             : null,
//                       ),
//                     ),
//
//                     const Spacer(), // Centering ke liye
//
//                     // Call Button
//                     Padding(
//                       padding: const EdgeInsets.only(left: 18.0),
//                       child: Container(
//                         height: 30,
//                         width: 80,
//                         padding: const EdgeInsets.all(5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: Colors.green.shade700,
//                             width: 1.4,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.call,
//                               color: Colors.green.shade700,
//                               size: 17,
//                             ),
//                             const SizedBox(width: 10),
//                             Text(
//                               'Call',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.green.shade700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   workerData?.fullName ?? '',
//                   style: GoogleFonts.roboto(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.location_on,
//                       size: 17,
//                       color: Colors.green.shade700,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       workerData?.location?["address"] ?? "Location not available",
//                       style: GoogleFonts.roboto(
//                         fontSize: 13,
//                         color: Colors.black,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 10),
//                 _buildProfileCard(),
//                 const SizedBox(height: 16),
//                 _buildTabButtons(),
//                 const SizedBox(height: 10),
//
//                 // About My Skills
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
//                 // Document Section
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
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Document",
//                               style: GoogleFonts.roboto(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Container(
//                               width: 82,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(5),
//                                   border: Border.all(color: Colors.green, width: 2)),
//                               child: Center(
//                                   child: Text(
//                                     "Verified",
//                                     style: TextStyle(
//                                         color: Colors.green.shade700, fontWeight: FontWeight.w600),
//                                   )),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Image.asset('assets/images/line2.png'),
//                             const SizedBox(width: 5),
//                             Text(
//                               "Valid Id Proof",
//                               style: GoogleFonts.roboto(
//                                 color: Colors.black,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             const Spacer(),
//                             InkWell(
//                               onTap: () {
//                                 if (workerData?.documents != null && workerData!.documents!.isNotEmpty) {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => FullImageScreen(
//                                         imageUrl: workerData!.documents!,
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(content: Text("No document available")),
//                                   );
//                                 }
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.only(right: 18.0),
//                                 child: Align(
//                                   alignment: Alignment.topRight,
//                                   child: Image.network(
//                                     workerData?.documents ?? "",
//                                     height: 70,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         height: 70,
//                                         width: 50,
//                                         color: Colors.grey[300],
//                                         child: const Icon(Icons.document_scanner, color: Colors.grey),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Reviews
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
//
//                 // Hire Button / Negotiation
//                 widget.hirebuttonhide == 'hide'
//                     ? NegotiationCardUser(
//                   key:  UniqueKey(), // GlobalKey conflict fix
//                   workerId: widget.workerId,
//                   biddingOfferId: widget.biddingOfferId,
//                   oderId: widget.oderId,
//                   UserId: widget.UserId,
//                 )
//                     : const SizedBox(),
//
//                 widget.hideonly == 'hideOnly'
//                     ? const SizedBox()
//                     : GestureDetector(
//                   onTap: () {
//                     if (widget.workerId != null && widget.workerId!.isNotEmpty) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => HireScreen(
//                             firstProviderId: widget.workerId ?? "",
//                             categreyId: widget.categreyId,
//                             subcategreyId: widget.subcategreyId,
//                           ),
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
//                         color: Colors.green,
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
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileCard() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: double.infinity,
//         margin: const EdgeInsets.all(1),
//         decoration: BoxDecoration(
//           color: const Color(0xFF9DF89D),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             const SizedBox(height: 10),
//             Text(
//               "Category: ${workerData?.categoryName ?? 'N/A'}",
//               style: GoogleFonts.poppins(
//                 fontSize: 13,
//                 color: Colors.green.shade800,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Sub-Categories: ${workerData?.subcategoryNames?.join(', ') ?? 'N/A'}",
//                 style: GoogleFonts.poppins(fontSize: 13),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),
//                   CarouselSlider(
//                     key: ValueKey('carousel_${isHisWork ? 'hiswork' : 'reviews'}'), // GlobalKey fix
//                     options: CarouselOptions(
//                       height: 150.0,
//                       autoPlay: true,
//                       enlargeCenterPage: true,
//                       aspectRatio: 16 / 9,
//                       autoPlayInterval: const Duration(seconds: 3),
//                       autoPlayAnimationDuration: const Duration(milliseconds: 800),
//                       viewportFraction: 0.8,
//                     ),
//                     items: (isHisWork ? (workerData?.hisWork ?? []) : (workerData?.customerReview ?? []))
//                         .map((imageUrl) {
//                       return InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ViewImage(
//                                   imageUrl: isHisWork ? (workerData?.hisWork ?? []) : (workerData?.customerReview ?? []),
//                               ),
//                             ),
//                           );
//                         },
//                         child: Builder(
//                           builder: (BuildContext context) {
//                             return Container(
//                               width: MediaQuery.of(context).size.width,
//                               margin: const EdgeInsets.symmetric(horizontal: 5.0),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.network(
//                                   imageUrl,
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
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
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
//                     color: !isHisWork ? Colors.green.shade700 : Colors.transparent,
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
//                             img,
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 width: 50,
//                                 height: 50,
//                                 color: Colors.grey[300],
//                                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                               );
//                             },
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
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Bidding/Models/bidding_order.dart';
import '../../../Bidding/view/user/nagotiate_card.dart';
import '../../../chat/APIServices.dart';
import '../../../chat/SocketService.dart';
import '../../../chat/chatScreen.dart';
import '../../../testingfile.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../models/ServiceProviderModel/ServiceProviderProfileModel.dart';
import '../../models/userModel/UserViewWorkerDetailsModel.dart';
import '../comm/view_images_screen.dart';
import 'HireScreen.dart';

class UserViewWorkerDetails extends StatefulWidget {
  final categreyId;
  final subcategreyId;
  final String workerId;
  final String? hirebuttonhide;
  final String? hideonly;
  final oderId;
  final biddingOfferId;
  final UserId;

  const UserViewWorkerDetails({
    super.key,
    required this.workerId,
    this.categreyId,
    this.subcategreyId,
    this.hirebuttonhide,
    this.oderId,
    this.biddingOfferId,
    this.UserId,
    this.hideonly,
  });

  @override
  State<UserViewWorkerDetails> createState() => _UserViewWorkerDetailsState();
}

class _UserViewWorkerDetailsState extends State<UserViewWorkerDetails> {
  bool _showReviews = true;
  bool _showAllSubCategories = false;
  bool _showAllEmergencySubCategories = false;
  bool isHisWork = true;
  File? _pickedImage;
  ServiceProviderDetailModel? workerData;
  bool isLoading = true;
  bool _isSwitched = false;
  String userLocation = "Select Location";
  ServiceProviderProfileModel? profile;
  List<BiddingOrder> biddingOrders = [];

  @override
  void initState() {
    bwDebug(
        ".categreyId: ${widget.categreyId},workerId: ${widget.workerId},"
        ".subcategreyId: ${widget.subcategreyId},"
        ".hirebuttonhide: ${widget.hirebuttonhide},."
        "oderId: ${widget.oderId},"
        ".biddingOfferId: ${widget.biddingOfferId},"
        ".UserId: ${widget.UserId},"
        ".hideonly: ${widget.hideonly},",
        tag: "UserViewWorkDetail");
    super.initState();
    fetchWorkerDetails();
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

  Future<void> fetchWorkerDetails() async {
    print("Abhi:- serive providerId :- ${widget.workerId}");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        CustomSnackBar.show(
            message: "No auth token found", type: SnackBarType.warning);

        return;
      }

      print("Abhi:- worker details screen :-- workerId  : ${widget.workerId}");

      final response = await http.get(
        Uri.parse(
            "https://api.thebharatworks.com/api/user/getServiceProvider/${widget.workerId}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("API Response: ${response.body}"); // Debug ke liye

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            workerData = ServiceProviderDetailModel.fromJson(data['data']);
            isLoading = false;
          });
        } else {
          CustomSnackBar.show(
              message: "Worker data not found", type: SnackBarType.error);
        }
      } else {
        throw Exception("Failed to load worker details");
      }
    } catch (e) {
      bwDebug("error : $e");
      CustomSnackBar.show(
          message: "Error loading worker details", type: SnackBarType.error);
    }
  }

  ///--------------       Added chat code ------------------///

  Future<Map<String, dynamic>> fetchUserById(
      String userId, String token) async {
    try {
      print("Abhi:- Fetching user by ID: $userId");
      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUser/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print(
          "Abhi:- User fetch API response: ${response.statusCode}, Body=${response.body}");
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          final user = body['user'];
          user['_id'] = getIdAsString(user['_id']); // Ensure _id is string
          return user;
        } else {
          throw Exception(body['message'] ?? 'Failed to fetch user');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Abhi:- Error fetching user by ID: $e");
      return {'full_name': 'Unknown', '_id': userId, 'profile_pic': null};
    }
  }

  String getIdAsString(dynamic id) {
    if (id == null) return '';
    if (id is String) return id;
    if (id is Map && id.containsKey('\$oid')) return id['\$oid'].toString();
    print("Abhi:- Warning: Unexpected _id format: $id");
    return id.toString();
  }

// Yeh function InkWell ke onTap mein call hota hai
  Future<void> _startOrFetchConversation(
      BuildContext context, String receiverId) async {
    try {
      // Step 1: User ID fetch karo
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("Abhi:- Error: No token found");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No token found, please log in again')),
        );
        return;
      }

      // Step 2: User profile fetch karo
      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUserProfileData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print("Abhi:- Error fetching profile: Status=${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to fetch user profile')),
        );
        return;
      }

      final body = json.decode(response.body);
      if (body['status'] != true) {
        print("Abhi:- Error fetching profile: ${body['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: Failed to fetch profile: ${body['message']}')),
        );
        return;
      }

      final userId = getIdAsString(body['data']['_id']);
      if (userId.isEmpty) {
        print("Abhi:- Error: User ID is empty");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User ID not available')),
        );
        return;
      }

      // Step 3: Check if conversation exists
      print(
          "Abhi:- Checking for existing conversation with receiverId: $receiverId, userId: $userId");
      final convs = await ApiService.fetchConversations(userId);
      dynamic currentChat = convs.firstWhere(
        (conv) {
          final members = conv['members'] as List? ?? [];
          if (members.isEmpty) return false;
          if (members[0] is String) {
            return members.contains(receiverId) && members.contains(userId);
          } else {
            return members.any((m) => getIdAsString(m['_id']) == receiverId) &&
                members.any((m) => getIdAsString(m['_id']) == userId);
          }
        },
        orElse: () => null,
      );

      // Step 4: Agar conversation nahi hai, toh nayi conversation start karo
      if (currentChat == null) {
        print(
            "Abhi:- No existing conversation, starting new with receiverId: $receiverId");
        currentChat = await ApiService.startConversation(userId, receiverId);
      }

      // Step 5: Agar members strings hain, toh full user details fetch karo
      if (currentChat['members'].isNotEmpty &&
          currentChat['members'][0] is String) {
        print("Abhi:- New conversation, fetching user details for members");
        final otherId = currentChat['members'].firstWhere((id) => id != userId);
        final otherUserData = await fetchUserById(otherId, token);
        final senderUserData = await fetchUserById(userId, token);
        currentChat['members'] = [senderUserData, otherUserData];
        print(
            "Abhi:- Updated members with full details: ${currentChat['members']}");
      }

      // Step 6: Messages fetch karo
      final messages =
          await ApiService.fetchMessages(getIdAsString(currentChat['_id']));
      messages.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));

      // Step 7: Socket initialize karo
      SocketService.connect(userId);
      final onlineUsers = <String>[];
      SocketService.listenOnlineUsers((users) {
        onlineUsers.clear();
        onlineUsers.addAll(users.map((u) => getIdAsString(u)));
      });

      // Step 8: ChatDetailScreen push karo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StandaloneChatDetailScreen(
            initialCurrentChat: currentChat,
            initialUserId: userId,
            initialMessages: messages,
            initialOnlineUsers: onlineUsers,
          ),
        ),
      ).then((_) {
        SocketService.disconnect();
      });
    } catch (e, stackTrace) {
      print("Abhi:- Error starting conversation: $e");
      print("Abhi:- Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to start conversation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF9DF89D),
        centerTitle: true,
        title: const Text("Worker Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF9DF89D),
          statusBarIconBrightness: Brightness.dark,
        ),

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
                // LayoutBuilder(
                //   builder: (context,constraints) {
                //     return ClipPath(
                //       clipper: BottomCurveClipper(),
                //       child: Container(
                //         width: constraints.maxWidth,
                //         color: const Color(0xFF9DF89D),
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 16,
                //           vertical: 16,
                //         ),
                //         height: 100,
                //
                //       ),
                //     );
                //   }
                // ),

                // Profile Image, Message, Call, Name, Location
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       // Message Button
                //       GestureDetector(
                //         onTap: () async {
                //           final receiverId =
                //               widget.workerId != null && widget.workerId != null
                //                   ? widget.workerId?.toString() ?? 'Unknown'
                //                   : 'Unknown';
                //           final fullName = widget.workerId != null &&
                //                   workerData?.fullName != null
                //               ? workerData?.fullName ?? 'No data'
                //               : 'Unknown';
                //           print(
                //               "Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullName");
                //
                //           if (receiverId != 'Unknown' &&
                //               receiverId.isNotEmpty) {
                //             await _startOrFetchConversation(
                //                 context, receiverId);
                //           } else {
                //             print("Abhi:- Error: Invalid receiver ID");
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               SnackBar(
                //                   content: Text('Error: Invalid receiver ID')),
                //             );
                //           }
                //         },
                //         child: Container(
                //           height: 30,
                //           width: 85,
                //           padding: const EdgeInsets.all(5),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(8),
                //             border: Border.all(
                //               color: Colors.green.shade700,
                //               width: 1.5,
                //             ),
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               InkWell(
                //                 child: Icon(
                //                   Icons.message,
                //                   color: Colors.green,
                //                   size: 14,
                //                 ),
                //               ),
                //               const SizedBox(width: 5),
                //               Text(
                //                 'Message',
                //                 style: GoogleFonts.roboto(
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w500,
                //                   color: Colors.green.shade700,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //
                //       const Spacer(), // Centering ke liye
                //
                //       // Profile Image with Tap
                //       GestureDetector(
                //         onTap: () {
                //           print(
                //               "Profile image tapped: ${workerData?.profilePic}");
                //           if (workerData?.profilePic != null &&
                //               workerData!.profilePic!.isNotEmpty) {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => ViewImage(
                //                     imageUrl: workerData!.profilePic!),
                //               ),
                //             );
                //           } else {
                //             CustomSnackBar.show(
                //                 message: "No profile image available",
                //                 type: SnackBarType.info);
                //           }
                //         },
                //         child: CircleAvatar(
                //           radius: 50,
                //           backgroundColor: Colors.grey.shade300,
                //           backgroundImage: workerData?.profilePic != null &&
                //                   workerData!.profilePic!.isNotEmpty
                //               ? NetworkImage(workerData!.profilePic!)
                //               : null,
                //           child: workerData?.profilePic == null ||
                //                   workerData!.profilePic!.isEmpty
                //               ? const Icon(
                //                   Icons.person,
                //                   size: 50,
                //                   color: Colors.white,
                //                 )
                //               : null,
                //         ),
                //       ),
                //
                //       const Spacer(), // Centering ke liye
                //
                //       // Call Button
                //       Padding(
                //         padding: const EdgeInsets.only(left: 18.0),
                //         child: Container(
                //           height: 30,
                //           width: 80,
                //           padding: const EdgeInsets.all(5),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(8),
                //             border: Border.all(
                //               color: Colors.green.shade700,
                //               width: 1.4,
                //             ),
                //           ),
                //           child: Row(
                //             children: [
                //               Icon(
                //                 Icons.call,
                //                 color: Colors.green.shade700,
                //                 size: 17,
                //               ),
                //               const SizedBox(width: 10),
                //               Text(
                //                 'Call',
                //                 style: GoogleFonts.roboto(
                //                   fontSize: 12,
                //                   fontWeight: FontWeight.w500,
                //                   color: Colors.green.shade700,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Message Button
                      GestureDetector(
                        onTap: () async {
                          final receiverId =
                              widget.workerId?.toString() ?? 'Unknown';
                          final fullName = workerData?.fullName ?? 'Unknown';

                          if (receiverId != 'Unknown' &&
                              receiverId.isNotEmpty) {
                            await _startOrFetchConversation(
                                context, receiverId);
                          } else {
                            CustomSnackBar.show(
                                message: "Invalid receiver ID",
                                type: SnackBarType.error);
                          }
                        },
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
                              Icon(Icons.message,
                                  color: Colors.green, size: 14),
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

                      // Profile Image
                      GestureDetector(
                        onTap: () {
                          if (workerData?.profilePic != null &&
                              workerData!.profilePic!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewImage(
                                    imageUrl: workerData!.profilePic!),
                              ),
                            );
                          } else {
                            CustomSnackBar.show(
                                message: "No profile image available",
                                type: SnackBarType.info);
                          }
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: workerData?.profilePic != null &&
                                  workerData!.profilePic!.isNotEmpty
                              ? NetworkImage(workerData!.profilePic!)
                              : null,
                          child: workerData?.profilePic == null ||
                                  workerData!.profilePic!.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                      ),

                      // Call Button
                      GestureDetector(
                        onTap: () {

                        },
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
                              Icon(Icons.call,
                                  color: Colors.green.shade700, size: 17),
                              const SizedBox(width: 5),
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
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 17,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        // ya Expanded bhi use kar sakti hai, but Flexible zyada flexible hai
                        child: Text(
                          workerData?.location?["address"] ??
                              "Location not available",
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow
                              .ellipsis, // overflow handle karne ke liye
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${workerData?.totalReview ?? 0} Reviews",
                      style: GoogleFonts.roboto(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: [
                        Text(
                          '(${workerData?.rating ?? 0.0} ',
                          style: GoogleFonts.roboto(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(
                          ')',
                          style: GoogleFonts.roboto(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildProfileCard(),
                const SizedBox(height: 16),
                // _buildTabButtons(),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffeaffea),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 160,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                          ),
                          items: (_showReviews
                                  ? (workerData?.hisWork?.isNotEmpty ?? false)
                                      ? workerData!.hisWork!
                                      : [
                                          'assets/images/d_png/No_Image_Available.jpg'
                                        ]
                                  : (workerData?.customerReview?.isNotEmpty ??
                                          false)
                                      ? workerData!.customerReview!
                                      : [
                                          'assets/images/d_png/No_Image_Available.jpg'
                                        ])
                              .map((imageUrl) {
                            return Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: imageUrl.startsWith('assets/')
                                      ? null
                                      : () {
                                          Get.to(() => ViewImage(
                                                    imageUrl: imageUrl,
                                                    title: "His Work",
                                                  ) /*FullImageScreen(
                                      imageUrl: imageUrl,
                                    )*/
                                              ); /*_showReviews
                                  ? GalleryScreen(images: profile?.hisWork ?? [], serviceProviderId: profile?.id ?? "")
                                  : ReviewImagesScreen(images: profile?.customerReview ?? []));*/
                                        },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imageUrl.startsWith('assets/')
                                          ? Image.asset(imageUrl,
                                              fit: BoxFit.cover)
                                          : Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                'assets/images/d_png/No_Image_Available.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildTabButtons(),
                        ),
                      ],
                    ),
                  ),
                ),
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
                          "About My Skills",
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
                /* Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 0.42.toWidthPercent(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Document",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 82,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.green, width: 2)),
                              child: Center(
                                  child: Text(
                                    "Verified",
                                    style: TextStyle(
                                        color: Colors.green.shade700, fontWeight: FontWeight.w600),
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Image.asset('assets/images/line2.png'),
                            const SizedBox(width: 5),
                            Text(
                              "Valid Id Proof",
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                // if (workerData?.documents != null && workerData!.documents!.isNotEmpty) {
                                final imageUrl = getFirstDocumentImage(workerData?.documents);
                                if (imageUrl != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullImageScreen(
                                        // imageUrl: workerData!.documents!,+
                                        imageUrl: imageUrl,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("No document available")),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Image.network(
                                    //workerData?.documents ?? "",
                                    getFirstDocumentImage(workerData?.documents) ?? "",
                                    height: 72,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 80,
                                        width: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.document_scanner, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),*/
// Document Section
                // Document Section
                // Document Section
                // Document Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final validImages = workerData?.documents
                              ?.where((doc) =>
                                  doc.images != null && doc.images!.isNotEmpty)
                              .expand((doc) => doc.images!)
                              .toList() ??
                          [];
                      return Container(
                        height: validImages.isEmpty ? 151.2 : null,
                        // Use original height for empty case, else auto-size
                        width: constraints.maxWidth,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Document",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  width: 82,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.green, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Verified",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/line2.png',
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Valid Id Proof",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: validImages.isEmpty ? null : 72,
                              // Image height when images exist
                              child: validImages.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No documents",
                                        style: GoogleFonts.roboto(fontSize: 13),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: validImages.length,
                                      itemBuilder: (context, index) {
                                        final imageUrl = validImages[index];
                                        bwDebug(" image url: $imageUrl");
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewImage(
                                                    imageUrl: imageUrl,
                                                    title: "Document",
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Image.network(
                                              imageUrl,
                                              height: 72,
                                              width: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/d_png/No_Image_Available.jpg',
                                                  height: 72,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
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

                // Hire Button / Negotiation
                widget.hirebuttonhide == 'hide'
                    ? NegotiationCardUser(
                        key: ValueKey('negotiationCardKey'),
                        // GlobalKey conflict fix
                        workerId: widget.workerId,
                        biddingOfferId: widget.biddingOfferId,
                        oderId: widget.oderId,
                        UserId: widget.UserId,
                      )
                    : const SizedBox(),

                // widget.hideonly == 'hideOnly'
                //     ? const SizedBox()
                //     : GestureDetector(
                //         onTap: () {
                //           if (widget.workerId != null &&
                //               widget.workerId!.isNotEmpty) {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (_) => HireScreen(
                //                   firstProviderId: widget.workerId ?? "",
                //                   categreyId: widget.categreyId,
                //                   subcategreyId: widget.subcategreyId,
                //                 ),
                //               ),
                //             );
                //           }
                //         },
                //         child: Padding(
                //           padding: const EdgeInsets.all(15.0),
                //           child: Container(
                //             height: 45,
                //             width: double.infinity,
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(15),
                //               color: Colors.green,
                //             ),
                //             child: Center(
                //               child: Text(
                //                 "Hire",
                //                 style: GoogleFonts.roboto(
                //                   fontSize: 16,
                //                   fontWeight: FontWeight.w500,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:   widget.hideonly == 'hideOnly'
          ? const SizedBox()
          : GestureDetector(
        onTap: () {
          if (widget.workerId != null &&
              widget.workerId!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HireScreen(
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
            //width: double.infinity,
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
        child: /*Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Category: ${workerData?.categoryName ?? 'N/A'}",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.green.shade800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Sub-Categories: ${workerData?.subcategoryNames?.join(', ') ?? 'N/A'}",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Emergency Sub-Categories: ${workerData?.subcategoryNames?.join(', ') ?? 'N/A'}",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CarouselSlider(
                    key: ValueKey('carousel_${isHisWork ? 'hiswork' : 'reviews'}'), // GlobalKey fix
                    options: CarouselOptions(
                      height: 150.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      viewportFraction: 0.8,
                    ),
                    items: (isHisWork
                        ? (workerData?.hisWork?.isNotEmpty ?? false)
                        ? workerData!.hisWork!
                        : ['assets/images/d_png/No_Image_Available.jpg']
                        : (workerData?.customerReview?.isNotEmpty ?? false)
                        ? workerData!.customerReview!
                        : ['assets/images/d_png/No_Image_Available.jpg'])
                        .map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.startsWith('assets/')
                                  ? Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                                  : InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewImage(
                                        imageUrl: isHisWork
                                            ? (workerData?.hisWork ?? [])
                                            : (workerData?.customerReview ?? []),
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/d_png/No_Image_Available.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),*/

            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 11),
                  children: [
                    TextSpan(
                      text: "Category: ",
                      style: GoogleFonts.roboto(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: workerData?.categoryName ?? 'N/A',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 11),
                  // children: [
                  // TextSpan(
                  //   text: "Sub-Category: ",
                  //   style: GoogleFonts.roboto(
                  //     color: Colors.green.shade800,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 13,
                  //   ),
                  // ),
                  // TextSpan(
                  //   text:
                  //   workerData?.subcategoryNames?.join(', ') ?? 'N/A',
                  //   style: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 12,
                  //   ),
                  // ),
                  //
                  //
                  // ],
                  children: _buildCategoryTextSpans(
                    workerData?.subcategoryNames ?? [],
                    _showAllSubCategories,
                    () {
                      setState(() {
                        _showAllSubCategories = !_showAllSubCategories;
                      });
                    },
                    "Sub-Category",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            /*      (profile?.subEmergencyCategoryNames != null &&
                    profile!.subEmergencyCategoryNames!.isNotEmpty)? */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 11),
                  /* children: [
                    TextSpan(
                      text: "Emergency Sub-Category: ",
                      style: GoogleFonts.roboto(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text:
                      workerData?.emergencySubcategoryNames?.join(', ') ??
                          'N/A',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],*/
                  children: _buildCategoryTextSpans(
                    workerData?.emergencySubcategoryNames ?? [],
                    _showAllEmergencySubCategories,
                    () {
                      setState(() {
                        _showAllEmergencySubCategories =
                            !_showAllEmergencySubCategories;
                      });
                    },
                    "Emergency Sub-Category",
                  ),
                ),
              ),
            ) /*:SizedBox()*/,
          ],
        ),
      ),
    );
  }

/*  Widget _buildTabButtons() {
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
                    color: isHisWork ? Colors.green.shade700 : Colors
                        .transparent,
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
                    color: !isHisWork ? Colors.green.shade700 : Colors
                        .transparent,
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
  }*/
  Widget _buildTabButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton("His Work", _showReviews, () {
          setState(() => _showReviews = true);
        }),
        const SizedBox(width: 10),
        _tabButton("Customer Review", !_showReviews, () {
          setState(() => _showReviews = false);
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
            color: selected ? Colors.green.shade700 : const Color(0xFFC3FBD8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade700),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.green.shade800,
            ),
          ),
        ),
      ),
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
      children: workerData!.rateAndReviews!.map((review) {
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
                      children: review.images.map((img) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Image.network(
                            img,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Image.asset(
                      'assets/images/d_png/No_Image_Available.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String? getFirstDocumentImage(List<Document>? documents) {
    if (documents == null || documents.isEmpty) {
      return null;
    }
    final firstDocument = documents.first;
    if (firstDocument.images != null && firstDocument.images!.isNotEmpty) {
      return firstDocument.images!.first;
    }
    return null;
  }

  List<TextSpan> _buildCategoryTextSpans(
    List<String> names,
    bool showAll,
    VoidCallback toggleShowAll,
    String categoryType,
  ) {
    if (names.isEmpty) {
      return [
        TextSpan(
          text: "$categoryType: ",
          style: GoogleFonts.roboto(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const TextSpan(
          text: 'N/A',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ];
    }

    const maxVisible = 3;
    final visibleNames = showAll ? names : names.take(maxVisible).toList();
    final moreCount = names.length - maxVisible;

    List<TextSpan> spans = [
      TextSpan(
        text: "$categoryType: ",
        style: GoogleFonts.roboto(
          color: Colors.green.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      TextSpan(
        text: visibleNames.join(', '),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ];

    if (moreCount > 0 && !showAll) {
      spans.add(
        TextSpan(
          text: " +$moreCount more",
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          recognizer: TapGestureRecognizer()..onTap = toggleShowAll,
        ),
      );
    } else if (showAll && names.length > maxVisible) {
      spans.add(
        TextSpan(
          text: " Hide",
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          recognizer: TapGestureRecognizer()..onTap = toggleShowAll,
        ),
      );
    }

    return spans;
  }
/*
  List<TextSpan> _buildSubcategoryTextSpans(List<String> names) {
    const maxVisible = 3; // ya 4
    final visibleNames = names.take(maxVisible).toList();
    final moreCount = names.length - maxVisible;

    List<TextSpan> spans = [
      TextSpan(
        text: visibleNames.join(', '),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      )
    ];

    if (moreCount > 0) {
      spans.add(
        TextSpan(
          text: " +$moreCount more",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // Yahan show dialog ya bottom sheet me full list dikha sakte ho
              showDialog(
                context: context,
                builder: (_) =>
                    AlertDialog(
                      title: const Text("Sub-Categories"),
                      content: Text(names.join(', ')),
                    ),
              );
            },
        ),
      );
    }

    return spans;
  }
*/
// List<String> getAllDocumentImages(List<Document>? documents) {
//   if (documents == null || documents.isEmpty) {
//     return [];
//   }
//   return documents
//       .where((doc) => doc.images != null && doc.images!.isNotEmpty)
//       .expand((doc) => doc.images!) // Flatten all images into one list
//       .toList();
// }
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
