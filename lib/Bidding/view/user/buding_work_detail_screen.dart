
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting dates
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Widgets/AppColors.dart';
import '../../controller/bidding_postTask_controller.dart';
import 'bidding_worker_detail_edit_screen.dart';

class BiddingWorkerDetailScreen extends StatefulWidget {
  final String? buddingOderId; // Made type explicit
  const BiddingWorkerDetailScreen({super.key, this.buddingOderId});

  @override
  State<BiddingWorkerDetailScreen> createState() =>
      _BiddingWorkerDetailScreenState();
}

class _BiddingWorkerDetailScreenState extends State<BiddingWorkerDetailScreen> {
  bool isBiddersClicked = false;
  Map<String, dynamic>? getBuddingOderByIdResponseData;
  List<dynamic>? bidders; // Store bidders for the specific order
  List<dynamic>? relatedWorkers; // Store related workers
  bool isLoading = true; // To handle loading state

  @override
  void initState() {
    super.initState();
    getBuddingOderById();
    getAllBidders();
  }

  Future<void> getBuddingOderById() async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.buddingOderId}";
    print("Abhi:- getBuddingOderById url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);
      print("Abhi:- getBuddingOderById response: ${response.body}");
      print("Abhi:- getBuddingOderById status: ${response.statusCode}");
      print("Abhi:- getBuddingOderById responseData: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          print("Abhi:- getBuddingOderById error ${responseData['message'] ?? "Failed to fetch related workers."}");
          // Extract categoryId and subCategoryIds
          final categoryId = responseData['data']?['category_id']?['_id'] ?? '';
          final subCategoryIds = (responseData['data']?['sub_category_ids'] as List<dynamic>?)?.map((sub) => sub['_id'] as String).toList() ?? [];
          if (categoryId.isNotEmpty && subCategoryIds.isNotEmpty && !isBiddersClicked) {
            await getReletedWorker(categoryId, subCategoryIds);
          }
          setState(() {
            getBuddingOderByIdResponseData = responseData;
            isLoading = bidders == null && relatedWorkers == null; // Keep loading until all APIs complete
          });
        } else {
          print("Abhi:- getBuddingOderById error ${responseData['message'] ?? "Failed to fetch related workers."}");
          setState(() {
            isLoading = bidders == null && relatedWorkers == null; // Keep loading until all APIs complete
          });
        }
      } else {
        print("Abhi:- getBuddingOderById error ${responseData['message'] ?? "Failed to fetch related workers."}");
        setState(() {
          isLoading = bidders == null && relatedWorkers == null; // Keep loading until all APIs complete
        });
      }
    } catch (e) {
      print("Abhi:- getBuddingOderById Exception: $e");
      setState(() {
        isLoading = bidders == null && relatedWorkers == null; // Keep loading until all APIs complete
      });
    }
  }

  Future<void> getAllBidders() async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/apiGetAllBiddingOrders";
    print("Abhi:- getAllBidders url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);
      print("Abhi:- getAllBidders response: ${response.body}");
      print("Abhi:- getAllBidders status: ${response.statusCode}");
      print("Abhi:- getAllBidders responseData: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          print("Abhi:- getAllBidders error ${responseData['message'] ?? "Failed to fetch related workers."}");
          // Find the order matching buddingOderId and extract bidders
          final orders = responseData['data'] as List<dynamic>?;
          final matchingOrder = orders?.firstWhere(
                (order) => order['_id'] == widget.buddingOderId,
            orElse: () => null,
          );
          setState(() {
            bidders = matchingOrder != null ? (matchingOrder['bidders'] as List<dynamic>?) ?? [] : [];
            isLoading = getBuddingOderByIdResponseData == null && relatedWorkers == null; // Keep loading until all APIs complete
          });
        } else {
          print("Abhi:- getAllBidders error ${responseData['message'] ?? "Failed to fetch related workers."}");
          setState(() {
            bidders = [];
            isLoading = getBuddingOderByIdResponseData == null && relatedWorkers == null; // Keep loading until all APIs complete
          });
        }
      } else {
        print("Abhi:- getAllBidders error ${responseData['message'] ?? "Failed to fetch related workers."}");
        setState(() {
          bidders = [];
          isLoading = getBuddingOderByIdResponseData == null && relatedWorkers == null; // Keep loading until all APIs complete
        });
      }
    } catch (e) {
      print("Abhi:- getAllBidders Exception: $e");
      setState(() {
        bidders = [];
        isLoading = getBuddingOderByIdResponseData == null && relatedWorkers == null; // Keep loading until all APIs complete
      });
    }
  }

  Future<void> getReletedWorker(String categoryId, List<String> subCategoryIds) async {
    final String url = "https://api.thebharatworks.com/api/user/getServiceProviders";
    print("Abhi:- getReletedWorker url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "category_id": categoryId,
          "subcategory_ids": subCategoryIds,
        }),
      );

      var responseData = jsonDecode(response.body);
      print("Abhi:- getReletedWorker response: ${response.body}");
      print("Abhi:- getReletedWorker status: ${response.statusCode}");
      print("Abhi:- getReletedWorker responseData: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          print("Abhi:- getReletedworker error ${responseData['message'] ?? "Failed to fetch related workers."}");
          setState(() {
            relatedWorkers = responseData['data'] as List<dynamic>? ?? [];
            isLoading = getBuddingOderByIdResponseData == null && bidders == null;
          });
        } else {
          print("Abhi:- getReletedworker error ${responseData['message'] ?? "Failed to fetch related workers."}");
          Get.snackbar(
            "Error",
            responseData['message'] ?? "Failed to fetch related workers.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            margin: const EdgeInsets.all(10),
            borderRadius: 10,
            duration: const Duration(seconds: 3),
          );
          setState(() {
            relatedWorkers = [];
            isLoading = getBuddingOderByIdResponseData == null && bidders == null;
          });
        }
      } else {

        setState(() {
          relatedWorkers = [];
          isLoading = getBuddingOderByIdResponseData == null && bidders == null;
        });
      }
    } catch (e) {
      print("Abhi:- getReletedWorker Exception: $e");
      setState(() {
        relatedWorkers = [];
        isLoading = getBuddingOderByIdResponseData == null && bidders == null;
      });
    }
  }
  //    cancel Task

  Future<void> cancelTask () async {
    final String url = "https://api.thebharatworks.com/api/bidding-order/cancelBiddingOrder/${widget.buddingOderId}";
    print("Abhi:- Cancel task url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.put(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode ==200 || response.statusCode == 201 ) {
        print("Abhi:- Cancel task response ${response.body}");
        print("Abhi:- Cancel task response ${response.statusCode}");
        Navigator.pop(context, true);
      }else {
        print("Abhi:- Cancel task response else ${response.body}");
        print("Abhi:- Cancel task response else ${response.statusCode}");
      }

    } catch(e){print("Abhi:- Cancel task");}
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print("Abhi:- buddingOderId is: ${widget.buddingOderId}");

    // Extract data from getBuddingOderById API response
    final data = getBuddingOderByIdResponseData?['data'];
    final title = data?['title'] ?? 'N/A';
    final address = data?['address'] ?? 'N/A';
    final googleAddress = data?['google_address'] ?? 'N/A';
    final description = data?['description'] ?? 'N/A';
    final cost = data?['cost']?.toString() ?? '0';
    final deadline = data?['deadline'] != null
        ? DateFormat('dd/MM/yy').format(DateTime.parse(data['deadline']))
        : 'N/A';
    final categoryName = data?['category_id']?['name'] ?? 'N/A';
    final subCategories = (data?['sub_category_ids'] as List<dynamic>?)?.map((sub) => sub['name'] as String).toList() ?? [];
    final imageUrls = (data?['image_url'] as List<dynamic>?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.green.shade700,
        body: SafeArea(
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Icon(Icons.arrow_back_outlined, size: 22),
                        ),
                      ),
                      const SizedBox(width: 90),
                      Text(
                        'Worker details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: height * 0.25,
                      enlargeCenterPage: true,
                      autoPlay: imageUrls.isNotEmpty,
                      viewportFraction: 0.85,
                    ),
                    items: imageUrls.isNotEmpty
                        ? imageUrls.map((url) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(url.trim()),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) => Image.asset(
                            'assets/images/Bid.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )).toList()
                        : [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/Bid.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.025,
                          width: MediaQuery.of(context).size.width * 0.28,
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              address.split(',').last.trim(), // e.g., "Madhya Pradesh, India"
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.03,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.005),
                        Text(
                          address,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(height: height * 0.002),
                        Text(
                          "Complete - $deadline",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: height * 0.002),
                        Text(
                          "Title - $title",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            // color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: height * 0.005),
                        Text(
                          "₹$cost",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Task Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, size: 6),
                                SizedBox(width: width * 0.02),
                                Expanded(
                                  child: Text(
                                    "Description: $description",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> PostTaskEditScreen(biddingOderId: widget.buddingOderId,)));
                            // Get.snackbar(
                            //   "Info",
                            //   "Edit functionality not implemented yet.",
                            //   snackPosition: SnackPosition.BOTTOM,
                            //   backgroundColor: Colors.black,
                            //   colorText: Colors.white,
                            //   margin: const EdgeInsets.all(10),
                            //   borderRadius: 10,
                            //   duration: const Duration(seconds: 3),
                            // );
                          },
                          child: Container(
                            height: height * 0.045,
                            width: width * 0.40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green.shade700,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit, color: AppColors.primaryGreen, size: height * 0.024),
                                  SizedBox(width: width * 0.03),
                                  Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await cancelTask();
                            Get.back(result: true);
                          },
                          child: Container(
                            height: height * 0.045,
                            width: width * 0.40,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel_presentation_rounded, color: Colors.white),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    "Cancel Task",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Container(
                      height: height * 0.06,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search for services",
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: height * 0.015,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isBiddersClicked = true; // Bidders tab select
                                });
                              },
                              child: Container(
                                height: height * 0.045,
                                width: width * 0.40,
                                decoration: BoxDecoration(
                                  color: isBiddersClicked
                                      ? Colors.green.shade700
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: width * 0.02),
                                      Text(
                                        "Bidders",
                                        style: TextStyle(
                                          color: isBiddersClicked
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          fontSize: width * 0.05,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isBiddersClicked = false; // Related Worker tab select
                                  // Trigger getReletedWorker if categoryId and subCategoryIds are available
                                  final categoryId = getBuddingOderByIdResponseData?['data']?['category_id']?['_id'] ?? '';
                                  final subCategoryIds = (getBuddingOderByIdResponseData?['data']?['sub_category_ids'] as List<dynamic>?)?.map((sub) => sub['_id'] as String).toList() ?? [];
                                  if (categoryId.isNotEmpty && subCategoryIds.isNotEmpty) {
                                    getReletedWorker(categoryId, subCategoryIds);
                                  }
                                });
                              },
                              child: Container(
                                height: height * 0.045,
                                width: width * 0.40,
                                decoration: BoxDecoration(
                                  color: !isBiddersClicked
                                      ? Colors.green.shade700
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: width * 0.02),
                                      Text(
                                        "Related Worker",
                                        style: TextStyle(
                                          color: !isBiddersClicked
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isBiddersClicked)
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.01),
                            child: bidders == null || bidders!.isEmpty
                                ? Center(
                              child: SvgPicture.asset(
                                'assets/svg_images/nobidders.svg',
                                height: height * 0.33,
                              ),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: bidders!.length,
                              itemBuilder: (context, index) {
                                final bidder = bidders![index];
                                final fullName = bidder['full_name']?.toString() ?? 'N/A';
                                final rating = bidder['rating']?.toString() ?? '0';
                                final bidAmount = bidder['bid_amount']?.toString() ?? '0';
                                final location = bidder['location']?.toString() ?? 'N/A';
                                final profilePic = bidder['profile_pic']?.toString();

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: height * 0.01,
                                    horizontal: width * 0.01,
                                  ),
                                  padding: EdgeInsets.all(width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: profilePic != null && profilePic.isNotEmpty
                                            ? Image.network(
                                          profilePic,
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/images/account1.png',
                                            height: 90,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Image.asset(
                                          'assets/images/account1.png',
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    fullName,
                                                    style: TextStyle(
                                                      fontSize: width * 0.045,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      rating,
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      size: width * 0.04,
                                                      color: Colors.yellow.shade700,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "₹$bidAmount",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.10),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 13,
                                                            backgroundColor: Colors.grey.shade300,
                                                            child: Icon(
                                                              Icons.phone,
                                                              size: 18,
                                                              color: Colors.green.shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: height * 0.005),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    height: 22,
                                                    constraints: BoxConstraints(
                                                      maxWidth: width * 0.25,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade300,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        location,
                                                        style: TextStyle(
                                                          fontSize: width * 0.033,
                                                          color: Colors.white,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.03),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor: Colors.grey.shade300,
                                                    child: Icon(
                                                      Icons.message,
                                                      size: 18,
                                                      color: Colors.green.shade600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.snackbar(
                                                      "Info",
                                                      "View profile functionality not implemented yet.",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.black,
                                                      colorText: Colors.white,
                                                      margin: const EdgeInsets.all(10),
                                                      borderRadius: 10,
                                                      duration: const Duration(seconds: 3),
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size(0, 25),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  child: Text(
                                                    "View Profile",
                                                    style: TextStyle(
                                                      fontSize: width * 0.032,
                                                      color: Colors.green.shade700,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    height: 32,
                                                    constraints: BoxConstraints(
                                                      maxWidth: width * 0.2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.shade700,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Accept",
                                                        style: TextStyle(
                                                          fontSize: width * 0.032,
                                                          color: Colors.white,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
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
                              },
                            ),
                          ),
                        if (!isBiddersClicked)
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.03),
                            child: relatedWorkers == null || relatedWorkers!.isEmpty
                                ? Column(
                                  children: [
                                    Center(
                                                                  child: SvgPicture.asset(
                                    'assets/svg_images/norelatedworker.svg',
                                    height: height * 0.23,
                                                                  ),
                                                                ),
                                    SizedBox(height: height * 0.023,),
                                    Text("No related worker",style: TextStyle(color: Colors.grey),)
                                  ],
                                )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: relatedWorkers!.length,
                              itemBuilder: (context, index) {
                                final worker = relatedWorkers![index];
                                final fullName = worker['full_name']?.toString() ?? 'N/A';
                                final rating = worker['rating']?.toString() ?? '0';
                                final amount = worker['amount']?.toString() ?? '0';
                                final location = worker['location']?.toString() ?? 'N/A';
                                final profilePic = worker['profile_pic']?.toString();

                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: height * 0.01,
                                    horizontal: width * 0.01,
                                  ),
                                  padding: EdgeInsets.all(width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: profilePic != null && profilePic.isNotEmpty
                                            ? Image.network(
                                          profilePic,
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/images/account1.png',
                                            height: 90,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Image.asset(
                                          'assets/images/account1.png',
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    fullName,
                                                    style: TextStyle(
                                                      fontSize: width * 0.045,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      rating,
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      size: width * 0.04,
                                                      color: Colors.yellow.shade700,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "₹$amount",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.10),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 13,
                                                            backgroundColor: Colors.grey.shade300,
                                                            child: Icon(
                                                              Icons.phone,
                                                              size: 18,
                                                              color: Colors.green.shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: height * 0.005),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    height: 22,
                                                    constraints: BoxConstraints(
                                                      maxWidth: width * 0.25,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade300,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        location,
                                                        style: TextStyle(
                                                          fontSize: width * 0.033,
                                                          color: Colors.white,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.03),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor: Colors.grey.shade300,
                                                    child: Icon(
                                                      Icons.message,
                                                      size: 18,
                                                      color: Colors.green.shade600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.snackbar(
                                                      "Info",
                                                      "View profile functionality not implemented yet.",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.black,
                                                      colorText: Colors.white,
                                                      margin: const EdgeInsets.all(10),
                                                      borderRadius: 10,
                                                      duration: const Duration(seconds: 3),
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size(0, 25),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  child: Text(
                                                    "View Profile",
                                                    style: TextStyle(
                                                      fontSize: width * 0.032,
                                                      color: Colors.green.shade700,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    height: 32,
                                                    constraints: BoxConstraints(
                                                      maxWidth: width * 0.2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.shade700,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Accept",
                                                        style: TextStyle(
                                                          fontSize: width * 0.032,
                                                          color: Colors.white,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
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
                              },
                            ),
                          ),
                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  Column(
                    children: [
                      // Center(child: Image.asset("assets/images/bidder.png")),
                    ],
                  ),
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}