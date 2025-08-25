import 'dart:convert';
import 'package:developer/Emergency/User/controllers/emergency_service_controller.dart';
import 'package:developer/Emergency/User/screens/work_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Bidding/view/user/buding_work_detail_screen.dart';
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

  int selectedTab = 0; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency

  @override
  void initState() {
    super.initState();
    _loadCategoryIdsAndFetchOrders();
    getEmergencyOrder();
    getBudingAllOders();
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
          bool matchesCategory = categoryId == null ||
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
          bool matchesSubCategory = subCategoryId == null ||
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

  var BudingData;
  Future<void> getBudingAllOders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        setState(() {
          BudingData = responseData;
        });
        print("Abhi:- getBudingAllOders data : ${responseData}");
        print("Abhi:- getBudingAllOders response : ${response.body}");
        print("Abhi:- getBudingAllOders response : ${response.statusCode}");
      } else {
        print("Abhi:- else getBudingAllOders response : ${response.body}");
        print(
            "Abhi:- else getBudingAllOders response : ${response.statusCode}");
      }
    } catch (e) {
      print("Abhi:- Exception $e");
    }
  }

  // Color _getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'cancelled':
  //       return Color(0xffDB5757);
  //
  //     case 'cancelleddispute':
  //       return Color(0xff9E9E9E);
  //     case 'accepted':
  //       return Color(0xff56DB56);
  //     case 'completed':
  //       return Color(0xff56DB56);
  //     case 'pending':
  //       return /*Colors.orange*/ Color(0xffFFC107);
  //     default:
  //       return Color(0xffDB5757);
  //   }
  // }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return const Color(0xFFFF3B30); // Vibrant Apple Red

      case 'cancelleddispute':
        return const Color(0xFF5D6D7E); // Steel Gray

      case 'accepted':
        return const Color(0xFF34C759); // Fresh Lime Green

      case 'completed':
        return const Color(0xFF0A84FF); // Premium Blue

      case 'pending':
        return const Color(0xFFFF9500); // Deep Amber Orange

      case 'review':
        return const Color(0xFFAF52DE); // Luxury Purple

      default:
        return const Color(0xFF8E8E93); // Neutral Gray
    }
  }


  @override
  Widget build(BuildContext context) {
    // print("Abhi:- print data in ui : ${BudingData}");
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
          const SizedBox(height: 12),
          Expanded(
            child: Builder(
              builder: (_) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (selectedTab == 0) {
                  return _buildBudingCard(BudingData);
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
          isLoading = true;
        });
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
        itemBuilder: (context, index) =>
            _buildEmergencyCard(emergencyOrders!.data[index]),
      ),
    );
  }

  Widget _buildBudingCard(dynamic BudingData) {
    // Null check for BudingData
    if (BudingData == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
    }

    final List dataList = BudingData['data'] ?? [];
    // print("Abhi:- get bidding oderId : ${BudingData['data'] }");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                prefixIcon: Icon(Icons.search),
                hintText: "Search for services",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Check if dataList is empty
            if (dataList.isEmpty)
              Center(
                child: Text(
                  "No bidding tasks found",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              )
            else
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  final item = dataList[index];

                  final title = item['category_id']?['name'] ?? "No Title";
                  final price = item['service_payment']?['amount']?.toString() ?? "0";
                  final buddingOderId = item['_id'] ?? "0";
                  final address = item['google_address'] ?? "No Address";
                  final status = item['hire_status'] ?? "No Status";
                  final deadline = item['deadline']?.toString() ?? "";
                  final imageUrl = (item['image_urls'] != null && item['image_urls'].isNotEmpty)
                      ? item['image_urls'][0]
                      : "";
                  print("Abhi:- get bidding oderId : ${buddingOderId }");

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green, width: 1),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // left image
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                                  : /*Image.asset(
                              "assets/images/Work.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),*/
                              Icon(Icons.image_not_supported_outlined,size: 100,)
                          ),
                          SizedBox(width: 10),
                          // right content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "₹$price",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  address,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Date: $deadline",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        "$status",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        address,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      width: 110,
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BiddingWorkerDetailScreen(
                                              buddingOderId: buddingOderId,
                                            ),
                                          ),
                                        );

                                        if (result == true) {
                                          // 👈 refresh function call kar do
                                          _loadCategoryIdsAndFetchOrders();
                                          getEmergencyOrder();
                                          getBudingAllOders();
                                          setState(() {});
                                        }
                                      },


                                      //                   _loadCategoryIdsAndFetchOrders();
                                      //                   getEmergencyOrder();
                                      //                    getBudingAllOders();
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          "View Details",
                                          style: TextStyle(
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
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildHireCard(DirectOrder data) {
    String displayStatus = data.status;
    if (data.offer_history != null &&
        data.offer_history!.isNotEmpty &&
        data.status != 'cancelled' &&
        data.status != 'completed') {
      displayStatus = data.offer_history!.last.status ?? data.status;
    }

    // Use the first image from image_url directly
    final String? imageshow = data.image; // This is already the first image URL

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        border: Border.all(
          color: AppColors.primaryGreen,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side image
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageshow != null && imageshow.isNotEmpty
                  ? Image.network(
                imageshow,
                height: 180,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/task.png',
                  height: 180,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              )
                  : Image.asset(
                'assets/images/task.png',
                height: 180,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right side content (unchanged)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + chat button
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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      child: SvgPicture.asset(
                        "assets/svg_images/chat.svg",
                        height: 18,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                // description
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.description,
                        style: _cardBody(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      child: SvgPicture.asset(
                        "assets/svg_images/call.svg",
                        height: 18,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                // date + call button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ${data.date}",
                      style: _cardDate(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      height: 25,
                      width: 78,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: const Text(
                          "Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // status
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 25,
                    width: 79,
                    decoration: BoxDecoration(
                      color: _getStatusColor(displayStatus),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        displayStatus.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // address + button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffF27773),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data.address ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                          const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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

  Widget _buildEmergencyCard(data) {
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
                    if (loadingProgress == null) return child;
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
                      Image.asset('assets/images/task.png',
                          height: 150, width: 110, fit: BoxFit.cover),
                )
                    : Image.asset('assets/images/task.png',
                    height: 150, width: 110, fit: BoxFit.cover),
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
                  "₹${data.servicePayment.amount} " ?? "0",
                  style: _cardBody().copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold),
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
                      child: Text(
                        data.subCategoryIds.isNotEmpty
                            ? data.subCategoryIds
                            .take(2)
                            .map((e) => e.name)
                            .join(", ")
                            : "",
                        style: _cardDate(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${data.deadline != null ? DateFormat('dd/MM/yyyy').format(data.deadline!.toLocal()) : 'N/A'}",
                        style: _cardDate(),
                      ),
                    ),
                    const SizedBox(width: 8),

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
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xffF27773),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data.googleAddress,
                          maxLines: 1, //
                          overflow: TextOverflow.ellipsis, // ... lag jayega
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // thoda gap de diya
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => WorkDetailPage(
                                data.id,
                                isUser: true,
                              )),
                        ).then(
                              (_) async {
                            final orders = await EmergencyServiceController()
                                .getEmergencyOrder();
                            setState(() {
                              emergencyOrders = orders;
                            });
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(70, 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 12),
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
