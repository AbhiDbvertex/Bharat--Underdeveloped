//
// import 'dart:convert';
// import 'package:developer/directHiring/views/ServiceProvider/view_user_profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Consent/ApiEndpoint.dart';
// import '../../Consent/app_constants.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../models/userModel/subCategoriesModel.dart';
// import 'ServiceDisputeScreen.dart';
// import 'ServiceWorkerListScreen.dart';
// // import 'ViewUserProfileScreen.dart';
// import 'WorkerListViewProfileScreen.dart';
//
// class ServiceDirectViewScreen extends StatefulWidget {
//   final String id;
//   final String? categreyId;
//   final String? subcategreyId;
//   const ServiceDirectViewScreen({
//     super.key,
//     required this.id,
//     this.categreyId,
//     this.subcategreyId,
//   });
//
//   @override
//   State<ServiceDirectViewScreen> createState() =>
//       _ServiceDirectViewScreenState();
// }
//
// class _ServiceDirectViewScreenState extends State<ServiceDirectViewScreen> {
//   bool isLoading = true;
//   Map<String, dynamic>? order;
//   Map<String, dynamic>? providerDetail;
//   List<ServiceProviderModel> providerslist = [];
//   String? orderProviderId;
//   ScaffoldMessengerState? _scaffoldMessenger;
//   bool _isProcessing = false;
//   bool _isOrderAccepted = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _scaffoldMessenger = ScaffoldMessenger.of(context);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchOrderDetail();
//   }
//
//   /*Future<void> fetchOrderDetail() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print("📋 Token mil gaya: $token");
//
//       if (token.isEmpty) {
//         setState(() => isLoading = false);
//         _showSnackBar("Bhai, pehle login toh kar le!");
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse(
//           'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
//         ),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         print("📥 Pura Response: ${response.body}");
//         print("🔍 Order Data: ${decoded['data']['order']}");
//         print("🔍 Assigned Worker Data: ${decoded['data']['assignedWorker']}");
//
//         String? providerId;
//         if (decoded['data']?['order']?['offer_history'] != null &&
//             (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
//             decoded['data']['order']['offer_history'][0]['provider_id'] !=
//                 null) {
//           providerId =
//               decoded['data']['order']['offer_history'][0]['provider_id']['_id']
//                   ?.toString();
//           print("🚫 Provider ID mil gaya: $providerId");
//         } else {
//           print("⚠️ Offer history me provider_id nahi mila!");
//         }
//
//         setState(() {
//           order = {
//             ...decoded['data']['order'],
//             'assignedWorker': decoded['data']['assignedWorker'],
//           };
//           orderProviderId = providerId;
//           _isOrderAccepted = order?['hire_status']?.toLowerCase() == 'accepted';
//           isLoading = false;
//         });
//
//         if (providerId != null) {
//           await _saveHiredProviderId(providerId);
//           await fetchProviderById(providerId);
//         }
//
//         await fetchServiceProvidersListinWorkDetails(
//           widget.categreyId,
//           widget.subcategreyId,
//         );
//       } else {
//         print("❌ API ne dhoka diya: ${response.statusCode} - ${response.body}");
//         setState(() => isLoading = false);
//         _showSnackBar("Order details nahi mile, bhai!");
//         await fetchServiceProvidersListinWorkDetails(
//           widget.categreyId,
//           widget.subcategreyId,
//         );
//       }
//     } catch (e) {
//       print("❗ API call me lafda: $e");
//       setState(() => isLoading = false);
//       _showSnackBar("Error aaya: $e");
//       await fetchServiceProvidersListinWorkDetails(
//         widget.categreyId,
//         widget.subcategreyId,
//       );
//     }
//   }*/
//
//   Future<void> fetchOrderDetail() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print("📋 Token mil gaya: $token");
//
//       if (token.isEmpty) {
//         setState(() => isLoading = false);
//         _showSnackBar("Please login first!");
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse(
//           'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
//         ),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         print("📥 Pura Response: ${response.body}");
//         print("🔍 Order Data: ${decoded['data']['order']}");
//         print("🔍 Assigned Worker Data: ${decoded['data']['assignedWorker']}");
//
//         String? providerId;
//         String? categoryId;
//         String? subcategoryId;
//
//         // Extract providerId, categoryId, and subcategoryId from response
//         if (decoded['data']?['order']?['offer_history'] != null &&
//             (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
//             decoded['data']['order']['offer_history'][0]['provider_id'] !=
//                 null) {
//           providerId =
//               decoded['data']['order']['offer_history'][0]['provider_id']['_id']
//                   ?.toString();
//           categoryId =
//               decoded['data']['order']['offer_history'][0]['provider_id']['category_id']?['_id']
//                   ?.toString();
//           subcategoryId =
//           decoded['data']['order']['offer_history'][0]['provider_id']['subcategory_ids']
//               ?.isNotEmpty ==
//               true
//               ? decoded['data']['order']['offer_history'][0]['provider_id']['subcategory_ids'][0]['_id']
//               ?.toString()
//               : null;
//           print("🚫 Provider ID mil gaya: $providerId");
//           print("📋 Category ID: $categoryId, Subcategory ID: $subcategoryId");
//         } else {
//           print("⚠️ Offer history me provider_id nahi mila!");
//         }
//
//         setState(() {
//           order = {
//             ...decoded['data']['order'],
//             'assignedWorker': decoded['data']['assignedWorker'],
//           };
//           orderProviderId = providerId;
//           _isOrderAccepted = order?['hire_status']?.toLowerCase() == 'accepted';
//           isLoading = false;
//         });
//
//         if (providerId != null) {
//           await _saveHiredProviderId(providerId);
//           await fetchProviderById(providerId);
//         }
//
//         // Check for valid categoryId and subcategoryId before calling fetchServiceProvidersListinWorkDetails
//         if (categoryId != null && subcategoryId != null) {
//           await fetchServiceProvidersListinWorkDetails(
//             categoryId,
//             subcategoryId,
//           );
//         } else {
//           print(
//             "⚠️ Category ID ya Subcategory ID nahi mila, skipping fetchServiceProviders!",
//           );
//           _showSnackBar("category or subcategory ID missing!");
//         }
//       } else {
//         print("❌ API ne dhoka diya: ${response.statusCode} - ${response.body}");
//         setState(() => isLoading = false);
//         _showSnackBar("Order details not found!");
//         // Skip fetchServiceProviders if API fails
//       }
//     } catch (e) {
//       print("api call error: $e");
//       setState(() => isLoading = false);
//       _showSnackBar("Error aaya: $e");
//       // Skip fetchServiceProviders if there's an exception
//     }
//   }
//
//   Future<void> fetchProviderById(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     print("Abhi:- get provider by $id");
//
//     final uri = Uri.parse(
//       'https://api.thebharatworks.com/api/user/getServiceProvider/$id',
//     );
//
//     try {
//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         setState(() {
//           providerDetail = jsonData['user'];
//         });
//         print("✅ Provider ka data mil gaya: ${jsonData['user']}");
//       } else {
//         print("❌ Provider fetch me lafda: ${response.body}");
//       }
//     } catch (e) {
//       print("❗ fetchProviderById me error: $e");
//     }
//   }
//
//   Future<void> _saveHiredProviderId(String hiredId) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> hiredIds = prefs.getStringList('hiredProviderIds') ?? [];
//     if (!hiredIds.contains(hiredId)) {
//       hiredIds.add(hiredId);
//       await prefs.setStringList('hiredProviderIds', hiredIds);
//       print("🚫 Hired Provider ID save kiya: $hiredId");
//       print("🚫 Poora hiredProviderIds list: $hiredIds");
//     }
//   }
//
//   Future<void> _clearHiredProviders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     print("🔐 Token: $token");
//     await prefs.remove('hiredProviderIds');
//     print("🗑️ Hired Provider IDs saaf kiye!");
//
//     if (order == null || order!['_id'] == null) {
//       print("❌ Order ya orderId nahi mila!");
//       _showSnackBar("order data missingi!");
//       return;
//     }
//
//     final orderStatus = order!['hire_status']?.toString().toLowerCase() ?? '';
//     final offerHistory = order!['offer_history'] as List<dynamic>?;
//     print("📋 Order ID: ${order!['_id']}, Status: $orderStatus");
//     print("📋 Offer History: $offerHistory");
//
//     if (orderStatus == 'rejected' || orderStatus == 'cancelled') {
//       print("⚠️ Order already reject or cancel!");
//       if (mounted) {
//         _showSnackBar("Order already rejected");
//         Navigator.pop(context);
//       }
//       return;
//     }
//
//     if (offerHistory != null && offerHistory.isNotEmpty) {
//       final providerStatus =
//       offerHistory[0]['status']?.toString().toLowerCase();
//       print("📩 Provider Status in Offer History: $providerStatus");
//       if (providerStatus == 'rejected' || providerStatus == 'cancelled') {
//         print("⚠️ Provider ne offer pehle se reject kiya hai!");
//         if (mounted) {
//           _showSnackBar("Offer already rejected by provider");
//           Navigator.pop(context);
//         }
//         return;
//       }
//     }
//
//     try {
//       final response = await http.post(
//         Uri.parse(
//           'https://api.thebharatworks.com/api/direct-order/reject-offer',
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({"order_id": order!['_id']}),
//       );
//
//       print("📤 Reject API Response Status: ${response.statusCode}");
//       print("📤 Reject API Response Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['message'] == "Offer rejected successfully" && mounted) {
//           _showSnackBar("Offer reject!");
//           Navigator.pop(context);
//         } else {
//           print("❌ Reject Failed: ${data['message']}");
//           _showSnackBar(" Not Reject: ${data['message']}");
//         }
//       } else {
//         final err = json.decode(response.body);
//         print("❌ API Error: ${response.statusCode} - ${err['message']}");
//         if (err['message'] == "Invalid rejection or already handled" &&
//             mounted) {
//           _showSnackBar("Order already rejected or invalid!");
//           Navigator.pop(context);
//         } else {
//           _showSnackBar("Error ${response.statusCode}: ${err['message']}");
//         }
//       }
//
//       if (order!['service_payment'] != null &&
//           order!['service_payment']['payment_history']?.isNotEmpty == true) {
//         try {
//           final refundResponse = await http.post(
//             Uri.parse(
//               'https://api.razorpay.com/v1/payments/${order!['service_payment']['payment_history'][0]['payment_id']}/refund',
//             ),
//             headers: {
//               'Authorization':
//               'Basic ${base64Encode(utf8.encode('YOUR_RAZORPAY_KEY_ID:YOUR_RAZORPAY_KEY_SECRET'))}',
//             },
//           );
//           print("📤 Refund API response: ${refundResponse.body}");
//         } catch (e) {
//           print("❗ Refund me lafda: $e");
//         }
//       }
//     } catch (e) {
//       print("❗ Reject Offer me error: $e");
//       _showSnackBar("Error: $e");
//     }
//   }
//
//   Future<void> fetchServiceProvidersListinWorkDetails(
//       String? categoryId,
//       String? subCategoryId,
//       ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
//     print("🚫 Hired Provider IDs before fetch: $hiredProviderIds");
//
//     if (token == null) {
//       _showSnackBar("Please login!");
//       return;
//     }
//
//     if (categoryId == null || subCategoryId == null) {
//       print("⚠️ categoryId ya subCategoryId null hai, API call skip!");
//       return;
//     }
//
//     final uri = Uri.parse(
//       '${AppConstants.baseUrl}${ApiEndpoint.serviceDirectViewScreen}',
//     );
//
//     try {
//       final response = await http.post(
//         uri,
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: json.encode({
//           "category_id": categoryId,
//           "subcategory_ids": [subCategoryId],
//         }),
//       );
//
//       print("📦 fetchServiceProviders Status: ${response.statusCode}");
//       print("📦 fetchServiceProviders Body: ${response.body}");
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data["status"] == true && data["data"] != null) {
//           setState(() {
//             providerslist =
//                 (data["data"] as List)
//                     .map((json) {
//                   final provider = ServiceProviderModel.fromJson(json);
//                   bool isExcluded =
//                       hiredProviderIds.contains(provider.id) ||
//                           provider.id == orderProviderId;
//                   print(
//                     "🔍 Provider ID: ${provider.id}, Name: ${provider.fullName}, Excluded: $isExcluded",
//                   );
//                   return provider;
//                 })
//                     .where((provider) {
//                   bool isValid =
//                       provider.id != null &&
//                           !hiredProviderIds.contains(provider.id) &&
//                           provider.id != orderProviderId;
//                   if (!isValid) {
//                     print("🚫 Filtered out provider: ${provider.id}");
//                   }
//                   return isValid;
//                 })
//                     .toList();
//             print("✅ Providers loaded: ${providerslist.length}");
//             print(
//               "✅ Providers IDs: ${providerslist.map((p) => p?.id).toList()}",
//             );
//           });
//         } else {
//           _showSnackBar("No provider found!");
//         }
//       } else {
//         final err = json.decode(response.body);
//         _showSnackBar("Error ${response.statusCode}: ${err['message']}");
//       }
//     } catch (e) {
//       print("❗ Exception: $e");
//       _showSnackBar("Error: $e");
//     }
//   }
//
//   Future<void> markOrderAsComplete() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString("token");
//
//       print("🔐 Token: $token");
//       if (token == null) {
//         _showSnackBar("Please login!");
//         return;
//       }
//
//       var headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//
//       var body = jsonEncode({"order_id": widget.id});
//       print("📤 Request Body: $body");
//
//       var response = await http.post(
//         Uri.parse(
//           "https://api.thebharatworks.com/api/direct-order/completeOrderProvider",
//         ),
//         headers: headers,
//         body: body,
//       );
//
//       print("📥 Response Status: ${response.statusCode}");
//       print("📥 Response Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         _showSnackBar("Mark as complete!");
//         Navigator.pop(context);
//       } else {
//         var data = jsonDecode(response.body);
//         _showSnackBar("Complete mark not: ${data['message']}");
//       }
//     } catch (e) {
//       print("❗ API call me error: $e");
//       _showSnackBar("Error: $e");
//     }
//   }
//
//   void _showSnackBar(String message) {
//     if (mounted && _scaffoldMessenger != null) {
//       _scaffoldMessenger!.showSnackBar(SnackBar(content: Text(message)));
//     }
//   }
//
//   Future<void> acceptOffer(String orderId) async {
//     if (!mounted || _isProcessing) return;
//
//     setState(() => _isProcessing = true);
//     print("Abhi:- getOderId in sent offer : ${orderId}");
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       if (token.isEmpty) {
//         _showSnackBar("Please login!");
//         print("❌ Token nahi mila, login karo!");
//         setState(() => _isProcessing = false);
//         return;
//       }
//
//       if (_isOrderAccepted) {
//         print("✅ Order pehle se accept hai!");
//         setState(() => _isProcessing = false);
//         return;
//       }
//
//       print("📤 OrderId: $orderId ke liye accept request bhej raha hoon");
//       final response = await http.post(
//         Uri.parse(
//           'https://api.thebharatworks.com/api/direct-order/accept-offer',
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({"order_id": orderId}),
//       );
//
//       print("📥 Response aaya: ${response.statusCode}, Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['message'] == "Offer accepted by provider") {
//           setState(() {
//             _isOrderAccepted = true;
//             order!['hire_status'] = 'accepted';
//           });
//           _showSnackBar("Offer accepted!");
//         } else {
//           _showSnackBar(" No accept Offer ${data['message']}");
//           print("❌ Offer accept fail: ${data['message']}");
//         }
//       } else {
//         final err = json.decode(response.body);
//         _showSnackBar("Error ${response.statusCode}: ${err['message']}");
//         print(
//           "❌ API ka dimaag kharab: ${response.statusCode} - ${err['message']}",
//         );
//         if (err['message'] == "Invalid acceptance or already handled") {
//           setState(() {
//             _isOrderAccepted = true;
//             order!['hire_status'] = 'accepted';
//           });
//         }
//       }
//     } catch (e) {
//       print("❗ AcceptOffer me lafda: $e");
//       _showSnackBar("Error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(
//       "📋 DirectViewScreen categreyId: ${widget.categreyId}, subCategreyId: ${widget.subcategreyId}",
//     );
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body:
//       isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : order == null
//           ? const Center(child: Text("No data found!"))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Padding(
//                     padding: EdgeInsets.only(left: 6.0),
//                     child: Icon(
//                       Icons.arrow_back_outlined,
//                       size: 20,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 80),
//                 Text(
//                   _isOrderAccepted ? 'Worker Details' : 'Work Details',
//                   style: GoogleFonts.roboto(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             order!['image_url'] != null
//                 ? Image.network(
//               order!['image_url'] is List
//                   ? 'https://api.thebharatworks.com${order!['image_url'][0]}'
//                   : 'https://api.thebharatworks.com${order!['image_url']}',
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 print("📸 Image load me lafda: $error");
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
//                   "Posted: ${order!['createdAt']?.toString().substring(0, 10) ?? 'N/A'}",
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
//               "Completion: ${order!['deadline']?.toString().substring(0, 10) ?? 'N/A'}",
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
//               order!['description'] ?? 'No description available.',
//               style: GoogleFonts.roboto(fontSize: 14),
//             ),
//             const SizedBox(height: 20),
//
//             //        status maintain by Abhishek
//
//             order!['hire_status'] == 'cancelled'
//                 ? Center(
//               child: Container(
//                 height: 35,
//                 width: 300,
//                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(Icons.warning_amber, color: Colors.red),
//                     Text("The order is Cancelled",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
//                   ],
//                 ),
//               ),
//             )
//                 : SizedBox(),
//             order!['hire_status'] == 'completed'
//                 ? Center(
//               child: Container(
//                 height: 35,
//                 width: 300,
//                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.green)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(Icons.check_circle_outline, color: Colors.green),
//                     Text("  The order has been completed",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600),),
//                   ],
//                 ),
//               ),
//             )
//                 : SizedBox(),
//             order!['hire_status'] == 'rejected'
//                 ? Center(
//               child: Container(
//                 height: 35,
//                 width: 300,
//                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(Icons.block, color: Colors.grey),
//                     Text("The order is rejected"),
//                   ],
//                 ),
//               ),
//             )
//                 : SizedBox(),
//
//
//             order?['hire_status']?.toLowerCase() == 'pending' ?
//               GestureDetector(
//                 onTap:
//                 _isProcessing || _isOrderAccepted
//                     ? null
//                     : () {
//                   if (order == null || order!['_id'] == null) {
//                     print("❌ Oder not found!");
//                     _showSnackBar(
//                       "Oder Data not found!",
//                     );
//                     return;
//                   }
//                   String orderId = order!['_id'].toString();
//                   print(
//                     "✅ OrderId $orderId ke liye Accept dabaya!",
//                   );
//                   acceptOffer(orderId);
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color:
//                     _isOrderAccepted
//                         ? Colors.grey.shade400
//                         : Colors.green.shade700,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child:
//                     _isProcessing
//                         ? const CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     )
//                         : Text(
//                       "Accept",
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ) : SizedBox(),
//               // if (_isOrderAccepted) ...[
//               //   const SizedBox(height: 8),
//               //   Text(
//               //     "Oder is allredy accepted!",
//               //     style: GoogleFonts.roboto(
//               //       fontSize: 14,
//               //       color: Colors.grey,
//               //       fontWeight: FontWeight.w500,
//               //     ),
//               //     textAlign: TextAlign.center,
//               //   ),
//               // ],
//             order?['hire_status']?.toLowerCase() == 'pending' ? SizedBox(height: 10,) : SizedBox(),
//             order?['hire_status']?.toLowerCase() == 'pending' ?
//                 Container(
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEE2121),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: TextButton(
//                     onPressed: () async {
//                       await _clearHiredProviders();
//                     },
//                     child: Text(
//                       "Reject",
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ) : SizedBox(),
//
//
//             /*if (!_isOrderAccepted) ...[
//               GestureDetector(
//                 onTap:
//                 _isProcessing || _isOrderAccepted
//                     ? null
//                     : () {
//                   if (order == null || order!['_id'] == null) {
//                     print("❌ Oder not found!");
//                     _showSnackBar(
//                       "Oder Data not found!",
//                     );
//                     return;
//                   }
//                   String orderId = order!['_id'].toString();
//                   print(
//                     "✅ OrderId $orderId ke liye Accept dabaya!",
//                   );
//                   acceptOffer(orderId);
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color:
//                     _isOrderAccepted
//                         ? Colors.grey.shade400
//                         : Colors.green.shade700,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child:
//                     _isProcessing
//                         ? const CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     )
//                         : Text(
//                       "Accept",
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               if (_isOrderAccepted) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   "Oder is allredy accepted!",
//                   style: GoogleFonts.roboto(
//                     fontSize: 14,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//               if (order != null &&
//                   order!['hire_status']?.toString().toLowerCase() !=
//                       'pending') ...[
//                 const SizedBox(height: 10),
//                 Container(
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEE2121),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: TextButton(
//                     onPressed: () async {
//                       await _clearHiredProviders();
//                     },
//                     child: Text(
//                       "Reject",
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ],*/
//             if (_isOrderAccepted) ...[
//               Container(
//                 height: 120,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 5,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 padding: EdgeInsets.all(10),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(70),
//                       child: () {
//                         final profilePic =
//                         order != null && order!['user_id'] != null
//                             ? order!['user_id']['profile_pic']
//                             : null;
//                         print("📸 Profile Pic URL: $profilePic");
//                         return profilePic != null
//                             ? Image.network(
//                           'https://api.thebharatworks.com$profilePic',
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                           errorBuilder: (
//                               context,
//                               error,
//                               stackTrace,
//                               ) {
//                             print(
//                               "📸 Profile pic load me lafda: $error",
//                             );
//                             return Container(
//                               width: 80,
//                               height: 80,
//                               color: Colors.grey[300],
//                               child: Center(
//                                 child: Text(
//                                   "No Pic",
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                             : Container(
//                           width: 80,
//                           height: 80,
//                           color: Colors.grey[300],
//                           child: Center(
//                             child: Text(
//                               "No Pic",
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         );
//                       }(),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: () {
//                                   final fullName =
//                                   order != null &&
//                                       order!['user_id'] != null
//                                       ? order!['user_id']['full_name'] ??
//                                       'Unknown Bhai'
//                                       : 'Unknown Bhai';
//                                   print("📛 User Full Name: $fullName");
//                                   return Text(
//                                     fullName,
//                                     style: GoogleFonts.roboto(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   );
//                                 }(),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Text(
//                                 "Project Fees – ₹${order != null && order!['platform_fee'] != null ? order!['platform_fee'] : 'N/A'}/-",
//                                 style: GoogleFonts.roboto(
//                                   color: Colors.black,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 6),
//                     Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 14,
//                           backgroundColor: Colors.grey[300],
//                           child: Icon(
//                             Icons.call,
//                             color: Colors.green,
//                             size: 18,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         CircleAvatar(
//                           radius: 14,
//                           backgroundColor: Colors.grey[300],
//                           child: Icon(
//                             Icons.message,
//                             color: Colors.green,
//                             size: 18,
//                           ),
//                         ),
//                         SizedBox(height: 6),
//                         GestureDetector(
//                           onTap: () {
//                             final userId =
//                             order != null &&
//                                 order!['user_id'] != null
//                                 ? order!['user_id']['_id'] ??
//                                 'Unknown Bhai'
//                                 : 'Unknown Bhai';
//                             print(
//                               "👤 Navigating to Profile with User ID: $userId",
//                             );
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (context) => ViewUserProfileScreen(
//                                   userId: userId,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Text(
//                             "View Profile",
//                             style: GoogleFonts.roboto(
//                               color: Colors.green,
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               // Assigned Person container will only show if order is accepted AND assignedWorker is not null
//               if (_isOrderAccepted && order!['assignedWorker'] != null)
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(color: Colors.white),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Assigned Person",
//                         style: GoogleFonts.roboto(
//                           color: Colors.black,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 50,
//                             backgroundImage:
//                             order != null &&
//                                 order!['assignedWorker'] !=
//                                     null &&
//                                 order!['assignedWorker']['image'] !=
//                                     null
//                                 ? NetworkImage(
//                               order!['assignedWorker']['image'],
//                             )
//                                 : AssetImage(
//                               'assets/profile_pic.jpg',
//                             ),
//                             onBackgroundImageError: (
//                                 exception,
//                                 stackTrace,
//                                 ) {
//                               print(
//                                 "📸 Assigned Worker Image Error: $exception",
//                               );
//                             },
//                           ),
//                           SizedBox(width: 30),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   order != null &&
//                                       order!['assignedWorker'] !=
//                                           null
//                                       ? order!['assignedWorker']['name'] ??
//                                       'Unknown Worker'
//                                       : 'Unknown Worker',
//                                   style: GoogleFonts.roboto(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   order != null &&
//                                       order!['assignedWorker'] !=
//                                           null
//                                       ? order!['assignedWorker']['address'] ??
//                                       'No Address'
//                                       : 'No Address',
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 SizedBox(height: 5),
//                                 GestureDetector(
//                                   onTap: () {
//                                     if (order != null &&
//                                         order!['assignedWorker'] !=
//                                             null &&
//                                         order!['assignedWorker']['_id'] !=
//                                             null) {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder:
//                                               (
//                                               context,
//                                               ) => WorkerListViewProfileScreen(
//                                             workerId:
//                                             order!['assignedWorker']['_id'],
//                                           ),
//                                         ),
//                                       );
//                                     } else {
//                                       print(
//                                         "❌ Assigned worker ID not found",
//                                       );
//                                       _showSnackBar(
//                                         "Worker data missing!",
//                                       );
//                                     }
//                                   },
//                                   child: Container(
//                                     height: 30,
//                                     width: 100,
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.shade700,
//                                       borderRadius:
//                                       BorderRadius.circular(10),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         'View profile',
//                                         style: GoogleFonts.roboto(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//               SizedBox(height: 20),
//               if (_isOrderAccepted && order!['assignedWorker'] == null)
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (_) => ServiceWorkerListScreen(
//                           orderId: widget.id,
//                         ),
//                       ),
//                     ).then((_) {
//                       // Refresh order details after returning from ServiceWorkerListScreen
//                       fetchOrderDetail();
//                     });
//                   },
//                   child: Container(
//                     height: 50,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.green.shade700),
//                     ),
//                     child: Center(
//                       child: Text(
//                         'Assign to another person',
//                         style: GoogleFonts.roboto(
//                           fontSize: 14,
//                           color: Colors.green,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 20),
//               Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     color: Colors.white,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           'Payment',
//                           style: GoogleFonts.roboto(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const Divider(thickness: 0.8),
//                       const SizedBox(height: 10),
//                       if (order!['service_payment'] != null &&
//                           order!['service_payment']['payment_history'] !=
//                               null &&
//                           order!['service_payment']['payment_history']
//                               .isNotEmpty)
//                         ...List.generate(
//                           order!['service_payment']['payment_history']
//                               .length,
//                               (index) {
//                             final item =
//                             order!['service_payment']['payment_history'][index];
//                             return Padding(
//                               padding: const EdgeInsets.only(
//                                 bottom: 10,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Flexible(
//                                     flex: 2,
//                                     child: Text(
//                                       "${index + 1}. ${item['description'] ?? 'No Description'}",
//                                       style: GoogleFonts.roboto(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 1,
//                                     ),
//                                   ),
//                                   Flexible(
//                                     flex: 3,
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Flexible(
//                                           child: Text(
//                                             "${item['status'] == 'paid' ? 'Paid' : 'Pending'}",
//                                             style: GoogleFonts.roboto(
//                                               color:
//                                               item['status'] ==
//                                                   'paid'
//                                                   ? Colors.green
//                                                   : Colors.red,
//                                               fontSize: 12,
//                                               fontWeight:
//                                               FontWeight.w500,
//                                             ),
//                                             overflow:
//                                             TextOverflow.ellipsis,
//                                             maxLines: 1,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Flexible(
//                                           child: Text(
//                                             "₹${item['amount']}",
//                                             style: GoogleFonts.roboto(
//                                               fontWeight:
//                                               FontWeight.w500,
//                                             ),
//                                             overflow:
//                                             TextOverflow.ellipsis,
//                                             maxLines: 1,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         )
//                       else
//                         Text(
//                           'No payment history found.',
//                           style: GoogleFonts.roboto(fontSize: 14),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.only(top: 40, bottom: 16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       color: Colors.yellow.shade100,
//                     ),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 10),
//                         Text(
//                           'Warning Message',
//                           style: GoogleFonts.roboto(
//                             fontSize: 14,
//                             color: Colors.red,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Lorem ipsum dolor sit amet consectetur.',
//                           style: GoogleFonts.roboto(
//                             fontSize: 14,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     top: -30,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: Colors.white,
//                         ),
//                         child: Image.asset(
//                           'assets/images/warning.png',
//                           height: 70,
//                           width: 70,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: () async {
//                   SharedPreferences prefs =
//                   await SharedPreferences.getInstance();
//                   String? token = prefs.getString("token");
//
//                   if (token == null || token.isEmpty) {
//                     _showSnackBar("Please login!");
//                     return;
//                   }
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => ServiceDisputeScreen(
//                         orderId: widget.id,
//                         flowType: "direct",
//                       ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     color: Colors.red,
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Cancel Task and create dispute',
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

/*import 'dart:convert';
import 'package:developer/directHiring/views/ServiceProvider/view_user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/userModel/subCategoriesModel.dart';
import 'ServiceDisputeScreen.dart';
import 'ServiceWorkerListScreen.dart';
// import 'ViewUserProfileScreen.dart';
import 'WorkerListViewProfileScreen.dart';

class ServiceDirectViewScreen extends StatefulWidget {
  final String id;
  final String? categreyId;
  final String? subcategreyId;
  const ServiceDirectViewScreen({
    super.key,
    required this.id,
    this.categreyId,
    this.subcategreyId,
  });

  @override
  State<ServiceDirectViewScreen> createState() =>
      _ServiceDirectViewScreenState();
}

class _ServiceDirectViewScreenState extends State<ServiceDirectViewScreen> {
  bool isLoading = true;
  Map<String, dynamic>? order;
  Map<String, dynamic>? providerDetail;
  List<ServiceProviderModel> providerslist = [];
  String? orderProviderId;
  ScaffoldMessengerState? _scaffoldMessenger;
  bool _isProcessing = false;
  bool _isOrderAccepted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    fetchOrderDetail();
  }

  Future<void> fetchOrderDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print("📋 Token mil gaya: $token");

      if (token.isEmpty) {
        setState(() => isLoading = false);
        _showSnackBar("Please login first!");
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("📥 Pura Response: ${response.body}");
        print("🔍 Order Data: ${decoded['data']['order']}");
        print("🔍 Assigned Worker Data: ${decoded['data']['assignedWorker']}");

        String? providerId;
        String? categoryId;
        String? subcategoryId;

        // Extract providerId, categoryId, and subcategoryId from response
        if (decoded['data']?['order']?['offer_history'] != null &&
            (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
            decoded['data']['order']['offer_history'][0]['provider_id'] !=
                null) {
          providerId =
              decoded['data']['order']['offer_history'][0]['provider_id']['_id']
                  ?.toString();
          categoryId =
              decoded['data']['order']['offer_history'][0]['provider_id']['category_id']?['_id']
                  ?.toString();
          subcategoryId =
          decoded['data']['order']['offer_history'][0]['provider_id']['subcategory_ids']
              ?.isNotEmpty ==
              true
              ? decoded['data']['order']['offer_history'][0]['provider_id']['subcategory_ids'][0]['_id']
              ?.toString()
              : null;
          print("🚫 Provider ID mil gaya: $providerId");
          print("📋 Category ID: $categoryId, Subcategory ID: $subcategoryId");
        } else {
          print("⚠️ Offer history me provider_id nahi mila!");
        }

        setState(() {
          order = {
            ...decoded['data']['order'],
            'assignedWorker': decoded['data']['assignedWorker'],
          };
          orderProviderId = providerId;
          _isOrderAccepted = order?['hire_status']?.toLowerCase() == 'accepted';
          isLoading = false;
        });

        if (providerId != null) {
          await _saveHiredProviderId(providerId);
          await fetchProviderById(providerId);
        }

        // Check for valid categoryId and subcategoryId before calling fetchServiceProvidersListinWorkDetails
        if (categoryId != null && subcategoryId != null) {
          await fetchServiceProvidersListinWorkDetails(
            categoryId,
            subcategoryId,
          );
        } else {
          print(
            "⚠️ Category ID ya Subcategory ID nahi mila, skipping fetchServiceProviders!",
          );
          _showSnackBar("category or subcategory ID missing!");
        }
      } else {
        print("❌ API ne dhoka diya: ${response.statusCode} - ${response.body}");
        setState(() => isLoading = false);
        _showSnackBar("Order details not found!");
        // Skip fetchServiceProviders if API fails
      }
    } catch (e) {
      print("api call error: $e");
      setState(() => isLoading = false);
      _showSnackBar("Error aaya: $e");
      // Skip fetchServiceProviders if there's an exception
    }
  }

  Future<void> fetchProviderById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- get provider by $id");

    final uri = Uri.parse(
      'https://api.thebharatworks.com/api/user/getServiceProvider/$id',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          providerDetail = jsonData['user'];
        });
        print("✅ Provider ka data mil gaya: ${jsonData['user']}");
      } else {
        print("❌ Provider fetch me lafda: ${response.body}");
      }
    } catch (e) {
      print("❗ fetchProviderById me error: $e");
    }
  }

  Future<void> _saveHiredProviderId(String hiredId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiredIds = prefs.getStringList('hiredProviderIds') ?? [];
    if (!hiredIds.contains(hiredId)) {
      hiredIds.add(hiredId);
      await prefs.setStringList('hiredProviderIds', hiredIds);
      print("🚫 Hired Provider ID save kiya: $hiredId");
      print("🚫 Poora hiredProviderIds list: $hiredIds");
    }
  }

  Future<void> _clearHiredProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("🔐 Token: $token");
    await prefs.remove('hiredProviderIds');
    print("🗑️ Hired Provider IDs saaf kiye!");

    if (order == null || order!['_id'] == null) {
      print("❌ Order ya orderId nahi mila!");
      _showSnackBar("order data missingi!");
      return;
    }

    final orderStatus = order!['hire_status']?.toString().toLowerCase() ?? '';
    final offerHistory = order!['offer_history'] as List<dynamic>?;
    print("📋 Order ID: ${order!['_id']}, Status: $orderStatus");
    print("📋 Offer History: $offerHistory");

    if (orderStatus == 'rejected' || orderStatus == 'cancelled') {
      print("⚠️ Order already reject or cancel!");
      if (mounted) {
        _showSnackBar("Order already rejected");
        Navigator.pop(context);
      }
      return;
    }

    if (offerHistory != null && offerHistory.isNotEmpty) {
      final providerStatus =
      offerHistory[0]['status']?.toString().toLowerCase();
      print("📩 Provider Status in Offer History: $providerStatus");
      if (providerStatus == 'rejected' || providerStatus == 'cancelled') {
        print("⚠️ Provider ne offer pehle se reject kiya hai!");
        if (mounted) {
          _showSnackBar("Offer already rejected by provider");
          Navigator.pop(context);
        }
        return;
      }
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.thebharatworks.com/api/direct-order/reject-offer',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"order_id": order!['_id']}),
      );

      print("📤 Reject API Response Status: ${response.statusCode}");
      print("📤 Reject API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == "Offer rejected successfully" && mounted) {
          _showSnackBar("Offer reject!");
          Navigator.pop(context);
        } else {
          print("❌ Reject Failed: ${data['message']}");
          _showSnackBar(" Not Reject: ${data['message']}");
        }
      } else {
        final err = json.decode(response.body);
        print("❌ API Error: ${response.statusCode} - ${err['message']}");
        if (err['message'] == "Invalid rejection or already handled" &&
            mounted) {
          _showSnackBar("Order already rejected or invalid!");
          Navigator.pop(context);
        } else {
          _showSnackBar("Error ${response.statusCode}: ${err['message']}");
        }
      }

      if (order!['service_payment'] != null &&
          order!['service_payment']['payment_history']?.isNotEmpty == true) {
        try {
          final refundResponse = await http.post(
            Uri.parse(
              'https://api.razorpay.com/v1/payments/${order!['service_payment']['payment_history'][0]['payment_id']}/refund',
            ),
            headers: {
              'Authorization':
              'Basic ${base64Encode(utf8.encode('YOUR_RAZORPAY_KEY_ID:YOUR_RAZORPAY_KEY_SECRET'))}',
            },
          );
          print("📤 Refund API response: ${refundResponse.body}");
        } catch (e) {
          print("❗ Refund me lafda: $e");
        }
      }
    } catch (e) {
      print("❗ Reject Offer me error: $e");
      _showSnackBar("Error: $e");
    }
  }

  Future<void> fetchServiceProvidersListinWorkDetails(
      String? categoryId,
      String? subCategoryId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
    print("🚫 Hired Provider IDs before fetch: $hiredProviderIds");

    if (token == null) {
      _showSnackBar("Please login!");
      return;
    }

    if (categoryId == null || subCategoryId == null) {
      print("⚠️ categoryId ya subCategoryId null hai, API call skip!");
      return;
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoint.serviceDirectViewScreen}',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "category_id": categoryId,
          "subcategory_ids": [subCategoryId],
        }),
      );

      print("📦 fetchServiceProviders Status: ${response.statusCode}");
      print("📦 fetchServiceProviders Body: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == true && data["data"] != null) {
          setState(() {
            providerslist =
                (data["data"] as List)
                    .map((json) {
                  final provider = ServiceProviderModel.fromJson(json);
                  bool isExcluded =
                      hiredProviderIds.contains(provider.id) ||
                          provider.id == orderProviderId;
                  print(
                    "🔍 Provider ID: ${provider.id}, Name: ${provider.fullName}, Excluded: $isExcluded",
                  );
                  return provider;
                })
                    .where((provider) {
                  bool isValid =
                      provider.id != null &&
                          !hiredProviderIds.contains(provider.id) &&
                          provider.id != orderProviderId;
                  if (!isValid) {
                    print("🚫 Filtered out provider: ${provider.id}");
                  }
                  return isValid;
                })
                    .toList();
            print("✅ Providers loaded: ${providerslist.length}");
            print(
              "✅ Providers IDs: ${providerslist.map((p) => p?.id).toList()}",
            );
          });
        } else {
          _showSnackBar("No provider found!");
        }
      } else {
        final err = json.decode(response.body);
        _showSnackBar("Error ${response.statusCode}: ${err['message']}");
      }
    } catch (e) {
      print("❗ Exception: $e");
      _showSnackBar("Error: $e");
    }
  }

  Future<void> markOrderAsComplete() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      print("🔐 Token: $token");
      if (token == null) {
        _showSnackBar("Please login!");
        return;
      }

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var body = jsonEncode({"order_id": widget.id});
      print("📤 Request Body: $body");

      var response = await http.post(
        Uri.parse(
          "https://api.thebharatworks.com/api/direct-order/completeOrderProvider",
        ),
        headers: headers,
        body: body,
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        _showSnackBar("Mark as complete!");
        Navigator.pop(context);
      } else {
        var data = jsonDecode(response.body);
        _showSnackBar("Complete mark not: ${data['message']}");
      }
    } catch (e) {
      print("❗ API call me error: $e");
      _showSnackBar("Error: $e");
    }
  }

  void _showSnackBar(String message) {
    if (mounted && _scaffoldMessenger != null) {
      _scaffoldMessenger!.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> acceptOffer(String orderId) async {
    if (!mounted || _isProcessing) return;

    setState(() => _isProcessing = true);
    print("Abhi:- getOderId in sent offer : ${orderId}");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        _showSnackBar("Please login!");
        print("❌ Token nahi mila, login karo!");
        setState(() => _isProcessing = false);
        return;
      }

      if (_isOrderAccepted) {
        print("✅ Order pehle se accept hai!");
        setState(() => _isProcessing = false);
        return;
      }

      print("📤 OrderId: $orderId ke liye accept request bhej raha hoon");
      final response = await http.post(
        Uri.parse(
          'https://api.thebharatworks.com/api/direct-order/accept-offer',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"order_id": orderId}),
      );

      print("📥 Response aaya: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == "Offer accepted by provider") {
          setState(() {
            _isOrderAccepted = true;
            order!['hire_status'] = 'accepted';
          });
          _showSnackBar("Offer accepted!");
        } else {
          _showSnackBar(" No accept Offer ${data['message']}");
          print("❌ Offer accept fail: ${data['message']}");
        }
      } else {
        final err = json.decode(response.body);
        _showSnackBar("Error ${response.statusCode}: ${err['message']}");
        print(
          "❌ API ka dimaag kharab: ${response.statusCode} - ${err['message']}",
        );
        if (err['message'] == "Invalid acceptance or already handled") {
          setState(() {
            _isOrderAccepted = true;
            order!['hire_status'] = 'accepted';
          });
        }
      }
    } catch (e) {
      print("❗ AcceptOffer me lafda: $e");
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      "📋 DirectViewScreen categreyId: ${widget.categreyId}, subCategreyId: ${widget.subcategreyId}",
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? const Center(child: Text("No data found!"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Icon(
                      Icons.arrow_back_outlined,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 80),
                Text(
                  _isOrderAccepted ? 'Worker Details' : 'Work Details',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            order!['image_url'] != null
                ? Image.network(
              order!['image_url'] is List
                  ? 'https://api.thebharatworks.com${order!['image_url'][0]}'
                  : 'https://api.thebharatworks.com${order!['image_url']}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("📸 Image load me lafda: $error");
                return Image.asset(
                  'assets/images/task.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              'assets/images/task.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    order!['title'] ?? 'Work Title',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "Posted: ${order!['createdAt']?.toString().substring(0, 10) ?? 'N/A'}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                order!['address'] ?? '',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Completion: ${order!['deadline']?.toString().substring(0, 10) ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Work Title",
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              order!['description'] ?? 'No description available.',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            const SizedBox(height: 20),

            //        status maintain by Abhishek

            order!['hire_status'] == 'cancelled'
                ? Center(
              child: Container(
                height: 35,
                width: 300,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red),
                    Text("The order is Cancelled",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
                  ],
                ),
              ),
            )
                : SizedBox(),
            order!['hire_status'] == 'completed'
                ? Center(
              child: Container(
                height: 35,
                width: 300,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.green)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    Text("  The order has been completed",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600),),
                  ],
                ),
              ),
            )
                : SizedBox(),
            order!['hire_status'] == 'rejected'
                ? Center(
              child: Container(
                height: 35,
                width: 300,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: Colors.grey),
                    Text("The order is rejected"),
                  ],
                ),
              ),
            )
                : SizedBox(),


            order?['hire_status']?.toLowerCase() == 'pending' ?
            GestureDetector(
              onTap:
              _isProcessing || _isOrderAccepted
                  ? null
                  : () {
                if (order == null || order!['_id'] == null) {
                  print("❌ Oder not found!");
                  _showSnackBar(
                    "Oder Data not found!",
                  );
                  return;
                }
                String orderId = order!['_id'].toString();
                print(
                  "✅ OrderId $orderId ke liye Accept dabaya!",
                );
                acceptOffer(orderId);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color:
                  _isOrderAccepted
                      ? Colors.grey.shade400
                      : Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child:
                  _isProcessing
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : Text(
                    "Accept",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ) : SizedBox(),
            // if (_isOrderAccepted) ...[
            //   const SizedBox(height: 8),
            //   Text(
            //     "Oder is allredy accepted!",
            //     style: GoogleFonts.roboto(
            //       fontSize: 14,
            //       color: Colors.grey,
            //       fontWeight: FontWeight.w500,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ],
            order?['hire_status']?.toLowerCase() == 'pending' ? SizedBox(height: 10,) : SizedBox(),
            order?['hire_status']?.toLowerCase() == 'pending' ?
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEE2121),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () async {
                  await _clearHiredProviders();
                },
                child: Text(
                  "Reject",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ) : SizedBox(),
            if (_isOrderAccepted) ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: () {
                        final profilePic =
                        order != null && order!['user_id'] != null
                            ? order!['user_id']['profile_pic']
                            : null;
                        print("📸 Profile Pic URL: $profilePic");
                        return profilePic != null
                            ? Image.network(
                          'https://api.thebharatworks.com$profilePic',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (
                              context,
                              error,
                              stackTrace,
                              ) {
                            print(
                              "📸 Profile pic load me lafda: $error",
                            );
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: Center(
                                child: Text(
                                  "No Pic",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                            : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              "No Pic",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }(),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: () {
                                  final fullName =
                                  order != null &&
                                      order!['user_id'] != null
                                      ? order!['user_id']['full_name'] ??
                                      'Unknown Bhai'
                                      : 'Unknown Bhai';
                                  print("📛 User Full Name: $fullName");
                                  return Text(
                                    fullName,
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }(),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "Project Fees – ₹${order != null && order!['platform_fee'] != null ? order!['platform_fee'] : 'N/A'}/-",
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.call,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.message,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            final userId =
                            order != null &&
                                order!['user_id'] != null
                                ? order!['user_id']['_id'] ??
                                'Unknown Bhai'
                                : 'Unknown Bhai';
                            print(
                              "👤 Navigating to Profile with User ID: $userId",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ViewUserProfileScreen(
                                  userId: userId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "View Profile",
                            style: GoogleFonts.roboto(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Assigned Person container will only show if order is accepted AND assignedWorker is not null
              if (_isOrderAccepted && order!['assignedWorker'] != null)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assigned Person",
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                            order != null &&
                                order!['assignedWorker'] !=
                                    null &&
                                order!['assignedWorker']['image'] !=
                                    null
                                ? NetworkImage(
                              order!['assignedWorker']['image'],
                            )
                                : AssetImage(
                              'assets/profile_pic.jpg',
                            ),
                            onBackgroundImageError: (
                                exception,
                                stackTrace,
                                ) {
                              print(
                                "📸 Assigned Worker Image Error: $exception",
                              );
                            },
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order != null &&
                                      order!['assignedWorker'] !=
                                          null
                                      ? order!['assignedWorker']['name'] ??
                                      'Unknown Worker'
                                      : 'Unknown Worker',
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order != null &&
                                      order!['assignedWorker'] !=
                                          null
                                      ? order!['assignedWorker']['address'] ??
                                      'No Address'
                                      : 'No Address',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () {
                                    if (order != null &&
                                        order!['assignedWorker'] !=
                                            null &&
                                        order!['assignedWorker']['_id'] !=
                                            null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                              context,
                                              ) => WorkerListViewProfileScreen(
                                            workerId:
                                            order!['assignedWorker']['_id'],
                                          ),
                                        ),
                                      );
                                    } else {
                                      print(
                                        "❌ Assigned worker ID not found",
                                      );
                                      _showSnackBar(
                                        "Worker data missing!",
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade700,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'View profile',
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              SizedBox(height: 20),
              if (_isOrderAccepted && order!['assignedWorker'] == null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ServiceWorkerListScreen(
                          orderId: widget.id,
                        ),
                      ),
                    ).then((_) {
                      // Refresh order details after returning from ServiceWorkerListScreen
                      fetchOrderDetail();
                    });
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
              const SizedBox(height: 20),
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
                          'Payment',
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
                      if (order!['service_payment'] != null &&
                          order!['service_payment']['payment_history'] !=
                              null &&
                          order!['service_payment']['payment_history']
                              .isNotEmpty)
                        ...List.generate(
                          order!['service_payment']['payment_history']
                              .length,
                              (index) {
                            final item =
                            order!['service_payment']['payment_history'][index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      "${index + 1}. ${item['description'] ?? 'No Description'}",
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${item['status'] == 'paid' ? 'Paid' : 'Pending'}",
                                            style: GoogleFonts.roboto(
                                              color:
                                              item['status'] ==
                                                  'paid'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                            overflow:
                                            TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            "₹${item['amount']}",
                                            style: GoogleFonts.roboto(
                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                            overflow:
                                            TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      else
                        Text(
                          'No payment history found.',
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  String? token = prefs.getString("token");

                  if (token == null || token.isEmpty) {
                    _showSnackBar("Please login!");
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ServiceDisputeScreen(
                        orderId: widget.id,
                        flowType: "direct",
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
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}*/

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/directHiring/views/ServiceProvider/view_user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../Widgets/address_map_class.dart';
import '../../../chat/APIServices.dart';
import '../../../chat/SocketService.dart';
import '../../../testingfile.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/userModel/subCategoriesModel.dart';
import 'ServiceDisputeScreen.dart';
import 'ServiceWorkerListScreen.dart';
import 'WorkerListViewProfileScreen.dart';

class ServiceDirectViewScreen extends StatefulWidget {
  final String id;
  final String? categreyId;
  final String? subcategreyId;
  const ServiceDirectViewScreen({
    super.key,
    required this.id,
    this.categreyId,
    this.subcategreyId,
  });

  @override
  State<ServiceDirectViewScreen> createState() =>
      _ServiceDirectViewScreenState();
}

class _ServiceDirectViewScreenState extends State<ServiceDirectViewScreen> {
  bool isLoading = true;
  Map<String, dynamic>? order;
  Map<String, dynamic>? providerDetail;
  List<ServiceProviderModel> providerslist = [];
  String? orderProviderId;
  ScaffoldMessengerState? _scaffoldMessenger;
  bool _isProcessing = false;
  bool _isOrderAccepted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    fetchOrderDetail();
  }

  Future<void> fetchOrderDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print("📋 Token mil gaya: $token");

      if (token.isEmpty) {
        setState(() => isLoading = false);
        _showSnackBar("Please login first!");
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("📥 Pura Response: ${response.body}");
        print("🔍 Order Data: ${decoded['data']['order']}");
        print("🔍 Assigned Worker Data: ${decoded['data']['assignedWorker']}");

        String? providerId;
        String? categoryId;
        String? subcategoryId;

        if (decoded['data']?['order']?['offer_history'] != null &&
            (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
            decoded['data']['order']['offer_history'][0]['provider_id'] !=
                null) {
          providerId = decoded['data']['order']['offer_history'][0]
                  ['provider_id']['_id']
              ?.toString();
          categoryId = decoded['data']['order']['offer_history'][0]
                  ['provider_id']['category_id']?['_id']
              ?.toString();
          subcategoryId = decoded['data']['order']['offer_history'][0]
                          ['provider_id']['subcategory_ids']
                      ?.isNotEmpty ==
                  true
              ? decoded['data']['order']['offer_history'][0]['provider_id']
                      ['subcategory_ids'][0]['_id']
                  ?.toString()
              : null;
          print("🚫 Provider ID mil gaya: $providerId");
          print("📋 Category ID: $categoryId, Subcategory ID: $subcategoryId");
        } else {
          print("⚠️ Offer history me provider_id nahi mila!");
        }

        setState(() {
          order = {
            ...decoded['data']['order'],
            'assignedWorker': decoded['data']['assignedWorker'],
          };
          orderProviderId = providerId;
          _isOrderAccepted = order?['hire_status']?.toLowerCase() == 'accepted';
          isLoading = false;
        });

        if (providerId != null) {
          await _saveHiredProviderId(providerId);
          await fetchProviderById(providerId);
        }

        if (categoryId != null && subcategoryId != null) {
          await fetchServiceProvidersListinWorkDetails(
              categoryId, subcategoryId);
        } else {
          print(
              "⚠️ Category ID ya Subcategory ID nahi mila, skipping fetchServiceProviders!");
          _showSnackBar("Category or subcategory ID missing!");
        }
      } else {
        print("❌ API ne dhoka diya: ${response.statusCode} - ${response.body}");
        setState(() => isLoading = false);
        _showSnackBar("Order details not found!");
      }
    } catch (e) {
      print("api call error: $e");
      setState(() => isLoading = false);
      _showSnackBar("Error aaya: $e");
    }
  }

  Future<void> fetchProviderById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- get provider by $id");

    final uri = Uri.parse(
        'https://api.thebharatworks.com/api/user/getServiceProvider/$id');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          providerDetail = jsonData['user'];
        });
        print("✅ Provider ka data mil gaya: ${jsonData['user']}");
      } else {
        print("❌ Provider fetch me lafda: ${response.body}");
      }
    } catch (e) {
      print("❗ fetchProviderById me error: $e");
    }
  }

  Future<void> _saveHiredProviderId(String hiredId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiredIds = prefs.getStringList('hiredProviderIds') ?? [];
    if (!hiredIds.contains(hiredId)) {
      hiredIds.add(hiredId);
      await prefs.setStringList('hiredProviderIds', hiredIds);
      print("🚫 Hired Provider ID save kiya: $hiredId");
      print("🚫 Poora hiredProviderIds list: $hiredIds");
    }
  }

  Future<void> _clearHiredProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("🔐 Token: $token");
    await prefs.remove('hiredProviderIds');
    print("🗑️ Hired Provider IDs saaf kiye!");

    if (order == null || order!['_id'] == null) {
      print("❌ Order ya orderId nahi mila!");
      _showSnackBar("Order data missing!");
      return;
    }

    final orderStatus = order!['hire_status']?.toString().toLowerCase() ?? '';
    final offerHistory = order!['offer_history'] as List<dynamic>?;
    print("📋 Order ID: ${order!['_id']}, Status: $orderStatus");
    print("📋 Offer History: $offerHistory");

    if (orderStatus == 'rejected' || orderStatus == 'cancelled') {
      print("⚠️ Order already reject or cancel!");
      if (mounted) {
        _showSnackBar("Order already rejected");
        Navigator.pop(context);
      }
      return;
    }

    if (offerHistory != null && offerHistory.isNotEmpty) {
      final providerStatus =
          offerHistory[0]['status']?.toString().toLowerCase();
      print("📩 Provider Status in Offer History: $providerStatus");
      if (providerStatus == 'rejected' || providerStatus == 'cancelled') {
        print("⚠️ Provider ne offer pehle se reject kiya hai!");
        if (mounted) {
          _showSnackBar("Offer already rejected by provider");
          Navigator.pop(context);
        }
        return;
      }
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://api.thebharatworks.com/api/direct-order/reject-offer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"order_id": order!['_id']}),
      );

      print("📤 Reject API Response Status: ${response.statusCode}");
      print("📤 Reject API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == "Offer rejected successfully" && mounted) {
          _showSnackBar("Offer rejected!");
          Navigator.pop(context);
        } else {
          print("❌ Reject Failed: ${data['message']}");
          _showSnackBar("Not Rejected: ${data['message']}");
        }
      } else {
        final err = json.decode(response.body);
        print("❌ API Error: ${response.statusCode} - ${err['message']}");
        if (err['message'] == "Invalid rejection or already handled" &&
            mounted) {
          _showSnackBar("Order already rejected or invalid!");
          Navigator.pop(context);
        } else {
          _showSnackBar("Error ${response.statusCode}: ${err['message']}");
        }
      }

      if (order!['service_payment'] != null &&
          order!['service_payment']['payment_history']?.isNotEmpty == true) {
        try {
          final refundResponse = await http.post(
            Uri.parse(
                'https://api.razorpay.com/v1/payments/${order!['service_payment']['payment_history'][0]['payment_id']}/refund'),
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('YOUR_RAZORPAY_KEY_ID:YOUR_RAZORPAY_KEY_SECRET'))}',
            },
          );
          print("📤 Refund API response: ${refundResponse.body}");
        } catch (e) {
          print("❗ Refund me lafda: $e");
        }
      }
    } catch (e) {
      print("❗ Reject Offer me error: $e");
      _showSnackBar("Error: $e");
    }
  }

  Future<void> fetchServiceProvidersListinWorkDetails(
      String? categoryId, String? subCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
    print("🚫 Hired Provider IDs before fetch: $hiredProviderIds");

    if (token == null) {
      _showSnackBar("Please login!");
      return;
    }

    if (categoryId == null || subCategoryId == null) {
      print("⚠️ categoryId ya subCategoryId null hai, API call skip!");
      return;
    }

    final uri = Uri.parse(
        '${AppConstants.baseUrl}${ApiEndpoint.serviceDirectViewScreen}');
    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "category_id": categoryId,
          "subcategory_ids": [subCategoryId],
        }),
      );

      print("📦 fetchServiceProviders Status: ${response.statusCode}");
      print("📦 fetchServiceProviders Body: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == true && data["data"] != null) {
          setState(() {
            providerslist = (data["data"] as List).map((json) {
              final provider = ServiceProviderModel.fromJson(json);
              bool isExcluded = hiredProviderIds.contains(provider.id) ||
                  provider.id == orderProviderId;
              print(
                  "🔍 Provider ID: ${provider.id}, Name: ${provider.fullName}, Excluded: $isExcluded");
              return provider;
            }).where((provider) {
              bool isValid = provider.id != null &&
                  !hiredProviderIds.contains(provider.id) &&
                  provider.id != orderProviderId;
              if (!isValid) {
                print("🚫 Filtered out provider: ${provider.id}");
              }
              return isValid;
            }).toList();
            print("✅ Providers loaded: ${providerslist.length}");
            print(
                "✅ Providers IDs: ${providerslist.map((p) => p?.id).toList()}");
          });
        } else {
          _showSnackBar("No provider found!");
        }
      } else {
        final err = json.decode(response.body);
        _showSnackBar("Error ${response.statusCode}: ${err['message']}");
      }
    } catch (e) {
      print("❗ Exception: $e");
      _showSnackBar("Error: $e");
    }
  }

  Future<void> markOrderAsComplete() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      print("🔐 Token: $token");
      if (token == null) {
        _showSnackBar("Please login!");
        return;
      }

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var body = jsonEncode({"order_id": widget.id});
      print("📤 Request Body: $body");

      var response = await http.post(
        Uri.parse(
            "https://api.thebharatworks.com/api/direct-order/completeOrderProvider"),
        headers: headers,
        body: body,
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        _showSnackBar("Mark as complete!");
        Navigator.pop(context);
      } else {
        var data = jsonDecode(response.body);
        _showSnackBar("Complete mark not: ${data['message']}");
      }
    } catch (e) {
      print("❗ API call me error: $e");
      _showSnackBar("Error: $e");
    }
  }

  void _showSnackBar(String message) {
    if (mounted && _scaffoldMessenger != null) {
      _scaffoldMessenger!.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> acceptOffer(String orderId) async {
    if (!mounted || _isProcessing) return;

    setState(() => _isProcessing = true);
    print("Abhi:- getOderId in sent offer : ${orderId}");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        _showSnackBar("Please login!");
        print("❌ Token nahi mila, login karo!");
        setState(() => _isProcessing = false);
        return;
      }

      if (_isOrderAccepted) {
        print("✅ Order pehle se accept hai!");
        setState(() => _isProcessing = false);
        return;
      }

      print("📤 OrderId: $orderId ke liye accept request bhej raha hoon");
      final response = await http.post(
        Uri.parse(
            'https://api.thebharatworks.com/api/direct-order/accept-offer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"order_id": orderId}),
      );

      print("📥 Response aaya: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == "Offer accepted by provider") {
          setState(() {
            _isOrderAccepted = true;
            order!['hire_status'] = 'accepted';
          });
          _showSnackBar("Offer accepted!");
        } else {
          // _showSnackBar("Offer not accepted: ${data['message']}");
          print("❌ Offer accept fail: ${data['message']}");
        }
      } else {
        final err = json.decode(response.body);
        // _showSnackBar("Error ${response.statusCode}: ${err['message']}");
        print(
            "❌ API ka dimaag kharab: ${response.statusCode} - ${err['message']}");
        if (err['message'] == "Invalid acceptance or already handled") {
          setState(() {
            _isOrderAccepted = true;
            order!['hire_status'] = 'accepted';
          });
        }
      }
    } catch (e) {
      print("❗ AcceptOffer me lafda: $e");
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final Uri googleMapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open the map.";
    }
  }
  ///                chat api added


  Future<Map<String, dynamic>> fetchUserById(String userId, String token) async {
    try {
      print("Abhi:- Fetching user by ID: $userId");
      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUser/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print("Abhi:- User fetch API response: ${response.statusCode}, Body=${response.body}");
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          final user = body['user'];
          user['_id'] = getIdAsString(user['_id']); // Ensure _id is string
          return user;
        } else {
          throw Exception(body['message'] ?? 'Failed to fetch user');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Abhi:- Error fetching user by ID: $e");
      return {'full_name': 'Unknown', '_id': userId, 'profile_pic': null};
    }
  }

  String getIdAsString(dynamic id) {
    if (id == null) return '';
    if (id is String) return id;
    if (id is Map && id.containsKey('\$oid')) return id['\$oid'].toString();
    print("Abhi:- Warning: Unexpected _id format: $id");
    return id.toString();
  }
