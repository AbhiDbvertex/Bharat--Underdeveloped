// // import 'package:flutter/material.dart';
// // import 'package:url_launcher/url_launcher.dart';
// //
// // void main() {
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: PaymentScreen(),
// //     );
// //   }
// // }
// //
// // class PaymentScreen extends StatelessWidget {
// //   PaymentScreen({super.key});
// //
// //   final TextEditingController amountController = TextEditingController();
// //
// //   Future<void> launchUPI(String amount) async {
// //     final upiId = ""; // apna UPI ID yaha daal
// //     final name = ""; // apna naam ya app ka naam
// //     final note = "Payment from app"; // payment note
// //
// //     final uri = Uri.parse(
// //       "upi://pay?pa=$upiId&pn=$name&tn=$note&am=$amount&cu=INR",
// //     );
// //
// //     if (await canLaunchUrl(uri)) {
// //       await launchUrl(uri, mode: LaunchMode.externalApplication);
// //     } else {
// //       throw "UPI app not found!";
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("UPI Payment"),
// //         centerTitle: true,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             TextField(
// //               controller: amountController,
// //               decoration: const InputDecoration(
// //                 labelText: "Enter Amount",
// //                 border: OutlineInputBorder(),
// //               ),
// //               keyboardType: TextInputType.number,
// //             ),
// //             const SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 String amt = amountController.text.trim();
// //                 if (amt.isNotEmpty) {
// //                   launchUPI(amt);
// //                 } else {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(content: Text("Please enter amount")),
// //                   );
// //                 }
// //               },
// //               child: const Text("Pay Now"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Assuming this is your widget class
// class YourWidget extends StatefulWidget {
//   final String buddingOderId;
//
//   const YourWidget({Key? key, required this.buddingOderId}) : super(key: key);
//
//   @override
//   _YourWidgetState createState() => _YourWidgetState();
// }
//
// class _YourWidgetState extends State<YourWidget> {
//   List<dynamic>? getBuddingOderByIdResponseDatalist;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBiddingOffers();
//   }
//
//   // Function to fetch bidding offers from the API
//   Future<void> fetchBiddingOffers() async {
//     final String apiUrl =
//         "https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.buddingOderId}";
//
//       // final response = await http.get(Uri.parse(apiUrl));
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//
//       try {
//         var response = await http.get(
//           Uri.parse(apiUrl),
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         );
//         if (response.statusCode == 200) {
//           print("Abhi:- getBuddingOderById response: ${response.body}");
//           print("Abhi:- getBuddingOderById status: ${response.statusCode}");
//           final data = json.decode(response.body);
//           if (data['status'] == true) {
//             setState(() {
//               getBuddingOderByIdResponseData = data['data'];
//             });
//           } else {
//             print("Abhi:- getBuddingOderById response: ${response.body}");
//             print("Abhi:- getBuddingOderById status: ${response.statusCode}");
//             print("API Error: ${data['message']}");
//           }
//         } else {
//           print("HTTP Error: ${response.statusCode}");
//         }
//       } catch (e) {
//         print("Exception: $e");
//       }
//     }
//   // Placeholder for acceptBid function
//   void acceptBid(String bidderId, String bidAmount) {
//     print("Accepting bid for bidderId: $bidderId with amount: $bidAmount");
//     // Implement your logic here
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final double width = MediaQuery.of(context).size.width;
//
//     return getBuddingOderByIdResponseData == null
//         ? const Center(child: CircularProgressIndicator())
//         : ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: getBuddingOderByIdResponseData?.length ?? 0,
//       itemBuilder: (context, index) {
//         final bidder = getBuddingOderByIdResponseData?[index];
//         final fullName = bidder['provider_id']['full_name']?.toString() ?? 'N/A';
//         final rating = bidder['provider_id']['rating']?.toString() ?? '0';
//         final bidderId = bidder['_id']?.toString() ?? '';
//         final bidAmount = bidder['bid_amount']?.toString() ?? '0';
//         final location = bidder['provider_id']['location']['address']?.toString() ?? 'N/A';
//         final profilePic = bidder['provider_id']['profile_pic']?.toString();
//
//         print("Abhi:- bidder id in bidder list : $bidderId");
//
//         return Container(
//           margin: EdgeInsets.symmetric(
//             vertical: height * 0.01,
//             horizontal: width * 0.01,
//           ),
//           padding: EdgeInsets.all(width * 0.02),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 1,
//                 blurRadius: 5,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: profilePic != null && profilePic.isNotEmpty
//                     ? Image.network(
//                   profilePic,
//                   height: 90,
//                   width: 90,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Image.asset(
//                     'assets/images/account1.png',
//                     height: 90,
//                     width: 90,
//                     fit: BoxFit.cover,
//                   ),
//                 )
//                     : Image.asset(
//                   'assets/images/account1.png',
//                   height: 90,
//                   width: 90,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               SizedBox(width: width * 0.03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Text(
//                             fullName,
//                             style: TextStyle(
//                               fontSize: width * 0.045,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               rating,
//                               style: TextStyle(
//                                 fontSize: width * 0.035,
//                               ),
//                             ),
//                             Icon(
//                               Icons.star,
//                               size: width * 0.04,
//                               color: Colors.yellow.shade700,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "₹$bidAmount",
//                           style: TextStyle(
//                             fontSize: width * 0.04,
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         CircleAvatar(
//                           radius: 13,
//                           backgroundColor: Colors.grey.shade300,
//                           child: Icon(
//                             Icons.phone,
//                             size: 18,
//                             color: Colors.green.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: height * 0.005),
//                     Row(
//                       children: [
//                         Flexible(
//                           child: Container(
//                             height: 22,
//                             constraints: BoxConstraints(
//                               maxWidth: width * 0.25,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade300,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 location,
//                                 style: TextStyle(
//                                   fontSize: width * 0.033,
//                                   color: Colors.white,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: width * 0.03),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: CircleAvatar(
//                             radius: 13,
//                             backgroundColor: Colors.grey.shade300,
//                             child: Icon(
//                               Icons.message,
//                               size: 18,
//                               color: Colors.green.shade600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => UserViewWorkerDetails(
//                                   workerId: bidderId,
//                                 ),
//                               ),
//                             );
//                           },
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: const Size(0, 25),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           child: Text(
//                             "View Profile",
//                             style: TextStyle(
//                               fontSize: width * 0.032,
//                               color: Colors.green.shade700,
//                             ),
//                           ),
//                         ),
//                         Flexible(
//                           child: InkWell(
//                             onTap: () {
//                               acceptBid(bidderId, bidAmount);
//                             },
//                             child: Container(
//                               height: 32,
//                               constraints: BoxConstraints(
//                                 maxWidth: width * 0.2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.shade700,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   "Accept",
//                                   style: TextStyle(
//                                     fontSize: width * 0.032,
//                                     color: Colors.white,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// // Placeholder for UserViewWorkerDetails widget
// class UserViewWorkerDetails extends StatelessWidget {
//   final String workerId;
//
//   const UserViewWorkerDetails({Key? key, required this.workerId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Worker Details")),
//       body: Center(child: Text("Worker ID: $workerId")),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Testingfile extends StatefulWidget {
  const Testingfile({Key? key}) : super(key: key);

  @override
  State<Testingfile> createState() => _TestingfileState();
}

class _TestingfileState extends State<Testingfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //Image.network("https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fprofile-image&psig=AOvVaw1LeAxeRzMzpwgD8_j3lhHM&ust=1756549668246000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCMDgz8znr48DFQAAAAAdAAAAABAE")
        CircleAvatar(
          radius: 45,
          backgroundImage: NetworkImage("https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fprofile-image&psig=AOvVaw1LeAxeRzMzpwgD8_j3lhHM&ust=1756549668246000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCMDgz8znr48DFQAAAAAdAAAAABAE"),)

        ],
      ),
    );
  }
  // It is immutable its once build , can not change data in runtime
  // It is mutable its data change in runtime
  Widget CustomTextFormfiled () {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Please inter ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(strokeAlign: double.infinity))
          ),

        )
      ],
    );
  }
}

// It is immutable once its build, cannot be change data in runtime
//It is immutable → once it’s built, it cannot change its internal data during runtime.