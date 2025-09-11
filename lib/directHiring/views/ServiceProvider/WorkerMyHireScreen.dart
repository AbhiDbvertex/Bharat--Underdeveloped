// import 'dart:convert';
//
// import 'package:developer/Emergency/Service_Provider/Screens/sp_work_detail.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../../Bidding/Models/bidding_order.dart';
// import '../../../Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
// import '../../../Emergency/Service_Provider/controllers/sp_emergency_service_controller.dart';
// import '../../../Emergency/Service_Provider/models/sp_emergency_list_model.dart';
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
//   List<DirectOrder> directOrders = [];
//   List<BiddingOrder> biddingOrders = [];
//   List<Map<String, dynamic>> emergencyItems = [
//     {
//       "title": "Fix plumbing issue",
//       "price": "₹2,000",
//       "desc": "Emergency pipe repair ...",
//       "view": "View Details",
//       "date": "21/02/25",
//       "status": "Pending",
//       "address": "Bhopal M.P.",
//     },
//     {
//       "title": "Electrical repair",
//       "price": "₹1,800",
//       "desc": "Urgent wiring fix ...",
//       "view": "View Details",
//       "date": "21/02/25",
//       "status": "Accepted",
//       "address": "Bhopal M.P.",
//     },
//   ];
//   List<BiddingOrder> filteredBiddingOrders = [];
//   List<DirectOrder> filteredDirectOrders = [];
//   List<Map<String, dynamic>> filteredEmergencyItems = [];
//   int selectedTab = 0; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency
//   String? currentProviderId;
//   final TextEditingController _biddingSearchController =
//       TextEditingController();
//   final TextEditingController _directSearchController = TextEditingController();
//   final TextEditingController _emergencySearchController =
//       TextEditingController();
//   SpEmergencyListModel? spEmergencyOrders;
//
//   @override
//   void initState() {
//     super.initState();
//     filteredBiddingOrders = biddingOrders;
//     filteredDirectOrders = directOrders;
//     filteredEmergencyItems = emergencyItems;
//     _loadProviderIdAndFetchOrders();
//     _biddingSearchController.addListener(() {
//       if (selectedTab == 0) _filterItems(_biddingSearchController.text);
//     });
//     _directSearchController.addListener(() {
//       if (selectedTab == 1) _filterItems(_directSearchController.text);
//     });
//     _emergencySearchController.addListener(() {
//       if (selectedTab == 2) _filterItems(_emergencySearchController.text);
//     });
//   }
//
//   Future<void> _loadProviderIdAndFetchOrders() async {
//     final prefs = await SharedPreferences.getInstance();
//     currentProviderId =
//         prefs.getString('provider_id') ?? '685e244fb93a9a07a9fe41ee';
//     print('🔑 Current Provider ID: $currentProviderId');
//     await fetchBiddingOrders();
//     await fetchDirectOrders();
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
//     print("🔄 Returned to WorkerMyHireScreen, refreshing data");
//     fetchBiddingOrders();
//     fetchDirectOrders();
//   }
//
//   @override
//   void dispose() {
//     final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
//     routeObserver.unsubscribe(this);
//     _biddingSearchController.dispose();
//     _directSearchController.dispose();
//     _emergencySearchController.dispose();
//     super.dispose();
//   }
//
//   // Fetch Bidding Orders
//   Future<void> fetchBiddingOrders() async {
//     setState(() => isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print('🔐 Token: $token');
//
//       final res = await http.get(
//         // Uri.parse('https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
//         Uri.parse(
//             'https://api.thebharatworks.com/api/bidding-order/getAvailableBiddingOrders'),
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
//           _showSnackBar("Bidding orders data not found!");
//         }
//       } else {
//         print("❌ API Error Status: ${res.statusCode}");
//         _showSnackBar("Failed to fetch bidding orders: ${res.statusCode}");
//       }
//     } catch (e) {
//       print("❌ API Exception: $e");
//       _showSnackBar("Something went wrong: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // Fetch Direct Orders
//   Future<void> fetchDirectOrders() async {
//     setState(() => isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print('🔐 Token: $token');
//
//       final res = await http.get(
//         Uri.parse(
//             'https://api.thebharatworks.com/api/direct-order/apiGetAllDirectOrders'),
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
//         final decoded = json.decode(res.body);
//         if (decoded.containsKey('data') && decoded['data'] is List) {
//           final List<dynamic> data = decoded['data'];
//           setState(() {
//             directOrders = data.map((e) {
//               final order = DirectOrder.fromJson(e);
//               String finalStatus = order.status.toLowerCase();
//               if (e['offer_history'] != null && currentProviderId != null) {
//                 for (var offer in e['offer_history']) {
//                   if (offer['provider_id']?['_id'] == currentProviderId) {
//                     final offerStatus =
//                         offer['status']?.toString().toLowerCase();
//                     print(
//                         '📩 Offer History for Order ${order.id}: Provider $currentProviderId, Status: $offerStatus');
//                     if (offerStatus == 'rejected' ||
//                         offerStatus == 'cancelled') {
//                       finalStatus = 'rejected';
//                     } else if (offerStatus == 'accepted') {
//                       finalStatus = 'accepted';
//                     }
//                     break;
//                   }
//                 }
//               }
//               print(
//                   '📋 Order ID: ${order.id}, Status: $finalStatus (Original: ${order.status})');
//               return DirectOrder(
//                 id: order.id,
//                 title: order.title,
//                 description: order.description,
//                 date: order.date,
//                 status: finalStatus,
//                 image: order
//                     .image, // Yeh line change hui, direct order.image use karo
//                 user_id: order.user_id,
//                 offer_history: order.offer_history,
//               );
//             }).toList();
//             filteredDirectOrders = directOrders;
//           });
//           print("✅ Direct Orders Fetched: ${directOrders.length}");
//         } else {
//           print("❌ 'data' key missing or invalid: ${decoded['data']}");
//           _showSnackBar("Direct orders data not found!");
//         }
//       } else {
//         print("❌ API Error Status: ${res.statusCode}");
//         _showSnackBar("Failed to fetch direct orders: ${res.statusCode}");
//       }
//     } catch (e) {
//       print("❌ API Exception: $e");
//       _showSnackBar("Something went wrong: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   // Filter Items based on selected tab
//   void _filterItems(String query) {
//     setState(() {
//       if (selectedTab == 0) {
//         if (query.isEmpty) {
//           filteredBiddingOrders = biddingOrders;
//         } else {
//           filteredBiddingOrders = biddingOrders.where((order) {
//             final title = order.title.toLowerCase();
//             final desc = order.description.toLowerCase();
//             return title.contains(query.toLowerCase()) ||
//                 desc.contains(query.toLowerCase());
//           }).toList();
//         }
//       } else if (selectedTab == 1) {
//         if (query.isEmpty) {
//           filteredDirectOrders = directOrders;
//         } else {
//           filteredDirectOrders = directOrders.where((order) {
//             final title = order.title.toLowerCase();
//             final desc = order.description.toLowerCase();
//             return title.contains(query.toLowerCase()) ||
//                 desc.contains(query.toLowerCase());
//           }).toList();
//         }
//       } else if (selectedTab == 2) {
//         if (query.isEmpty) {
//           filteredEmergencyItems = emergencyItems;
//         } else {
//           filteredEmergencyItems = emergencyItems.where((item) {
//             final title = item["title"].toString().toLowerCase();
//             final desc = item["desc"].toString().toLowerCase();
//             return title.contains(query.toLowerCase()) ||
//                 desc.contains(query.toLowerCase());
//           }).toList();
//         }
//       }
//     });
//   }
//
//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(message)));
//     }
//   }
//
//   Color _getStatusColor(String status) {
//     print("🎨 Checking status color for: $status");
//     switch (status.toLowerCase()) {
//       case 'cancelled':
//       case 'cancelledDispute':
//         return Colors.red;
//       case 'accepted':
//         return Colors.green;
//       case 'completed':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'rejected':
//         return Colors.red;
//       case 'review':
//         return Colors.brown;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: screenHeight * 0.05,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Padding(
//               padding: EdgeInsets.all(screenWidth * 0.03),
//               child: Center(
//                 child: Text(
//                   "My Work",
//                   style: GoogleFonts.roboto(
//                     fontSize: screenWidth * 0.045,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               height: screenHeight * 0.07,
//               color: Colors.green.shade100,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildTabButton("Bidding Tasks", 0, screenWidth),
//                   _verticalDivider(screenHeight),
//                   _buildTabButton("Direct Hiring", 1, screenWidth),
//                   _verticalDivider(screenHeight),
//                   _buildTabButton("Emergency Tasks", 2, screenWidth),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(screenWidth * 0.03),
//               child: Card(
//                 child: Container(
//                   height: screenHeight * 0.07,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.025,
//                     vertical: screenHeight * 0.015,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(screenWidth * 0.025),
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.search_rounded,
//                           color: Colors.grey, size: screenWidth * 0.06),
//                       SizedBox(width: screenWidth * 0.025),
//                       Expanded(
//                         child: TextField(
//                           controller: selectedTab == 0
//                               ? _biddingSearchController
//                               : selectedTab == 1
//                                   ? _directSearchController
//                                   : _emergencySearchController,
//                           decoration: InputDecoration(
//                             hintText: selectedTab == 0
//                                 ? 'Search for bidding tasks'
//                                 : selectedTab == 1
//                                     ? 'Search for direct hiring'
//                                     : 'Search for emergency tasks',
//                             hintStyle: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: screenWidth * 0.04),
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.015),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : selectedTab == 0
//                       ? _buildBiddingTasksList(screenWidth, screenHeight)
//                       : selectedTab == 1
//                           ? _buildDirectHiringList(screenWidth, screenHeight)
//                           : _buildEmergencyList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTabButton(String title, int tabIndex, double screenWidth) {
//     final isSelected = selectedTab == tabIndex;
//     return ElevatedButton(
//       onPressed: () async {
//         setState(() {
//           selectedTab = tabIndex;
//           _biddingSearchController.clear();
//           _directSearchController.clear();
//           _emergencySearchController.clear();
//           filteredBiddingOrders = biddingOrders;
//           filteredDirectOrders = directOrders;
//           filteredEmergencyItems = emergencyItems;
//         });
//         if (selectedTab == 2) {
//           final orders =
//               await SpEmergencyServiceController().getEmergencySpOrderByRole();
//           setState(() {
//             spEmergencyOrders = orders;
//             isLoading = false;
//           });
//         } else {
//           setState(() => isLoading = false);
//         }
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor:
//             isSelected ? Colors.green.shade700 : Colors.green.shade100,
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(screenWidth * 0.05)),
//       ),
//       child: Text(
//         title,
//         style: _tabText(
//             color: isSelected ? Colors.white : Colors.black,
//             fontSize: screenWidth * 0.03),
//       ),
//     );
//   }
//
//   Widget _verticalDivider(double screenHeight) {
//     return Container(
//         width: 1, height: screenHeight * 0.05, color: Colors.white38);
//   }
//
//   Widget _buildDirectHiringList(double screenWidth, double screenHeight) {
//     if (filteredDirectOrders.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(child: Text("No Direct Hiring Found")),
//       );
//     }
//
//     return Column(
//       children: List.generate(
//         filteredDirectOrders.length,
//         (index) => _buildHireCard(
//           filteredDirectOrders[index],
//           widget.categreyId,
//           widget.subcategreyId,
//           screenWidth,
//           screenHeight,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBiddingTasksList(double screenWidth, double screenHeight) {
//     if (filteredBiddingOrders.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(child: Text("No Bidding Tasks Found")),
//       );
//     }
//
//     return Column(
//       children: List.generate(
//         filteredBiddingOrders.length,
//         (index) => _buildBiddingCard(
//           filteredBiddingOrders[index],
//           widget.categreyId,
//           widget.subcategreyId,
//           screenWidth,
//           screenHeight,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmergencyList() {
//     if (spEmergencyOrders == null || spEmergencyOrders!.data.isEmpty) {
//       return const Center(child: Text("No Emergency Orders Found"));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: ListView.builder(
//         itemCount: spEmergencyOrders!.data.length,
//         itemBuilder: (context, index) =>
//             _buildEmergencyCard(spEmergencyOrders!.data[index]),
//       ),
//     );
//   }
//
//   Widget _buildHireCard(
//     DirectOrder data,
//     String? categreyId,
//     String? subcategreyId,
//     double screenWidth,
//     double screenHeight,
//   ) {
//     // Check karo ki image field khali toh nahi
//     final bool hasImage = data.image.isNotEmpty;
//     print(
//         "🛠 Card ban raha hai, Order ID: ${data.id}, Status: ${data.status}, Image: ${data.image}, Address: ${data.address}");
//
//     return Container(
//       margin: EdgeInsets.only(bottom: screenHeight * 0.015),
//       padding: EdgeInsets.all(screenWidth * 0.025),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(screenWidth * 0.035),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(screenWidth * 0.02),
//             child: hasImage
//                 ? Image.network(
//                     data.image,
//                     height: screenHeight * 0.15,
//                     width: screenWidth * 0.3,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       print(
//                           'Image load nahi hui: ${data.image}, Error: $error');
//                       return Image.asset(
//                         'assets/images/task.png',
//                         height: screenHeight * 0.15,
//                         width: screenWidth * 0.3,
//                         fit: BoxFit.cover,
//                       );
//                     },
//                   )
//                 : Image.asset(
//                     'assets/images/task.png',
//                     height: screenHeight * 0.15,
//                     width: screenWidth * 0.3,
//                     fit: BoxFit.cover,
//                   ),
//           ),
//           SizedBox(width: screenWidth * 0.025),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   data.title,
//                   style: _cardTitle(fontSize: screenWidth * 0.04),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 Text(
//                   data.description,
//                   style: _cardBody(fontSize: screenWidth * 0.035),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 Text(
//                   "Posted Date: ${data.date}",
//                   style: _cardDate(fontSize: screenWidth * 0.03),
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 SizedBox(height: screenHeight * 0.008),
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: screenWidth * 0.02,
//                         vertical: screenHeight * 0.005,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _getStatusColor(data.status),
//                         borderRadius:
//                             BorderRadius.circular(screenWidth * 0.015),
//                       ),
//                       child: Text(
//                         data.status.isEmpty
//                             ? 'Pending'
//                             : data.status[0].toUpperCase() +
//                                 data.status.substring(1),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: screenWidth * 0.03,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     TextButton(
//                       onPressed: () {
//                         print(
//                             "🔍 ServiceDirectViewScreen pe ja raha hai, Order ID: ${data.id}");
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
//                               "🔄 Wapas aaya WorkerMyHireScreen pe, orders refresh kar raha hai");
//                           fetchDirectOrders();
//                         });
//                       },
//                       style: TextButton.styleFrom(
//                         backgroundColor: Colors.green.shade700,
//                         minimumSize:
//                             Size(screenWidth * 0.25, screenHeight * 0.05),
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(screenWidth * 0.015),
//                         ),
//                       ),
//                       child: Text(
//                         "View Details",
//                         style: GoogleFonts.roboto(
//                           color: Colors.white,
//                           fontSize: screenWidth * 0.03,
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
//   Widget _buildBiddingCard(
//     BiddingOrder data,
//     String? categoryId,
//     String? subcategoryId,
//     double screenWidth,
//     double screenHeight,
//   ) {
//     print(
//         "🛠 Building card for Task: ${data.title}, Status: ${data.hireStatus}");
//     print("Image URLs: ${data.imageUrls}");
//
//     return Container(
//       margin: EdgeInsets.only(bottom: screenHeight * 0.015),
//       padding: EdgeInsets.all(screenWidth * 0.025),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(screenWidth * 0.035),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(screenWidth * 0.02),
//             child: Container(
//               alignment: Alignment.topCenter,
//               child: data.imageUrls.isNotEmpty
//                   ? Image.network(
//                       data.imageUrls.first,
//                       height: screenHeight * 0.16,
//                       width: screenWidth * 0.32,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         print(
//                             'Error loading image: ${data.imageUrls.first}, Error: $error');
//                         return Image.asset(
//                           'assets/images/chair.png',
//                           height: screenHeight * 0.16,
//                           width: screenWidth * 0.32,
//                           fit: BoxFit.cover,
//                         );
//                       },
//                     )
//                   : Image.asset(
//                       'assets/images/chair.png',
//                       height: screenHeight * 0.16,
//                       width: screenWidth * 0.32,
//                       fit: BoxFit.cover,
//                     ),
//             ),
//           ),
//           SizedBox(width: screenWidth * 0.025),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   data.title,
//                   style: _cardTitle(fontSize: screenWidth * 0.04),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 Text(
//                   '₹${data.cost.toStringAsFixed(0)}',
//                   style: GoogleFonts.roboto(
//                     fontSize: screenWidth * 0.035,
//                     color: Colors.green,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 Text(
//                   data.description,
//                   style: _cardBody(fontSize: screenWidth * 0.035),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Date: ${data.deadline.split('T').first}",
//                       style: _cardDate(fontSize: screenWidth * 0.03),
//                     ),
//                     if (data.hireStatus != "")
//                       Padding(
//                         padding: EdgeInsets.only(left: screenWidth * 0.05),
//                         child: Container(
//                           height: 25,
//                           width: 80,
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(data.hireStatus),
//                             borderRadius:
//                                 BorderRadius.circular(screenWidth * 0.015),
//                           ),
//                           child: Center(
//                             child: Text(
//                               data.hireStatus.isEmpty
//                                   ? 'Pending'
//                                   : data.hireStatus[0].toUpperCase() +
//                                       data.hireStatus.substring(1),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: screenWidth * 0.03,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: screenHeight * 0.005),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       height: 20,
//                       width: 100,
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade300,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Center(
//                         child: Text(
//                           data.address,
//                           style: GoogleFonts.roboto(
//                             fontSize: screenWidth * 0.035,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         print(
//                             'Navigating to details with orderId: ${data.id}, status: ${data.hireStatus}');
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 Biddingserviceproviderworkdetail(
//                               orderId: data.id,
//                               hireStatus: data.hireStatus, // Pass hireStatus
//                             ),
//                           ),
//                         ).then((_) {
//                           print(
//                               "🔄 Returned to WorkerMyHireScreen, refreshing bidding tasks");
//                           fetchBiddingOrders();
//                         });
//                       },
//                       child: Padding(
//                         padding: EdgeInsets.only(top: screenHeight * 0.01),
//                         child: SizedBox(
//                           width: screenWidth * 0.2,
//                           height: screenHeight * 0.04,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade700,
//                               borderRadius:
//                                   BorderRadius.circular(screenWidth * 0.02),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "View Details",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: screenWidth * 0.03,
//                                 ),
//                               ),
//                             ),
//                           ),
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
//   Widget _buildEmergencyCard(data) {
//     //   bwDebug("[_buildEmergencyCard] call ",tag:"myHireScreen ");
//
//     String displayStatus = data.hireStatus ?? "pending";
//
//     // Last accepted status check karna
//     if (data.acceptedByProviders != null &&
//         data.acceptedByProviders!.isNotEmpty &&
//         displayStatus != 'cancelled' &&
//         displayStatus != 'completed') {
//       displayStatus = data.acceptedByProviders!.last.status ?? displayStatus;
//     }
//
//     // Image check
//     final bool hasImage = data.imageUrls != null && data.imageUrls!.isNotEmpty;
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
//         border: Border.all(
//           color: AppColors.primaryGreen, // <-- primary color border
//           width: 1.5, // thickness
//         ),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Stack(
//               children: [
//                 hasImage
//                     ? Image.network(
//                         data.imageUrls!.first, // first image show karenge
//                         height: 200,
//                         width: 110,
//                         fit: BoxFit.cover,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Container(
//                             height: 200,
//                             width: 110,
//                             alignment: Alignment.center,
//                             child: const CircularProgressIndicator(
//                               color: AppColors.primaryGreen,
//                               strokeWidth: 2.5,
//                             ),
//                           );
//                         },
//                         errorBuilder: (context, error, stackTrace) =>
//                             Image.asset('assets/images/task.png',
//                                 height: 150, width: 110, fit: BoxFit.cover),
//                       )
//                     : Image.asset('assets/images/task.png',
//                         height: 150, width: 110, fit: BoxFit.cover),
//                 Positioned(
//                   bottom: 5,
//                   left: 5,
//                   right: 5,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(15), // corner circle
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                     child: Text(
//                       "${data.projectId ?? 'N/A'}", // product id
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   data.categoryId.name ?? "",
//                   style: _cardTitle(fontSize: 15),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   "₹${data.servicePayment.amount} " ?? "0",
//                   style: _cardBody(fontSize: 13).copyWith(
//                       color: AppColors.primaryGreen,
//                       fontWeight: FontWeight.bold),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Container(
//                   height: 1, // thickness
//                   color: Colors.grey.shade200, // light color
//                   margin: const EdgeInsets.symmetric(vertical: 4),
//                 ),
//                 Row(
//                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   // crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         data.subCategoryIds.isNotEmpty
//                             ? data.subCategoryIds
//                                 .take(2)
//                                 .map((e) => e.name)
//                                 .join(", ")
//                             : "",
//                         style: _cardDate(fontSize: 11),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed: () {
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (_) => DirectViewScreen(
//                         //       id: data.id ?? '',
//                         //       categreyId: data.categoryId?._id ?? '',
//                         //       subcategreyId: data.subCategoryIds != null && data.subCategoryIds!.isNotEmpty
//                         //           ? data.subCategoryIds!.first._id!
//                         //           : '',
//                         //     ),
//                         //   ),
//                         // ).then((_) => fetchDirectOrders());
//                       },
//                       style: TextButton.styleFrom(
//                         backgroundColor: Color(0xff353026),
//                         minimumSize: const Size(70, 20),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: Text(
//                         "Review",
//                         style: GoogleFonts.roboto(
//                             color: Colors.white, fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   // crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         "Date: ${data.deadline != null ? DateFormat('dd/MM/yyyy').format(data.deadline!.toLocal()) : 'N/A'}",
//                         style: _cardDate(fontSize: 11),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//
//                     // TextButton(
//                     //   onPressed: () {
//                     //     // Navigator.push(
//                     //     //   context,
//                     //     // MaterialPageRoute(
//                     //     //   builder: (_) => DirectViewScreen(
//                     //     //     id: data.id ?? '',
//                     //     //     categreyId: data.categoryId?._id ?? '',
//                     //     //     subcategreyId: data.subCategoryIds != null && data.subCategoryIds!.isNotEmpty
//                     //     //         ? data.subCategoryIds!.first._id!
//                     //     //         : '',
//                     //     //   ),
//                     //     // ),
//                     //     // ).then((_) => fetchDirectOrders());
//                     //   },
//                     //   style: TextButton.styleFrom(
//                     //     backgroundColor: _getStatusColor(data.hireStatus),
//                     //     minimumSize: const Size(70, 10),
//                     //     shape: RoundedRectangleBorder(
//                     //       borderRadius: BorderRadius.circular(10),
//                     //     ),
//                     //   ),
//                     //   child: Text(
//                     //     "${data.hireStatus[0].toUpperCase()}${data.hireStatus.substring(1)}",
//                     //     style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
//                     //   ),
//                     // ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8, horizontal: 12),
//                       decoration: BoxDecoration(
//                         color: _getStatusColor(data.hireStatus),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         "${data.hireStatus[0].toUpperCase()}${data.hireStatus.substring(1)}",
//                         style: GoogleFonts.roboto(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   // crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 5, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: Color(0xffF27773),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           data.googleAddress,
//                           maxLines: 1, //
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => SpWorkDetail(
//                                     data.id,
//                                     isUser: true,
//                                   )),
//                         ).then(
//                           (_) async {
//                             final orders = await SpEmergencyServiceController()
//                                 .getEmergencySpOrderByRole();
//                             setState(() {
//                               spEmergencyOrders = orders;
//                             });
//                           },
//                         );
//                       },
//                       style: TextButton.styleFrom(
//                         backgroundColor: Colors.green.shade700,
//                         minimumSize: const Size(70, 20),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: Text(
//                         "View Details",
//                         style: GoogleFonts.roboto(
//                             color: Colors.white, fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   TextStyle _tabText({Color color = Colors.black, required double fontSize}) =>
//       GoogleFonts.roboto(
//         color: color,
//         fontWeight: FontWeight.w500,
//         fontSize: fontSize,
//       );
//
//   TextStyle _cardTitle({required double fontSize}) =>
//       GoogleFonts.roboto(fontSize: fontSize, fontWeight: FontWeight.bold);
//
//   TextStyle _cardBody({required double fontSize}) =>
//       GoogleFonts.roboto(fontSize: fontSize);
//
//   TextStyle _cardDate({required double fontSize}) =>
//       GoogleFonts.roboto(fontSize: fontSize, color: Colors.grey[700]);
// }

import 'dart:convert';

import 'package:developer/Emergency/Service_Provider/Screens/sp_work_detail.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/map_launcher_lat_long.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../Bidding/Models/bidding_order.dart';
import '../../../Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
import '../../../Emergency/Service_Provider/controllers/sp_emergency_service_controller.dart';
import '../../../Emergency/Service_Provider/models/sp_emergency_list_model.dart';
import '../../../Emergency/Service_Provider/models/sp_review_model.dart';
import '../../../Emergency/User/screens/sp_review_screen.dart';
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
  List<BiddingOrder> biddingOrders = [];
  List<Map<String, dynamic>> emergencyItems = [
    {
      "title": "Fix plumbing issue",
      "price": "₹2,000",
      "desc": "Emergency pipe repair ...",
      "view": "View Details",
      "date": "21/02/25",
      "status": "Pending",
      "address": "Bhopal M.P.",
    },
    {
      "title": "Electrical repair",
      "price": "₹1,800",
      "desc": "Urgent wiring fix ...",
      "view": "View Details",
      "date": "21/02/25",
      "status": "Accepted",
      "address": "Bhopal M.P.",
    },
  ];
  List<BiddingOrder> filteredBiddingOrders = [];
  List<DirectOrder> filteredDirectOrders = [];
  List<Map<String, dynamic>> filteredEmergencyItems = [];
  int selectedTab = 0; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency
  String? currentProviderId;
  final TextEditingController _biddingSearchController =
      TextEditingController();
  final TextEditingController _directSearchController = TextEditingController();
  final TextEditingController _emergencySearchController =
      TextEditingController();
  SpEmergencyOrderListModel? spEmergencyOrders;

  @override
  void initState() {
    super.initState();
    filteredBiddingOrders = biddingOrders;
    filteredDirectOrders = directOrders;
    filteredEmergencyItems = emergencyItems;
    _loadProviderIdAndFetchOrders();
    _biddingSearchController.addListener(() {
      if (selectedTab == 0) _filterItems(_biddingSearchController.text);
    });
    _directSearchController.addListener(() {
      if (selectedTab == 1) _filterItems(_directSearchController.text);
    });
    _emergencySearchController.addListener(() {
      if (selectedTab == 2) _filterItems(_emergencySearchController.text);
    });
  }

  Future<void> _loadProviderIdAndFetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    currentProviderId =
        prefs.getString('provider_id') ?? '685e244fb93a9a07a9fe41ee';
    print('🔑 Current Provider ID: $currentProviderId');
    await fetchBiddingOrders();
    await fetchDirectOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    print("🔄 Returned to WorkerMyHireScreen, refreshing data");
    fetchBiddingOrders();
    fetchDirectOrders();
  }

  @override
  void dispose() {
    final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
    routeObserver.unsubscribe(this);
    _biddingSearchController.dispose();
    _directSearchController.dispose();
    _emergencySearchController.dispose();
    super.dispose();
  }

  // Fetch Bidding Orders
  Future<void> fetchBiddingOrders() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print('🔐 Token: $token');

      final res = await http.get(
        Uri.parse(
            // 'https://api.thebharatworks.com/api/bidding-order/getAvailableBiddingOrders'),
            //     Abhishek added new link
            'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
        // 'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
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
            biddingOrders = data.map((e) {
              final order = BiddingOrder.fromJson(e);
              String finalStatus = order.hireStatus.toLowerCase();
              if (e['accepted_negotiation_id'] != null &&
                  currentProviderId != null) {
                final negotiation = e['accepted_negotiation_id'];
                if (negotiation['service_provider'] == currentProviderId) {
                  if (!negotiation['is_accepted_by_user']) {
                    finalStatus = 'pending';
                  }
                }
              }
              print('📋 Bidding Order ID: ${order.id}, Status: $finalStatus');
              return BiddingOrder(
                id: order.id,
                projectId: order.projectId,
                title: order.title,
                description: order.description,
                address: order.address,
                cost: order.cost,
                deadline: order.deadline,
                hireStatus: finalStatus,
                serviceProviderId: order.serviceProviderId,
                imageUrls: order.imageUrls,
                userId: order.userId,
                categoryId: order.categoryId,
                subcategoryIds: order.subcategoryIds,
                servicePayment: order.servicePayment,
                latitude: order.latitude,
                longitude: order.longitude,
              );
            }).toList();
            filteredBiddingOrders = biddingOrders;
            print("✅ Bidding Orders Fetched: ${biddingOrders.length}");
            print(
                "Hire Statuses: ${biddingOrders.map((e) => e.hireStatus).toList()}");
            print(
                "Image URLs in Orders: ${biddingOrders.map((e) => e.imageUrls).toList()}");
            print(
                "Project IDs: ${biddingOrders.map((e) => e.projectId).toList()}");
            print(
                "Category IDs: ${biddingOrders.map((e) => e.categoryId).toList()}");
            print(
                "Subcategory IDs: ${biddingOrders.map((e) => e.subcategoryIds).toList()}");
          });
        } else {
          print("❌ 'data' key missing or invalid: ${decoded['data']}");
          _showSnackBar("Bidding orders data not found!");
        }
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        // _showSnackBar("Failed to fetch bidding orders: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: $e");
      // _showSnackBar("Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
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
              print('📋 Order ID: ${order.id}, Status: $finalStatus (Original: ${order.status})');
              return DirectOrder(
                id: order.id,
                title: order.title,
                description: order.description,
                date: order.date,
                status: finalStatus,
                image: order.image,
                user_id: order.user_id,
                offer_history: order.offer_history,
              );
            }).toList();
            filteredDirectOrders = directOrders;
          });
          print("✅ Direct Orders Fetched: ${directOrders.length}");
        } else {
          print("❌ 'data' key missing or invalid: ${decoded['data']}");
          _showSnackBar("Direct orders data not found!");
        }
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        // _showSnackBar("Failed to fetch direct orders: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: $e");
      // _showSnackBar("Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Filter Items based on selected tab
  void _filterItems(String query) {
    setState(() {
      if (selectedTab == 0) {
        if (query.isEmpty) {
          filteredBiddingOrders = biddingOrders;
        } else {
          filteredBiddingOrders = biddingOrders.where((order) {
            final title = order.title.toLowerCase();
            final desc = order.description.toLowerCase();
            return title.contains(query.toLowerCase()) ||
                desc.contains(query.toLowerCase());
          }).toList();
        }
      } else if (selectedTab == 1) {
        if (query.isEmpty) {
          filteredDirectOrders = directOrders;
        } else {
          filteredDirectOrders = directOrders.where((order) {
            final title = order.title.toLowerCase();
            final desc = order.description.toLowerCase();
            return title.contains(query.toLowerCase()) ||
                desc.contains(query.toLowerCase());
          }).toList();
        }
      } else if (selectedTab == 2) {
        if (query.isEmpty) {
          filteredEmergencyItems = emergencyItems;
        } else {
          filteredEmergencyItems = emergencyItems.where((item) {
            final title = item["title"].toString().toLowerCase();
            final desc = item["desc"].toString().toLowerCase();
            return title.contains(query.toLowerCase()) ||
                desc.contains(query.toLowerCase());
          }).toList();
        }
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
    // print("🎨 Checking status color for: $status");
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: screenHeight * 0.013,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Center(
                child: Text(
                  "My Work",
                  style: GoogleFonts.roboto(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.0035,),
            Container(
              width: double.infinity,
              height: screenHeight * 0.063,
              color: Colors.green.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton("Bidding Tasks", 0, screenWidth),
                  _verticalDivider(screenHeight),
                  _buildTabButton("Direct Hiring", 1, screenWidth),
                  _verticalDivider(screenHeight),
                  _buildTabButton("Emergency Tasks", 2, screenWidth),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Card(
                child: Container(
                  height: screenHeight * 0.07,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: Colors.grey, size: screenWidth * 0.06),
                      SizedBox(width: screenWidth * 0.025),
                      Expanded(
                        child: TextField(
                          controller: selectedTab == 0
                              ? _biddingSearchController
                              : selectedTab == 1
                                  ? _directSearchController
                                  : _emergencySearchController,
                          decoration: InputDecoration(
                            hintText: selectedTab == 0
                                ? 'Search for bidding tasks'
                                : selectedTab == 1
                                    ? 'Search for direct hiring'
                                    : 'Search for emergency tasks',
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
            ),
            SizedBox(height: screenHeight * 0.015),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selectedTab == 0
                      ? _buildBiddingTasksList(screenWidth, screenHeight)
                      : selectedTab == 1
                          ? _buildDirectHiringList(screenWidth, screenHeight)
                          : _buildEmergencyList(screenWidth, screenHeight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int tabIndex, double screenWidth) {
    final isSelected = selectedTab == tabIndex;
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          selectedTab = tabIndex;
          _biddingSearchController.clear();
          _directSearchController.clear();
          _emergencySearchController.clear();
          filteredBiddingOrders = biddingOrders;
          filteredDirectOrders = directOrders;
          filteredEmergencyItems = emergencyItems;
        });
        if (selectedTab == 2) {
          setState(() => isLoading = true);

          final orders =
              await SpEmergencyServiceController().getEmergencySpOrderByRole();
          setState(() {
            spEmergencyOrders = orders;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.green.shade700 : Colors.green.shade100,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05)),
      ),
      child: Text(
        title,
        style: _tabText(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: screenWidth * 0.034),
      ),
    );
  }

  Widget _verticalDivider(double screenHeight) {
    return Container(
        width: 1, height: screenHeight * 0.05, color: Colors.white38);
  }

  Widget _buildDirectHiringList(double screenWidth, double screenHeight) {
    if (filteredDirectOrders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("No Direct Hiring Found")),
      );
    }

    return Column(
      children: List.generate(
        filteredDirectOrders.length,
        (index) => _buildHireCard(
          filteredDirectOrders[index],
          widget.categreyId,
          widget.subcategreyId,
          screenWidth,
          screenHeight,
        ),
      ),
    );
  }

  Widget _buildBiddingTasksList(double screenWidth, double screenHeight) {
    if (filteredBiddingOrders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("No Bidding Tasks Found")),
      );
    }

    return Column(
      children: List.generate(
        filteredBiddingOrders.length,
        (index) => _buildBiddingCard(
          filteredBiddingOrders[index],
          widget.categreyId,
          widget.subcategreyId,
          screenWidth,
          screenHeight,
        ),
      ),
    );
  }

  Widget _buildEmergencyList(double screenWidth, double screenHeight) {
    if (spEmergencyOrders == null || spEmergencyOrders!.data.isEmpty) {
      return const Center(child: Text("No Emergency Orders Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 550,
        width: 1.toWidthPercent(),
        child: ListView.builder(
          itemCount: spEmergencyOrders!.data.length,
          itemBuilder: (context, index) => _buildEmergencyCard(
              spEmergencyOrders!.data[index], screenWidth, screenHeight),
        ),
      ),
    );
  }

  Widget _buildHireCard(
    DirectOrder data,
    String? categreyId,
    String? subcategreyId,
    double screenWidth,
    double screenHeight,
  ) {
    final bool hasImage = data.image.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
          color: Colors.grey,
          child: Stack(
            children: [ ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              child: hasImage
                  ? Image.network(
                      data.image,
                      height: screenHeight * 0.15,
                      width: screenWidth * 0.3,
                      // fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            'Image load nahi hui: ${data.image}, Error: $error');
                        return Image.asset(
                          'assets/images/task.png',
                          height: screenHeight * 0.15,
                          width: screenWidth * 0.3,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/task.png',
                      height: screenHeight * 0.15,
                      width: screenWidth * 0.3,
                      fit: BoxFit.cover,
                    ),
            ),
              Positioned(
                bottom: 10,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(5)),
                  child: Center(child: Text(data.projectid ?? "",style: TextStyle(color: Colors.white), maxLines: 1,
                    overflow: TextOverflow.ellipsis,)),),
              ),
          ],),
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: _cardTitle(fontSize: screenWidth * 0.04),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  data.description,
                  style: _cardBody(fontSize: screenWidth * 0.035),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  "Posted Date: ${data.date}",
                  style: _cardDate(fontSize: screenWidth * 0.03),
                ),
                SizedBox(height: screenHeight * 0.008),
                Row(
                  children: [
                    Container(
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.03,
                      // padding: EdgeInsets.symmetric(
                      //   horizontal: screenWidth * 0.05,
                      //   vertical: screenHeight * 0.005,
                      // ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(data.status),
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.015),
                      ),
                      child: Center(
                        child: Text(
                          data.status.isEmpty
                              ? 'Pending'
                              : data.status == 'cancelleddispute'
                                  ? 'Cancelled Dispute'
                                  : data.status[0].toUpperCase() +
                                      data.status.substring(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        print(
                            "🔍 ServiceDirectViewScreen pe ja raha hai, Order ID: ${data.id}");
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
                          //  Abhishek check screen refrase the code

                          fetchDirectOrders();
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize:
                            Size(screenWidth * 0.25, screenHeight * 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.015),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
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
    BiddingOrder data,
    String? categoryId,
    String? subcategoryId,
    double screenWidth,
    double screenHeight,
  ) {
    print("Building card for Task: ${data.title} ,projectId : ${data.projectId}, Status: ${data.hireStatus}, Project ID: ${data.projectId}, Category ID: ${data.categoryId}, Subcategory IDs: ${data.subcategoryIds}");

    print("Image URLs: ${data.imageUrls}");

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children:[ Container(color: Colors.grey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                child: Container(
                  alignment: Alignment.topCenter,
                  child: data.imageUrls.isNotEmpty
                      ? Image.network(
                          data.imageUrls.first,
                          height: screenHeight * 0.16,
                          width: screenWidth * 0.32,
                          // fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                'Error loading image: ${data.imageUrls.first}, Error: $error');
                            return Image.asset(
                              'assets/images/chair.png',
                              height: screenHeight * 0.16,
                              width: screenWidth * 0.32,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/chair.png',
                          height: screenHeight * 0.16,
                          width: screenWidth * 0.32,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
              Positioned(
                bottom: 10,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(5)),
                  child: Center(child: Text(data.projectId,style: TextStyle(color: Colors.white), maxLines: 1,
                    overflow: TextOverflow.ellipsis,)),),
              )
          ],),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: _cardTitle(fontSize: screenWidth * 0.04),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  '₹${data.cost.toStringAsFixed(0)}',
                  style: GoogleFonts.roboto(
                    fontSize: screenWidth * 0.035,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  data.description,
                  style: _cardBody(fontSize: screenWidth * 0.035),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ${data.deadline.split('T').first}",
                      style: _cardDate(fontSize: screenWidth * 0.03),
                    ),
                    if (data.hireStatus.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.05),
                        child: Container(
                          height: 25,
                          width: 70,
                          decoration: BoxDecoration(
                            color: _getStatusColor(data.hireStatus),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.015),
                          ),
                          child: Center(
                            child: Text(
                              data.hireStatus.isEmpty
                                  ? 'Pending'
                                  : data.hireStatus == 'cancelledDispute'
                                      ? 'Cancelled Dispute'
                                      : data.hireStatus[0].toUpperCase() +
                                          data.hireStatus.substring(1),
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: screenWidth * 0.022,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        // MapLauncher.openMap(address: data.address);
                        MapLauncher.openMap(latitude: data.latitude, longitude: data.longitude,address: data.address);
                      },
                      child: Container(
                        height: 20,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            data.address,
                            style: GoogleFonts.roboto(
                              fontSize: screenWidth * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        var result = print(
                            'Navigating to details with orderId: ${data.id}, status: ${data.hireStatus}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Biddingserviceproviderworkdetail(
                              orderId: data.id,
                              hireStatus: data.hireStatus,
                            ),
                          ),
                        ).then((_) {
                          print(
                              "🔄 Returned to WorkerMyHireScreen, refreshing bidding tasks");
                          if (_ == true) {
                            fetchBiddingOrders();
                          }
                          fetchBiddingOrders();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.01),
                        child: SizedBox(
                          width: screenWidth * 0.2,
                          height: screenHeight * 0.04,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Center(
                              child: Text(
                                "View Details",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
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
  }

  Widget _buildEmergencyCard(
      dynamic data, double screenWidth, double screenHeight) {
    String displayStatus = data.hireStatus ?? "pending";

    if (data.acceptedByProviders != null &&
        data.acceptedByProviders!.isNotEmpty &&
        displayStatus != 'cancelled' &&
        displayStatus != 'completed') {
      displayStatus = data.acceptedByProviders!.last.status ?? displayStatus;
    }

    final bool hasImage = data.imageUrls != null && data.imageUrls!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: Stack(
              children: [
                hasImage
                    ? Container(
                      color: Colors.grey,
                      child: Image.network(
                          data.imageUrls!.first,
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.3,
                          // fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: screenHeight * 0.2,
                              width: screenWidth * 0.3,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: AppColors.primaryGreen,
                                strokeWidth: 2.5,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/task.png',
                                  height: screenHeight * 0.2,
                                  width: screenWidth * 0.3,
                                  fit: BoxFit.cover),
                        ),
                    )
                    : Image.asset('assets/images/task.png',
                        height: screenHeight * 0.2,
                        width: screenWidth * 0.3,
                        fit: BoxFit.cover),
                Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.005,
                        horizontal: screenWidth * 0.02),
                    child: Text(
                      "${data.projectId ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.categoryId.name ?? "",
                  style: _cardTitle(fontSize: screenWidth * 0.04),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "₹${data.servicePayment?.amount ?? 0}",
                  style: _cardBody(fontSize: screenWidth * 0.035).copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.subCategoryIds.isNotEmpty
                            ? data.subCategoryIds
                                .take(2)
                                .map((e) => e.name)
                                .join(", ")
                            : "",
                        style: _cardDate(fontSize: screenWidth * 0.03),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    TextButton(
                      onPressed: () {
                        final reviews = [
                          SpReviewModel(
                            title: "Made a computer table",
                            description:
                                "It is a long established fact that a reader will be distracted...",
                            date: "14 Apr, 2023",
                            rating: 4,
                            images: [
                              "https://picsum.photos/200",
                              "https://picsum.photos/201",
                              "https://picsum.photos/202",
                            ],
                          ),
                        ];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SpReviewScreen(reviews: reviews),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xff353026),
                        minimumSize:
                            Size(screenWidth * 0.2, screenHeight * 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                        ),
                      ),
                      child: Text(
                        "Review",
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: screenWidth * 0.03),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${data.deadline != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(data.deadline).toLocal()) : 'N/A'}",
                        style: _cardDate(fontSize: screenWidth * 0.03),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: _getStatusColor(displayStatus),
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.025),
                      ),
                      child: Text(
                        displayStatus.isEmpty
                            ? 'Pending'
                            : displayStatus == 'cancelledDispute'
                                ? 'Cancelled Dispute'
                                : displayStatus[0].toUpperCase() +
                                    displayStatus.substring(1),
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          bwDebug("tap ");
                          // MapLauncher.openMap(address: data.googleAddress);
                          MapLauncher.openMap(latitude: data.latitude,longitude: data.longitude,address: data.googleAddress);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenHeight * 0.005),
                          decoration: BoxDecoration(
                            color: const Color(0xffF27773),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.025),
                          ),
                          child: Text(
                            data.googleAddress ?? 'N/A',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SpWorkDetail(
                                    data.id,
                                    isUser: true,
                                  )),
                        ).then(
                          (_) async {
                            final orders = await SpEmergencyServiceController()
                                .getEmergencySpOrderByRole();
                            setState(() {
                              spEmergencyOrders = orders;
                            });
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize:
                            Size(screenWidth * 0.2, screenHeight * 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: screenWidth * 0.03),
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

  TextStyle _tabText({Color color = Colors.black, required double fontSize}) =>
      GoogleFonts.roboto(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: fontSize,
      );

  TextStyle _cardTitle({required double fontSize}) =>
      GoogleFonts.roboto(fontSize: fontSize, fontWeight: FontWeight.bold);

  TextStyle _cardBody({required double fontSize}) =>
      GoogleFonts.roboto(fontSize: fontSize);

  TextStyle _cardDate({required double fontSize}) =>
      GoogleFonts.roboto(fontSize: fontSize, color: Colors.grey[700]);
}
