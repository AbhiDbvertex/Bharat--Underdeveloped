
import 'dart:convert';
import 'package:developer/Emergency/User/controllers/emergency_service_controller.dart';
import 'package:developer/Emergency/User/screens/work_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Emergency/User/models/emergency_list_model.dart';
import '../../../Widgets/AppColors.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/ServiceProviderModel/DirectOrder.dart';
import 'DirecrViewScreen.dart';

class MyHireScreen extends StatefulWidget {
  final String? categreyId;
  final String? subcategreyId;

  const MyHireScreen({super.key, this.categreyId, this.subcategreyId});

  @override
  State<MyHireScreen> createState() => _MyHireScreenState();
}

class _MyHireScreenState extends State<MyHireScreen> {
  EmergencyListModel? emergencyOrders;
  bool isLoading = false;
  List<DirectOrder> orders = [];

  String? categoryId;
  String? subCategoryId;

  int selectedTab = 1; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency

  @override
  void initState() {
    super.initState();
    _loadCategoryIdsAndFetchOrders();
    getEmergencyOrder();

  }
  getEmergencyOrder() async {
    await EmergencyServiceController().getEmergencyOrder();
  }
  Future<void> _loadCategoryIdsAndFetchOrders() async {
    final prefs = await SharedPreferences.getInstance();

    // Use widget.categreyId/subcategreyId if available, else fallback to SharedPreferences or null
    categoryId = widget.categreyId ?? prefs.getString('category_id') ?? null;
    subCategoryId =
        widget.subcategreyId ?? prefs.getString('sub_category_id') ?? null;

    print("✅ MyHireScreen using categoryId: $categoryId");
    print("✅ MyHireScreen using subCategoryId: $subCategoryId");

    fetchDirectOrders();
  }

