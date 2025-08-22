// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// //
// // import '../../Widgets/AppColors.dart';
// // import '../Models/bidding_order.dart'; // Import your BiddingOrder and UserId classes
// //
// // class Biddingserviceproviderworkdetail extends StatefulWidget {
// //   final String orderId;
// //
// //   const Biddingserviceproviderworkdetail({Key? key, required this.orderId})
// //       : super(key: key);
// //
// //   @override
// //   _BiddingserviceproviderworkdetailState createState() =>
// //       _BiddingserviceproviderworkdetailState();
// // }
// //
// // class _BiddingserviceproviderworkdetailState
// //     extends State<Biddingserviceproviderworkdetail> {
// //   BiddingOrder? biddingOrder;
// //   bool isLoading = true;
// //   String errorMessage = '';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchBiddingOrder();
// //   }
// //
// //   Future<void> fetchBiddingOrder() async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse(
// //             'https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.orderId}'),
// //       );
// //
// //       if (response.statusCode == 200) {
// //         final jsonData = jsonDecode(response.body);
// //         if (jsonData['status'] == true) {
// //           setState(() {
// //             biddingOrder = BiddingOrder.fromJson(jsonData['data']);
// //             isLoading = false;
// //           });
// //         } else {
// //           setState(() {
// //             errorMessage = jsonData['message'] ?? 'Failed to fetch data';
// //             isLoading = false;
// //           });
// //         }
// //       } else {
// //         setState(() {
// //           errorMessage = 'Error: ${response.statusCode}';
// //           isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         errorMessage = 'Error: $e';
// //         isLoading = false;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final height = MediaQuery.of(context).size.height;
// //     final width = MediaQuery.of(context).size.width;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: AppColors.primaryGreen,
// //         centerTitle: true,
// //         elevation: 0,
// //         toolbarHeight: height * 0.03,
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: isLoading
// //           ? Center(child: CircularProgressIndicator())
// //           : errorMessage.isNotEmpty
// //               ? Center(child: Text(errorMessage))
// //               : SingleChildScrollView(
// //                   child: Padding(
// //                     padding: EdgeInsets.all(width * 0.02),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         SizedBox(height: height * 0.01),
// //                         Row(
// //                           children: [
// //                             GestureDetector(
// //                               onTap: () => Navigator.pop(context),
// //                               child: Padding(
// //                                 padding: EdgeInsets.only(left: width * 0.02),
// //                                 child:
// //                                     Icon(Icons.arrow_back, size: width * 0.06),
// //                               ),
// //                             ),
// //                             SizedBox(width: width * 0.25),
// //                             Text(
// //                               "Work detail",
// //                               style: GoogleFonts.roboto(
// //                                 fontSize: width * 0.045,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.black,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         SizedBox(height: height * 0.01),
// //                         Padding(
// //                           padding: EdgeInsets.all(width * 0.02),
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(height: height * 0.015),
// //                               Row(
// //                                 children: [
// //                                   Container(
// //                                     padding: EdgeInsets.symmetric(
// //                                       horizontal: width * 0.06,
// //                                       vertical: height * 0.005,
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.red.shade300,
// //                                       borderRadius:
// //                                           BorderRadius.circular(width * 0.03),
// //                                     ),
// //                                     child: Text(
// //                                       biddingOrder!.address,
// //                                       style: GoogleFonts.roboto(
// //                                           color: Colors.white,
// //                                           fontSize: width * 0.03),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: height * 0.015),
// //                               Padding(
// //                                 padding: EdgeInsets.only(left: width * 0.02),
// //                                 child: Text(
// //                                   biddingOrder!.title,
// //                                   style: TextStyle(
// //                                       fontSize: width * 0.045,
// //                                       fontWeight: FontWeight.bold),
// //                                 ),
// //                               ),
// //                               SizedBox(height: height * 0.005),
// //                               Padding(
// //                                 padding: EdgeInsets.only(left: width * 0.02),
// //                                 child: Text(
// //                                   'Complete: ${biddingOrder!.deadline.split('T').first}',
// //                                   style: TextStyle(
// //                                       fontSize: width * 0.035,
// //                                       color: Colors.grey),
// //                                 ),
// //                               ),
// //                               SizedBox(height: height * 0.015),
// //                               Padding(
// //                                 padding: EdgeInsets.only(left: width * 0.02),
// //                                 child: Text(
// //                                   '₹${biddingOrder!.cost.toStringAsFixed(0)}',
// //                                   style: TextStyle(
// //                                       fontSize: width * 0.05,
// //                                       color: Colors.green,
// //                                       fontWeight: FontWeight.bold),
// //                                 ),
// //                               ),
// //                               SizedBox(height: height * 0.015),
// //                               Padding(
// //                                 padding: EdgeInsets.only(left: width * 0.02),
// //                                 child: Text(
// //                                   'Task Details',
// //                                   style: TextStyle(
// //                                       fontSize: width * 0.04,
// //                                       fontWeight: FontWeight.bold),
// //                                 ),
// //                               ),
// //                               SizedBox(height: height * 0.005),
// //                               Padding(
// //                                 padding: EdgeInsets.only(left: width * 0.02),
// //                                 child: Text(
// //                                   biddingOrder!.description,
// //                                   style: TextStyle(fontSize: width * 0.035),
// //                                 ),
// //                               ),
// //                               SizedBox(height: height * 0.02),
// //                               // Bid button and below remains same
// //                               Center(
// //                                 child: GestureDetector(
// //                                   onTap: () {
// //                                     showDialog(
// //                                       context: context,
// //                                       builder: (BuildContext context) {
// //                                         return AlertDialog(
// //                                           backgroundColor: Colors.white,
// //                                           insetPadding: EdgeInsets.symmetric(
// //                                               horizontal: width * 0.05),
// //                                           title: Center(
// //                                               child: Text(
// //                                             "Bid",
// //                                             style: GoogleFonts.roboto(
// //                                               fontSize: width * 0.05,
// //                                               color: Colors.black,
// //                                               fontWeight: FontWeight.bold,
// //                                             ),
// //                                           )),
// //                                           content: SingleChildScrollView(
// //                                             child: SizedBox(
// //                                               width: width * 0.8,
// //                                               child: Column(
// //                                                 crossAxisAlignment:
// //                                                     CrossAxisAlignment.start,
// //                                                 children: [
// //                                                   Text("Enter Amount",
// //                                                       style: GoogleFonts.roboto(
// //                                                         fontSize: width * 0.035,
// //                                                         fontWeight:
// //                                                             FontWeight.bold,
// //                                                       )),
// //                                                   SizedBox(
// //                                                       height: height * 0.005),
// //                                                   TextField(
// //                                                     decoration: InputDecoration(
// //                                                       hintText: "\$0.00",
// //                                                       border:
// //                                                           OutlineInputBorder(
// //                                                         borderRadius:
// //                                                             BorderRadius
// //                                                                 .circular(
// //                                                                     width *
// //                                                                         0.02),
// //                                                       ),
// //                                                     ),
// //                                                   ),
// //                                                   SizedBox(
// //                                                       height: height * 0.01),
// //                                                   Text("Description",
// //                                                       style: GoogleFonts.roboto(
// //                                                         fontSize: width * 0.035,
// //                                                         fontWeight:
// //                                                             FontWeight.bold,
// //                                                       )),
// //                                                   SizedBox(
// //                                                       height: height * 0.005),
// //                                                   TextField(
// //                                                     maxLines: 3,
// //                                                     decoration: InputDecoration(
// //                                                       hintText:
// //                                                           "Enter description here",
// //                                                       border:
// //                                                           OutlineInputBorder(
// //                                                         borderRadius:
// //                                                             BorderRadius
// //                                                                 .circular(
// //                                                                     width *
// //                                                                         0.02),
// //                                                       ),
// //                                                     ),
// //                                                   ),
// //                                                   SizedBox(
// //                                                       height: height * 0.015),
// //                                                   Center(
// //                                                     child: Container(
// //                                                       padding:
// //                                                           EdgeInsets.symmetric(
// //                                                               horizontal:
// //                                                                   width * 0.18,
// //                                                               vertical: height *
// //                                                                   0.012),
// //                                                       decoration: BoxDecoration(
// //                                                         color: Colors
// //                                                             .green.shade700,
// //                                                         borderRadius:
// //                                                             BorderRadius
// //                                                                 .circular(
// //                                                                     width *
// //                                                                         0.02),
// //                                                       ),
// //                                                       child: Text("Bid",
// //                                                           style: TextStyle(
// //                                                               color:
// //                                                                   Colors.white,
// //                                                               fontSize:
// //                                                                   width * 0.04,
// //                                                               fontWeight:
// //                                                                   FontWeight
// //                                                                       .bold)),
// //                                                     ),
// //                                                   )
// //                                                 ],
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         );
// //                                       },
// //                                     );
// //                                   },
// //                                   child: Container(
// //                                     padding: EdgeInsets.symmetric(
// //                                         horizontal: width * 0.18,
// //                                         vertical: height * 0.012),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.green.shade700,
// //                                       borderRadius:
// //                                           BorderRadius.circular(width * 0.02),
// //                                     ),
// //                                     child: Text(
// //                                       "Bid",
// //                                       style: TextStyle(
// //                                           color: Colors.white,
// //                                           fontSize: width * 0.04,
// //                                           fontWeight: FontWeight.bold),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(height: height * 0.02),
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceEvenly,
// //                                 children: [
// //                                   Container(
// //                                     padding: EdgeInsets.symmetric(
// //                                         horizontal: width * 0.17,
// //                                         vertical: height * 0.015),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.green.shade700,
// //                                       borderRadius:
// //                                           BorderRadius.circular(width * 0.02),
// //                                     ),
// //                                     child: Text('Bidders',
// //                                         style: TextStyle(
// //                                             color: Colors.white,
// //                                             fontSize: width * 0.035)),
// //                                   ),
// //                                   Container(
// //                                     padding: EdgeInsets.symmetric(
// //                                         horizontal: width * 0.11,
// //                                         vertical: height * 0.015),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.green.shade700,
// //                                       borderRadius:
// //                                           BorderRadius.circular(width * 0.02),
// //                                     ),
// //                                     child: Text('Related Worker',
// //                                         style: TextStyle(
// //                                             color: Colors.white,
// //                                             fontSize: width * 0.035)),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: height * 0.02),
// //                               Card(
// //                                 color: Colors.white,
// //                                 child: Container(
// //                                   width: width,
// //                                   padding: EdgeInsets.all(width * 0.04),
// //                                   child: Column(
// //                                     children: [
// //                                       Container(
// //                                         width: width,
// //                                         padding: EdgeInsets.all(width * 0.015),
// //                                         decoration: BoxDecoration(
// //                                           borderRadius: BorderRadius.circular(
// //                                               width * 0.02),
// //                                           color: Colors.green.shade100,
// //                                         ),
// //                                         child: Row(
// //                                           children: [
// //                                             Expanded(
// //                                               child: Container(
// //                                                 padding: EdgeInsets.symmetric(
// //                                                     vertical: height * 0.015),
// //                                                 alignment: Alignment.center,
// //                                                 decoration: BoxDecoration(
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                           width * 0.02),
// //                                                   border: Border.all(
// //                                                       color: Colors.green),
// //                                                   color: Colors.white,
// //                                                 ),
// //                                                 child: Text("Offer Price(120)",
// //                                                     style: TextStyle(
// //                                                         color: Colors.green,
// //                                                         fontSize:
// //                                                             width * 0.04)),
// //                                               ),
// //                                             ),
// //                                             SizedBox(width: width * 0.015),
// //                                             Expanded(
// //                                               child: Container(
// //                                                 padding: EdgeInsets.symmetric(
// //                                                     vertical: height * 0.015),
// //                                                 alignment: Alignment.center,
// //                                                 decoration: BoxDecoration(
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(
// //                                                           width * 0.02),
// //                                                   color: Colors.green.shade700,
// //                                                 ),
// //                                                 child: Text("Negotiate",
// //                                                     style: TextStyle(
// //                                                         color: Colors.white,
// //                                                         fontSize:
// //                                                             width * 0.04)),
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ),
// //                                       SizedBox(height: height * 0.02),
// //                                       Container(
// //                                         padding: EdgeInsets.symmetric(
// //                                             vertical: height * 0.018),
// //                                         alignment: Alignment.center,
// //                                         decoration: BoxDecoration(
// //                                           borderRadius: BorderRadius.circular(
// //                                               width * 0.02),
// //                                           border:
// //                                               Border.all(color: Colors.green),
// //                                           color: Colors.white,
// //                                         ),
// //                                         child: Text("Enter your offer amount",
// //                                             style: GoogleFonts.roboto(
// //                                                 color: Colors.green.shade700,
// //                                                 fontWeight: FontWeight.bold,
// //                                                 fontSize: width * 0.04)),
// //                                       ),
// //                                       SizedBox(height: height * 0.02),
// //                                       Container(
// //                                         padding: EdgeInsets.symmetric(
// //                                             vertical: height * 0.018),
// //                                         alignment: Alignment.center,
// //                                         decoration: BoxDecoration(
// //                                           borderRadius: BorderRadius.circular(
// //                                               width * 0.02),
// //                                           color: Colors.green.shade700,
// //                                         ),
// //                                         child: Text("Send request",
// //                                             style: GoogleFonts.roboto(
// //                                                 color: Colors.white,
// //                                                 fontSize: width * 0.04)),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //     );
// //   }
// // }
//
// import 'dart:convert';
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
//
// import '../../Widgets/AppColors.dart';
// import '../Models/bidding_order.dart'; // Import your BiddingOrder and UserId classes
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
//   BiddingOrder? biddingOrder;
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBiddingOrder();
//   }
//
//   Future<void> fetchBiddingOrder() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.orderId}'),
//       );
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           setState(() {
//             biddingOrder = BiddingOrder.fromJson(jsonData['data']);
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             errorMessage = jsonData['message'] ?? 'Failed to fetch data';
//             isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           errorMessage = 'Error: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
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
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(width * 0.02),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: height * 0.01),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child:
//                                     Icon(Icons.arrow_back, size: width * 0.06),
//                               ),
//                             ),
//                             SizedBox(width: width * 0.25),
//                             Text(
//                               "Work detail",
//                               style: GoogleFonts.roboto(
//                                 fontSize: width * 0.045,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: height * 0.01),
//                         Padding(
//                           padding: EdgeInsets.all(width * 0.02),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CarouselSlider(
//                                 options: CarouselOptions(
//                                   height: height * 0.25,
//                                   enlargeCenterPage: true,
//                                   autoPlay: true,
//                                   viewportFraction: 1,
//                                 ),
//                                 items: (biddingOrder!.imageUrls.isNotEmpty
//                                         ? biddingOrder!.imageUrls
//                                         : ["assets/images/chair.png"])
//                                     .map(
//                                       (item) => ClipRRect(
//                                         borderRadius: BorderRadius.circular(
//                                             width * 0.025),
//                                         child: item.contains('http')
//                                             ? Image.network(
//                                                 item,
//                                                 fit: BoxFit.cover,
//                                                 width: width,
//                                                 errorBuilder: (context, error,
//                                                         stackTrace) =>
//                                                     Image.asset(
//                                                   'assets/images/chair.png',
//                                                   fit: BoxFit.cover,
//                                                   width: width,
//                                                 ),
//                                               )
//                                             : Image.asset(
//                                                 item,
//                                                 fit: BoxFit.cover,
//                                                 width: width,
//                                               ),
//                                       ),
//                                     )
//                                     .toList(),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.06,
//                                       vertical: height * 0.005,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red.shade300,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.03),
//                                     ),
//                                     child: Text(
//                                       biddingOrder!.address,
//                                       style: GoogleFonts.roboto(
//                                           color: Colors.white,
//                                           fontSize: width * 0.03),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   biddingOrder!.title,
//                                   style: TextStyle(
//                                       fontSize: width * 0.045,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Complete: ${biddingOrder!.deadline.split('T').first}',
//                                   style: TextStyle(
//                                       fontSize: width * 0.035,
//                                       color: Colors.grey),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   '₹${biddingOrder!.cost.toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                       fontSize: width * 0.05,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Task Details',
//                                   style: TextStyle(
//                                       fontSize: width * 0.04,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   biddingOrder!.description,
//                                   style: TextStyle(fontSize: width * 0.035),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               // Bid button and below remains same
//                               Center(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
//                                         return AlertDialog(
//                                           backgroundColor: Colors.white,
//                                           insetPadding: EdgeInsets.symmetric(
//                                               horizontal: width * 0.05),
//                                           title: Center(
//                                               child: Text(
//                                             "Bid",
//                                             style: GoogleFonts.roboto(
//                                               fontSize: width * 0.05,
//                                               color: Colors.black,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           )),
//                                           content: SingleChildScrollView(
//                                             child: SizedBox(
//                                               width: width * 0.8,
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text("Enter Amount",
//                                                       style: GoogleFonts.roboto(
//                                                         fontSize: width * 0.035,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       )),
//                                                   SizedBox(
//                                                       height: height * 0.005),
//                                                   TextField(
//                                                     decoration: InputDecoration(
//                                                       hintText: "\$0.00",
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
//                                                   Text("Description",
//                                                       style: GoogleFonts.roboto(
//                                                         fontSize: width * 0.035,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       )),
//                                                   SizedBox(
//                                                       height: height * 0.005),
//                                                   TextField(
//                                                     maxLines: 3,
//                                                     decoration: InputDecoration(
//                                                       hintText:
//                                                           "Enter description here",
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
//                                                     child: Container(
//                                                       padding:
//                                                           EdgeInsets.symmetric(
//                                                               horizontal:
//                                                                   width * 0.18,
//                                                               vertical: height *
//                                                                   0.012),
//                                                       decoration: BoxDecoration(
//                                                         color: Colors
//                                                             .green.shade700,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                     width *
//                                                                         0.02),
//                                                       ),
//                                                       child: Text("Bid",
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.white,
//                                                               fontSize:
//                                                                   width * 0.04,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold)),
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: width * 0.18,
//                                         vertical: height * 0.012),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       "Bid",
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: width * 0.04,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: width * 0.17,
//                                         vertical: height * 0.015),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text('Bidders',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: width * 0.035)),
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: width * 0.11,
//                                         vertical: height * 0.015),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text('Related Worker',
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: width * 0.035)),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Card(
//                                 color: Colors.white,
//                                 child: Container(
//                                   width: width,
//                                   padding: EdgeInsets.all(width * 0.04),
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: width,
//                                         padding: EdgeInsets.all(width * 0.015),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade100,
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   border: Border.all(
//                                                       color: Colors.green),
//                                                   color: Colors.white,
//                                                 ),
//                                                 child: Text("Offer Price(120)",
//                                                     style: TextStyle(
//                                                         color: Colors.green,
//                                                         fontSize:
//                                                             width * 0.04)),
//                                               ),
//                                             ),
//                                             SizedBox(width: width * 0.015),
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   color: Colors.green.shade700,
//                                                 ),
//                                                 child: Text("Negotiate",
//                                                     style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize:
//                                                             width * 0.04)),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           border:
//                                               Border.all(color: Colors.green),
//                                           color: Colors.white,
//                                         ),
//                                         child: Text("Enter your offer amount",
//                                             style: GoogleFonts.roboto(
//                                                 color: Colors.green.shade700,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: width * 0.04)),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade700,
//                                         ),
//                                         child: Text("Send request",
//                                             style: GoogleFonts.roboto(
//                                                 color: Colors.white,
//                                                 fontSize: width * 0.04)),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }
// import 'dart:convert';
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Widgets/AppColors.dart';
// import '../Models/bidding_order.dart'; // Import BiddingOrder and UserId classes
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
//   BiddingOrder? biddingOrder;
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBiddingOrder();
//   }
//
//   Future<void> fetchBiddingOrder() async {
//     try {
//       // Retrieve token from SharedPreferences
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
//       print('🔐 Using Token: $token');
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
//       print('📥 Bidding Order Response Status: ${response.statusCode}');
//       print('📥 Bidding Order Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           setState(() {
//             biddingOrder = BiddingOrder.fromJson(jsonData['data']);
//             isLoading = false;
//           });
//           print('✅ Parsed Bidding Order: ${biddingOrder!.title}');
//           print('✅ Image URLs: ${biddingOrder!.imageUrls}');
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
//         // Optionally, redirect to login screen
//         // Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         setState(() {
//           errorMessage = 'Error: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('❌ API Exception: $e');
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
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
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(width * 0.02),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: height * 0.01),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child:
//                                     Icon(Icons.arrow_back, size: width * 0.06),
//                               ),
//                             ),
//                             SizedBox(width: width * 0.25),
//                             Text(
//                               "Work detail",
//                               style: GoogleFonts.roboto(
//                                 fontSize: width * 0.045,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: height * 0.01),
//                         Padding(
//                           padding: EdgeInsets.all(width * 0.02),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CarouselSlider(
//                                 options: CarouselOptions(
//                                   height: height * 0.25,
//                                   enlargeCenterPage: true,
//                                   autoPlay: true,
//                                   viewportFraction: 1,
//                                 ),
//                                 items: biddingOrder!.imageUrls.isNotEmpty
//                                     ? biddingOrder!.imageUrls.map((item) {
//                                         print('🖼️ Loading image: $item');
//                                         return ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.025),
//                                           child: Image.network(
//                                             item, // Use the URL directly as it already includes the base URL
//                                             fit: BoxFit.cover,
//                                             width: width,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) {
//                                               print(
//                                                   '❌ Error loading image: $item, Error: $error');
//                                               return Image.asset(
//                                                 'assets/images/chair.png',
//                                                 fit: BoxFit.cover,
//                                                 width: width,
//                                               );
//                                             },
//                                           ),
//                                         );
//                                       }).toList()
//                                     : [
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.025),
//                                           child: Image.asset(
//                                             'assets/images/chair.png',
//                                             fit: BoxFit.cover,
//                                             width: width,
//                                           ),
//                                         ),
//                                       ],
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.06,
//                                       vertical: height * 0.005,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red.shade300,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.03),
//                                     ),
//                                     child: Text(
//                                       biddingOrder!.address,
//                                       style: GoogleFonts.roboto(
//                                         color: Colors.white,
//                                         fontSize: width * 0.03,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   biddingOrder!.title,
//                                   style: TextStyle(
//                                     fontSize: width * 0.045,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Complete: ${biddingOrder!.deadline.split('T').first}',
//                                   style: TextStyle(
//                                     fontSize: width * 0.035,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   '₹${biddingOrder!.cost.toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                     fontSize: width * 0.05,
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Task Details',
//                                   style: TextStyle(
//                                     fontSize: width * 0.04,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: biddingOrder!.description
//                                       .split('.')
//                                       .where((s) => s.trim().isNotEmpty)
//                                       .map((s) => Padding(
//                                             padding: EdgeInsets.only(
//                                                 bottom: height * 0.004),
//                                             child: Text(
//                                               '• $s',
//                                               style: TextStyle(
//                                                   fontSize: width * 0.035),
//                                             ),
//                                           ))
//                                       .toList(),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Center(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
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
//                                                     maxLines: 3,
//                                                     decoration: InputDecoration(
//                                                       hintText:
//                                                           "Enter description here",
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
//                                                     child: Container(
//                                                       padding:
//                                                           EdgeInsets.symmetric(
//                                                         horizontal:
//                                                             width * 0.18,
//                                                         vertical:
//                                                             height * 0.012,
//                                                       ),
//                                                       decoration: BoxDecoration(
//                                                         color: Colors
//                                                             .green.shade700,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                     width *
//                                                                         0.02),
//                                                       ),
//                                                       child: Text(
//                                                         "Bid",
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize:
//                                                               width * 0.04,
//                                                           fontWeight:
//                                                               FontWeight.bold,
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
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.18,
//                                       vertical: height * 0.012,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       "Bid",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.04,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.17,
//                                       vertical: height * 0.015,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       'Bidders',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.035,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.11,
//                                       vertical: height * 0.015,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       'Related Worker',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.035,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Card(
//                                 color: Colors.white,
//                                 child: Container(
//                                   width: width,
//                                   padding: EdgeInsets.all(width * 0.04),
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: width,
//                                         padding: EdgeInsets.all(width * 0.015),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade100,
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   border: Border.all(
//                                                       color: Colors.green),
//                                                   color: Colors.white,
//                                                 ),
//                                                 child: Text(
//                                                   "Offer Price(120)",
//                                                   style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontSize: width * 0.04,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: width * 0.015),
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   color: Colors.green.shade700,
//                                                 ),
//                                                 child: Text(
//                                                   "Negotiate",
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: width * 0.04,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           border:
//                                               Border.all(color: Colors.green),
//                                           color: Colors.white,
//                                         ),
//                                         child: Text(
//                                           "Enter your offer amount",
//                                           style: GoogleFonts.roboto(
//                                             color: Colors.green.shade700,
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: width * 0.04,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade700,
//                                         ),
//                                         child: Text(
//                                           "Send request",
//                                           style: GoogleFonts.roboto(
//                                             color: Colors.white,
//                                             fontSize: width * 0.04,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }
//
// import 'dart:convert';
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
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
//   final List<Map<String, dynamic>> bidders = [
//     {
//       'name': 'Dipak Sharma',
//       'amount': '₹2000.00',
//       'location': 'Indore M.P.',
//       'rating': 4.5,
//       'viewed': false,
//     },
//     {
//       'name': 'Dipak Sharma',
//       'amount': '₹2000.00',
//       'location': 'Indore M.P.',
//       'rating': 4.5,
//       'viewed': true,
//     },
//     {
//       'name': 'Dipak Sharma',
//       'amount': '₹2000.00',
//       'location': 'Indore M.P.',
//       'rating': 4.5,
//       'viewed': true,
//     },
//   ];
//
//   final List<Map<String, dynamic>> relatedWorkers = [
//     // Add similar data structure for related workers if available
//     {
//       'name': 'Worker 1',
//       'amount': '₹1500.00',
//       'location': 'Indore M.P.',
//       'rating': 4.0,
//       'viewed': false,
//     },
//   ];
//   BiddingOrder? biddingOrder;
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBiddingOrder();
//   }
//
//   Future<void> fetchBiddingOrder() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         setState(() {
//           errorMessage = 'Koi token nahi mila. Dobara login karo.';
//           isLoading = false;
//         });
//         print('❌ Token nahi mila SharedPreferences mein');
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
//         } else {
//           setState(() {
//             errorMessage = jsonData['message'] ?? 'Data fetch nahi hua';
//             isLoading = false;
//           });
//         }
//       } else if (response.statusCode == 401) {
//         setState(() {
//           errorMessage = 'Unauthorized: Dobara login karo.';
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
//   Future<void> submitBid(
//       String amount, String description, String duration) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print('🔐 Token: $token');
//       if (token.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Token nahi mila. Login karo.')),
//         );
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }
//
//       final payload = {
//         'order_id': '68691ef349e1aca49f73dcff',
//         'bid_amount': amount,
//         'duration': duration,
//         'message': description,
//       };
//       print('📦 Sending Payload: ${jsonEncode(payload)}');
//
//       final response = await http.put(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/updateBiddingOffer'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📤 Response Status: ${response.statusCode}');
//       print('📤 Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     jsonData['message'] ?? 'Bid successfully submit ho gaya!')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(jsonData['message'] ?? 'Bid submit nahi hua')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Error: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('❌ Bid Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Bid submit karne mein error: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     final TextEditingController amountController = TextEditingController();
//     final TextEditingController durationController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
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
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(width * 0.02),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: height * 0.01),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child:
//                                     Icon(Icons.arrow_back, size: width * 0.06),
//                               ),
//                             ),
//                             SizedBox(width: width * 0.25),
//                             Text(
//                               "Work detail",
//                               style: GoogleFonts.roboto(
//                                 fontSize: width * 0.045,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: height * 0.01),
//                         Padding(
//                           padding: EdgeInsets.all(width * 0.02),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CarouselSlider(
//                                 options: CarouselOptions(
//                                   height: height * 0.25,
//                                   enlargeCenterPage: true,
//                                   autoPlay: true,
//                                   viewportFraction: 1,
//                                 ),
//                                 items: biddingOrder!.imageUrls.isNotEmpty
//                                     ? biddingOrder!.imageUrls.map((item) {
//                                         print('🖼️ Image: $item');
//                                         return ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.025),
//                                           child: Image.network(
//                                             item,
//                                             fit: BoxFit.cover,
//                                             width: width,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) {
//                                               print(
//                                                   '❌ Image error: $item, Error: $error');
//                                               return Image.asset(
//                                                 'assets/images/chair.png',
//                                                 fit: BoxFit.cover,
//                                                 width: width,
//                                               );
//                                             },
//                                           ),
//                                         );
//                                       }).toList()
//                                     : [
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.025),
//                                           child: Image.asset(
//                                             'assets/images/chair.png',
//                                             fit: BoxFit.cover,
//                                             width: width,
//                                           ),
//                                         ),
//                                       ],
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.06,
//                                       vertical: height * 0.005,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red.shade300,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.03),
//                                     ),
//                                     child: Text(
//                                       biddingOrder!.address,
//                                       style: GoogleFonts.roboto(
//                                         color: Colors.white,
//                                         fontSize: width * 0.03,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   biddingOrder!.title,
//                                   style: TextStyle(
//                                     fontSize: width * 0.045,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Complete: ${biddingOrder!.deadline.split('T').first}',
//                                   style: TextStyle(
//                                     fontSize: width * 0.035,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   '₹${biddingOrder!.cost.toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                     fontSize: width * 0.05,
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Task Details',
//                                   style: TextStyle(
//                                     fontSize: width * 0.04,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: biddingOrder!.description
//                                       .split('.')
//                                       .where((s) => s.trim().isNotEmpty)
//                                       .map((s) => Padding(
//                                             padding: EdgeInsets.only(
//                                                 bottom: height * 0.004),
//                                             child: Text(
//                                               '• $s',
//                                               style: TextStyle(
//                                                   fontSize: width * 0.035),
//                                             ),
//                                           ))
//                                       .toList(),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Center(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
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
//                                                         if (amount.isEmpty ||
//                                                             description
//                                                                 .isEmpty ||
//                                                             duration.isEmpty) {
//                                                           ScaffoldMessenger.of(
//                                                                   context)
//                                                               .showSnackBar(
//                                                             SnackBar(
//                                                                 content: Text(
//                                                                     'Please fill from')),
//                                                           );
//                                                           return;
//                                                         }
//                                                         submitBid(
//                                                             amount,
//                                                             description,
//                                                             duration);
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
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.18,
//                                       vertical: height * 0.012,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       "Bid",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.04,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Card(
//                                 color: Colors.white,
//                                 child: Container(
//                                   width: width,
//                                   padding: EdgeInsets.all(width * 0.04),
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: width,
//                                         padding: EdgeInsets.all(width * 0.015),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade100,
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   border: Border.all(
//                                                       color: Colors.green),
//                                                   color: Colors.white,
//                                                 ),
//                                                 child: Text(
//                                                   "Offer Price(120)",
//                                                   style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontSize: width * 0.04,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: width * 0.015),
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   color: Colors.green.shade700,
//                                                 ),
//                                                 child: Text(
//                                                   "Negotiate",
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: width * 0.04,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           border:
//                                               Border.all(color: Colors.green),
//                                           color: Colors.white,
//                                         ),
//                                         child: Text(
//                                           "Enter your offer amount",
//                                           style: GoogleFonts.roboto(
//                                             color: Colors.green.shade700,
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: width * 0.04,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade700,
//                                         ),
//                                         child: Text(
//                                           "Send request",
//                                           style: GoogleFonts.roboto(
//                                             color: Colors.white,
//                                             fontSize: width * 0.04,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.17,
//                                       vertical: height * 0.015,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       'Bidders',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.035,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.11,
//                                       vertical: height * 0.015,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       'Related Worker',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.035,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }
//
// import 'dart:convert';
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
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
//   final List<Map<String, dynamic>> bidders = [
//     {
//       'name': 'Dipak Sharma',
//       'amount': '₹2000.00',
//       'location': 'Indore M.P.',
//       'rating': 4.5,
//       'viewed': false,
//     },
//   ];
//
//   final List<Map<String, dynamic>> relatedWorkers = [
//     {
//       'name': 'Worker 1',
//       'amount': '₹1500.00',
//       'location': 'Indore M.P.',
//       'rating': 4.0,
//       'viewed': false,
//     },
//   ];
//   BiddingOrder? biddingOrder;
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBiddingOrder();
//   }
//
//   Future<void> fetchBiddingOrder() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         setState(() {
//           errorMessage = 'Koi token nahi mila. Dobara login karo.';
//           isLoading = false;
//         });
//         print('❌ Token nahi mila SharedPreferences mein');
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
//         } else {
//           setState(() {
//             errorMessage = jsonData['message'] ?? 'Data fetch nahi hua';
//             isLoading = false;
//           });
//         }
//       } else if (response.statusCode == 401) {
//         setState(() {
//           errorMessage = 'Unauthorized: Dobara login karo.';
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
//   Future<void> submitBid(
//       String amount, String description, String duration) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print('🔐 Token: $token');
//       if (token.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Token nahi mila. Login karo.')),
//         );
//         Navigator.pushReplacementNamed(context, '/login');
//         return;
//       }
//
//       final payload = {
//         'order_id': '68691ef349e1aca49f73dcff',
//         'bid_amount': amount,
//         'duration': duration,
//         'message': description,
//       };
//       print('📦 Sending Payload: ${jsonEncode(payload)}');
//
//       final response = await http.put(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/updateBiddingOffer'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//
//       print('📤 Response Status: ${response.statusCode}');
//       print('📤 Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     jsonData['message'] ?? 'Bid successfully submit ho gaya!')),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(jsonData['message'] ?? 'Bid submit nahi hua')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Error: ${response.statusCode} - ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('❌ Bid Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Bid submit karne mein error: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     final TextEditingController amountController = TextEditingController();
//     final TextEditingController durationController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
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
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(width * 0.02),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: height * 0.01),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child:
//                                     Icon(Icons.arrow_back, size: width * 0.06),
//                               ),
//                             ),
//                             SizedBox(width: width * 0.25),
//                             Text(
//                               "Work detail",
//                               style: GoogleFonts.roboto(
//                                 fontSize: width * 0.045,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: height * 0.01),
//                         Padding(
//                           padding: EdgeInsets.all(width * 0.02),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               CarouselSlider(
//                                 options: CarouselOptions(
//                                   height: height * 0.25,
//                                   enlargeCenterPage: true,
//                                   autoPlay: true,
//                                   viewportFraction: 1,
//                                 ),
//                                 items: biddingOrder!.imageUrls.isNotEmpty
//                                     ? biddingOrder!.imageUrls.map((item) {
//                                         print('🖼️ Image: $item');
//                                         return ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.025),
//                                           child: Image.network(
//                                             item,
//                                             fit: BoxFit.cover,
//                                             width: width,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) {
//                                               print(
//                                                   '❌ Image error: $item, Error: $error');
//                                               return Image.asset(
//                                                 'assets/images/chair.png',
//                                                 fit: BoxFit.cover,
//                                                 width: width,
//                                               );
//                                             },
//                                           ),
//                                         );
//                                       }).toList()
//                                     : [
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.025),
//                                           child: Image.asset(
//                                             'assets/images/chair.png',
//                                             fit: BoxFit.cover,
//                                             width: width,
//                                           ),
//                                         ),
//                                       ],
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.06,
//                                       vertical: height * 0.005,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red.shade300,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.03),
//                                     ),
//                                     child: Text(
//                                       biddingOrder!.address,
//                                       style: GoogleFonts.roboto(
//                                         color: Colors.white,
//                                         fontSize: width * 0.03,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   biddingOrder!.title,
//                                   style: TextStyle(
//                                     fontSize: width * 0.045,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Complete: ${biddingOrder!.deadline.split('T').first}',
//                                   style: TextStyle(
//                                     fontSize: width * 0.035,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   '₹${biddingOrder!.cost.toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                     fontSize: width * 0.05,
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.015),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Text(
//                                   'Task Details',
//                                   style: TextStyle(
//                                     fontSize: width * 0.04,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.005),
//                               Padding(
//                                 padding: EdgeInsets.only(left: width * 0.02),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: biddingOrder!.description
//                                       .split('.')
//                                       .where((s) => s.trim().isNotEmpty)
//                                       .map((s) => Padding(
//                                             padding: EdgeInsets.only(
//                                                 bottom: height * 0.004),
//                                             child: Text(
//                                               '• $s',
//                                               style: TextStyle(
//                                                   fontSize: width * 0.035),
//                                             ),
//                                           ))
//                                       .toList(),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Center(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
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
//                                                         if (amount.isEmpty ||
//                                                             description
//                                                                 .isEmpty ||
//                                                             duration.isEmpty) {
//                                                           ScaffoldMessenger.of(
//                                                                   context)
//                                                               .showSnackBar(
//                                                             SnackBar(
//                                                                 content: Text(
//                                                                     'Please fill all fields')),
//                                                           );
//                                                           return;
//                                                         }
//                                                         submitBid(
//                                                             amount,
//                                                             description,
//                                                             duration);
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
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: width * 0.18,
//                                       vertical: height * 0.012,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                           BorderRadius.circular(width * 0.02),
//                                     ),
//                                     child: Text(
//                                       "Bid",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: width * 0.04,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Card(
//                                 color: Colors.white,
//                                 child: Container(
//                                   width: width,
//                                   padding: EdgeInsets.all(width * 0.04),
//                                   child: Column(
//                                     children: [
//                                       Container(
//                                         width: width,
//                                         padding: EdgeInsets.all(width * 0.015),
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade100,
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   border: Border.all(
//                                                       color: Colors.green),
//                                                   color: Colors.white,
//                                                 ),
//                                                 child: Text(
//                                                   "Offer Price(120)",
//                                                   style: TextStyle(
//                                                     color: Colors.green,
//                                                     fontSize: width * 0.04,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: width * 0.015),
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     vertical: height * 0.015),
//                                                 alignment: Alignment.center,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           width * 0.02),
//                                                   color: Colors.green.shade700,
//                                                 ),
//                                                 child: Text(
//                                                   "Negotiate",
//                                                   style: TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: width * 0.04,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           border:
//                                               Border.all(color: Colors.green),
//                                           color: Colors.white,
//                                         ),
//                                         child: Text(
//                                           "Enter your offer amount",
//                                           style: GoogleFonts.roboto(
//                                             color: Colors.green.shade700,
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: width * 0.04,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: height * 0.02),
//                                       Container(
//                                         padding: EdgeInsets.symmetric(
//                                             vertical: height * 0.018),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               width * 0.02),
//                                           color: Colors.green.shade700,
//                                         ),
//                                         child: Text(
//                                           "Send request",
//                                           style: GoogleFonts.roboto(
//                                             color: Colors.white,
//                                             fontSize: width * 0.04,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.02),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: width * 0.05),
//                                 child: Column(
//                                   children: [
//                                     SizedBox(height: height * 0.015),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//                                             setState(() {
//                                               _selectedIndex =
//                                                   0; // Bidders tab select
//                                             });
//                                           },
//                                           child: Container(
//                                             height: height * 0.045,
//                                             width: width * 0.40,
//                                             decoration: BoxDecoration(
//                                               color: _selectedIndex == 0
//                                                   ? Colors.green.shade700
//                                                   : Colors.grey.shade300,
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: Center(
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   SizedBox(width: width * 0.02),
//                                                   Text(
//                                                     "Bidders",
//                                                     style: TextStyle(
//                                                       color: _selectedIndex == 0
//                                                           ? Colors.white
//                                                           : Colors
//                                                               .grey.shade700,
//                                                       fontSize: width * 0.05,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(width: width * 0.0),
//                                         InkWell(
//                                           onTap: () {
//                                             setState(() {
//                                               _selectedIndex =
//                                                   1; // Related Worker tab select
//                                             });
//                                           },
//                                           child: Container(
//                                             height: height * 0.045,
//                                             width: width * 0.40,
//                                             decoration: BoxDecoration(
//                                               color: _selectedIndex == 1
//                                                   ? Colors.green.shade700
//                                                   : Colors.grey.shade300,
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: Center(
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   SizedBox(width: width * 0.02),
//                                                   Text(
//                                                     "Related Worker",
//                                                     style: TextStyle(
//                                                       color: _selectedIndex == 1
//                                                           ? Colors.white
//                                                           : Colors
//                                                               .grey.shade700,
//                                                       fontSize: width * 0.04,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     if (_selectedIndex == 0)
//                                       Padding(
//                                         padding:
//                                             EdgeInsets.only(top: height * 0.01),
//                                         child: ListView.builder(
//                                           shrinkWrap: true,
//                                           physics:
//                                               const NeverScrollableScrollPhysics(),
//                                           itemCount: bidders
//                                               .length, // Use dynamic length
//                                           itemBuilder: (context, index) {
//                                             final bidder = bidders[index];
//                                             return Container(
//                                               margin: EdgeInsets.symmetric(
//                                                 vertical: height * 0.01,
//                                                 horizontal: width * 0.01,
//                                               ),
//                                               padding:
//                                                   EdgeInsets.all(width * 0.02),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white,
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.grey
//                                                         .withOpacity(0.2),
//                                                     spreadRadius: 1,
//                                                     blurRadius: 5,
//                                                     offset: const Offset(0, 3),
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: Row(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8),
//                                                     child: Image.asset(
//                                                       "assets/images/account1.png",
//                                                       height: 90,
//                                                       width: 90,
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   SizedBox(width: width * 0.03),
//                                                   Expanded(
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Flexible(
//                                                               child: Text(
//                                                                 bidder['name'],
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.045,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 maxLines: 1,
//                                                               ),
//                                                             ),
//                                                             Row(
//                                                               children: [
//                                                                 Text(
//                                                                   "${bidder['rating']}",
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         width *
//                                                                             0.035,
//                                                                   ),
//                                                                 ),
//                                                                 Icon(
//                                                                   Icons.star,
//                                                                   size: width *
//                                                                       0.04,
//                                                                   color: Colors
//                                                                       .yellow
//                                                                       .shade700,
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Text(
//                                                               bidder['amount'],
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     width *
//                                                                         0.04,
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                               ),
//                                                             ),
//                                                             SizedBox(
//                                                                 width: width *
//                                                                     0.10),
//                                                             Expanded(
//                                                               child: Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       CircleAvatar(
//                                                                         radius:
//                                                                             13,
//                                                                         backgroundColor: Colors
//                                                                             .grey
//                                                                             .shade300,
//                                                                         child:
//                                                                             Icon(
//                                                                           Icons
//                                                                               .phone,
//                                                                           size:
//                                                                               18,
//                                                                           color: Colors
//                                                                               .green
//                                                                               .shade600,
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         SizedBox(
//                                                             height:
//                                                                 height * 0.005),
//                                                         Row(
//                                                           children: [
//                                                             Flexible(
//                                                               child: Container(
//                                                                 height: 22,
//                                                                 constraints:
//                                                                     BoxConstraints(
//                                                                   maxWidth:
//                                                                       width *
//                                                                           0.25,
//                                                                 ),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .red
//                                                                       .shade300,
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               10),
//                                                                 ),
//                                                                 child: Center(
//                                                                   child: Text(
//                                                                     bidder[
//                                                                         'location'],
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           width *
//                                                                               0.033,
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     maxLines: 1,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             SizedBox(
//                                                                 width: width *
//                                                                     0.03),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .only(
//                                                                       top: 8.0),
//                                                               child:
//                                                                   CircleAvatar(
//                                                                 radius: 13,
//                                                                 backgroundColor:
//                                                                     Colors.grey
//                                                                         .shade300,
//                                                                 child: Icon(
//                                                                   Icons.message,
//                                                                   size: 18,
//                                                                   color: Colors
//                                                                       .green
//                                                                       .shade600,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             TextButton(
//                                                               onPressed: () {},
//                                                               style: TextButton
//                                                                   .styleFrom(
//                                                                 padding:
//                                                                     EdgeInsets
//                                                                         .zero,
//                                                                 minimumSize:
//                                                                     Size(0, 25),
//                                                                 tapTargetSize:
//                                                                     MaterialTapTargetSize
//                                                                         .shrinkWrap,
//                                                               ),
//                                                               child: Text(
//                                                                 "View Profile",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.032,
//                                                                   color: Colors
//                                                                       .green
//                                                                       .shade700,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Flexible(
//                                                               child: Container(
//                                                                 height: 32,
//                                                                 constraints:
//                                                                     BoxConstraints(
//                                                                   maxWidth:
//                                                                       width *
//                                                                           0.2,
//                                                                 ),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .green
//                                                                       .shade700,
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               8),
//                                                                 ),
//                                                                 child: Center(
//                                                                   child: Text(
//                                                                     "Accept",
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           width *
//                                                                               0.032,
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     maxLines: 1,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     if (_selectedIndex == 1)
//                                       Padding(
//                                         padding:
//                                             EdgeInsets.only(top: height * 0.01),
//                                         child: ListView.builder(
//                                           shrinkWrap: true,
//                                           physics:
//                                               const NeverScrollableScrollPhysics(),
//                                           itemCount: relatedWorkers
//                                               .length, // Use dynamic length
//                                           itemBuilder: (context, index) {
//                                             final worker =
//                                                 relatedWorkers[index];
//                                             return Container(
//                                               margin: EdgeInsets.symmetric(
//                                                 vertical: height * 0.01,
//                                                 horizontal: width * 0.01,
//                                               ),
//                                               padding:
//                                                   EdgeInsets.all(width * 0.02),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white,
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.grey
//                                                         .withOpacity(0.2),
//                                                     spreadRadius: 1,
//                                                     blurRadius: 5,
//                                                     offset: const Offset(0, 3),
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: Row(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8),
//                                                     child: Image.asset(
//                                                       "assets/images/account1.png",
//                                                       height: 90,
//                                                       width: 90,
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   SizedBox(width: width * 0.03),
//                                                   Expanded(
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             Flexible(
//                                                               child: Text(
//                                                                 worker['name'],
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.045,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 maxLines: 1,
//                                                               ),
//                                                             ),
//                                                             Row(
//                                                               children: [
//                                                                 Text(
//                                                                   "${worker['rating']}",
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         width *
//                                                                             0.035,
//                                                                   ),
//                                                                 ),
//                                                                 Icon(
//                                                                   Icons.star,
//                                                                   size: width *
//                                                                       0.04,
//                                                                   color: Colors
//                                                                       .yellow
//                                                                       .shade700,
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Row(
//                                                           children: [
//                                                             Text(
//                                                               worker['amount'],
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     width *
//                                                                         0.04,
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                               ),
//                                                             ),
//                                                             SizedBox(
//                                                                 width: width *
//                                                                     0.10),
//                                                             Expanded(
//                                                               child: Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       CircleAvatar(
//                                                                         radius:
//                                                                             13,
//                                                                         backgroundColor: Colors
//                                                                             .grey
//                                                                             .shade300,
//                                                                         child:
//                                                                             Icon(
//                                                                           Icons
//                                                                               .phone,
//                                                                           size:
//                                                                               18,
//                                                                           color: Colors
//                                                                               .green
//                                                                               .shade600,
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         SizedBox(
//                                                             height:
//                                                                 height * 0.005),
//                                                         Row(
//                                                           children: [
//                                                             Flexible(
//                                                               child: Container(
//                                                                 height: 22,
//                                                                 constraints:
//                                                                     BoxConstraints(
//                                                                   maxWidth:
//                                                                       width *
//                                                                           0.25,
//                                                                 ),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .red
//                                                                       .shade300,
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               10),
//                                                                 ),
//                                                                 child: Center(
//                                                                   child: Text(
//                                                                     worker[
//                                                                         'location'],
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           width *
//                                                                               0.033,
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     maxLines: 1,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             SizedBox(
//                                                                 width: width *
//                                                                     0.03),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .only(
//                                                                       top: 8.0),
//                                                               child:
//                                                                   CircleAvatar(
//                                                                 radius: 13,
//                                                                 backgroundColor:
//                                                                     Colors.grey
//                                                                         .shade300,
//                                                                 child: Icon(
//                                                                   Icons.message,
//                                                                   size: 18,
//                                                                   color: Colors
//                                                                       .green
//                                                                       .shade600,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceBetween,
//                                                           children: [
//                                                             TextButton(
//                                                               onPressed: () {},
//                                                               style: TextButton
//                                                                   .styleFrom(
//                                                                 padding:
//                                                                     EdgeInsets
//                                                                         .zero,
//                                                                 minimumSize:
//                                                                     Size(0, 25),
//                                                                 tapTargetSize:
//                                                                     MaterialTapTargetSize
//                                                                         .shrinkWrap,
//                                                               ),
//                                                               child: Text(
//                                                                 "View Profile",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       width *
//                                                                           0.032,
//                                                                   color: Colors
//                                                                       .green
//                                                                       .shade700,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Flexible(
//                                                               child: Container(
//                                                                 height: 32,
//                                                                 constraints:
//                                                                     BoxConstraints(
//                                                                   maxWidth:
//                                                                       width *
//                                                                           0.2,
//                                                                 ),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .green
//                                                                       .shade700,
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               8),
//                                                                 ),
//                                                                 child: Center(
//                                                                   child: Text(
//                                                                     "Accept",
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           width *
//                                                                               0.032,
//                                                                       color: Colors
//                                                                           .white,
//                                                                     ),
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                     maxLines: 1,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     SizedBox(height: height * 0.02),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.01),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widgets/AppColors.dart';
import '../Models/bidding_order.dart'; // BiddingOrder model imported

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
  List<Map<String, dynamic>> bidders = []; // Dynamic bidders list
  final List<Map<String, dynamic>> relatedWorkers = [
    {
      'name': 'Worker 1',
      'amount': '₹1500.00',
      'location': 'Indore M.P.',
      'rating': 4.0,
      'viewed': false,
    },
  ];
  BiddingOrder? biddingOrder;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBiddingOrder();
    fetchBidders(); // New method to fetch bidders
  }

  // Fetch single bidding order details
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

  // Fetch bidding offers for bidders tab
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
            'https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/68691ef349e1aca49f73dcff'),
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
          setState(() {
            bidders = offers.map((offer) {
              return {
                'name': offer['provider_id']['full_name'] ?? 'Unknown',
                'amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
                'location':
                    'Unknown Location', // Location not available in API, using default
                'rating': (offer['provider_id']['rating'] ?? 0).toDouble(),
                'status': offer['status'] ?? 'pending',
                'viewed': false,
              };
            }).toList();
            isLoading = false;
          });
          print('✅ Bidders fetched: ${bidders.length}');
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

  Future<void> submitBid(
      String amount, String description, String duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print('🔐 Token: $token');
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No token found. Please log in.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final payload = {
        'order_id': "68691ef349e1aca49f73dcff", // Use dynamic orderId
        'bid_amount': amount,
        'duration': duration,
        'message': description,
      };
      print('📦 Sending Payload: ${jsonEncode(payload)}');

      final response = await http.put(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/updateBiddingOffer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📤 Response Status: ${response.statusCode}');
      print('📤 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(jsonData['message'] ?? 'Bid successfully submitted!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(jsonData['message'] ?? 'Failed to submit bid')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      print('❌ Bid Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting bid: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final TextEditingController amountController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: height * 0.03,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
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
                                child:
                                    Icon(Icons.arrow_back, size: width * 0.06),
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
                                          borderRadius: BorderRadius.circular(
                                              width * 0.025),
                                          child: Image.network(
                                            item,
                                            fit: BoxFit.cover,
                                            width: width,
                                            errorBuilder:
                                                (context, error, stackTrace) {
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
                                          borderRadius: BorderRadius.circular(
                                              width * 0.025),
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
                                      borderRadius:
                                          BorderRadius.circular(width * 0.03),
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
                                            padding: EdgeInsets.only(
                                                bottom: height * 0.004),
                                            child: Text(
                                              '• $s',
                                              style: TextStyle(
                                                  fontSize: width * 0.035),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
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
                                                        if (amount.isEmpty ||
                                                            description
                                                                .isEmpty ||
                                                            duration.isEmpty) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Please fill all fields')),
                                                          );
                                                          return;
                                                        }
                                                        submitBid(
                                                            amount,
                                                            description,
                                                            duration);
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
                                      color: Colors.green.shade700,
                                      borderRadius:
                                          BorderRadius.circular(width * 0.02),
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
                              Card(
                                color: Colors.white,
                                child: Container(
                                  width: width,
                                  padding: EdgeInsets.all(width * 0.04),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: width,
                                        padding: EdgeInsets.all(width * 0.015),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              width * 0.02),
                                          color: Colors.green.shade100,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.015),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          width * 0.02),
                                                  border: Border.all(
                                                      color: Colors.green),
                                                  color: Colors.white,
                                                ),
                                                child: Text(
                                                  "Offer Price(120)",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: width * 0.04,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: width * 0.015),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.015),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          width * 0.02),
                                                  color: Colors.green.shade700,
                                                ),
                                                child: Text(
                                                  "Negotiate",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * 0.04,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: height * 0.02),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: height * 0.018),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              width * 0.02),
                                          border:
                                              Border.all(color: Colors.green),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          "Enter your offer amount",
                                          style: GoogleFonts.roboto(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: width * 0.04,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: height * 0.02),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: height * 0.018),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              width * 0.02),
                                          color: Colors.green.shade700,
                                        ),
                                        child: Text(
                                          "Send request",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: width * 0.04,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.05),
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
                                              _selectedIndex =
                                                  0; // Bidders tab select
                                            });
                                          },
                                          child: Container(
                                            height: height * 0.045,
                                            width: width * 0.40,
                                            decoration: BoxDecoration(
                                              color: _selectedIndex == 0
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                          : Colors
                                                              .grey.shade700,
                                                      fontSize: width * 0.05,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                              _selectedIndex =
                                                  1; // Related Worker tab select
                                            });
                                          },
                                          child: Container(
                                            height: height * 0.045,
                                            width: width * 0.40,
                                            decoration: BoxDecoration(
                                              color: _selectedIndex == 1
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                          : Colors
                                                              .grey.shade700,
                                                      fontSize: width * 0.04,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                        padding:
                                            EdgeInsets.only(top: height * 0.01),
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
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      vertical: height * 0.01,
                                                      horizontal: width * 0.01,
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        width * 0.02),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          spreadRadius: 1,
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: Image.asset(
                                                            "assets/images/account1.png",
                                                            height: 90,
                                                            width: 90,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.03),
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
                                                                      bidder[
                                                                          'name'],
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            width *
                                                                                0.045,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        "${bidder['rating']}",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              width * 0.035,
                                                                        ),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
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
                                                                children: [
                                                                  Text(
                                                                    bidder[
                                                                        'amount'],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          width *
                                                                              0.04,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: width *
                                                                          0.1),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
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
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.005),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: Container(
                                                                        height: 22,
                                                                        constraints: BoxConstraints(
                                                                          maxWidth:
                                                                              width * 0.25,
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .red
                                                                              .shade300,
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        child: Center(
                                                                          child:
                                                                              Container(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            width:
                                                                                double.infinity, // Optional: Ensures it takes full width if needed
                                                                            child:
                                                                                Text(
                                                                              bidder['location'],
                                                                              textAlign: TextAlign.center, // 👈 This is what actually centers text *inside*
                                                                              style: GoogleFonts.roboto(
                                                                                fontSize: width * 0.028,
                                                                                color: Colors.white,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                        )),
                                                                  ),
                                                                  SizedBox(
                                                                      width: width *
                                                                          0.03),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            5.0),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          13,
                                                                      backgroundColor: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .message,
                                                                        size:
                                                                            18,
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
                                                                    onPressed:
                                                                        () {},
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      minimumSize:
                                                                          Size(
                                                                              0,
                                                                              25),
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
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          25,
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
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "Accept",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.032,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
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
                                    if (_selectedIndex == 1)
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: height * 0.01),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: relatedWorkers.length,
                                          itemBuilder: (context, index) {
                                            final worker =
                                                relatedWorkers[index];
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
                                                        BorderRadius.circular(
                                                            8),
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
                                                                style:
                                                                    TextStyle(
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
                                                        Row(
                                                          children: [
                                                            Text(
                                                              worker['amount'],
                                                              style: TextStyle(
                                                                fontSize:
                                                                    width *
                                                                        0.04,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: width *
                                                                    0.10),
                                                            Expanded(
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        radius:
                                                                            13,
                                                                        backgroundColor: Colors
                                                                            .grey
                                                                            .shade300,
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .phone,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .green
                                                                              .shade600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Container(
                                                                height: 22,
                                                                constraints:
                                                                    BoxConstraints(
                                                                  maxWidth:
                                                                      width *
                                                                          0.25,
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
                                                                  child: Text(
                                                                    worker[
                                                                        'location'],
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
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: width *
                                                                    0.03),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0),
                                                              child:
                                                                  CircleAvatar(
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
                                                              onPressed: () {},
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                minimumSize:
                                                                    Size(0, 25),
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
                                                              child: Container(
                                                                height: 28,
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
                                                                    "Accept",
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
                                                                    maxLines: 1,
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
                              SizedBox(height: height * 0.01),
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
