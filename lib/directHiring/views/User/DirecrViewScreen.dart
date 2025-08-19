// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:developer/directHiring/views/User/viewServiceProviderProfile.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Consent/ApiEndpoint.dart';
// import '../../Consent/app_constants.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../models/userModel/subCategoriesModel.dart';
// import '../Account/service_provider_profile/ServiceProviderProfileScreen.dart';
// import '../ServiceProvider/ViewWorkerScreen.dart';
// import '../ServiceProvider/WorkerListViewProfileScreen.dart';
// import '../comm/view_images_screen.dart';
// import 'PaymentScreen.dart'; // Note: Typo in 'PatmentScreen', should be 'PaymentScreen'
//
// class DirectViewScreen extends StatefulWidget {
//   final String id;
//   final String?
//   categreyId; // Note: Typo in 'categreyId', consider renaming to 'categoryId'
//   final String?
//   subcategreyId; // Note: Typo in 'subcategreyId', consider renaming to 'subcategoryId'
//
//   const DirectViewScreen({
//     super.key,
//     required this.id,
//     this.categreyId,
//     this.subcategreyId,
//   });
//
//   @override
//   State<DirectViewScreen> createState() => _DirectViewScreenState();
// }
//
// class _DirectViewScreenState extends State<DirectViewScreen> {
//   bool isLoading = true;
//   Map<String, dynamic>? order;
//   Map<String, dynamic>? providerDetail;
//   List<ServiceProviderModel> providerslist = [];
//   String? orderProviderId;
//   ScaffoldMessengerState? _scaffoldMessenger;
//   final ScrollController _scrollController =
//       ScrollController(); // Add ScrollController
//   final GlobalKey _listViewKey =
//       GlobalKey(); // Add GlobalKey for ListView.builder
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _scaffoldMessenger = ScaffoldMessenger.of(context);
//   }
//
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _clearHiredProviders().then((_) => fetchOrderDetail());
//     // _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
//     //   fetchOrderDetail();
//     // });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> fetchOrderDetail() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';
//       print("Abhi:- fetchOrderDetail token: $token");
//       print("Abhi:- fetchOrderDetail id ---> : ${widget.id}");
//
//       final response = await http.get(
//         Uri.parse(
//           'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
//           // 'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/6870d28ab1bd9d65afad055e',
//         ),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         print("Abhi:- fetchOrderDetail response: ${response.body}");
//         print(
//           "Abhi:- Service Payment: ${decoded['data']['order']['service_payment']}",
//         ); // Debugging
//         String? providerId;
//         if (decoded['data']?['order']?['offer_history'] != null &&
//             (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
//             decoded['data']['order']['offer_history'][0]['provider_id'] !=
//                 null) {
//           providerId =
//               decoded['data']['order']['offer_history'][0]['provider_id']['_id']
//                   ?.toString();
//           print("🚫 Order Provider ID set: $providerId");
//         } else {
//           print("⚠️ No provider_id found in offer_history");
//         }
//         setState(() {
//           order = decoded['data']['order'];
//           orderProviderId = providerId;
//           isLoading = false;
//         });
//
//         if (providerId != null) {
//           await _saveHiredProviderId(providerId);
//           await fetchProviderById(providerId);
//         }
//
//         await fetchServiceProvidersListinWorkDetails(
//           widget.categreyId ?? '68443fdbf03868e7d6b74874',
//           widget.subcategreyId ?? '684e7226962b4919ae932af5',
//         );
//       } else {
//         print(
//           "❌ fetchOrderDetail failed: ${response.statusCode} - ${response.body}",
//         );
//         setState(() => isLoading = false);
//         await fetchServiceProvidersListinWorkDetails(
//           widget.categreyId ?? '68443fdbf03868e7d6b74874',
//           widget.subcategreyId ?? '684e7226962b4919ae932af5',
//         );
//       }
//     } catch (e) {
//       print("❗ fetchOrderDetail Error: $e");
//       setState(() => isLoading = false);
//       await fetchServiceProvidersListinWorkDetails(
//         widget.categreyId ?? '68443fdbf03868e7d6b74874',
//         widget.subcategreyId ?? '684e7226962b4919ae932af5',
//       );
//     }
//   }
//
//   Future<void> cancelDarectOder() async {
//     print("Abhi:- darect cancelOder order id ${widget.id}");
//
//     final String url =
//         '${AppConstants.baseUrl}${ApiEndpoint.darectCanceloffer}';
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     print("Abhi:- cancelOder token: $token");
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json', // 👈 ye zaruri hai
//         },
//         body: jsonEncode({"order_id": widget.id}),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("Abhi:- darecthire cancelOder success :- ${response.body}");
//         print(
//           "Abhi:- darecthire cancelOder statusCode :- ${response.statusCode}",
//         );
//         Navigator.pop(context);
//         _clearHiredProviders().then((_) => fetchOrderDetail());
//       } else {
//         print("Abhi:- else darect-hire cancelOder error :- ${response.body}");
//         print(
//           "Abhi:- else darect-hire cancelOder statusCode :- ${response.statusCode}",
//         );
//       }
//     } catch (e) {
//       print("Abhi:- Exception darect-hire : - $e");
//     }
//   }
//
//   Future<void> fetchProviderById(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     print("Abhi:- fetchproviderbyId providerId --> ${id}");
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
//       } else {
//         print("❌ Provider fetch failed: ${response.body}");
//       }
//     } catch (e) {
//       print("❗ fetchProviderById Error: $e");
//     }
//   }
//
//   Future<void> _saveHiredProviderId(String hiredId) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> hiredIds = prefs.getStringList('hiredProviderIds') ?? [];
//     if (!hiredIds.contains(hiredId)) {
//       hiredIds.add(hiredId);
//       await prefs.setStringList('hiredProviderIds', hiredIds);
//       print("🚫 Saved Hired Provider ID: $hiredId");
//       print("🚫 Current hiredProviderIds: $hiredIds");
//     }
//   }
//
//   Future<void> _clearHiredProviders() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('hiredProviderIds');
//     print("🗑️ Cleared hiredProviderIds");
//     if (order != null &&
//         order!['service_payment'] != null &&
//         order!['service_payment']['payment_history']?.isNotEmpty == true) {
//       try {
//         final response = await http.post(
//           Uri.parse(
//             'https://api.razorpay.com/v1/payments/${order!['service_payment']['payment_history'][0]['payment_id']}/refund',
//           ),
//           headers: {
//             'Authorization':
//                 'Basic ${base64Encode(utf8.encode('YOUR_RAZORPAY_KEY_ID:YOUR_RAZORPAY_KEY_SECRET'))}',
//           },
//         );
//         print("📤 Refund API response: ${response.body}");
//       } catch (e) {
//         print("❗ Refund Error: $e");
//       }
//     }
//   }
//
//   Future<void> fetchServiceProvidersListinWorkDetails(
//     String? categoryId,
//     String? subCategoryId,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
//     print("🚫 Hired Provider IDs: $hiredProviderIds");
//     print("🚫 Offer History: ${order?['offer_history']}");
//
//     if (token == null) {
//       if (mounted && _scaffoldMessenger != null) {
//         _scaffoldMessenger!.showSnackBar(
//           const SnackBar(content: Text("Pehle login kar bhai")),
//         );
//       }
//       return;
//     }
//
//     final effectiveCategoryId = categoryId ?? '68443fdbf03868e7d6b74874';
//     final effectiveSubCategoryId = subCategoryId ?? '684e7226962b4919ae932af5';
//     print(
//       "📌 Using categoryId: $effectiveCategoryId, subCategoryId: $effectiveSubCategoryId",
//     );
//
//     final uri = Uri.parse(
//       'https://api.thebharatworks.com/api/user/getServiceProviders',
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
//           "category_id": effectiveCategoryId,
//           "subcategory_id": effectiveSubCategoryId,
//         }),
//       );
//
//       print(
//         "📦 API Body Sent: ${json.encode({"category_id": effectiveCategoryId, "subcategory_id": effectiveSubCategoryId})}",
//       );
//       print(
//         "📦 Abhi:- Status: ${response.statusCode}, Response: ${response.body}",
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data["status"] == true && data["data"] != null) {
//           setState(() {
//             providerslist =
//                 (data["data"] as List)
//                     .map((json) {
//                       final provider = ServiceProviderModel.fromJson(json);
//                       print("🔍 Raw Provider Data: $json");
//                       return provider;
//                     })
//                     .where((provider) {
//                       if (provider.id == null) {
//                         print("🔍 Provider ID null hai: $provider");
//                         return false;
//                       }
//                       bool isExcluded =
//                           hiredProviderIds.contains(provider.id) ||
//                           (order?['offer_history'] != null &&
//                               (order!['offer_history'] as List).any((offer) {
//                                 String offerProviderId =
//                                     offer['provider_id'] is String
//                                         ? offer['provider_id']
//                                         : offer['provider_id']?['_id']
//                                                 ?.toString() ??
//                                             '';
//                                 bool match = offerProviderId == provider.id;
//                                 print(
//                                   "🔍 Checking Offer: $offerProviderId vs ${provider.id} => $match",
//                                 );
//                                 return match;
//                               }));
//                       print(
//                         "🔍 Provider: ${provider.id}, Name: ${provider.fullName}, Chhupa?: $isExcluded",
//                       );
//                       return !isExcluded;
//                     })
//                     .toList();
//             print("✅ Providers loaded: ${providerslist.length}");
//             print(
//               "✅ Providers IDs: ${providerslist.map((p) => p.id).toList()}",
//             );
//           });
//         } else {
//           print("⚠️ No providers in API response");
//           if (mounted && _scaffoldMessenger != null) {
//             _scaffoldMessenger!.showSnackBar(
//               const SnackBar(content: Text("Koi provider nahi mila")),
//             );
//           }
//         }
//       } else {
//         print("❌ API Error: ${response.statusCode}");
//         if (mounted && _scaffoldMessenger != null) {
//           _scaffoldMessenger!.showSnackBar(
//             SnackBar(content: Text("Error ${response.statusCode}")),
//           );
//         }
//       }
//     } catch (e) {
//       print("❗ Error: $e");
//       if (mounted && _scaffoldMessenger != null) {
//         _scaffoldMessenger!.showSnackBar(SnackBar(content: Text("Error: $e")));
//       }
//     }
//   }
//
//   Future<void> sendNextOffer(String orderId, String providerId) async {
//     if (!mounted) {
//       print("🚫 Widget not mounted. Exiting sendNextOffer.");
//       return;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//     final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
//
//     print("📌 Sending offer to provider ID: $providerId");
//     print("🚫 Hired Provider IDs before sending offer: $hiredProviderIds");
//
//     final alreadyOffered =
//         hiredProviderIds.contains(providerId.trim()) ||
//         (order != null &&
//             order!['offer_history'] != null &&
//             (order!['offer_history'] as List).any((offer) {
//               bool match = false;
//               if (offer['provider_id'] is String) {
//                 match =
//                     offer['provider_id'].toString().trim() == providerId.trim();
//               } else if (offer['provider_id'] is Map) {
//                 match =
//                     offer['provider_id']['_id'].toString().trim() ==
//                     providerId.trim();
//               }
//               print("🧐 Offer history match check: $match | Offer: $offer");
//               return match;
//             }));
//
//     if (alreadyOffered) {
//       print("⚠️ Provider has already been offered.");
//       if (mounted && _scaffoldMessenger != null) {
//         _scaffoldMessenger!.showSnackBar(
//           const SnackBar(content: Text("Offer already sent to this provider")),
//         );
//       }
//       return;
//     }
//
//     final uri = Uri.parse(
//       'https://api.thebharatworks.com/api/direct-order/send-next-offer',
//     );
//     print("🌐 Sending POST request to: $uri");
//
//     try {
//       final response = await http.post(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'order_id': orderId,
//           'next_provider_id': providerId,
//         }),
//       );
//
//       print("📤 sendNextOffer Status: ${response.statusCode}");
//       print("📤 sendNextOffer Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['status'] == true) {
//           await _saveHiredProviderId(providerId.trim());
//           final updatedHiredIds = prefs.getStringList('hiredProviderIds') ?? [];
//           print("✅ HiredProviderIds after saving: $updatedHiredIds");
//
//           await prefs.setString(
//             'category_id',
//             widget.categreyId ?? '68443fdbf03868e7d6b74874',
//           );
//           await prefs.setString(
//             'sub_category_id',
//             widget.subcategreyId ?? '684e7226962b4919ae932af5',
//           );
//
//           if (mounted) {
//             setState(() {
//               providerslist.removeWhere((provider) {
//                 bool isRemoved = provider.id?.trim() == providerId.trim();
//                 print(
//                   "🔍 Comparing: ${provider.id?.trim()} == ${providerId.trim()} => $isRemoved",
//                 );
//                 return isRemoved;
//               });
//               print(
//                 "📋 Updated providerslist: ${providerslist.map((p) => p.id).toList()}",
//               );
//             });
//
//             await fetchServiceProvidersListinWorkDetails(
//               widget.categreyId ?? '68443fdbf03868e7d6b74874',
//               widget.subcategreyId ?? '684e7226962b4919ae932af5',
//             );
//
//             if (order != null) {
//               setState(() {
//                 order!['offer_history'] = [
//                   ...?order!['offer_history'],
//                   {'provider_id': providerId.trim(), 'status': 'pending'},
//                 ];
//               });
//             }
//
//             if (mounted && _scaffoldMessenger != null) {
//               _scaffoldMessenger!.showSnackBar(
//                 const SnackBar(content: Text("Offer sent successfully")),
//               );
//             }
//           }
//         } else {
//           print("❌ Send offer failed: ${data['message']}");
//           if (mounted && _scaffoldMessenger != null) {
//             _scaffoldMessenger!.showSnackBar(
//               SnackBar(content: Text("${data['message']}")),
//             );
//           }
//         }
//       } else {
//         final err = json.decode(response.body);
//         print("❗ API Error: ${response.statusCode} - ${err['message']}");
//         if (mounted && _scaffoldMessenger != null) {
//           _scaffoldMessenger!.showSnackBar(
//             SnackBar(
//               content: Text("Error ${response.statusCode}: ${err['message']}"),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print("❗ sendNextOffer Exception: $e");
//       if (mounted && _scaffoldMessenger != null) {
//         _scaffoldMessenger!.showSnackBar(SnackBar(content: Text("Error: $e")));
//       }
//     }
//   }
//
//   // Function to scroll to ListView.builder
//   void _scrollToListView() {
//     final RenderObject? renderObject =
//         _listViewKey.currentContext?.findRenderObject();
//     if (renderObject != null && renderObject is RenderBox) {
//       final position = renderObject.localToGlobal(Offset.zero).dy;
//       _scrollController.animateTo(
//         position,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     //    print("Abhi:- DirectViewscreen get categreyId new ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}");
//     //    print("Abhi:- DirectViewscreen hire status---> ${ order?['hire_status']??""}");
//     // // print("Abhi:- Oder id: ${order!['_id']?['service_payment']['payment_history']['amount'] ?? ""}");
//        print("Abhi:- darect oder id ${widget.id}");
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 10,
//         automaticallyImplyLeading: false,
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : order == null
//               ? const Center(child: Text("No data found"))
//               : SingleChildScrollView(
//                 controller: _scrollController, // Attach ScrollController
//                 padding: const EdgeInsets.only(bottom: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 30),
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () => Navigator.pop(context),
//                           child: const Padding(
//                             padding: EdgeInsets.only(left: 18.0),
//                             child: Icon(Icons.arrow_back_outlined, size: 22),
//                           ),
//                         ),
//                         const SizedBox(width: 90),
//                         Text(
//                           "Work details",
//                           style: GoogleFonts.roboto(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//
//                   /*  if (order!['image_url'] != null &&
//                         order!['image_url'] is List)
//                       Image.network(
//                         (order!['image_url'] as List).isNotEmpty
//                             ? 'https://api.thebharatworks.com${(order!['image_url'] as List).first}'
//                             : 'https://api.thebharatworks.com/uploads/directOrder/placeholder.jpg',
//                         width: double.infinity,
//                         height: 200,
//                         fit: BoxFit.cover,
//                         errorBuilder:
//                             (context, error, stackTrace) => Image.asset(
//                               'assets/images/task.png',
//                               width: double.infinity,
//                               height: 200,
//                               fit: BoxFit.cover,
//                             ),
//                       ),*/
//                     if (order!['image_url'] != null &&
//                         order!['image_url'] is List &&
//                         (order!['image_url'] as List).isNotEmpty)
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (context) => ViewImage(
//                                 imageUrl:
//                                 'https://api.thebharatworks.com/uploads/hiswork/1752481481201.jpg${order!['image_url'] ?? ""}',
//                               ),
//                             ),
//                           );
//                         },
//                         child: CarouselSlider(
//                           options: CarouselOptions(
//                             height: 200,
//                             autoPlay: true,
//                             enlargeCenterPage: true,
//                             aspectRatio: 16 / 9,
//                             viewportFraction: 1.0,
//                             autoPlayInterval: const Duration(seconds: 3),
//                             autoPlayAnimationDuration: const Duration(
//                               milliseconds: 800,
//                             ),
//                             autoPlayCurve: Curves.fastOutSlowIn,
//                           ),
//                           items:
//                           (order!['image_url'] as List).map((imageUrl) {
//                             return Builder(
//                               builder: (BuildContext context) {
//                                 return Image.network(
//                                   '$imageUrl',
//                                   width: double.infinity,
//                                   height: 200,
//                                   fit: BoxFit.cover,
//                                   errorBuilder:
//                                       (context, error, stackTrace) =>
//                                       Image.asset(
//                                         'assets/images/task.png',
//                                         width: double.infinity,
//                                         height: 200,
//                                         fit: BoxFit.cover,
//                                       ),
//                                 );
//                               },
//                             );
//                           }).toList(),
//                         ),
//                       )
//                     else
//                       Image.asset(
//                         'assets/images/task.png',
//                         width: double.infinity,
//                         height: 200,
//                         fit: BoxFit.cover,
//                       ),
//
//
//                     const SizedBox(height: 12),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             order!['title'] ?? '',
//                             style: GoogleFonts.roboto(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Container(
//                                 height: 24,
//                                 width: 160,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 40,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   color: Colors.red,
//                                 ),
//                                 child: Expanded(
//                                   child: Text(
//                                     order!['address'] ?? '',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 "Posted: ${order!['createdAt']?.toString().substring(0, 10) ?? ''}",
//                                 style: GoogleFonts.roboto(color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Completion: ${order!['deadline']?.toString().substring(0, 10) ?? ''}",
//                             style: const TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Work title",
//                             style: GoogleFonts.roboto(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             order!['description'] ??
//                                 "No description available.",
//                             style: const TextStyle(fontSize: 15),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     order!['hire_status'] == 'accepted'
//                         ? Center(
//                           child: Card(
//                             elevation: 3,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Container(
//                               height: 120,
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   ClipOval(
//                                     child: Image.network(
//                                       // "assets/images/account1.png",
//                                       "${order!['service_provider_id']?['profile_pic'] ?? ''}",
//                                       height: 80,
//                                       width: 80,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (
//                                         context,
//                                         error,
//                                         stackTrace,
//                                       ) {
//                                         return const Icon(
//                                           Icons.image_not_supported_outlined,
//                                           size: 56,
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 "${order!['service_provider_id']?['full_name'] ?? ''}",
//                                                 style: GoogleFonts.roboto(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ),
//                                             Container(
//                                               padding: const EdgeInsets.all(6),
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 color: Colors.grey.shade200,
//                                               ),
//                                               child: const Icon(
//                                                 Icons.call,
//                                                 size: 16,
//                                                 color: Colors.green,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 5),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 "Project Fees - ₹${order!['platform_fee'] ?? "200"}/-",
//                                                 style: GoogleFonts.roboto(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ),
//                                             Container(
//                                               padding: const EdgeInsets.all(6),
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 color: Colors.grey.shade300,
//                                               ),
//                                               child: const Icon(
//                                                 Icons.message,
//                                                 size: 16,
//                                                 color: Colors.green,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const Spacer(),
//                                         InkWell(
//                                           onTap: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder:
//                                                     (
//                                                       context,
//                                                     ) => ViewServiceProviderProfileScreen(
//                                                       serviceProviderId:
//                                                           order!['service_provider_id']?['_id'] ??
//                                                           '',
//                                                     ),
//                                               ),
//                                             );
//                                           },
//                                           child: Align(
//                                             alignment: Alignment.bottomRight,
//                                             child: Text(
//                                               "View Profile",
//                                               style: GoogleFonts.roboto(
//                                                 fontSize: 13,
//                                                 color: Colors.green.shade700,
//                                                 fontWeight: FontWeight.w700,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )
//                         : SizedBox(),
//                     // worker card
//                     order!['hire_status'] == 'accepted' && order!['assignedWorker'] != null && order!['assignedWorker'].isNotEmpty
//                         ? Center(
//                       child: Card(
//                         elevation: 3,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Container(
//                           height: 120,
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               ClipOval(
//                                 child: Image.network(
//                                   order!['assignedWorker']?['image'] != null
//                                       ? "http://api.thebharatworks.com${order!['assignedWorker']['image']}"
//                                       : "https://api.thebharatworks.com/uploads/directOrder/placeholder.jpg",
//                                   height: 80,
//                                   width: 80,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return const Icon(
//                                       Icons.image_not_supported_outlined,
//                                       size: 56,
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             order!['assignedWorker']?['name'] ?? 'Unknown Worker',
//                                             style: GoogleFonts.roboto(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),// state
//                                     const SizedBox(height: 5),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             order!['assignedWorker']?['address'] ?? 'No address',
//                                             style: GoogleFonts.roboto(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                               color: Colors.black87,
//                                             ),
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                    // const Spacer(),
//                                     SizedBox(height: 15,),
//                                     InkWell(
//                                       onTap: () {
//                                         if (order!['service_provider_id']?['_id'] != null) {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => WorkerListViewProfileScreen(
//                                                 workerId: order!['assignedWorker']?['_id']??"",
//                                               ),
//                                             ),
//                                           );
//                                         } else {
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             const SnackBar(
//                                               content: Text("Provider ID not found"),
//                                             ),
//                                           );
//                                         }
//                                       },
//                                       child: Container(
//                                         height: 30,
//                                         width: 120,
//                                         decoration: BoxDecoration(border: Border.all(color: Colors.green),borderRadius: BorderRadius.circular(8)),
//                                         child: Center(
//                                           child: Text(
//                                             "View Profile",
//                                             style: GoogleFonts.roboto(
//                                               fontSize: 13,
//                                               color: Colors.green.shade700,
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                         : const SizedBox(),
//                     const SizedBox(height: 20),
//                     order!['hire_status'] == 'accepted'
//                         ? SizedBox()
//                         : Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Column(
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   _scrollToListView(); // Scroll to ListView on tap
//                                 },
//                                 child: Container(
//                                   width: double.infinity,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade700,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.1),
//                                         spreadRadius: 1,
//                                         blurRadius: 6,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "Offer sent",
//                                       style: GoogleFonts.roboto(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Container(
//                                 width: double.infinity,
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFEE2121),
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.1),
//                                       spreadRadius: 1,
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: TextButton(
//                                   onPressed: () async {
//                                     await _clearHiredProviders();
//                                     cancelDarectOder();
//                                     if (mounted && _scaffoldMessenger != null) {
//                                       _scaffoldMessenger!.showSnackBar(
//                                         const SnackBar(
//                                           content: Text("Order cancelled"),
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   child: Text(
//                                     "Cancel",
//                                     style: GoogleFonts.roboto(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                             ],
//                           ),
//                         ),
//
//                     order!['hire_status'] == 'cancelled'
//                         ? Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Icon(Icons.warning_amber, color: Colors.red),
//                           Text("The order is Cancelled"),
//                         ],
//                       ),
//                     )
//                         : SizedBox(),
//
//                     order!['hire_status'] == 'completed'
//                         ? Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Icon(Icons.check_circle_outline, color: Colors.green),
//                           Text("  The order is Completed"),
//                         ],
//                       ),
//                     )
//                         : SizedBox(),
//
//                     order!['hire_status'] == 'rejected'
//                         ? Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Icon(Icons.block, color: Colors.red),
//                           Text("The order is rejected"),
//                         ],
//                       ),
//                     )
//                         : SizedBox(),
//
//                     order!['hire_status'] == 'accepted'
//                         ? const SizedBox(height: 20)
//                         : SizedBox(),
//                     if (providerslist.isEmpty &&
//                         order!['hire_status'] != 'accepted')
//                       const Center(
//                         child: Text(
//                           "No providers available",
//                           style: TextStyle(fontSize: 16, color: Colors.grey),
//                         ),
//                       )
//                     else if (order!['hire_status'] != 'accepted')
//                       ListView.builder(
//                         key: _listViewKey,
//                         // Attach GlobalKey to ListView.builder
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: providerslist.length,
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         itemBuilder: (context, index) {
//                           final worker = providerslist[index];
//                           final imageUrl =
//                               worker.hisWork.isNotEmpty
//                                   ? "https://api.thebharatworks.com/${worker.hisWork.first.replaceAll("\\", "/")}"
//                                   : null;
//
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 10),
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.1),
//                                   spreadRadius: 1,
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Center(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(8),
//                                     child:
//                                         imageUrl != null
//                                             ? Center(
//                                               child: Image.network(
//                                                 imageUrl,
//                                                 height: 120,
//                                                 width: 120,
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder:
//                                                     (context, error, stackTrace) =>
//                                                         const Icon(
//                                                           Icons.broken_image,
//                                                           size: 60,
//                                                         ),
//                                               ),
//                                             )
//                                             : Image.asset(
//                                               "assets/images/account1.png",
//                                               height: 80,
//                                               width: 80,
//                                               fit: BoxFit.cover,
//                                             ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const SizedBox(height: 10),
//                                       Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               worker.fullName ?? "Unknown",
//                                               style: GoogleFonts.roboto(
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 13,
//                                               ),
//                                             ),
//                                           ),
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.end,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     worker.rating
//                                                         .toStringAsFixed(1),
//                                                     style: GoogleFonts.roboto(
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                     ),
//                                                   ),
//                                                   const Icon(
//                                                     Icons.star,
//                                                     size: 18,
//                                                     color: Colors.yellow,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             "₹200.00",
//                                             style: GoogleFonts.roboto(
//                                               fontWeight: FontWeight.w500,
//                                               color: Colors.grey[700],
//                                               fontSize: 13,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 100),
//                                           GestureDetector(
//                                             onTap: () async {
//                                               final url =
//                                                   "https://api.thebharatworks.com/api/user/getServiceProvider/${worker.id}";
//                                               try {
//                                                 final prefs =
//                                                     await SharedPreferences.getInstance();
//                                                 final token = prefs.getString(
//                                                   'token',
//                                                 );
//                                                 if (token == null) {
//                                                   if (mounted &&
//                                                       _scaffoldMessenger !=
//                                                           null) {
//                                                     _scaffoldMessenger!
//                                                         .showSnackBar(
//                                                           const SnackBar(
//                                                             content: Text(
//                                                               "User not logged in.",
//                                                             ),
//                                                           ),
//                                                         );
//                                                   }
//                                                   return;
//                                                 }
//                                                 final response = await http.get(
//                                                   Uri.parse(url),
//                                                   headers: {
//                                                     'Content-Type':
//                                                         'application/json',
//                                                     'Authorization':
//                                                         'Bearer $token',
//                                                   },
//                                                 );
//                                                 if (response.statusCode ==
//                                                     200) {
//                                                   final data = jsonDecode(
//                                                     response.body,
//                                                   );
//                                                   if (mounted) {
//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder:
//                                                             (
//                                                               _,
//                                                             ) => ViewServiceProviderProfileScreen(
//                                                               serviceProviderId:
//                                                                   worker.id,
//                                                             ),
//                                                       ),
//                                                     );
//                                                   }
//                                                 } else {
//                                                   if (mounted &&
//                                                       _scaffoldMessenger !=
//                                                           null) {
//                                                     _scaffoldMessenger!
//                                                         .showSnackBar(
//                                                           SnackBar(
//                                                             content: Text(
//                                                               "Failed: ${response.statusCode}",
//                                                             ),
//                                                           ),
//                                                         );
//                                                   }
//                                                 }
//                                               } catch (e) {
//                                                 if (mounted &&
//                                                     _scaffoldMessenger !=
//                                                         null) {
//                                                   _scaffoldMessenger!
//                                                       .showSnackBar(
//                                                         SnackBar(
//                                                           content: Text(
//                                                             "Error: $e",
//                                                           ),
//                                                         ),
//                                                       );
//                                                 }
//                                               }
//                                             },
//                                             child: Padding(
//                                               padding: const EdgeInsets.only(
//                                                 top: 8.0,
//                                               ),
//                                               child: Text(
//                                                 'View Profile',
//                                                 style: GoogleFonts.roboto(
//                                                   fontSize: 11,
//                                                   color: Colors.green.shade700,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 2),
//                                       Text(
//                                         worker.skill ?? "No skill info",
//                                         // "sdafsdaf sdaf jksdfa sdfhasjh sdfjksdahjfsdjkafsd wequir sd saduirsasdauir  uiawersdguacbvsd ",
//                                         style: GoogleFonts.roboto(
//                                           fontSize: 11,
//                                           color: Colors.grey[700],
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       const SizedBox(height: 6),
//                                       Row(
//                                         children: [
//                                           Container(
//                                             width: 120,
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 18,
//                                               vertical: 4,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: const Color(0xFFF27773),
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             ),
//                                             child: Expanded(
//                                               child: Text(
//                                                 // worker.location ?? "No location",
//                                                 worker.location?['address'] ??
//                                                     "No address",
//                                                 style: GoogleFonts.roboto(
//                                                   color: Colors.white,
//                                                   fontSize: 11,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                                 maxLines: 1,
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 20),
//                                           ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor:
//                                                   Colors.green.shade700,
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 12,
//                                                     vertical: 4,
//                                                   ),
//                                               minimumSize: const Size(60, 28),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(6),
//                                               ),
//                                             ),
//                                             onPressed: () async {
//                                               if (order?['_id'] != null &&
//                                                   worker.id != null) {
//                                                 await sendNextOffer(
//                                                   order!['_id'],
//                                                   worker.id!,
//                                                 );
//                                               } else {
//                                                 if (mounted &&
//                                                     _scaffoldMessenger !=
//                                                         null) {
//                                                   _scaffoldMessenger!.showSnackBar(
//                                                     const SnackBar(
//                                                       content: Text(
//                                                         "Invalid order or provider ID",
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }
//                                               }
//                                             },
//                                             child: Text(
//                                               "Sent Offer",
//                                               style: GoogleFonts.roboto(
//                                                 fontSize: 12,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     order!['hire_status'] == 'accepted'
//                         ? SizedBox()
//                         : order!['hire_status'] == 'accepted'
//                         ? SizedBox()
//                         : const SizedBox(height: 10),
//                     // PaymentScreen(orderId: '',paymentHistory: [],),
//                     order!['hire_status'] == 'accepted'
//                         ? PaymentScreen(
//                           orderId: widget.id,
//                           orderProviderId: orderProviderId,
//                           paymentHistory:
//                               order!['service_payment']?['payment_history'],
//                         )
//                         : const SizedBox(),
//                   ],
//                 ),
//               ),
//     );
//   }
// }

/*
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/directHiring/views/User/viewServiceProviderProfile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/userModel/subCategoriesModel.dart';
import '../Account/service_provider_profile/ServiceProviderProfileScreen.dart';
import '../ServiceProvider/ViewWorkerScreen.dart';
import '../ServiceProvider/WorkerListViewProfileScreen.dart';
import '../comm/view_images_screen.dart';
import 'PaymentScreen.dart'; // Note: Typo in 'PatmentScreen', should be 'PaymentScreen'

class DirectViewScreen extends StatefulWidget {
  final String id;
  final String?
  categreyId; // Note: Typo in 'categreyId', consider renaming to 'categoryId'
  final String?
  subcategreyId; // Note: Typo in 'subcategreyId', consider renaming to 'subcategoryId'

  const DirectViewScreen({
    super.key,
    required this.id,
    this.categreyId,
    this.subcategreyId,
  });

  @override
  State<DirectViewScreen> createState() => _DirectViewScreenState();
}

class _DirectViewScreenState extends State<DirectViewScreen> {
  bool isLoading = true;
  Map<String, dynamic>? order;
  Map<String, dynamic>? providerDetail;
  List<ServiceProviderModel> providerslist = [];
  String? orderProviderId;
  ScaffoldMessengerState? _scaffoldMessenger;
  final ScrollController _scrollController =
  ScrollController(); // Add ScrollController
  final GlobalKey _listViewKey =
  GlobalKey(); // Add GlobalKey for ListView.builder

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _clearHiredProviders().then((_) => fetchOrderDetail());
    // _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   fetchOrderDetail();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchOrderDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print("Abhi:- fetchOrderDetail token: $token");
      print("Abhi:- fetchOrderDetail id ---> : ${widget.id}");

      final response = await http.get(
        Uri.parse(
          'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
          // 'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/6870d28ab1bd9d65afad055e',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("Abhi:- fetchOrderDetail response: ${response.body}");
        print(
          "Abhi:- Service Payment: ${decoded['data']['order']['service_payment']}",
        ); // Debugging
        String? providerId;
        if (decoded['data']?['order']?['offer_history'] != null &&
            (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
            decoded['data']['order']['offer_history'][0]['provider_id'] !=
                null) {
          providerId =
              decoded['data']['order']['offer_history'][0]['provider_id']['_id']
                  ?.toString();
          print("🚫 Order Provider ID set: $providerId");
        } else {
          print("⚠️ No provider_id found in offer_history");
        }
        setState(() {
          order = decoded['data']['order'];
          orderProviderId = providerId;
          isLoading = false;
        });

        if (providerId != null) {
          await _saveHiredProviderId(providerId);
          await fetchProviderById(providerId);
        }

        await fetchServiceProvidersListinWorkDetails(
          widget.categreyId ?? '68443fdbf03868e7d6b74874',
          widget.subcategreyId ?? '684e7226962b4919ae932af5',
        );
      } else {
        print(
          "❌ fetchOrderDetail failed: ${response.statusCode} - ${response.body}",
        );
        setState(() => isLoading = false);
        await fetchServiceProvidersListinWorkDetails(
          widget.categreyId ?? '68443fdbf03868e7d6b74874',
          widget.subcategreyId ?? '684e7226962b4919ae932af5',
        );
      }
    } catch (e) {
      print("❗ fetchOrderDetail Error: $e");
      setState(() => isLoading = false);
      await fetchServiceProvidersListinWorkDetails(
        widget.categreyId ?? '68443fdbf03868e7d6b74874',
        widget.subcategreyId ?? '684e7226962b4919ae932af5',
      );
    }
  }

  Future<void> cancelDarectOder() async {
    print("Abhi:- darect cancelOder order id ${widget.id}");

    final String url =
        '${AppConstants.baseUrl}${ApiEndpoint.darectCanceloffer}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- cancelOder token: $token");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // 👈 ye zaruri hai
        },
        body: jsonEncode({"order_id": widget.id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- darecthire cancelOder success :- ${response.body}");
        print(
          "Abhi:- darecthire cancelOder statusCode :- ${response.statusCode}",
        );
        Navigator.pop(context);
        _clearHiredProviders().then((_) => fetchOrderDetail());
      } else {
        print("Abhi:- else darect-hire cancelOder error :- ${response.body}");
        print(
          "Abhi:- else darect-hire cancelOder statusCode :- ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Abhi:- Exception darect-hire : - $e");
    }
  }

  Future<void> fetchProviderById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print("Abhi:- fetchproviderbyId providerId --> ${id}");

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
      } else {
        print("❌ Provider fetch failed: ${response.body}");
      }
    } catch (e) {
      print("❗ fetchProviderById Error: $e");
    }
  }

  Future<void> _saveHiredProviderId(String hiredId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiredIds = prefs.getStringList('hiredProviderIds') ?? [];
    if (!hiredIds.contains(hiredId)) {
      hiredIds.add(hiredId);
      await prefs.setStringList('hiredProviderIds', hiredIds);
      print("🚫 Saved Hired Provider ID: $hiredId");
      print("🚫 Current hiredProviderIds: $hiredIds");
    }
  }

  Future<void> _clearHiredProviders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hiredProviderIds');
    print("🗑️ Cleared hiredProviderIds");
    if (order != null &&
        order!['service_payment'] != null &&
        order!['service_payment']['payment_history']?.isNotEmpty == true) {
      try {
        final response = await http.post(
          Uri.parse(
            'https://api.razorpay.com/v1/payments/${order!['service_payment']['payment_history'][0]['payment_id']}/refund',
          ),
          headers: {
            'Authorization':
            'Basic ${base64Encode(utf8.encode('YOUR_RAZORPAY_KEY_ID:YOUR_RAZORPAY_KEY_SECRET'))}',
          },
        );
        print("📤 Refund API response: ${response.body}");
      } catch (e) {
        print("❗ Refund Error: $e");
      }
    }
  }

  Future<void> fetchServiceProvidersListinWorkDetails(
      String? categoryId,
      String? subCategoryId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
    print("🚫 Hired Provider IDs: $hiredProviderIds");
    print("🚫 Offer History: ${order?['offer_history']}");

    if (token == null) {
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(
          const SnackBar(content: Text("Pehle login kar bhai")),
        );
      }
      return;
    }

    final effectiveCategoryId = categoryId ?? '68443fdbf03868e7d6b74874';
    final effectiveSubCategoryId = subCategoryId ?? '684e7226962b4919ae932af5';
    print(
      "📌 Using categoryId: $effectiveCategoryId, subCategoryId: $effectiveSubCategoryId",
    );

    final uri = Uri.parse(
      'https://api.thebharatworks.com/api/user/getServiceProviders',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "category_id": effectiveCategoryId,
          "subcategory_id": effectiveSubCategoryId,
        }),
      );

      print(
        "📦 API Body Sent: ${json.encode({"category_id": effectiveCategoryId, "subcategory_id": effectiveSubCategoryId})}",
      );
      print(
        "📦 Abhi:- Status: ${response.statusCode}, Response: ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == true && data["data"] != null) {
          setState(() {
            providerslist =
                (data["data"] as List)
                    .map((json) {
                  final provider = ServiceProviderModel.fromJson(json);
                  print("🔍 Raw Provider Data: $json");
                  return provider;
                })
                    .where((provider) {
                  if (provider.id == null) {
                    print("🔍 Provider ID null hai: $provider");
                    return false;
                  }
                  bool isExcluded =
                      hiredProviderIds.contains(provider.id) ||
                          (order?['offer_history'] != null &&
                              (order!['offer_history'] as List).any((offer) {
                                String offerProviderId =
                                offer['provider_id'] is String
                                    ? offer['provider_id']
                                    : offer['provider_id']?['_id']
                                    ?.toString() ??
                                    '';
                                bool match = offerProviderId == provider.id;
                                print(
                                  "🔍 Checking Offer: $offerProviderId vs ${provider.id} => $match",
                                );
                                return match;
                              }));
                  print(
                    "🔍 Provider: ${provider.id}, Name: ${provider.fullName}, Chhupa?: $isExcluded",
                  );
                  return !isExcluded;
                })
                    .toList();
            print("✅ Providers loaded: ${providerslist.length}");
            print(
              "✅ Providers IDs: ${providerslist.map((p) => p.id).toList()}",
            );
          });
        } else {
          print("⚠️ No providers in API response");
          if (mounted && _scaffoldMessenger != null) {
            _scaffoldMessenger!.showSnackBar(
              const SnackBar(content: Text("Koi provider nahi mila")),
            );
          }
        }
      } else {
        print("❌ API Error: ${response.statusCode}");
        if (mounted && _scaffoldMessenger != null) {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(content: Text("Error ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      print("❗ Error: $e");
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> sendNextOffer(String orderId, String providerId) async {
    if (!mounted) {
      print("🚫 Widget not mounted. Exiting sendNextOffer.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];

    print("📌 Sending offer to provider ID: $providerId");
    print("🚫 Hired Provider IDs before sending offer: $hiredProviderIds");

    final alreadyOffered =
        hiredProviderIds.contains(providerId.trim()) ||
            (order != null &&
                order!['offer_history'] != null &&
                (order!['offer_history'] as List).any((offer) {
                  bool match = false;
                  if (offer['provider_id'] is String) {
                    match =
                        offer['provider_id'].toString().trim() == providerId.trim();
                  } else if (offer['provider_id'] is Map) {
                    match =
                        offer['provider_id']['_id'].toString().trim() ==
                            providerId.trim();
                  }
                  print("🧐 Offer history match check: $match | Offer: $offer");
                  return match;
                }));

    if (alreadyOffered) {
      print("⚠️ Provider has already been offered.");
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(
          const SnackBar(content: Text("Offer already sent to this provider")),
        );
      }
      return;
    }

    final uri = Uri.parse(
      'https://api.thebharatworks.com/api/direct-order/send-next-offer',
    );
    print("🌐 Sending POST request to: $uri");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_id': orderId,
          'next_provider_id': providerId,
        }),
      );

      print("📤 sendNextOffer Status: ${response.statusCode}");
      print("📤 sendNextOffer Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          await _saveHiredProviderId(providerId.trim());
          final updatedHiredIds = prefs.getStringList('hiredProviderIds') ?? [];
          print("✅ HiredProviderIds after saving: $updatedHiredIds");

          await prefs.setString(
            'category_id',
            widget.categreyId ?? '68443fdbf03868e7d6b74874',
          );
          await prefs.setString(
            'sub_category_id',
            widget.subcategreyId ?? '684e7226962b4919ae932af5',
          );

          if (mounted) {
            setState(() {
              providerslist.removeWhere((provider) {
                bool isRemoved = provider.id?.trim() == providerId.trim();
                print(
                  "🔍 Comparing: ${provider.id?.trim()} == ${providerId.trim()} => $isRemoved",
                );
                return isRemoved;
              });
              print(
                "📋 Updated providerslist: ${providerslist.map((p) => p.id).toList()}",
              );
            });

            await fetchServiceProvidersListinWorkDetails(
              widget.categreyId ?? '68443fdbf03868e7d6b74874',
              widget.subcategreyId ?? '684e7226962b4919ae932af5',
            );

            if (order != null) {
              setState(() {
                order!['offer_history'] = [
                  ...?order!['offer_history'],
                  {'provider_id': providerId.trim(), 'status': 'pending'},
                ];
              });
            }

            if (mounted && _scaffoldMessenger != null) {
              _scaffoldMessenger!.showSnackBar(
                const SnackBar(content: Text("Offer sent successfully")),
              );
            }
          }
        } else {
          print("❌ Send offer failed: ${data['message']}");
          if (mounted && _scaffoldMessenger != null) {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(content: Text("${data['message']}")),
            );
          }
        }
      } else {
        final err = json.decode(response.body);
        print("❗ API Error: ${response.statusCode} - ${err['message']}");
        if (mounted && _scaffoldMessenger != null) {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(
              content: Text("Error ${response.statusCode}: ${err['message']}"),
            ),
          );
        }
      }
    } catch (e) {
      print("❗ sendNextOffer Exception: $e");
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // Function to scroll to ListView.builder
  void _scrollToListView() {
    final RenderObject? renderObject =
    _listViewKey.currentContext?.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //    print("Abhi:- DirectViewscreen get categreyId new ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}");
    //    print("Abhi:- DirectViewscreen hire status---> ${ order?['hire_status']??""}");
    // // print("Abhi:- Oder id: ${order!['_id']?['service_payment']['payment_history']['amount'] ?? ""}");
    print("Abhi:- darect oder id ${widget.id}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? const Center(child: Text("No data found"))
          : SingleChildScrollView(
        controller: _scrollController, // Attach ScrollController
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Icon(Icons.arrow_back_outlined, size: 22),
                  ),
                ),
                const SizedBox(width: 90),
                Text(
                  "Work details",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            */
/*  if (order!['image_url'] != null &&
                        order!['image_url'] is List)
                      Image.network(
                        (order!['image_url'] as List).isNotEmpty
                            ? 'https://api.thebharatworks.com${(order!['image_url'] as List).first}'
                            : 'https://api.thebharatworks.com/uploads/directOrder/placeholder.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Image.asset(
                              'assets/images/task.png',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                      ),*//*

            if (order!['image_url'] != null &&
                order!['image_url'] is List &&
                (order!['image_url'] as List).isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ViewImage(
                        imageUrl:
                        'https://api.thebharatworks.com/uploads/hiswork/1752481481201.jpg${order!['image_url'] ?? ""}',
                      ),
                    ),
                  );
                },
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    autoPlayCurve: Curves.fastOutSlowIn,
                  ),
                  items:
                  (order!['image_url'] as List).map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          '$imageUrl',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                              Image.asset(
                                'assets/images/task.png',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                        );
                      },
                    );
                  }).toList(),
                ),
              )
            else
              Image.asset(
                'assets/images/task.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),


            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order!['title'] ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 24,
                        width: 160,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red,
                        ),
                        child: Expanded(
                          child: Text(
                            order!['address'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        "Posted: ${order!['createdAt']?.toString().substring(0, 10) ?? ''}",
                        style: GoogleFonts.roboto(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Completion: ${order!['deadline']?.toString().substring(0, 10) ?? ''}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Work title",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order!['description'] ??
                        "No description available.",
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            order!['hire_status'] == 'accepted'
                ? Center(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          // "assets/images/account1.png",
                          "${order!['service_provider_id']?['profile_pic'] ?? ''}",
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 56,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${order!['service_provider_id']?['full_name'] ?? ''}",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: const Icon(
                                    Icons.call,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Project Fees - ₹${order!['platform_fee'] ?? "200"}/-",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300,
                                  ),
                                  child: const Icon(
                                    Icons.message,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                        context,
                                        ) => ViewServiceProviderProfileScreen(
                                      serviceProviderId:
                                      order!['service_provider_id']?['_id'] ??
                                          '',
                                    ),
                                  ),
                                );
                              },
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "View Profile",
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w700,
                                  ),
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
            )
                : SizedBox(),
            // worker card
            order!['hire_status'] == 'accepted' && order!['assignedWorker'] != null && order!['assignedWorker'].isNotEmpty
                ? Center(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          order!['assignedWorker']?['image'] != null
                              ? "http://api.thebharatworks.com${order!['assignedWorker']['image']}"
                              : "https://api.thebharatworks.com/uploads/directOrder/placeholder.jpg",
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 56,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order!['assignedWorker']?['name'] ?? 'Unknown Worker',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),// state
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order!['assignedWorker']?['address'] ?? 'No address',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // const Spacer(),
                            SizedBox(height: 15,),
                            InkWell(
                              onTap: () {
                                if (order!['service_provider_id']?['_id'] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkerListViewProfileScreen(
                                        workerId: order!['assignedWorker']?['_id']??"",
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Provider ID not found"),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 30,
                                width: 120,
                                decoration: BoxDecoration(border: Border.all(color: Colors.green),borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: Text(
                                    "View Profile",
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w700,
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
                ),
              ),
            )
                : const SizedBox(),
            const SizedBox(height: 20),
            order!['hire_status'] == 'accepted'
                ? SizedBox()
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scrollToListView(); // Scroll to ListView on tap
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
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
                        child: Text(
                          "Offer sent",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        cancelDarectOder();
                        if (mounted && _scaffoldMessenger != null) {
                          _scaffoldMessenger!.showSnackBar(
                            const SnackBar(
                              content: Text("Order cancelled"),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            order!['hire_status'] == 'cancelled'
                ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.red),
                  Text("The order is Cancelled"),
                ],
              ),
            )
                : SizedBox(),

            order!['hire_status'] == 'completed'
                ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  Text("  The order is Completed"),
                ],
              ),
            )
                : SizedBox(),

            order!['hire_status'] == 'rejected'
                ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: Colors.red),
                  Text("The order is rejected"),
                ],
              ),
            )
                : SizedBox(),

            order!['hire_status'] == 'accepted'
                ? const SizedBox(height: 20)
                : SizedBox(),
            if (providerslist.isEmpty &&
                order!['hire_status'] != 'accepted')
              const Center(
                child: Text(
                  "No providers available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else if (order!['hire_status'] != 'accepted')
              ListView.builder(
                key: _listViewKey,
                // Attach GlobalKey to ListView.builder
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: providerslist.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final worker = providerslist[index];
                  final imageUrl =
                  worker.hisWork.isNotEmpty
                      ? "https://api.thebharatworks.com/${worker.hisWork.first.replaceAll("\\", "/")}"
                      : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                            imageUrl != null
                                ? Center(
                              child: Image.network(
                                imageUrl,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                ),
                              ),
                            )
                                : Image.asset(
                              "assets/images/account1.png",
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      worker.fullName ?? "Unknown",
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            worker.rating
                                                .toStringAsFixed(1),
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.yellow,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "₹200.00",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 100),
                                  GestureDetector(
                                    onTap: () async {
                                      final url =
                                          "https://api.thebharatworks.com/api/user/getServiceProvider/${worker.id}";
                                      try {
                                        final prefs =
                                        await SharedPreferences.getInstance();
                                        final token = prefs.getString(
                                          'token',
                                        );
                                        if (token == null) {
                                          if (mounted &&
                                              _scaffoldMessenger !=
                                                  null) {
                                            _scaffoldMessenger!
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "User not logged in.",
                                                ),
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                        final response = await http.get(
                                          Uri.parse(url),
                                          headers: {
                                            'Content-Type':
                                            'application/json',
                                            'Authorization':
                                            'Bearer $token',
                                          },
                                        );
                                        if (response.statusCode ==
                                            200) {
                                          final data = jsonDecode(
                                            response.body,
                                          );
                                          if (mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                    _,
                                                    ) => ViewServiceProviderProfileScreen(
                                                  serviceProviderId:
                                                  worker.id,
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (mounted &&
                                              _scaffoldMessenger !=
                                                  null) {
                                            _scaffoldMessenger!
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Failed: ${response.statusCode}",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted &&
                                            _scaffoldMessenger !=
                                                null) {
                                          _scaffoldMessenger!
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Error: $e",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: Text(
                                        'View Profile',
                                        style: GoogleFonts.roboto(
                                          fontSize: 11,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                worker.skill ?? "No skill info",
                                // "sdafsdaf sdaf jksdfa sdfhasjh sdfjksdahjfsdjkafsd wequir sd saduirsasdauir  uiawersdguacbvsd ",
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 120,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF27773),
                                      borderRadius:
                                      BorderRadius.circular(15),
                                    ),
                                    child: Expanded(
                                      child: Text(
                                        // worker.location ?? "No location",
                                        worker.location?['address'] ??
                                            "No address",
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Colors.green.shade700,
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      minimumSize: const Size(60, 28),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (order?['_id'] != null &&
                                          worker.id != null) {
                                        await sendNextOffer(
                                          order!['_id'],
                                          worker.id!,
                                        );
                                      } else {
                                        if (mounted &&
                                            _scaffoldMessenger !=
                                                null) {
                                          _scaffoldMessenger!.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Invalid order or provider ID",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Sent Offer",
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        color: Colors.white,
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
            order!['hire_status'] == 'accepted'
                ? SizedBox()
                : order!['hire_status'] == 'accepted'
                ? SizedBox()
                : const SizedBox(height: 10),
            // PaymentScreen(orderId: '',paymentHistory: [],),
            order!['hire_status'] == 'accepted'
                ? PaymentScreen(
              orderId: widget.id,
              orderProviderId: orderProviderId,
              paymentHistory:
              order!['service_payment']?['payment_history'],
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
*/

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/directHiring/views/User/viewServiceProviderProfile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/userModel/subCategoriesModel.dart';
import '../Account/service_provider_profile/ServiceProviderProfileScreen.dart';
import '../ServiceProvider/ViewWorkerScreen.dart';
import '../ServiceProvider/WorkerListViewProfileScreen.dart';
import '../comm/view_images_screen.dart';
import 'PaymentScreen.dart'; // Note: Typo in 'PatmentScreen', should be 'PaymentScreen'

class DirectViewScreen extends StatefulWidget {
  final String id;
  final String?
  categreyId; // Note: Typo in 'categreyId', consider renaming to 'categoryId'
  final String?
  subcategreyId; // Note: Typo in 'subcategreyId', consider renaming to 'subcategoryId'

  const DirectViewScreen({
    super.key,
    required this.id,
    this.categreyId,
    this.subcategreyId,
  });

  @override
  State<DirectViewScreen> createState() => _DirectViewScreenState();
}

class _DirectViewScreenState extends State<DirectViewScreen> {
  bool isLoading = true;
  Map<String, dynamic>? order;
  Map<String, dynamic>? providerDetail;
  List<ServiceProviderModel> providerslist = [];
  String? orderProviderId;
  ScaffoldMessengerState? _scaffoldMessenger;
  final ScrollController _scrollController =
  ScrollController(); // Add ScrollController
  final GlobalKey _listViewKey =
  GlobalKey(); // Add GlobalKey for ListView.builder

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _clearHiredProviders().then((_) => fetchOrderDetail());
    // _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   fetchOrderDetail();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchOrderDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print("Abhi:- fetchOrderDetail token: $token");
      print("Abhi:- fetchOrderDetail id ---> : ${widget.id}");

      final response = await http.get(
        Uri.parse(
          'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
          // 'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/6870d28ab1bd9d65afad055e',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("Abhi:- fetchOrderDetail response: ${response.body}");
        print(
          "Abhi:- Service Payment: ${decoded['data']['order']['service_payment']}",
        ); // Debugging
        String? providerId;
        if (decoded['data']?['order']?['offer_history'] != null &&
            (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
            decoded['data']['order']['offer_history'][0]['provider_id'] !=
                null) {
          providerId =
              decoded['data']['order']['offer_history'][0]['provider_id']['_id']
                  ?.toString();
          print("🚫 Order Provider ID set: $providerId");
        } else {
          print("⚠️ No provider_id found in offer_history");
        }
        setState(() {
          order = decoded['data']['order'];
          orderProviderId = providerId;
          isLoading = false;
        });

        if (providerId != null) {
          await _saveHiredProviderId(providerId);
          await fetchProviderById(providerId);
        }

        await fetchServiceProvidersListinWorkDetails(
          widget.categreyId ?? '68443fdbf03868e7d6b74874',
          widget.subcategreyId ?? '684e7226962b4919ae932af5',
        );
      } else {
        print(
          "❌ fetchOrderDetail failed: ${response.statusCode} - ${response.body}",
        );
        setState(() => isLoading = false);
        await fetchServiceProvidersListinWorkDetails(
          widget.categreyId ?? '68443fdbf03868e7d6b74874',
          widget.subcategreyId ?? '684e7226962b4919ae932af5',
        );
      }
    } catch (e) {
      print("❗ fetchOrderDetail Error: $e");
      setState(() => isLoading = false);
      await fetchServiceProvidersListinWorkDetails(
        widget.categreyId ?? '68443fdbf03868e7d6b74874',
        widget.subcategreyId ?? '684e7226962b4919ae932af5',
      );
    }
  }

  Future<void> cancelDarectOder() async {
    print("Abhi:- darect cancelOder order id ${widget.id}");

    final String url =
        '${AppConstants.baseUrl}${ApiEndpoint.darectCanceloffer}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- cancelOder token: $token");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // 👈 ye zaruri hai
        },
        body: jsonEncode({"order_id": widget.id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- darecthire cancelOder success :- ${response.body}");
        print(
          "Abhi:- darecthire cancelOder statusCode :- ${response.statusCode}",
        );
        Navigator.pop(context);
        _clearHiredProviders().then((_) => fetchOrderDetail());
      } else {
        print("Abhi:- else darect-hire cancelOder error :- ${response.body}");
        print(
          "Abhi:- else darect-hire cancelOder statusCode :- ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Abhi:- Exception darect-hire : - $e");
    }
  }

  Future<void> fetchProviderById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print("Abhi:- fetchproviderbyId providerId --> ${id}");

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
      } else {
        print("❌ Provider fetch failed: ${response.body}");
      }
    } catch (e) {
      print("❗ fetchProviderById Error: $e");
    }
  }

  Future<void> _saveHiredProviderId(String hiredId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiredIds = prefs.getStringList('hiredProviderIds') ?? [];
    if (!hiredIds.contains(hiredId)) {
      hiredIds.add(hiredId);
      await prefs.setStringList('hiredProviderIds', hiredIds);
      print("🚫 Saved Hired Provider ID: $hiredId");
      print("🚫 Current hiredProviderIds: $hiredIds");
    }
  }

  Future<void> _clearHiredProviders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hiredProviderIds');
    print("🗑️ Cleared hiredProviderIds");
    if (order != null &&
        order!['service_payment'] != null &&
        order!['service_payment']['payment_history']?.isNotEmpty == true) {
      try {
        final response = await http.post(
          Uri.parse(
            'https://api.razorpay.com/v1/payments/${order!['service_payment']['payment_history'][0]['payment_id']}/refund',
          ),
          headers: {
            'Authorization':
            'Basic ${base64Encode(utf8.encode('YOUR_RAZORPAY_KEY_ID:YOUR_RAZORPAY_KEY_SECRET'))}',
          },
        );
        print("📤 Refund API response: ${response.body}");
      } catch (e) {
        print("❗ Refund Error: $e");
      }
    }
  }

  Future<void> fetchServiceProvidersListinWorkDetails(
      String? categoryId,
      String? subCategoryId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
    print("🚫 Hired Provider IDs: $hiredProviderIds");
    print("🚫 Offer History: ${order?['offer_history']}");

    if (token == null) {
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(
          const SnackBar(content: Text("Pehle login kar bhai")),
        );
      }
      return;
    }

    final effectiveCategoryId = categoryId ?? '68443fdbf03868e7d6b74874';
    final effectiveSubCategoryId = subCategoryId ?? '684e7226962b4919ae932af5';
    print(
      "📌 Using categoryId: $effectiveCategoryId, subCategoryId: $effectiveSubCategoryId",
    );

    final uri = Uri.parse(
      'https://api.thebharatworks.com/api/user/getServiceProviders',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "category_id": effectiveCategoryId,
          "subcategory_id": effectiveSubCategoryId,
        }),
      );

      print(
        "📦 API Body Sent: ${json.encode({"category_id": effectiveCategoryId, "subcategory_id": effectiveSubCategoryId})}",
      );
      print(
        "📦 Abhi:- Status: ${response.statusCode}, Response: ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == true && data["data"] != null) {
          setState(() {
            providerslist =
                (data["data"] as List)
                    .map((json) {
                  final provider = ServiceProviderModel.fromJson(json);
                  print("🔍 Raw Provider Data: $json");
                  return provider;
                })
                    .where((provider) {
                  if (provider.id == null) {
                    print("🔍 Provider ID null hai: $provider");
                    return false;
                  }
                  bool isExcluded =
                      hiredProviderIds.contains(provider.id) ||
                          (order?['offer_history'] != null &&
                              (order!['offer_history'] as List).any((offer) {
                                String offerProviderId =
                                offer['provider_id'] is String
                                    ? offer['provider_id']
                                    : offer['provider_id']?['_id']
                                    ?.toString() ??
                                    '';
                                bool match = offerProviderId == provider.id;
                                print(
                                  "🔍 Checking Offer: $offerProviderId vs ${provider.id} => $match",
                                );
                                return match;
                              }));
                  print(
                    "🔍 Provider: ${provider.id}, Name: ${provider.fullName}, Chhupa?: $isExcluded",
                  );
                  return !isExcluded;
                })
                    .toList();
            print("✅ Providers loaded: ${providerslist.length}");
            print(
              "✅ Providers IDs: ${providerslist.map((p) => p.id).toList()}",
            );
          });
        } else {
          print("⚠️ No providers in API response");
          if (mounted && _scaffoldMessenger != null) {
            _scaffoldMessenger!.showSnackBar(
              const SnackBar(content: Text("Koi provider nahi mila")),
            );
          }
        }
      } else {
        print("❌ API Error: ${response.statusCode}");
        if (mounted && _scaffoldMessenger != null) {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(content: Text("Error ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      print("❗ Error: $e");
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> sendNextOffer(String orderId, String providerId) async {
    if (!mounted) {
      print("🚫 Widget not mounted. Exiting sendNextOffer.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];

    print("📌 Sending offer to provider ID: $providerId");
    print("🚫 Hired Provider IDs before sending offer: $hiredProviderIds");

    final alreadyOffered =
        hiredProviderIds.contains(providerId.trim()) ||
            (order != null &&
                order!['offer_history'] != null &&
                (order!['offer_history'] as List).any((offer) {
                  bool match = false;
                  if (offer['provider_id'] is String) {
                    match =
                        offer['provider_id'].toString().trim() == providerId.trim();
                  } else if (offer['provider_id'] is Map) {
                    match =
                        offer['provider_id']['_id'].toString().trim() ==
                            providerId.trim();
                  }
                  print("🧐 Offer history match check: $match | Offer: $offer");
                  return match;
                }));

    if (alreadyOffered) {
      print("⚠️ Provider has already been offered.");
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(
          const SnackBar(content: Text("Offer already sent to this provider")),
        );
      }
      return;
    }

    final uri = Uri.parse(
      'https://api.thebharatworks.com/api/direct-order/send-next-offer',
    );
    print("🌐 Sending POST request to: $uri");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_id': orderId,
          'next_provider_id': providerId,
        }),
      );

      print("📤 sendNextOffer Status: ${response.statusCode}");
      print("📤 sendNextOffer Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          await _saveHiredProviderId(providerId.trim());
          final updatedHiredIds = prefs.getStringList('hiredProviderIds') ?? [];
          print("✅ HiredProviderIds after saving: $updatedHiredIds");

          await prefs.setString(
            'category_id',
            widget.categreyId ?? '68443fdbf03868e7d6b74874',
          );
          await prefs.setString(
            'sub_category_id',
            widget.subcategreyId ?? '684e7226962b4919ae932af5',
          );

          if (mounted) {
            setState(() {
              providerslist.removeWhere((provider) {
                bool isRemoved = provider.id?.trim() == providerId.trim();
                print(
                  "🔍 Comparing: ${provider.id?.trim()} == ${providerId.trim()} => $isRemoved",
                );
                return isRemoved;
              });
              print(
                "📋 Updated providerslist: ${providerslist.map((p) => p.id).toList()}",
              );
            });

            await fetchServiceProvidersListinWorkDetails(
              widget.categreyId ?? '68443fdbf03868e7d6b74874',
              widget.subcategreyId ?? '684e7226962b4919ae932af5',
            );

            if (order != null) {
              setState(() {
                order!['offer_history'] = [
                  ...?order!['offer_history'],
                  {'provider_id': providerId.trim(), 'status': 'pending'},
                ];
              });
            }

            if (mounted && _scaffoldMessenger != null) {
              _scaffoldMessenger!.showSnackBar(
                const SnackBar(content: Text("Offer sent successfully")),
              );
            }
          }
        } else {
          print("❌ Send offer failed: ${data['message']}");
          if (mounted && _scaffoldMessenger != null) {
            _scaffoldMessenger!.showSnackBar(
              SnackBar(content: Text("${data['message']}")),
            );
          }
        }
      } else {
        final err = json.decode(response.body);
        print("❗ API Error: ${response.statusCode} - ${err['message']}");
        if (mounted && _scaffoldMessenger != null) {
          _scaffoldMessenger!.showSnackBar(
            SnackBar(
              content: Text("Error ${response.statusCode}: ${err['message']}"),
            ),
          );
        }
      }
    } catch (e) {
      print("❗ sendNextOffer Exception: $e");
      if (mounted && _scaffoldMessenger != null) {
        _scaffoldMessenger!.showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // Function to scroll to ListView.builder
  void _scrollToListView() {
    final RenderObject? renderObject =
    _listViewKey.currentContext?.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //    print("Abhi:- DirectViewscreen get categreyId new ${widget.categreyId} : subCategreyId : ${widget.subcategreyId}");
    //    print("Abhi:- DirectViewscreen hire status---> ${ order?['hire_status']??""}");
    // // print("Abhi:- Oder id: ${order!['_id']?['service_payment']['payment_history']['amount'] ?? ""}");
    print("Abhi:- darect oder id ${widget.id}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? const Center(child: Text("No data found"))
          : SingleChildScrollView(
        controller: _scrollController, // Attach ScrollController
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Icon(Icons.arrow_back_outlined, size: 22),
                  ),
                ),
                const SizedBox(width: 90),
                Text(
                  "Work details",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /*  if (order!['image_url'] != null &&
                        order!['image_url'] is List)
                      Image.network(
                        (order!['image_url'] as List).isNotEmpty
                            ? 'https://api.thebharatworks.com${(order!['image_url'] as List).first}'
                            : 'https://api.thebharatworks.com/uploads/directOrder/placeholder.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Image.asset(
                              'assets/images/task.png',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                      ),*/
            if (order!['image_url'] != null &&
                order!['image_url'] is List &&
                (order!['image_url'] as List).isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ViewImage(
                        imageUrl:
                        'https://api.thebharatworks.com/uploads/hiswork/1752481481201.jpg${order!['image_url'] ?? ""}',
                      ),
                    ),
                  );
                },
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    autoPlayCurve: Curves.fastOutSlowIn,
                  ),
                  items:
                  (order!['image_url'] as List).map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          '$imageUrl',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                              Image.asset(
                                'assets/images/task.png',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                        );
                      },
                    );
                  }).toList(),
                ),
              )
            else
              Image.asset(
                'assets/images/task.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),


            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order!['title'] ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 24,
                        width: 160,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red,
                        ),
                        child: Text(  // Removed Expanded here
                          order!['address'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "Posted: ${order!['createdAt']?.toString().substring(0, 10) ?? ''}",
                        style: GoogleFonts.roboto(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Completion: ${order!['deadline']?.toString().substring(0, 10) ?? ''}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Work title",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order!['description'] ??
                        "No description available.",
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            order!['hire_status'] == 'accepted'
                ? Center(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          // "assets/images/account1.png",
                          "${order!['service_provider_id']?['profile_pic'] ?? ''}",
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (
                              context,
                              error,
                              stackTrace,
                              ) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 56,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${order!['service_provider_id']?['full_name'] ?? ''}",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: const Icon(
                                    Icons.call,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Project Fees - ₹${order!['platform_fee'] ?? "200"}/-",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300,
                                  ),
                                  child: const Icon(
                                    Icons.message,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                        context,
                                        ) => ViewServiceProviderProfileScreen(
                                      serviceProviderId:
                                      order!['service_provider_id']?['_id'] ??
                                          '',
                                    ),
                                  ),
                                );
                              },
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "View Profile",
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w700,
                                  ),
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
            )
                : SizedBox(),
            // worker card
            order!['hire_status'] == 'accepted' && order!['assignedWorker'] != null && order!['assignedWorker'].isNotEmpty
                ? Center(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          order!['assignedWorker']?['image'] != null
                              ? "http://api.thebharatworks.com${order!['assignedWorker']['image']}"
                              : "https://api.thebharatworks.com/uploads/directOrder/placeholder.jpg",
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported_outlined,
                              size: 56,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order!['assignedWorker']?['name'] ?? 'Unknown Worker',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),// state
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order!['assignedWorker']?['address'] ?? 'No address',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // const Spacer(),
                            SizedBox(height: 15,),
                            InkWell(
                              onTap: () {
                                if (order!['service_provider_id']?['_id'] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkerListViewProfileScreen(
                                        workerId: order!['assignedWorker']?['_id']??"",
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Provider ID not found"),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 30,
                                width: 120,
                                decoration: BoxDecoration(border: Border.all(color: Colors.green),borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: Text(
                                    "View Profile",
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w700,
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
                ),
              ),
            )
                : const SizedBox(),
            const SizedBox(height: 20),
            order!['hire_status'] == 'accepted'
                ? SizedBox()
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scrollToListView(); // Scroll to ListView on tap
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
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
                        child: Text(
                          "Offer sent",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        cancelDarectOder();
                        if (mounted && _scaffoldMessenger != null) {
                          _scaffoldMessenger!.showSnackBar(
                            const SnackBar(
                              content: Text("Order cancelled"),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            order!['hire_status'] == 'cancelled'
                ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, color: Colors.red),
                  Text("The order is Cancelled"),
                ],
              ),
            )
                : SizedBox(),

            order!['hire_status'] == 'completed'
                ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  Text("  The order is Completed"),
                ],
              ),
            )
                : SizedBox(),

            order!['hire_status'] == 'rejected'
                ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: Colors.red),
                  Text("The order is rejected"),
                ],
              ),
            )
                : SizedBox(),

            order!['hire_status'] == 'accepted'
                ? const SizedBox(height: 20)
                : SizedBox(),
            if (providerslist.isEmpty &&
                order!['hire_status'] != 'accepted')
              const Center(
                child: Text(
                  "No providers available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else if (order!['hire_status'] != 'accepted')
              ListView.builder(
                key: _listViewKey,
                // Attach GlobalKey to ListView.builder
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: providerslist.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final worker = providerslist[index];
                  final imageUrl =
                  worker.hisWork.isNotEmpty
                      ? "https://api.thebharatworks.com/${worker.hisWork.first.replaceAll("\\", "/")}"
                      : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                            imageUrl != null
                                ? Center(
                              child: Image.network(
                                imageUrl,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                ),
                              ),
                            )
                                : Image.asset(
                              "assets/images/account1.png",
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      worker.fullName ?? "Unknown",
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            worker.rating
                                                .toStringAsFixed(1),
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.w700,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.yellow,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "₹200.00",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 100),
                                  GestureDetector(
                                    onTap: () async {
                                      final url =
                                          "https://api.thebharatworks.com/api/user/getServiceProvider/${worker.id}";
                                      try {
                                        final prefs =
                                        await SharedPreferences.getInstance();
                                        final token = prefs.getString(
                                          'token',
                                        );
                                        if (token == null) {
                                          if (mounted &&
                                              _scaffoldMessenger !=
                                                  null) {
                                            _scaffoldMessenger!
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "User not logged in.",
                                                ),
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                        final response = await http.get(
                                          Uri.parse(url),
                                          headers: {
                                            'Content-Type':
                                            'application/json',
                                            'Authorization':
                                            'Bearer $token',
                                          },
                                        );
                                        if (response.statusCode ==
                                            200) {
                                          final data = jsonDecode(
                                            response.body,
                                          );
                                          if (mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                    _,
                                                    ) => ViewServiceProviderProfileScreen(
                                                  serviceProviderId:
                                                  worker.id,
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (mounted &&
                                              _scaffoldMessenger !=
                                                  null) {
                                            _scaffoldMessenger!
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Failed: ${response.statusCode}",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted &&
                                            _scaffoldMessenger !=
                                                null) {
                                          _scaffoldMessenger!
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Error: $e",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      child: Text(
                                        'View Profile',
                                        style: GoogleFonts.roboto(
                                          fontSize: 11,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                worker.skill ?? "No skill info",
                                // "sdafsdaf sdaf jksdfa sdfhasjh sdfjksdahjfsdjkafsd wequir sd saduirsasdauir  uiawersdguacbvsd ",
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 120,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF27773),
                                      borderRadius:
                                      BorderRadius.circular(15),
                                    ),
                                    child: Text(  // Removed Expanded here
                                      worker.location?['address'] ??
                                          "No address",
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Colors.green.shade700,
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      minimumSize: const Size(60, 28),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (order?['_id'] != null &&
                                          worker.id != null) {
                                        await sendNextOffer(
                                          order!['_id'],
                                          worker.id!,
                                        );
                                      } else {
                                        if (mounted &&
                                            _scaffoldMessenger !=
                                                null) {
                                          _scaffoldMessenger!.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Invalid order or provider ID",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Sent Offer",
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        color: Colors.white,
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
            order!['hire_status'] == 'accepted'
                ? SizedBox()
                : order!['hire_status'] == 'accepted'
                ? SizedBox()
                : const SizedBox(height: 10),
            // PaymentScreen(orderId: '',paymentHistory: [],),
            order!['hire_status'] == 'accepted'
                ? PaymentScreen(
              orderId: widget.id,
              orderProviderId: orderProviderId,
              paymentHistory:
              order!['service_payment']?['payment_history'],
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}