  Future<void> fetchDirectOrders() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoint.MyHireScreen}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("🔁 API URL: ${AppConstants.baseUrl}${ApiEndpoint.MyHireScreen}");
      print("anjali API Response: ${res.body}");

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final List<dynamic> data = decoded['data'] ?? [];

        print("🔍 Total Orders in Response: ${data.length}");
        print("🔍 Raw Orders Data: $data");

        List<dynamic> filteredOrders = [];

        for (var order in data) {
          print("🔍 Processing Order: ${order['_id']}");

          // Check category and subcategory, bypass if categoryId/subCategoryId is null
          bool matchesCategory =
              categoryId == null ||
                  (order['category_id'] != null &&
                      order['category_id'] == categoryId) ||
                  (order['offer_history'] != null &&
                      (order['offer_history'] as List).any(
                            (offer) =>
                        offer['provider_id'] is Map &&
                            offer['provider_id']['category_id'] is Map &&
                            offer['provider_id']['category_id']['_id'] ==
                                categoryId,
                      ));
          bool matchesSubCategory =
              subCategoryId == null ||
                  (order['subcategory_id'] != null &&
                      order['subcategory_id'] == subCategoryId) ||
                  (order['offer_history'] != null &&
                      (order['offer_history'] as List).any(
                            (offer) =>
                        offer['provider_id'] is Map &&
                            offer['provider_id']['subcategory_ids'] is List &&
                            (offer['provider_id']['subcategory_ids'] as List).any(
                                  (sub) => sub['_id'] == subCategoryId,
                            ),
                      ));

          print(
            "🔍 Order Category: ${order['category_id']}, Matches: $matchesCategory",
          );
          print(
            "🔍 Order SubCategory: ${order['subcategory_id']}, Matches: $matchesSubCategory",
          );

          if (order['offer_history'] != null &&
              (order['offer_history'] as List).isNotEmpty) {
            // Include all offers regardless of status
            List<dynamic> validOffers = order['offer_history'] as List;

            print("🔍 All Offers for Order ${order['_id']}: $validOffers");

            if (validOffers.isNotEmpty &&
                matchesCategory &&
                matchesSubCategory) {
              order['offer_history'] = validOffers;
              filteredOrders.add(order);
              print("✅ Added Order to filteredOrders: ${order['_id']}");
            } else {
              print(
                "⚠️ No valid offers or category/subcategory mismatch for Order ${order['_id']}",
              );
            }
          } else {
            print("⚠️ No offer_history or empty for Order ${order['_id']}");
          }
        }

        setState(() {
          orders = filteredOrders.map((e) => DirectOrder.fromJson(e)).toList();
          print("✅ Final Orders Count: ${orders.length}");
          print("✅ Final Orders IDs: ${orders.map((o) => o.id).toList()}");
        });
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error ${res.statusCode}")));
        }
      }
    } catch (e) {
      print("❌ API Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return Color(0xffDB5757);

      case 'cancelleddispute':
        return Color(0xff9E9E9E);
      case 'accepted':
        return Color(0xff56DB56);
      case 'completed':
        return Color(0xff56DB56);
      case 'pending':
        return /*Colors.orange*/Color(0xffFFC107);
      default:
        return Color(0xffDB5757);
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
                "My Hire",
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
          const SizedBox(height: 12),
          Expanded(
            child: Builder(
              builder: (_) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (selectedTab == 0) {
                  return const Center(child: Text("No Bidding Tasks Found"));
                } else if (selectedTab == 1) {
                  return _buildDirectHiringList();
                } else {
                  // return const Center(child: Text("No Emergency Tasks Found"));
                  return _buildEmergencyList();
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
      onPressed: () async {
        setState(() {
          selectedTab = tabIndex;
          isLoading =true;
        });
        // if (selectedTab == 2) {
        //   // ✅ Emergency tab select hone par call karo
        //    emergencyOrders=  await EmergencyServiceController().getEmergencyOrder();
        //   if(emergencyOrders != null) {
        //     bwDebug("Total orders: ${emergencyOrders?.data.length}",tag:"myHireScreen 1");
        //   }else{
        //     bwDebug("else call for emergency : ",tag: "MyHireScreen");
        //   }
        // }
        if (selectedTab == 2) {
          final orders = await EmergencyServiceController().getEmergencyOrder();
          setState(() {
            emergencyOrders = orders;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
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
    if (orders.isEmpty) {
      return const Center(child: Text("No Direct Hiring Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildHireCard(orders[index]),
      ),
    );
  }
  Widget _buildEmergencyList() {
    if (emergencyOrders == null || emergencyOrders!.data.isEmpty) {
      return const Center(child: Text("No Emergency Orders Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: emergencyOrders!.data.length,
        itemBuilder: (context, index) => _buildEmergencyCard(emergencyOrders!.data[index]),
      ),
    );
  }
/*
  Widget _buildHireCard(DirectOrder data) {
    String displayStatus = data.status;
    if (data.offer_history != null &&
        data.offer_history!.isNotEmpty &&
        data.status != 'cancelled' &&
        data.status != 'completed') {
      displayStatus = data.offer_history!.last.status ?? data.status;
    }

    // Check if image field is not empty
    final bool hasImage = data.image.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(
          color: AppColors.primaryGreen, // <-- primary color border
          width: 1.5, // thickness
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
            hasImage
                ? Image.network(
              data.offer_history, // Use data.image directly
              height: 200,
              width: 110,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Image.asset(
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
                        horizontal: 5,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(displayStatus),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        displayStatus.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DirectViewScreen(
                              id: data.id,
                              categreyId:
                              categoryId ?? '68443fdbf03868e7d6b74874',
                              subcategreyId:
                              subCategoryId ??
                                  '684e7226962b4919ae932af5',
                            ),
                          ),
                        ).then((_) {
                          // Refresh orders after returning from DirectViewScreen
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
  }*/

  // Widget _buildHireCard(DirectOrder data) {
  //   String displayStatus = data.status;
  //   if (data.offer_history != null &&
  //       data.offer_history!.isNotEmpty &&
  //       data.status != 'cancelled' &&
  //       data.status != 'completed') {
  //     displayStatus = data.offer_history!.last.status ?? data.status;
  //   }
  //
  //   // Check if provider image exists
  //   final String? imageUrl = (data.offer_history != null &&
  //       data.offer_history!.isNotEmpty &&
  //       data.offer_history!.first.provider_id?.profile_pic != null)
  //       ? data.offer_history!.first.provider_id!.profile_pic
  //       : null;
  //
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //       boxShadow: const [
  //         BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
  //       ],
  //       border: Border.all(
  //         color: AppColors.primaryGreen,
  //         width: 1.5,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(8),
  //           child: imageUrl != null
  //               ? Image.network(
  //             imageUrl,
  //             height: 110,
  //             width: 110,
  //             fit: BoxFit.cover,
  //             errorBuilder: (context, error, stackTrace) =>
  //                 Image.asset(
  //                   'assets/images/task.png',
  //                   height: 110,
  //                   width: 110,
  //                   fit: BoxFit.cover,
  //                 ),
  //           )
  //               : Image.asset(
  //             'assets/images/task.png',
  //             height: 110,
  //             width: 110,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 data.title,
  //                 style: _cardTitle(),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               const SizedBox(height: 4),
  //               // Text(
  //               //   data.description,
  //               //   style: _cardBody(),
  //               //   maxLines: 2,
  //               //   overflow: TextOverflow.ellipsis,
  //               // ),
  //               const SizedBox(height: 4),
  //               // Text("Posted Date: ${data.date}", style: _cardDate()),
  //               const SizedBox(height: 6),
  //               Row(
  //                 children: [
  //                   Container(
  //
  //                       child: Text("Date: ${data.date}", style: _cardDate(),overflow: TextOverflow.ellipsis,maxLines: 1,),width: 90,),
  //                   const Spacer(),
  //                   Column(
  //                     // mainAxisAlignment: MainAxisAlignment.start,
  //                     // crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Align(
  //                             alignment: Alignment.topLeft,
  //                             child: Text(
  //                               data.description,
  //                               style: _cardBody(),
  //                               maxLines: 2,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                           Container(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 5,
  //                               vertical: 5,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               color: _getStatusColor(displayStatus),
  //                               borderRadius: BorderRadius.circular(6),
  //                             ),
  //                             child: Text(
  //                               displayStatus.toUpperCase(),
  //                               overflow: TextOverflow.ellipsis,
  //                               style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 12,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       TextButton(
  //                         onPressed: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (_) => DirectViewScreen(
  //                                 id: data.id,
  //                                 categreyId: categoryId ?? '68443fdbf03868e7d6b74874',
  //                                 subcategreyId: subCategoryId ??
  //                                     '684e7226962b4919ae932af5',
  //                               ),
  //                             ),
  //                           ).then((_) {
  //                             fetchDirectOrders();
  //                           });
  //                         },
  //                         style: TextButton.styleFrom(
  //                           backgroundColor: Colors.green.shade700,
  //                           minimumSize: const Size(90, 36),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(6),
  //                           ),
  //                         ),
  //                         child: Text(
  //                           "View Details",
  //                           style: GoogleFonts.roboto(
  //                             color: Colors.white,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildHireCard(DirectOrder data) {
    String displayStatus = data.status;
    if (data.offer_history != null &&
        data.offer_history!.isNotEmpty &&
        data.status != 'cancelled' &&
        data.status != 'completed') {
      displayStatus = data.offer_history!.last.status ?? data.status;
    }

    // Check if provider image exists
    final String? imageUrl = (data.offer_history != null &&
        data.offer_history!.isNotEmpty &&
        data.offer_history!.first.provider_id?.profile_pic != null)
        ? data.offer_history!.first.provider_id!.profile_pic
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // left side image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
              imageUrl,
              height: 110,
              width: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/task.png',
                height: 160,
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

          // right side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: _cardTitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CircleAvatar(child:   SvgPicture.asset("assets/svg_images/chat.svg"),backgroundColor: Colors.grey.shade300,)
                  ],
                ),
                const SizedBox(height: 6),

                // date
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ${data.date}",
                      style: _cardDate(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    CircleAvatar(child:   SvgPicture.asset("assets/svg_images/call.svg"),backgroundColor: Colors.grey.shade300,)
                  ],
                ),
                const SizedBox(height: 6),

                // description + status row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // description left
                    Expanded(
                      child: Text(
                        data.description,
                        style: _cardBody(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 6),

                    // status right
                    Column(
                      children: [
                        Container(
                          width: 66,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // color: _getStatusColor(displayStatus),
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              "Review",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8,),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(displayStatus),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            displayStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // view details button aligned right
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xffF27773),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        data.address ?? "" ,
                        maxLines: 1, //
                        overflow: TextOverflow.ellipsis, // ... lag jayega
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),SizedBox(width: 5,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DirectViewScreen(
                              id: data.id,
                              categreyId: categoryId ?? '68443fdbf03868e7d6b74874',
                              subcategreyId:
                              subCategoryId ?? '684e7226962b4919ae932af5',
                            ),
                          ),
                        ).then((_) {
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



  Widget _buildEmergencyCard( data) {
    //   bwDebug("[_buildEmergencyCard] call ",tag:"myHireScreen ");

    String displayStatus = data.hireStatus ?? "pending";

    // Last accepted status check karna
    if (data.acceptedByProviders != null &&
        data.acceptedByProviders!.isNotEmpty &&
        displayStatus != 'cancelled' &&
        displayStatus != 'completed') {
      displayStatus = data.acceptedByProviders!.last.status ?? displayStatus;
    }

    // Image check
    final bool hasImage = data.imageUrls != null && data.imageUrls!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(
          color: AppColors.primaryGreen, // <-- primary color border
          width: 1.5, // thickness
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                hasImage
                    ? Image.network(
                  data.imageUrls!.first, // first image show karenge
                  height: 200,
                  width: 110,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if(loadingProgress ==null)return child;
                    return Container(
                      height: 200,
                      width: 110,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                        strokeWidth: 2.5,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/task.png', height: 150, width: 110, fit: BoxFit.cover),
                )
                    : Image.asset('assets/images/task.png', height: 150, width: 110, fit: BoxFit.cover),
                Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15), // corner circle
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      "${data.projectId ?? 'N/A'}", // product id
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.categoryId.name ?? "",
                  style: _cardTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "₹${data.servicePayment.amount} "??"0",
                  style: _cardBody().copyWith(color: AppColors.primaryGreen,fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                ),
                Container(
                  height: 1, // thickness
                  color: Colors.grey.shade200, // light color
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child:
                      Text(
                        data.subCategoryIds.isNotEmpty
                            ? data.subCategoryIds.take(2).map((e) => e.name).join(", ")
                            : "",
                        style: _cardDate(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    ),
                    const SizedBox(width: 8), // thoda gap de diya
                    TextButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => DirectViewScreen(
                        //       id: data.id ?? '',
                        //       categreyId: data.categoryId?._id ?? '',
                        //       subcategreyId: data.subCategoryIds != null && data.subCategoryIds!.isNotEmpty
                        //           ? data.subCategoryIds!.first._id!
                        //           : '',
                        //     ),
                        //   ),
                        // ).then((_) => fetchDirectOrders());
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xff353026),
                        minimumSize: const Size(70, 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Review",
                        style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child:
                      Text(
                        "Date: ${data.deadline != null
                            ? DateFormat('dd/MM/yyyy').format(data.deadline!.toLocal())
                            : 'N/A'}",
                        style: _cardDate(),
                      ),

                    ),
                    const SizedBox(width: 8), // thoda gap de diya
                    // TextButton(
                    //   onPressed: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     // MaterialPageRoute(
                    //     //   builder: (_) => DirectViewScreen(
                    //     //     id: data.id ?? '',
                    //     //     categreyId: data.categoryId?._id ?? '',
                    //     //     subcategreyId: data.subCategoryIds != null && data.subCategoryIds!.isNotEmpty
                    //     //         ? data.subCategoryIds!.first._id!
                    //     //         : '',
                    //     //   ),
                    //     // ),
                    //     // ).then((_) => fetchDirectOrders());
                    //   },
                    //   style: TextButton.styleFrom(
                    //     backgroundColor: _getStatusColor(data.hireStatus),
                    //     minimumSize: const Size(70, 10),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: Text(
                    //     "${data.hireStatus[0].toUpperCase()}${data.hireStatus.substring(1)}",
                    //     style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                    //   ),
                    // ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(data.hireStatus),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${data.hireStatus[0].toUpperCase()}${data.hireStatus.substring(1)}",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),




                const SizedBox(height: 6),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xffF27773),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data.googleAddress,
                          maxLines: 1, //
                          overflow: TextOverflow.ellipsis, // ... lag jayega
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // thoda gap de diya
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>WorkDetailPage(
                                  data, isUser: null,
                              )
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(70,20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                )

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
      GoogleFonts.roboto(fontSize: 11, color: Colors.grey[700]);
}
