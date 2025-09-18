import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Bidding/view/user/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Emergency/utils/assets.dart';
import '../../../Widgets/AppColors.dart';
import '../../../Widgets/address_map_class.dart';
import '../../../directHiring/views/ServiceProvider/WorkerListViewProfileScreen.dart';
import '../../../directHiring/views/User/UserViewWorkerDetails.dart';
import '../../../testingfile.dart';
import 'bidding_worker_detail_edit_screen.dart';

class BiddingWorkerDetailScreen extends StatefulWidget {
  final String? buddingOderId;
  final userId;
  final serviceProviderId;

  const BiddingWorkerDetailScreen(
      {super.key, this.buddingOderId, this.userId, this.serviceProviderId});

  @override
  State<BiddingWorkerDetailScreen> createState() =>
      _BiddingWorkerDetailScreenState();
}

class _BiddingWorkerDetailScreenState extends State<BiddingWorkerDetailScreen> {
  bool isBiddersClicked = false;
  Map<String, dynamic>? getBuddingOderByIdResponseData;
  List<dynamic> bidders = [];
  List<dynamic> relatedWorkers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredBidders = [];
  List<dynamic> filteredRelatedWorkers = [];
  List<dynamic>? getBuddingOderByIdResponseDatalist;
  late Razorpay _razorpay;
  String? selectedBidderId; // New variable add kar
  @override
  void initState() {
    super.initState();
    getBuddingOderById();
    getAllBidders();
    _searchController.addListener(_filterLists);
    _filterLists();
    fetchBiddingOffers();
    var getCurrentBiddingId;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> verifaibiddingPlateformFee(
      String paymentId, String orderId, serviceProviderId) async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/verifyPlatformFeePayment';
    print("Abhi:- verifaibiddingPlateformFee url: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "razorpay_order_id": orderId,
          "razorpay_payment_id": paymentId,
          "serviceProviderId": serviceProviderId,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            "Abhi:- verifaibiddingPlateformFee statusCode: ${response.statusCode}");
        print("Abhi:- verifaibiddingPlateformFee response: ${response.body}");
        // Verify success hone ke baad AcceptNegotiation call karo
        // await AcceptNegotiation();
        Get.back(result: true);
        Get.back(result: true);
        Get.snackbar(
          "Success",
          responseData['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print(
            "Abhi:- else verifaibiddingPlateformFee statusCode: ${response.statusCode}");
        print(
            "Abhi:- else verifaibiddingPlateformFee response: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- verifaibiddingPlateformFee Exception: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Abhi:- Payment Success: ${response.paymentId}");
    // verifaibiddingPlateformFee(response.paymentId!, razorpayOrderId!,); // Call verify
    verifaibiddingPlateformFee(response.paymentId!, razorpayOrderId!,
        selectedBidderId!); // Ab teesra arg: selectedBidderId
    Get.snackbar("Payment Success", "Transaction completed!",
        backgroundColor: Colors.green, colorText: Colors.white);
    Get.back(); // Close dialog
    Get.back(); // Extra back if needed for previous screen
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Abhi:- Payment Error: ${response.message}");
    Get.snackbar("Payment Failed", "Error: ${response.message}",
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("Abhi:- External Wallet: ${response.walletName}");
  }

  void _filterLists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredBidders = List.from(bidders);
        filteredRelatedWorkers = List.from(relatedWorkers);
      } else {
        filteredBidders = bidders.where((bidder) {
          final fullName = bidder['full_name']?.toString().toLowerCase() ?? '';
          final location = bidder['location']?.toString().toLowerCase() ?? '';
          return fullName.contains(query) || location.contains(query);
        }).toList();

        filteredRelatedWorkers = relatedWorkers.where((worker) {
          final fullName = worker['full_name']?.toString().toLowerCase() ?? '';
          final location = worker['location']?.toString().toLowerCase() ?? '';
          return fullName.contains(query) || location.contains(query);
        }).toList();
      }
      print("Abhi:- Filtered Bidders: $filteredBidders");
      print("Abhi:- Filtered Related Workers: $filteredRelatedWorkers");
    });
  }

  //     abhishek add new api code
  Future<void> fetchBiddingOffers() async {
    final String apiUrl =
        "https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.buddingOderId}";

    // final response = await http.get(Uri.parse(apiUrl));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print("Abhi:- getBuddingOderById response: ${response.body}");
        print("Abhi:- getBuddingOderById status: ${response.statusCode}");
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            getBuddingOderByIdResponseDatalist = data['data'];
          });
        } else {
          print("Abhi:- getBuddingOderById response: ${response.body}");
          print("Abhi:- getBuddingOderById status: ${response.statusCode}");
          print("API Error: ${data['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> getBuddingOderById() async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.buddingOderId}";
    // "https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.buddingOderId}";
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          final categoryId = responseData['data']?['category_id']?['_id'] ?? '';
          final subCategoryIds =
              (responseData['data']?['sub_category_ids'] as List<dynamic>?)
                      ?.map((sub) => sub['_id'] as String)
                      .toList() ??
                  [];
          if (categoryId.isNotEmpty &&
              subCategoryIds.isNotEmpty &&
              !isBiddersClicked) {
            await getReletedWorker(categoryId, subCategoryIds);
          }
          setState(() {
            getBuddingOderByIdResponseData = responseData;
            isLoading = false;
            _filterLists();
          });
        } else {
          setState(() {
            isLoading = false;
            _filterLists();
          });
          Get.snackbar(
            "Error",
            responseData['message'] ?? "Failed to fetch order details.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          isLoading = false;
          _filterLists();
        });
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to fetch order details.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- getBuddingOderById Exception: $e");
      setState(() {
        isLoading = false;
        _filterLists();
      });
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          final orders = responseData['data'] as List<dynamic>?;
          final matchingOrder = orders?.firstWhere(
            (order) => order['_id'] == widget.buddingOderId,
            orElse: () => null,
          );
          setState(() {
            bidders = matchingOrder != null
                ? (matchingOrder['bidders'] as List<dynamic>?) ?? []
                : [];
            filteredBidders = List.from(bidders);
            isLoading = getBuddingOderByIdResponseData == null &&
                relatedWorkers.isEmpty;
            print("Abhi:- Bidders: $bidders");
          });
        } else {
          setState(() {
            bidders = [];
            filteredBidders = [];
            isLoading = getBuddingOderByIdResponseData == null &&
                relatedWorkers.isEmpty;
          });
          Get.snackbar(
            "Error",
            responseData['message'] ?? "Failed to fetch bidders.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          bidders = [];
          filteredBidders = [];
          isLoading =
              getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
        });
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to fetch bidders.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- getAllBidders Exception: $e");
      setState(() {
        bidders = [];
        filteredBidders = [];
        isLoading =
            getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
      });
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getReletedWorker(
      String categoryId, List<String> subCategoryIds) async {
    final String url =
        "https://api.thebharatworks.com/api/user/getServiceProviders";
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          setState(() {
            relatedWorkers = responseData['data'] as List<dynamic>? ?? [];
            filteredRelatedWorkers = List.from(relatedWorkers);
            isLoading =
                getBuddingOderByIdResponseData == null && bidders.isEmpty;
            print("Abhi:- Related Workers: $relatedWorkers");
          });
        } else {
          setState(() {
            relatedWorkers = [];
            filteredRelatedWorkers = [];
            isLoading =
                getBuddingOderByIdResponseData == null && bidders.isEmpty;
          });
          Get.snackbar(
            "Error",
            responseData['message'] ?? "Failed to fetch related workers.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        setState(() {
          relatedWorkers = [];
          filteredRelatedWorkers = [];
          isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
        });
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Failed to fetch related workers.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- getReletedWorker Exception: $e");
      setState(() {
        relatedWorkers = [];
        filteredRelatedWorkers = [];
        isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
      });
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> cancelTask() async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/cancelBiddingOrder/${widget.buddingOderId}";
    print("Abhi:- Cancel task url: $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- Cancel task response ${response.body}");
        print("Abhi:- Cancel task response ${response.statusCode}");
        Navigator.pop(context, true);
      } else {
        print("Abhi:- Cancel task response else ${response.body}");
        print("Abhi:- Cancel task response else ${response.statusCode}");
        Get.snackbar(
          "Error",
          "Failed to cancel task.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- Cancel task Exception: $e");
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> inviteproviderId(String workerId) async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/inviteServiceProviders';
    print("Abhi:- inviteprovider api url : $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": widget.buddingOderId,
          "provider_ids": [workerId],
        }),
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- Invideprovider response : ${response.body}");
        Get.snackbar(
          "Success",
          responseData['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Abhi:- else Invideprovider response : ${response.body}");
        Get.snackbar(
          "Error",
          responseData['message'] ?? "Something went wrong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Abhi:- inviteprovider api Exception $e");
      Get.snackbar(
        "Error",
        "Something went wrong!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  int? platformFee;

  Future<void> CreatebiddingPlateformfee() async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/createPlatformFeeOrder/${widget.buddingOderId}';
    print("Abhi:- CreatebiddingPlateformfee url: $url");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            "Abhi:- CreatebiddingPlateformfee statusCode: ${response.statusCode}");
        print("Abhi:- CreatebiddingPlateformfee response: ${response.body}");
        setState(() {
          razorpayOrderId = responseData['orderId']; // Store orderId
          platformFee = responseData[
              'amount']; // Store platform fee amount (assuming it's int)
        });
        print(
            "Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee");
        // Do not open Razorpay here; it will be opened from dialog's Pay button
      } else {
        print(
            "Abhi:- else CreatebiddingPlateformfee statusCode: ${response.statusCode}");
        print(
            "Abhi:- else CreatebiddingPlateformfee response: ${response.body}");
      }
    } catch (e) {
      print("Abhi:- CreatebiddingPlateformfee Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print("Abhi:- buddingOderId is: ${widget.buddingOderId}");

    final data = getBuddingOderByIdResponseData?['data'];

    final title = data?['title'] ?? 'N/A';
    final address = data?['address'] ?? 'N/A';
    final latitude = data?['latitude'] ?? 'N/A';
    final description = data?['description'] ?? 'N/A';
    final cost = data?['cost']?.toString() ?? '0';
    final deadline = data?['deadline'] != null
        ? DateFormat('dd/MM/yy').format(DateTime.parse(data?['deadline']))
        : 'N/A';
    final imageUrls =
        (data?['image_url'] as List<dynamic>?)?.cast<String>() ?? [];
    // final data = getBuddingOderByIdResponseData;
    final AssignedWorkerdata = getBuddingOderByIdResponseData;
    final assignedWorker =
        AssignedWorkerdata?['assignedWorker'] as Map<String, dynamic>?;

    print(
        "Abhi:- buddingOderId is worker name: ${data?['assignedWorker']?['name']}");

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.green.shade700, // navigation bar color
      statusBarColor: Colors.green.shade700, // status bar color
      statusBarIconBrightness: Brightness.light, // status bar icons' color
      systemNavigationBarIconBrightness:
          Brightness.light, //navigation bar icons' color
    ));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text("Worker Details",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            leading: const BackButton(color: Colors.black),
            actions: [],
            systemOverlayStyle:  SystemUiOverlayStyle(
              statusBarColor: AppColors.primaryGreen,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          backgroundColor: Colors.white,
          body: Container(
            width: width,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      //  const SizedBox(height: 10),
                        // Row(
                        //   children: [
                        //     GestureDetector(
                        //       onTap: () => Navigator.pop(context),
                        //       child: const Padding(
                        //         padding: EdgeInsets.only(left: 15.0),
                        //         child:
                        //             Icon(Icons.arrow_back_outlined, size: 22),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 90),
                        //     Text(
                        //       'Worker details',
                        //       style: GoogleFonts.poppins(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //         color: AppColors.black,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      //  SizedBox(height: height * 0.01),
                        Container(color: Colors.grey,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: height * 0.25,
                              enlargeCenterPage: true,
                              autoPlay: imageUrls.isNotEmpty,
                              viewportFraction: 0.85,
                            ),
                            items: imageUrls.isNotEmpty
                                ? imageUrls
                                    .map((url) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              image: NetworkImage(url.trim()),
                                              // fit: BoxFit.cover,
                                              onError: (exception, stackTrace) =>
                                                  Image.asset(
                                                'assets/images/Bid.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList()
                                : [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                          image:
                                              AssetImage('assets/images/Bid.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                        SizedBox(height: height * 0.015),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => MapScreen(
                                      //       latitude: data?['user_id']?['location']
                                      //               ?['latitude'] ??
                                      //           'N/A',
                                      //       longitude: data?['user_id']?['location']
                                      //               ?['longitude'] ??
                                      //           'N/A',
                                      //     ),
                                      //   ),
                                      // );

                                        openMap(data?['latitude'] ?? 0.0,
                                            data?['longitude'] ?? 0.0);

                                      print(
                                          "Abhi:- get oder Details lat for bidding : ${data?['latitude'] ?? 0.0} long : ${data?['longitude'] ?? 0.0} address ${data?['address'] ?? ""}");
                                    },
                                    child: Container(
                                      height: MediaQuery.of(context).size.height *
                                          0.025,
                                      width:
                                          MediaQuery.of(context).size.width * 0.28,
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            // address.split(',').last.trim(),
                                            // data?['user_id']?['location']
                                            // ?['address'] ??
                                            //     'N/A',
                                            data?['address'] ?? "",
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize:
                                                  MediaQuery.of(context).size.width *
                                                      0.03,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(5)),
                                    child: Center(child: Text(data?['project_id'] ?? "",style: TextStyle(color: Colors.white), maxLines: 1,
                                      overflow: TextOverflow.ellipsis,)),)
                                ],
                              ),

                              SizedBox(height: height * 0.005),
                              Text(
                                address,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                              SizedBox(height: height * 0.002),
                              Text(
                                "Completion  - $deadline",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              SizedBox(height: height * 0.002),
                              Text(
                                "Title - $title",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.05),
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
                        data?['hire_status'] == 'accepted'
                            ? SizedBox(
                                height: height * 0.03,
                              )
                            : SizedBox(),
                        //             This is accepted time show this fileds
                        data?['hire_status'] == 'accepted'
                            ? Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Profile Image
                                      CircleAvatar(
                                        radius: height * 0.05,
                                        backgroundImage: data?[
                                                        'service_provider_id']
                                                    ?['profile_pic'] !=
                                                null
                                            ? NetworkImage(
                                                data!['service_provider_id']![
                                                    'profile_pic'])
                                            : null,
                                        child: data?['service_provider_id']
                                                    ?['profile_pic'] ==
                                                null
                                            ? Icon(Icons.person,
                                                size: height * 0.05)
                                            : null,
                                      ),
                                      SizedBox(width: 12),

                                      // Details + Actions
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Name + Message icon
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    data?['service_provider_id']
                                                    ?['full_name'] ?? "No data",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.message,
                                                    size: 18,
                                                    color: Colors.green.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6),
                                            // Phone + Call icon
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  data?['service_provider_id']?['phone'] ?? "No data",
                                                  style: TextStyle(fontSize: 14,
                                                      color: Colors.grey[700]),
                                                ),
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.call,
                                                    size: 18,
                                                    color: Colors.green.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),

                                            // View profile link
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserViewWorkerDetails(
                                                        workerId: data?['service_provider_id']?['_id'],
                                                        hirebuttonhide: "hide",
                                                        UserId: widget.userId,
                                                        hideonly: "hideOnly",
                                                        // oderId: OderId,
                                                        // biddingOfferId: biddingofferId,
                                                      ),
                                                    ));
                                              },
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "View profile",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green,
                                                    //decoration: TextDecoration.underline,
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
                              )
                            : SizedBox(),

                        //   This is show all status according filed

                        SizedBox(
                          height: 15,
                        ),

                        data?['hire_status'] == 'cancelled'
                            ? Center(
                                child: Container(
                                  height: 35,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warning_amber,color: Colors.red),
                                      Text(
                                        "The order is Cancelled",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                        data?['hire_status'] == 'cancelledDispute'
                            ? Center(
                                child: Container(
                                  height: 35,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warning_amber,
                                          color: Colors.red),
                                      Text(
                                        "The order is dispute Cancelled",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),

                        data?['hire_status'] == 'completed'
                            ? Center(
                                child: Container(
                                  height: 35,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          color: Colors.green),
                                      Text(
                                        "  The order has been completed",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                        data?['hire_status'] == 'rejected'
                            ? Center(
                                child: Container(
                                  height: 35,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.block, color: Colors.grey),
                                      Text("The order is rejected"),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                        data?['hire_status'] == 'accepted'
                            ? const SizedBox(height: 20)
                            : SizedBox(),

                        data?['hire_status'] == 'accepted' &&
                                assignedWorker?['name'] != null
                            ? Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Assigned Person",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Profile Image
                                          CircleAvatar(
                                            radius: MediaQuery.of(context).size.height * 0.05,
                                            backgroundImage: assignedWorker?['image'] != null ? NetworkImage(assignedWorker?['image']) : null,
                                            child: assignedWorker?['image'] == null
                                                ? Icon(Icons.person, size: MediaQuery.of(context).size.height * 0.05) : null,
                                          ),
                                          SizedBox(width: 12),
                                          // Details + Actions
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Name + Message icon
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        assignedWorker?['name'] ?? "No name",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 6),
                                                // Phone + Call icon
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      assignedWorker?['phone'] ?? "No phone",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[700]),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                // View profile link
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            WorkerListViewProfileScreen(
                                                          workerId:
                                                              assignedWorker?[
                                                                  '_id'],
                                                          // hirebuttonhide: "hide",
                                                          // userId: widget.userId,
                                                          // UserId: widget.userId,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                WorkerListViewProfileScreen(
                                                              workerId:
                                                                  assignedWorker?[
                                                                      '_id'],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 29,
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: Colors
                                                              .green.shade700,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "View profile",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
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
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),

                        SizedBox(height: height * 0.02),
                        data?['hire_status'] == 'pending'
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.05),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                     /* onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostTaskEditScreen(
                                                  title: data?['title'],
                                                    description: data?['description'],
                                                    category:  data?['category_id']?['name'],
                                                    location:  data?['google_address'],
                                                    selectDeadline:  data?['deadline'],
                                                    // subcategory:  data?['sub_category_ids']?['sub_category_ids'],
                                                    cost:  data?['cost'],
                                                    biddingOderId: widget.buddingOderId),
                                          ),
                                        );
                                      },*/
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PostTaskEditScreen(
                                              title: data?['title']?.toString(), // "Chair repair"
                                              description: data?['description']?.toString(), // "Welcome to Gboard clipboard..."
                                              category: data?['category_id']?['_id']?.toString(), // "68936066cff3b791084d288e"
                                              location: data?['google_address']?.toString(), // "8, Indore, Madhya Pradesh, India"
                                              selectDeadline: data?['deadline']?.toString(), // "2025-08-30T00:00:00.000Z"
                                              subcategory: data?['sub_category_ids'] != null
                                                  ? (data['sub_category_ids'] as List).map((sub) => sub['_id'].toString()).toList() // ["689453bbe57505b551542c3b"]
                                                  : [],
                                              cost: data?['cost']?.toString(), // "5000"
                                              biddingOderId: widget.buddingOderId?.toString() ?? data?['_id']?.toString(), // "68b1af1ff77872fc186ad308"
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: height * 0.045,
                                        width: width * 0.40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.green.shade700,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.edit,
                                                  color: AppColors.primaryGreen,
                                                  size: height * 0.024),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                  Icons
                                                      .cancel_presentation_rounded,
                                                  color: Colors.white),
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
                              )
                            : SizedBox(),

                        data?['hire_status'] == 'accepted'
                            ? SizedBox()
                            : SizedBox(height: height * 0.02),
                        data?['hire_status'] == 'pending'
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.05),
                                child: Container(
                                  height: height * 0.06,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius:
                                        BorderRadius.circular(width * 0.03),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: "Search for services",
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    _filterLists();
                                                  },
                                                )
                                              : null,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: height * 0.015,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        data?['hire_status'] == 'pending'
                            ? SizedBox(height: height * 0.015)
                            : SizedBox(),
                        data?['hire_status'] == 'pending'
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.05),
                                child: Column(
                                  children: [
                                    SizedBox(height: height * 0.015),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              isBiddersClicked = true;
                                              _filterLists();
                                            });
                                          },
                                          child: Container(
                                            height: height * 0.045,
                                            width: width * 0.40,
                                            decoration: BoxDecoration(
                                              color: isBiddersClicked
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: width * 0.02),
                                                  Text(
                                                    "Bidders",
                                                    style: TextStyle(
                                                      color: isBiddersClicked
                                                          ? Colors.white
                                                          : Colors
                                                              .grey.shade700,
                                                      fontSize: width * 0.05,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                              isBiddersClicked = false;
                                              final categoryId =
                                                  getBuddingOderByIdResponseData?[
                                                                  'data']
                                                              ?['category_id']
                                                          ?['_id'] ??
                                                      '';
                                              final subCategoryIds =
                                                  (getBuddingOderByIdResponseData?[
                                                                      'data']?[
                                                                  'sub_category_ids']
                                                              as List<dynamic>?)
                                                          ?.map((sub) =>
                                                              sub['_id']
                                                                  as String)
                                                          .toList() ??
                                                      [];
                                              if (categoryId.isNotEmpty &&
                                                  subCategoryIds.isNotEmpty) {
                                                getReletedWorker(
                                                    categoryId, subCategoryIds);
                                              }
                                              _filterLists();
                                            });
                                          },
                                          child: Container(
                                            height: height * 0.045,
                                            width: width * 0.40,
                                            decoration: BoxDecoration(
                                              color: !isBiddersClicked
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: width * 0.02),
                                                  Text(
                                                    "Related Worker",
                                                    style: TextStyle(
                                                      color: !isBiddersClicked
                                                          ? Colors.white
                                                          : Colors
                                                              .grey.shade700,
                                                      fontSize: width * 0.04,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                          padding: EdgeInsets.only(
                                              top: height * 0.01),
                                          child:
                                              getBuddingOderByIdResponseDatalist!
                                                      .isEmpty
                                                  ? Column(
                                                      children: [
                                                        Center(
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/svg_images/nobidders.svg',
                                                            height:
                                                                height * 0.33,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.023),
                                                        const Text(
                                                          "No bidders found",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ],
                                                    )
                                                  : ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          getBuddingOderByIdResponseDatalist
                                                                  ?.length ??
                                                              0,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final bidder =
                                                            getBuddingOderByIdResponseDatalist?[
                                                                index];
                                                        final fullName = bidder?[
                                                                        'provider_id']
                                                                    [
                                                                    'full_name']
                                                                ?.toString() ??
                                                            'N/A';
                                                        final rating = bidder?[
                                                                        'provider_id']
                                                                    ['rating']
                                                                ?.toString() ??
                                                            '0';
                                                        final bidderId =
                                                            bidder?['provider_id']
                                                                        ?['_id']
                                                                    ?.toString() ??
                                                                '';
                                                        final biddingofferId =
                                                            bidder?['_id']
                                                                    ?.toString() ??
                                                                '';
                                                        final OderId = bidder?[
                                                                    'order_id']
                                                                ?.toString() ??
                                                            '';
                                                        final bidAmount = bidder?[
                                                                'bid_amount'] ??
                                                            '0';
                                                        final location = bidder?[
                                                                            'provider_id']
                                                                        [
                                                                        'location']
                                                                    ['address']
                                                                ?.toString() ??
                                                            'N/A';
                                                        final profilePic =
                                                            bidder?['provider_id']
                                                                    [
                                                                    'profile_pic']
                                                                ?.toString();

                                                        print(
                                                            "Abhi:- bidder id in bidder list : $bidderId");

                                                        return Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                            vertical:
                                                                height * 0.01,
                                                            horizontal:
                                                                width * 0.01,
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  width * 0.02),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 1,
                                                                blurRadius: 5,
                                                                offset:
                                                                    const Offset(
                                                                        0, 3),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                child: profilePic !=
                                                                            null &&
                                                                        profilePic
                                                                            .isNotEmpty
                                                                    ? Image
                                                                        .network(
                                                                        profilePic,
                                                                        height:
                                                                            90,
                                                                        width:
                                                                            90,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        errorBuilder: (context,
                                                                                error,
                                                                                stackTrace) =>
                                                                            Image.asset(
                                                                          'assets/images/d_png/no_profile_image.png',
                                                                          height:
                                                                              90,
                                                                          width:
                                                                              90,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      )
                                                                    : Image
                                                                        .asset(
                                                                        'assets/images/d_png/no_profile_image.png',
                                                                        height:
                                                                            90,
                                                                        width:
                                                                            90,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                              ),
                                                              SizedBox(
                                                                  width: width *
                                                                      0.03),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            fullName,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: width * 0.045,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
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
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "₹$bidAmount",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.04,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        CircleAvatar(
                                                                          radius:
                                                                              13,
                                                                          backgroundColor: Colors
                                                                              .grey
                                                                              .shade300,
                                                                          child:
                                                                              Icon(
                                                                            Icons.phone,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                Colors.green.shade600,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height: height *
                                                                            0.005),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                22,
                                                                            constraints:
                                                                                BoxConstraints(
                                                                              maxWidth: width * 0.25,
                                                                            ),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.red.shade300,
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            child:
                                                                                Center(
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
                                                                        SizedBox(
                                                                            width:
                                                                                width * 0.03),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 8.0),
                                                                          child:
                                                                              CircleAvatar(
                                                                            radius:
                                                                                13,
                                                                            backgroundColor:
                                                                                Colors.grey.shade300,
                                                                            child:
                                                                                Icon(
                                                                              Icons.message,
                                                                              size: 18,
                                                                              color: Colors.green.shade600,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => UserViewWorkerDetails(
                                                                                  workerId: bidderId,
                                                                                  hirebuttonhide: "hide",
                                                                                  hideonly: "hideOnly",
                                                                                  UserId: widget.userId,
                                                                                  oderId: OderId,
                                                                                  biddingOfferId: biddingofferId,
                                                                                ),
                                                                                // UserViewWorkerDetails(
                                                                                //   workerId: '68ac07f700315e754a037e56',
                                                                                // ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            padding:
                                                                                EdgeInsets.zero,
                                                                            minimumSize:
                                                                                const Size(0, 25),
                                                                            tapTargetSize:
                                                                                MaterialTapTargetSize.shrinkWrap,
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            "View Profile",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: width * 0.032,
                                                                              color: Colors.green.shade700,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Flexible(
                                                                          child:
                                                                              InkWell(
                                                                            // onTap: () async {
                                                                            //   // acceptBid(bidderId, bidAmount);
                                                                            //   // Navigator.push(
                                                                            //   //   context,
                                                                            //   //   MaterialPageRoute(
                                                                            //   //     builder: (context) => UserViewWorkerDetails(
                                                                            //   //       workerId: bidderId,
                                                                            //   //       hirebuttonhide: "hide",
                                                                            //   //       UserId: widget.userId,
                                                                            //   //       oderId: OderId,
                                                                            //   //       biddingOfferId: biddingofferId,
                                                                            //   //     ),
                                                                            //   //     // UserViewWorkerDetails(
                                                                            //   //     //   workerId: '68ac07f700315e754a037e56',
                                                                            //   //     // ),
                                                                            //   //   ),
                                                                            //   // );
                                                                            //   await CreatebiddingPlateformfee();
                                                                            //   // final bidderId = bidder?['provider_id']?['_id']?.toString() ?? '';  // Bidder ID yahaan se le
                                                                            //   // showTotalDialog(context, index, bidAmount, platformFee, bidderId);  // Extra bidderId pass kar
                                                                            //
                                                                            //   showTotalDialog(context,index,bidAmount,platformFee);
                                                                            // },
                                                                            onTap:
                                                                                () async {
                                                                              final bidder = getBuddingOderByIdResponseDatalist?[index];
                                                                              final bidderId = bidder?['provider_id']?['_id']?.toString() ?? '';
                                                                              selectedBidderId = bidderId; // Store kar
                                                                              await CreatebiddingPlateformfee();
                                                                              showTotalDialog(context, index, bidAmount, platformFee); // BidderId ab nahi pass, class level par hai
                                                                            },
                                                                            child:
                                                                                Container(
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
                                                    )),
                                    if (!isBiddersClicked)
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: height * 0.03),
                                        child: filteredRelatedWorkers.isEmpty
                                            ? Column(
                                                children: [
                                                  Center(
                                                    child: SvgPicture.asset(
                                                      'assets/svg_images/norelatedworker.svg',
                                                      height: height * 0.23,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.023),
                                                  const Text(
                                                    "No related worker",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              )
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    filteredRelatedWorkers
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  final worker =
                                                      filteredRelatedWorkers[
                                                          index];
                                                  final workerId = worker['_id']
                                                          ?.toString() ??
                                                      'N/A';
                                                  final fullName =
                                                      worker['full_name']
                                                              ?.toString() ??
                                                          'N/A';
                                                  final rating =
                                                      worker['rating']
                                                              ?.toString() ??
                                                          '0';
                                                  final amount =
                                                      worker['amount']
                                                              ?.toString() ??
                                                          '0';
                                                  final location =
                                                      worker['location']
                                                                  ?['address']
                                                              ?.toString() ??
                                                          'N/A';
                                                  final profilePic =
                                                      worker['profile_pic']
                                                          ?.toString();
                                                  print(
                                                      "Abhi:- get bidding related workerId : $workerId");

                                                  return Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      vertical: height * 0.01,
                                                      horizontal: width * 0.01,
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        width * 0.02),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          spreadRadius: 1,
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: profilePic !=
                                                                      null &&
                                                                  profilePic
                                                                      .isNotEmpty
                                                              ? Image.network(
                                                                  profilePic,
                                                                  height: 90,
                                                                  width: 90,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/d_png/no_profile_image.png',
                                                                    height: 90,
                                                                    width: 90,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                )
                                                              : Image.asset(
                                                                  'assets/images/d_png/no_profile_image.png',
                                                                  height: 90,
                                                                  width: 90,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.03),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      fullName,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            width *
                                                                                0.045,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        rating,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              width * 0.035,
                                                                        ),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .star,
                                                                        size: width *
                                                                            0.04,
                                                                        color: Colors
                                                                            .yellow
                                                                            .shade700,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "₹$amount",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          width *
                                                                              0.04,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  CircleAvatar(
                                                                    radius: 13,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade300,
                                                                    child: Icon(
                                                                      Icons
                                                                          .phone,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .green
                                                                          .shade600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.005),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          22,
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxWidth:
                                                                            width *
                                                                                0.27,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .red
                                                                            .shade300,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 4.0),
                                                                          child:
                                                                              Text(
                                                                            location,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: width * 0.033,
                                                                              color: Colors.white,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: width *
                                                                          0.03),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          13,
                                                                      backgroundColor: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .message,
                                                                        size:
                                                                            18,
                                                                        color: Colors
                                                                            .green
                                                                            .shade600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              UserViewWorkerDetails(
                                                                            workerId:
                                                                                workerId,
                                                                            hirebuttonhide:
                                                                                "hide",
                                                                                hideonly: "hideOnly",
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      minimumSize:
                                                                          const Size(
                                                                              0,
                                                                              25),
                                                                      tapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                    ),
                                                                    child: Text(
                                                                      "View Profile",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            width *
                                                                                0.032,
                                                                        color: Colors
                                                                            .green
                                                                            .shade700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        inviteproviderId(
                                                                            workerId);
                                                                        print(
                                                                            "Abhi:- tab on invite print workerId : $workerId");
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            32,
                                                                        constraints:
                                                                            BoxConstraints(
                                                                          maxWidth:
                                                                              width * 0.2,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Colors
                                                                              .green
                                                                              .shade700,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            "Invite",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: width * 0.032,
                                                                              color: Colors.white,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
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
                                                },
                                              ),
                                      ),
                                    SizedBox(height: height * 0.02),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        // TextButton(onPressed: (){
                        //   print("Abhi:-print data providerId : ${data?['service_provider_id']?['_id']}");
                        // }, child: Text("print data")),
                        data?['hire_status'] == 'pending'
                            ? SizedBox(height: height * 0.04)
                            : SizedBox(),
                        data?['hire_status'] == 'accepted'
                            ? BiddingPaymentScreen(
                                orderId: widget.buddingOderId ?? "",
                                paymentHistory: data?['service_payment']
                                    ?['payment_history'],
                                orderProviderId: data?['service_provider_id']
                                    ?['_id'],
                              )
                            : SizedBox(),
                        // Container(color: Colors.white,height: )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildAssignedWorkerCard() {
    final data = getBuddingOderByIdResponseData;
    final assignedWorker = data?['assignedWorker'] as Map<String, dynamic>?;

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (assignedWorker == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            "No assigned worker found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              "Assigned Person",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: MediaQuery.of(context).size.height * 0.05,
                  backgroundImage: assignedWorker['image'] != null
                      ? NetworkImage(assignedWorker['image'])
                      : null,
                  child: assignedWorker['image'] == null
                      ? Icon(Icons.person,
                          size: MediaQuery.of(context).size.height * 0.05)
                      : null,
                ),
                SizedBox(width: 12),
                // Details + Actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Message icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              assignedWorker['name'] ?? "No name",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              Icons.message,
                              size: 18,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      // Phone + Call icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            assignedWorker['phone'] ?? "No phone",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              Icons.call,
                              size: 18,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // View profile link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserViewWorkerDetails(
                                workerId: assignedWorker['_id'],
                                hirebuttonhide: "hide",
                                hideonly: "hideOnly",
                                // userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "View profile",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //        Accept pyment dailog box
  String? razorpayOrderId; // New variable to store orderId
  // late Razorpay _razorpay;
  void showTotalDialog(
      BuildContext context, int index, dynamic amount, dynamic platformFee) {
    int fee = platformFee ?? 0; // Default to 0 if null
    getBuddingOderByIdResponseDatalist?[index];

    final bidder = getBuddingOderByIdResponseDatalist?[index];
    final bidAmount = bidder?['bid_amount']?.toString() ?? '0';
    int bidAmountValue = int.tryParse(bidAmount) ?? 0;
    int totalAmount = bidAmountValue + fee;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Payment Confirmation",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Image.asset(BharatAssets.payConfLogo2),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18)),
                        Text(DateFormat("dd-MM-yy").format(DateTime.now()),
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Time",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18)),
                        Text(DateFormat("hh:mm a").format(DateTime.now()),
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Amount",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18)),
                        Text("RS $bidAmount",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Platform fees",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18)),
                        Text("INR $fee",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Image.asset(BharatAssets.payLine),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 24)),
                        Text("RS $totalAmount/-",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 24)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 4, color: Colors.green),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (platformFee != null && razorpayOrderId != null) {
                          var options = {
                            'key': 'rzp_test_R7z5O0bqmRXuiH',
                            'amount': totalAmount * 100,
                            // Changed to totalAmount for payment
                            'name': 'The Bharat Work',
                            'description': 'Payment for Order',
                            'prefill': {
                              'contact': '9876543210',
                              'email': 'test@razorpay.com',
                            },
                            'external': {
                              'wallets': ['paytm']
                            }
                          };
                          try {
                            _razorpay.open(options); // Open Razorpay now
                          } catch (e) {
                            debugPrint('Razorpay Error: $e');
                          }
                        } else {
                          Get.snackbar(
                              "Error", "Platform fee or order ID not available",
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width * 0.28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xff228B22)),
                        child: Text("Pay",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width * 0.28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 1.5),
                        ),
                        child: Text("Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.green)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
