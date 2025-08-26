// import 'dart:convert';
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
// import '../Models/bidding_order.dart'; // BiddingOrder model imported
//
// class Biddingserviceproviderworkdetail extends StatefulWidget {
//   final String orderId;
//
//   const Biddingserviceproviderworkdetail({Key? key, required this.orderId})
//       : super(key: key);
//
//   @override
//   _BiddingserviceproviderworkdetailState createState() =>
//       _BiddingserviceproviderworkdetailState();
// }
//
// class _BiddingserviceproviderworkdetailState
//     extends State<Biddingserviceproviderworkdetail> {
//   int _selectedIndex = 0; // 0 for Bidders, 1 for Related Worker
//   List<Map<String, dynamic>> bidders = []; // Dynamic bidders list
//   List<Map<String, dynamic>> relatedWorkers =
//       []; // Empty initially, filled by API
//   BiddingOrder? biddingOrder;
//   bool isLoading = true;
//   String errorMessage = '';
//   String? currentUserId; // To store current user ID
//   bool hasAlreadyBid = false; // To track if user has already bid
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch bidding order first, then related workers
//     fetchBiddingOrder().then((_) {
//       if (biddingOrder != null && biddingOrder!.categoryId.isNotEmpty) {
//         print('✅ Bidding Order Ready: ${biddingOrder!.title}');
//         print('✅ Category ID: ${biddingOrder!.categoryId}');
//         print('✅ Subcategory IDs: ${biddingOrder!.subcategoryIds}');
//         fetchRelatedWorkers(); // Call only if biddingOrder is valid
//       } else {
//         setState(() {
//           errorMessage = 'Bidding order details ya category ID nahi mila.';
//           isLoading = false;
//         });
//         print('❌ Bidding order ya category ID invalid hai');
//       }
//       fetchBidders();
//       fetchCurrentUserId();
//     });
//   }
//
//   // Fetch current user ID from token
//   Future<void> fetchCurrentUserId() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) return;
//
//       final parts = token.split('.');
//       if (parts.length != 3) return;
//       final payload = jsonDecode(String.fromCharCodes(
//           base64Url.decode(base64Url.normalize(parts[1]))));
//       setState(() {
//         currentUserId = payload['id']?.toString();
//       });
//       print('👤 Current User ID: $currentUserId');
//     } catch (e) {
//       print('❌ Error fetching user ID: $e');
//     }
//   }
//
//   // Fetch single bidding order details
//   Future<void> fetchBiddingOrder() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         setState(() {
//           errorMessage = 'No token found. Please log in again.';
//           isLoading = false;
//         });
//         print('❌ No token found in SharedPreferences');
//         return;
//       }
//       print('🔐 Token: $token');
//
//       final response = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.orderId}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('📥 Response Status: ${response.statusCode}');
//       print('📥 Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           setState(() {
//             biddingOrder = BiddingOrder.fromJson(jsonData['data']);
//             isLoading = false;
//           });
//           print('✅ Bidding Order: ${biddingOrder!.title}');
//           print('✅ Image URLs: ${biddingOrder!.imageUrls}');
//           print('👤 Order Owner ID: ${biddingOrder!.userId}');
//         } else {
//           setState(() {
//             errorMessage = jsonData['message'] ?? 'Failed to fetch data';
//             isLoading = false;
//           });
//         }
//       } else if (response.statusCode == 401) {
//         setState(() {
//           errorMessage = 'Unauthorized: Please log in again.';
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Error: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('❌ API Error: $e');
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   // Fetch bidding offers for bidders tab
//   Future<void> fetchBidders() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         setState(() {
//           errorMessage = 'No token found. Please log in again.';
//           isLoading = false;
//         });
//         print('❌ No token found in SharedPreferences');
//         return;
//       }
//       print('🔐 Token: $token');
//
//       final response = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.orderId}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('📥 Bidders Response Status: ${response.statusCode}');
//       print('📥 Bidders Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           List<dynamic> offers = jsonData['data'];
//           setState(() {
//             bidders = offers.map((offer) {
//               return {
//                 'name': offer['provider_id']['full_name'] ?? 'Unknown',
//                 'amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
//                 'location': 'Unknown Location',
//                 'rating': (offer['provider_id']['rating'] ?? 0).toDouble(),
//                 'status': offer['status'] ?? 'pending',
//                 'viewed': false,
//               };
//             }).toList();
//             isLoading = false;
//           });
//           print('✅ Bidders fetched: ${bidders.length}');
//         } else {
//           setState(() {
//             errorMessage = jsonData['message'] ?? 'Failed to fetch bidders';
//             isLoading = false;
//           });
//         }
//       } else if (response.statusCode == 401) {
//         setState(() {
//           errorMessage = 'Unauthorized: Please log in again.';
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Error: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('❌ Bidders API Error: $e');
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   // Fetch related workers (service providers) from API
//   Future<void> fetchRelatedWorkers() async {
//     try {
//       if (biddingOrder == null || biddingOrder!.categoryId.isEmpty) {
//         setState(() {
//           errorMessage = 'Order details ya category ID nahi mila.';
//           isLoading = false;
//         });
//         print('❌ Bidding order ya category ID nahi hai');
//         return;
//       }
//
//       if (biddingOrder!.subcategoryIds.isEmpty) {
//         print(
//             '⚠️ Subcategory IDs empty hain, API ke behavior ke hisaab se check karo');
//       }
//
//       setState(() {
//         isLoading = true;
//       });
//
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         setState(() {
//           errorMessage = 'Koi token nahi mila. Phir se login karo.';
//           isLoading = false;
//         });
//         print('❌ Token nahi mila SharedPreferences mein');
//         return;
//       }
//       print('🔐 Token: $token');
//
//       final payload = {
//         'category_id': biddingOrder!.categoryId,
//         'subcategory_ids': biddingOrder!.subcategoryIds,
//       };
//
//       print('📤 Payload bheja ja raha: ${jsonEncode(payload)}');
//
//       final response = await http.post(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/user/getServiceProviders'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📥 Related Workers Response Status: ${response.statusCode}');
//       print('📥 Related Workers Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           List<dynamic> providers = jsonData['data'];
//           setState(() {
//             relatedWorkers = providers.map((provider) {
//               return {
//                 'name': provider['full_name'] ?? 'Unknown',
//                 'amount':
//                     '₹${biddingOrder?.cost.toStringAsFixed(2) ?? '1500.00'}',
//                 'location':
//                     provider['location']['address'] ?? 'Unknown Location',
//                 'rating': (provider['rateAndReviews']?.isNotEmpty ?? false)
//                     ? provider['rateAndReviews']
//                             .map((review) => review['rating'])
//                             .reduce((a, b) => a + b) /
//                         provider['rateAndReviews'].length
//                     : 0.0,
//                 'viewed': false,
//               };
//             }).toList();
//             isLoading = false;
//           });
//           print('✅ Related Workers mile: ${relatedWorkers.length}');
//         } else {
//           setState(() {
//             errorMessage = jsonData['message'] ?? 'Service providers nahi mile';
//             isLoading = false;
//           });
//         }
//       } else if (response.statusCode == 401) {
//         setState(() {
//           errorMessage = 'Unauthorized: Phir se login karo.';
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Error: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('❌ Related Workers API Error: $e');
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> submitBid(
//       String amount, String description, String duration) async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'No token found. Please log in again.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }
//
//       if (amount.isEmpty || description.isEmpty || duration.isEmpty) {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'Please fill all fields',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }
//
//       double? bidAmount;
//       int? bidDuration;
//       try {
//         bidAmount = double.parse(amount);
//         bidDuration = int.parse(duration);
//         if (bidAmount <= 0 || bidDuration <= 0) {
//           throw FormatException('Amount aur duration positive hone chahiye');
//         }
//       } catch (e) {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'Invalid amount ya duration format',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }
//
//       final payload = {
//         'order_id': widget.orderId,
//         'bid_amount': bidAmount.toString(),
//         'duration': bidDuration,
//         'message': description,
//       };
//
//       print('📤 Sending Bid Payload: ${jsonEncode(payload)}');
//       print('🔐 Using Token: $token');
//
//       final response = await http.post(
//         Uri.parse('https://api.thebharatworks.com/api/bidding-order/placeBid'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📥 Bid Response Status: ${response.statusCode}');
//       print('📥 Bid Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           setState(() {
//             isLoading = false;
//             hasAlreadyBid = true;
//           });
//           Get.snackbar(
//             'Success',
//             'Bid successfully placed!',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//           fetchBidders();
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           Get.snackbar(
//             'Error',
//             jsonData['message'] ?? 'Failed to place bid',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//         }
//       } else if (response.statusCode == 400) {
//         final jsonData = jsonDecode(response.body);
//         setState(() {
//           isLoading = false;
//           if (jsonData['message'] ==
//               'You have already placed a bid on this order.') {
//             hasAlreadyBid = true;
//           }
//         });
//         Get.snackbar(
//           'Error',
//           jsonData['message'] ?? 'Invalid request data',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//       } else if (response.statusCode == 401) {
//         setState(() {
//           isLoading = false;
//           errorMessage = 'Unauthorized: Please log in again.';
//         });
//         Get.snackbar(
//           'Error',
//           'Unauthorized: Please log in again.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'Error: ${response.statusCode}',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       print('❌ Bid API Error: $e');
//       setState(() {
//         isLoading = false;
//       });
//       Get.snackbar(
//         'Error',
//         'Error: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         margin: EdgeInsets.all(10),
//         duration: Duration(seconds: 3),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     // If still loading or biddingOrder is null, show loading indicator
//     if (isLoading || biddingOrder == null) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: AppColors.primaryGreen,
//           centerTitle: true,
//           elevation: 0,
//           toolbarHeight: height * 0.03,
//           automaticallyImplyLeading: false,
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     // If there's an error, show error message
//     if (errorMessage.isNotEmpty) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: AppColors.primaryGreen,
//           centerTitle: true,
//           elevation: 0,
//           toolbarHeight: height * 0.03,
//           automaticallyImplyLeading: false,
//         ),
//         body: Center(child: Text(errorMessage)),
//       );
//     }
//
//     // Main content when data is available
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: height * 0.03,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(width * 0.02),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: height * 0.01),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Padding(
//                       padding: EdgeInsets.only(left: width * 0.02),
//                       child: Icon(Icons.arrow_back, size: width * 0.06),
//                     ),
//                   ),
//                   SizedBox(width: width * 0.25),
//                   Text(
//                     "Work detail",
//                     style: GoogleFonts.roboto(
//                       fontSize: width * 0.045,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: height * 0.01),
//               Padding(
//                 padding: EdgeInsets.all(width * 0.02),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CarouselSlider(
//                       options: CarouselOptions(
//                         height: height * 0.25,
//                         enlargeCenterPage: true,
//                         autoPlay: true,
//                         viewportFraction: 1,
//                       ),
//                       items: biddingOrder!.imageUrls.isNotEmpty
//                           ? biddingOrder!.imageUrls.map((item) {
//                               print('🖼️ Image: $item');
//                               return ClipRRect(
//                                 borderRadius:
//                                     BorderRadius.circular(width * 0.025),
//                                 child: Image.network(
//                                   item,
//                                   fit: BoxFit.cover,
//                                   width: width,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     print(
//                                         '❌ Image error: $item, Error: $error');
//                                     return Image.asset(
//                                       'assets/images/chair.png',
//                                       fit: BoxFit.cover,
//                                       width: width,
//                                     );
//                                   },
//                                 ),
//                               );
//                             }).toList()
//                           : [
//                               ClipRRect(
//                                 borderRadius:
//                                     BorderRadius.circular(width * 0.025),
//                                 child: Image.asset(
//                                   'assets/images/chair.png',
//                                   fit: BoxFit.cover,
//                                   width: width,
//                                 ),
//                               ),
//                             ],
//                     ),
//                     SizedBox(height: height * 0.015),
//                     Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: width * 0.06,
//                             vertical: height * 0.005,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade300,
//                             borderRadius: BorderRadius.circular(width * 0.03),
//                           ),
//                           child: Text(
//                             biddingOrder!.address,
//                             style: GoogleFonts.roboto(
//                               color: Colors.white,
//                               fontSize: width * 0.03,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: height * 0.015),
//                     Padding(
//                       padding: EdgeInsets.only(left: width * 0.02),
//                       child: Text(
//                         biddingOrder!.title,
//                         style: TextStyle(
//                           fontSize: width * 0.045,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.005),
//                     Padding(
//                       padding: EdgeInsets.only(left: width * 0.02),
//                       child: Text(
//                         'Complete: ${biddingOrder!.deadline.split('T').first}',
//                         style: TextStyle(
//                           fontSize: width * 0.035,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.015),
//                     Padding(
//                       padding: EdgeInsets.only(left: width * 0.02),
//                       child: Text(
//                         '₹${biddingOrder!.cost.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: width * 0.05,
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.015),
//                     Padding(
//                       padding: EdgeInsets.only(left: width * 0.02),
//                       child: Text(
//                         'Task Details',
//                         style: TextStyle(
//                           fontSize: width * 0.04,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.005),
//                     Padding(
//                       padding: EdgeInsets.only(left: width * 0.02),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: biddingOrder!.description
//                             .split('.')
//                             .where((s) => s.trim().isNotEmpty)
//                             .map((s) => Padding(
//                                   padding:
//                                       EdgeInsets.only(bottom: height * 0.004),
//                                   child: Text(
//                                     '• $s',
//                                     style: TextStyle(fontSize: width * 0.035),
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.02),
//                     Center(
//                       child: GestureDetector(
//                         onTap: biddingOrder!.userId == currentUserId
//                             ? () {
//                                 Get.snackbar(
//                                   'Error',
//                                   'You cannot bid on your own order',
//                                   snackPosition: SnackPosition.BOTTOM,
//                                   backgroundColor: Colors.red,
//                                   colorText: Colors.white,
//                                   margin: EdgeInsets.all(10),
//                                   duration: Duration(seconds: 3),
//                                 );
//                               }
//                             : hasAlreadyBid
//                                 ? () {
//                                     Get.snackbar(
//                                       'Error',
//                                       'You have already placed a bid on this order',
//                                       snackPosition: SnackPosition.BOTTOM,
//                                       backgroundColor: Colors.red,
//                                       colorText: Colors.white,
//                                       margin: EdgeInsets.all(10),
//                                       duration: Duration(seconds: 3),
//                                     );
//                                   }
//                                 : () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
//                                         final TextEditingController
//                                             amountController =
//                                             TextEditingController();
//                                         final TextEditingController
//                                             descriptionController =
//                                             TextEditingController();
//                                         final TextEditingController
//                                             durationController =
//                                             TextEditingController();
//                                         return AlertDialog(
//                                           backgroundColor: Colors.white,
//                                           insetPadding: EdgeInsets.symmetric(
//                                               horizontal: width * 0.05),
//                                           title: Center(
//                                             child: Text(
//                                               "Bid",
//                                               style: GoogleFonts.roboto(
//                                                 fontSize: width * 0.05,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                           content: SingleChildScrollView(
//                                             child: SizedBox(
//                                               width: width * 0.8,
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     "Enter Amount",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: width * 0.035,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       height: height * 0.005),
//                                                   TextField(
//                                                     controller:
//                                                         amountController,
//                                                     keyboardType:
//                                                         TextInputType.number,
//                                                     decoration: InputDecoration(
//                                                       hintText: "₹0.00",
//                                                       border:
//                                                           OutlineInputBorder(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                     width *
//                                                                         0.02),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       height: height * 0.01),
//                                                   Text(
//                                                     "Description",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: width * 0.035,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       height: height * 0.005),
//                                                   TextField(
//                                                     controller:
//                                                         descriptionController,
//                                                     maxLines: 3,
//                                                     decoration: InputDecoration(
//                                                       hintText:
//                                                           "Enter Description",
//                                                       border:
//                                                           OutlineInputBorder(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                     width *
//                                                                         0.02),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       height: height * 0.01),
//                                                   Text(
//                                                     "Duration",
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: width * 0.035,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       height: height * 0.005),
//                                                   TextField(
//                                                     controller:
//                                                         durationController,
//                                                     keyboardType:
//                                                         TextInputType.number,
//                                                     decoration: InputDecoration(
//                                                       hintText:
//                                                           "Enter Duration (in days)",
//                                                       border:
//                                                           OutlineInputBorder(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                     width *
//                                                                         0.02),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                       height: height * 0.015),
//                                                   Center(
//                                                     child: GestureDetector(
//                                                       onTap: () {
//                                                         String amount =
//                                                             amountController
//                                                                 .text
//                                                                 .trim();
//                                                         String description =
//                                                             descriptionController
//                                                                 .text
//                                                                 .trim();
//                                                         String duration =
//                                                             durationController
//                                                                 .text
//                                                                 .trim();
//                                                         submitBid(
//                                                             amount,
//                                                             description,
//                                                             duration);
//                                                         Navigator.pop(context);
//                                                       },
//                                                       child: Container(
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                           horizontal:
//                                                               width * 0.18,
//                                                           vertical:
//                                                               height * 0.012,
//                                                         ),
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color: Colors
//                                                               .green.shade700,
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       width *
//                                                                           0.02),
//                                                         ),
//                                                         child: Text(
//                                                           "Bid",
//                                                           style: TextStyle(
//                                                             color: Colors.white,
//                                                             fontSize:
//                                                                 width * 0.04,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: width * 0.18,
//                             vertical: height * 0.012,
//                           ),
//                           decoration: BoxDecoration(
//                             color: biddingOrder!.userId == currentUserId ||
//                                     hasAlreadyBid
//                                 ? Colors.grey.shade400
//                                 : Colors.green.shade700,
//                             borderRadius: BorderRadius.circular(width * 0.02),
//                           ),
//                           child: Text(
//                             "Bid",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: width * 0.04,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: height * 0.02),
//                     // Negotiation Card
//                     NegotiationCard(
//                       width: width,
//                       height: height,
//                       offerPrice: biddingOrder!.cost.toStringAsFixed(0),
//                       onSubmit: submitBid,
//                     ),
//                     SizedBox(height: height * 0.02),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: width * 0.05),
//                       child: Column(
//                         children: [
//                           SizedBox(height: height * 0.015),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     _selectedIndex = 0;
//                                   });
//                                 },
//                                 child: Container(
//                                   height: height * 0.045,
//                                   width: width * 0.40,
//                                   decoration: BoxDecoration(
//                                     color: _selectedIndex == 0
//                                         ? Colors.green.shade700
//                                         : Colors.grey.shade300,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Center(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(width: width * 0.02),
//                                         Text(
//                                           "Bidders",
//                                           style: TextStyle(
//                                             color: _selectedIndex == 0
//                                                 ? Colors.white
//                                                 : Colors.grey.shade700,
//                                             fontSize: width * 0.05,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: width * 0.0),
//                               InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     _selectedIndex = 1;
//                                   });
//                                 },
//                                 child: Container(
//                                   height: height * 0.045,
//                                   width: width * 0.40,
//                                   decoration: BoxDecoration(
//                                     color: _selectedIndex == 1
//                                         ? Colors.green.shade700
//                                         : Colors.grey.shade300,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Center(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(width: width * 0.02),
//                                         Text(
//                                           "Related Worker",
//                                           style: TextStyle(
//                                             color: _selectedIndex == 1
//                                                 ? Colors.white
//                                                 : Colors.grey.shade700,
//                                             fontSize: width * 0.04,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (_selectedIndex == 0)
//                             Padding(
//                               padding: EdgeInsets.only(top: height * 0.01),
//                               child: bidders.isEmpty
//                                   ? Center(
//                                       child: Text(
//                                         'No bidders found',
//                                         style: TextStyle(
//                                           fontSize: width * 0.04,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     )
//                                   : ListView.builder(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       itemCount: bidders.length,
//                                       itemBuilder: (context, index) {
//                                         final bidder = bidders[index];
//                                         return Container(
//                                           margin: EdgeInsets.symmetric(
//                                             vertical: height * 0.01,
//                                             horizontal: width * 0.01,
//                                           ),
//                                           padding: EdgeInsets.all(width * 0.02),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.grey
//                                                     .withOpacity(0.2),
//                                                 spreadRadius: 1,
//                                                 blurRadius: 5,
//                                                 offset: const Offset(0, 3),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                                 child: Image.asset(
//                                                   "assets/images/account1.png",
//                                                   height: 90,
//                                                   width: 90,
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                               SizedBox(width: width * 0.03),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         Flexible(
//                                                           child: Text(
//                                                             bidder['name'],
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   width * 0.045,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             maxLines: 1,
//                                                           ),
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Text(
//                                                               "${bidder['rating']}",
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     width *
//                                                                         0.035,
//                                                               ),
//                                                             ),
//                                                             Icon(
//                                                               Icons.star,
//                                                               size:
//                                                                   width * 0.04,
//                                                               color: Colors
//                                                                   .yellow
//                                                                   .shade700,
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         Text(
//                                                           bidder['amount'],
//                                                           style: TextStyle(
//                                                             fontSize:
//                                                                 width * 0.04,
//                                                             color: Colors.black,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             width: width * 0.1),
//                                                         Expanded(
//                                                           child: Column(
//                                                             children: [
//                                                               Row(
//                                                                 children: [
//                                                                   CircleAvatar(
//                                                                     radius: 13,
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .grey
//                                                                             .shade300,
//                                                                     child: Icon(
//                                                                       Icons
//                                                                           .phone,
//                                                                       size: 18,
//                                                                       color: Colors
//                                                                           .green
//                                                                           .shade600,
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     Row(
//                                                       children: [
//                                                         Flexible(
//                                                           child: Container(
//                                                               height: 22,
//                                                               constraints:
//                                                                   BoxConstraints(
//                                                                 maxWidth:
//                                                                     width *
//                                                                         0.25,
//                                                               ),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 color: Colors
//                                                                     .red
//                                                                     .shade300,
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             10),
//                                                               ),
//                                                               child: Center(
//                                                                 child:
//                                                                     Container(
//                                                                   alignment:
//                                                                       Alignment
//                                                                           .center,
//                                                                   width: double
//                                                                       .infinity,
//                                                                   child: Text(
//                                                                     bidder[
//                                                                         'location'],
//                                                                     textAlign:
//                                                                         TextAlign
//                                                                             .center,
//                                                                     style: GoogleFonts
//                                                                         .roboto(
//                                                                       fontSize:
//                                                                           width *
//                                                                               0.028,
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     maxLines: 1,
//                                                                   ),
//                                                                 ),
//                                                               )),
//                                                         ),
//                                                         SizedBox(
//                                                             width:
//                                                                 width * 0.03),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   bottom: 5.0),
//                                                           child: CircleAvatar(
//                                                             radius: 13,
//                                                             backgroundColor:
//                                                                 Colors.grey
//                                                                     .shade300,
//                                                             child: Icon(
//                                                               Icons.message,
//                                                               size: 18,
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade600,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         TextButton(
//                                                           onPressed: () {},
//                                                           style: TextButton
//                                                               .styleFrom(
//                                                             padding:
//                                                                 EdgeInsets.zero,
//                                                             minimumSize:
//                                                                 Size(0, 25),
//                                                             tapTargetSize:
//                                                                 MaterialTapTargetSize
//                                                                     .shrinkWrap,
//                                                           ),
//                                                           child: Text(
//                                                             "View Profile",
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   width * 0.032,
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade700,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Flexible(
//                                                           child: Container(
//                                                             height: 25,
//                                                             constraints:
//                                                                 BoxConstraints(
//                                                               maxWidth:
//                                                                   width * 0.2,
//                                                             ),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade700,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           8),
//                                                             ),
//                                                             child: Center(
//                                                               child: Text(
//                                                                 "Accept",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.032,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 maxLines: 1,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                             ),
//                           if (_selectedIndex == 1)
//                             Padding(
//                               padding: EdgeInsets.only(top: height * 0.01),
//                               child: relatedWorkers.isEmpty
//                                   ? Center(
//                                       child: Text(
//                                         'No related workers found',
//                                         style: TextStyle(
//                                           fontSize: width * 0.04,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     )
//                                   : ListView.builder(
//                                       shrinkWrap: true,
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       itemCount: relatedWorkers.length,
//                                       itemBuilder: (context, index) {
//                                         final worker = relatedWorkers[index];
//                                         return Container(
//                                           margin: EdgeInsets.symmetric(
//                                             vertical: height * 0.01,
//                                             horizontal: width * 0.01,
//                                           ),
//                                           padding: EdgeInsets.all(width * 0.02),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.grey
//                                                     .withOpacity(0.2),
//                                                 spreadRadius: 1,
//                                                 blurRadius: 5,
//                                                 offset: const Offset(0, 3),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                                 child: Image.asset(
//                                                   "assets/images/account1.png",
//                                                   height: 90,
//                                                   width: 90,
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                               SizedBox(width: width * 0.03),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         Flexible(
//                                                           child: Text(
//                                                             worker['name'],
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   width * 0.045,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             maxLines: 1,
//                                                           ),
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Text(
//                                                               "${worker['rating']}",
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     width *
//                                                                         0.035,
//                                                               ),
//                                                             ),
//                                                             Icon(
//                                                               Icons.star,
//                                                               size:
//                                                                   width * 0.04,
//                                                               color: Colors
//                                                                   .yellow
//                                                                   .shade700,
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         Text(
//                                                           worker['amount'],
//                                                           style: TextStyle(
//                                                             fontSize:
//                                                                 width * 0.04,
//                                                             color: Colors.black,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             width:
//                                                                 width * 0.10),
//                                                         Expanded(
//                                                           child: Column(
//                                                             children: [
//                                                               Row(
//                                                                 children: [
//                                                                   CircleAvatar(
//                                                                     radius: 13,
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .grey
//                                                                             .shade300,
//                                                                     child: Icon(
//                                                                       Icons
//                                                                           .phone,
//                                                                       size: 18,
//                                                                       color: Colors
//                                                                           .green
//                                                                           .shade600,
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     Row(
//                                                       children: [
//                                                         Flexible(
//                                                           child: Container(
//                                                             height: 22,
//                                                             constraints:
//                                                                 BoxConstraints(
//                                                               maxWidth:
//                                                                   width * 0.25,
//                                                             ),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               color: Colors
//                                                                   .red.shade300,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           10),
//                                                             ),
//                                                             child: Center(
//                                                               child: Text(
//                                                                 worker[
//                                                                     'location'],
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.033,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 maxLines: 1,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             width:
//                                                                 width * 0.03),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   top: 8.0),
//                                                           child: CircleAvatar(
//                                                             radius: 13,
//                                                             backgroundColor:
//                                                                 Colors.grey
//                                                                     .shade300,
//                                                             child: Icon(
//                                                               Icons.message,
//                                                               size: 18,
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade600,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         TextButton(
//                                                           onPressed: () {},
//                                                           style: TextButton
//                                                               .styleFrom(
//                                                             padding:
//                                                                 EdgeInsets.zero,
//                                                             minimumSize:
//                                                                 Size(0, 25),
//                                                             tapTargetSize:
//                                                                 MaterialTapTargetSize
//                                                                     .shrinkWrap,
//                                                           ),
//                                                           child: Text(
//                                                             "View Profile",
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   width * 0.032,
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade700,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Flexible(
//                                                           child: Container(
//                                                             height: 28,
//                                                             constraints:
//                                                                 BoxConstraints(
//                                                               maxWidth:
//                                                                   width * 0.2,
//                                                             ),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               color: Colors
//                                                                   .green
//                                                                   .shade700,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           8),
//                                                             ),
//                                                             child: Center(
//                                                               child: Text(
//                                                                 "Invite",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.032,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 maxLines: 1,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                             ),
//                           SizedBox(height: height * 0.02),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: height * 0.01),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Negotiation Card Widget
// class NegotiationCard extends StatefulWidget {
//   final double width;
//   final double height;
//   final String offerPrice;
//   final Function(String, String, String) onSubmit;
//
//   const NegotiationCard({
//     Key? key,
//     required this.width,
//     required this.height,
//     required this.offerPrice,
//     required this.onSubmit,
//   }) : super(key: key);
//
//   @override
//   _NegotiationCardState createState() => _NegotiationCardState();
// }
//
// class _NegotiationCardState extends State<NegotiationCard> {
//   bool isNegotiating = false;
//   final TextEditingController amountController = TextEditingController();
//
//   @override
//   void dispose() {
//     amountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.white,
//       child: Container(
//         width: widget.width,
//         padding: EdgeInsets.all(widget.width * 0.04),
//         child: Column(
//           children: [
//             Container(
//               width: widget.width,
//               padding: EdgeInsets.all(widget.width * 0.015),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(widget.width * 0.02),
//                 color: Colors.green.shade100,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding:
//                           EdgeInsets.symmetric(vertical: widget.height * 0.015),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(widget.width * 0.02),
//                         border: Border.all(color: Colors.green),
//                         color: Colors.white,
//                       ),
//                       child: Text(
//                         "Offer Price(₹${widget.offerPrice})",
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontSize: widget.width * 0.04,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: widget.width * 0.015),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isNegotiating = true; // Show negotiation field
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                             vertical: widget.height * 0.015),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius:
//                               BorderRadius.circular(widget.width * 0.02),
//                           border: Border.all(
//                             color: Colors.green.shade700,
//                           ),
//                           color: isNegotiating
//                               ? Colors.green.shade700
//                               : Colors.white,
//                         ),
//                         child: Text(
//                           "Negotiate",
//                           style: GoogleFonts.roboto(
//                             color: isNegotiating
//                                 ? Colors.white
//                                 : Colors.green.shade700,
//                             fontSize: widget.width * 0.04,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: widget.height * 0.02),
//             if (isNegotiating) ...[
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 2),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(widget.width * 0.02),
//                   border: Border.all(color: Colors.green),
//                   color: Colors.white,
//                 ),
//                 child: TextField(
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: "Enter your offer amount",
//                     hintStyle: GoogleFonts.roboto(
//                       color: Colors.green.shade700,
//                       fontWeight: FontWeight.bold,
//                       fontSize: widget.width * 0.04,
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                   ),
//                   style: GoogleFonts.roboto(
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.bold,
//                     fontSize: widget.width * 0.04,
//                   ),
//                 ),
//               ),
//               SizedBox(height: widget.height * 0.02),
//               GestureDetector(
//                 onTap: () {
//                   String amount = amountController.text.trim();
//                   widget.onSubmit(amount, "", ""); // ✅ only amount pass
//                   setState(() {
//                     isNegotiating = false;
//                     amountController.clear();
//                   });
//                 },
//                 child: Container(
//                   padding:
//                       EdgeInsets.symmetric(vertical: widget.height * 0.018),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(widget.width * 0.02),
//                     color: Colors.green.shade700,
//                   ),
//                   child: Text(
//                     "Send request",
//                     style: GoogleFonts.roboto(
//                       color: Colors.white,
//                       fontSize: widget.width * 0.04,
//                     ),
//                   ),
//                 ),
//               ),
//             ] else ...[
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: widget.height * 0.018),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(widget.width * 0.02),
//                   color: Colors.green.shade700,
//                 ),
//                 child: Text(
//                   "Accepted & Amount",
//                   style: GoogleFonts.roboto(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: widget.width * 0.03,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widgets/AppColors.dart';
import '../Models/bidding_order.dart'; // BiddingOrder model import kiya gaya

// Yeh main widget hai jo bidding order details aur negotiation handle karta hai
class Biddingserviceproviderworkdetail extends StatefulWidget {
  final String orderId;

  const Biddingserviceproviderworkdetail({Key? key, required this.orderId})
      : super(key: key);

  @override
  _BiddingserviceproviderworkdetailState createState() =>
      _BiddingserviceproviderworkdetailState();
}

class _BiddingserviceproviderworkdetailState
    extends State<Biddingserviceproviderworkdetail> {
  int _selectedIndex = 0; // 0 for Bidders, 1 for Related Worker
  List<Map<String, dynamic>> bidders = []; // Bidders ki list
  List<Map<String, dynamic>> relatedWorkers = []; // Related workers ki list
  BiddingOrder? biddingOrder; // Bidding order details
  bool isLoading = true; // Loading state
  String errorMessage = ''; // Error message
  String? currentUserId; // Current user ka ID
  bool hasAlreadyBid = false; // Check karta hai ki user ne bid kiya ya nahi
  String? biddingOfferId; // Bidding offer ID store karta hai
  String? negotiationId; // Negotiation ID store karta hai

  @override
  void initState() {
    super.initState();
    // Bidding order fetch karo, phir related workers aur bidders
    fetchBiddingOrder().then((_) {
      if (biddingOrder != null && biddingOrder!.categoryId.isNotEmpty) {
        print('✅ Bidding Order Ready: ${biddingOrder!.title}');
        print('✅ Category ID: ${biddingOrder!.categoryId}');
        print('✅ Subcategory IDs: ${biddingOrder!.subcategoryIds}');
        fetchRelatedWorkers(); // Valid bidding order ke liye call karo
      } else {
        setState(() {
          errorMessage = 'Bidding order details ya category ID nahi mila.';
          isLoading = false;
        });
        print('❌ Bidding order ya category ID invalid hai');
      }
      fetchBidders();
      fetchCurrentUserId();
    });
  }

  // Current user ID token se fetch karo
  Future<void> fetchCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) return;

      final parts = token.split('.');
      if (parts.length != 3) return;
      final payload = jsonDecode(String.fromCharCodes(
          base64Url.decode(base64Url.normalize(parts[1]))));
      setState(() {
        currentUserId = payload['id']?.toString();
      });
      print('👤 Current User ID: $currentUserId');
    } catch (e) {
      print('❌ Error fetching user ID: $e');
    }
  }

  // Single bidding order details fetch karo
  Future<void> fetchBiddingOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'No token found. Please log in again.';
          isLoading = false;
        });
        print('❌ No token found in SharedPreferences');
        return;
      }
      print('🔐 Token: $token');

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            biddingOrder = BiddingOrder.fromJson(jsonData['data']);
            isLoading = false;
          });
          print('✅ Bidding Order: ${biddingOrder!.title}');
          print('✅ Image URLs: ${biddingOrder!.imageUrls}');
          print('👤 Order Owner ID: ${biddingOrder!.userId}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Failed to fetch data';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Please log in again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ API Error: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Bidders ke offers fetch karo
  Future<void> fetchBidders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'No token found. Please log in again.';
          isLoading = false;
        });
        print('❌ No token found in SharedPreferences');
        return;
      }
      print('🔐 Token: $token');

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Bidders Response Status: ${response.statusCode}');
      print('📥 Bidders Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          List<dynamic> offers = jsonData['data'];
          print('📋 Offers: $offers'); // Debugging ke liye
          setState(() {
            bidders = offers.map((offer) {
              print(
                  '🔍 Checking offer for provider: ${offer['provider_id']['_id']}');
              if (offer['provider_id']['_id'] == currentUserId) {
                biddingOfferId = offer['_id'];
                hasAlreadyBid = true;
                print('✅ Found biddingOfferId: $biddingOfferId');
              }
              return {
                'name': offer['provider_id']['full_name'] ?? 'Unknown',
                'amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
                'location': 'Unknown Location',
                'rating': (offer['provider_id']['rating'] ?? 0).toDouble(),
                'status': offer['status'] ?? 'pending',
                'viewed': false,
                'offer_id': offer['_id'],
              };
            }).toList();
            isLoading = false;
          });
          print('✅ Bidders fetched: ${bidders.length}');
          print('✅ biddingOfferId: $biddingOfferId');
          print('✅ hasAlreadyBid: $hasAlreadyBid');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Failed to fetch bidders';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Please log in again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Bidders API Error: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Related workers (service providers) fetch karo
  Future<void> fetchRelatedWorkers() async {
    try {
      if (biddingOrder == null || biddingOrder!.categoryId.isEmpty) {
        setState(() {
          errorMessage = 'Order details ya category ID nahi mila.';
          isLoading = false;
        });
        print('❌ Bidding order ya category ID nahi hai');
        return;
      }

      if (biddingOrder!.subcategoryIds.isEmpty) {
        print(
            '⚠️ Subcategory IDs empty hain, API ke behavior ke hisaab se check karo');
      }

      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Koi token nahi mila. Phir se login karo.';
          isLoading = false;
        });
        print('❌ Token nahi mila SharedPreferences mein');
        return;
      }
      print('🔐 Token: $token');

      final payload = {
        'category_id': biddingOrder!.categoryId,
        'subcategory_ids': biddingOrder!.subcategoryIds,
      };

      print('📤 Payload bheja ja raha: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(
            'https://api.thebharatworks.com/api/user/getServiceProviders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Related Workers Response Status: ${response.statusCode}');
      print('📥 Related Workers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          List<dynamic> providers = jsonData['data'];
          setState(() {
            relatedWorkers = providers.map((provider) {
              return {
                'name': provider['full_name'] ?? 'Unknown',
                'amount':
                    '₹${biddingOrder?.cost.toStringAsFixed(2) ?? '1500.00'}',
                'location':
                    provider['location']['address'] ?? 'Unknown Location',
                'rating': (provider['rateAndReviews']?.isNotEmpty ?? false)
                    ? provider['rateAndReviews']
                            .map((review) => review['rating'])
                            .reduce((a, b) => a + b) /
                        provider['rateAndReviews'].length
                    : 0.0,
                'viewed': false,
                'provider_id': provider['_id'],
              };
            }).toList();
            isLoading = false;
          });
          print('✅ Related Workers mile: ${relatedWorkers.length}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Service providers nahi mile';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Phir se login karo.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Related Workers API Error: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Bid submit karne ka function
  // Future<void> submitBid(
  //     String amount, String description, String duration) async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token') ?? '';
  //     if (token.isEmpty) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Get.snackbar(
  //         'Error',
  //         'No token found. Please log in again.',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         margin: EdgeInsets.all(10),
  //         duration: Duration(seconds: 3),
  //       );
  //       return;
  //     }
  //
  //     if (amount.isEmpty || description.isEmpty || duration.isEmpty) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Get.snackbar(
  //         'Error',
  //         'Please fill all fields',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         margin: EdgeInsets.all(10),
  //         duration: Duration(seconds: 3),
  //       );
  //       return;
  //     }
  //
  //     double? bidAmount;
  //     int? bidDuration;
  //     try {
  //       bidAmount = double.parse(amount);
  //       bidDuration = int.parse(duration);
  //       if (bidAmount <= 0 || bidDuration <= 0) {
  //         throw FormatException('Amount aur duration positive hone chahiye');
  //       }
  //     } catch (e) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Get.snackbar(
  //         'Error',
  //         'Invalid amount ya duration format',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         margin: EdgeInsets.all(10),
  //         duration: Duration(seconds: 3),
  //       );
  //       return;
  //     }
  //
  //     final payload = {
  //       'order_id': widget.orderId,
  //       'bid_amount': bidAmount.toString(),
  //       'duration': bidDuration,
  //       'message': description,
  //     };
  //
  //     print('📤 Sending Bid Payload: ${jsonEncode(payload)}');
  //     print('🔐 Using Token: $token');
  //
  //     final response = await http.post(
  //       Uri.parse('https://api.thebharatworks.com/api/bidding-order/placeBid'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(payload),
  //     );
  //
  //     print('📥 Bid Response Status: ${response.statusCode}');
  //     print('📥 Bid Response Body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(response.body);
  //       if (jsonData['status'] == true) {
  //         setState(() {
  //           isLoading = false;
  //           hasAlreadyBid = true;
  //           biddingOfferId = jsonData['data']['_id'];
  //         });
  //         print('✅ Bid placed, biddingOfferId: $biddingOfferId');
  //         Get.snackbar(
  //           'Success',
  //           'Bid successfully placed!',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,
  //           margin: EdgeInsets.all(10),
  //           duration: Duration(seconds: 3),
  //         );
  //         fetchBidders();
  //       } else {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         Get.snackbar(
  //           'Error',
  //           jsonData['message'] ?? 'Failed to place bid',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.red,
  //           colorText: Colors.white,
  //           margin: EdgeInsets.all(10),
  //           duration: Duration(seconds: 3),
  //         );
  //       }
  //     } else if (response.statusCode == 400) {
  //       final jsonData = jsonDecode(response.body);
  //       setState(() {
  //         isLoading = false;
  //         if (jsonData['message'] ==
  //             'You have already placed a bid on this order.') {
  //           hasAlreadyBid = true;
  //         }
  //       });
  //       Get.snackbar(
  //         'Error',
  //         jsonData['message'] ?? 'Invalid request data',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         margin: EdgeInsets.all(10),
  //         duration: Duration(seconds: 3),
  //       );
  //     } else if (response.statusCode == 401) {
  //       setState(() {
  //         isLoading = false;
  //         errorMessage = 'Unauthorized: Please log in again.';
  //       });
  //       Get.snackbar(
  //         'Error',
  //         'Unauthorized: Please log in again.',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         margin: EdgeInsets.all(10),
  //         duration: Duration(seconds: 3),
  //       );
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Get.snackbar(
  //         'Error',
  //         'Error: ${response.statusCode}',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         margin: EdgeInsets.all(10),
  //         duration: Duration(seconds: 3),
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Bid API Error: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Get.snackbar(
  //       'Error',
  //       'Error: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       margin: EdgeInsets.all(10),
  //       duration: Duration(seconds: 3),
  //     );
  //   }
  // }

  Future<void> submitBid(
      String amount, String description, String duration) async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'No token found. Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      if (amount.isEmpty || description.isEmpty || duration.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      double? bidAmount;
      int? bidDuration;
      try {
        bidAmount = double.parse(amount);
        bidDuration = int.parse(duration);
        if (bidAmount <= 0 || bidDuration <= 0) {
          throw FormatException('Amount aur duration positive hone chahiye');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Invalid amount ya duration format',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      final payload = {
        'order_id': widget.orderId,
        'bid_amount': bidAmount.toString(),
        'duration': bidDuration,
        'message': description,
      };

      print('📤 Sending Bid Payload: ${jsonEncode(payload)}');
      print('🔐 Using Token: $token');

      final response = await http.post(
        Uri.parse('https://api.thebharatworks.com/api/bidding-order/placeBid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Bid Response Status: ${response.statusCode}');
      print('📥 Bid Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Yahan 201 add kiya
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            isLoading = false;
            hasAlreadyBid = true;
            biddingOfferId = jsonData['data']['_id'];
          });
          print('✅ Bid placed, biddingOfferId: $biddingOfferId');
          Get.snackbar(
            'Success',
            'Bid successfully placed!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
          fetchBidders();
        } else {
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Failed to place bid',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
        }
      } else if (response.statusCode == 400) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          isLoading = false;
          if (jsonData['message'] ==
              'You have already placed a bid on this order.') {
            hasAlreadyBid = true;
          }
        });
        Get.snackbar(
          'Error',
          jsonData['message'] ?? 'Invalid request data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unauthorized: Please log in again.';
        });
        Get.snackbar(
          'Error',
          'Unauthorized: Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Bid API Error: $e');
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      );
    }
  }

  // Negotiation shuru karne ka function
  Future<void> startNegotiation(String amount) async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Koi token nahi mila. Phir se login karo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Check karo ki biddingOfferId available hai
      if (biddingOfferId == null || biddingOfferId!.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Bid Place.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      if (amount.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          ' Enter Amount ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      double? offerAmount;
      try {
        offerAmount = double.parse(amount);
        if (offerAmount <= 0) {
          throw FormatException('Amount positive hona chahiye');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Invalid amount format',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      final payload = {
        'order_id': widget.orderId,
        'bidding_offer_id': biddingOfferId,
        'service_provider': currentUserId ?? '',
        'user': biddingOrder!.userId,
        'initiator': 'service_provider',
        'offer_amount': offerAmount,
        'message': 'Negotiation request for ₹$offerAmount',
      };

      print('📤 Sending Negotiation Payload: ${jsonEncode(payload)}');
      print('🔐 Using Token: $token');

      final response = await http.post(
        Uri.parse('https://api.thebharatworks.com/api/negotiations/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Negotiation Response Status: ${response.statusCode}');
      print('📥 Negotiation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            isLoading = false;
            negotiationId = jsonData['negotiation']['_id'];
          });
          Get.snackbar(
            'Success',
            'Negotiation shuru ho gaya!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Negotiation shuru nahi hua',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
        }
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unauthorized: Phir se login karo.';
        });
        Get.snackbar(
          'Error',
          'Unauthorized: Phir se login karo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Negotiation API Error: $e');
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      );
    }
  }

  // Negotiation accept karne ka function (PUT request ke saath)
  Future<void> acceptNegotiation(String amount) async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'No token found. Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Check karo ki biddingOfferId available hai
      if (biddingOfferId == null || biddingOfferId!.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Bid not placed. Please place a bid first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      if (amount.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          ' Enter Amount ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      double? offerAmount;
      try {
        offerAmount = double.parse(amount);
        if (offerAmount <= 0) {
          throw FormatException('Amount must be positive');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Invalid amount format',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
        return;
      }

      if (negotiationId == null) {
        final payloadStart = {
          'order_id': widget.orderId,
          'bidding_offer_id': biddingOfferId,
          'service_provider': currentUserId ?? '',
          'user': biddingOrder!.userId,
          'initiator': 'service_provider',
          'offer_amount': offerAmount,
          'message': 'Accept request for ₹$offerAmount',
        };

        print(
            '📤 Sending Negotiation Start Payload: ${jsonEncode(payloadStart)}');
        print('🔐 Using Token: $token');

        final responseStart = await http.post(
          Uri.parse('https://api.thebharatworks.com/api/negotiations/start'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payloadStart),
        );

        print(
            '📥 Negotiation Start Response Status: ${responseStart.statusCode}');
        print('📥 Negotiation Start Response Body: ${responseStart.body}');

        if (responseStart.statusCode == 200) {
          final jsonData = jsonDecode(responseStart.body);
          if (jsonData['status'] == true) {
            setState(() {
              negotiationId = jsonData['negotiation']['_id'];
            });
          } else {
            setState(() {
              isLoading = false;
            });
            Get.snackbar(
              'Error',
              jsonData['message'] ?? 'Negotiation start',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: EdgeInsets.all(10),
              duration: Duration(seconds: 3),
            );
            return;
          }
        } else {
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            'Error',
            'Error starting negotiation: ${responseStart.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
          return;
        }
      }

      // Ab negotiation accept karo (PUT request)
      final payloadAccept = {
        'role': 'service_provider',
      };

      print(
          '📤 Sending Accept Negotiation Payload: ${jsonEncode(payloadAccept)}');
      print('🔐 Using Token: $token');
      print(
          '🔗 Accept URL: https://api.thebharatworks.com/api/negotiations/accept/$negotiationId');

      final responseAccept = await http.put(
        Uri.parse(
            'https://api.thebharatworks.com/api/negotiations/accept/$negotiationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payloadAccept),
      );

      print(
          '📥 Accept Negotiation Response Status: ${responseAccept.statusCode}');
      print('📥 Accept Negotiation Response Body: ${responseAccept.body}');

      if (responseAccept.statusCode == 200) {
        final jsonData = jsonDecode(responseAccept.body);
        if (jsonData['status'] == true) {
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            'Success',
            'Negotiation accept ',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Negotiation not  accept ',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
        }
      } else if (responseAccept.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unauthorized: Please log in again.';
        });
        Get.snackbar(
          'Error',
          'Unauthorized:Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Error: ${responseAccept.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Accept Negotiation API Error: $e');
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (isLoading || biddingOrder == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: height * 0.03,
          automaticallyImplyLeading: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Agar error hai, toh error message dikhao
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: height * 0.03,
          automaticallyImplyLeading: false,
        ),
        body: Center(child: Text(errorMessage)),
      );
    }

    // Main content jab data available ho
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: height * 0.03,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.01),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Icon(Icons.arrow_back, size: width * 0.06),
                    ),
                  ),
                  SizedBox(width: width * 0.25),
                  Text(
                    "Work detail",
                    style: GoogleFonts.roboto(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: height * 0.25,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        viewportFraction: 1,
                      ),
                      items: biddingOrder!.imageUrls.isNotEmpty
                          ? biddingOrder!.imageUrls.map((item) {
                              print('🖼️ Image: $item');
                              return ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(width * 0.025),
                                child: Image.network(
                                  item,
                                  fit: BoxFit.cover,
                                  width: width,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                        '❌ Image error: $item, Error: $error');
                                    return Image.asset(
                                      'assets/images/chair.png',
                                      fit: BoxFit.cover,
                                      width: width,
                                    );
                                  },
                                ),
                              );
                            }).toList()
                          : [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(width * 0.025),
                                child: Image.asset(
                                  'assets/images/chair.png',
                                  fit: BoxFit.cover,
                                  width: width,
                                ),
                              ),
                            ],
                    ),
                    SizedBox(height: height * 0.015),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.06,
                            vertical: height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.circular(width * 0.03),
                          ),
                          child: Text(
                            biddingOrder!.address,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: width * 0.03,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Text(
                        biddingOrder!.title,
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Text(
                        'Complete: ${biddingOrder!.deadline.split('T').first}',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Text(
                        '₹${biddingOrder!.cost.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: width * 0.05,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Text(
                        'Task Details',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.005),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: biddingOrder!.description
                            .split('.')
                            .where((s) => s.trim().isNotEmpty)
                            .map((s) => Padding(
                                  padding:
                                      EdgeInsets.only(bottom: height * 0.004),
                                  child: Text(
                                    '• $s',
                                    style: TextStyle(fontSize: width * 0.035),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Center(
                      child: GestureDetector(
                        onTap: biddingOrder!.userId == currentUserId
                            ? () {
                                Get.snackbar(
                                  'Error',
                                  'You cannot bid on your own order',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  margin: EdgeInsets.all(10),
                                  duration: Duration(seconds: 3),
                                );
                              }
                            : hasAlreadyBid
                                ? () {
                                    Get.snackbar(
                                      'Error',
                                      'You have already placed a bid on this order',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      margin: EdgeInsets.all(10),
                                      duration: Duration(seconds: 3),
                                    );
                                  }
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        final TextEditingController
                                            amountController =
                                            TextEditingController();
                                        final TextEditingController
                                            descriptionController =
                                            TextEditingController();
                                        final TextEditingController
                                            durationController =
                                            TextEditingController();
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          insetPadding: EdgeInsets.symmetric(
                                              horizontal: width * 0.05),
                                          title: Center(
                                            child: Text(
                                              "Bid",
                                              style: GoogleFonts.roboto(
                                                fontSize: width * 0.05,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          content: SingleChildScrollView(
                                            child: SizedBox(
                                              width: width * 0.8,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Enter Amount",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: width * 0.035,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.005),
                                                  TextField(
                                                    controller:
                                                        amountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      hintText: "₹0.00",
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    width *
                                                                        0.02),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  Text(
                                                    "Description",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: width * 0.035,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.005),
                                                  TextField(
                                                    controller:
                                                        descriptionController,
                                                    maxLines: 3,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter Description",
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    width *
                                                                        0.02),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  Text(
                                                    "Duration",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: width * 0.035,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.005),
                                                  TextField(
                                                    controller:
                                                        durationController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter Duration (in days)",
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    width *
                                                                        0.02),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.015),
                                                  Center(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        String amount =
                                                            amountController
                                                                .text
                                                                .trim();
                                                        String description =
                                                            descriptionController
                                                                .text
                                                                .trim();
                                                        String duration =
                                                            durationController
                                                                .text
                                                                .trim();
                                                        submitBid(
                                                            amount,
                                                            description,
                                                            duration);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              width * 0.18,
                                                          vertical:
                                                              height * 0.012,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .green.shade700,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      width *
                                                                          0.02),
                                                        ),
                                                        child: Text(
                                                          "Bid",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                width * 0.04,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.18,
                            vertical: height * 0.012,
                          ),
                          decoration: BoxDecoration(
                            color: biddingOrder!.userId == currentUserId ||
                                    hasAlreadyBid
                                ? Colors.grey.shade400
                                : Colors.green.shade700,
                            borderRadius: BorderRadius.circular(width * 0.02),
                          ),
                          child: Text(
                            "Bid",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    // Negotiation Card ko call karo
                    NegotiationCard(
                      width: width,
                      height: height,
                      offerPrice: biddingOrder!.cost.toStringAsFixed(0),
                      onNegotiate: (amount) {
                        if (hasAlreadyBid && biddingOfferId != null) {
                          startNegotiation(amount);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please place a bid first.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: EdgeInsets.all(10),
                            duration: Duration(seconds: 3),
                          );
                        }
                      },
                      onAccept: (amount) {
                        if (hasAlreadyBid && biddingOfferId != null) {
                          acceptNegotiation(amount);
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please place a bid first.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: EdgeInsets.all(10),
                            duration: Duration(seconds: 3),
                          );
                        }
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 0;
                                  });
                                },
                                child: Container(
                                  height: height * 0.045,
                                  width: width * 0.40,
                                  decoration: BoxDecoration(
                                    color: _selectedIndex == 0
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
                                            color: _selectedIndex == 0
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
                              SizedBox(width: width * 0.0),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 1;
                                  });
                                },
                                child: Container(
                                  height: height * 0.045,
                                  width: width * 0.40,
                                  decoration: BoxDecoration(
                                    color: _selectedIndex == 1
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
                                            color: _selectedIndex == 1
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
                          if (_selectedIndex == 0)
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.01),
                              child: bidders.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No bidders found',
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: bidders.length,
                                      itemBuilder: (context, index) {
                                        final bidder = bidders[index];
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: height * 0.01,
                                            horizontal: width * 0.01,
                                          ),
                                          padding: EdgeInsets.all(width * 0.02),
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
                                                child: Image.asset(
                                                  "assets/images/account1.png",
                                                  height: 90,
                                                  width: 90,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.03),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          // Flexible ke bajaye Expanded use kiya
                                                          child: Text(
                                                            bidder['name'],
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width * 0.045,
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
                                                        SizedBox(
                                                            width: width *
                                                                0.02), // Thodi space rating ke liye
                                                        Row(
                                                          mainAxisSize: MainAxisSize
                                                              .min, // Rating Row ko minimum size do
                                                          children: [
                                                            Text(
                                                              "${bidder['rating']}",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    width *
                                                                        0.035,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: width *
                                                                    0.01),
                                                            Icon(
                                                              Icons.star,
                                                              size:
                                                                  width * 0.04,
                                                              color: Colors
                                                                  .yellow
                                                                  .shade700,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      bidder['amount'],
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      bidder['location'],
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      'Status: ${bidder['status']}',
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.01),
                              child: relatedWorkers.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No related workers found',
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: relatedWorkers.length,
                                      itemBuilder: (context, index) {
                                        final worker = relatedWorkers[index];
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: height * 0.01,
                                            horizontal: width * 0.01,
                                          ),
                                          padding: EdgeInsets.all(width * 0.02),
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
                                                child: Image.asset(
                                                  "assets/images/account1.png",
                                                  height: 90,
                                                  width: 90,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.03),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            worker['name'],
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width * 0.045,
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
                                                              "${worker['rating']}",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    width *
                                                                        0.035,
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.star,
                                                              size:
                                                                  width * 0.04,
                                                              color: Colors
                                                                  .yellow
                                                                  .shade700,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      worker['amount'],
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.005),
                                                    Text(
                                                      worker['location'],
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                        color: Colors.grey,
                                                      ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// NegotiationCard widget for Negotiate and Accept buttons
class NegotiationCard extends StatefulWidget {
  final double width;
  final double height;
  final String offerPrice;
  final Function(String) onNegotiate; // Amount ke liye negotiate
  final Function(String) onAccept; // Amount ke liye accept

  const NegotiationCard({
    Key? key,
    required this.width,
    required this.height,
    required this.offerPrice,
    required this.onNegotiate,
    required this.onAccept,
  }) : super(key: key);

  @override
  _NegotiationCardState createState() => _NegotiationCardState();
}

class _NegotiationCardState extends State<NegotiationCard> {
  bool isNegotiating = false;
  bool isAccepting = false; // Naya state for Accept & Amount
  final TextEditingController amountController = TextEditingController();
  final TextEditingController acceptAmountController =
      TextEditingController(); // Naya controller for accept

  @override
  void dispose() {
    amountController.dispose();
    acceptAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        width: widget.width,
        padding: EdgeInsets.all(widget.width * 0.04),
        child: Column(
          children: [
            Container(
              width: widget.width,
              padding: EdgeInsets.all(widget.width * 0.015),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.width * 0.02),
                color: Colors.green.shade100,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: widget.height * 0.015),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.width * 0.02),
                        border: Border.all(color: Colors.green),
                        color: Colors.white,
                      ),
                      child: Text(
                        "Offer Price",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: widget.width * 0.04,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.width * 0.015),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isNegotiating = true;
                          isAccepting =
                              false; // Negotiate click hone pe accept band
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: widget.height * 0.015),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.width * 0.02),
                          border: Border.all(color: Colors.green.shade700),
                          color: isNegotiating
                              ? Colors.green.shade700
                              : Colors.white,
                        ),
                        child: Text(
                          "Negotiate",
                          style: GoogleFonts.roboto(
                            color: isNegotiating
                                ? Colors.white
                                : Colors.green.shade700,
                            fontSize: widget.width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.height * 0.02),
            if (isNegotiating) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.width * 0.02),
                  border: Border.all(color: Colors.green),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter your offer Amount",
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.width * 0.04,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  style: GoogleFonts.roboto(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.width * 0.04,
                  ),
                ),
              ),
              SizedBox(height: widget.height * 0.02),
              GestureDetector(
                onTap: () {
                  String amount = amountController.text.trim();
                  widget.onNegotiate(amount);
                  setState(() {
                    isNegotiating = false;
                    amountController.clear();
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: widget.height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Send Request",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: widget.width * 0.04,
                    ),
                  ),
                ),
              ),
            ] else if (isAccepting) ...[
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.width * 0.02),
                  border: Border.all(color: Colors.green),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: acceptAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter your Accept Amount",
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.width * 0.04,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  style: GoogleFonts.roboto(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.width * 0.04,
                  ),
                ),
              ),
              SizedBox(height: widget.height * 0.02),
              GestureDetector(
                onTap: () {
                  String amount = acceptAmountController.text.trim();
                  widget.onAccept(amount);
                  setState(() {
                    isAccepting = false;
                    acceptAmountController.clear();
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: widget.height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Confirm Accept",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: widget.width * 0.04,
                    ),
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    isAccepting = true;
                    isNegotiating =
                        false; // Accept click hone pe negotiate band
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: widget.height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Accepted & Amount",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.width * 0.03,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
