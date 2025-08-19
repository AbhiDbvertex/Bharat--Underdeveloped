// //
// //
// // import 'dart:convert';
// //
// // import 'package:developer/views/ServiceProvider/ServiceDisputeScreen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../../Widgets/AppColors.dart';
// // import 'ServiceWorkerListScreen.dart';
// //
// // class ServiceWorkDetailScreen extends StatefulWidget {
// //   final String orderId;
// //
// //   const ServiceWorkDetailScreen({super.key, required this.orderId});
// //
// //   @override
// //   State<ServiceWorkDetailScreen> createState() =>
// //       _ServiceWorkDetailScreenState();
// // }
// //
// // class _ServiceWorkDetailScreenState extends State<ServiceWorkDetailScreen> {
// //   bool isLoading = true;
// //   Map<String, dynamic>? order;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchOrderDetails();
// //   }
// //
// //   Future<void> fetchOrderDetails() async {
// //     try {
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       String? token = prefs.getString("token");
// //
// //       if (token == null) {
// //         if (mounted) {
// //           ScaffoldMessenger.of(
// //             context,
// //           ).showSnackBar(const SnackBar(content: Text("Please login first")));
// //         }
// //         setState(() => isLoading = false);
// //         return;
// //       }
// //
// //       print("Token: $token"); // Debug: Log token
// //
// //       var headers = {
// //         'Content-Type': 'application/json',
// //         'Authorization': 'Bearer $token',
// //       };
// //
// //       var response = await http.get(
// //         Uri.parse(
// //           "https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.orderId}",
// //         ),
// //         headers: headers,
// //       );
// //
// //       print("API Response Status: ${response.statusCode}");
// //       print("API Response Body: ${response.body}"); // Debug: Log full response
// //
// //       var data = jsonDecode(response.body);
// //       if (response.statusCode == 200 && data["data"]?["order"] != null) {
// //         setState(() {
// //           order = data["data"]["order"];
// //           print(
// //             "Raw image_url: ${order?['image_url']}",
// //           ); // Debug: Check raw URL
// //           isLoading = false;
// //         });
// //       } else {
// //         throw Exception(data["message"] ?? "Failed to fetch order details");
// //       }
// //     } catch (e) {
// //       print("Error fetching order details: $e"); // Debug: Log error
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text("Failed to load work details: $e")),
// //         );
// //       }
// //       setState(() => isLoading = false);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: AppColors.primaryGreen,
// //         centerTitle: true,
// //         elevation: 0,
// //         title: const Text("Work Detail", style: TextStyle(color: Colors.white)),
// //       ),
// //       body:
// //       isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : order == null
// //           ? const Center(
// //         child: Text(
// //           "Unable to load order details. It may have been already accepted or is invalid.",
// //           style: TextStyle(fontSize: 16, color: Colors.red),
// //           textAlign: TextAlign.center,
// //         ),
// //       )
// //           : SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Static image to avoid FormatException
// //             Image.asset(
// //               'assets/images/task.png',
// //               height: 200,
// //               width: double.infinity,
// //               fit: BoxFit.cover,
// //             ),
// //             // Uncomment when backend fixes image_url
// //             /*
// //                       Image.network(
// //                         'https://api.thebharatworks.com${order!['image_url'] is List ? order!['image_url'][0] : order!['image_url']}',
// //                         height: 200,
// //                         width: double.infinity,
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (context, error, stackTrace) {
// //                           print("Image load error: $error");
// //                           return Image.asset('assets/images/task.png');
// //                         },
// //                       ),
// //                       */
// //             const SizedBox(height: 20),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   order!['title'] ?? 'Work Title',
// //                   style: const TextStyle(
// //                     fontSize: 22,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 Text(
// //                   "Posted Date: ${order!['deadline']?.substring(0, 10) ?? 'N/A'}",
// //                   style: const TextStyle(fontSize: 16),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 10),
// //             Container(
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: 18,
// //                 vertical: 5,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: Colors.red,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: Text(
// //                 order!['address'] ?? '',
// //                 style: const TextStyle(color: Colors.white),
// //               ),
// //             ),
// //             const SizedBox(height: 10),
// //             Text(
// //               "Completion Date: ${order!['deadline']?.substring(0, 10) ?? 'N/A'}",
// //               style: const TextStyle(fontSize: 16),
// //             ),
// //             const SizedBox(height: 10),
// //             Text(
// //               "Work Title",
// //               style: GoogleFonts.roboto(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 5),
// //             Text(order!['description'] ?? ''),
// //             const SizedBox(height: 20),
// //             GestureDetector(
// //               onTap: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (_) => ServiceWorkerListScreen(),
// //                   ),
// //                 );
// //               },
// //               child: Container(
// //                 height: 50,
// //                 width: 320,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(10),
// //                   border: Border.all(color: Colors.green.shade700),
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     'Assign to another person',
// //                     style: GoogleFonts.roboto(
// //                       fontSize: 14,
// //                       color: Colors.green,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             Card(
// //               elevation: 6,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(14),
// //               ),
// //               child: Container(
// //                 padding: const EdgeInsets.all(16),
// //                 width: 330,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(14),
// //                   color: Colors.white,
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Center(
// //                       child: Text(
// //                         'Payment',
// //                         style: GoogleFonts.roboto(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w600,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     const Divider(thickness: 0.8),
// //                     const SizedBox(height: 10),
// //                     if (order!['service_payment'] != null &&
// //                         order!['service_payment']['payment_history'] !=
// //                             null &&
// //                         order!['service_payment']['payment_history']
// //                             .isNotEmpty)
// //                       ...List.generate(
// //                         order!['service_payment']['payment_history']
// //                             .length,
// //                             (index) {
// //                           final item =
// //                           order!['service_payment']['payment_history'][index];
// //                           return Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: Row(
// //                               mainAxisAlignment:
// //                               MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   "${index + 1}. ${item['stage'] ?? 'Stage'}",
// //                                   style: GoogleFonts.roboto(
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 Row(
// //                                   children: [
// //                                     Text(
// //                                       "${item['status'] == 'paid' ? 'Paid' : 'Pending'}",
// //                                       style: GoogleFonts.roboto(
// //                                         color:
// //                                         item['status'] == 'paid'
// //                                             ? Colors.green
// //                                             : Colors.red,
// //                                         fontSize: 12,
// //                                         fontWeight: FontWeight.w500,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(width: 10),
// //                                     Text(
// //                                       "₹${item['amount']}",
// //                                       style: GoogleFonts.roboto(
// //                                         fontWeight: FontWeight.w500,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           );
// //                         },
// //                       )
// //                     else
// //                       Text(
// //                         'No payment history found.',
// //                         style: GoogleFonts.roboto(fontSize: 14),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 40),
// //             Stack(
// //               clipBehavior: Clip.none,
// //               children: [
// //                 Container(
// //                   width: 320,
// //                   padding: const EdgeInsets.only(top: 40, bottom: 16),
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(14),
// //                     color: Colors.yellow.shade100,
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       const SizedBox(height: 10),
// //                       Text(
// //                         'Warning Message',
// //                         style: GoogleFonts.roboto(
// //                           fontSize: 14,
// //                           color: Colors.red,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         'Lorem ipsum dolor sit amet consectetur.',
// //                         style: GoogleFonts.roboto(
// //                           fontSize: 14,
// //                           color: Colors.black87,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Positioned(
// //                   top: -30,
// //                   left: 0,
// //                   right: 0,
// //                   child: Center(
// //                     child: Container(
// //                       padding: const EdgeInsets.all(6),
// //                       decoration: BoxDecoration(
// //                         borderRadius: BorderRadius.circular(12),
// //                         color: Colors.white,
// //                       ),
// //                       child: Image.asset(
// //                         'assets/images/warning.png',
// //                         height: 70,
// //                         width: 70,
// //                         fit: BoxFit.contain,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 16),
// //             GestureDetector(
// //               onTap: () async {
// //                 SharedPreferences prefs =
// //                 await SharedPreferences.getInstance();
// //                 String? token = prefs.getString("token");
// //
// //                 if (token == null || token.isEmpty) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text("Please login to continue."),
// //                     ),
// //                   );
// //                   return;
// //                 }
// //
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder:
// //                         (_) => ServiceDisputeScreen(
// //                       orderId: widget.orderId,
// //                       flowType: "direct",
// //                       token: token,
// //                     ),
// //                   ),
// //                 );
// //               },
// //               child: Container(
// //                 width: 320,
// //                 height: 50,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(14),
// //                   color: Colors.red,
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     'Cancel Task and create dispute',
// //                     style: GoogleFonts.roboto(
// //                       fontSize: 14,
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 10),
// //             Container(
// //               width: 320,
// //               height: 50,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(14),
// //                 color: Colors.green.shade700,
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   'Mark as complete',
// //                   style: GoogleFonts.roboto(
// //                     fontSize: 14,
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:convert';
//
// import 'package:developer/views/ServiceProvider/ServiceDisputeScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
// import 'ServiceWorkerListScreen.dart';
//
// class ServiceWorkDetailScreen extends StatefulWidget {
//   final String orderId;
//
//   const ServiceWorkDetailScreen({super.key, required this.orderId});
//
//   @override
//   State<ServiceWorkDetailScreen> createState() =>
//       _ServiceWorkDetailScreenState();
// }
//
// class _ServiceWorkDetailScreenState extends State<ServiceWorkDetailScreen> {
//   bool isLoading = true;
//   Map<String, dynamic>? order;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchOrderDetails();
//   }
//
//   Future<void> fetchOrderDetails() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString("token");
//
//       if (token == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("Please login first")));
//         }
//         setState(() => isLoading = false);
//         return;
//       }
//
//       print("Token: $token"); // Debug: Log token
//
//       var headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//       var response = await http.get(
//         Uri.parse(
//           "https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.orderId}",
//         ),
//         headers: headers,
//       );
//
//       print("API Response Status: ${response.statusCode}");
//       print("API Response Body: ${response.body}"); // Debug: Log full response
//
//       var data = jsonDecode(response.body);
//       if (response.statusCode == 200 && data["data"]?["order"] != null) {
//         setState(() {
//           order = data["data"]["order"];
//           print(
//             "Raw image_url: ${order?['image_url']}",
//           ); // Debug: Check raw URL
//           isLoading = false;
//         });
//       } else {
//         throw Exception(data["message"] ?? "Failed to fetch order details");
//       }
//     } catch (e) {
//       print("Error fetching order details: $e"); // Debug: Log error
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to load work details: $e")),
//         );
//       }
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> markOrderAsComplete() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString("token");
//       if (token == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please login to continue.")),
//         );
//         return;
//       }
//
//       var headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//       var body = jsonEncode({"order_id": widget.orderId});
//
//       var response = await http.post(
//         Uri.parse(
//           "https://api.thebharatworks.com/api/direct-order/mark-complete",
//         ),
//         headers: headers,
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Order marked as complete.")),
//         );
//         Navigator.pop(context); // Navigate back after success
//       } else {
//         var data = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to mark complete: ${data['message']}"),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         title: const Text("Work Detail", style: TextStyle(color: Colors.white)),
//       ),
//       body:
//       isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : order == null
//           ? const Center(
//         child: Text(
//           "Unable to load order details. It may have been already accepted or is invalid.",
//           style: TextStyle(fontSize: 16, color: Colors.red),
//           textAlign: TextAlign.center,
//         ),
//       )
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image handling
//             order!['image_url'] != null
//                 ? Image.network(
//               order!['image_url'] is List
//                   ? 'https://api.thebharatworks.com${order!['image_url'][0]}'
//                   : 'https://api.thebharatworks.com${order!['image_url']}',
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 print("Image load error: $error");
//                 return Image.asset(
//                   'assets/images/task.png',
//                   height: 200,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 );
//               },
//             )
//                 : Image.asset(
//               'assets/images/task.png',
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Text(
//                     order!['title'] ?? 'Work Title',
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Text(
//                   "Posted Date: ${order!['deadline']?.substring(0, 10) ?? 'N/A'}",
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 18,
//                 vertical: 5,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 order!['address'] ?? '',
//                 style: const TextStyle(color: Colors.white),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Completion Date: ${order!['deadline']?.substring(0, 10) ?? 'N/A'}",
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Work Title",
//               style: GoogleFonts.roboto(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               order!['description'] ?? '',
//               style: GoogleFonts.roboto(fontSize: 14),
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ServiceWorkerListScreen(),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 50,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.green.shade700),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Assign to another person',
//                     style: GoogleFonts.roboto(
//                       fontSize: 14,
//                       color: Colors.green,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             /*Card(
//               elevation: 6,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   color: Colors.white,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Text(
//                         'Payment',
//                         style: GoogleFonts.roboto(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Divider(thickness: 0.8),
//                     const SizedBox(height: 10),
//                     if (order!['service_payment'] != null &&
//                         order!['service_payment']['payment_history'] !=
//                             null &&
//                         order!['service_payment']['payment_history']
//                             .isNotEmpty)
//                       ...List.generate(
//                         order!['service_payment']['payment_history']
//                             .length,
//                             (index) {
//                           final item =
//                           order!['service_payment']['payment_history'][index];
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 10),
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Flexible(
//                                   flex: 2,
//                                   child: Text(
//                                     "${index + 1}. ${item['stage'] ?? 'Stage'}",
//                                     style: GoogleFonts.roboto(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ),
//                                 Flexible(
//                                   flex: 3,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           "${item['status'] == 'paid' ? 'Paid' : 'Pending'}",
//                                           style: GoogleFonts.roboto(
//                                             color:
//                                             item['status'] == 'paid'
//                                                 ? Colors.green
//                                                 : Colors.red,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           overflow:
//                                           TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Flexible(
//                                         child: Text(
//                                           "₹${item['amount']}",
//                                           style: GoogleFonts.roboto(
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           overflow:
//                                           TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       )
//                     else
//                       Text(
//                         'No payment history found.',
//                         style: GoogleFonts.roboto(fontSize: 14),
//                       ),
//                   ],
//                 ),
//               ),
//             ),*/
//             Card(
//               elevation: 6,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   color: Colors.white,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Text(
//                         'Payment',
//                         style: GoogleFonts.roboto(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Divider(thickness: 0.8),
//                     const SizedBox(height: 10),
//                     if (order!['service_payment'] != null &&
//                         order!['service_payment']['payment_history'] !=
//                             null &&
//                         order!['service_payment']['payment_history']
//                             .isNotEmpty)
//                       ...List.generate(
//                         order!['service_payment']['payment_history']
//                             .length,
//                             (index) {
//                           final item =
//                           order!['service_payment']['payment_history'][index];
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 10),
//                             child: Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Flexible(
//                                   flex: 2,
//                                   child: Text(
//                                     "${index + 1}. ${item['description'] ?? 'No Description'}",
//                                     style: GoogleFonts.roboto(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 1,
//                                   ),
//                                 ),
//                                 Flexible(
//                                   flex: 3,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           "${item['status'] == 'paid' ? 'Paid' : 'Pending'}",
//                                           style: GoogleFonts.roboto(
//                                             color:
//                                             item['status'] == 'paid'
//                                                 ? Colors.green
//                                                 : Colors.red,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           overflow:
//                                           TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Flexible(
//                                         child: Text(
//                                           "₹${item['amount']}",
//                                           style: GoogleFonts.roboto(
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           overflow:
//                                           TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       )
//                     else
//                       Text(
//                         'No payment history found.',
//                         style: GoogleFonts.roboto(fontSize: 14),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 40),
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(top: 40, bottom: 16),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     color: Colors.yellow.shade100,
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 10),
//                       Text(
//                         'Warning Message',
//                         style: GoogleFonts.roboto(
//                           fontSize: 14,
//                           color: Colors.red,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Lorem ipsum dolor sit amet consectetur.',
//                         style: GoogleFonts.roboto(
//                           fontSize: 14,
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   top: -30,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.white,
//                       ),
//                       child: Image.asset(
//                         'assets/images/warning.png',
//                         height: 70,
//                         width: 70,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: () async {
//                 SharedPreferences prefs =
//                 await SharedPreferences.getInstance();
//                 String? token = prefs.getString("token");
//
//                 if (token == null || token.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Please login to continue."),
//                     ),
//                   );
//                   return;
//                 }
//
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (_) => ServiceDisputeScreen(
//                       orderId: widget.orderId,
//                       flowType: "direct",
//                       // token: token,
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: double.infinity,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   color: Colors.red,
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Cancel Task and create dispute',
//                     style: GoogleFonts.roboto(
//                       fontSize: 14,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             GestureDetector(
//               onTap: markOrderAsComplete,
//               child: Container(
//                 width: double.infinity,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   color: Colors.green.shade700,
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Mark as complete',
//                     style: GoogleFonts.roboto(
//                       fontSize: 14,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
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
