// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../../Widgets/AppColors.dart';
// // import '../../models/ServiceProviderModel/DirectOrder.dart';
// // import '../ServiceProvider/ServiceDirectViewScreen.dart';
// //
// // class WorkerMyHireScreen extends StatefulWidget {
// //   final String? categreyId;
// //   final String? subcategreyId;
// //
// //   const WorkerMyHireScreen({super.key, this.categreyId, this.subcategreyId});
// //
// //   @override
// //   State<WorkerMyHireScreen> createState() => _WorkerMyHireScreenState();
// // }
// //
// // class _WorkerMyHireScreenState extends State<WorkerMyHireScreen>
// //     with RouteAware {
// //   bool isLoading = false;
// //   List<DirectOrder> orders = [];
// //   int selectedTab = 1; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency
// //   String? currentProviderId; // To store current provider's ID
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadProviderIdAndFetchOrders();
// //   }
// //
// //   Future<void> _loadProviderIdAndFetchOrders() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     currentProviderId =
// //         prefs.getString('provider_id') ??
// //             '685e244fb93a9a07a9fe41ee'; // Fallback from logs
// //     print('🔑 Current Provider ID: $currentProviderId');
// //     fetchDirectOrders();
// //   }
// //
// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
// //     routeObserver.subscribe(this, ModalRoute.of(context)!);
// //   }
// //
// //   @override
// //   void didPopNext() {
// //     print(
// //       "🔄 WorkerMyHireScreen: Screen pe wapas aaya, orders refresh kar raha hoon!",
// //     );
// //     fetchDirectOrders();
// //   }
// //
// //   @override
// //   void dispose() {
// //     final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
// //     routeObserver.unsubscribe(this);
// //     super.dispose();
// //   }
// //
// //   Future<void> fetchDirectOrders() async {
// //     setState(() => isLoading = true);
// //
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token') ?? '';
// //       print('🔐 Token: $token');
// //
// //       final res = await http.get(
// //         Uri.parse(
// //           'https://api.thebharatworks.com/api/direct-order/apiGetAllDirectOrders',
// //         ),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json',
// //         },
// //       );
// //
// //       print('📥 Direct Response Status: ${res.statusCode}');
// //       print('📥 Direct Response Body: ${res.body}');
// //
// //       if (res.statusCode == 200) {
// //         try {
// //           final decoded = json.decode(res.body);
// //           if (decoded.containsKey('data') && decoded['data'] is List) {
// //             final List<dynamic> data = decoded['data'];
// //             setState(() {
// //               orders =
// //                   data.map((e) {
// //                     final order = DirectOrder.fromJson(e);
// //                     // Check offer_history for current provider's status
// //                     String finalStatus = order.status;
// //                     if (e['offer_history'] != null &&
// //                         currentProviderId != null) {
// //                       for (var offer in e['offer_history']) {
// //                         if (offer['provider_id']?['_id'] == currentProviderId) {
// //                           final offerStatus =
// //                           offer['status']?.toString().toLowerCase();
// //                           print(
// //                             '📩 Offer History for Order ${order.id}: Provider $currentProviderId, Status: $offerStatus',
// //                           );
// //                           if (offerStatus == 'rejected') {
// //                             finalStatus = 'rejected';
// //                           }
// //                           break;
// //                         }
// //                       }
// //                     }
// //                     print(
// //                       '📋 Order ID: ${order.id}, Status: $finalStatus (Original: ${order.status})',
// //                     );
// //                     // Create new DirectOrder with updated status
// //                     return DirectOrder(
// //                       id: order.id,
// //                       title: order.title,
// //                       description: order.description,
// //                       date: order.date,
// //                       status: finalStatus, // Override status if needed
// //                       image: order.image,
// //                       providerId: order.providerId,
// //                       user_id: order.user_id,
// //                     );
// //                   }).toList();
// //             });
// //             print("✅ Orders Fetched: ${orders.length}");
// //             print("✅ Order Statuses: ${orders.map((o) => o.status).toList()}");
// //           } else {
// //             print("❌ 'data' key missing or invalid: ${decoded['data']}");
// //             _showSnackBar("Orders ka data nahi mila!");
// //           }
// //         } catch (jsonErr) {
// //           print('❌ JSON Decode Error: $jsonErr');
// //           _showSnackBar("Data parse karne mein error: $jsonErr");
// //         }
// //       } else {
// //         print("❌ API Error Status: ${res.statusCode}");
// //         print("❌ API Error Response: ${res.body}");
// //         _showSnackBar("Orders fetch nahi hue: ${res.statusCode}");
// //       }
// //     } catch (e) {
// //       print("❌ API Exception: $e");
// //       _showSnackBar("Kuchh galat ho gaya: $e");
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }
// //
// //   void _showSnackBar(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text(message)));
// //     }
// //   }
// //
// //   Color _getStatusColor(String status) {
// //     print("🎨 Checking status color for: $status");
// //     switch (status.toLowerCase()) {
// //       case 'cancelled':
// //         return Colors.red;
// //       case 'accepted':
// //         return Colors.green;
// //       case 'completed':
// //         return Colors.brown;
// //       case 'pending':
// //         return Colors.orange;
// //       case 'rejected':
// //         return Colors.red; // Rejected ke liye red color
// //       case 'cancelleddispute':
// //         return Colors.red;
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: AppColors.primaryGreen,
// //         centerTitle: true,
// //         elevation: 0,
// //         toolbarHeight: 20,
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: Column(
// //         crossAxisAlignment: CrossAxisAlignment.stretch,
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(12.0),
// //             child: Center(
// //               child: Text(
// //                 "My Hire",
// //                 style: GoogleFonts.roboto(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Container(
// //             width: double.infinity,
// //             height: 50,
// //             color: Colors.green.shade100,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 _buildTabButton("Bidding Tasks", 0),
// //                 _verticalDivider(),
// //                 _buildTabButton("Direct Hiring", 1),
// //                 _verticalDivider(),
// //                 _buildTabButton("Emergency Tasks", 2),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           Expanded(
// //             child: Builder(
// //               builder: (_) {
// //                 if (isLoading) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }
// //                 if (selectedTab == 0) {
// //                   return const Center(child: Text("No Bidding Tasks Found"));
// //                 } else if (selectedTab == 1) {
// //                   return _buildDirectHiringList();
// //                 } else {
// //                   return const Center(child: Text("No Emergency Tasks Found"));
// //                 }
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTabButton(String title, int tabIndex) {
// //     final isSelected = selectedTab == tabIndex;
// //     return ElevatedButton(
// //       onPressed: () {
// //         setState(() {
// //           selectedTab = tabIndex;
// //         });
// //       },
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor:
// //         isSelected ? Colors.green.shade700 : Colors.green.shade100,
// //         padding: const EdgeInsets.symmetric(horizontal: 16),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //       ),
// //       child: Text(
// //         title,
// //         style: _tabText(color: isSelected ? Colors.white : Colors.black),
// //       ),
// //     );
// //   }
// //
// //   Widget _verticalDivider() {
// //     return Container(width: 1, height: 40, color: Colors.white38);
// //   }
// //
// //   Widget _buildDirectHiringList() {
// //     if (orders.isEmpty) {
// //       return const Center(child: Text("No Direct Hiring Found"));
// //     }
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 12),
// //       child: ListView.builder(
// //         itemCount: orders.length,
// //         itemBuilder:
// //             (context, index) => _buildHireCard(
// //           orders[index],
// //           widget.categreyId,
// //           widget.subcategreyId,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHireCard(
// //       DirectOrder data,
// //       String? categreyId,
// //       String? subcategreyId,
// //       ) {
// //     final bool hasProfilePic =
// //         data.user_id != null &&
// //             data.user_id!.profile_pic != null &&
// //             (data.user_id!.profile_pic?.isNotEmpty ?? false) &&
// //             data.user_id!.profile_pic != 'local';
// //     print("🛠 Building card for Order ID: ${data.id}, Status: ${data.status}");
// //
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       padding: const EdgeInsets.all(10),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         boxShadow: const [
// //           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child:
// //             hasProfilePic
// //                 ? Image.network(
// //               data.user_id!.profile_pic!,
// //               height: 110,
// //               width: 110,
// //               fit: BoxFit.cover,
// //               errorBuilder:
// //                   (context, error, stackTrace) => Image.asset(
// //                 'assets/images/task.png',
// //                 height: 110,
// //                 width: 110,
// //                 fit: BoxFit.cover,
// //               ),
// //             )
// //                 : Image.asset(
// //               'assets/images/task.png',
// //               height: 110,
// //               width: 110,
// //               fit: BoxFit.cover,
// //             ),
// //           ),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   data.title,
// //                   style: _cardTitle(),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   data.description,
// //                   style: _cardBody(),
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text("Posted Date: ${data.date}", style: _cardDate()),
// //                 const SizedBox(height: 6),
// //                 Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 8,
// //                         vertical: 4,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: _getStatusColor(data.status),
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Text(
// //                         data.status,
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ),
// //                     const Spacer(),
// //                     TextButton(
// //                       onPressed: () {
// //                         print(
// //                           "🔍 Navigating to ServiceDirectViewScreen for Order ID: ${data.id}",
// //                         );
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder:
// //                                 (_) => ServiceDirectViewScreen(
// //                               id: data.id,
// //                               categreyId: categreyId,
// //                               subcategreyId: subcategreyId,
// //                             ),
// //                           ),
// //                         ).then((_) {
// //                           print(
// //                             "🔄 Returned to WorkerMyHireScreen, refreshing orders",
// //                           );
// //                           fetchDirectOrders();
// //                         });
// //                       },
// //                       style: TextButton.styleFrom(
// //                         backgroundColor: Colors.green.shade700,
// //                         minimumSize: const Size(90, 36),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(6),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         "View Details",
// //                         style: GoogleFonts.roboto(
// //                           color: Colors.white,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   TextStyle _tabText({Color color = Colors.black}) => GoogleFonts.roboto(
// //     color: color,
// //     fontWeight: FontWeight.w500,
// //     fontSize: 12,
// //   );
// //
// //   TextStyle _cardTitle() =>
// //       GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.bold);
// //
// //   TextStyle _cardBody() => GoogleFonts.roboto(fontSize: 13);
// //
// //   TextStyle _cardDate() =>
// //       GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700]);
// // }
//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../models/ServiceProviderModel/DirectOrder.dart';
// import 'ServiceDirectViewScreen.dart';
//
// class WorkerMyHireScreen extends StatefulWidget {
//   final String? categreyId;
//   final String? subcategreyId;
//
//   const WorkerMyHireScreen({super.key, this.categreyId, this.subcategreyId});
//
//   @override
//   State<WorkerMyHireScreen> createState() => _WorkerMyHireScreenState();
// }
//
// class _WorkerMyHireScreenState extends State<WorkerMyHireScreen>
//     with RouteAware {
//   bool isLoading = false;
//   List<DirectOrder> orders = [];
//   int selectedTab = 0; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency
//   String? currentProviderId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProviderIdAndFetchOrders();
//   }
//
//   Future<void> _loadProviderIdAndFetchOrders() async {
//     final prefs = await SharedPreferences.getInstance();
//     currentProviderId = prefs.getString('provider_id') ??
//         '685e244fb93a9a07a9fe41ee'; // Fallback from logs
//     print('🔑 Current Provider ID: $currentProviderId');
//     fetchDirectOrders();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
//     routeObserver.subscribe(this, ModalRoute.of(context)!);
//   }
//
//   @override
//   void didPopNext() {
//     print(
//       "🔄 WorkerMyHireScreen: Screen pe wapas aaya, orders refresh kar raha hoon!",
//     );
//     fetchDirectOrders();
//   }
//
//   @override
//   void dispose() {
//     final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
//     routeObserver.unsubscribe(this);
//     super.dispose();
//   }
//
//   Future<void> fetchDirectOrders() async {
//     setState(() => isLoading = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print('🔐 Token: $token');
//
//       final res = await http.get(
//         Uri.parse(
//           'https://api.thebharatworks.com/api/direct-order/apiGetAllDirectOrders',
//         ),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       print('📥 Direct Response Status: ${res.statusCode}');
//       print('📥 Direct Response Body: ${res.body}');
//
//       if (res.statusCode == 200) {
//         try {
//           final decoded = json.decode(res.body);
//           if (decoded.containsKey('data') && decoded['data'] is List) {
//             final List<dynamic> data = decoded['data'];
//             setState(() {
//               orders = data.map((e) {
//                 final order = DirectOrder.fromJson(e);
//                 // Check offer_history for current provider's status
//                 String finalStatus = order.status.toLowerCase();
//                 if (e['offer_history'] != null && currentProviderId != null) {
//                   for (var offer in e['offer_history']) {
//                     if (offer['provider_id']?['_id'] == currentProviderId) {
//                       final offerStatus =
//                           offer['status']?.toString().toLowerCase();
//                       print(
//                         '📩 Offer History for Order ${order.id}: Provider $currentProviderId, Status: $offerStatus',
//                       );
//                       if (offerStatus == 'rejected' ||
//                           offerStatus == 'cancelled') {
//                         finalStatus = 'rejected';
//                       } else if (offerStatus == 'accepted') {
//                         finalStatus = 'accepted';
//                       }
//                       break;
//                     }
//                   }
//                 }
//                 print(
//                   '📋 Order ID: ${order.id}, Status: $finalStatus (Original: ${order.status})',
//                 );
//
//                 return /*DirectOrder(
//
//                       id: order.id,
//                       title: order.title,
//                       description: order.description,
//                       date: order.date,
//                       status: finalStatus, // Override status
//                       image: order.image,
//                       providerId: order.providerId,
//                       user_id: order.user_id,
//
//                     );*/
//                     DirectOrder(
//                   id: order.id,
//                   title: order.title,
//                   description: order.description,
//                   date: order.date,
//                   status: finalStatus, // Override status
//                   image: (order.offer_history != null &&
//                           order.offer_history!.isNotEmpty)
//                       ? order.offer_history!.first.provider_id?.profile_pic ??
//                           order.image
//                       : order
//                           .image, // first offer ka provider image ya default order image
//                   user_id: order.user_id,
//                   offer_history: order.offer_history, // original offers
//                 );
//               }).toList();
//             });
//             print("✅ Orders Fetched: ${orders.length}");
//             print("✅ Order Statuses: ${orders.map((o) => o.status).toList()}");
//           } else {
//             print("❌ 'data' key missing or invalid: ${decoded['data']}");
//             _showSnackBar("Orders data not found !");
//           }
//         } catch (jsonErr) {
//           print('❌ JSON Decode Error: $jsonErr');
//           // _showSnackBar("Data parse karne mein error: $jsonErr");
//         }
//       } else {
//         print("❌ API Error Status: ${res.statusCode}");
//         print("❌ API Error Response: ${res.body}");
//         // _showSnackBar("Orders fetch nahi hue: ${res.statusCode}");
//       }
//     } catch (e) {
//       print("❌ API Exception: $e");
//       // _showSnackBar("Kuchh galat ho gaya: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     print("🎨 Checking status color for: $status");
//     switch (status.toLowerCase()) {
//       case 'cancelled':
//         return Colors.red;
//       case 'accepted':
//         return Colors.green;
//       case 'completed':
//         return Colors.brown;
//       case 'pending':
//         return Colors.orange;
//       case 'rejected':
//         return Colors.red;
//       case 'cancelleddispute':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Center(
//               child: Text(
//                 "My Hire",
//                 style: GoogleFonts.roboto(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             width: double.infinity,
//             height: 50,
//             color: Colors.green.shade100,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildTabButton("Bidding Tasks", 0),
//                 _verticalDivider(),
//                 _buildTabButton("Direct Hiring", 1),
//                 _verticalDivider(),
//                 _buildTabButton("Emergency Tasks", 2),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: Builder(
//               builder: (_) {
//                 if (isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (selectedTab == 0) {
//                   return const Center(child: Text("No Bidding Tasks Found"));
//                 } else if (selectedTab == 1) {
//                   return _buildDirectHiringList();
//                 } else {
//                   return const Center(child: Text("No Emergency Tasks Found"));
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabButton(String title, int tabIndex) {
//     final isSelected = selectedTab == tabIndex;
//     return ElevatedButton(
//       onPressed: () {
//         setState(() {
//           selectedTab = tabIndex;
//         });
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor:
//             isSelected ? Colors.green.shade700 : Colors.green.shade100,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(
//         title,
//         style: _tabText(color: isSelected ? Colors.white : Colors.black),
//       ),
//     );
//   }
//
//   Widget _verticalDivider() {
//     return Container(width: 1, height: 40, color: Colors.white38);
//   }
//
//   Widget _buildDirectHiringList() {
//     if (orders.isEmpty) {
//       return const Center(child: Text("No Direct Hiring Found"));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: ListView.builder(
//         itemCount: orders.length,
//         itemBuilder: (context, index) => _buildHireCard(
//           orders[index],
//           widget.categreyId,
//           widget.subcategreyId,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHireCard(
//     DirectOrder data,
//     String? categreyId,
//     String? subcategreyId,
//   ) {
//     final bool hasProfilePic = data.user_id != null &&
//         data.user_id!.profile_pic != null &&
//         (data.user_id!.profile_pic?.isNotEmpty ?? false) &&
//         data.user_id!.profile_pic != 'local';
//     print("🛠 Building card for Order ID: ${data.id}, Status: ${data.status}");
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: hasProfilePic
//                 ? Image.network(
//                     data.user_id!.profile_pic!,
//                     height: 110,
//                     width: 110,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Image.asset(
//                       'assets/images/task.png',
//                       height: 110,
//                       width: 110,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                 : Image.asset(
//                     'assets/images/task.png',
//                     height: 110,
//                     width: 110,
//                     fit: BoxFit.cover,
//                   ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   data.title,
//                   style: _cardTitle(),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   data.description,
//                   style: _cardBody(),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text("Posted Date: ${data.date}", style: _cardDate()),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _getStatusColor(data.status),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         data.status.isEmpty
//                             ? 'Pending'
//                             : data.status[0].toUpperCase() +
//                                 data.status.substring(1),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     TextButton(
//                       onPressed: () {
//                         print(
//                           "🔍 Navigating to ServiceDirectViewScreen for Order ID: ${data.id}",
//                         );
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ServiceDirectViewScreen(
//                               id: data.id,
//                               categreyId: categreyId,
//                               subcategreyId: subcategreyId,
//                             ),
//                           ),
//                         ).then((_) {
//                           print(
//                             "🔄 Returned to WorkerMyHireScreen, refreshing orders",
//                           );
//                           fetchDirectOrders();
//                         });
//                       },
//                       style: TextButton.styleFrom(
//                         backgroundColor: Colors.green.shade700,
//                         minimumSize: const Size(90, 36),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                       child: Text(
//                         "View Details",
//                         style: GoogleFonts.roboto(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   TextStyle _tabText({Color color = Colors.black}) => GoogleFonts.roboto(
//         color: color,
//         fontWeight: FontWeight.w500,
//         fontSize: 12,
//       );
//
//   TextStyle _cardTitle() =>
//       GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.bold);
//
//   TextStyle _cardBody() => GoogleFonts.roboto(fontSize: 13);
//
//   TextStyle _cardDate() =>
//       GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700]);
// }

import 'dart:convert';

import 'package:developer/Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../models/ServiceProviderModel/DirectOrder.dart';
import 'ServiceDirectViewScreen.dart';

class WorkerMyHireScreen extends StatefulWidget {
  final String? categreyId;
  final String? subcategreyId;

  const WorkerMyHireScreen({super.key, this.categreyId, this.subcategreyId});

  @override
  State<WorkerMyHireScreen> createState() => _WorkerMyHireScreenState();
}

class _WorkerMyHireScreenState extends State<WorkerMyHireScreen>
    with RouteAware {
  bool isLoading = false;
  List<DirectOrder> directOrders = [];
  // Static Bidding Data from WorkerbiddingtaskScreen
  final List<Map<String, dynamic>> biddingItems = [
    {
      "title": "Make a chair",
      "price": "₹1,500",
      "desc": "Lorem ipsum dolor ...",
      "view": "View Details",
      "date": "21/02/25",
      "status": "",
    },
    {
      "title": "Make a chair",
      "price": "₹1,500",
      "desc": "Lorem ipsum dolor ...",
      "view": "View Details",
      "date": "21/02/25",
      "status": "Cancelled",
    },
    {
      "title": "Make a chair",
      "price": "₹1,500",
      "desc": "Lorem ipsum dolor ...",
      "view": "View Details",
      "date": "21/02/25",
      "status": "Accepted",
    },
    {
      "title": "Make a chair",
      "price": "₹1,500",
      "desc": "Lorem ipsum dolor ...",
      "view": "View Details",
      "date": "21/02/25",
      "status": "Completed",
    },
    {
      "title": "Make a chair",
      "price": "₹1,500",
      "desc": "Lorem ipsum dolor ...",
      "view": "View Details",
      "date": "21/02/25",
      "status": "Review",
    },
  ];
  List<Map<String, dynamic>> filteredBiddingItems = [];
  int selectedTab = 0; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency
  String? currentProviderId;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredBiddingItems = biddingItems; // Initialize filtered list
    _loadProviderIdAndFetchOrders();
    _searchController.addListener(() {
      _filterBiddingItems(_searchController.text);
    });
  }

  Future<void> _loadProviderIdAndFetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    currentProviderId =
        prefs.getString('provider_id') ?? '685e244fb93a9a07a9fe41ee';
    print('🔑 Current Provider ID: $currentProviderId');
    fetchDirectOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    print(
        "🔄 WorkerMyHireScreen: Screen pe wapas aaya, data refresh kar raha hoon!");
    fetchDirectOrders();
  }

  @override
  void dispose() {
    final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch Direct Orders
  Future<void> fetchDirectOrders() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print('🔐 Token: $token');

      final res = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/direct-order/apiGetAllDirectOrders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Direct Response Status: ${res.statusCode}');
      print('📥 Direct Response Body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded.containsKey('data') && decoded['data'] is List) {
          final List<dynamic> data = decoded['data'];
          setState(() {
            directOrders = data.map((e) {
              final order = DirectOrder.fromJson(e);
              String finalStatus = order.status.toLowerCase();
              if (e['offer_history'] != null && currentProviderId != null) {
                for (var offer in e['offer_history']) {
                  if (offer['provider_id']?['_id'] == currentProviderId) {
                    final offerStatus =
                        offer['status']?.toString().toLowerCase();
                    print(
                        '📩 Offer History for Order ${order.id}: Provider $currentProviderId, Status: $offerStatus');
                    if (offerStatus == 'rejected' ||
                        offerStatus == 'cancelled') {
                      finalStatus = 'rejected';
                    } else if (offerStatus == 'accepted') {
                      finalStatus = 'accepted';
                    }
                    break;
                  }
                }
              }
              print(
                  '📋 Order ID: ${order.id}, Status: $finalStatus (Original: ${order.status})');
              return DirectOrder(
                id: order.id,
                title: order.title,
                description: order.description,
                date: order.date,
                status: finalStatus,
                image: (order.offer_history != null &&
                        order.offer_history!.isNotEmpty)
                    ? order.offer_history!.first.provider_id?.profile_pic ??
                        order.image
                    : order.image,
                user_id: order.user_id,
                offer_history: order.offer_history,
              );
            }).toList();
          });
          print("✅ Direct Orders Fetched: ${directOrders.length}");
        } else {
          print("❌ 'data' key missing or invalid: ${decoded['data']}");
          _showSnackBar("Direct orders data not found!");
        }
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        _showSnackBar("Direct orders fetch nahi hue: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: $e");
      _showSnackBar("Kuchh galat ho gaya: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Filter Bidding Items
  void _filterBiddingItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBiddingItems = biddingItems;
      } else {
        filteredBiddingItems = biddingItems.where((item) {
          final title = item["title"].toString().toLowerCase();
          final desc = item["desc"].toString().toLowerCase();
          return title.contains(query.toLowerCase()) ||
              desc.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Color _getStatusColor(String status) {
    print("🎨 Checking status color for: $status");
    switch (status.toLowerCase()) {
      case 'cancelled':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.green.shade800;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                "My Work",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.green.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton("Bidding Tasks", 0),
                _verticalDivider(),
                _buildTabButton("Direct Hiring", 1),
                _verticalDivider(),
                _buildTabButton("Emergency Tasks", 2),
              ],
            ),
          ),
          if (selectedTab == 0) // Search bar only for Bidding Tasks
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for bidding tasks',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Builder(
              builder: (_) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (selectedTab == 0) {
                  return _buildBiddingTasksList();
                } else if (selectedTab == 1) {
                  return _buildDirectHiringList();
                } else {
                  return const Center(child: Text("No Emergency Tasks Found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int tabIndex) {
    final isSelected = selectedTab == tabIndex;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTab = tabIndex;
          if (tabIndex != 0)
            _searchController.clear(); // Clear search when switching tabs
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.green.shade700 : Colors.green.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        title,
        style: _tabText(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 40, color: Colors.white38);
  }

  Widget _buildDirectHiringList() {
    if (directOrders.isEmpty) {
      return const Center(child: Text("No Direct Hiring Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: directOrders.length,
        itemBuilder: (context, index) => _buildHireCard(
          directOrders[index],
          widget.categreyId,
          widget.subcategreyId,
        ),
      ),
    );
  }

  Widget _buildBiddingTasksList() {
    if (filteredBiddingItems.isEmpty) {
      return const Center(child: Text("No Bidding Tasks Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: filteredBiddingItems.length,
        itemBuilder: (context, index) => _buildBiddingCard(
          filteredBiddingItems[index],
          widget.categreyId,
          widget.subcategreyId,
        ),
      ),
    );
  }

  Widget _buildHireCard(
    DirectOrder data,
    String? categreyId,
    String? subcategreyId,
  ) {
    final bool hasProfilePic = data.user_id != null &&
        data.user_id!.profile_pic != null &&
        (data.user_id!.profile_pic?.isNotEmpty ?? false) &&
        data.user_id!.profile_pic != 'local';
    print("🛠 Building card for Order ID: ${data.id}, Status: ${data.status}");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasProfilePic
                ? Image.network(
                    data.user_id!.profile_pic!,
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/task.png',
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/task.png',
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: _cardTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: _cardBody(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text("Posted Date: ${data.date}", style: _cardDate()),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(data.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.status.isEmpty
                            ? 'Pending'
                            : data.status[0].toUpperCase() +
                                data.status.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        print(
                          "🔍 Navigating to ServiceDirectViewScreen for Order ID: ${data.id}",
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDirectViewScreen(
                              id: data.id,
                              categreyId: categreyId,
                              subcategreyId: subcategreyId,
                            ),
                          ),
                        ).then((_) {
                          print(
                            "🔄 Returned to WorkerMyHireScreen, refreshing orders",
                          );
                          fetchDirectOrders();
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(90, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
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
  }

  Widget _buildBiddingCard(
    Map<String, dynamic> data,
    String? categreyId,
    String? subcategreyId,
  ) {
    print(
        "🛠 Building card for Bidding Task: ${data['title']}, Status: ${data['status']}");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/chair.png', // Static image from WorkerbiddingtaskScreen
              height: 110,
              width: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: _cardTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data['desc'],
                  style: _cardBody(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Posted Date: ${data['date']}",
                  style: _cardDate(),
                ),
                const SizedBox(height: 4),
                Text(
                  data['price'],
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (data['status'] != "")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(data['status']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data['status'].isEmpty
                              ? 'Pending'
                              : data['status'][0].toUpperCase() +
                                  data['status'].substring(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        print(
                          "🔍 Navigating to Biddingserviceproviderworkdetail for Task: ${data['title']}",
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Biddingserviceproviderworkdetail(),
                          ),
                        ).then((_) {
                          print(
                            "🔄 Returned to WorkerMyHireScreen, refreshing bidding tasks",
                          );
                          // No need to refresh static data, but kept for consistency
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(90, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
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
  }

  TextStyle _tabText({Color color = Colors.black}) => GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      );

  TextStyle _cardTitle() =>
      GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.bold);

  TextStyle _cardBody() => GoogleFonts.roboto(fontSize: 13);

  TextStyle _cardDate() =>
      GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700]);
}
