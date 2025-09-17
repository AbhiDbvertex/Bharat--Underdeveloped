// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:url_launcher/url_launcher.dart';
// // // // // //
// // // // // // void main() {
// // // // // //   runApp(const MyApp());
// // // // // // }
// // // // // //
// // // // // // class MyApp extends StatelessWidget {
// // // // // //   const MyApp({super.key});
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return MaterialApp(
// // // // // //       debugShowCheckedModeBanner: false,
// // // // // //       home: PaymentScreen(),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // //
// // // // // // class PaymentScreen extends StatelessWidget {
// // // // // //   PaymentScreen({super.key});
// // // // // //
// // // // // //   final TextEditingController amountController = TextEditingController();
// // // // // //
// // // // // //   Future<void> launchUPI(String amount) async {
// // // // // //     final upiId = ""; // apna UPI ID yaha daal
// // // // // //     final name = ""; // apna naam ya app ka naam
// // // // // //     final note = "Payment from app"; // payment note
// // // // // //
// // // // // //     final uri = Uri.parse(
// // // // // //       "upi://pay?pa=$upiId&pn=$name&tn=$note&am=$amount&cu=INR",
// // // // // //     );
// // // // // //
// // // // // //     if (await canLaunchUrl(uri)) {
// // // // // //       await launchUrl(uri, mode: LaunchMode.externalApplication);
// // // // // //     } else {
// // // // // //       throw "UPI app not found!";
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: const Text("UPI Payment"),
// // // // // //         centerTitle: true,
// // // // // //       ),
// // // // // //       body: Padding(
// // // // // //         padding: const EdgeInsets.all(20),
// // // // // //         child: Column(
// // // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // // //           children: [
// // // // // //             TextField(
// // // // // //               controller: amountController,
// // // // // //               decoration: const InputDecoration(
// // // // // //                 labelText: "Enter Amount",
// // // // // //                 border: OutlineInputBorder(),
// // // // // //               ),
// // // // // //               keyboardType: TextInputType.number,
// // // // // //             ),
// // // // // //             const SizedBox(height: 20),
// // // // // //             ElevatedButton(
// // // // // //               onPressed: () {
// // // // // //                 String amt = amountController.text.trim();
// // // // // //                 if (amt.isNotEmpty) {
// // // // // //                   launchUPI(amt);
// // // // // //                 } else {
// // // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                     const SnackBar(content: Text("Please enter amount")),
// // // // // //                   );
// // // // // //                 }
// // // // // //               },
// // // // // //               child: const Text("Pay Now"),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // //
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'dart:convert';
// // // // //
// // // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // //
// // // // // // Assuming this is your widget class
// // // // // class YourWidget extends StatefulWidget {
// // // // //   final String buddingOderId;
// // // // //
// // // // //   const YourWidget({Key? key, required this.buddingOderId}) : super(key: key);
// // // // //
// // // // //   @override
// // // // //   _YourWidgetState createState() => _YourWidgetState();
// // // // // }
// // // // //
// // // // // class _YourWidgetState extends State<YourWidget> {
// // // // //   List<dynamic>? getBuddingOderByIdResponseDatalist;
// // // // //
// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     fetchBiddingOffers();
// // // // //   }
// // // // //
// // // // //   // Function to fetch bidding offers from the API
// // // // //   Future<void> fetchBiddingOffers() async {
// // // // //     final String apiUrl =
// // // // //         "https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.buddingOderId}";
// // // // //
// // // // //       // final response = await http.get(Uri.parse(apiUrl));
// // // // //       final prefs = await SharedPreferences.getInstance();
// // // // //       final token = prefs.getString('token') ?? '';
// // // // //
// // // // //       try {
// // // // //         var response = await http.get(
// // // // //           Uri.parse(apiUrl),
// // // // //           headers: {
// // // // //             'Authorization': 'Bearer $token',
// // // // //             'Content-Type': 'application/json',
// // // // //           },
// // // // //         );
// // // // //         if (response.statusCode == 200) {
// // // // //           print("Abhi:- getBuddingOderById response: ${response.body}");
// // // // //           print("Abhi:- getBuddingOderById status: ${response.statusCode}");
// // // // //           final data = json.decode(response.body);
// // // // //           if (data['status'] == true) {
// // // // //             setState(() {
// // // // //               getBuddingOderByIdResponseData = data['data'];
// // // // //             });
// // // // //           } else {
// // // // //             print("Abhi:- getBuddingOderById response: ${response.body}");
// // // // //             print("Abhi:- getBuddingOderById status: ${response.statusCode}");
// // // // //             print("API Error: ${data['message']}");
// // // // //           }
// // // // //         } else {
// // // // //           print("HTTP Error: ${response.statusCode}");
// // // // //         }
// // // // //       } catch (e) {
// // // // //         print("Exception: $e");
// // // // //       }
// // // // //     }
// // // // //   // Placeholder for acceptBid function
// // // // //   void acceptBid(String bidderId, String bidAmount) {
// // // // //     print("Accepting bid for bidderId: $bidderId with amount: $bidAmount");
// // // // //     // Implement your logic here
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final double height = MediaQuery.of(context).size.height;
// // // // //     final double width = MediaQuery.of(context).size.width;
// // // // //
// // // // //     return getBuddingOderByIdResponseData == null
// // // // //         ? const Center(child: CircularProgressIndicator())
// // // // //         : ListView.builder(
// // // // //       shrinkWrap: true,
// // // // //       physics: const NeverScrollableScrollPhysics(),
// // // // //       itemCount: getBuddingOderByIdResponseData?.length ?? 0,
// // // // //       itemBuilder: (context, index) {
// // // // //         final bidder = getBuddingOderByIdResponseData?[index];
// // // // //         final fullName = bidder['provider_id']['full_name']?.toString() ?? 'N/A';
// // // // //         final rating = bidder['provider_id']['rating']?.toString() ?? '0';
// // // // //         final bidderId = bidder['_id']?.toString() ?? '';
// // // // //         final bidAmount = bidder['bid_amount']?.toString() ?? '0';
// // // // //         final location = bidder['provider_id']['location']['address']?.toString() ?? 'N/A';
// // // // //         final profilePic = bidder['provider_id']['profile_pic']?.toString();
// // // // //
// // // // //         print("Abhi:- bidder id in bidder list : $bidderId");
// // // // //
// // // // //         return Container(
// // // // //           margin: EdgeInsets.symmetric(
// // // // //             vertical: height * 0.01,
// // // // //             horizontal: width * 0.01,
// // // // //           ),
// // // // //           padding: EdgeInsets.all(width * 0.02),
// // // // //           decoration: BoxDecoration(
// // // // //             color: Colors.white,
// // // // //             borderRadius: BorderRadius.circular(12),
// // // // //             boxShadow: [
// // // // //               BoxShadow(
// // // // //                 color: Colors.grey.withOpacity(0.2),
// // // // //                 spreadRadius: 1,
// // // // //                 blurRadius: 5,
// // // // //                 offset: const Offset(0, 3),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //           child: Row(
// // // // //             crossAxisAlignment: CrossAxisAlignment.start,
// // // // //             children: [
// // // // //               ClipRRect(
// // // // //                 borderRadius: BorderRadius.circular(8),
// // // // //                 child: profilePic != null && profilePic.isNotEmpty
// // // // //                     ? Image.network(
// // // // //                   profilePic,
// // // // //                   height: 90,
// // // // //                   width: 90,
// // // // //                   fit: BoxFit.cover,
// // // // //                   errorBuilder: (context, error, stackTrace) => Image.asset(
// // // // //                     'assets/images/d_png/no_profile_image.png',
// // // // //                     height: 90,
// // // // //                     width: 90,
// // // // //                     fit: BoxFit.cover,
// // // // //                   ),
// // // // //                 )
// // // // //                     : Image.asset(
// // // // //                   'assets/images/d_png/no_profile_image.png',
// // // // //                   height: 90,
// // // // //                   width: 90,
// // // // //                   fit: BoxFit.cover,
// // // // //                 ),
// // // // //               ),
// // // // //               SizedBox(width: width * 0.03),
// // // // //               Expanded(
// // // // //                 child: Column(
// // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                   children: [
// // // // //                     Row(
// // // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //                       children: [
// // // // //                         Flexible(
// // // // //                           child: Text(
// // // // //                             fullName,
// // // // //                             style: TextStyle(
// // // // //                               fontSize: width * 0.045,
// // // // //                               fontWeight: FontWeight.bold,
// // // // //                             ),
// // // // //                             overflow: TextOverflow.ellipsis,
// // // // //                             maxLines: 1,
// // // // //                           ),
// // // // //                         ),
// // // // //                         Row(
// // // // //                           children: [
// // // // //                             Text(
// // // // //                               rating,
// // // // //                               style: TextStyle(
// // // // //                                 fontSize: width * 0.035,
// // // // //                               ),
// // // // //                             ),
// // // // //                             Icon(
// // // // //                               Icons.star,
// // // // //                               size: width * 0.04,
// // // // //                               color: Colors.yellow.shade700,
// // // // //                             ),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                     Row(
// // // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //                       children: [
// // // // //                         Text(
// // // // //                           "₹$bidAmount",
// // // // //                           style: TextStyle(
// // // // //                             fontSize: width * 0.04,
// // // // //                             color: Colors.black,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                           ),
// // // // //                         ),
// // // // //                         CircleAvatar(
// // // // //                           radius: 13,
// // // // //                           backgroundColor: Colors.grey.shade300,
// // // // //                           child: Icon(
// // // // //                             Icons.phone,
// // // // //                             size: 18,
// // // // //                             color: Colors.green.shade600,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                     SizedBox(height: height * 0.005),
// // // // //                     Row(
// // // // //                       children: [
// // // // //                         Flexible(
// // // // //                           child: Container(
// // // // //                             height: 22,
// // // // //                             constraints: BoxConstraints(
// // // // //                               maxWidth: width * 0.25,
// // // // //                             ),
// // // // //                             decoration: BoxDecoration(
// // // // //                               color: Colors.red.shade300,
// // // // //                               borderRadius: BorderRadius.circular(10),
// // // // //                             ),
// // // // //                             child: Center(
// // // // //                               child: Text(
// // // // //                                 location,
// // // // //                                 style: TextStyle(
// // // // //                                   fontSize: width * 0.033,
// // // // //                                   color: Colors.white,
// // // // //                                 ),
// // // // //                                 overflow: TextOverflow.ellipsis,
// // // // //                                 maxLines: 1,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                         SizedBox(width: width * 0.03),
// // // // //                         Padding(
// // // // //                           padding: const EdgeInsets.only(top: 8.0),
// // // // //                           child: CircleAvatar(
// // // // //                             radius: 13,
// // // // //                             backgroundColor: Colors.grey.shade300,
// // // // //                             child: Icon(
// // // // //                               Icons.message,
// // // // //                               size: 18,
// // // // //                               color: Colors.green.shade600,
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                     Row(
// // // // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //                       children: [
// // // // //                         TextButton(
// // // // //                           onPressed: () {
// // // // //                             Navigator.push(
// // // // //                               context,
// // // // //                               MaterialPageRoute(
// // // // //                                 builder: (context) => UserViewWorkerDetails(
// // // // //                                   workerId: bidderId,
// // // // //                                 ),
// // // // //                               ),
// // // // //                             );
// // // // //                           },
// // // // //                           style: TextButton.styleFrom(
// // // // //                             padding: EdgeInsets.zero,
// // // // //                             minimumSize: const Size(0, 25),
// // // // //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// // // // //                           ),
// // // // //                           child: Text(
// // // // //                             "View Profile",
// // // // //                             style: TextStyle(
// // // // //                               fontSize: width * 0.032,
// // // // //                               color: Colors.green.shade700,
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                         Flexible(
// // // // //                           child: InkWell(
// // // // //                             onTap: () {
// // // // //                               acceptBid(bidderId, bidAmount);
// // // // //                             },
// // // // //                             child: Container(
// // // // //                               height: 32,
// // // // //                               constraints: BoxConstraints(
// // // // //                                 maxWidth: width * 0.2,
// // // // //                               ),
// // // // //                               decoration: BoxDecoration(
// // // // //                                 color: Colors.green.shade700,
// // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // //                               ),
// // // // //                               child: Center(
// // // // //                                 child: Text(
// // // // //                                   "Accept",
// // // // //                                   style: TextStyle(
// // // // //                                     fontSize: width * 0.032,
// // // // //                                     color: Colors.white,
// // // // //                                   ),
// // // // //                                   overflow: TextOverflow.ellipsis,
// // // // //                                   maxLines: 1,
// // // // //                                 ),
// // // // //                               ),
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         );
// // // // //       },
// // // // //     );
// // // // //   }
// // // // // }
// // // // //
// // // // // // Placeholder for UserViewWorkerDetails widget
// // // // // class UserViewWorkerDetails extends StatelessWidget {
// // // // //   final String workerId;
// // // // //
// // // // //   const UserViewWorkerDetails({Key? key, required this.workerId}) : super(key: key);
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(title: const Text("Worker Details")),
// // // // //       body: Center(child: Text("Worker ID: $workerId")),
// // // // //     );
// // // // //   }
// // // // // }
// // // //
// // // // import 'package:flutter/cupertino.dart';
// // // // import 'package:flutter/material.dart';
// // // //
// // // // class Testingfile extends StatefulWidget {
// // // //   const Testingfile({Key? key}) : super(key: key);
// // // //
// // // //   @override
// // // //   State<Testingfile> createState() => _TestingfileState();
// // // // }
// // // //
// // // // class _TestingfileState extends State<Testingfile> {
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       body: Column(
// // // //         children: [
// // // //           //Image.network("https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fprofile-image&psig=AOvVaw1LeAxeRzMzpwgD8_j3lhHM&ust=1756549668246000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCMDgz8znr48DFQAAAAAdAAAAABAE")
// // // //         CircleAvatar(
// // // //           radius: 45,
// // // //           backgroundImage: NetworkImage("https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fprofile-image&psig=AOvVaw1LeAxeRzMzpwgD8_j3lhHM&ust=1756549668246000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCMDgz8znr48DFQAAAAAdAAAAABAE"),)
// // // //
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //   // flutter architecture is the layered structure of flutter
// // // //   Widget CustomTextFormfiled () {
// // // //     return Column(
// // // //       children: [
// // // //         TextFormField(
// // // //           decoration: InputDecoration(
// // // //             hintText: 'Please inter ',
// // // //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(strokeAlign: double.infinity))
// // // //           ),
// // // //         )
// // // //       ],
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // It is immutable once its build, cannot be change data in runtime
// // // // //It is immutable → once it’s built, it cannot change its internal data during runtime.
// // // // //Flutter architecture is the layered structure of Flutter (Framework, Engine, Embedder) that defines how apps are built and run. (flutter architecture is the layered structure of flutter)
// // // // //Flutter architecture is the layered of structure of flutter.
// // // // //A widget is a basic building block of Flutter UI that represents everything you see on the screen, like text, button, image, or layout.
// // // // //The main() function is the entry point of a Flutter app, from where the execution starts and the first widget (usually runApp) is called.
// // // //setsta in flutter use to update state for widget .
// // // //
// // // // // App live.
// // // // // In the user tab got ot bidding , cancel,canceldispute,complite time show proper flag.
// // // // // In the worker tab:-
// // // // // In the my worker tab bidding list , add currect api and show currect data
// // // // // In the resent worker change api and currect data for resent time.
// // // // // Currect Ui in recent post work
// // // // // Remove unnaccery sanckbar in homepage
// // // // //In the darect hiring cancel dispute tab show cenceldispute flag
// // // // //In the Worker tab bidding detail page , cancel, canceldispute,complite, show proper flag
// // // // //In the bidding detail page show user profile page. currect alinment in detail page
// // // // //In the location tab not update location on the tab submit tab
// // //
// // // import 'package:flutter/cupertino.dart';
// // //
// // // void main() {
// // //   runApp(const MyCupertinoApp());
// // // }
// // //
// // // class MyCupertinoApp extends StatelessWidget {
// // //   const MyCupertinoApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return const CupertinoApp(
// // //       debugShowCheckedModeBanner: false,
// // //       title: 'Cupertino Demo',
// // //       home: HomePage(),
// // //     );
// // //   }
// // // }
// // //
// // // class HomePage extends StatelessWidget {
// // //   const HomePage({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return CupertinoPageScaffold(
// // //       navigationBar: const CupertinoNavigationBar(
// // //         middle: Text("Cupertino App"),
// // //         trailing: CupertinoButton(
// // //           padding: EdgeInsets.zero,
// // //           child: Icon(CupertinoIcons.add),
// // //           onPressed: null, // abhi disable rakha hai
// // //         ),
// // //       ),
// // //       child: SafeArea(
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.start,
// // //           children: [
// // //             const SizedBox(height: 20),
// // //
// // //             /// iOS style button
// // //             CupertinoButton.filled(
// // //               child: const Text("Click Me"),
// // //               onPressed: () {
// // //                 showCupertinoDialog(
// // //                   context: context,
// // //                   builder: (context) => CupertinoAlertDialog(
// // //                     title: const Text("Hello 👋"),
// // //                     content: const Text("This is an iOS style alert."),
// // //                     actions: [
// // //                       CupertinoDialogAction(
// // //                         child: const Text("OK"),
// // //                         onPressed: () => Navigator.pop(context),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //
// // //             const SizedBox(height: 20),
// // //
// // //             /// iOS style text field
// // //             const Padding(
// // //               padding: EdgeInsets.symmetric(horizontal: 16.0),
// // //               child: CupertinoTextField(
// // //                 placeholder: "Enter your name",
// // //                 prefix: Icon(CupertinoIcons.person),
// // //                 // Material app provide google layout stretcher , like appbar, bottombar, fab
// // //                 // cupertionApp is provide ios layout stretcher ,
// // //               ),
// // //             ),
// // //
// // //             const SizedBox(height: 20),
// // //
// // //             /// iOS style switch
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 const Text("Enable Notifications"),
// // //                 const SizedBox(width: 10),
// // //                 CupertinoSwitch(
// // //                   value: true,
// // //                   onChanged: (val) {},
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'dart:collection';
// //
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// //
// // class MapScreen extends StatefulWidget {
// //   final double latitude;
// //   final double longitude;
// //
// //   const MapScreen({
// //     super.key,
// //     required this.latitude,
// //     required this.longitude,
// //   });
// //
// //   @override
// //   State<MapScreen> createState() => _MapScreenState();
// // }
// //
// // class _MapScreenState extends State<MapScreen> {
// //   late GoogleMapController _mapController;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     LatLng targetLocation = LatLng(widget.latitude, widget.longitude);
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Google Map"),
// //       ),
// //       body: GoogleMap(
// //         initialCameraPosition: CameraPosition(
// //           target: targetLocation,
// //           zoom: 14, // zoom level
// //         ),
// //         onMapCreated: (controller) {
// //           _mapController = controller;
// //         },
// //         markers: {
// //           Marker(
// //             markerId: const MarkerId("target"),
// //             position: targetLocation,
// //             infoWindow: const InfoWindow(title: "Selected Location"),
// //           ),
// //         },
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_webservice/places.dart';
//
// class GoogleMapScreen extends StatefulWidget {
//   const GoogleMapScreen({super.key});
//
//   @override
//   State<GoogleMapScreen> createState() => _GoogleMapScreenState();
// }
//
// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   final Completer<GoogleMapController> _controller = Completer();
//   static const LatLng _start = LatLng(28.6139, 77.2090); // Delhi
//   LatLng? _end;
//
//   final Set<Marker> _markers = {};
//   final List<LatLng> _polylineCoordinates = [];
//   final PolylinePoints polylinePoints = PolylinePoints();
//
//   final String googleApiKey = "YOUR_GOOGLE_API_KEY";
//
//   final TextEditingController _searchController = TextEditingController();
//   List<Prediction> _predictions = [];
//
//   Future<void> _searchPlaces(String input) async {
//     final places = GoogleMapsPlaces(apiKey: googleApiKey);
//     final result = await places.autocomplete(input);
//     if (result.status == "OK") {
//       setState(() {
//         _predictions = result.predictions;
//       });
//     }
//   }
//
//   Future<void> _selectPlace(Prediction prediction) async {
//     final places = GoogleMapsPlaces(apiKey: googleApiKey);
//     final detail = await places.getDetailsByPlaceId(prediction.placeId!);
//
//     final location = detail.result.geometry!.location;
//     final LatLng latLng = LatLng(location.lat, location.lng);
//
//     setState(() {
//       _end = latLng;
//       _markers.add(
//         Marker(
//           markerId: MarkerId(prediction.placeId!),
//           position: latLng,
//           infoWindow: InfoWindow(title: detail.result.name),
//         ),
//       );
//       _predictions = [];
//       _searchController.text = detail.result.name;
//     });
//
//     _getDirections(_start, latLng);
//
//     final GoogleMapController mapController = await _controller.future;
//     mapController.animateCamera(
//       CameraUpdate.newLatLngZoom(latLng, 14),
//     );
//   }
//
//   Future<void> _getDirections(LatLng origin, LatLng destination) async {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleApiKey,
//       PointLatLng(origin.latitude, origin.longitude),
//       PointLatLng(destination.latitude, destination.longitude),
//       // PointLatLng()
//
//     );
//
//     if (result.points.isNotEmpty) {
//       _polylineCoordinates.clear();
//       for (var point in result.points) {
//         _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Google Map Search + Direction"),
//         backgroundColor: Colors.blue,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 build(context),
//                 TextField(
//                   controller: _searchController,
//                   decoration: const InputDecoration(
//                     hintText: "Search location...",
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (value) {
//                     _searchPlaces(value);
//                   },
//                 ),
//                 if (_predictions.isNotEmpty)
//                   Container(
//                     height: 200,
//                     color: Colors.white,
//                     child: ListView.builder(
//                       itemCount: _predictions.length,
//                       itemBuilder: (context, index) {
//                         final prediction = _predictions[index];
//                         return ListTile(
//                           title: Text(prediction.description ?? ""),
//                           onTap: () => _selectPlace(prediction),
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: const CameraPosition(
//                 target: _start,
//                 zoom: 10,
//               ),
//               markers: _markers,
//               polylines: {
//                 Polyline(
//                   polylineId: const PolylineId("route"),
//                   points: _polylineCoordinates,
//                   color: Colors.red,
//                   width: 5,
//                 ),
//               },
//               onMapCreated: (controller) {
//                 _controller.complete(controller);
//                 _markers.add(
//                   const Marker(
//                     markerId: MarkerId("start"),
//                     position: _start,
//                     infoWindow: InfoWindow(title: "Start Location"),
//                   ),
//                 );
//                 setState(() {});
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DragToPayScreen extends StatefulWidget {
  @override
  State<DragToPayScreen> createState() => _DragToPayScreenState();
}

class _DragToPayScreenState extends State<DragToPayScreen> {
  Razorpay? _razorpay;
  bool isDropped = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  void openRazorpay() {
    var options = {
      'key': 'rzp_test_R7z5O0bqmRXuiH', // yahan apna key dalna
      'amount': 5000, // amount in paise (50.00 INR)
      'name': 'Test Payment',
      'description': 'Payment for order',
      'prefill': {
        'contact': '9123456789',
        'email': 'test@example.com'
      },
      'method': {
        'netbanking': false,
        'card': false,
        'wallet': false,
        'upi': true
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Success: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }
  bool isLoding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drag To Pay"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Drag UPI to Pay area", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 40),

            DragTarget(
              onAccept: (data) {
                setState(() {
                  isDropped = true;
                });
                openRazorpay();
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 200,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDropped ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Pay Here",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),

            // ReorderableDelayedDragStartListener(child: Text("Text"), index: index),
            // p,u,a,d,d,y,a,m,s,t,n,p,a,s,d,m

            const SizedBox(height: 50),

            Draggable(
              data: "upi",
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("UPI", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              childWhenDragging: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("UPI", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("UPI", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}