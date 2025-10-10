import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Bidding/view/user/payment_screen.dart';
import 'package:developer/Emergency/utils/logger.dart';
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
import '../../../chat/APIServices.dart';
import '../../../chat/SocketService.dart';
import '../../../chat/chatScreen.dart';
import '../../../directHiring/views/ServiceProvider/WorkerListViewProfileScreen.dart';
import '../../../directHiring/views/User/UserViewWorkerDetails.dart';
import '../../../utility/custom_snack_bar.dart';
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
  bool _isChatLoading = false; // Add this as a field in your State class
  String? selectedBidderId; // New variable add kar
  String? CreatePlatformfeemessage;
  @override
  void initState() {
    bwDebug("order id ${widget.buddingOderId}",
        tag: "Bidding workdetail screen");
    super.initState();

    // if(getBuddingOderByIdResponseData?['hire_status'] == 'accepted' && getBuddingOderByIdResponseData?['platform_fee_paid'] == false) {
    //   showTotalDialog(context, 0, bidAmount, platformFee);
    // }

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
    print("Abhi:- verifaibiddingPlatformFee paymentId : $paymentId orderId : $orderId serviceproviderId : $serviceProviderId}");

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

        CustomSnackBar.show(
            message: responseData['message'], type: SnackBarType.success);
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
        /*selectedBidderId!*/widget.serviceProviderId); // Ab teesra arg: selectedBidderId
    CustomSnackBar.show(
        message: "Transaction completed!", type: SnackBarType.success);
    Get.back(); // Close dialog
    Get.back(); // Extra back if needed for previous screen
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Abhi:- Payment Error: ${response.message}");
    CustomSnackBar.show(
        message: "Error: ${response.message}", type: SnackBarType.error);
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

  Future<void> AcceptBiddingOrder (BidderId) async {
    final String url =
        "https://api.thebharatworks.com/api/bidding-order/acceptBiddingOrder";
    print("Abhi:- getAllBidders url: $url");
    print("Abhi:- getAllBidders service providerId: ${widget.serviceProviderId} orderId : ${widget.buddingOderId}");
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
          "order_id":widget.buddingOderId,
          "service_provider_id":BidderId,
        })
      );

      var responseData = jsonDecode(response.body);
      if(response.statusCode == 200 || response.statusCode == 201){
        print("Abhi:- accept bidding order response ${response.statusCode}");
        print("Abhi:- accept bidding order response ${response.body}");
      }else{
        print("Abhi:- accept bidding order else statusCode : ${response.statusCode} response : ${response.body}");
      }
    }catch(e){
      print("Abhi:- accept bidding order Expception : $e");
    }
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

          CustomSnackBar.show(
              message:
                  responseData['message'] ?? "Failed to fetch order details.",
              type: SnackBarType.error);
        }
      } else {
        setState(() {
          isLoading = false;
          _filterLists();
        });

        CustomSnackBar.show(
            message:
                responseData['message'] ?? "Failed to fetch order details.",
            type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- getBuddingOderById Exception: $e");
      setState(() {
        isLoading = false;
        _filterLists();
      });

      CustomSnackBar.show(
          message: "Something went wrong!", type: SnackBarType.error);
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

          CustomSnackBar.show(
              message: responseData['message'] ?? "Failed to fetch bidders.",
              type: SnackBarType.error);
        }
      } else {
        setState(() {
          bidders = [];
          filteredBidders = [];
          isLoading =
              getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
        });

        CustomSnackBar.show(
            message: responseData['message'] ?? "Failed to fetch bidders.",
            type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- getAllBidders Exception: $e");
      setState(() {
        bidders = [];
        filteredBidders = [];
        isLoading =
            getBuddingOderByIdResponseData == null && relatedWorkers.isEmpty;
      });

      CustomSnackBar.show(
          message: "Something went wrong!", type: SnackBarType.error);
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

          CustomSnackBar.show(
              message:
                  responseData['message'] ?? "Failed to fetch related workers.",
              type: SnackBarType.error);
        }
      } else {
        setState(() {
          relatedWorkers = [];
          filteredRelatedWorkers = [];
          isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
        });

        CustomSnackBar.show(
            message:
                responseData['message'] ?? "Failed to fetch related workers.",
            type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- getReletedWorker Exception: $e");
      setState(() {
        relatedWorkers = [];
        filteredRelatedWorkers = [];
        isLoading = getBuddingOderByIdResponseData == null && bidders.isEmpty;
      });

      CustomSnackBar.show(
          message: "Something went wrong!", type: SnackBarType.error);
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

        CustomSnackBar.show(
            message: "Failed to cancel task.", type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- Cancel task Exception: $e");

      CustomSnackBar.show(
          message: "Something went wrong!", type: SnackBarType.error);
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

        CustomSnackBar.show(
            message: responseData['message'], type: SnackBarType.success);
      } else {
        print(
            "Abhi:- else Invideprovider response : ${response.statusCode},${response.body}");
        CustomSnackBar.show(
            message: responseData['message'] ?? "Something went wrong",
            type: SnackBarType.error);
      }
    } catch (e) {
      print("Abhi:- inviteprovider api Exception $e");
      CustomSnackBar.show(
          message: "Something went wrong!", type: SnackBarType.error);
    }
  }



  Future<void> openMap(double lat, double lng) async {
    final Uri googleMapUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open the map.";
    }
  }

  int? platformFee;

  // Future<void> CreatebiddingPlateformfee() async {
  //   final String url =
  //       'https://api.thebharatworks.com/api/bidding-order/createPlatformFeeOrder/${widget.buddingOderId}';
  //   print("Abhi:- CreatebiddingPlateformfee url: $url");
  //   print("Abhi:- CreatebiddingPlateformfee url: ${widget.buddingOderId}");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token') ?? '';
  //
  //   try {
  //     var response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     var responseData = jsonDecode(response.body);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print("Abhi:- CreatebiddingPlateformfee statusCode: ${response.statusCode}");
  //       print("Abhi:- CreatebiddingPlateformfee response: ${response.body}");
  //       print("Abhi:- ");
  //       setState(() {
  //         razorpayOrderId = responseData['razorpay_order_id']; // Store orderId
  //         platformFee = responseData['platform_fee']; // Store platform fee amount (assuming it's int)
  //       });
  //       print("Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee");
  //       // Do not open Razorpay here; it will be opened from dialog's Pay button
  //     } else {
  //       print("Abhi:- else CreatebiddingPlateformfee statusCode: ${response.statusCode}");
  //       print("Abhi:- else CreatebiddingPlateformfee response: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Abhi:- CreatebiddingPlateformfee Exception: $e");
  //   }
  // }

  Future<void> CreatebiddingPlateformfee() async {
    final String url =
        'https://api.thebharatworks.com/api/bidding-order/createPlatformFeeOrder/${widget.buddingOderId}';
    print("Abhi:- CreatebiddingPlateformfee url: $url");
    print("Abhi:- CreatebiddingPlateformfee url: ${widget.buddingOderId}");

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
        print("Abhi:- CreatebiddingPlateformfee statusCode: ${response.statusCode}");
        print("Abhi:- CreatebiddingPlateformfee response: ${response.body}");
        print("Abhi:- ");
        setState(() {
          razorpayOrderId = responseData['razorpay_order_id']; // Store orderId

          platformFee = responseData['platform_fee']; // Store platform fee amount (assuming it's int)
        });
        print("Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee createplatformfeemessage : ${CreatePlatformfeemessage}");
        // Do not open Razorpay here; it will be opened from dialog's Pay button
      } else {
        setState(() {
          CreatePlatformfeemessage =  responseData['message'];
        });
        print("Abhi:- createbiddingOrder razorpayOrderId: ${razorpayOrderId} platformFee: $platformFee createplatformfeemessage : ${CreatePlatformfeemessage}");
        print("Abhi:- else CreatebiddingPlateformfee statusCode: ${response.statusCode}");
        print("Abhi:- else CreatebiddingPlateformfee response: ${response.body}");
        if(CreatePlatformfeemessage == 'Platform fee is greater than 10% advance amount!') {
          Get.snackbar(
            "Success",
            responseData['message'],
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print("Abhi:- CreatebiddingPlateformfee Exception: $e");
    }
  }

  ///                chat api added

  Future<Map<String, dynamic>> fetchUserById(
      String userId, String token) async {
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
      print(
          "Abhi:- User fetch API response: ${response.statusCode}, Body=${response.body}");
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
  Future<void> _startOrFetchConversation(
      BuildContext context, String receiverId) async {
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
          SnackBar(
              content:
                  Text('Error: Failed to fetch profile: ${body['message']}')),
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
      print(
          "Abhi:- Checking for existing conversation with receiverId: $receiverId, userId: $userId");
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
        print(
            "Abhi:- No existing conversation, starting new with receiverId: $receiverId");
        currentChat = await ApiService.startConversation(userId, receiverId);
      }

      // Step 5: Agar members strings hain, toh full user details fetch karo
      if (currentChat['members'].isNotEmpty &&
          currentChat['members'][0] is String) {
        print("Abhi:- New conversation, fetching user details for members");
        final otherId = currentChat['members'].firstWhere((id) => id != userId);
        final otherUserData = await fetchUserById(otherId, token);
        final senderUserData = await fetchUserById(userId, token);
        currentChat['members'] = [senderUserData, otherUserData];
        print(
            "Abhi:- Updated members with full details: ${currentChat['members']}");
      }

      // Step 6: Messages fetch karo
      final messages =
          await ApiService.fetchMessages(getIdAsString(currentChat['_id']));
      messages.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));

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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print("Abhi:- buddingOderId is: ${widget.buddingOderId}");
    print("Abhi:- buddingOderId serviceProviderId: ${widget.serviceProviderId}");

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

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   systemNavigationBarColor: Colors.green.shade700, // navigation bar color
    //   statusBarColor: Colors.green.shade700, // status bar color
    //   statusBarIconBrightness: Brightness.light, // status bar icons' color
    //   systemNavigationBarIconBrightness:
    //       Brightness.light, //navigation bar icons' color
    // ));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Work Details",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: const BackButton(color: Colors.black),
          actions: [],
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.primaryGreen,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        // backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
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
                        Container(
                          color: Colors.grey,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: height * 0.25,
                              enlargeCenterPage: true,
                              autoPlay: imageUrls.length > 1, // auto play only if more than one
                              viewportFraction: 0.85,
                              scrollPhysics: imageUrls.length > 1
                                  ? const BouncingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                            ),
                            items: imageUrls.isNotEmpty
                                ? imageUrls.map((url) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  url.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return /*Image.asset(
                                      'assets/images/Bid.png',
                                      fit: BoxFit.cover,
                                    )*/ Icon(Icons.image_not_supported_outlined);
                                  },
                                ),
                              );
                            }).toList()
                                : [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: /*Image.asset(
                                  'assets/images/Bid.png',
                                  fit: BoxFit.cover,
                                ),*/
                                Icon(Icons.image_not_supported_outlined)
                              ),
                            ],
                          ),
                        ),//
                        SizedBox(height: height * 0.015),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      // ); //

                                      openMap(data?['latitude'] ?? 0.0,
                                          data?['longitude'] ?? 0.0);

                                      print(
                                          "Abhi:- get oder Details lat for bidding : ${data?['latitude'] ?? 0.0} long : ${data?['longitude'] ?? 0.0} address ${data?['address'] ?? ""}");
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.025,
                                      width: MediaQuery.of(context).size.width *
                                          0.28,
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
                                              fontSize: MediaQuery.of(context).size.width * 0.03,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                        child: Text(
                                      data?['project_id'] ?? "",
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  )
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
                                "Completion Date  - $deadline",
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
                        data?['hire_status'] == 'accepted' && data?['platform_fee_paid'] == true
                            ? SizedBox(
                                height: height * 0.03,
                              )
                            : SizedBox(),
                        //             This is accepted time show this fileds
                        data?['hire_status'] == 'accepted' && data?['platform_fee_paid'] == true
                            ? Card(
                                color: Colors.white,
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
                                                            ?['full_name'] ??
                                                        "No data",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.message,
                                                    size: 18,
                                                    color:
                                                        Colors.green.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6),
                                            // Phone + Call icon
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  data?['service_provider_id']
                                                          ?['phone'] ??
                                                      "No data",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700]),
                                                ),
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.call,
                                                    size: 18,
                                                    color:
                                                        Colors.green.shade600,
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
                                                        oderId: widget
                                                            .buddingOderId,
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
                                  width: 250,
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
                                        "This order is cancelled",
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
                                  height: 40,
                                  width: double.infinity,
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
                                      Flexible(
                                        child: Text(
                                          "The order has been cancelled due to a dispute.",
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red),
                                        ),
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
                                        "  This order has been completed.",
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
                        data?['hire_status'] == 'accepted' && data?['platform_fee_paid'] == true
                            ? const SizedBox(height: 20)
                            : SizedBox(),

                        data?['hire_status'] == 'accepted' && data?['platform_fee_paid'] == true &&
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
                                            radius: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                            backgroundImage: assignedWorker?[
                                                        'image'] !=
                                                    null
                                                ? NetworkImage(
                                                    assignedWorker?['image'])
                                                : null,
                                            child: assignedWorker?['image'] ==
                                                    null
                                                ? Icon(Icons.person,
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.05)
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
                                                        assignedWorker?[
                                                                'name'] ??
                                                            "No name",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 6),
                                                // Phone + Call icon
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      assignedWorker?[
                                                              'phone'] ??
                                                          "No phone",
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
                                            builder: (context) =>
                                                PostTaskEditScreen(
                                              title: data?['title']?.toString(),
                                              // "Chair repair"
                                              description: data?['description']
                                                  ?.toString(),
                                              // "Welcome to Gboard clipboard..."
                                              category: data?['category_id']
                                                      ?['_id']
                                                  ?.toString(),
                                              // "68936066cff3b791084d288e"
                                              location: data?['google_address']
                                                  ?.toString(),
                                              // "8, Indore, Madhya Pradesh, India"
                                              selectDeadline:
                                                  data?['deadline']?.toString(),
                                              // "2025-08-30T00:00:00.000Z"
                                              subcategory: data?[
                                                          'sub_category_ids'] !=
                                                      null
                                                  ? (data['sub_category_ids']
                                                          as List)
                                                      .map((sub) =>
                                                          sub['_id'].toString())
                                                      .toList() // ["689453bbe57505b551542c3b"]
                                                  : [],
                                              cost: data?['cost']?.toString(),
                                              // "5000"
                                              biddingOderId: widget
                                                      .buddingOderId
                                                      ?.toString() ??
                                                  data?['_id']
                                                      ?.toString(), // "68b1af1ff77872fc186ad308"
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

                        data?['hire_status'] == 'accepted'  && data?['platform_fee_paid'] == true
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
                                                        final bidderId = bidder?['provider_id']?['_id']?.toString() ?? '';
                                                        final biddingofferId = bidder?['_id']?.toString() ??'';
                                                        final OderId = bidder?['order_id']?.toString() ?? '';
                                                        final bidAmount = bidder?['bid_amount'] ?? '0';
                                                        final location = bidder?['provider_id']['location']['address']?.toString() ?? 'N/A';
                                                        final profilePic = bidder?['provider_id']['profile_pic']?.toString();

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
                                                                              GestureDetector(
                                                                                onTap: _isChatLoading
                                                                                    ? null  // Disable tap while loading
                                                                                    :
                                                                                () async {
                                                                              final receiverId = bidderId != null && bidderId != null ? bidderId?.toString() ?? 'Unknown' : 'Unknown';
                                                                              final fullNamed = bidderId != null && bidderId != null ? fullName ?? 'Unknown' : 'Unknown';
                                                                              print("Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullNamed");
                                                                              if (receiverId != 'Unknown' && receiverId.isNotEmpty) {
                                                                                // await _startOrFetchConversation(context, receiverId);

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
                                                                              } else {
                                                                                print("Abhi:- Error: Invalid receiver ID");
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(content: Text('Error: Invalid receiver ID')),
                                                                                );
                                                                              }
                                                                            },
                                                                            child:
                                                                                /*CircleAvatar(
                                                                              radius: 13,
                                                                              backgroundColor: Colors.grey.shade300,
                                                                              child: Icon(
                                                                                Icons.message,
                                                                                size: 18,
                                                                                color: Colors.green.shade600,
                                                                              ),
                                                                            ),*/
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
                                                                                  print("Abhi:-print bidderId ${bidderId}");
                                                                                   await AcceptBiddingOrder (bidder?['provider_id']?['_id']?.toString() ?? '');
                                                                                   await CreatebiddingPlateformfee();
                                                                                   // showTotalDialog(context, index, bidAmount, platformFee); // BidderId ab nahi pass, class level par hai
                                                                                  if (CreatePlatformfeemessage != 'Platform fee is greater than 10% advance amount!') {
                                                                                    showTotalDialog(context, index, bidAmount, platformFee);
                                                                                  }
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

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserViewWorkerDetails(
                                                            workerId: workerId,
                                                            hirebuttonhide:
                                                                "hide",
                                                            hideonly:
                                                                "hideOnly",
                                                            oderId: widget
                                                                .buddingOderId,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                        vertical: height * 0.01,
                                                        horizontal:
                                                            width * 0.01,
                                                      ),
                                                      padding: EdgeInsets.all(
                                                          width * 0.02),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
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
                                                                      height:
                                                                          90,
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
                                                                      child:
                                                                          Text(
                                                                        fullName,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              width * 0.045,
                                                                          fontWeight:
                                                                              FontWeight.bold,
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
                                                                        Icons
                                                                            .phone,
                                                                        size:
                                                                            18,
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
                                                                              width * 0.27,
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
                                                                            padding:
                                                                                const EdgeInsets.only(left: 4.0),
                                                                            child:
                                                                                Text(
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
                                                                          GestureDetector(
                                                                            onTap: _isChatLoading
                                                                                ? null  // Disable tap while loading
                                                                                :  () async {
                                                                          final receiverId = workerId != null && workerId != null
                                                                              ? workerId?.toString() ?? 'Unknown'
                                                                              : 'Unknown';
                                                                          final fullNamed = workerId != null && workerId != null
                                                                              ? fullName ?? 'Unknown'
                                                                              : 'Unknown';
                                                                          print(
                                                                              "Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullNamed");
                                                                          if (receiverId != 'Unknown' &&
                                                                              receiverId.isNotEmpty) {
                                                                            // await _startOrFetchConversation(context,
                                                                            //     receiverId);
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
                                                                          } else {
                                                                            print("Abhi:- Error: Invalid receiver ID");
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(content: Text('Error: Invalid receiver ID')),
                                                                            );
                                                                          }
                                                                        },
                                                                        child:
                                                                            /*CircleAvatar(
                                                                          radius:
                                                                              13,
                                                                          backgroundColor: Colors
                                                                              .grey
                                                                              .shade300,
                                                                          child:
                                                                              Icon(
                                                                            Icons.message,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                Colors.green.shade600,
                                                                          ),
                                                                        ),*/

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
                                                                              workerId: workerId,
                                                                              hirebuttonhide: "hide",
                                                                              hideonly: "hideOnly",
                                                                              oderId: widget.buddingOderId,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                        minimumSize: const Size(
                                                                            0,
                                                                            25),
                                                                        tapTargetSize:
                                                                            MaterialTapTargetSize.shrinkWrap,
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        "View Profile",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              width * 0.032,
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
                                                                            color:
                                                                                Colors.green.shade700,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              "Invite",
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
                        data?['hire_status'] == 'accepted'  && data?['platform_fee_paid'] == true
                            ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Remaining Amount : ${data?['service_payment']?['remaining_amount']}",style: TextStyle(color: Colors.green[600],fontWeight: FontWeight.w600),),
                            ): SizedBox(),
                        data?['hire_status'] == 'accepted' && data?['platform_fee_paid'] == true
                            ? BiddingPaymentScreen(
                          RemainingAmount: data?['service_payment']?['remaining_amount'],
                                orderId: widget.buddingOderId ?? "",
                                paymentHistory: data?['service_payment']?['payment_history'],
                                orderProviderId: data?['service_provider_id']
                                    ?['_id'],
                              )
                            : SizedBox(),
                        data?['hire_status'] == 'accepted' && data?['platform_fee_paid'] == false
                            ?  Padding(padding: EdgeInsets.all(12),child:  Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                children: [
                                  Text("You haven’t completed your payment yet. Please complete the payment by tapping the ‘Pay’ button to unlock and access all app features."),
                                 Container(
                                   decoration: BoxDecoration(color: Colors.green[600],borderRadius: BorderRadius.circular(12)),
                                   child: TextButton(onPressed: () async {
                                     await AcceptBiddingOrder (data?['service_provider_id']?['_id']?.toString() ?? '');
                                     await CreatebiddingPlateformfee();
                                     showTotalDialog(context, 0, data?['service_provider_id']?['_id'], platformFee);
                                   }, child: Text("Pay",style: TextStyle(fontSize: 18,color: Colors.white),)),
                                 )
                                ],
                              ),),
                          ),
                        ),) : SizedBox(),
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
                                oderId: widget.buddingOderId,
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
    int totalAmount = bidAmountValue /*+ fee*/;

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
                          CustomSnackBar.show(
                              message: "Platform fee or order ID not available",
                              type: SnackBarType.error);
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