// Yeh function InkWell ke onTap mein call hota hai
  Future<void> _startOrFetchConversation(BuildContext context, String receiverId) async {
    try {
      // Step 1: User ID fetch karo
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("Abhi:- Error: No token found");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No token found, please log in again')),
        );
        return;
      }

      // Step 2: User profile fetch karo
      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/user/getUserProfileData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print("Abhi:- Error fetching profile: Status=${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to fetch user profile')),
        );
        return;
      }

      final body = json.decode(response.body);
      if (body['status'] != true) {
        print("Abhi:- Error fetching profile: ${body['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Failed to fetch profile: ${body['message']}')),
        );
        return;
      }

      final userId = getIdAsString(body['data']['_id']);
      if (userId.isEmpty) {
        print("Abhi:- Error: User ID is empty");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User ID not available')),
        );
        return;
      }

      // Step 3: Check if conversation exists
      print("Abhi:- Checking for existing conversation with receiverId: $receiverId, userId: $userId");
      final convs = await ApiService.fetchConversations(userId);
      dynamic currentChat = convs.firstWhere(
            (conv) {
          final members = conv['members'] as List? ?? [];
          if (members.isEmpty) return false;
          if (members[0] is String) {
            return members.contains(receiverId) && members.contains(userId);
          } else {
            return members.any((m) => getIdAsString(m['_id']) == receiverId) &&
                members.any((m) => getIdAsString(m['_id']) == userId);
          }
        },
        orElse: () => null,
      );

      // Step 4: Agar conversation nahi hai, toh nayi conversation start karo
      if (currentChat == null) {
        print("Abhi:- No existing conversation, starting new with receiverId: $receiverId");
        currentChat = await ApiService.startConversation(userId, receiverId);
      }

      // Step 5: Agar members strings hain, toh full user details fetch karo
      if (currentChat['members'].isNotEmpty && currentChat['members'][0] is String) {
        print("Abhi:- New conversation, fetching user details for members");
        final otherId = currentChat['members'].firstWhere((id) => id != userId);
        final otherUserData = await fetchUserById(otherId, token);
        final senderUserData = await fetchUserById(userId, token);
        currentChat['members'] = [senderUserData, otherUserData];
        print("Abhi:- Updated members with full details: ${currentChat['members']}");
      }

      // Step 6: Messages fetch karo
      final messages = await ApiService.fetchMessages(getIdAsString(currentChat['_id']));
      messages.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

      // Step 7: Socket initialize karo
      SocketService.connect(userId);
      final onlineUsers = <String>[];
      SocketService.listenOnlineUsers((users) {
        onlineUsers.clear();
        onlineUsers.addAll(users.map((u) => getIdAsString(u)));
      });

      // Step 8: ChatDetailScreen push karo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StandaloneChatDetailScreen(
            initialCurrentChat: currentChat,
            initialUserId: userId,
            initialMessages: messages,
            initialOnlineUsers: onlineUsers,
          ),
        ),
      ).then((_) {
        SocketService.disconnect();
      });
    } catch (e, stackTrace) {
      print("Abhi:- Error starting conversation: $e");
      print("Abhi:- Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to start conversation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "📋 DirectViewScreen categreyId: ${widget.categreyId}, subCategreyId: ${widget.subcategreyId}");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title:  Text(_isOrderAccepted
                     ? 'Worker Details'
                       : 'Work Details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text("No data found!"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () => Navigator.pop(context),
                      //       child: const Padding(
                      //         padding: EdgeInsets.only(left: 6.0),
                      //         child: Icon(
                      //           Icons.arrow_back_outlined,
                      //           size: 20,
                      //           color: Colors.black,
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 80),
                      //     Text(
                      //       _isOrderAccepted
                      //           ? 'Worker Details'
                      //           : 'Work Details',
                      //       style: GoogleFonts.roboto(
                      //         fontSize: 18,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),
                      // Updated CarouselSlider for full screen width
                      order!['image_url'] != null &&
                              (order!['image_url'] is List &&
                                  order!['image_url'].isNotEmpty)
                          ? Container(color: Colors.grey,
                            child: CarouselSlider(
                                options: CarouselOptions(
                                  height: 200.0,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  viewportFraction: 1.0, // Full screen width
                                  enableInfiniteScroll: true,
                                  enlargeCenterPage: false, // No scaling
                                ),
                                items:
                                    (order!['image_url'] as List).map((imageUrl) {
                                  final url = imageUrl.startsWith('http')
                                      ? imageUrl
                                      : 'https://api.thebharatworks.com$imageUrl';
                                  print("📸 Carousel Image URL: $url");
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.zero, // No extra margin
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Image.network(
                                            url,
                                            // fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 200,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  "📸 Image load me lafda: $error");
                                              return Image.asset(
                                                'assets/images/task.png',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 200,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                          )
                          : Image.asset(
                              'assets/images/task.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              order!['title'] ?? 'Work Title',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "Posted: ${order!['createdAt']?.toString().substring(0, 10) ?? 'N/A'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => MapScreen(
                              //       latitude: order?['service_provider_id']?['location']?['latitude'] ?? 'No lat',
                              //       longitude: order?['service_provider_id']?['location']?['longitude'] ?? 'No long',
                              //     ),
                              //   ),
                              // );
                              openMap(order?['latitude'] ?? 'No lat',
                                order?['longitude'] ?? 'No long',);

                              print("Abhi:- get oder Details lat : ${order?['latitude'] ?? 'No lat'} long : ${order?['longitude'] ?? 'No long'}");
                            },
                            child: Container(
                              height: 24,
                              width: 160,
                              // padding: const EdgeInsets.symmetric(
                              //     horizontal: 18, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                  // "",
                                  order!['address'] ?? '',
                                // order?['service_provider_id']?['location']?['address'] ?? 'No long',
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(5)),
                            child: Center(child: Text(order!['project_id'] ?? '',style: TextStyle(color: Colors.white), maxLines: 1,
                              overflow: TextOverflow.ellipsis,)),),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "Completion Date - ${order!['deadline']?.toString().substring(0, 10) ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Task Details",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        order!['description'] ?? 'No description available.',
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      // Status Containers
                      if (order!['hire_status'] == 'cancelled')
                        Center(
                          child: Container(
                            height: 35,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.warning_amber, color: Colors.red),
                                Text(
                                  "This order is cancelled",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (order!['hire_status'] == 'completed')
                        Center(
                          child: Container(
                            height: 35,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.green),
                                Text(
                                  "This order has been completed.",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      order!['hire_status'] == 'cancelledDispute'
                          ? Center(
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber, color: Colors.red),
                              Flexible(
                                child: Text("The order has been cancelled due to a dispute.",
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
                              ),
                            ],
                          ),
                        ),
                      )
                          : SizedBox(),
                      if (order!['hire_status'] == 'rejected')
                        Center(
                          child: Container(
                            height: 35,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.block, color: Colors.grey),
                                Text("The order is rejected"),
                              ],
                            ),
                          ),
                        ),
                      if (order?['hire_status']?.toLowerCase() ==
                          'pending') ...[
                        GestureDetector(
                          onTap: _isProcessing || _isOrderAccepted
                              ? null
                              : () {
                                  if (order == null || order!['_id'] == null) {
                                    print("❌ Order not found!");
                                    _showSnackBar("Order Data not found!");
                                    return;
                                  }
                                  String orderId = order!['_id'].toString();
                                  print(
                                      "✅ OrderId $orderId ke liye Accept dabaya!");
                                  acceptOffer(orderId);
                                },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _isOrderAccepted
                                  ? Colors.grey.shade400
                                  : Colors.green.shade700,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isProcessing
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      "Accept",
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEE2121),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () async {
                              await _clearHiredProviders();
                            },
                            child: Text(
                              "Reject",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (_isOrderAccepted) ...[
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: () {
                                  final profilePic =
                                      order != null && order!['user_id'] != null
                                          ? order!['user_id']['profile_pic']
                                          : null;
                                  print("📸 Profile Pic URL: $profilePic");
                                  return profilePic != null
                                      ? Image.network(
                                          '$profilePic',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                "📸 Profile pic load me lafda: $error");
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: Center(
                                                child: Text(
                                                  "No Pic",
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Text(
                                              "No Pic",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                }(),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: () {
                                            final fullName = order != null &&
                                                    order!['user_id'] != null
                                                ? order!['user_id']
                                                        ['full_name'] ??
                                                    'Unknown '
                                                : 'Unknown ';
                                            print(
                                                "📛 User Full Name: $fullName");
                                            return Text(
                                              fullName,
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          }(),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "Project Fees – ₹${order != null && order!['platform_fee'] != null ? order!['platform_fee'] : 'N/A'}/-",
                                          style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6),
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(
                                      Icons.call,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //           this code is currect added by Abhishek
                                  InkWell(
                                    onTap: () async {
                                      final receiverId = order != null && order!['user_id'] != null
                                          ? order!['user_id']['_id']?.toString() ?? 'Unknown'
                                          : 'Unknown';
                                      final fullName = order != null && order!['user_id'] != null
                                          ?  order!['user_id']['full_name'] ?? 'Unknown'
                                          : 'Unknown';
                                      print("Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullName");

                                      if (receiverId != 'Unknown' && receiverId.isNotEmpty) {
                                        await _startOrFetchConversation(context, receiverId);
                                      } else {
                                        print("Abhi:- Error: Invalid receiver ID");
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: Invalid receiver ID')),
                                        );
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(
                                        Icons.message,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      final userId = order != null &&
                                              order!['user_id'] != null
                                          ? order!['user_id']['_id'] ??
                                              'Unknown '
                                          : 'Unknown ';
                                      print(
                                          "👤 Navigating to Profile with User ID: $userId");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewUserProfileScreen(
                                                  profileImage:
                                                      order?['user_id']
                                                              ['profile_pic'] ??
                                                          "",
                                                  userId: userId),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "View Profile",
                                      style: GoogleFonts.roboto(
                                        color: Colors.green,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_isOrderAccepted &&
                            order!['assignedWorker'] != null)
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Assigned Person",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: order != null &&
                                              order!['assignedWorker'] !=
                                                  null &&
                                              order!['assignedWorker']
                                                      ['image'] !=
                                                  null
                                          ? NetworkImage(
                                              order!['assignedWorker']['image'])
                                          : AssetImage(
                                              'assets/profile_pic.jpg'),
                                      onBackgroundImageError:
                                          (exception, stackTrace) {
                                        print(
                                            "📸 Assigned Worker Image Error: $exception");
                                      },
                                    ),
                                    SizedBox(width: 30),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order != null &&
                                                    order!['assignedWorker'] !=
                                                        null
                                                ? order!['assignedWorker']
                                                        ['name'] ??
                                                    'Unknown Worker'
                                                : 'Unknown Worker',
                                            style: GoogleFonts.roboto(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            order != null &&
                                                    order!['assignedWorker'] !=
                                                        null
                                                ? order!['assignedWorker']
                                                        ['address'] ??
                                                    'No Address'
                                                : 'No Address',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: () {
                                              if (order != null &&
                                                  order!['assignedWorker'] !=
                                                      null &&
                                                  order!['assignedWorker']
                                                          ['_id'] !=
                                                      null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WorkerListViewProfileScreen(
                                                      workerId: order![
                                                              'assignedWorker']
                                                          ['_id'],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                print(
                                                    "❌ Assigned worker ID not found");
                                                _showSnackBar(
                                                    "Worker data missing!");
                                              }
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade700,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'View profile',
                                                  style: GoogleFonts.roboto(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),
                        if (_isOrderAccepted &&
                            order!['assignedWorker'] == null)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceWorkerListScreen(
                                      orderId: widget.id),
                                ),
                              ).then((_) {
                                fetchOrderDetail();
                              });
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.green.shade700),
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
                        const SizedBox(height: 20),
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
                                    'Payment',
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
                                if (order!['service_payment'] != null &&
                                    order!['service_payment']
                                            ['payment_history'] !=
                                        null &&
                                    order!['service_payment']['payment_history']
                                        .isNotEmpty)
                                  ...List.generate(
                                    order!['service_payment']['payment_history']
                                        .length,
                                    (index) {
                                      final item = order!['service_payment']
                                          ['payment_history'][index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 2,
                                              child: Text(
                                                "${index + 1}. ${item['description'] ?? 'No Description'}",
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            Flexible(
                                              flex: 3,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "${item['status'] == 'paid' ? 'Paid' : 'Pending'}",
                                                      style: GoogleFonts.roboto(
                                                        color: item['status'] ==
                                                                'paid'
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Flexible(
                                                    child: Text(
                                                      "₹${item['amount']}",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                else
                                  Text(
                                    'No payment history found.',
                                    style: GoogleFonts.roboto(fontSize: 14),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.only(top: 40, bottom: 16),
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
                                    'Make payments only through the app,\nit’s safer and more secure.',
                                    textAlign: TextAlign.center,
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
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? token = prefs.getString("token");

                            if (token == null || token.isEmpty) {
                              _showSnackBar("Please login!");
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDisputeScreen(
                                  orderId: widget.id,
                                  flowType: "direct",
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
                                'Cancel Task and Create Dispute',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
    );
  }
}
