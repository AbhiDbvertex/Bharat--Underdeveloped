import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:developer/Emergency/User/controllers/emergency_service_controller.dart';
import 'package:developer/Emergency/User/screens/work_detail.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Bidding/view/user/bidding_work_detail_screen.dart';
import '../../../Emergency/User/models/emergency_list_model.dart';
import '../../../Emergency/utils/map_launcher_lat_long.dart';
import '../../../Widgets/AppColors.dart';
import '../../../chat/APIServices.dart';
import '../../../chat/SocketService.dart';
import '../../../chat/chatScreen.dart';
import '../../../testingfile.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/ServiceProviderModel/DirectOrder.dart';
import 'DirecrViewScreen.dart';

class MyHireScreen extends StatefulWidget {
  final String? categreyId;
  final String? subcategreyId;
  final int? passIndex;

  const MyHireScreen({super.key, this.categreyId, this.subcategreyId, this.passIndex});

  @override
  State<MyHireScreen> createState() => _MyHireScreenState();
}

class _MyHireScreenState extends State<MyHireScreen> {
  EmergencyListModel? emergencyOrders;
  bool isLoading = false;
  List<DirectOrder> orders = [];
  bool _isChatLoading = false; // Add this as a field in your State class
  String? categoryId;
  String? subCategoryId;

  int selectedTab = 0; // 0 = Bidding, 1 = Direct Hiring, 2 = Emergency

  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredBiddingData = [];
  List<DirectOrder> filteredDirectOrders = [];
  List<dynamic> filteredEmergencyData = [];
  String searchQuery = '';

  /*@override
  void initState() {
    super.initState();
    // Set initial tab based on passIndex
    if (widget.passIndex == 1) {
      selectedTab = 1; // Set to Direct Hiring tab
    } else if(widget.passIndex == 2) {
      selectedTab = 2; // Default to Bidding tab
    }else {
      selectedTab = 0;
    }

    // Initialize data fetching
    _loadCategoryIdsAndFetchOrders();
    // Fetch data for the selected tab
    _fetchInitialData();

    // Add search listener
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
      _filterData();
    });
  }*/

