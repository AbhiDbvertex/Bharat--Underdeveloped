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
// import '../Models/bidding_order.dart'; // BiddingOrder model import
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
//   List<Map<String, dynamic>> bidders = []; // Bidders ki list
//   List<Map<String, dynamic>> relatedWorkers = []; // Related workers ki list
//   BiddingOrder? biddingOrder; // Bidding order details
//   bool isLoading = true; // Loading state
//   String errorMessage = ''; // Error message
//   String? currentUserId; // Current user ka ID
//   bool hasAlreadyBid = false; // Check karta hai ki user ne bid kiya ya nahi
//   String? biddingOfferId; // Bidding offer ID store karta hai
//   String? negotiationId; // Negotiation ID store karta hai
//   String offerPrice = ''; // Dynamic offer price
//
//   @override
//   void initState() {
//     super.initState();
//     // Bidding order fetch karo, phir related workers aur bidders
//     fetchBiddingOrder().then((_) {
//       if (biddingOrder != null && biddingOrder!.categoryId.isNotEmpty) {
//         print('✅ Bidding Order Ready: ${biddingOrder!.title}');
//         print('✅ Category ID: ${biddingOrder!.categoryId}');
//         print('✅ Subcategory IDs: ${biddingOrder!.subcategoryIds}');
//         setState(() {
//           offerPrice = '₹${biddingOrder!.cost.toStringAsFixed(2)}';
//         });
//         fetchRelatedWorkers();
//         fetchLatestNegotiation(); // Fetch latest negotiation on init
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
//   // Current user ID token se fetch karo
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
//   // Bidding order fetch karo
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
//   // Bidders ke offers fetch karo
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
//           print('📋 Offers: $offers');
//           setState(() {
//             bidders = offers.map((offer) {
//               print(
//                   '🔍 Checking offer for provider: ${offer['provider_id']['_id']}');
//               if (offer['provider_id']['_id'] == currentUserId) {
//                 biddingOfferId = offer['_id'];
//                 hasAlreadyBid = true;
//                 print('✅ Found biddingOfferId: $biddingOfferId');
//               }
//               return {
//                 'bid_amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
//                 'offer_id': offer['_id'],
//                 'name': offer['provider_id']['full_name'] ?? 'Unknown',
//                 'status': offer['status'] ?? 'Pending',
//                 'address':
//                     offer['provider_id']['location']['address'] ?? 'Unknown',
//               };
//             }).toList();
//             isLoading = false;
//           });
//           print('✅ Bidders fetched: ${bidders.length}');
//           print('✅ biddingOfferId: $biddingOfferId');
//           print('✅ hasAlreadyBid: $hasAlreadyBid');
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
//   // Related workers fetch karo
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
//                 'provider_id': provider['_id'],
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
//   // Bid submit karo
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
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           setState(() {
//             isLoading = false;
//             hasAlreadyBid = true;
//             biddingOfferId = jsonData['data']['_id'];
//           });
//           print('✅ Bid placed, biddingOfferId: $biddingOfferId');
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
//   // Start Negotiation API
//   Future<void> startNegotiation(String amount) async {
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
//       if (amount.isEmpty) {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'Please enter an amount',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }
//
//       double? offerAmount;
//       try {
//         offerAmount = double.parse(amount);
//         if (offerAmount <= 0) {
//           throw FormatException('Amount positive hona chahiye');
//         }
//       } catch (e) {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'Invalid amount format',
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
//         'bidding_offer_id': biddingOfferId,
//         'service_provider': currentUserId,
//         'user': biddingOrder!.userId,
//         'initiator': 'service_provider',
//         'offer_amount': offerAmount,
//       };
//
//       print('📤 Sending Negotiation Payload: ${jsonEncode(payload)}');
//       print('🔐 Using Token: $token');
//
//       final response = await http.post(
//         Uri.parse('https://api.thebharatworks.com/api/negotiations/start'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📥 Negotiation Response Status: ${response.statusCode}');
//       print('📥 Negotiation Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['message'] == 'Negotiation started') {
//           setState(() {
//             isLoading = false;
//             negotiationId = jsonData['negotiation']['_id'];
//             offerPrice = '₹${offerAmount?.toStringAsFixed(2)}';
//             print('✅ Setting offerPrice in setState: $offerPrice');
//           });
//           print('✅ Negotiation started, negotiationId: $negotiationId');
//           print('✅ Updated offerPrice: $offerPrice');
//           Get.snackbar(
//             'Success',
//             'Negotiation request sent successfully!',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//           // Fetch latest negotiation to ensure UI is in sync
//           await fetchLatestNegotiation();
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           Get.snackbar(
//             'Error',
//             jsonData['message'] ?? 'Failed to start negotiation',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//         }
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
//       print('❌ Negotiation API Error: $e');
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
//   // Accept Negotiation API
//   Future<void> acceptNegotiation() async {
//     if (negotiationId == null) {
//       Get.snackbar(
//         'Error',
//         'No negotiation found to accept.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         margin: EdgeInsets.all(10),
//         duration: Duration(seconds: 3),
//       );
//       return;
//     }
//
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
//       final payload = {
//         'role': 'service_provider',
//       };
//
//       print('📤 Sending Accept Negotiation Payload: ${jsonEncode(payload)}');
//       print('🔐 Using Token: $token');
//
//       final response = await http.put(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/negotiations/accept/$negotiationId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📥 Accept Negotiation Response Status: ${response.statusCode}');
//       print('📥 Accept Negotiation Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['message'] == 'Negotiation accepted') {
//           setState(() {
//             isLoading = false;
//             offerPrice =
//                 '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
//             print('✅ Setting offerPrice in acceptNegotiation: $offerPrice');
//           });
//           Get.snackbar(
//             'Success',
//             'Negotiation accepted successfully!',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//           // Fetch latest negotiation to ensure UI is in sync
//           await fetchLatestNegotiation();
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           Get.snackbar(
//             'Error',
//             jsonData['message'] ?? 'Failed to accept negotiation',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//         }
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
//       print('❌ Accept Negotiation API Error: $e');
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
//   Future<void> fetchLatestNegotiation() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         print('❌ No token found for fetching latest negotiation');
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/negotiations/latest/${widget.orderId}/${biddingOfferId}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('📥 Latest Negotiation Response Status: ${response.statusCode}');
//       print('📥 Latest Negotiation Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['message'] == 'Negotiation found') {
//           setState(() {
//             offerPrice =
//                 '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
//             negotiationId = jsonData['negotiation']['_id'];
//             print(
//                 '✅ Setting offerPrice in fetchLatestNegotiation: $offerPrice');
//           });
//           print('✅ Latest offerPrice: $offerPrice');
//           print('✅ Latest negotiationId: $negotiationId');
//         } else {
//           print(
//               '⚠️ No negotiation found or unexpected message: ${jsonData['message']}');
//         }
//       } else {
//         print('⚠️ Failed to fetch latest negotiation: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Fetch Latest Negotiation Error: $e');
//     }
//   }
//
//   // Current user ka bid_amount fetch karo
//   String getCurrentUserBidAmount() {
//     if (bidders.isNotEmpty) {
//       for (var bidder in bidders) {
//         if (bidder['offer_id'] == biddingOfferId) {
//           return bidder['bid_amount'];
//         }
//       }
//       return bidders[0]['bid_amount'];
//     }
//     return biddingOrder != null
//         ? '₹${biddingOrder!.cost.toStringAsFixed(2)}'
//         : '₹0.00';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     print(
//         '🛠️ Building Biddingserviceproviderworkdetail with offerPrice: $offerPrice');
//
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
//                     Card(
//                       child: Container(
//                         height: 100,
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                         ),
//                         child: Row(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(50),
//                               child: biddingOrder?.userId?.profilePic != null
//                                   ? Image.network(
//                                       biddingOrder!.userId!.profilePic!,
//                                       height: 70,
//                                       width: 70,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                         return Image.asset(
//                                           'assets/images/account1.png',
//                                           height: 70,
//                                           width: 70,
//                                           fit: BoxFit.cover,
//                                         );
//                                       },
//                                     )
//                                   : Image.asset(
//                                       'assets/images/account1.png',
//                                       height: 70,
//                                       width: 70,
//                                       fit: BoxFit.cover,
//                                     ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         biddingOrder?.userId?.fullName ??
//                                             'Unknown',
//                                         style: GoogleFonts.roboto(
//                                           fontSize: 12,
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Spacer(),
//                                       Container(
//                                         height: 30,
//                                         width: 30,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Colors.grey.withOpacity(0.1),
//                                         ),
//                                         child: IconButton(
//                                           icon: Icon(
//                                             Icons.call,
//                                             color: Colors.green.shade700,
//                                             size: 14,
//                                           ),
//                                           onPressed: () {},
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 5),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         'Awarded amount - ₹${biddingOrder?.cost.toStringAsFixed(0) ?? '0'}/-',
//                                         style: GoogleFonts.roboto(
//                                           fontSize: 12,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       Spacer(),
//                                       Container(
//                                         height: 30,
//                                         width: 30,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Colors.grey.withOpacity(0.1),
//                                         ),
//                                         child: IconButton(
//                                           icon: Icon(
//                                             Icons.message_rounded,
//                                             color: Colors.green.shade700,
//                                             size: 14,
//                                           ),
//                                           onPressed: () {},
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     InkWell(
//                       onTap: () {
//                         // Yahan apni navigation dalni hai
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) => AssignAnotherPersonScreen(), // <-- apna screen yahan
//                         //   ),
//                         // );
//                       },
//                       child: Container(
//                         height: 50,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.green.shade700),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'Assign to another person',
//                             style: GoogleFonts.roboto(
//                               fontSize: 14,
//                               color: Colors.green,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: Colors.white,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Center(
//                               child: Text(
//                                 'Payment',
//                                 style: GoogleFonts.roboto(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             const Divider(thickness: 0.8),
//                             const SizedBox(height: 10),
//                             Text(
//                               'No payment history found.',
//                               style: GoogleFonts.roboto(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 40,
//                     ),
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.only(top: 40, bottom: 16),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(14),
//                             color: Colors.yellow.shade100,
//                           ),
//                           child: Column(
//                             children: [
//                               const SizedBox(height: 10),
//                               Text(
//                                 'Warning Message',
//                                 style: GoogleFonts.roboto(
//                                   fontSize: 14,
//                                   color: Colors.red,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Lorem ipsum dolor sit amet consectetur.',
//                                 style: GoogleFonts.roboto(
//                                   fontSize: 14,
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Positioned(
//                           top: -30,
//                           left: 0,
//                           right: 0,
//                           child: Center(
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 color: Colors.white,
//                               ),
//                               child: Image.asset(
//                                 'assets/images/warning.png',
//                                 height: 70,
//                                 width: 70,
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     GestureDetector(
//                       onTap: () {
//                         // TODO: yaha apna action likho
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: Colors.red,
//                         ),
//                         child: Center(
//                           child: Text(
//                             'Cancel Task and create dispute',
//                             style: GoogleFonts.roboto(
//                               fontSize: 14,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
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
//                     NegotiationCard(
//                       key: ValueKey(
//                           offerPrice), // Force rebuild on offerPrice change
//                       width: width,
//                       height: height,
//                       offerPrice: offerPrice,
//                       bidAmount: getCurrentUserBidAmount(),
//                       onNegotiate: (amount) {
//                         if (hasAlreadyBid && biddingOfferId != null) {
//                           startNegotiation(amount);
//                         } else {
//                           Get.snackbar(
//                             'Error',
//                             'Please place a bid first.',
//                             snackPosition: SnackPosition.BOTTOM,
//                             backgroundColor: Colors.red,
//                             colorText: Colors.white,
//                             margin: EdgeInsets.all(10),
//                             duration: Duration(seconds: 3),
//                           );
//                         }
//                       },
//                       onAccept: () {
//                         if (hasAlreadyBid && biddingOfferId != null) {
//                           acceptNegotiation();
//                         } else {
//                           Get.snackbar(
//                             'Error',
//                             'Please place a bid first.',
//                             snackPosition: SnackPosition.BOTTOM,
//                             backgroundColor: Colors.red,
//                             colorText: Colors.white,
//                             margin: EdgeInsets.all(10),
//                             duration: Duration(seconds: 3),
//                           );
//                         }
//                       },
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
//                                                     Text(
//                                                       bidder['name'],
//                                                       style: TextStyle(
//                                                         fontSize: width * 0.045,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     Text(
//                                                       'Status: ${bidder['status']}',
//                                                       style: TextStyle(
//                                                         fontSize: width * 0.035,
//                                                         color: Colors.grey,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     Text(
//                                                       bidder['address'],
//                                                       style: TextStyle(
//                                                         fontSize: width * 0.035,
//                                                         color: Colors.grey,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     Text(
//                                                       bidder['bid_amount'],
//                                                       style: TextStyle(
//                                                         fontSize: width * 0.035,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.green,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                             )
//                           else
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
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     Text(
//                                                       worker['amount'],
//                                                       style: TextStyle(
//                                                         fontSize: width * 0.035,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.green,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     Text(
//                                                       worker['location'],
//                                                       style: TextStyle(
//                                                         fontSize: width * 0.035,
//                                                         color: Colors.grey,
//                                                       ),
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
//                         ],
//                       ),
//                     ),
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
// class NegotiationCard extends StatefulWidget {
//   final double width;
//   final double height;
//   final String offerPrice;
//   final String bidAmount;
//   final Function(String) onNegotiate;
//   final Function() onAccept;
//
//   const NegotiationCard({
//     Key? key,
//     required this.width,
//     required this.height,
//     required this.offerPrice,
//     required this.bidAmount,
//     required this.onNegotiate,
//     required this.onAccept,
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
//   void initState() {
//     super.initState();
//     print(
//         '🖼️ NegotiationCard initialized with offerPrice: ${widget.offerPrice}');
//   }
//
//   @override
//   void didUpdateWidget(NegotiationCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.offerPrice != widget.offerPrice) {
//       print(
//           '🖼️ NegotiationCard updated with new offerPrice: ${widget.offerPrice}');
//     }
//   }
//
//   @override
//   void dispose() {
//     amountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(
//         '🖼️ NegotiationCard rebuilding with offerPrice: ${widget.offerPrice}');
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
//                   SizedBox(width: widget.width * 0.015),
//                   Expanded(
//                     child: Container(
//                       height: 45,
//                       padding:
//                           EdgeInsets.symmetric(vertical: widget.height * 0.0),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(widget.width * 0.02),
//                         border: Border.all(color: Colors.green),
//                         color: Colors.white,
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             "Offer Price",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontSize: widget.width * 0.04,
//                             ),
//                           ),
//                           Text(
//                             widget.offerPrice,
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontSize: widget.width * 0.04,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: widget.width * 0.015),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isNegotiating = !isNegotiating;
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                             vertical: widget.height * 0.015),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius:
//                               BorderRadius.circular(widget.width * 0.02),
//                           border: Border.all(color: Colors.green.shade700),
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
//               TextField(
//                 controller: amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Enter your offer Amount",
//                   hintStyle: GoogleFonts.roboto(
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.bold,
//                     fontSize: widget.width * 0.04,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(widget.width * 0.02),
//                   ),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                 ),
//                 style: GoogleFonts.roboto(
//                   color: Colors.green.shade700,
//                   fontWeight: FontWeight.bold,
//                   fontSize: widget.width * 0.04,
//                 ),
//               ),
//               SizedBox(height: widget.height * 0.02),
//               GestureDetector(
//                 onTap: () {
//                   String amount = amountController.text.trim();
//                   widget.onNegotiate(amount);
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
//                     "Send Request",
//                     style: GoogleFonts.roboto(
//                       color: Colors.white,
//                       fontSize: widget.width * 0.04,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//             SizedBox(height: widget.height * 0.02),
//             GestureDetector(
//               onTap: widget.onAccept,
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: widget.height * 0.018),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(widget.width * 0.02),
//                   color: Colors.green.shade700,
//                 ),
//                 child: Text(
//                   "Accept",
//                   style: GoogleFonts.roboto(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: widget.width * 0.04,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/directHiring/views/ServiceProvider/ServiceWorkerListScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widgets/AppColors.dart';
import '../Models/bidding_order.dart';
import 'BiddingWorkerDisputeScreen.dart';

class Biddingserviceproviderworkdetail extends StatefulWidget {
  final String orderId;
  final String hireStatus;

  const Biddingserviceproviderworkdetail({
    Key? key,
    required this.orderId,
    required this.hireStatus,
  }) : super(key: key);

  String get id => orderId; // Alias orderId

  @override
  _BiddingserviceproviderworkdetailState createState() =>
      _BiddingserviceproviderworkdetailState();
}

class _BiddingserviceproviderworkdetailState
    extends State<Biddingserviceproviderworkdetail> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> bidders = [];
  List<Map<String, dynamic>> relatedWorkers = [];
  BiddingOrder? biddingOrder;
  bool isLoading = true;
  String errorMessage = '';
  String? currentUserId;
  bool hasAlreadyBid = false;
  String? biddingOfferId;
  String? negotiationId;
  String offerPrice = '';

  @override
  void initState() {
    super.initState();
    fetchBiddingOrder().then((_) {
      if (biddingOrder != null && biddingOrder!.categoryId.isNotEmpty) {
        print('✅ Bidding Order Ready: ${biddingOrder!.title}');
        print('✅ Category ID: ${biddingOrder!.categoryId}');
        print('✅ Subcategory IDs: ${biddingOrder!.subcategoryIds}');
        setState(() {
          offerPrice = '₹${biddingOrder!.cost.toStringAsFixed(2)}';
        });
        if (widget.hireStatus.toLowerCase() == 'pending') {
          fetchRelatedWorkers();
          fetchBidders();
          fetchLatestNegotiation();
        }
        fetchCurrentUserId();
      } else {
        setState(() {
          errorMessage = 'Bidding order details ya category ID nahi mila.';
          isLoading = false;
        });
        print('❌ Bidding order ya category ID invalid hai');
      }
    });
  }

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
          print('📋 Offers: $offers');
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
                'bid_amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
                'offer_id': offer['_id'],
                'name': offer['provider_id']['full_name'] ?? 'Unknown',
                'status': offer['status'] ?? 'Pending',
                'address':
                    offer['provider_id']['location']['address'] ?? 'Unknown',
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
          'No token found. Please log in again.',
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
          'Please enter an amount',
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
        'service_provider': currentUserId,
        'user': biddingOrder!.userId,
        'initiator': 'service_provider',
        'offer_amount': offerAmount,
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] == 'Negotiation started') {
          setState(() {
            isLoading = false;
            negotiationId = jsonData['negotiation']['_id'];
            offerPrice = '₹${offerAmount?.toStringAsFixed(2)}';
            print('✅ Setting offerPrice in setState: $offerPrice');
          });
          print('✅ Negotiation started, negotiationId: $negotiationId');
          print('✅ Updated offerPrice: $offerPrice');
          Get.snackbar(
            'Success',
            'Negotiation request sent successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
          await fetchLatestNegotiation();
        } else {
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Failed to start negotiation',
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

  Future<void> acceptNegotiation() async {
    if (negotiationId == null) {
      Get.snackbar(
        'Error',
        'No negotiation found to accept.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      );
      return;
    }

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

      final payload = {
        'role': 'service_provider',
      };

      print('📤 Sending Accept Negotiation Payload: ${jsonEncode(payload)}');
      print('🔐 Using Token: $token');

      final response = await http.put(
        Uri.parse(
            'https://api.thebharatworks.com/api/negotiations/accept/$negotiationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Accept Negotiation Response Status: ${response.statusCode}');
      print('📥 Accept Negotiation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] == 'Negotiation accepted') {
          setState(() {
            isLoading = false;
            offerPrice =
                '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
            print('✅ Setting offerPrice in acceptNegotiation: $offerPrice');
          });
          Get.snackbar(
            'Success',
            'Negotiation accepted successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            duration: Duration(seconds: 3),
          );
          await fetchLatestNegotiation();
        } else {
          setState(() {
            isLoading = false;
          });
          Get.snackbar(
            'Error',
            jsonData['message'] ?? 'Failed to accept negotiation',
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

  Future<void> fetchLatestNegotiation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        print('❌ No token found for fetching latest negotiation');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/negotiations/latest/${widget.orderId}/${biddingOfferId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Latest Negotiation Response Status: ${response.statusCode}');
      print('📥 Latest Negotiation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] == 'Negotiation found') {
          setState(() {
            offerPrice =
                '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
            negotiationId = jsonData['negotiation']['_id'];
            print(
                '✅ Setting offerPrice in fetchLatestNegotiation: $offerPrice');
          });
          print('✅ Latest offerPrice: $offerPrice');
          print('✅ Latest negotiationId: $negotiationId');
        } else {
          print(
              '⚠️ No negotiation found or unexpected message: ${jsonData['message']}');
        }
      } else {
        print('⚠️ Failed to fetch latest negotiation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Fetch Latest Negotiation Error: $e');
    }
  }

  String getCurrentUserBidAmount() {
    if (bidders.isNotEmpty) {
      for (var bidder in bidders) {
        if (bidder['offer_id'] == biddingOfferId) {
          return bidder['bid_amount'];
        }
      }
      return bidders[0]['bid_amount'];
    }
    return biddingOrder != null
        ? '₹${biddingOrder!.cost.toStringAsFixed(2)}'
        : '₹0.00';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    print(
        '🛠️ Building Biddingserviceproviderworkdetail with offerPrice: $offerPrice, hireStatus: ${widget.hireStatus}');

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

    bool isAccepted = widget.hireStatus.toLowerCase() == 'accepted';
    bool isPending = widget.hireStatus.toLowerCase() == 'pending';

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
                        Flexible(
                          child: Container(
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
                              overflow: TextOverflow
                                  .ellipsis, // Optional: truncate text with "..."
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
                    // Awarded amount card - only shown when hireStatus is 'accepted'
                    if (isAccepted)
                      Card(
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: biddingOrder?.userId?.profilePic != null
                                    ? Image.network(
                                        biddingOrder!.userId!.profilePic!,
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/account1.png',
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/account1.png',
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          biddingOrder?.userId?.fullName ??
                                              'Unknown',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.withOpacity(0.1),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.call,
                                              color: Colors.green.shade700,
                                              size: 14,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          'Awarded amount - ₹${biddingOrder?.cost.toStringAsFixed(0) ?? '0'}/-',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.withOpacity(0.1),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.message_rounded,
                                              color: Colors.green.shade700,
                                              size: 14,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isAccepted) ...[
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ServiceWorkerListScreen(
                                      orderId: widget.id)));
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade700),
                          ),
                          child: Center(
                            child: Text(
                              'Assign to another person',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (isAccepted) ...[
                        SizedBox(height: 20),
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Payment Details',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(thickness: 0.8),
                                const SizedBox(height: 10),
                                // Text("No Payment history found"),
                                if (biddingOrder!.servicePayment != null &&
                                    biddingOrder!.servicePayment![
                                            'payment_history'] !=
                                        null &&
                                    biddingOrder!
                                        .servicePayment!['payment_history']
                                        .isNotEmpty)
                                  ...List.generate(
                                    biddingOrder!
                                        .servicePayment!['payment_history']
                                        .length,
                                    (index) {
                                      final item =
                                          biddingOrder!.servicePayment![
                                              'payment_history'][index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
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
                                                  flex: 2,
                                                  child: Text(
                                                    "${index + 1}. ${item['description'] ?? 'No Description'}",
                                                    style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 3,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          "${item['status'] == 'success' ? 'Paid' : item['status'] == 'pending' ? 'Pending' : 'Failed'}",
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: item['status'] ==
                                                                    'success'
                                                                ? Colors.green
                                                                : item['status'] ==
                                                                        'pending'
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors
                                                                        .red,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Flexible(
                                                        child: Text(
                                                          "₹${item['amount']}",
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 40),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 40, bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.yellow.shade100,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  'Warning Message',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Lorem ipsum dolor sit amet consectetur.',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -30,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Image.asset(
                                  'assets/images/warning.png',
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isPending) ...[
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
                                                      decoration:
                                                          InputDecoration(
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
                                                      decoration:
                                                          InputDecoration(
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
                                                      decoration:
                                                          InputDecoration(
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
                                                          Navigator.pop(
                                                              context);
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
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  width * 0.04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                      NegotiationCard(
                        key: ValueKey(offerPrice),
                        width: width,
                        height: height,
                        offerPrice: offerPrice,
                        bidAmount: getCurrentUserBidAmount(),
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
                        onAccept: () {
                          if (hasAlreadyBid && biddingOfferId != null) {
                            acceptNegotiation();
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        bidder['name'],
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.045,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                      Text(
                                                        'Status: ${bidder['status']}',
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                      Text(
                                                        bidder['address'],
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                      Text(
                                                        bidder['bid_amount'],
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.green,
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
                                                              worker['name'],
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
                                                                "${worker['rating']}",
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
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                      Text(
                                                        worker['amount'],
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                      Text(
                                                        worker['location'],
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
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
                    // Cancel Task button - only shown when hireStatus is 'accepted'
                    if (isAccepted) ...[
                      SizedBox(height: height * 0.02),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BiddingWorkerDisputeScreen(
                                // orderId: widget.id,
                                orderId: widget.orderId,
                                flowType: "bidding",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              'Cancel Task and create dispute',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class NegotiationCard extends StatefulWidget {
  final double width;
  final double height;
  final String offerPrice;
  final String bidAmount;
  final Function(String) onNegotiate;
  final Function() onAccept;

  const NegotiationCard({
    Key? key,
    required this.width,
    required this.height,
    required this.offerPrice,
    required this.bidAmount,
    required this.onNegotiate,
    required this.onAccept,
  }) : super(key: key);

  @override
  _NegotiationCardState createState() => _NegotiationCardState();
}

class _NegotiationCardState extends State<NegotiationCard> {
  bool isNegotiating = false;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(
        '🖼️ NegotiationCard initialized with offerPrice: ${widget.offerPrice}');
  }

  @override
  void didUpdateWidget(NegotiationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerPrice != widget.offerPrice) {
      print(
          '🖼️ NegotiationCard updated with new offerPrice: ${widget.offerPrice}');
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        '🖼️ NegotiationCard rebuilding with offerPrice: ${widget.offerPrice}');
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
                  SizedBox(width: widget.width * 0.015),
                  Expanded(
                    child: Container(
                      height: 45,
                      padding:
                          EdgeInsets.symmetric(vertical: widget.height * 0.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.width * 0.02),
                        border: Border.all(color: Colors.green),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Offer Price",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: widget.width * 0.04,
                            ),
                          ),
                          Text(
                            widget.offerPrice,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: widget.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: widget.width * 0.015),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isNegotiating = !isNegotiating;
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
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter your offer Amount",
                  hintStyle: GoogleFonts.roboto(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.width * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.width * 0.02),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                style: GoogleFonts.roboto(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.width * 0.04,
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
            ],
            SizedBox(height: widget.height * 0.02),
            GestureDetector(
              onTap: widget.onAccept,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: widget.height * 0.018),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.width * 0.02),
                  color: Colors.green.shade700,
                ),
                child: Text(
                  "Accept",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: widget.width * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// import 'dart:convert';
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:developer/directHiring/views/ServiceProvider/ServiceWorkerListScreen.dart';
// import 'package:developer/directHiring/views/ServiceProvider/WorkerListViewProfileScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
// import '../Models/bidding_order.dart';
// import 'BiddingWorkerDisputeScreen.dart';
//
// class Biddingserviceproviderworkdetail extends StatefulWidget {
//   final String orderId;
//   final String hireStatus;
//
//   const Biddingserviceproviderworkdetail({
//     Key? key,
//     required this.orderId,
//     required this.hireStatus,
//   }) : super(key: key);
//
//   String get id => orderId;
//
//   @override
//   _BiddingserviceproviderworkdetailState createState() =>
//       _BiddingserviceproviderworkdetailState();
// }
//
// class _BiddingserviceproviderworkdetailState
//     extends State<Biddingserviceproviderworkdetail> {
//   int _selectedIndex = 0;
//   List<Map<String, dynamic>> bidders = [];
//   List<Map<String, dynamic>> relatedWorkers = [];
//   BiddingOrder? biddingOrder;
//   AssignedWorker? tempAssignedWorker; // Temporary storage for assigned worker
//   bool isLoading = true;
//   String errorMessage = '';
//   String? currentUserId;
//   bool hasAlreadyBid = false;
//   String? biddingOfferId;
//   String? negotiationId;
//   String offerPrice = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBiddingOrder().then((_) {
//       if (biddingOrder != null && biddingOrder!.categoryId.isNotEmpty) {
//         print('✅ Bidding Order Ready: ${biddingOrder!.title}');
//         print('✅ Category ID: ${biddingOrder!.categoryId}');
//         print('✅ Subcategory IDs: ${biddingOrder!.subcategoryIds}');
//         print('👷 Assigned Worker: ${biddingOrder!.assignedWorker?.name}');
//         setState(() {
//           offerPrice = '₹${biddingOrder!.cost.toStringAsFixed(2)}';
//         });
//         if (widget.hireStatus.toLowerCase() == 'pending') {
//           fetchRelatedWorkers();
//           fetchBidders();
//           fetchLatestNegotiation();
//         }
//         fetchCurrentUserId();
//       } else {
//         setState(() {
//           errorMessage = 'Bidding order details ya category ID nahi mila.';
//           isLoading = false;
//         });
//         print('❌ Bidding order ya category ID invalid hai');
//       }
//     });
//   }
//
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
//   // Future<void> fetchBiddingOrder() async {
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('token') ?? '';
//   //     if (token.isEmpty) {
//   //       setState(() {
//   //         errorMessage = 'Koi token nahi mila. Phir se login karo.';
//   //         isLoading = false;
//   //       });
//   //       print('❌ Token nahi mila SharedPreferences mein');
//   //       return;
//   //     }
//   //     print('🔐 Token: $token');
//   //
//   //     final response = await http.get(
//   //       Uri.parse(
//   //           'https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.orderId}'),
//   //       headers: {
//   //         'Authorization': 'Bearer $token',
//   //         'Content-Type': 'application/json',
//   //       },
//   //     );
//   //
//   //     print('📥 Response Status: ${response.statusCode}');
//   //     print('📥 Response Body: ${response.body}');
//   //
//   //     if (response.statusCode == 200) {
//   //       final jsonData = jsonDecode(response.body);
//   //       if (jsonData['status'] == true) {
//   //         setState(() {
//   //           biddingOrder = BiddingOrder.fromJson(jsonData['data']);
//   //           isLoading = false;
//   //         });
//   //         print('✅ Bidding Order: ${biddingOrder!.title}');
//   //         print('✅ Image URLs: ${biddingOrder!.imageUrls}');
//   //         print('👤 Order Owner ID: ${biddingOrder!.userId}');
//   //         print('👷 Assigned Worker: ${biddingOrder!.assignedWorker?.name}');
//   //       } else {
//   //         setState(() {
//   //           errorMessage = jsonData['message'] ?? 'Data fetch nahi hua';
//   //           isLoading = false;
//   //         });
//   //       }
//   //     } else if (response.statusCode == 401) {
//   //       setState(() {
//   //         errorMessage = 'Unauthorized: Phir se login karo.';
//   //         isLoading = false;
//   //       });
//   //     } else {
//   //       setState(() {
//   //         errorMessage = 'Error: ${response.statusCode}';
//   //         isLoading = false;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print('❌ API Error: $e');
//   //     setState(() {
//   //       errorMessage = 'Error: $e';
//   //       isLoading = false;
//   //     });
//   //   }
//   // }
//
//   Future<void> fetchBiddingOrder() async {
//     try {
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
//       final response = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
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
//           List<dynamic> orders = jsonData['data'];
//           // Find the order matching widget.orderId
//           final orderData = orders.firstWhere(
//             (order) => order['_id'] == widget.orderId,
//             orElse: () => null,
//           );
//
//           if (orderData != null) {
//             setState(() {
//               biddingOrder = BiddingOrder.fromJson(orderData);
//               isLoading = false;
//               // Update offerPrice with the latest payment amount if available
//               if (biddingOrder!.servicePayment != null &&
//                   biddingOrder!.servicePayment!['payment_history'] != null &&
//                   biddingOrder!.servicePayment!['payment_history'].isNotEmpty) {
//                 offerPrice =
//                     '₹${biddingOrder!.servicePayment!['payment_history'].last['amount'].toStringAsFixed(2)}';
//               } else {
//                 offerPrice = '₹${biddingOrder!.cost.toStringAsFixed(2)}';
//               }
//             });
//             print('✅ Bidding Order: ${biddingOrder!.title}');
//             print('✅ Image URLs: ${biddingOrder!.imageUrls}');
//             print('👤 Order Owner ID: ${biddingOrder!.userId?.id}');
//             print('👷 Assigned Worker: ${biddingOrder!.assignedWorker?.name}');
//             print(
//                 '💳 Payment History: ${biddingOrder!.servicePayment?['payment_history']}');
//           } else {
//             setState(() {
//               errorMessage = 'Order with ID ${widget.orderId} not found.';
//               isLoading = false;
//             });
//             print('❌ Order not found for ID: ${widget.orderId}');
//           }
//         } else {
//           setState(() {
//             errorMessage = jsonData['message'] ?? 'Data fetch nahi hua';
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
//       print('❌ API Error: $e');
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   // Store assigned worker details temporarily
//   void storeAssignedWorker(Map<String, dynamic> workerData) {
//     setState(() {
//       tempAssignedWorker = AssignedWorker.fromJson(workerData);
//     });
//     print('✅ Stored Temp Assigned Worker: ${tempAssignedWorker!.name}');
//   }
//
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
//           print('📋 Offers: $offers');
//           setState(() {
//             bidders = offers.map((offer) {
//               print(
//                   '🔍 Checking offer for provider: ${offer['provider_id']['_id']}');
//               if (offer['provider_id']['_id'] == currentUserId) {
//                 biddingOfferId = offer['_id'];
//                 hasAlreadyBid = true;
//                 print('✅ Found biddingOfferId: $biddingOfferId');
//               }
//               return {
//                 'bid_amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
//                 'offer_id': offer['_id'],
//                 'name': offer['provider_id']['full_name'] ?? 'Unknown',
//                 'status': offer['status'] ?? 'Pending',
//                 'address':
//                     offer['provider_id']['location']['address'] ?? 'Unknown',
//               };
//             }).toList();
//             isLoading = false;
//           });
//           print('✅ Bidders fetched: ${bidders.length}');
//           print('✅ biddingOfferId: $biddingOfferId');
//           print('✅ hasAlreadyBid: $hasAlreadyBid');
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
//                 'provider_id': provider['_id'],
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
//   Future<void> fetchLatestNegotiation() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         print('❌ No token found for fetching latest negotiation');
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/negotiations/latest/${widget.orderId}/$biddingOfferId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('📥 Latest Negotiation Response Status: ${response.statusCode}');
//       print('📥 Latest Negotiation Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['message'] == 'Negotiation found') {
//           setState(() {
//             offerPrice =
//                 '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
//             negotiationId = jsonData['negotiation']['_id'];
//             print(
//                 '✅ Setting offerPrice in fetchLatestNegotiation: $offerPrice');
//           });
//           print('✅ Latest offerPrice: $offerPrice');
//           print('✅ Latest negotiationId: $negotiationId');
//         } else {
//           print(
//               '⚠️ No negotiation found or unexpected message: ${jsonData['message']}');
//         }
//       } else {
//         print('⚠️ Failed to fetch latest negotiation: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Fetch Latest Negotiation Error: $e');
//     }
//   }
//
//   String getCurrentUserBidAmount() {
//     if (bidders.isNotEmpty) {
//       for (var bidder in bidders) {
//         if (bidder['offer_id'] == biddingOfferId) {
//           return bidder['bid_amount'];
//         }
//       }
//       return bidders[0]['bid_amount'];
//     }
//     return biddingOrder != null
//         ? '₹${biddingOrder!.cost.toStringAsFixed(2)}'
//         : '₹0.00';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     print(
//         '🛠️ Building Biddingserviceproviderworkdetail with offerPrice: $offerPrice, hireStatus: ${widget.hireStatus}, assignedWorker: ${biddingOrder?.assignedWorker?.name ?? tempAssignedWorker?.name}');
//
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
//     bool isAccepted = widget.hireStatus.toLowerCase() == 'accepted';
//     bool isPending = widget.hireStatus.toLowerCase() == 'pending';
//     bool hasAssignedWorker =
//         biddingOrder!.assignedWorker != null || tempAssignedWorker != null;
//
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
//                     hasAssignedWorker ? "Worker Details" : "Work detail",
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
//                         Flexible(
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: width * 0.06,
//                               vertical: height * 0.005,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade300,
//                               borderRadius: BorderRadius.circular(width * 0.03),
//                             ),
//                             child: Text(
//                               biddingOrder!.address,
//                               style: GoogleFonts.roboto(
//                                 color: Colors.white,
//                                 fontSize: width * 0.03,
//                               ),
//                               overflow: TextOverflow.ellipsis,
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
//                     if (isAccepted)
//                       Card(
//                         child: Container(
//                           height: 100,
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(horizontal: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                           ),
//                           child: Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(50),
//                                 child: biddingOrder?.userId?.profilePic != null
//                                     ? Image.network(
//                                         biddingOrder!.userId!.profilePic!,
//                                         height: 70,
//                                         width: 70,
//                                         fit: BoxFit.cover,
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                           return Image.asset(
//                                             'assets/images/account1.png',
//                                             height: 70,
//                                             width: 70,
//                                             fit: BoxFit.cover,
//                                           );
//                                         },
//                                       )
//                                     : Image.asset(
//                                         'assets/images/account1.png',
//                                         height: 70,
//                                         width: 70,
//                                         fit: BoxFit.cover,
//                                       ),
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           biddingOrder?.userId?.fullName ??
//                                               'Unknown',
//                                           style: GoogleFonts.roboto(
//                                             fontSize: 12,
//                                             color: Colors.black,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         Spacer(),
//                                         Container(
//                                           height: 30,
//                                           width: 30,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.grey.withOpacity(0.1),
//                                           ),
//                                           child: IconButton(
//                                             icon: Icon(
//                                               Icons.call,
//                                               color: Colors.green.shade700,
//                                               size: 14,
//                                             ),
//                                             onPressed: () {},
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 5),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           'Awarded amount - ₹${biddingOrder?.cost.toStringAsFixed(0) ?? '0'}/-',
//                                           style: GoogleFonts.roboto(
//                                             fontSize: 12,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                         Spacer(),
//                                         Container(
//                                           height: 30,
//                                           width: 30,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.grey.withOpacity(0.1),
//                                           ),
//                                           child: IconButton(
//                                             icon: Icon(
//                                               Icons.message_rounded,
//                                               color: Colors.green.shade700,
//                                               size: 14,
//                                             ),
//                                             onPressed: () {},
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     if (isAccepted && hasAssignedWorker) ...[
//                       SizedBox(height: 20),
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(color: Colors.white),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Assigned Person",
//                               style: GoogleFonts.roboto(
//                                 color: Colors.black,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 50,
//                                   backgroundImage: (biddingOrder!
//                                                   .assignedWorker?.image ??
//                                               tempAssignedWorker?.image) !=
//                                           null
//                                       ? NetworkImage(
//                                           biddingOrder!.assignedWorker?.image ??
//                                               tempAssignedWorker!.image!)
//                                       : AssetImage('assets/profile_pic.jpg')
//                                           as ImageProvider,
//                                   onBackgroundImageError:
//                                       (exception, stackTrace) {
//                                     print(
//                                         "📸 Assigned Worker Image Error: $exception");
//                                   },
//                                 ),
//                                 SizedBox(width: 30),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         biddingOrder!.assignedWorker?.name ??
//                                             tempAssignedWorker?.name ??
//                                             'Unknown',
//                                         style: GoogleFonts.roboto(
//                                           color: Colors.black,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         biddingOrder!.assignedWorker?.address ??
//                                             tempAssignedWorker?.address ??
//                                             'No Address',
//                                         style: TextStyle(
//                                           color: Colors.grey,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       SizedBox(height: 5),
//                                       GestureDetector(
//                                         onTap: () {
//                                           final workerId = biddingOrder!
//                                                   .assignedWorker?.id ??
//                                               tempAssignedWorker?.id;
//                                           if (workerId != null &&
//                                               workerId.isNotEmpty) {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     WorkerListViewProfileScreen(
//                                                   workerId: workerId,
//                                                 ),
//                                               ),
//                                             );
//                                           } else {
//                                             print(
//                                                 "❌ Assigned worker ID not found");
//                                             Get.snackbar(
//                                               'Error',
//                                               'Worker data missing!',
//                                               snackPosition:
//                                                   SnackPosition.BOTTOM,
//                                               backgroundColor: Colors.red,
//                                               colorText: Colors.white,
//                                               margin: EdgeInsets.all(10),
//                                               duration: Duration(seconds: 3),
//                                             );
//                                           }
//                                         },
//                                         child: Container(
//                                           height: 30,
//                                           width: 100,
//                                           decoration: BoxDecoration(
//                                             color: Colors.green.shade700,
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               'View profile',
//                                               style: GoogleFonts.roboto(
//                                                 color: Colors.white,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 10),
//                           ],
//                         ),
//                       ),
//                     ],
//                     if (isAccepted && !hasAssignedWorker) ...[
//                       SizedBox(height: 20),
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ServiceWorkerListScreen(
//                                 orderId: widget.id,
//                               ),
//                             ),
//                           ).then((result) {
//                             if (result != null &&
//                                 result is Map<String, dynamic>) {
//                               storeAssignedWorker(result);
//                             }
//                             fetchBiddingOrder(); // Refresh order details
//                           });
//                         },
//                         child: Container(
//                           height: 50,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: Colors.green.shade700),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Assign to another person',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 14,
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                     // if (isAccepted) ...[
//                     //   SizedBox(height: 20),
//                     //   Card(
//                     //     elevation: 6,
//                     //     shape: RoundedRectangleBorder(
//                     //       borderRadius: BorderRadius.circular(14),
//                     //     ),
//                     //     child: Container(
//                     //       padding: const EdgeInsets.all(16),
//                     //       width: double.infinity,
//                     //       decoration: BoxDecoration(
//                     //         borderRadius: BorderRadius.circular(14),
//                     //         color: Colors.white,
//                     //       ),
//                     //       child: Column(
//                     //         crossAxisAlignment: CrossAxisAlignment.start,
//                     //         children: [
//                     //           Center(
//                     //             child: Text(
//                     //               'Payment',
//                     //               style: GoogleFonts.roboto(
//                     //                 fontSize: 16,
//                     //                 fontWeight: FontWeight.w600,
//                     //                 color: Colors.black,
//                     //               ),
//                     //             ),
//                     //           ),
//                     //           const SizedBox(height: 10),
//                     //           const Divider(thickness: 0.8),
//                     //           const SizedBox(height: 10),
//                     //           if (biddingOrder!.servicePayment != null &&
//                     //               biddingOrder!
//                     //                       .servicePayment!['payment_history'] !=
//                     //                   null &&
//                     //               biddingOrder!
//                     //                   .servicePayment!['payment_history']
//                     //                   .isNotEmpty)
//                     //             ...List.generate(
//                     //               biddingOrder!
//                     //                   .servicePayment!['payment_history']
//                     //                   .length,
//                     //               (index) {
//                     //                 final item = biddingOrder!
//                     //                         .servicePayment!['payment_history']
//                     //                     [index];
//                     //                 return Padding(
//                     //                   padding:
//                     //                       const EdgeInsets.only(bottom: 10),
//                     //                   child: Row(
//                     //                     mainAxisAlignment:
//                     //                         MainAxisAlignment.spaceBetween,
//                     //                     children: [
//                     //                       Flexible(
//                     //                         flex: 2,
//                     //                         child: Text(
//                     //                           "${index + 1}. ${item['description'] ?? 'No Description'}",
//                     //                           style: GoogleFonts.roboto(
//                     //                             fontWeight: FontWeight.bold,
//                     //                           ),
//                     //                           overflow: TextOverflow.ellipsis,
//                     //                           maxLines: 1,
//                     //                         ),
//                     //                       ),
//                     //                       Flexible(
//                     //                         flex: 3,
//                     //                         child: Row(
//                     //                           mainAxisSize: MainAxisSize.min,
//                     //                           children: [
//                     //                             Flexible(
//                     //                               child: Text(
//                     //                                 "${item['status'] == 'paid' ? 'Paid' : 'Pending'}",
//                     //                                 style: GoogleFonts.roboto(
//                     //                                   color: item['status'] ==
//                     //                                           'paid'
//                     //                                       ? Colors.green
//                     //                                       : Colors.red,
//                     //                                   fontSize: 12,
//                     //                                   fontWeight:
//                     //                                       FontWeight.w500,
//                     //                                 ),
//                     //                                 overflow:
//                     //                                     TextOverflow.ellipsis,
//                     //                                 maxLines: 1,
//                     //                               ),
//                     //                             ),
//                     //                             const SizedBox(width: 10),
//                     //                             Flexible(
//                     //                               child: Text(
//                     //                                 "₹${item['amount']}",
//                     //                                 style: GoogleFonts.roboto(
//                     //                                   fontWeight:
//                     //                                       FontWeight.w500,
//                     //                                 ),
//                     //                                 overflow:
//                     //                                     TextOverflow.ellipsis,
//                     //                                 maxLines: 1,
//                     //                               ),
//                     //                             ),
//                     //                           ],
//                     //                         ),
//                     //                       ),
//                     //                     ],
//                     //                   ),
//                     //                 );
//                     //               },
//                     //             )
//                     //           else
//                     //             Text(
//                     //               'No payment history found.',
//                     //               style: GoogleFonts.roboto(fontSize: 14),
//                     //             ),
//                     //         ],
//                     //       ),
//                     //     ),
//                     //   ),
//                     //   SizedBox(height: 40),
//                     //   Stack(
//                     //     clipBehavior: Clip.none,
//                     //     children: [
//                     //       Container(
//                     //         width: double.infinity,
//                     //         padding: const EdgeInsets.only(top: 40, bottom: 16),
//                     //         decoration: BoxDecoration(
//                     //           borderRadius: BorderRadius.circular(14),
//                     //           color: Colors.yellow.shade100,
//                     //         ),
//                     //         child: Column(
//                     //           children: [
//                     //             const SizedBox(height: 10),
//                     //             Text(
//                     //               'Warning Message',
//                     //               style: GoogleFonts.roboto(
//                     //                 fontSize: 14,
//                     //                 color: Colors.red,
//                     //                 fontWeight: FontWeight.w600,
//                     //               ),
//                     //             ),
//                     //             const SizedBox(height: 8),
//                     //             Text(
//                     //               'Lorem ipsum dolor sit amet consectetur.',
//                     //               style: GoogleFonts.roboto(
//                     //                 fontSize: 14,
//                     //                 color: Colors.black87,
//                     //                 fontWeight: FontWeight.w500,
//                     //               ),
//                     //             ),
//                     //           ],
//                     //         ),
//                     //       ),
//                     //       Positioned(
//                     //         top: -30,
//                     //         left: 0,
//                     //         right: 0,
//                     //         child: Center(
//                     //           child: Container(
//                     //             padding: const EdgeInsets.all(6),
//                     //             decoration: BoxDecoration(
//                     //               borderRadius: BorderRadius.circular(12),
//                     //               color: Colors.white,
//                     //             ),
//                     //             child: Image.asset(
//                     //               'assets/images/warning.png',
//                     //               height: 70,
//                     //               width: 70,
//                     //               fit: BoxFit.contain,
//                     //             ),
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ],
//                     if (isAccepted) ...[
//                       SizedBox(height: 20),
//                       Card(
//                         elevation: 6,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.all(16),
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(14),
//                             color: Colors.white,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Center(
//                                 child: Text(
//                                   'Payment Details',
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               const Divider(thickness: 0.8),
//                               const SizedBox(height: 10),
//                               // Text("No Payment history found"),
//                               if (biddingOrder!.servicePayment != null &&
//                                   biddingOrder!
//                                           .servicePayment!['payment_history'] !=
//                                       null &&
//                                   biddingOrder!
//                                       .servicePayment!['payment_history']
//                                       .isNotEmpty)
//                                 ...List.generate(
//                                   biddingOrder!
//                                       .servicePayment!['payment_history']
//                                       .length,
//                                   (index) {
//                                     final item = biddingOrder!
//                                             .servicePayment!['payment_history']
//                                         [index];
//                                     return Padding(
//                                       padding:
//                                           const EdgeInsets.only(bottom: 10),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Flexible(
//                                                 flex: 2,
//                                                 child: Text(
//                                                   "${index + 1}. ${item['description'] ?? 'No Description'}",
//                                                   style: GoogleFonts.roboto(
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   maxLines: 1,
//                                                 ),
//                                               ),
//                                               Flexible(
//                                                 flex: 3,
//                                                 child: Row(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     Flexible(
//                                                       child: Text(
//                                                         "${item['status'] == 'success' ? 'Paid' : item['status'] == 'pending' ? 'Pending' : 'Failed'}",
//                                                         style:
//                                                             GoogleFonts.roboto(
//                                                           color: item['status'] ==
//                                                                   'success'
//                                                               ? Colors.green
//                                                               : item['status'] ==
//                                                                       'pending'
//                                                                   ? Colors
//                                                                       .orange
//                                                                   : Colors.red,
//                                                           fontSize: 12,
//                                                           fontWeight:
//                                                               FontWeight.w500,
//                                                         ),
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         maxLines: 1,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 10),
//                                                     Flexible(
//                                                       child: Text(
//                                                         "₹${item['amount']}",
//                                                         style:
//                                                             GoogleFonts.roboto(
//                                                           fontWeight:
//                                                               FontWeight.w500,
//                                                         ),
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         maxLines: 1,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                     if (isPending) ...[
//                       SizedBox(height: height * 0.02),
//                       Center(
//                         child: GestureDetector(
//                           onTap: biddingOrder!.userId?.id == currentUserId
//                               ? () {
//                                   Get.snackbar(
//                                     'Error',
//                                     'You cannot bid on your own order',
//                                     snackPosition: SnackPosition.BOTTOM,
//                                     backgroundColor: Colors.red,
//                                     colorText: Colors.white,
//                                     margin: EdgeInsets.all(10),
//                                     duration: Duration(seconds: 3),
//                                   );
//                                 }
//                               : hasAlreadyBid
//                                   ? () {
//                                       Get.snackbar(
//                                         'Error',
//                                         'You have already placed a bid on this order',
//                                         snackPosition: SnackPosition.BOTTOM,
//                                         backgroundColor: Colors.red,
//                                         colorText: Colors.white,
//                                         margin: EdgeInsets.all(10),
//                                         duration: Duration(seconds: 3),
//                                       );
//                                     }
//                                   : () {
//                                       showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           final TextEditingController
//                                               amountController =
//                                               TextEditingController();
//                                           final TextEditingController
//                                               descriptionController =
//                                               TextEditingController();
//                                           final TextEditingController
//                                               durationController =
//                                               TextEditingController();
//                                           return AlertDialog(
//                                             backgroundColor: Colors.white,
//                                             insetPadding: EdgeInsets.symmetric(
//                                                 horizontal: width * 0.05),
//                                             title: Center(
//                                               child: Text(
//                                                 "Bid",
//                                                 style: GoogleFonts.roboto(
//                                                   fontSize: width * 0.05,
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             content: SingleChildScrollView(
//                                               child: SizedBox(
//                                                 width: width * 0.8,
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       "Enter Amount",
//                                                       style: GoogleFonts.roboto(
//                                                         fontSize: width * 0.035,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     TextField(
//                                                       controller:
//                                                           amountController,
//                                                       keyboardType:
//                                                           TextInputType.number,
//                                                       decoration:
//                                                           InputDecoration(
//                                                         hintText: "₹0.00",
//                                                         border:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       width *
//                                                                           0.02),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.01),
//                                                     Text(
//                                                       "Description",
//                                                       style: GoogleFonts.roboto(
//                                                         fontSize: width * 0.035,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     TextField(
//                                                       controller:
//                                                           descriptionController,
//                                                       maxLines: 3,
//                                                       decoration:
//                                                           InputDecoration(
//                                                         hintText:
//                                                             "Enter Description",
//                                                         border:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       width *
//                                                                           0.02),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.01),
//                                                     Text(
//                                                       "Duration",
//                                                       style: GoogleFonts.roboto(
//                                                         fontSize: width * 0.035,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.005),
//                                                     TextField(
//                                                       controller:
//                                                           durationController,
//                                                       keyboardType:
//                                                           TextInputType.number,
//                                                       decoration:
//                                                           InputDecoration(
//                                                         hintText:
//                                                             "Enter Duration (in days)",
//                                                         border:
//                                                             OutlineInputBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       width *
//                                                                           0.02),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                         height: height * 0.015),
//                                                     Center(
//                                                       child: GestureDetector(
//                                                         onTap: () {
//                                                           String amount =
//                                                               amountController
//                                                                   .text
//                                                                   .trim();
//                                                           String description =
//                                                               descriptionController
//                                                                   .text
//                                                                   .trim();
//                                                           String duration =
//                                                               durationController
//                                                                   .text
//                                                                   .trim();
//                                                           submitBid(
//                                                               amount,
//                                                               description,
//                                                               duration);
//                                                           Navigator.pop(
//                                                               context);
//                                                         },
//                                                         child: Container(
//                                                           padding: EdgeInsets
//                                                               .symmetric(
//                                                             horizontal:
//                                                                 width * 0.18,
//                                                             vertical:
//                                                                 height * 0.012,
//                                                           ),
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             color: Colors
//                                                                 .green.shade700,
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         width *
//                                                                             0.02),
//                                                           ),
//                                                           child: Text(
//                                                             "Bid",
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize:
//                                                                   width * 0.04,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       );
//                                     },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: width * 0.18,
//                               vertical: height * 0.012,
//                             ),
//                             decoration: BoxDecoration(
//                               color:
//                                   biddingOrder!.userId?.id == currentUserId ||
//                                           hasAlreadyBid
//                                       ? Colors.grey.shade400
//                                       : Colors.green.shade700,
//                               borderRadius: BorderRadius.circular(width * 0.02),
//                             ),
//                             child: Text(
//                               "Bid",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: width * 0.04,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: height * 0.02),
//                       NegotiationCard(
//                         key: ValueKey(offerPrice),
//                         width: width,
//                         height: height,
//                         offerPrice: offerPrice,
//                         bidAmount: getCurrentUserBidAmount(),
//                         onNegotiate: (amount) {
//                           if (hasAlreadyBid && biddingOfferId != null) {
//                             startNegotiation(amount);
//                           } else {
//                             Get.snackbar(
//                               'Error',
//                               'Please place a bid first.',
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.red,
//                               colorText: Colors.white,
//                               margin: EdgeInsets.all(10),
//                               duration: Duration(seconds: 3),
//                             );
//                           }
//                         },
//                         onAccept: () {
//                           if (hasAlreadyBid && biddingOfferId != null) {
//                             acceptNegotiation();
//                           } else {
//                             Get.snackbar(
//                               'Error',
//                               'Please place a bid first.',
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.red,
//                               colorText: Colors.white,
//                               margin: EdgeInsets.all(10),
//                               duration: Duration(seconds: 3),
//                             );
//                           }
//                         },
//                       ),
//                       SizedBox(height: height * 0.02),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: width * 0.05),
//                         child: Column(
//                           children: [
//                             SizedBox(height: height * 0.015),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       _selectedIndex = 0;
//                                     });
//                                   },
//                                   child: Container(
//                                     height: height * 0.045,
//                                     width: width * 0.40,
//                                     decoration: BoxDecoration(
//                                       color: _selectedIndex == 0
//                                           ? Colors.green.shade700
//                                           : Colors.grey.shade300,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Center(
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(width: width * 0.02),
//                                           Text(
//                                             "Bidders",
//                                             style: TextStyle(
//                                               color: _selectedIndex == 0
//                                                   ? Colors.white
//                                                   : Colors.grey.shade700,
//                                               fontSize: width * 0.05,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: width * 0.0),
//                                 InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       _selectedIndex = 1;
//                                     });
//                                   },
//                                   child: Container(
//                                     height: height * 0.045,
//                                     width: width * 0.40,
//                                     decoration: BoxDecoration(
//                                       color: _selectedIndex == 1
//                                           ? Colors.green.shade700
//                                           : Colors.grey.shade300,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Center(
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(width: width * 0.02),
//                                           Text(
//                                             "Related Worker",
//                                             style: TextStyle(
//                                               color: _selectedIndex == 1
//                                                   ? Colors.white
//                                                   : Colors.grey.shade700,
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
//                             if (_selectedIndex == 0)
//                               Padding(
//                                 padding: EdgeInsets.only(top: height * 0.01),
//                                 child: bidders.isEmpty
//                                     ? Center(
//                                         child: Text(
//                                           'No bidders found',
//                                           style: TextStyle(
//                                             fontSize: width * 0.04,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       )
//                                     : ListView.builder(
//                                         shrinkWrap: true,
//                                         physics:
//                                             const NeverScrollableScrollPhysics(),
//                                         itemCount: bidders.length,
//                                         itemBuilder: (context, index) {
//                                           final bidder = bidders[index];
//                                           return Container(
//                                             margin: EdgeInsets.symmetric(
//                                               vertical: height * 0.01,
//                                               horizontal: width * 0.01,
//                                             ),
//                                             padding:
//                                                 EdgeInsets.all(width * 0.02),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                   spreadRadius: 1,
//                                                   blurRadius: 5,
//                                                   offset: const Offset(0, 3),
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                   child: Image.asset(
//                                                     "assets/images/account1.png",
//                                                     height: 90,
//                                                     width: 90,
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: width * 0.03),
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         bidder['name'],
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               width * 0.045,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                           height:
//                                                               height * 0.005),
//                                                       Text(
//                                                         'Status: ${bidder['status']}',
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               width * 0.035,
//                                                           color: Colors.grey,
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                           height:
//                                                               height * 0.005),
//                                                       Text(
//                                                         bidder['address'],
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               width * 0.035,
//                                                           color: Colors.grey,
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                           height:
//                                                               height * 0.005),
//                                                       Text(
//                                                         bidder['bid_amount'],
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               width * 0.035,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           color: Colors.green,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           );
//                                         },
//                                       ),
//                               )
//                             else
//                               Padding(
//                                 padding: EdgeInsets.only(top: height * 0.01),
//                                 child: relatedWorkers.isEmpty
//                                     ? Center(
//                                         child: Text(
//                                           'No related workers found',
//                                           style: TextStyle(
//                                             fontSize: width * 0.04,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       )
//                                     : ListView.builder(
//                                         shrinkWrap: true,
//                                         physics:
//                                             const NeverScrollableScrollPhysics(),
//                                         itemCount: relatedWorkers.length,
//                                         itemBuilder: (context, index) {
//                                           final worker = relatedWorkers[index];
//                                           return Container(
//                                             margin: EdgeInsets.symmetric(
//                                               vertical: height * 0.01,
//                                               horizontal: width * 0.01,
//                                             ),
//                                             padding:
//                                                 EdgeInsets.all(width * 0.02),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                   spreadRadius: 1,
//                                                   blurRadius: 5,
//                                                   offset: const Offset(0, 3),
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                   child: Image.asset(
//                                                     "assets/images/account1.png",
//                                                     height: 90,
//                                                     width: 90,
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: width * 0.03),
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceBetween,
//                                                         children: [
//                                                           Flexible(
//                                                             child: Text(
//                                                               worker['name'],
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     width *
//                                                                         0.045,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                               ),
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                               maxLines: 1,
//                                                             ),
//                                                           ),
//                                                           Row(
//                                                             children: [
//                                                               Text(
//                                                                 "${worker['rating']}",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.035,
//                                                                 ),
//                                                               ),
//                                                               Icon(
//                                                                 Icons.star,
//                                                                 size: width *
//                                                                     0.04,
//                                                                 color: Colors
//                                                                     .yellow
//                                                                     .shade700,
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       SizedBox(
//                                                           height:
//                                                               height * 0.005),
//                                                       Text(
//                                                         worker['amount'],
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               width * 0.035,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           color: Colors.green,
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                           height:
//                                                               height * 0.005),
//                                                       Text(
//                                                         worker['location'],
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               width * 0.035,
//                                                           color: Colors.grey,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           );
//                                         },
//                                       ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                     if (isAccepted) ...[
//                       SizedBox(height: height * 0.02),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => BiddingWorkerDisputeScreen(
//                                 orderId: widget.orderId,
//                                 flowType: "bidding",
//                               ),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(14),
//                             color: Colors.red,
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Cancel Task and create dispute',
//                               style: GoogleFonts.roboto(
//                                 fontSize: 14,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
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
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           setState(() {
//             isLoading = false;
//             hasAlreadyBid = true;
//             biddingOfferId = jsonData['data']['_id'];
//           });
//           print('✅ Bid placed, biddingOfferId: $biddingOfferId');
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
//   Future<void> startNegotiation(String amount) async {
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
//       if (amount.isEmpty) {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'Please enter an amount',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: EdgeInsets.all(10),
//           duration: Duration(seconds: 3),
//         );
//         return;
//       }
//
//       double? offerAmount;
//       try {
//         offerAmount = double.parse(amount);
//         if (offerAmount <= 0) {
//           throw FormatException('Amount positive hona chahiye');
//         }
//       } catch (e) {
//         setState(() {
//           isLoading = false;
//         });
//         Get.snackbar(
//           'Error',
//           'Invalid amount format',
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
//         'bidding_offer_id': biddingOfferId,
//         'service_provider': currentUserId,
//         'user': biddingOrder!.userId?.id,
//         'initiator': 'service_provider',
//         'offer_amount': offerAmount,
//       };
//
//       print('📤 Sending Negotiation Payload: ${jsonEncode(payload)}');
//       print('🔐 Using Token: $token');
//
//       final response = await http.post(
//         Uri.parse('https://api.thebharatworks.com/api/negotiations/start'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📥 Negotiation Response Status: ${response.statusCode}');
//       print('📥 Negotiation Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['message'] == 'Negotiation started') {
//           setState(() {
//             isLoading = false;
//             negotiationId = jsonData['negotiation']['_id'];
//             offerPrice = '₹${offerAmount?.toStringAsFixed(2)}';
//             print('✅ Setting offerPrice in setState: $offerPrice');
//           });
//           print('✅ Negotiation started, negotiationId: $negotiationId');
//           print('✅ Updated offerPrice: $offerPrice');
//           Get.snackbar(
//             'Success',
//             'Negotiation request sent successfully!',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//           await fetchLatestNegotiation();
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           Get.snackbar(
//             'Error',
//             jsonData['message'] ?? 'Failed to start negotiation',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//         }
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
//       print('❌ Negotiation API Error: $e');
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
//   Future<void> acceptNegotiation() async {
//     if (negotiationId == null) {
//       Get.snackbar(
//         'Error',
//         'No negotiation found to accept.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         margin: EdgeInsets.all(10),
//         duration: Duration(seconds: 3),
//       );
//       return;
//     }
//
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
//       final payload = {
//         'role': 'service_provider',
//       };
//
//       print('📤 Sending Accept Negotiation Payload: ${jsonEncode(payload)}');
//       print('🔐 Using Token: $token');
//
//       final response = await http.put(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/negotiations/accept/$negotiationId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📥 Accept Negotiation Response Status: ${response.statusCode}');
//       print('📥 Accept Negotiation Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['message'] == 'Negotiation accepted') {
//           setState(() {
//             isLoading = false;
//             offerPrice =
//                 '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
//             print('✅ Setting offerPrice in acceptNegotiation: $offerPrice');
//           });
//           Get.snackbar(
//             'Success',
//             'Negotiation accepted successfully!',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//           await fetchLatestNegotiation();
//           await fetchBiddingOrder();
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           Get.snackbar(
//             'Error',
//             jsonData['message'] ?? 'Failed to accept negotiation',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             margin: EdgeInsets.all(10),
//             duration: Duration(seconds: 3),
//           );
//         }
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
//       print('❌ Accept Negotiation API Error: $e');
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
// }
//
// class NegotiationCard extends StatefulWidget {
//   final double width;
//   final double height;
//   final String offerPrice;
//   final String bidAmount;
//   final Function(String) onNegotiate;
//   final Function() onAccept;
//
//   const NegotiationCard({
//     Key? key,
//     required this.width,
//     required this.height,
//     required this.offerPrice,
//     required this.bidAmount,
//     required this.onNegotiate,
//     required this.onAccept,
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
//   void initState() {
//     super.initState();
//     print(
//         '🖼️ NegotiationCard initialized with offerPrice: ${widget.offerPrice}');
//   }
//
//   @override
//   void didUpdateWidget(NegotiationCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.offerPrice != widget.offerPrice) {
//       print(
//           '🖼️ NegotiationCard updated with new offerPrice: ${widget.offerPrice}');
//     }
//   }
//
//   @override
//   void dispose() {
//     amountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(
//         '🖼️ NegotiationCard rebuilding with offerPrice: ${widget.offerPrice}');
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
//                   SizedBox(width: widget.width * 0.015),
//                   Expanded(
//                     child: Container(
//                       height: 45,
//                       padding:
//                           EdgeInsets.symmetric(vertical: widget.height * 0.0),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(widget.width * 0.02),
//                         border: Border.all(color: Colors.green),
//                         color: Colors.white,
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             "Offer Price",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontSize: widget.width * 0.04,
//                             ),
//                           ),
//                           Text(
//                             widget.offerPrice,
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontSize: widget.width * 0.04,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: widget.width * 0.015),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isNegotiating = !isNegotiating;
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                             vertical: widget.height * 0.015),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           borderRadius:
//                               BorderRadius.circular(widget.width * 0.02),
//                           border: Border.all(color: Colors.green.shade700),
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
//               TextField(
//                 controller: amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: "Enter your offer Amount",
//                   hintStyle: GoogleFonts.roboto(
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.bold,
//                     fontSize: widget.width * 0.04,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(widget.width * 0.02),
//                   ),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                 ),
//                 style: GoogleFonts.roboto(
//                   color: Colors.green.shade700,
//                   fontWeight: FontWeight.bold,
//                   fontSize: widget.width * 0.04,
//                 ),
//               ),
//               SizedBox(height: widget.height * 0.02),
//               GestureDetector(
//                 onTap: () {
//                   String amount = amountController.text.trim();
//                   widget.onNegotiate(amount);
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
//                     "Send Request",
//                     style: GoogleFonts.roboto(
//                       color: Colors.white,
//                       fontSize: widget.width * 0.04,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//             SizedBox(height: widget.height * 0.02),
//             GestureDetector(
//               onTap: widget.onAccept,
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: widget.height * 0.018),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(widget.width * 0.02),
//                   color: Colors.green.shade700,
//                 ),
//                 child: Text(
//                   "Accept",
//                   style: GoogleFonts.roboto(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: widget.width * 0.04,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
