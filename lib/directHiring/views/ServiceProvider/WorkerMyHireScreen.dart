
import 'dart:convert';

import 'package:developer/Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../Bidding/Models/bidding_order.dart';
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
            'https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
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
            biddingOrders = data.map((e) => BiddingOrder.fromJson(e)).toList();
            filteredBiddingOrders = biddingOrders;
          });
          print("✅ Bidding Orders Fetched: ${biddingOrders.length}");
          print(
              "Image URLs in Orders: ${biddingOrders.map((e) => e.imageUrls).toList()}");
        } else {
          print("❌ 'data' key missing or invalid: ${decoded['data']}");
          _showSnackBar("Bidding orders data not found!");
        }
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        _showSnackBar("Failed to fetch bidding orders: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: $e");
      _showSnackBar("Something went wrong: $e");
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
            filteredDirectOrders = directOrders;
          });
          print("✅ Direct Orders Fetched: ${directOrders.length}");
        } else {
          print("❌ 'data' key missing or invalid: ${decoded['data']}");
          _showSnackBar("Direct orders data not found!");
        }
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        _showSnackBar("Failed to fetch direct orders: ${res.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: $e");
      _showSnackBar("Something went wrong: $e");
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
    print("🎨 Checking status color for: $status");
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
        toolbarHeight: screenHeight * 0.05,
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
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),

                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: screenHeight * 0.07,
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
                          : _buildEmergencyTasksList(screenWidth, screenHeight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int tabIndex, double screenWidth) {
    final isSelected = selectedTab == tabIndex;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTab = tabIndex;
          _biddingSearchController.clear();
          _directSearchController.clear();
          _emergencySearchController.clear();
          filteredBiddingOrders = biddingOrders;
          filteredDirectOrders = directOrders;
          filteredEmergencyItems = emergencyItems;
        });
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
            fontSize: screenWidth * 0.03),
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

  Widget _buildEmergencyTasksList(double screenWidth, double screenHeight) {
    if (filteredEmergencyItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("No Emergency Tasks Found")),
      );
    }

    return Column(
      children: List.generate(
        filteredEmergencyItems.length,
        (index) => _buildBiddingCardForEmergency(
          filteredEmergencyItems[index],
          widget.categreyId,
          widget.subcategreyId,
          screenWidth,
          screenHeight,
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
    final bool hasProfilePic = data.user_id != null &&
        data.user_id!.profile_pic != null &&
        (data.user_id!.profile_pic?.isNotEmpty ?? false) &&
        data.user_id!.profile_pic != 'local';
    print("🛠 Building card for Order ID: ${data.id}, Status: ${data.status}");

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
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: hasProfilePic
                ? Image.network(
                    data.user_id!.profile_pic!,
                    height: screenHeight * 0.15,
                    width: screenWidth * 0.3,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/task.png',
                      height: screenHeight * 0.15,
                      width: screenWidth * 0.3,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/task.png',
                    height: screenHeight * 0.15,
                    width: screenWidth * 0.3,
                    fit: BoxFit.cover,
                  ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(data.status),
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.015),
                      ),
                      child: Text(
                        data.status.isEmpty
                            ? 'Pending'
                            : data.status[0].toUpperCase() +
                                data.status.substring(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
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
    print(
        "🛠 Building card for Task: ${data.title}, Status: ${data.hireStatus}");
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
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: Container(
              alignment: Alignment.topCenter,
              child: data.imageUrls.isNotEmpty
                  ? Image.network(
                      data.imageUrls.first,
                      height: screenHeight * 0.16,
                      width: screenWidth * 0.32,
                      fit: BoxFit.cover,
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
                    if (data.hireStatus != "")
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.05),
                        child: Container(
                          height: 25,
                          width: 80,
                          decoration: BoxDecoration(
                            color: _getStatusColor(data.hireStatus),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.015),
                          ),
                          child: Center(
                            child: Text(
                              data.hireStatus.isEmpty
                                  ? 'Pending'
                                  : data.hireStatus[0].toUpperCase() +
                                      data.hireStatus.substring(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03,
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
                    Container(
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
                    GestureDetector(
                      onTap: () {
                        print(
                            "🔍 Navigating to Biddingserviceproviderworkdetail for Task: ${data.title}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Biddingserviceproviderworkdetail(
                                orderId: data.id),
                          ),
                        ).then((_) {
                          print(
                              "🔄 Returned to WorkerMyHireScreen, refreshing bidding tasks");
                          fetchBiddingOrders();
                        });
                      },
                      child: Container(
                        height: 25,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.015),
                        ),
                        child: Center(
                          child: Text(
                            "View Details",
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
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

  Widget _buildBiddingCardForEmergency(
    Map<String, dynamic> data,
    String? categreyId,
    String? subcategreyId,
    double screenWidth,
    double screenHeight,
  ) {
    print(
        "🛠 Building card for Emergency Task: ${data['title']}, Status: ${data['status']}");

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
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: Container(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/chair.png',
                height: screenHeight * 0.16,
                width: screenWidth * 0.32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: _cardTitle(fontSize: screenWidth * 0.04),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  data['price'],
                  style: GoogleFonts.roboto(
                    fontSize: screenWidth * 0.035,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  data['desc'],
                  style: _cardBody(fontSize: screenWidth * 0.035),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ${data['date']}",
                      style: _cardDate(fontSize: screenWidth * 0.03),
                    ),
                    if (data['status'] != "")
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.05),
                        child: Container(
                          height: 25,
                          width: 80,
                          decoration: BoxDecoration(
                            color: _getStatusColor(data['status']),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.015),
                          ),
                          child: Center(
                            child: Text(
                              data['status'].isEmpty
                                  ? 'Pending'
                                  : data['status'][0].toUpperCase() +
                                      data['status'].substring(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03,
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
                    Container(
                      height: 20,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.red.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            data['address'],
                            style: GoogleFonts.roboto(
                              fontSize: screenWidth * 0.035,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print(
                            "🔍 Navigating to Biddingserviceproviderworkdetail for Task: ${data['title']}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Biddingserviceproviderworkdetail(
                                orderId: data['_id'] ?? ''),
                          ),
                        ).then((_) {
                          print(
                              "🔄 Returned to WorkerMyHireScreen, refreshing bidding tasks");
                          fetchBiddingOrders();
                        });
                      },
                      child: Container(
                        height: 25,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.015),
                        ),
                        child: Center(
                          child: Text(
                            "View Details",
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
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
