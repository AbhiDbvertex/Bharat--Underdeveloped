// // import 'package:developer/Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// //
// // import '../../Widgets/AppColors.dart';
// //
// // class WorkerRecentPostedScreen extends StatefulWidget {
// //   @override
// //   _WorkerRecentPostedScreenState createState() =>
// //       _WorkerRecentPostedScreenState();
// // }
// //
// // class _WorkerRecentPostedScreenState extends State<WorkerRecentPostedScreen> {
// //   final List<Map<String, dynamic>> items = [
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Cancelled",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Accepted",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Completed",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Review",
// //     },
// //   ];
// //
// //   List<Map<String, dynamic>> filteredItems = [];
// //   TextEditingController _searchController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     filteredItems = items;
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   Color getStatusColor(String status) {
// //     switch (status) {
// //       case "Cancelled":
// //         return Colors.red;
// //       case "Accepted":
// //         return Colors.green;
// //       case "Completed":
// //         return Colors.green.shade800;
// //       case "Review":
// //         return Colors.brown;
// //       default:
// //         return Colors.transparent;
// //     }
// //   }
// //
// //   void _filterItems(String query) {
// //     setState(() {
// //       if (query.isEmpty) {
// //         filteredItems = items;
// //         filteredItems = items.where((item) {
// //           final title = item["title"].toString().toLowerCase();
// //           final desc = item["desc"].toString().toLowerCase();
// //           return title.contains(query.toLowerCase()) ||
// //               desc.contains(query.toLowerCase());
// //         }).toList();
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: AppColors.primaryGreen,
// //         centerTitle: true,
// //         elevation: 0,
// //         toolbarHeight: 20,
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             SizedBox(height: 20),
// //             Row(
// //               children: [
// //                 GestureDetector(
// //                   onTap: () => Navigator.pop(context),
// //                   child: const Padding(
// //                     padding: EdgeInsets.only(left: 8.0),
// //                     child: Icon(Icons.arrow_back, size: 25),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 50),
// //                 Text(
// //                   "Recent Posted work",
// //                   style: GoogleFonts.roboto(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //                 ),
// //                 SizedBox(width: 50),
// //                 Image.asset("assets/images/vec1.png"),
// //               ],
// //             ),
// //             SizedBox(height: 10),
// //             Card(
// //               child: Container(
// //                 height: 50,
// //                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(10),
// //                   color: Colors.white,
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(Icons.search_rounded, color: Colors.grey),
// //                     SizedBox(width: 10),
// //                     Expanded(
// //                       child: TextField(
// //                         controller: _searchController,
// //                         decoration: InputDecoration(
// //                           hintText: 'Search for services',
// //                           hintStyle: TextStyle(color: Colors.grey),
// //                           border: InputBorder.none,
// //                         ),
// //                         onChanged: (value) {
// //                           _filterItems(value); // Har type par filter karo
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: 10),
// //             Column(
// //               children: filteredItems.asMap().entries.map((entry) {
// //                 var index = entry.key;
// //                 var item = entry.value;
// //                 return Card(
// //                   color: Colors.white,
// //                   margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
// //                   elevation: 4,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     side: BorderSide(
// //                       color: Colors.green,
// //                       width: 1.0,
// //                     ),
// //                   ),
// //                   child: Padding(
// //                     padding: EdgeInsets.all(8.0),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         ClipRRect(
// //                           borderRadius: BorderRadius.circular(10),
// //                           child: Image.asset(
// //                             "assets/images/chair.png",
// //                             width: 100,
// //                             height: 100,
// //                             fit: BoxFit.cover,
// //                           ),
// //                         ),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 item["title"],
// //                                 style: TextStyle(
// //                                   fontSize: 18,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               Text(
// //                                 item["price"],
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   color: Colors.green,
// //                                 ),
// //                               ),
// //                               Row(
// //                                 children: [
// //                                   Expanded(
// //                                     child: Padding(
// //                                       padding: const EdgeInsets.only(top: 12.0),
// //                                       child: Text(item["desc"]),
// //                                     ),
// //                                   ),
// //                                   if (item["status"] != "")
// //                                     SizedBox(
// //                                       width: 80,
// //                                       height: 30,
// //                                       child: Container(
// //                                         decoration: BoxDecoration(
// //                                           color: getStatusColor(item["status"]),
// //                                           borderRadius:
// //                                               BorderRadius.circular(8),
// //                                         ),
// //                                         child: Center(
// //                                           child: Text(
// //                                             item["status"],
// //                                             style: TextStyle(
// //                                               color: Colors.white,
// //                                               fontSize: 12,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                 ],
// //                               ),
// //                               Row(
// //                                 children: [
// //                                   Text(
// //                                     "Date: ${item["date"]}",
// //                                     style: TextStyle(fontSize: 14),
// //                                   ),
// //                                   SizedBox(width: 54),
// //                                   GestureDetector(
// //                                     onTap: () {
// //                                       Navigator.push(
// //                                         context,
// //                                         MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               Biddingserviceproviderworkdetail(
// //                                             orderId: '',
// //                                           ),
// //                                         ),
// //                                       );
// //                                     },
// //                                     child: Padding(
// //                                       padding: const EdgeInsets.only(top: 8.0),
// //                                       child: SizedBox(
// //                                         width: 80,
// //                                         height: 30,
// //                                         child: Container(
// //                                           decoration: BoxDecoration(
// //                                             color: Colors.green,
// //                                             borderRadius:
// //                                                 BorderRadius.circular(8),
// //                                           ),
// //                                           child: Center(
// //                                             child: Text(
// //                                               "View Details",
// //                                               style: TextStyle(
// //                                                 color: Colors.white,
// //                                                 fontSize: 12,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:convert';
//
// import 'package:developer/Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
//
// class UserId {
//   final String id;
//   final String fullName;
//   final String? profilePic;
//
//   UserId({
//     required this.id,
//     required this.fullName,
//     this.profilePic,
//   });
//
//   factory UserId.fromJson(Map<String, dynamic> json) {
//     return UserId(
//       id: json['_id'] ?? '',
//       fullName: json['full_name'] ?? 'Unknown',
//       profilePic: json['profile_pic'],
//     );
//   }
// }
//
// class BiddingOrder {
//   final String id;
//   final String projectId;
//   final String title;
//   final String description;
//   final String address;
//   final double cost;
//   final String deadline;
//   final String hireStatus;
//   final String? serviceProviderId;
//   final List<String> imageUrls;
//   final UserId? userId;
//
//   BiddingOrder({
//     required this.id,
//     required this.projectId,
//     required this.title,
//     required this.description,
//     required this.address,
//     required this.cost,
//     required this.deadline,
//     required this.hireStatus,
//     this.serviceProviderId,
//     required this.imageUrls,
//     this.userId,
//   });
//
//   factory BiddingOrder.fromJson(Map<String, dynamic> json) {
//     List<String> imageUrls = [];
//     if (json['image_url'] != null) {
//       if (json['image_url'] is String) {
//         String cleanUrl =
//             json['image_url'].toString().replaceAll('//uploads', '/uploads');
//         imageUrls = [
//           cleanUrl.startsWith('http')
//               ? cleanUrl
//               : 'https://api.thebharatworks.com$cleanUrl'
//         ];
//       } else if (json['image_url'] is List<dynamic>) {
//         imageUrls = (json['image_url'] as List<dynamic>).map((url) {
//           String cleanUrl = url.toString().replaceAll('//uploads', '/uploads');
//           return cleanUrl.startsWith('http')
//               ? cleanUrl
//               : 'https://api.thebharatworks.com$cleanUrl';
//         }).toList();
//       }
//     }
//
//     return BiddingOrder(
//       id: json['_id'] ?? '',
//       projectId: json['project_id'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       address: json['address'] ?? '',
//       cost: (json['cost'] ?? 0).toDouble(),
//       deadline: json['deadline'] ?? '',
//       hireStatus: json['hire_status'] ?? 'pending',
//       serviceProviderId: json['service_provider_id'] != null
//           ? json['service_provider_id'] is String
//               ? json['service_provider_id']
//               : json['service_provider_id']['_id'] ?? ''
//           : null,
//       imageUrls: imageUrls,
//       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
//     );
//   }
// }
//
// class WorkerRecentPostedScreen extends StatefulWidget {
//   @override
//   _WorkerRecentPostedScreenState createState() =>
//       _WorkerRecentPostedScreenState();
// }
//
// class _WorkerRecentPostedScreenState extends State<WorkerRecentPostedScreen> {
//   List<BiddingOrder> biddingOrders = [];
//   List<BiddingOrder> filteredBiddingOrders = [];
//   TextEditingController _searchController = TextEditingController();
//   bool isLoading = true;
//   String? errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     print('WorkerRecentPostedScreen initialized');
//     fetchBiddingOrders();
//     _searchController.addListener(() {
//       _filterItems(_searchController.text);
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//   Future<void> fetchBiddingOrders() async {
//     setState(() => isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print('🔐 Token: $token');
//
//       if (token.isEmpty) {
//         setState(() {
//           isLoading = false;
//           errorMessage = 'Please login again to fetch bidding orders';
//         });
//         _showSnackBar('Please login again');
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }
//
//       final res = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('📥 Bidding Response Status: ${res.statusCode}');
//       print('📥 Bidding Response Body: ${res.body}');
//
//       if (res.statusCode == 200) {
//         final decoded = json.decode(res.body);
//         if (decoded.containsKey('data') && decoded['data'] is List) {
//           final List<dynamic> data = decoded['data'];
//           setState(() {
//             biddingOrders = data.map((e) => BiddingOrder.fromJson(e)).toList();
//             filteredBiddingOrders = biddingOrders;
//           });
//           print("✅ Bidding Orders Fetched: ${biddingOrders.length}");
//           print(
//               "Image URLs in Orders: ${biddingOrders.map((e) => e.imageUrls).toList()}");
//         } else {
//           print("❌ 'data' key missing or invalid: ${decoded['data']}");
//           setState(() {
//             errorMessage = "Bidding orders data not found";
//           });
//           _showSnackBar("Bidding orders data not found");
//         }
//       } else {
//         print("❌ API Error Status: ${res.statusCode}");
//         setState(() {
//           errorMessage = "Failed to fetch bidding orders: ${res.statusCode}";
//         });
//         _showSnackBar("Failed to fetch bidding orders: ${res.statusCode}");
//         if (res.statusCode == 401) {
//           Navigator.pushReplacementNamed(context, '/login');
//         }
//       }
//     } catch (e) {
//       print("❌ API Exception: $e");
//       setState(() {
//         errorMessage = "Something went wrong: $e";
//       });
//       _showSnackBar("Something went wrong: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'cancelled':
//         return Colors.red;
//       case 'accepted':
//         return Colors.green;
//       case 'completed':
//         return Colors.green;
//       case 'review':
//         return Colors.brown;
//       case 'pending':
//         return Colors.orange;
//       default:
//         return Colors.transparent;
//     }
//   }
//
//   void _filterItems(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredBiddingOrders = biddingOrders;
//       } else {
//         filteredBiddingOrders = biddingOrders.where((item) {
//           final title = item.title.toLowerCase();
//           final desc = item.description.toLowerCase();
//           return title.contains(query.toLowerCase()) ||
//               desc.contains(query.toLowerCase());
//         }).toList();
//       }
//       print('Filtered items: ${filteredBiddingOrders.length}');
//     });
//   }
//
//   Widget buildNetworkImage(String? url,
//       {required double width, required double height}) {
//     print('Trying to load image: $url');
//     return url != null &&
//             url.isNotEmpty &&
//             !url.contains('via.placeholder.com') &&
//             url != 'https://via.placeholder.com/150'
//         ? Image.network(
//             url,
//             width: width,
//             height: height,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               print('Image load error: $error for URL: $url');
//               return Image.asset(
//                 "assets/images/chair.png",
//                 width: width,
//                 height: height,
//                 fit: BoxFit.cover,
//               );
//             },
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                 child: CircularProgressIndicator(
//                   value: loadingProgress.expectedTotalBytes != null
//                       ? loadingProgress.cumulativeBytesLoaded /
//                           (loadingProgress.expectedTotalBytes ?? 1)
//                       : null,
//                 ),
//               );
//             },
//           )
//         : Image.asset(
//             "assets/images/chair.png",
//             width: width,
//             height: height,
//             fit: BoxFit.cover,
//           );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     print('Building WorkerRecentPostedScreen');
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: screenHeight * 0.02,
//         automaticallyImplyLeading: false,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(child: Text(errorMessage!))
//               : SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       SizedBox(height: screenHeight * 0.02),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: Padding(
//                               padding:
//                                   EdgeInsets.only(left: screenWidth * 0.03),
//                               child: Icon(Icons.arrow_back,
//                                   size: screenWidth * 0.06),
//                             ),
//                           ),
//                           SizedBox(width: screenWidth * 0.13),
//                           Text(
//                             "Recent Posted Work",
//                             style: GoogleFonts.roboto(
//                               fontSize: screenWidth * 0.045,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(width: screenWidth * 0.13),
//                           SvgPicture.asset(
//                             'assets/svg_images/Vector1.svg',
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: screenHeight * 0.010),
//                       Card(
//                         child: Container(
//                           width: screenWidth *
//                               0.95, // 👈 यहां width control करो (80% of screen)
//
//                           height: screenHeight * 0.07,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: screenWidth * 0.010,
//                               vertical: screenHeight * 0.015),
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.circular(screenWidth * 0.025),
//                             color: Colors.white,
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.search_rounded,
//                                   color: Colors.grey, size: screenWidth * 0.06),
//                               SizedBox(width: screenWidth * 0.025),
//                               Expanded(
//                                 child: TextField(
//                                   controller: _searchController,
//                                   decoration: InputDecoration(
//                                     hintText: 'Search for services',
//                                     hintStyle: TextStyle(
//                                         color: Colors.grey,
//                                         fontSize: screenWidth * 0.04),
//                                     border: InputBorder.none,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.0),
//                       filteredBiddingOrders.isEmpty
//                           ? Center(child: Text("No orders found"))
//                           : Column(
//                               children: filteredBiddingOrders
//                                   .asMap()
//                                   .entries
//                                   .map((entry) {
//                                 var index = entry.key;
//                                 var item = entry.value;
//                                 return Card(
//                                   color: Colors.white,
//                                   margin: EdgeInsets.symmetric(
//                                       vertical: screenHeight * 0.015,
//                                       horizontal: screenWidth * 0.02),
//                                   elevation: 4,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         screenWidth * 0.025),
//                                     side: BorderSide(
//                                       color: Colors.green,
//                                       width: screenWidth * 0.0025,
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: EdgeInsets.all(screenWidth * 0.02),
//                                     child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               screenWidth * 0.025),
//                                           child: buildNetworkImage(
//                                             item.imageUrls.isNotEmpty
//                                                 ? item.imageUrls[0]
//                                                 : null,
//                                             width: screenWidth * 0.25,
//                                             height: screenHeight * 0.15,
//                                           ),
//                                         ),
//                                         SizedBox(width: screenWidth * 0.025),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 item.title,
//                                                 style: TextStyle(
//                                                   fontSize: screenWidth * 0.045,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "₹${item.cost.toStringAsFixed(0)}",
//                                                 style: TextStyle(
//                                                   fontSize: screenWidth * 0.04,
//                                                   color: Colors.green,
//                                                 ),
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Padding(
//                                                       padding: EdgeInsets.only(
//                                                           top: screenHeight *
//                                                               0.015),
//                                                       child: Text(
//                                                           item.description),
//                                                     ),
//                                                   ),
//                                                   if (item
//                                                       .hireStatus.isNotEmpty)
//                                                     SizedBox(
//                                                       width: screenWidth * 0.2,
//                                                       height:
//                                                           screenHeight * 0.04,
//                                                       child: Container(
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color: getStatusColor(
//                                                               item.hireStatus),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       screenWidth *
//                                                                           0.02),
//                                                         ),
//                                                         child: Center(
//                                                           child: Text(
//                                                             item.hireStatus,
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize:
//                                                                   screenWidth *
//                                                                       0.03,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                 ],
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Expanded(
//                                                     child: Text(
//                                                       "Date: ${item.deadline.split('T')[0]}",
//                                                       style: TextStyle(
//                                                           fontSize:
//                                                               screenWidth *
//                                                                   0.035),
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                   GestureDetector(
//                                                     onTap: () {
//                                                       print(
//                                                           'Navigating to details with orderId: ${item.id}');
//                                                       Navigator.push(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               Biddingserviceproviderworkdetail(
//                                                             orderId: item.id,
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                     child: Padding(
//                                                       padding: EdgeInsets.only(
//                                                           top: screenHeight *
//                                                               0.01),
//                                                       child: SizedBox(
//                                                         width:
//                                                             screenWidth * 0.2,
//                                                         height:
//                                                             screenHeight * 0.04,
//                                                         child: Container(
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             color: Colors
//                                                                 .green.shade700,
//                                                             borderRadius:
//                                                                 BorderRadius.circular(
//                                                                     screenWidth *
//                                                                         0.02),
//                                                           ),
//                                                           child: Center(
//                                                             child: Text(
//                                                               "View Details",
//                                                               style: TextStyle(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 fontSize:
//                                                                     screenWidth *
//                                                                         0.03,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widgets/AppColors.dart';
import 'BiddingServiceProviderWorkdetail.dart';

class UserId {
  final String id;
  final String fullName;
  final String? profilePic;

  UserId({
    required this.id,
    required this.fullName,
    this.profilePic,
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      profilePic: json['profile_pic'],
    );
  }
}

class BiddingOrder {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String address;
  final double cost;
  final String deadline;
  final String hireStatus;
  final String? serviceProviderId;
  final List<String> imageUrls;
  final UserId? userId;

  BiddingOrder({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.address,
    required this.cost,
    required this.deadline,
    required this.hireStatus,
    this.serviceProviderId,
    required this.imageUrls,
    this.userId,
  });

  factory BiddingOrder.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    if (json['image_url'] != null) {
      if (json['image_url'] is String) {
        String cleanUrl =
            json['image_url'].toString().replaceAll('//uploads', '/uploads');
        imageUrls = [
          cleanUrl.startsWith('http')
              ? cleanUrl
              : 'https://api.thebharatworks.com$cleanUrl'
        ];
      } else if (json['image_url'] is List<dynamic>) {
        imageUrls = (json['image_url'] as List<dynamic>).map((url) {
          String cleanUrl = url.toString().replaceAll('//uploads', '/uploads');
          return cleanUrl.startsWith('http')
              ? cleanUrl
              : 'https://api.thebharatworks.com$cleanUrl';
        }).toList();
      }
    }

    return BiddingOrder(
      id: json['_id'] ?? '',
      projectId: json['project_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      deadline: json['deadline'] ?? '',
      hireStatus: json['hire_status'] ?? 'pending',
      serviceProviderId: json['service_provider_id'] != null
          ? json['service_provider_id'] is String
              ? json['service_provider_id']
              : json['service_provider_id']['_id'] ?? ''
          : null,
      imageUrls: imageUrls,
      userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
    );
  }
}

class WorkerRecentPostedScreen extends StatefulWidget {
  @override
  _WorkerRecentPostedScreenState createState() =>
      _WorkerRecentPostedScreenState();
}

class _WorkerRecentPostedScreenState extends State<WorkerRecentPostedScreen> {
  List<BiddingOrder> biddingOrders = [];
  List<BiddingOrder> filteredBiddingOrders = [];
  TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('WorkerRecentPostedScreen initialized');
    fetchBiddingOrders();
    _searchController.addListener(() {
      _filterItems(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchBiddingOrders() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print('🔐 Token: $token');

      if (token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'Please login again to fetch bidding orders';
        });
        _showSnackBar('Please login again');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final res = await http.get(
        Uri.parse(
            // 'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
            'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Bidding Response Status: ${res.statusCode}');
      print('📥 Bidding Response Body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded.containsKey('data') && decoded['data'] is List) {
          final List<dynamic> data = decoded['data'];
          setState(() {
            biddingOrders = data.map((e) => BiddingOrder.fromJson(e)).toList();
            filteredBiddingOrders = biddingOrders;
          });
          print("✅ Bidding Orders Fetched: ${biddingOrders.length}");
          print(
              "Image URLs in Orders: ${biddingOrders.map((e) => e.imageUrls).toList()}");
        } else {
          print("❌ 'data' key missing or invalid: ${decoded['data']}");
          setState(() {
            errorMessage = "Bidding orders data not found";
          });
          _showSnackBar("Bidding orders data not found");
        }
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        setState(() {
          errorMessage = "Failed to fetch bidding orders: ${res.statusCode}";
        });
        _showSnackBar("Failed to fetch bidding orders: ${res.statusCode}");
        if (res.statusCode == 401) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print("❌ API Exception: $e");
      setState(() {
        errorMessage = "Something went wrong: $e";
      });
      _showSnackBar("Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Color getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'cancelled':
  //       return Colors.red;
  //     case 'accepted':
  //       return Colors.green;
  //     case 'completed':
  //       return Colors.green;
  //     case 'review':
  //       return Colors.brown;
  //     case 'pending':
  //       return Colors.orange;
  //     default:
  //       return Colors.transparent;
  //   }
  // }

  Color _getStatusColor(String status) {
    print("🎨 Checking status color for: $status");
    switch (status.toLowerCase()) {
      case 'cancelled':
      case 'cancelleddispute':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'review':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBiddingOrders = biddingOrders;
      } else {
        filteredBiddingOrders = biddingOrders.where((item) {
          final title = item.title.toLowerCase();
          final desc = item.description.toLowerCase();
          return title.contains(query.toLowerCase()) ||
              desc.contains(query.toLowerCase());
        }).toList();
      }
      print('Filtered items: ${filteredBiddingOrders.length}');
    });
  }

  Widget buildNetworkImage(String? url,
      {required double width, required double height}) {
    print('Trying to load image: $url');
    return url != null &&
            url.isNotEmpty &&
            !url.contains('via.placeholder.com') &&
            url != 'https://via.placeholder.com/150'
        ? Image.network(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image load error: $error for URL: $url');
              return Image.asset(
                "assets/images/chair.png",
                width: width,
                height: height,
                fit: BoxFit.cover,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
          )
        : Image.asset(
            "assets/images/chair.png",
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    print('Building WorkerRecentPostedScreen');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: screenHeight * 0.02,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.03),
                              child: Icon(Icons.arrow_back,
                                  size: screenWidth * 0.06),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.13),
                          Text(
                            "Recent Posted Work",
                            style: GoogleFonts.roboto(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.13),
                          SvgPicture.asset(
                            'assets/svg_images/Vector1.svg',
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.010),
                      Card(
                        child: Container(
                          width: screenWidth * 0.95,
                          height: screenHeight * 0.07,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.010,
                              vertical: screenHeight * 0.015),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.025),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded,
                                  color: Colors.grey, size: screenWidth * 0.06),
                              SizedBox(width: screenWidth * 0.025),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search for services',
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenWidth * 0.04),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.0),
                      filteredBiddingOrders.isEmpty
                          ? Center(child: Text("No orders found"))
                          : Column(
                              children: filteredBiddingOrders
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                var index = entry.key;
                                var item = entry.value;
                                return Card(
                                  color: Colors.white,
                                  margin: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                      horizontal: screenWidth * 0.02),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.025),
                                    side: BorderSide(
                                      color: Colors.green,
                                      width: screenWidth * 0.0025,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.02),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.025),
                                          child: buildNetworkImage(
                                            item.imageUrls.isNotEmpty
                                                ? item.imageUrls[0]
                                                : null,
                                            width: screenWidth * 0.25,
                                            height: screenHeight * 0.15,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.025),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.045,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "₹${item.cost.toStringAsFixed(0)}",
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: screenHeight *
                                                              0.015),
                                                      child: Text(
                                                          item.description),
                                                    ),
                                                  ),
                                                  if (item
                                                      .hireStatus.isNotEmpty)
                                                    SizedBox(
                                                      width: screenWidth * 0.2,
                                                      height:
                                                          screenHeight * 0.04,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _getStatusColor(
                                                              item.hireStatus),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      screenWidth *
                                                                          0.02),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            item.hireStatus,
                                                            style: GoogleFonts.roboto(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.022,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Date: ${item.deadline.split('T')[0]}",
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.035),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      print(
                                                          'Navigating to details with orderId: ${item.id}, status: ${item.hireStatus}');
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Biddingserviceproviderworkdetail(
                                                            orderId: item.id,
                                                            hireStatus: item
                                                                .hireStatus, // Pass hireStatus
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: screenHeight *
                                                              0.01),
                                                      child: SizedBox(
                                                        width:
                                                            screenWidth * 0.2,
                                                        height:
                                                            screenHeight * 0.04,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .green.shade700,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    screenWidth *
                                                                        0.02),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              "View Details",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.03,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
    );
  }
}