  @override
  void initState() {
    super.initState();
    // Set initial tab based on passIndex
    print("Abhi:-get pass index in myhireScreen : ${widget.passIndex} ");
    if (widget.passIndex == 1) {
      selectedTab = 1; // Set to Direct Hiring tab
      print("✅ initState: passIndex == 1, selectedTab set to 1 (Direct Hiring)");
    } else if (widget.passIndex == 2) {
      selectedTab = 2; // Set to Emergency Tasks tab
      print("✅ initState: passIndex == 2, selectedTab set to 2 (Emergency Tasks)");
    } else {
      selectedTab = 0; // Default to Bidding tab
      print("✅ initState: passIndex == ${widget.passIndex}, selectedTab set to 0 (Bidding)");
    }

    // Force UI rebuild to ensure selectedTab is reflected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    // Initialize data fetching
    _loadCategoryIdsAndFetchOrders();
    // Fetch data for the selected tab
    _fetchInitialData();

    // Add search listener
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
      _filterData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*Future<void> _fetchInitialData() async {
    setState(() => isLoading = true);
    try {
      if (selectedTab == 0) {
        await getBudingAllOders();
      } else if (selectedTab == 1) {
        await fetchDirectOrders();
      } else if (selectedTab == 2) {
        final orders = await EmergencyServiceController().getEmergencyOrder();
        setState(() {
          emergencyOrders = orders;
        });
      }
    } catch (e) {
      print("Error fetching initial data for tab $selectedTab: $e");
      if (mounted) {
        CustomSnackBar.show(
          message: "Error fetching data",
          type: SnackBarType.error,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }*/

  Future<void> _fetchInitialData() async {
    setState(() => isLoading = true);
    try {
      if (selectedTab == 0) {
        print("🔍 Fetching Bidding Orders");
        await getBudingAllOders();
      } else if (selectedTab == 1) {
        print("🔍 Fetching Direct Orders");
        await fetchDirectOrders();
      } else if (selectedTab == 2) {
        print("🔍 Fetching Emergency Orders");
        final orders = await EmergencyServiceController().getEmergencyOrder();
        setState(() {
          emergencyOrders = orders;
        });
      }
    } catch (e) {
      print("❌ Error fetching initial data for tab $selectedTab: $e");
      if (mounted) {
        CustomSnackBar.show(
          message: "Error fetching data",
          type: SnackBarType.error,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> getEmergencyOrder() async {
    final orders = await EmergencyServiceController().getEmergencyOrder();
    setState(() {
      emergencyOrders = orders;
    });
  }

  // Future<void> _loadCategoryIdsAndFetchOrders() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   categoryId = widget.categreyId ?? prefs.getString('category_id') ?? null;
  //   subCategoryId = widget.subcategreyId ?? prefs.getString('sub_category_id') ?? null;
  //
  //   print("✅ MyHireScreen using categoryId: $categoryId");
  //   print("✅ MyHireScreen using subCategoryId: $subCategoryId");
  //
  //   // Fetch direct orders only if Direct Hiring tab is selected initially
  //   if (widget.passIndex == 1) {
  //     await fetchDirectOrders();
  //   } else if (widget.passIndex == 2){
  //     getEmergencyOrder();
  //   }
  // }

  Future<void> _loadCategoryIdsAndFetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    categoryId = widget.categreyId ?? prefs.getString('category_id') ?? null;
    subCategoryId = widget.subcategreyId ?? prefs.getString('sub_category_id') ?? null;

    print("✅ MyHireScreen using categoryId: $categoryId");
    print("✅ MyHireScreen using subCategoryId: $subCategoryId");

    // Fetch data based on passIndex
    if (widget.passIndex == 1) {
      print("🔍 Loading Direct Orders for passIndex 1");
      await fetchDirectOrders();
    } else if (widget.passIndex == 2) {
      print("🔍 Loading Emergency Orders for passIndex 2");
      await getEmergencyOrder();
    }
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

          bool matchesCategory = categoryId == null ||
              (order['category_id'] != null && order['category_id'] == categoryId) ||
              (order['offer_history'] != null &&
                  (order['offer_history'] as List).any(
                        (offer) =>
                    offer['provider_id'] is Map &&
                        offer['provider_id']['category_id'] is Map &&
                        offer['provider_id']['category_id']['_id'] == categoryId,
                  ));
          bool matchesSubCategory = subCategoryId == null ||
              (order['subcategory_id'] != null && order['subcategory_id'] == subCategoryId) ||
              (order['offer_history'] != null &&
                  (order['offer_history'] as List).any(
                        (offer) =>
                    offer['provider_id'] is Map &&
                        offer['provider_id']['subcategory_ids'] is List &&
                        (offer['provider_id']['subcategory_ids'] as List).any(
                              (sub) => sub['_id'] == subCategoryId,
                        ),
                  ));

          print("🔍 Order Category: ${order['category_id']}, Matches: $matchesCategory");
          print("🔍 Order SubCategory: ${order['subcategory_id']}, Matches: $matchesSubCategory");

          if (order['offer_history'] != null && (order['offer_history'] as List).isNotEmpty) {
            List<dynamic> validOffers = order['offer_history'] as List;
            print("🔍 All Offers for Order ${order['_id']}: $validOffers");

            if (validOffers.isNotEmpty && matchesCategory && matchesSubCategory) {
              order['offer_history'] = validOffers;
              filteredOrders.add(order);
              print("✅ Added Order to filteredOrders: ${order['_id']}");
            } else {
              print("⚠️ No valid offers or category/subcategory mismatch for Order ${order['_id']}");
            }
          } else {
            print("⚠️ No offer_history or empty for Order ${order['_id']}");
          }
        }

        setState(() {
          orders = filteredOrders.map((e) => DirectOrder.fromJson(e)).toList();
          print("✅ Final Orders Count: ${orders.length}");
          print("✅ Final Orders IDs: ${orders.map((o) => o.id).toList()}");
          _filterData();
        });
      } else {
        print("❌ API Error Status: ${res.statusCode}");
        if (mounted) {
          CustomSnackBar.show(
            message: "Error ${res.statusCode}, Something went wrong",
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      print("❌ API Exception: $e");
      if (mounted) {
        CustomSnackBar.show(
          message: "Error: Something went wrong",
          type: SnackBarType.error,
        );
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
        Uri.parse('https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        setState(() {
          BudingData = responseData;
          _filterData();
        });
        print("Abhi:- getBudingAllOders data: $responseData");
      } else {
        print("Abhi:- else getBudingAllOders response: ${response.body}");
        if (mounted) {
          CustomSnackBar.show(
            message: "Error fetching bidding orders",
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      print("Abhi:- Exception in getBudingAllOders: $e");
      if (mounted) {
        CustomSnackBar.show(
          message: "Error: Something went wrong",
          type: SnackBarType.error,
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return const Color(0xFFFF3B30);
      case 'cancelleddispute':
        return const Color(0xFFFF3B30);
      case 'accepted':
        return const Color(0xFF34C759);
      case 'completed':
        return const Color(0xFF0A84FF);
      case 'pending':
        return const Color(0xFFFF9500);
      case 'review':
        return const Color(0xFFAF52DE);
      default:
        return const Color(0xFF8d8E93);
    }
  }

  void _filterData() {
    setState(() {
      if (selectedTab == 0) {
        if (BudingData == null || BudingData['data'] == null) {
          filteredBiddingData = [];
        } else {
          filteredBiddingData = (BudingData['data'] as List).where((item) {
            final title = (item['title'] ?? '').toString().toLowerCase();
            final desc = (item['description'] ?? '').toString().toLowerCase();
            return title.contains(searchQuery) || desc.contains(searchQuery);
          }).toList();
        }
      } else if (selectedTab == 1) {
        filteredDirectOrders = orders.where((order) {
          final title = (order.title ?? '').toLowerCase();
          final desc = (order.description ?? '').toLowerCase();
          return title.contains(searchQuery) || desc.contains(searchQuery);
        }).toList();
      } else if (selectedTab == 2) {
        if (emergencyOrders == null || emergencyOrders!.data.isEmpty) {
          filteredEmergencyData = [];
        } else {
          filteredEmergencyData = emergencyOrders!.data.where((item) {
            final categoryName = (item.categoryId?.name ?? '').toLowerCase();
            return categoryName.contains(searchQuery);
          }).toList();
        }
      }
    });
  }

  /*@override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Hire",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: SizedBox(),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                hintText: selectedTab == 0
                    ? 'Search by name'
                    : selectedTab == 1
                    ? 'Search by name'
                    : 'Search by name',
                prefixIcon: Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
                _filterData();
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (selectedTab == 0) {
                  return _buildBiddingCard(BudingData);
                } else if (selectedTab == 1) {
                  return _buildDirectHiringList();
                } else {
                  return _buildEmergencyList();
                }
              },
            ),
          ),
        ],
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    print("🔍 Building UI, selectedTab: $selectedTab");

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Hire",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: SizedBox(),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                hintText: selectedTab == 0
                    ? 'Search by name'
                    : selectedTab == 1
                    ? 'Search by name'
                    : 'Search by name',
                prefixIcon: Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
                _filterData();
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                print("🔍 Rendering content for selectedTab: $selectedTab");
                if (selectedTab == 0) {
                  return _buildBiddingCard(BudingData);
                } else if (selectedTab == 1) {
                  return _buildDirectHiringList();
                } else {
                  return _buildEmergencyList();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTabButton(String title, int tabIndex) {
  //   final isSelected = selectedTab == tabIndex;
  //   return ElevatedButton(
  //     onPressed: () async {
  //       setState(() {
  //         selectedTab = tabIndex;
  //         isLoading = true;
  //         _searchController.clear();
  //         searchQuery = '';
  //         filteredBiddingData.clear();
  //         filteredDirectOrders.clear();
  //         filteredEmergencyData.clear();
  //       });
  //
  //       try {
  //         if (selectedTab == 0) {
  //           await getBudingAllOders();
  //         } else if (selectedTab == 1) {
  //           await fetchDirectOrders();
  //         } else if (selectedTab == 2) {
  //           final orders = await EmergencyServiceController().getEmergencyOrder();
  //           setState(() {
  //             emergencyOrders = orders;
  //           });
  //         }
  //       } catch (e) {
  //         print("Error refreshing data for tab $tabIndex: $e");
  //         if (mounted) {
  //           CustomSnackBar.show(
  //             message: "Error refreshing data",
  //             type: SnackBarType.error,
  //           );
  //         }
  //       } finally {
  //         setState(() {
  //           isLoading = false;
  //           _filterData();
  //         });
  //       }
  //     },
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: isSelected ? Colors.green.shade700 : Colors.green.shade100,
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //     ),
  //     child: Text(
  //       title,
  //       style: _tabText(color: isSelected ? Colors.white : Colors.black),
  //     ),
  //   );
  // }

  Widget _buildTabButton(String title, int tabIndex) {
    final isSelected = selectedTab == tabIndex;
    print("🔍 Building tab: $title, index: $tabIndex, isSelected: $isSelected, selectedTab: $selectedTab");
    return ElevatedButton(
      onPressed: () async {
        print("✅ Tab $tabIndex ($title) pressed, setting selectedTab to $tabIndex");
        setState(() {
          selectedTab = tabIndex;
          isLoading = true;
          _searchController.clear();
          searchQuery = '';
          filteredBiddingData.clear();
          filteredDirectOrders.clear();
          filteredEmergencyData.clear();
        });

        try {
          if (selectedTab == 0) {
            print("🔍 Fetching Bidding Orders for tab 0");
            await getBudingAllOders();
          } else if (selectedTab == 1) {
            print("🔍 Fetching Direct Orders for tab 1");
            await fetchDirectOrders();
          } else if (selectedTab == 2) {
            print("🔍 Fetching Emergency Orders for tab 2");
            final orders = await EmergencyServiceController().getEmergencyOrder();
            setState(() {
              emergencyOrders = orders;
            });
          }
        } catch (e) {
          print("❌ Error refreshing data for tab $tabIndex: $e");
          if (mounted) {
            CustomSnackBar.show(
              message: "Error refreshing data",
              type: SnackBarType.error,
            );
          }
        } finally {
          setState(() {
            isLoading = false;
            _filterData();
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green.shade700 : Colors.green.shade100,
        foregroundColor: isSelected ? Colors.white : Colors.black, // Ensure text/icon color contrast
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isSelected ? 4 : 0, // Optional: Add elevation for selected tab
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

/*  Widget _buildDirectHiringList() {
    List<DirectOrder> displayOrders = searchQuery.isEmpty ? orders : filteredDirectOrders;

    if (displayOrders.isEmpty) {
      return const Center(child: Text("No Direct Hiring Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: displayOrders.length,
        itemBuilder: (context, index) => _buildHireCard(displayOrders[index]),
      ),
    );
  }*/

  // _buildDirectHiringList function same rahega
  Widget _buildDirectHiringList() {
    List<DirectOrder> displayOrders =
    searchQuery.isEmpty ? orders : filteredDirectOrders;

    if (displayOrders.isEmpty) {
      return const Center(child: Text("No Direct Hiring Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: displayOrders.length,
        itemBuilder: (context, index) => _buildHireCard(displayOrders[index]),
      ),
    );
  }

  Widget _buildEmergencyList() {
    List<dynamic> displayEmergency = searchQuery.isEmpty
        ? (emergencyOrders?.data ?? [])
        : filteredEmergencyData;
    if (displayEmergency.isEmpty) {
      return const Center(child: Text("No Emergency Orders Found"));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: displayEmergency.length,
        itemBuilder: (context, index) => _buildEmergencyCard(displayEmergency[index]),
      ),
    );
  }

  Widget _buildBiddingCard(dynamic biddingData) {
    if (biddingData == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
    }

    final List dataList = searchQuery.isEmpty ? (biddingData['data'] ?? []) : filteredBiddingData;

    print("Abhi:- get bidding oderId : ${biddingData['data']}");

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (dataList.isEmpty)
              Center(
                child: Text(
                  searchQuery.isEmpty ? "No bidding tasks found!" : "No matching bidding tasks found!",
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

                  final category = item['category_id']?['name'] ?? "No Title";
                  final price = item['service_payment']?['amount']?.toString() ?? "0";
                  final buddingOderId = item['_id'] ?? "0";
                  final buddingprojectid = item['project_id'] ?? "0";
                  final address = item['google_address'] ?? "No Address";
                  final latitude = item['latitude'] ?? 0.0;
                  final longitude = item['longitude'] ?? 0.0;
                  final description = item['description'] ?? "No description";
                  final status = item['hire_status'] ?? "No Status";
                  final title = item['title'] ?? "No title";
                  final deadline = item['deadline']?.toString() ?? "";
                  final imageUrl = (item['image_url'] != null && item['image_url'].isNotEmpty)
                      ? item['image_url'][0]
                      : "";
                  var user = item?['user_id'];
                  var serviceProvider = item?['service_provider_id'];

                  String userId = "";
                  String serviceProviderId = "";

                  if (user is Map) {
                    userId = user['_id']?.toString() ?? "";
                  } else if (user is String) {
                    userId = user;
                  }

                  if (serviceProvider is Map) {
                    serviceProviderId = serviceProvider['_id']?.toString() ?? "";
                  } else if (serviceProvider is String) {
                    serviceProviderId = serviceProvider;
                  }

                  print("Abhi:- get bidding oderId : $buddingOderId");
                  print("Abhi:- get bidding oderId status : $status");
                  print("Abhi:- get bidding images : $imageUrl");
                  print("Abhi:- get bidding userId : $userId");

                  return Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green, width: 1.02),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 10, top: 5),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                                    child: Container(
                                      color: Colors.grey,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: imageUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                          imageUrl: 'https://api.thebharatworks.com/$imageUrl',
                                          height: 125,
                                          width: 100,
                                          placeholder: (context, url) => Container(
                                            height: 125,
                                            width: 100,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => const Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 100,
                                          ),
                                        )
                                            : const Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 7,
                                    left: 10,
                                    right: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          buddingprojectid,
                                          style: TextStyle(color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                  Text(
                                    address,
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
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
                                      InkWell(
                                        onTap: () {
                                          MapLauncher.openMap(
                                            latitude: latitude,
                                            longitude: longitude,
                                            address: address,
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            address,
                                            style: TextStyle(
                                              color: Colors.transparent,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          width: 110,
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BiddingWorkerDetailScreen(
                                                buddingOderId: buddingOderId,
                                                userId: userId,
                                                serviceProviderId: serviceProviderId,
                                              ),
                                            ),
                                          );

                                          if (result == true) {
                                            _loadCategoryIdsAndFetchOrders();
                                            getEmergencyOrder();
                                            getBudingAllOders();
                                            setState(() {});
                                          }
                                        },
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
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

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
          user['_id'] = getIdAsString(user['_id']);
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

  Future<void> _startOrFetchConversation(BuildContext context, String receiverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("Abhi:- Error: No token found");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No token found, please log in again')),
        );
        return;
      }

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

      if (currentChat == null) {
        print("Abhi:- No existing conversation, starting new with receiverId: $receiverId");
        currentChat = await ApiService.startConversation(userId, receiverId);
      }

      if (currentChat['members'].isNotEmpty && currentChat['members'][0] is String) {
        print("Abhi:- New conversation, fetching user details for members");
        final otherId = currentChat['members'].firstWhere((id) => id != userId);
        final otherUserData = await fetchUserById(otherId, token);
        final senderUserData = await fetchUserById(userId, token);
        currentChat['members'] = [senderUserData, otherUserData];
        print("Abhi:- Updated members with full details: ${currentChat['members']}");
      }

      final messages = await ApiService.fetchMessages(getIdAsString(currentChat['_id']));
      messages.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

      SocketService.connect(userId);
      final onlineUsers = <String>[];
      SocketService.listenOnlineUsers((users) {
        onlineUsers.clear();
        onlineUsers.addAll(users.map((u) => getIdAsString(u)));
      });

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

 /* Widget _buildHireCard(DirectOrder darectHiringData) {
    String displayStatus = darectHiringData.status;
    String displayProjectId = darectHiringData.projectid ?? "";

    String? firstProviderId = darectHiringData.offer_history?.isNotEmpty == true
        ? darectHiringData.offer_history!.first.provider_id?.id
        : null;
    String? firstProviderName = darectHiringData.offer_history?.isNotEmpty == true
        ? darectHiringData.offer_history!.first.provider_id?.full_name
        : null;
    String? firstProviderImage = darectHiringData.offer_history?.isNotEmpty == true
        ? darectHiringData.offer_history!.first.provider_id?.profile_pic
        : null;

    print("Abhi:- Provider ID: $firstProviderId");

    final String? imageshow = darectHiringData.image;
    print("Abhi:- get darect oder status : ${darectHiringData.status}");
    print("Abhi:- get darect oder displayProjectId : ${darectHiringData.projectid}");

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
          Center(
            child: Stack(
              children: [
                Container(
                  color: Colors.grey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageshow != null && imageshow.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: imageshow,
                      height: 180,
                      width: 100,
                      placeholder: (context, url) => Container(
                        height: 180,
                        width: 100,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
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
                Positioned(
                  bottom: 7,
                  left: 10,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        darectHiringData.projectid ?? "No data",
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        darectHiringData.title,
                        style: _cardTitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (displayStatus == 'accepted' || displayStatus == 'pending')
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        child: SvgPicture.asset(
                          "assets/svg_images/call.svg",
                          height: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        darectHiringData.address ?? "",
                        style: TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (displayStatus == 'accepted' || displayStatus == 'pending')
                      GestureDetector(
                        onTap: _isChatLoading
                            ? null  // Disable tap while loading
                            : () async {
                          final receiverId = firstProviderId != null ? firstProviderId.toString() : 'Unknown';
                          final fullName = firstProviderName ?? 'Unknown';
                          print("Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullName");

                          if (receiverId != 'Unknown' && receiverId.isNotEmpty) {
                            setState(() {
                              _isChatLoading = true;  // Disable button immediately
                            });
                            try {
                              await _startOrFetchConversation(context, receiverId);
                            } catch (e) {
                              print("Abhi:- Error starting conversation: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error starting chat')),
                              );
                            } finally {
                              if (mounted) {  // Check if widget is still mounted
                                setState(() {
                                  _isChatLoading = false;  // Re-enable button
                                });
                              }
                            }
                            // await _startOrFetchConversation(context, receiverId);
                          } else {
                            print("Abhi:- Error: Invalid receiver ID");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: Invalid receiver ID')),
                            );
                          }
                        },
                        child: *//*CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                          child: SvgPicture.asset(
                            "assets/svg_images/chat.svg",
                            height: 18,
                          ),
                        ),*//*
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _isChatLoading ? Colors.grey : Colors.grey[300],
                          child: _isChatLoading
                              ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          )
                              : Icon(
                            Icons.message,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ${darectHiringData.date}",
                      style: _cardDate(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 25,
                        width: 105,
                        decoration: BoxDecoration(
                          color: _getStatusColor(displayStatus),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            displayStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  darectHiringData.description,
                  style: TextStyle(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Icon(Icons.add, color: Colors.transparent)),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DirectViewScreen(
                                id: darectHiringData.id,
                                categreyId: categoryId ?? '68443fdbf03868e7d6b74874',
                                subcategreyId: subCategoryId ?? '684e7226962b4919ae932af5',
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

  Map<String, bool> _chatLoadingStates = {};

// _buildHireCard function mein changes
  Widget _buildHireCard(DirectOrder darectHiringData) {
    String displayStatus = darectHiringData.status;
    String displayProjectId = darectHiringData.projectid ?? "";

    String? firstProviderId = darectHiringData.offer_history?.isNotEmpty == true
        ? darectHiringData.offer_history!.first.provider_id?.id
        : null;
    String? firstProviderName = darectHiringData.offer_history?.isNotEmpty == true
        ? darectHiringData.offer_history!.first.provider_id?.full_name
        : null;
    String? firstProviderImage = darectHiringData.offer_history?.isNotEmpty == true
        ? darectHiringData.offer_history!.first.provider_id?.profile_pic
        : null;

    print("Abhi:- Provider ID: $firstProviderId");

    final String? imageshow = darectHiringData.image;
    print("Abhi:- get darect oder status : ${darectHiringData.status}");
    print("Abhi:- get darect oder displayProjectId : ${darectHiringData.projectid}");

    // Check if this specific card is loading
    bool isCardLoading = _chatLoadingStates[darectHiringData.id] ?? false;

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
          Center(
            child: Stack(
              children: [
                Container(
                  color: Colors.grey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageshow != null && imageshow.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: imageshow,
                      height: 180,
                      width: 100,
                      placeholder: (context, url) => Container(
                        height: 180,
                        width: 100,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
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
                Positioned(
                  bottom: 7,
                  left: 10,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        darectHiringData.projectid ?? "No data",
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        darectHiringData.title,
                        style: _cardTitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (displayStatus == 'accepted' || displayStatus == 'pending')
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        child: SvgPicture.asset(
                          "assets/svg_images/call.svg",
                          height: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        darectHiringData.address ?? "",
                        style: TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (displayStatus == 'accepted' || displayStatus == 'pending')
                      GestureDetector(
                        onTap: isCardLoading
                            ? null // Disable tap while loading
                            : () async {
                          final receiverId = firstProviderId != null
                              ? firstProviderId.toString()
                              : 'Unknown';
                          final fullName = firstProviderName ?? 'Unknown';
                          print(
                              "Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullName");

                          if (receiverId != 'Unknown' &&
                              receiverId.isNotEmpty) {
                            setState(() {
                              _chatLoadingStates[darectHiringData.id] =
                              true; // Set loading for this card only
                            });
                            try {
                              await _startOrFetchConversation(
                                  context, receiverId);
                            } catch (e) {
                              print("Abhi:- Error starting conversation: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error starting chat')),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _chatLoadingStates[darectHiringData.id] =
                                  false; // Reset loading for this card
                                });
                              }
                            }
                          } else {
                            print("Abhi:- Error: Invalid receiver ID");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: Invalid receiver ID')),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                          isCardLoading ? Colors.grey : Colors.grey[300],
                          child: isCardLoading
                              ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          )
                              : Icon(
                            Icons.message,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ${darectHiringData.date}",
                      style: _cardDate(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 25,
                        width: 105,
                        decoration: BoxDecoration(
                          color: _getStatusColor(displayStatus),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            displayStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  darectHiringData.description,
                  style: TextStyle(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Icon(Icons.add, color: Colors.transparent)),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DirectViewScreen(
                                id: darectHiringData.id,
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
    String displayStatus = data.hireStatus ?? "pending";

    if (data.acceptedByProviders != null &&
        data.acceptedByProviders!.isNotEmpty &&
        displayStatus != 'cancelled' &&
        displayStatus != 'completed') {
      displayStatus = data.acceptedByProviders!.last.status ?? displayStatus;
    }

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
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  hasImage
                      ? CachedNetworkImage(
                    imageUrl: data.imageUrls!.first,
                    height: 0.4.toWidthPercent(),
                    width: 0.25.toWidthPercent(),
                    placeholder: (context, url) => Container(
                      height: 0.4.toWidthPercent(),
                      width: 0.25.toWidthPercent(),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                        strokeWidth: 2.5,
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/task.png',
                      height: 150,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'assets/images/task.png',
                    height: 150,
                    width: 110,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 5,
                    left: 5,
                    right: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text(
                        "${data.projectId ?? 'N/A'}",
                        style: const TextStyle(
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
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${data.googleAddress}",
                  style: TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                ),
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.subCategoryIds.isNotEmpty
                            ? data.subCategoryIds.take(2).map((e) => e.name).join(", ")
                            : "",
                        style: _cardDate(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${data.deadline != null ? DateFormat('dd/MM/yyyy').format(data.deadline!.toLocal()) : 'N/A'}",
                        style: _cardDate(),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          bwDebug("on tap call: ");
                          final address = data.googleAddress;
                          bool success = await MapLauncher.openMap(
                            address: address,
                            latitude: data.latitude,
                            longitude: data.longitude,
                          );
                          if (!success) {
                            CustomSnackBar.show(
                              message: "Could not open the map",
                              type: SnackBarType.error,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            data.googleAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.transparent, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkDetailPage(
                              data.id,
                              isUser: true,
                            ),
                          ),
                        ).then((_) async {
                          final orders = await EmergencyServiceController().getEmergencyOrder();
                          setState(() {
                            emergencyOrders = orders;
                          });
                        });
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
                        style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
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
  TextStyle _cardTitle() => GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.bold);
  TextStyle _cardBody() => GoogleFonts.roboto(fontSize: 13);
  TextStyle _cardDate() => GoogleFonts.roboto(fontSize: 11, color: Colors.grey[700]);
}