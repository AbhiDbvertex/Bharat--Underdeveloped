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
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../Widgets/AppColors.dart';
import '../Models/bidding_order.dart'; // Import BiddingOrder and UserId classes

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
  BiddingOrder? biddingOrder;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBiddingOrder();
  }

  Future<void> fetchBiddingOrder() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.orderId}'),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NDY4ZTY0NTJhZjc4ZGQ1NGJlYmRhMyIsImlhdCI6MTc1NTc1NTk4NywiZXhwIjoxNzU1ODQyMzg3fQ.iIuarWMAhhPkcdNB4HpxDWMS1aLcACzwxkmnEBtOV6Y',
        },
      );

      print('📥 Bidding Order Response Status: ${response.statusCode}');
      print('📥 Bidding Order Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            biddingOrder = BiddingOrder.fromJson(jsonData['data']);
            isLoading = false;
          });
          print('✅ Parsed Bidding Order: ${biddingOrder!.title}');
          print('✅ Image URLs: ${biddingOrder!.imageUrls}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Failed to fetch data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ API Exception: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
                                        print('🖼️ Loading image: $item');
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              width * 0.025),
                                          child: Image.network(
                                            item, // Use the URL directly as it already includes the base URL
                                            fit: BoxFit.cover,
                                            width: width,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  '❌ Error loading image: $item, Error: $error');
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
                                                    maxLines: 3,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter description here",
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
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            width * 0.18,
                                                        vertical:
                                                            height * 0.012,
                                                      ),
                                                      decoration: BoxDecoration(
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.17,
                                      vertical: height * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade700,
                                      borderRadius:
                                          BorderRadius.circular(width * 0.02),
                                    ),
                                    child: Text(
                                      'Bidders',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.11,
                                      vertical: height * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade700,
                                      borderRadius:
                                          BorderRadius.circular(width * 0.02),
                                    ),
                                    child: Text(
                                      'Related Worker',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
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
