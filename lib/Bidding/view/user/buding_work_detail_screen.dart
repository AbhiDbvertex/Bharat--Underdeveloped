// import 'dart:convert';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:developer/Bidding/view/user/payment_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart'; // For formatting dates
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../Widgets/AppColors.dart';
// import '../../../directHiring/views/User/UserViewWorkerDetails.dart';
// import 'bidding_worker_detail_edit_screen.dart';
//
// class BiddingWorkerDetailScreen extends StatefulWidget {
//   final String? buddingOderId;
//
//   const BiddingWorkerDetailScreen({super.key, this.buddingOderId});
//
//   @override
//   State<BiddingWorkerDetailScreen> createState() =>
//       _BiddingWorkerDetailScreenState();
// }
//
// class _BiddingWorkerDetailScreenState extends State<BiddingWorkerDetailScreen> {
//   bool isBiddersClicked = false;
//   Map<String, dynamic>? getBuddingOderByIdResponseData;
//   List<dynamic> bidders = []; // Initialize with empty list
//   List<dynamic> relatedWorkers = []; // Initialize with empty list
//   bool isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> filteredBidders = []; // Initialize with empty list
//   List<dynamic> filteredRelatedWorkers = []; // Initialize with empty list
//
//   @override
//   void initState() {
//     super.initState();
//     getBuddingOderById();
//     getAllBidders();
//     _searchController.addListener(_filterLists);
//     _filterLists(); // Initialize filtered lists
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _filterLists() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         filteredBidders = List.from(bidders);
//         filteredRelatedWorkers = List.from(relatedWorkers);
//       } else {
//         filteredBidders = bidders.where((bidder) {
//           final fullName = bidder['full_name']?.toString().toLowerCase() ?? '';
//           final location = bidder['location']?.toString().toLowerCase() ?? '';
//           return fullName.contains(query) || location.contains(query);
//         }).toList();
//
//         filteredRelatedWorkers = relatedWorkers.where((worker) {
//           final fullName = worker['full_name']?.toString().toLowerCase() ?? '';
//           final location = worker['location']?.toString().toLowerCase() ?? '';
//           return fullName.contains(query) || location.contains(query);
//         }).toList();
//       }
//       print("Abhi:- Filtered Bidders: $filteredBidders");
//       print("Abhi:- Filtered Related Workers: $filteredRelatedWorkers");
//     });
//   }
//
//   Future<void> getBuddingOderById() async {
//     final String url = "https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.buddingOderId}";
//     print("Abhi:- getBuddingOderById url: $url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       var responseData = jsonDecode(response.body);
//       print("Abhi:- getBuddingOderById response: ${response.body}");
//       print("Abhi:- getBuddingOderById status: ${response.statusCode}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (responseData['status'] == true) {
//           final categoryId = responseData['data']?['category_id']?['_id'] ?? '';
//           final subCategoryIds =
//               (responseData['data']?['sub_category_ids'] as List<dynamic>?)
//                       ?.map((sub) => sub['_id'] as String)
//                       .toList() ??
//                   [];
//           if (categoryId.isNotEmpty &&
//               subCategoryIds.isNotEmpty &&
//               !isBiddersClicked) {
//             await getReletedWorker(categoryId, subCategoryIds);
//           }
//           setState(() {
//             getBuddingOderByIdResponseData = responseData;
//             isLoading = false;
//             _filterLists();
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//             _filterLists();
//           });
//           Get.snackbar(
//             "Error",
//             responseData['message'] ?? "Failed to fetch order details.",
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//           _filterLists();
//         });
//         Get.snackbar(
//           "Error",
//           responseData['message'] ?? "Failed to fetch order details.",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       print("Abhi:- getBuddingOderById Exception: $e");
//       setState(() {
//         isLoading = false;
//         _filterLists();
//       });
//       Get.snackbar(
//         "Error",
//         "Something went wrong!",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> getAllBidders() async {
//     final String url =
//         "https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders";
//     print("Abhi:- getAllBidders url: $url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       var responseData = jsonDecode(response.body);
//       print("Abhi:- getAllBidders response: ${response.body}");
//       print("Abhi:- getAllBidders status: ${response.statusCode}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (responseData['status'] == true) {
//           final orders = responseData['data'] as List<dynamic>?;
//           final matchingOrder = orders?.firstWhere(
//             (order) => order['_id'] == widget.buddingOderId,
//             orElse: () => null,
//           );
//           setState(() {
//             bidders = matchingOrder != null
//                 ? (matchingOrder['bidders'] as List<dynamic>?) ?? []
//                 : [];
//             filteredBidders = List.from(bidders);
//             isLoading = getBuddingOderByIdResponseData == null &&
//                 relatedWorkers.isEmpty;
//             print("Abhi:- Bidders: $bidders");
//           });
//         } else {
//           setState(() {
//             bidders = [];
//             filteredBidders = [];
//             isLoading = getBuddingOderByIdResponseData == null &&
//                 relatedWorkers.isEmpty;
//           });
//           Get.snackbar(
//             "Error",
//             responseData['message'] ?? "Failed to fetch bidders.",
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       } else {
//         setState(() {
//           bidders = [];
//           filteredBidders = [];
//           isLoading =
//               getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
//         });
//         Get.snackbar(
//           "Error",
//           responseData['message'] ?? "Failed to fetch bidders.",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       print("Abhi:- getAllBidders Exception: $e");
//       setState(() {
//         bidders = [];
//         filteredBidders = [];
//         isLoading =
//             getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
//       });
//       Get.snackbar(
//         "Error",
//         "Something went wrong!",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> getReletedWorker(
//       String categoryId, List<String> subCategoryIds) async {
//     final String url =
//         "https://api.thebharatworks.com/api/user/getServiceProviders";
//     print("Abhi:- getReletedWorker url: $url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           "category_id": categoryId,
//           "subcategory_ids": subCategoryIds,
//         }),
//       );
//
//       var responseData = jsonDecode(response.body);
//       print("Abhi:- getReletedWorker response: ${response.body}");
//       print("Abhi:- getReletedWorker status: ${response.statusCode}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (responseData['status'] == true) {
//           setState(() {
//             relatedWorkers = responseData['data'] as List<dynamic>? ?? [];
//             filteredRelatedWorkers = List.from(relatedWorkers);
//             isLoading =
//                 getBuddingOderByIdResponseData == null && bidders.isEmpty;
//             print("Abhi:- Related Workers: $relatedWorkers");
//           });
//         } else {
//           setState(() {
//             relatedWorkers = [];
//             filteredRelatedWorkers = [];
//             isLoading =
//                 getBuddingOderByIdResponseData == null && bidders.isEmpty;
//           });
//           Get.snackbar(
//             "Error",
//             responseData['message'] ?? "Failed to fetch related workers.",
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       } else {
//         setState(() {
//           relatedWorkers = [];
//           filteredRelatedWorkers = [];
//           isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
//         });
//         Get.snackbar(
//           "Error",
//           responseData['message'] ?? "Failed to fetch related workers.",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       print("Abhi:- getReletedWorker Exception: $e");
//       setState(() {
//         relatedWorkers = [];
//         filteredRelatedWorkers = [];
//         isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
//       });
//       Get.snackbar(
//         "Error",
//         "Something went wrong!",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> cancelTask() async {
//     final String url =
//         "https://api.thebharatworks.com/api/bidding-order/cancelBiddingOrder/${widget.buddingOderId}";
//     print("Abhi:- Cancel task url: $url");
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- Cancel task response ${response.body}");
//         print("Abhi:- Cancel task response ${response.statusCode}");
//         Navigator.pop(context, true);
//       } else {
//         print("Abhi:- Cancel task response else ${response.body}");
//         print("Abhi:- Cancel task response else ${response.statusCode}");
//         Get.snackbar(
//           "Error",
//           "Failed to cancel task.",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       print("Abhi:- Cancel task Exception: $e");
//       Get.snackbar(
//         "Error",
//         "Something went wrong!",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> inviteproviderId(String workerId) async {
//     final String url =
//         'https://api.thebharatworks.com/api/bidding-order/inviteServiceProviders';
//     print("Abhi:- inviteprovider api url : $url");
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "order_id": widget.buddingOderId,
//           "provider_ids": [workerId],
//         }),
//       );
//
//       var responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- Invideprovider response : ${response.body}");
//         Get.snackbar(
//           "Success",
//           responseData['message'],
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         print("Abhi:- else Invideprovider response : ${response.body}");
//         Get.snackbar(
//           "Error",
//           responseData['message'] ?? "Something went wrong",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       print("Abhi:- inviteprovider api Exception $e");
//       Get.snackbar(
//         "Error",
//         "Something went wrong!",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     print("Abhi:- buddingOderId is: ${widget.buddingOderId}");
//
//     final data = getBuddingOderByIdResponseData?['data'];
//     final title = data?['title'] ?? 'N/A';
//     final address = data?['address'] ?? 'N/A';
//     final description = data?['description'] ?? 'N/A';
//     final cost = data?['cost']?.toString() ?? '0';
//     final deadline = data?['deadline'] != null
//         ? DateFormat('dd/MM/yy').format(DateTime.parse(data['deadline']))
//         : 'N/A';
//     final imageUrls =
//         (data?['image_url'] as List<dynamic>?)?.cast<String>() ?? [];
//
//     return GestureDetector(
//         onTap: () {
//           FocusScope.of(context).requestFocus(FocusNode());
//         },
//         child: Scaffold(
//           backgroundColor: Colors.green.shade700,
//           body: SafeArea(
//             child: Container(
//               width: width,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//               ),
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               GestureDetector(
//                                 onTap: () => Navigator.pop(context),
//                                 child: const Padding(
//                                   padding: EdgeInsets.only(left: 15.0),
//                                   child:
//                                       Icon(Icons.arrow_back_outlined, size: 22),
//                                 ),
//                               ),
//                               const SizedBox(width: 90),
//                               Text(
//                                 'Worker details',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: height * 0.01),
//                           CarouselSlider(
//                             options: CarouselOptions(
//                               height: height * 0.25,
//                               enlargeCenterPage: true,
//                               autoPlay: imageUrls.isNotEmpty,
//                               viewportFraction: 0.85,
//                             ),
//                             items: imageUrls.isNotEmpty
//                                 ? imageUrls
//                                     .map((url) => Container(
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             image: DecorationImage(
//                                               image: NetworkImage(url.trim()),
//                                               fit: BoxFit.cover,
//                                               onError:
//                                                   (exception, stackTrace) =>
//                                                       Image.asset(
//                                                 'assets/images/Bid.png',
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                           ),
//                                         ))
//                                     .toList()
//                                 : [
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(20),
//                                         image: const DecorationImage(
//                                           image: AssetImage(
//                                               'assets/images/Bid.png'),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                           ),
//                           SizedBox(height: height * 0.015),
//                           Padding(
//                             padding:
//                                 EdgeInsets.symmetric(horizontal: width * 0.05),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   height: MediaQuery.of(context).size.height *
//                                       0.025,
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.28,
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.shade300,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       address.split(',').last.trim(),
//                                       style: GoogleFonts.roboto(
//                                         color: Colors.white,
//                                         fontSize:
//                                             MediaQuery.of(context).size.width *
//                                                 0.03,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: height * 0.005),
//                                 Text(
//                                   address,
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.black),
//                                 ),
//                                 SizedBox(height: height * 0.002),
//                                 Text(
//                                   "Complete - $deadline",
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey.shade500,
//                                   ),
//                                 ),
//                                 SizedBox(height: height * 0.002),
//                                 Text(
//                                   "Title - $title",
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: height * 0.005),
//                                 Text(
//                                   "₹$cost",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: height * 0.02),
//                           Padding(
//                             padding:
//                                 EdgeInsets.symmetric(horizontal: width * 0.05),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "Task Details",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 SizedBox(height: height * 0.01),
//                                 Column(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.circle, size: 6),
//                                         SizedBox(width: width * 0.02),
//                                         Expanded(
//                                           child: Text(
//                                             "Description: $description",
//                                             style:
//                                                 const TextStyle(fontSize: 14),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: height * 0.02),
//                           Padding(
//                             padding:
//                                 EdgeInsets.symmetric(horizontal: width * 0.05),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             PostTaskEditScreen(
//                                                 biddingOderId:
//                                                     widget.buddingOderId),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     height: height * 0.045,
//                                     width: width * 0.40,
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: Colors.green.shade700,
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Center(
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(Icons.edit,
//                                               color: AppColors.primaryGreen,
//                                               size: height * 0.024),
//                                           SizedBox(width: width * 0.03),
//                                           Text(
//                                             "Edit",
//                                             style: TextStyle(
//                                               color: Colors.green.shade700,
//                                               fontSize: width * 0.045,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 InkWell(
//                                   onTap: () async {
//                                     await cancelTask();
//                                     Get.back(result: true);
//                                   },
//                                   child: Container(
//                                     height: height * 0.045,
//                                     width: width * 0.40,
//                                     decoration: BoxDecoration(
//                                       color: Colors.red,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Center(
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           const Icon(
//                                               Icons.cancel_presentation_rounded,
//                                               color: Colors.white),
//                                           SizedBox(width: width * 0.02),
//                                           Text(
//                                             "Cancel Task",
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: width * 0.04,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: height * 0.02),
//                           Padding(
//                             padding:
//                                 EdgeInsets.symmetric(horizontal: width * 0.05),
//                             child: Container(
//                               height: height * 0.06,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade200,
//                                 borderRadius:
//                                     BorderRadius.circular(width * 0.03),
//                               ),
//                               child: TextField(
//                                 controller: _searchController,
//                                 decoration: InputDecoration(
//                                   hintText: "Search for services",
//                                   prefixIcon: const Icon(Icons.search),
//                                   suffixIcon: _searchController.text.isNotEmpty
//                                       ? IconButton(
//                                           icon: const Icon(Icons.clear),
//                                           onPressed: () {
//                                             _searchController.clear();
//                                             _filterLists();
//                                           },
//                                         )
//                                       : null,
//                                   border: InputBorder.none,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     vertical: height * 0.015,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: height * 0.015),
//                           Padding(
//                             padding:
//                                 EdgeInsets.symmetric(horizontal: width * 0.05),
//                             child: Column(
//                               children: [
//                                 SizedBox(height: height * 0.015),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           isBiddersClicked = true;
//                                           _filterLists();
//                                         });
//                                       },
//                                       child: Container(
//                                         height: height * 0.045,
//                                         width: width * 0.40,
//                                         decoration: BoxDecoration(
//                                           color: isBiddersClicked
//                                               ? Colors.green.shade700
//                                               : Colors.grey.shade300,
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: Center(
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               SizedBox(width: width * 0.02),
//                                               Text(
//                                                 "Bidders",
//                                                 style: TextStyle(
//                                                   color: isBiddersClicked
//                                                       ? Colors.white
//                                                       : Colors.grey.shade700,
//                                                   fontSize: width * 0.05,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           isBiddersClicked = false;
//                                           final categoryId =
//                                               getBuddingOderByIdResponseData?[
//                                                               'data']
//                                                           ?['category_id']
//                                                       ?['_id'] ??
//                                                   '';
//                                           final subCategoryIds =
//                                               (getBuddingOderByIdResponseData?[
//                                                                   'data']?[
//                                                               'sub_category_ids']
//                                                           as List<dynamic>?)
//                                                       ?.map((sub) =>
//                                                           sub['_id'] as String)
//                                                       .toList() ??
//                                                   [];
//                                           if (categoryId.isNotEmpty &&
//                                               subCategoryIds.isNotEmpty) {
//                                             getReletedWorker(
//                                                 categoryId, subCategoryIds);
//                                           }
//                                           _filterLists();
//                                         });
//                                       },
//                                       child: Container(
//                                         height: height * 0.045,
//                                         width: width * 0.40,
//                                         decoration: BoxDecoration(
//                                           color: !isBiddersClicked
//                                               ? Colors.green.shade700
//                                               : Colors.grey.shade300,
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: Center(
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               SizedBox(width: width * 0.02),
//                                               Text(
//                                                 "Related Worker",
//                                                 style: TextStyle(
//                                                   color: !isBiddersClicked
//                                                       ? Colors.white
//                                                       : Colors.grey.shade700,
//                                                   fontSize: width * 0.04,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 if (isBiddersClicked)
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.only(top: height * 0.01),
//                                     child: filteredBidders.isEmpty
//                                         ? Column(
//                                             children: [
//                                               Center(
//                                                 child: SvgPicture.asset(
//                                                   'assets/svg_images/nobidders.svg',
//                                                   height: height * 0.33,
//                                                 ),
//                                               ),
//                                               SizedBox(height: height * 0.023),
//                                               const Text(
//                                                 "No bidders found",
//                                                 style: TextStyle(
//                                                     color: Colors.grey),
//                                               ),
//                                             ],
//                                           )
//                                         : ListView.builder(
//                                             shrinkWrap: true,
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             itemCount: getBuddingOderByIdResponseData?.length,
//                                             itemBuilder: (context, index) {
//                                               final bidder =
//                                                   filteredBidders[index];
//                                               final fullName =
//                                                   bidder['full_name']
//                                                           ?.toString() ??
//                                                       'N/A';
//                                               final rating = bidder['rating']
//                                                       ?.toString() ??
//                                                   '0';
//                                               final bidderId = bidder['_id']
//                                                       ?.toString() ??
//                                                   '0';
//                                               final bidAmount =
//                                                   bidder['bid_amount']
//                                                           ?.toString() ??
//                                                       '0';
//                                               final location =
//                                                   bidder['location']
//                                                           ?.toString() ??
//                                                       'N/A';
//                                               final profilePic =
//                                                   bidder['profile_pic']
//                                                       ?.toString();
//                                               print("Abhi:- bidder id in bidder list : $bidderId");
//                                               return Container(
//                                                 margin: EdgeInsets.symmetric(
//                                                   vertical: height * 0.01,
//                                                   horizontal: width * 0.01,
//                                                 ),
//                                                 padding: EdgeInsets.all(
//                                                     width * 0.02),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.grey
//                                                           .withOpacity(0.2),
//                                                       spreadRadius: 1,
//                                                       blurRadius: 5,
//                                                       offset:
//                                                           const Offset(0, 3),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     ClipRRect(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               8),
//                                                       child: profilePic !=
//                                                                   null &&
//                                                               profilePic
//                                                                   .isNotEmpty
//                                                           ? Image.network(
//                                                               profilePic,
//                                                               height: 90,
//                                                               width: 90,
//                                                               fit: BoxFit.cover,
//                                                               errorBuilder: (context,
//                                                                       error,
//                                                                       stackTrace) =>
//                                                                   Image.asset(
//                                                                 'assets/images/account1.png',
//                                                                 height: 90,
//                                                                 width: 90,
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                               ),
//                                                             )
//                                                           : Image.asset(
//                                                               'assets/images/account1.png',
//                                                               height: 90,
//                                                               width: 90,
//                                                               fit: BoxFit.cover,
//                                                             ),
//                                                     ),
//                                                     SizedBox(
//                                                         width: width * 0.03),
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               Flexible(
//                                                                 child: Text(
//                                                                   fullName,
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         width *
//                                                                             0.045,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                   ),
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                   maxLines: 1,
//                                                                 ),
//                                                               ),
//                                                               Row(
//                                                                 children: [
//                                                                   Text(
//                                                                     rating,
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           width *
//                                                                               0.035,
//                                                                     ),
//                                                                   ),
//                                                                   Icon(
//                                                                     Icons.star,
//                                                                     size: width *
//                                                                         0.04,
//                                                                     color: Colors
//                                                                         .yellow
//                                                                         .shade700,
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment.spaceBetween,
//                                                             children: [
//                                                               Text(
//                                                                 "₹$bidAmount",
//                                                                 style: TextStyle(
//                                                                   fontSize: width * 0.04,
//                                                                   color: Colors.black,
//                                                                   fontWeight: FontWeight.bold,
//                                                                 ),
//                                                               ),
//                                                               CircleAvatar(
//                                                                 radius: 13,
//                                                                 backgroundColor:
//                                                                     Colors.grey.shade300,
//                                                                 child: Icon(
//                                                                   Icons.phone,
//                                                                   size: 18,
//                                                                   color: Colors.green.shade600,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           SizedBox(
//                                                               height: height *
//                                                                   0.005),
//                                                           Row(
//                                                             children: [
//                                                               Flexible(
//                                                                 child:
//                                                                     Container(
//                                                                   height: 22,
//                                                                   constraints:
//                                                                       BoxConstraints(
//                                                                     maxWidth:
//                                                                         width *
//                                                                             0.25,
//                                                                   ),
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     color: Colors
//                                                                         .red
//                                                                         .shade300,
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             10),
//                                                                   ),
//                                                                   child: Center(
//                                                                     child: Text(
//                                                                       location,
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontSize:
//                                                                             width *
//                                                                                 0.033,
//                                                                         color: Colors
//                                                                             .white,
//                                                                       ),
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                       maxLines:
//                                                                           1,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               SizedBox(
//                                                                   width: width *
//                                                                       0.03),
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .only(
//                                                                         top:
//                                                                             8.0),
//                                                                 child:
//                                                                     CircleAvatar(
//                                                                   radius: 13,
//                                                                   backgroundColor:
//                                                                       Colors
//                                                                           .grey
//                                                                           .shade300,
//                                                                   child: Icon(
//                                                                     Icons
//                                                                         .message,
//                                                                     size: 18,
//                                                                     color: Colors
//                                                                         .green
//                                                                         .shade600,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               TextButton(
//                                                                 onPressed: () {
//                                                                   // Get.snackbar(
//                                                                   //   "Info",
//                                                                   //   "View profile functionality not implemented yet.",
//                                                                   //   snackPosition:
//                                                                   //   SnackPosition.BOTTOM,
//                                                                   //   backgroundColor: Colors.black,
//                                                                   //   colorText: Colors.white,
//                                                                   //   margin: const EdgeInsets.all(10),
//                                                                   //   borderRadius: 10,
//                                                                   //   duration: const Duration(seconds: 3),
//                                                                   // );
//                                                                   Navigator.push(context, MaterialPageRoute(builder: (context)=> UserViewWorkerDetails(
//                                                                     workerId: bidderId ?? '',
//                                                                     // categreyId: widget.categreyId,
//                                                                     // subcategreyId:
//                                                                     // widget.subcategreyId,
//                                                                   ),));
//                                                                 },
//                                                                 style: TextButton
//                                                                     .styleFrom(
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .zero,
//                                                                   minimumSize:
//                                                                       const Size(
//                                                                           0,
//                                                                           25),
//                                                                   tapTargetSize:
//                                                                       MaterialTapTargetSize
//                                                                           .shrinkWrap,
//                                                                 ),
//                                                                 child: Text(
//                                                                   "View Profile",
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         width *
//                                                                             0.032,
//                                                                     color: Colors
//                                                                         .green
//                                                                         .shade700,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               Flexible(
//                                                                 child:
//                                                                     Container(
//                                                                   height: 32,
//                                                                   constraints:
//                                                                       BoxConstraints(
//                                                                     maxWidth:
//                                                                         width *
//                                                                             0.2,
//                                                                   ),
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     color: Colors
//                                                                         .green
//                                                                         .shade700,
//                                                                     borderRadius:
//                                                                         BorderRadius
//                                                                             .circular(8),
//                                                                   ),
//                                                                   child: Center(
//                                                                     child: Text(
//                                                                       "Accept",
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontSize:
//                                                                             width *
//                                                                                 0.032,
//                                                                         color: Colors
//                                                                             .white,
//                                                                       ),
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                       maxLines:
//                                                                           1,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                   ),
//                                 if (!isBiddersClicked)
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.only(top: height * 0.03),
//                                     child: filteredRelatedWorkers.isEmpty
//                                         ? Column(
//                                             children: [
//                                               Center(
//                                                 child: SvgPicture.asset(
//                                                   'assets/svg_images/norelatedworker.svg',
//                                                   height: height * 0.23,
//                                                 ),
//                                               ),
//                                               SizedBox(height: height * 0.023),
//                                               const Text(
//                                                 "No related worker",
//                                                 style: TextStyle(
//                                                     color: Colors.grey),
//                                               ),
//                                             ],
//                                           )
//                                         : ListView.builder(
//                                             shrinkWrap: true,
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             itemCount:
//                                                 filteredRelatedWorkers.length,
//                                             itemBuilder: (context, index) {
//                                               final worker =
//                                                   filteredRelatedWorkers[index];
//                                               final workerId =
//                                                   worker['_id']?.toString() ??
//                                                       'N/A';
//                                               final fullName =
//                                                   worker['full_name']
//                                                           ?.toString() ??
//                                                       'N/A';
//                                               final rating = worker['rating']
//                                                       ?.toString() ??
//                                                   '0';
//                                               final amount = worker['amount']
//                                                       ?.toString() ??
//                                                   '0';
//                                               final location =
//                                                   worker['location']?['address']
//                                                           ?.toString() ??
//                                                       'N/A';
//                                               final profilePic =
//                                                   worker['profile_pic']
//                                                       ?.toString();
//                                               print(
//                                                   "Abhi:- get bidding related workerId : $workerId");
//
//                                               return Container(
//                                                 margin: EdgeInsets.symmetric(
//                                                   vertical: height * 0.01,
//                                                   horizontal: width * 0.01,
//                                                 ),
//                                                 padding: EdgeInsets.all(
//                                                     width * 0.02),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.grey
//                                                           .withOpacity(0.2),
//                                                       spreadRadius: 1,
//                                                       blurRadius: 5,
//                                                       offset:
//                                                           const Offset(0, 3),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     ClipRRect(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               8),
//                                                       child: profilePic !=
//                                                                   null &&
//                                                               profilePic
//                                                                   .isNotEmpty
//                                                           ? Image.network(
//                                                               profilePic,
//                                                               height: 90,
//                                                               width: 90,
//                                                               fit: BoxFit.cover,
//                                                               errorBuilder: (context,
//                                                                       error,
//                                                                       stackTrace) =>
//                                                                   Image.asset(
//                                                                 'assets/images/account1.png',
//                                                                 height: 90,
//                                                                 width: 90,
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                               ),
//                                                             )
//                                                           : Image.asset(
//                                                               'assets/images/account1.png',
//                                                               height: 90,
//                                                               width: 90,
//                                                               fit: BoxFit.cover,
//                                                             ),
//                                                     ),
//                                                     SizedBox(
//                                                         width: width * 0.03),
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               Flexible(
//                                                                 child: Text(
//                                                                   fullName,
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         width *
//                                                                             0.045,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                   ),
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                   maxLines: 1,
//                                                                 ),
//                                                               ),
//                                                               Row(
//                                                                 children: [
//                                                                   Text(
//                                                                     rating,
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           width *
//                                                                               0.035,
//                                                                     ),
//                                                                   ),
//                                                                   Icon(
//                                                                     Icons.star,
//                                                                     size: width *
//                                                                         0.04,
//                                                                     color: Colors
//                                                                         .yellow
//                                                                         .shade700,
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               Text(
//                                                                 "₹$amount",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.04,
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                               ),
//                                                               CircleAvatar(
//                                                                 radius: 13,
//                                                                 backgroundColor:
//                                                                     Colors.grey
//                                                                         .shade300,
//                                                                 child: Icon(
//                                                                   Icons.phone,
//                                                                   size: 18,
//                                                                   color: Colors
//                                                                       .green
//                                                                       .shade600,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           SizedBox(
//                                                               height: height *
//                                                                   0.005),
//                                                           Row(
//                                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                             children: [
//                                                               Flexible(
//                                                                 child: Container(height: 22,
//                                                                   constraints: BoxConstraints(
//                                                                         maxWidth: width * 0.27,
//                                                                   ),
//                                                                   decoration: BoxDecoration(
//                                                                     color: Colors.red.shade300,
//                                                                     borderRadius: BorderRadius.circular(10),
//                                                                   ),
//                                                                   child: Center(
//                                                                     child: Padding(
//                                                                       padding: const EdgeInsets.only(left: 4.0),
//                                                                       child: Text(
//                                                                         location,
//                                                                         style:
//                                                                             TextStyle(
//                                                                           fontSize: width * 0.033,
//                                                                           color: Colors.white,
//                                                                         ),
//                                                                         overflow: TextOverflow.ellipsis,
//                                                                         maxLines: 1,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               SizedBox(
//                                                                   width: width * 0.03),
//                                                               Padding(
//                                                                 padding: const EdgeInsets.only(top: 8.0),
//                                                                 child:
//                                                                     CircleAvatar(
//                                                                   radius: 13,
//                                                                   backgroundColor:
//                                                                       Colors.grey.shade300,
//                                                                   child: Icon(
//                                                                     Icons.message,
//                                                                     size: 18,
//                                                                     color: Colors.green.shade600,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               TextButton(
//                                                                 onPressed: () {
//                                                                   // Get.snackbar(
//                                                                   //   "Info",
//                                                                   //   "View profile functionality not implemented yet.",
//                                                                   //   snackPosition: SnackPosition.BOTTOM,
//                                                                   //   backgroundColor: Colors.black,
//                                                                   //   colorText: Colors.white,
//                                                                   //   margin: const EdgeInsets.all(10),
//                                                                   //   borderRadius: 10,
//                                                                   //   duration: const Duration(seconds: 3),
//                                                                   // );
//                                                                   Navigator.push(context, MaterialPageRoute(builder: (context)=> UserViewWorkerDetails(
//                                                                     workerId: workerId ?? '',
//                                                                     // categreyId: widget.categreyId,
//                                                                     // subcategreyId:
//                                                                     // widget.subcategreyId,
//                                                                   ),));
//                                                                 },
//                                                                 style: TextButton
//                                                                     .styleFrom(
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .zero,
//                                                                   minimumSize:
//                                                                       const Size(
//                                                                           0,
//                                                                           25),
//                                                                   tapTargetSize:
//                                                                       MaterialTapTargetSize
//                                                                           .shrinkWrap,
//                                                                 ),
//                                                                 child: Text(
//                                                                   "View Profile",
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         width *
//                                                                             0.032,
//                                                                     color: Colors
//                                                                         .green
//                                                                         .shade700,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               Flexible(
//                                                                 child: InkWell(
//                                                                   onTap: () {
//                                                                     inviteproviderId(
//                                                                         workerId);
//                                                                     print(
//                                                                         "Abhi:- tab on invite print workerId : $workerId");
//                                                                   },
//                                                                   child:
//                                                                       Container(
//                                                                     height: 32,
//                                                                     constraints:
//                                                                         BoxConstraints(
//                                                                       maxWidth:
//                                                                           width *
//                                                                               0.2,
//                                                                     ),
//                                                                     decoration:
//                                                                         BoxDecoration(
//                                                                       color: Colors
//                                                                           .green
//                                                                           .shade700,
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               8),
//                                                                     ),
//                                                                     child:
//                                                                         Center(
//                                                                       child:
//                                                                           Text(
//                                                                         "Invite",
//                                                                         style:
//                                                                             TextStyle(
//                                                                           fontSize:
//                                                                               width * 0.032,
//                                                                           color:
//                                                                               Colors.white,
//                                                                         ),
//                                                                         overflow:
//                                                                             TextOverflow.ellipsis,
//                                                                         maxLines:
//                                                                             1,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                   ),
//                                 SizedBox(height: height * 0.02),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: height * 0.04),
//                           BiddingPaymentScreen(
//                               orderId: widget.buddingOderId ?? ""),
//                         ],
//                       ),
//                     ),
//             ),
//           ),
//         ));
//   }
// }

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Bidding/view/user/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Widgets/AppColors.dart';
import '../../../directHiring/views/User/UserViewWorkerDetails.dart';
import 'bidding_worker_detail_edit_screen.dart';

class BiddingWorkerDetailScreen extends StatefulWidget {
  final String? buddingOderId;
  final userId;

  const BiddingWorkerDetailScreen({super.key, this.buddingOderId, this.userId});

  @override
  State<BiddingWorkerDetailScreen> createState() =>
      _BiddingWorkerDetailScreenState();
}

class _BiddingWorkerDetailScreenState extends State<BiddingWorkerDetailScreen> {
  bool isBiddersClicked = false;
  Map<String, dynamic>? getBuddingOderByIdResponseData;
  List<dynamic> bidders = [];
  List<dynamic> relatedWorkers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredBidders = [];
  List<dynamic> filteredRelatedWorkers = [];
  List<dynamic>? getBuddingOderByIdResponseDatalist;
  @override
  void initState() {
    super.initState();
    getBuddingOderById();
    getAllBidders();
    _searchController.addListener(_filterLists);
    _filterLists();
    fetchBiddingOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredBidders = List.from(bidders);
        filteredRelatedWorkers = List.from(relatedWorkers);
      } else {
        filteredBidders = bidders.where((bidder) {
          final fullName = bidder['full_name']?.toString().toLowerCase() ?? '';
          final location = bidder['location']?.toString().toLowerCase() ?? '';
          return fullName.contains(query) || location.contains(query);
        }).toList();

        filteredRelatedWorkers = relatedWorkers.where((worker) {
          final fullName = worker['full_name']?.toString().toLowerCase() ?? '';
          final location = worker['location']?.toString().toLowerCase() ?? '';
          return fullName.contains(query) || location.contains(query);
        }).toList();
      }
      print("Abhi:- Filtered Bidders: $filteredBidders");
      print("Abhi:- Filtered Related Workers: $filteredRelatedWorkers");
    });
  }

  //     abhishek add new api code
  Future<void> fetchBiddingOffers() async {
    final String apiUrl =
        "https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.buddingOderId}";

    // final response = await http.get(Uri.parse(apiUrl));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print("Abhi:- getBuddingOderById response: ${response.body}");
        print("Abhi:- getBuddingOderById status: ${response.statusCode}");
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            getBuddingOderByIdResponseDatalist = data['data'];
          });
        } else {
          print("Abhi:- getBuddingOderById response: ${response.body}");
          print("Abhi:- getBuddingOderById status: ${response.statusCode}");
          print("API Error: ${data['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> getBuddingOderById() async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.buddingOderId}";
        // "https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.buddingOderId}";
    print("Abhi:- getBuddingOderById url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);
      print("Abhi:- getBuddingOderById response: ${response.body}");
      print("Abhi:- getBuddingOderById status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          final categoryId = responseData['data']?['category_id']?['_id'] ?? '';
          final subCategoryIds =
              (responseData['data']?['sub_category_ids'] as List<dynamic>?)
                  ?.map((sub) => sub['_id'] as String)
                  .toList() ??
                  [];
          if (categoryId.isNotEmpty &&
              subCategoryIds.isNotEmpty &&
              !isBiddersClicked) {
            await getReletedWorker(categoryId, subCategoryIds);
          }
          setState(() {
            getBuddingOderByIdResponseData = responseData;
            isLoading = false;
            _filterLists();
          });
        } else {
          setState(() {
            isLoading = false;
            _filterLists();
          });
          Get.snackbar(
            "Error",
            responseData['message'] ?? "Failed to fetch order details.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          isLoading = false;
          _filterLists();
        });
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to fetch order details.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- getBuddingOderById Exception: $e");
      setState(() {
        isLoading = false;
        _filterLists();
      });
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getAllBidders() async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders";
    print("Abhi:- getAllBidders url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);
      print("Abhi:- getAllBidders response: ${response.body}");
      print("Abhi:- getAllBidders status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          final orders = responseData['data'] as List<dynamic>?;
          final matchingOrder = orders?.firstWhere(
                (order) => order['_id'] == widget.buddingOderId,
            orElse: () => null,
          );
          setState(() {
            bidders = matchingOrder != null
                ? (matchingOrder['bidders'] as List<dynamic>?) ?? []
                : [];
            filteredBidders = List.from(bidders);
            isLoading = getBuddingOderByIdResponseData == null &&
                relatedWorkers.isEmpty;
            print("Abhi:- Bidders: $bidders");
          });
        } else {
          setState(() {
            bidders = [];
            filteredBidders = [];
            isLoading = getBuddingOderByIdResponseData == null &&
                relatedWorkers.isEmpty;
          });
          Get.snackbar(
            "Error",
            responseData['message'] ?? "Failed to fetch bidders.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          bidders = [];
          filteredBidders = [];
          isLoading =
              getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
        });
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to fetch bidders.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- getAllBidders Exception: $e");
      setState(() {
        bidders = [];
        filteredBidders = [];
        isLoading =
            getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
      });
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getReletedWorker(
      String categoryId, List<String> subCategoryIds) async {
    final String url =
        "https://api.thebharatworks.com/api/user/getServiceProviders";
    print("Abhi:- getReletedWorker url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "category_id": categoryId,
          "subcategory_ids": subCategoryIds,
        }),
      );

      var responseData = jsonDecode(response.body);
      print("Abhi:- getReletedWorker response: ${response.body}");
      print("Abhi:- getReletedWorker status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          setState(() {
            relatedWorkers = responseData['data'] as List<dynamic>? ?? [];
            filteredRelatedWorkers = List.from(relatedWorkers);
            isLoading =
                getBuddingOderByIdResponseData == null && bidders.isEmpty;
            print("Abhi:- Related Workers: $relatedWorkers");
          });
        } else {
          setState(() {
            relatedWorkers = [];
            filteredRelatedWorkers = [];
            isLoading =
                getBuddingOderByIdResponseData == null && bidders.isEmpty;
          });
          Get.snackbar(
            "Error",
            responseData['message'] ?? "Failed to fetch related workers.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          relatedWorkers = [];
          filteredRelatedWorkers = [];
          isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
        });
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to fetch related workers.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- getReletedWorker Exception: $e");
      setState(() {
        relatedWorkers = [];
        filteredRelatedWorkers = [];
        isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
      });
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> cancelTask() async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/cancelBiddingOrder/${widget.buddingOderId}";
    print("Abhi:- Cancel task url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- Cancel task response ${response.body}");
        print("Abhi:- Cancel task response ${response.statusCode}");
        Navigator.pop(context, true);
      } else {
        print("Abhi:- Cancel task response else ${response.body}");
        print("Abhi:- Cancel task response else ${response.statusCode}");
        Get.snackbar(
          "Error",
          "Failed to cancel task.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- Cancel task Exception: $e");
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> inviteproviderId(String workerId) async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/inviteServiceProviders';
    print("Abhi:- inviteprovider api url : $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": widget.buddingOderId,
          "provider_ids": [workerId],
        }),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- Invideprovider response : ${response.body}");
        Get.snackbar(
          "Success",
          responseData['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Abhi:- else Invideprovider response : ${response.body}");
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Something went wrong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- inviteprovider api Exception $e");
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> acceptBid(String bidderId, String bidAmount) async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/acceptBid';
    print("Abhi:- acceptBid api url : $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": widget.buddingOderId,
          "bidder_id": bidderId,
          "bid_amount": bidAmount,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- acceptBid response : ${response.body}");
        Get.snackbar(
          "Success",
          responseData['message'] ?? "Bid accepted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh bidders list after accepting a bid
        await getAllBidders();
      } else {
        print("Abhi:- else acceptBid response : ${response.body}");
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to accept bid",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- acceptBid api Exception $e");
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print("Abhi:- buddingOderId is: ${widget.buddingOderId}");

    final data = getBuddingOderByIdResponseData?['data'];
    final title = data?['title'] ?? 'N/A';
    final address = data?['address'] ?? 'N/A';
    final description = data?['description'] ?? 'N/A';
    final cost = data?['cost']?.toString() ?? '0';
    final deadline = data?['deadline'] != null
        ? DateFormat('dd/MM/yy').format(DateTime.parse(data['deadline']))
        : 'N/A';
    final imageUrls =
        (data?['image_url'] as List<dynamic>?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.green.shade700,
        body: SafeArea(
          child: Container(
            width: width,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child:
                          Icon(Icons.arrow_back_outlined, size: 22),
                        ),
                      ),
                      const SizedBox(width: 90),
                      Text(
                        'Worker details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: height * 0.25,
                      enlargeCenterPage: true,
                      autoPlay: imageUrls.isNotEmpty,
                      viewportFraction: 0.85,
                    ),
                    items: imageUrls.isNotEmpty
                        ? imageUrls
                        .map((url) => Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(url.trim()),
                          fit: BoxFit.cover,
                          onError:
                              (exception, stackTrace) =>
                              Image.asset(
                                'assets/images/Bid.png',
                                fit: BoxFit.cover,
                              ),
                        ),
                      ),
                    ))
                        .toList()
                        : [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image:
                            AssetImage('assets/images/Bid.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.025,
                          width: MediaQuery.of(context).size.width * 0.28,
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              address.split(',').last.trim(),
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize:
                                MediaQuery.of(context).size.width *
                                    0.03,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.005),
                        Text(
                          address,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        SizedBox(height: height * 0.002),
                        Text(
                          "Complete - $deadline",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: height * 0.002),
                        Text(
                          "Title - $title",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.005),
                        Text(
                          "₹$cost",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Task Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, size: 6),
                                SizedBox(width: width * 0.02),
                                Expanded(
                                  child: Text(
                                    "Description: $description",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostTaskEditScreen(
                                        biddingOderId:
                                        widget.buddingOderId),
                              ),
                            );
                          },
                          child: Container(
                            height: height * 0.045,
                            width: width * 0.40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green.shade700,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit,
                                      color: AppColors.primaryGreen,
                                      size: height * 0.024),
                                  SizedBox(width: width * 0.03),
                                  Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await cancelTask();
                            Get.back(result: true);
                          },
                          child: Container(
                            height: height * 0.045,
                            width: width * 0.40,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.cancel_presentation_rounded,
                                      color: Colors.white),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    "Cancel Task",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w600,
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
                  SizedBox(height: height * 0.02),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Container(
                      height: height * 0.06,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search for services",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterLists();
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.015,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.015),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isBiddersClicked = true;
                                  _filterLists();
                                });
                              },
                              child: Container(
                                height: height * 0.045,
                                width: width * 0.40,
                                decoration: BoxDecoration(
                                  color: isBiddersClicked
                                      ? Colors.green.shade700
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: width * 0.02),
                                      Text(
                                        "Bidders",
                                        style: TextStyle(
                                          color: isBiddersClicked
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          fontSize: width * 0.05,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isBiddersClicked = false;
                                  final categoryId =
                                      getBuddingOderByIdResponseData?[
                                      'data']
                                      ?['category_id']
                                      ?['_id'] ??
                                          '';
                                  final subCategoryIds =
                                      (getBuddingOderByIdResponseData?[
                                      'data']
                                      ?['sub_category_ids']
                                      as List<dynamic>?)?.map((sub) =>
                                      sub['_id'] as String).toList() ??
                                          [];
                                  if (categoryId.isNotEmpty &&
                                      subCategoryIds.isNotEmpty) {
                                    getReletedWorker(
                                        categoryId, subCategoryIds);
                                  }
                                  _filterLists();
                                });
                              },
                              child: Container(
                                height: height * 0.045,
                                width: width * 0.40,
                                decoration: BoxDecoration(
                                  color: !isBiddersClicked
                                      ? Colors.green.shade700
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: width * 0.02),
                                      Text(
                                        "Related Worker",
                                        style: TextStyle(
                                          color: !isBiddersClicked
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isBiddersClicked)
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.01),
                            child: getBuddingOderByIdResponseDatalist!.isEmpty
                                ? Column(
                              children: [
                                Center(
                                  child: SvgPicture.asset(
                                    'assets/svg_images/nobidders.svg',
                                    height: height * 0.33,
                                  ),
                                ),
                                SizedBox(height: height * 0.023),
                                const Text(
                                  "No bidders found",
                                  style:
                                  TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: getBuddingOderByIdResponseDatalist?.length ?? 0,
                              itemBuilder: (context, index) {
                                final bidder = getBuddingOderByIdResponseDatalist?[index];
                                final fullName = bidder?['provider_id']['full_name']?.toString() ?? 'N/A';
                                final rating = bidder?['provider_id']['rating']?.toString() ?? '0';
                                final bidderId = bidder?['provider_id']?['_id']?.toString() ?? '';
                                final biddingofferId = bidder?['_id']?.toString() ?? '';
                                final  OderId = bidder?['order_id']?.toString() ?? '';
                                final bidAmount = bidder?['bid_amount']?.toString() ?? '0';
                                final location = bidder?['provider_id']['location']['address']?.toString() ?? 'N/A';
                                final profilePic = bidder?['provider_id']['profile_pic']?.toString();

                                print("Abhi:- bidder id in bidder list : $bidderId");

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: height * 0.01,
                                    horizontal: width * 0.01,
                                  ),
                                  padding: EdgeInsets.all(width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: profilePic != null && profilePic.isNotEmpty
                                            ? Image.network(
                                          profilePic,
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/images/account1.png',
                                            height: 90,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Image.asset(
                                          'assets/images/account1.png',
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    fullName,
                                                    style: TextStyle(
                                                      fontSize: width * 0.045,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      rating,
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      size: width * 0.04,
                                                      color: Colors.yellow.shade700,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "₹$bidAmount",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor: Colors.grey.shade300,
                                                  child: Icon(
                                                    Icons.phone,
                                                    size: 18,
                                                    color: Colors.green.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: height * 0.005),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    height: 22,
                                                    constraints: BoxConstraints(
                                                      maxWidth: width * 0.25,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade300,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        location,
                                                        style: TextStyle(
                                                          fontSize: width * 0.033,
                                                          color: Colors.white,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.03),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor: Colors.grey.shade300,
                                                    child: Icon(
                                                      Icons.message,
                                                      size: 18,
                                                      color: Colors.green.shade600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => UserViewWorkerDetails(
                                                          workerId: bidderId,
                                                          hirebuttonhide: "hide",
                                                          UserId: widget.userId,
                                                          oderId: OderId,
                                                          biddingOfferId: biddingofferId,
                                                        ),
                                                        // UserViewWorkerDetails(
                                                        //   workerId: '68ac07f700315e754a037e56',
                                                        // ),
                                                      ),
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: const Size(0, 25),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  child: Text(
                                                    "View Profile",
                                                    style: TextStyle(
                                                      fontSize: width * 0.032,
                                                      color: Colors.green.shade700,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: InkWell(
                                                    onTap: () {
                                                      acceptBid(bidderId, bidAmount);
                                                    },
                                                    child: Container(
                                                      height: 32,
                                                      constraints: BoxConstraints(
                                                        maxWidth: width * 0.2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade700,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Accept",
                                                          style: TextStyle(
                                                            fontSize: width * 0.032,
                                                            color: Colors.white,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ),
                        if (!isBiddersClicked)
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.03),
                            child: filteredRelatedWorkers.isEmpty
                                ? Column(
                              children: [
                                Center(
                                  child: SvgPicture.asset(
                                    'assets/svg_images/norelatedworker.svg',
                                    height: height * 0.23,
                                  ),
                                ),
                                SizedBox(height: height * 0.023),
                                const Text(
                                  "No related worker",
                                  style:
                                  TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              itemCount:
                              filteredRelatedWorkers.length,
                              itemBuilder: (context, index) {
                                final worker =
                                filteredRelatedWorkers[index];
                                final workerId =
                                    worker['_id']?.toString() ??
                                        'N/A';
                                final fullName =
                                    worker['full_name']
                                        ?.toString() ??
                                        'N/A';
                                final rating = worker['rating']
                                    ?.toString() ??
                                    '0';
                                final amount = worker['amount']
                                    ?.toString() ??
                                    '0';
                                final location =
                                    worker['location']?['address']
                                        ?.toString() ??
                                        'N/A';
                                final profilePic =
                                worker['profile_pic']
                                    ?.toString();
                                print(
                                    "Abhi:- get bidding related workerId : $workerId");

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: height * 0.01,
                                    horizontal: width * 0.01,
                                  ),
                                  padding:
                                  EdgeInsets.all(width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey
                                            .withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        child: profilePic != null &&
                                            profilePic.isNotEmpty
                                            ? Image.network(
                                          profilePic,
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context,
                                              error,
                                              stackTrace) =>
                                              Image.asset(
                                                'assets/images/account1.png',
                                                height: 90,
                                                width: 90,
                                                fit: BoxFit.cover,
                                              ),
                                        )
                                            : Image.asset(
                                          'assets/images/account1.png',
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    fullName,
                                                    style: TextStyle(
                                                      fontSize:
                                                      width *
                                                          0.045,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                    ),
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      rating,
                                                      style:
                                                      TextStyle(
                                                        fontSize:
                                                        width *
                                                            0.035,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      size: width *
                                                          0.04,
                                                      color: Colors
                                                          .yellow
                                                          .shade700,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  "₹$amount",
                                                  style: TextStyle(
                                                    fontSize:
                                                    width * 0.04,
                                                    color:
                                                    Colors.black,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                  ),
                                                ),
                                                CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                  Colors.grey
                                                      .shade300,
                                                  child: Icon(
                                                    Icons.phone,
                                                    size: 18,
                                                    color: Colors
                                                        .green
                                                        .shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                height * 0.005),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    height: 22,
                                                    constraints:
                                                    BoxConstraints(
                                                      maxWidth:
                                                      width *
                                                          0.27,
                                                    ),
                                                    decoration:
                                                    BoxDecoration(
                                                      color: Colors
                                                          .red
                                                          .shade300,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10),
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            left:
                                                            4.0),
                                                        child: Text(
                                                          location,
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            width *
                                                                0.033,
                                                            color: Colors
                                                                .white,
                                                          ),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          maxLines:
                                                          1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                    width * 0.03),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      top: 8.0),
                                                  child: CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor:
                                                    Colors.grey
                                                        .shade300,
                                                    child: Icon(
                                                      Icons.message,
                                                      size: 18,
                                                      color: Colors
                                                          .green
                                                          .shade600,
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
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                            UserViewWorkerDetails(
                                                              workerId: workerId,
                                                              hirebuttonhide: "hide",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  style: TextButton
                                                      .styleFrom(
                                                    padding:
                                                    EdgeInsets
                                                        .zero,
                                                    minimumSize:
                                                    const Size(
                                                        0, 25),
                                                    tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                  ),
                                                  child: Text(
                                                    "View Profile",
                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      width *
                                                          0.032,
                                                      color: Colors
                                                          .green
                                                          .shade700,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: InkWell(
                                                    onTap: () {
                                                      inviteproviderId(
                                                          workerId);
                                                      print(
                                                          "Abhi:- tab on invite print workerId : $workerId");
                                                    },
                                                    child: Container(
                                                      height: 32,
                                                      constraints:
                                                      BoxConstraints(
                                                        maxWidth:
                                                        width *
                                                            0.2,
                                                      ),
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Colors
                                                            .green
                                                            .shade700,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            8),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Invite",
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            width *
                                                                0.032,
                                                            color: Colors
                                                                .white,
                                                          ),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          maxLines:
                                                          1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  BiddingPaymentScreen(orderId: widget.buddingOderId ?? ""),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}