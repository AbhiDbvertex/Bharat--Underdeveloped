import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Bidding/ServiceProvider/BiddingWorkerList.dart';
import 'package:developer/directHiring/views/ServiceProvider/WorkerListViewProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Widgets/AppColors.dart';
import '../../chat/APIServices.dart';
import '../../chat/SocketService.dart';
import '../../chat/chatScreen.dart';
import '../../directHiring/views/ServiceProvider/view_user_profile_screen.dart';
import '../../utility/custom_snack_bar.dart';
import '../Models/bidding_order.dart';
import 'BiddingWorkerDisputeScreen.dart';

// Worker Model for parsing API data
class Worker {
  final String id;
  final String name;
  final String address;
  final String image;

  Worker({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ?? '';
    final fullImageUrl = rawImage.startsWith('http')
        ? rawImage.replaceFirst('http://', 'https://')
        : 'https://via.placeholder.com/150';
    print('🖼️ Worker image URL: $fullImageUrl');

    return Worker(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['address'] ?? 'Unknown',
      image: fullImageUrl,
    );
  }
}

class Biddingserviceproviderworkdetail extends StatefulWidget {
  final String orderId;
  final String hireStatus;

  const Biddingserviceproviderworkdetail({
    Key? key,
    required this.orderId,
    required this.hireStatus,
  }) : super(key: key);

  String get id => orderId; // Alias orderId

  @override
  _BiddingserviceproviderworkdetailState createState() =>
      _BiddingserviceproviderworkdetailState();
}

class _BiddingserviceproviderworkdetailState
    extends State<Biddingserviceproviderworkdetail> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> bidders = [];
  List<Map<String, dynamic>> relatedWorkers = [];
  BiddingOrder? biddingOrder;
  Worker? assignedWorker;
  bool isLoading = true;
  String errorMessage = '';
  String? currentUserId;
  bool hasAlreadyBid = false;
  String? biddingOfferId;
  String? negotiationId;
  String offerPrice = '';

  @override
  void initState() {
    super.initState();
    fetchBiddingOrder().then((_) {
      if (biddingOrder != null && biddingOrder!.categoryId.isNotEmpty) {
        print('✅ Bidding Order Ready: ${biddingOrder!.title}');
        print('✅ Category ID: ${biddingOrder!.categoryId}');
        print('✅ Subcategory IDs: ${biddingOrder!.subcategoryIds}');
        setState(() {
          offerPrice = '₹${biddingOrder!.cost.toStringAsFixed(2)}';
        });
        if (widget.hireStatus.toLowerCase() == 'pending') {
          fetchRelatedWorkers();
          fetchBidders();
          fetchLatestNegotiation();
        }
        fetchCurrentUserId();
        if (widget.hireStatus.toLowerCase() == 'accepted') {
          fetchAssignedWorker();
        }
      } else {
        setState(() {
          errorMessage = 'Bidding order details ya category ID nahi mila.';
          isLoading = false;
        });
        print('❌ Bidding order ya category ID invalid hai');
      }
    });
  }

  var name;
  var imge;
  var address;

  Future<void> openMap(double lat, double lng) async {
    final Uri googleMapUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open the map.";
    }
  }

  Future<void> fetchCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) return;

      final parts = token.split('.');
      if (parts.length != 3) return;
      final payload = jsonDecode(String.fromCharCodes(
          base64Url.decode(base64Url.normalize(parts[1]))));
      setState(() {
        currentUserId = payload['id']?.toString();
      });
      print('👤 Current User ID: $currentUserId');
    } catch (e) {
      print('❌ Error fetching user ID: $e');
    }
  }

  Future<void> fetchBiddingOrder() async {
    try {
      print('🔍 Fetching bidding order for ID: ${widget.orderId}');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Token nahi mila, bhai! Login kar phir se.';
          isLoading = false;
        });
        return;
      }
      print('🔐 Token: $token');

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/getBiddingOrderById/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            name = jsonData['data']?['assignedWorker']?['name'] ?? "hnbhk";
            biddingOrder = BiddingOrder.fromJson(jsonData['data']);
            isLoading = false;
          });
          print('✅ Bidding Order: ${biddingOrder!.title}');
          print('✅ Bidding Order assignworker name: ${name}');
          print('✅ Image URLs: ${biddingOrder!.imageUrls}');
          print('👤 Order Owner ID: ${biddingOrder!.userId}');
          print(
              '👷 Assigned Worker: ${biddingOrder!.assignedWorker?.name ?? 'Koi worker assign nahi'}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Data fetch nahi hua';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Phir se login karo, bhai!';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ API Error: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchBidders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'No token found. Please log in again.';
          isLoading = false;
        });
        print('❌ No token found in SharedPreferences');
        return;
      }
      print('🔐 Token: $token');

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Bidders Response Status: ${response.statusCode}');
      print('📥 Bidders Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          List<dynamic> offers = jsonData['data'];
          print('📋 Offers: $offers');
          setState(() {
            bidders = offers.map((offer) {
              print(
                  '🔍 Checking offer for provider: ${offer['provider_id']['_id']}');
              if (offer['provider_id']['_id'] == currentUserId) {
                biddingOfferId = offer['_id'];
                hasAlreadyBid = true;
                print('✅ Found biddingOfferId: $biddingOfferId');
              }
              return {
                'bid_amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
                'offer_id': offer['_id'],
                'name': offer['provider_id']['full_name'] ?? 'Unknown',
                'status': offer['status'] ?? 'Pending',
                'address':
                    offer['provider_id']['location']['address'] ?? 'Unknown',
              };
            }).toList();
            isLoading = false;
          });
          print('✅ Bidders fetched: ${bidders.length}');
          print('✅ biddingOfferId: $biddingOfferId');
          print('✅ hasAlreadyBid: $hasAlreadyBid');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Failed to fetch bidders';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Please log in again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Bidders API Error: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchRelatedWorkers() async {
    try {
      if (biddingOrder == null || biddingOrder!.categoryId.isEmpty) {
        setState(() {
          errorMessage = 'Order details ya category ID nahi mila.';
          isLoading = false;
        });
        print('❌ Bidding order ya category ID nahi hai');
        return;
      }

      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Koi token nahi mila. Phir se login karo.';
          isLoading = false;
        });
        print('❌ Token nahi mila SharedPreferences mein');
        return;
      }
      print('🔐 Token: $token');

      final payload = {
        'category_id': biddingOrder!.categoryId,
        'subcategory_ids': biddingOrder!.subcategoryIds,
      };

      print('📤 Payload bheja ja raha: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(
            'https://api.thebharatworks.com/api/user/getServiceProviders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Related Workers Response Status: ${response.statusCode}');
      print('📥 Related Workers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          List<dynamic> providers = jsonData['data'];
          setState(() {
            relatedWorkers = providers.map((provider) {
              return {
                'name': provider['full_name'] ?? 'Unknown',
                'amount':
                    '₹${biddingOrder?.cost.toStringAsFixed(2) ?? '1500.00'}',
                'location':
                    provider['location']['address'] ?? 'Unknown Location',
                'rating': (provider['rateAndReviews']?.isNotEmpty ?? false)
                    ? provider['rateAndReviews']
                            .map((review) => review['rating'])
                            .reduce((a, b) => a + b) /
                        provider['rateAndReviews'].length
                    : 0.0,
                'viewed': false,
                'provider_id': provider['_id'],
              };
            }).toList();
            isLoading = false;
          });
          print('✅ Related Workers mile: ${relatedWorkers.length}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Service providers nahi mile';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Phir se login karo.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Related Workers API Error: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchAssignedWorker() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Token nahi mila, bhai! Login kar phir se.';
          isLoading = false;
        });
        print('❌ Token nahi mila SharedPreferences mein');
        return;
      }
      print('🔐 Token: $token');

      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/worker/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Worker Response Status: ${response.statusCode}');
      print('📥 Worker Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List workerList = jsonData['workers'];
        for (var workerJson in workerList) {
          final List assignOrders = workerJson['assignOrders'] ?? [];
          for (var order in assignOrders) {
            if (order['order_id'] == widget.orderId &&
                order['type'] == 'bidding') {
              setState(() {
                assignedWorker = Worker.fromJson(workerJson);
                isLoading = false;
              });
              print('✅ Assigned Worker: ${assignedWorker!.name}');
              return;
            }
          }
        }
        setState(() {
          isLoading = false;
          assignedWorker = null;
        });
        print('⚠️ No assigned worker found for order ${widget.orderId}');
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Phir se login karo, bhai!';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Worker API Error: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  var editbidAmount;
  var editbidmassage;
  var editbidduration;

  // submit bid
  Future<void> submitBid(
      String amount, String description, String duration) async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });


        CustomSnackBar.show(
            message:  'No token found. Please log in again.' ,
            type: SnackBarType.error
        );
        return;
      }

      if (amount.isEmpty || description.isEmpty || duration.isEmpty) {
        setState(() {
          isLoading = false;
        });


        CustomSnackBar.show(
            message:  'Please fill all fields',
            type: SnackBarType.error
        );
        return;
      }

      double? bidAmount;
      int? bidDuration;
      try {
        bidAmount = double.parse(amount);
        bidDuration = int.parse(duration);
        if (bidAmount <= 0 || bidDuration <= 0) {
          throw FormatException('Amount aur duration positive hone chahiye');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
             CustomSnackBar.show(
            message:  'Invalid amount ya duration format',
            type: SnackBarType.error
        );
        return;
      }

      final payload = {
        'order_id': widget.orderId,
        'bid_amount': bidAmount.toString(),
        'duration': bidDuration,
        'message': description,
      };

      print('Abhi:- Sending Bid Payload: ${jsonEncode(payload)}');
      print('Abhi:- Using Token: $token');

      final response = await http.post(
        Uri.parse('https://api.thebharatworks.com/api/bidding-order/placeBid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('Abhi:- Bid Response Status: ${response.statusCode}');
      print('Abhi:- Bid Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            isLoading = false;
            hasAlreadyBid = true;
            biddingOfferId = jsonData['data']['_id'];
            editbidAmount = jsonData['data']['bid_amount'];
            editbidmassage = jsonData['data']['message'];
            editbidduration = jsonData['data']['duration'];
          });
          print('Abhi:- Bid placed, biddingOfferId: $biddingOfferId');

          CustomSnackBar.show(
              message:  'Bid successfully placed!',
              type: SnackBarType.success
          );

          fetchBidders();
        } else {
          setState(() {
            isLoading = false;
          });
                CustomSnackBar.show(
              message: jsonData['message'] ?? 'Failed to place bid',
              type: SnackBarType.error
          );

        }
      } else if (response.statusCode == 400) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          isLoading = false;
          if (jsonData['message'] ==
              'You have already placed a bid on this order.') {
            hasAlreadyBid = true;
          }
        });


        CustomSnackBar.show(
            message: jsonData['message'] ?? 'Invalid request data',
            type: SnackBarType.error
        );

      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unauthorized: Please log in again.';
        });


        CustomSnackBar.show(
            message:    'Unauthorized: Please log in again.',
            type: SnackBarType.error
        );

      } else {
        setState(() {
          isLoading = false;
        });

        CustomSnackBar.show(
            message:"Something went wrong ! ${response.statusCode} ",
            type: SnackBarType.error
        );
      }
    } catch (e) {
      print('Abhi:- Bid API Error: $e');
      setState(() {
        isLoading = false;
      });
      CustomSnackBar.show(
          message:"Something went wrong !" ,
          type: SnackBarType.error
      );
    }
  }

  //   edit bid api
  Future<void> editBid(editbidAmout, editbidduration, editbidmessage) async {
    final String url = "https://api.thebharatworks.com/api/bidding-order/edit";
    print("Abhi:- print editbid url : $url");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final payload = {
      'order_id': widget.orderId,
      'bid_amount': editbidAmout.toString(),
      'duration': editbidduration,
      'message': editbidmessage,
    };

    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // body: jsonEncode(payload),
      body: jsonEncode(payload),
    );

    print("Abhi:- edit bid amount print : $payload");

    var responseData = jsonDecode(response.body);
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {

        CustomSnackBar.show(
            message: responseData['message'],
            type: SnackBarType.success
        );


        print("Abhi:- editbide response :${response.statusCode}");
        print("Abhi:- editbide response :${response.body}");
      } else {
        print("Abhi:- editbide response :${response.statusCode}");
        print("Abhi:- editbide response :${response.body}");
      }
    } catch (e) {
      print("Abhi:- editbid Exception");
    }
  }

  //      Negotiation tab
  Future<void> startNegotiation(String amount) async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });

        CustomSnackBar.show(
            message:  'No token found. Please log in again.',
            type: SnackBarType.error
        );
        return;
      }

      if (amount.isEmpty) {
        setState(() {
          isLoading = false;
        });
        CustomSnackBar.show(
            message:  'Please enter an amount',
            type: SnackBarType.error
        );

        return;
      }

      double? offerAmount;
      try {
        offerAmount = double.parse(amount);
        if (offerAmount <= 0) {
          throw FormatException('Amount positive hona chahiye');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        CustomSnackBar.show(
            message:  'Invalid amount format',
            type: SnackBarType.error
        );
        return;
      }
print("user: ${biddingOrder!.userId?.id}");
      final payload = {
        'order_id': widget.orderId,
        'bidding_offer_id': biddingOfferId,
        'service_provider': currentUserId,
        'user': biddingOrder!.userId?.id,
        'initiator': 'service_provider',
        'offer_amount': offerAmount,
      };

      print('📤 Sending Negotiation Payload: ${jsonEncode(payload)}');
      print('🔐 Using Token: $token');

      final response = await http.post(
        Uri.parse('https://api.thebharatworks.com/api/negotiations/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Negotiation Response Status: ${response.statusCode}');
      print('📥 Negotiation Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] == 'Negotiation started') {
          setState(() {
            isLoading = false;
            negotiationId = jsonData['negotiation']['_id'];
            offerPrice = '₹${offerAmount?.toStringAsFixed(2)}';
            print('✅ Setting offerPrice in setState: $offerPrice');
          });
          print('✅ Negotiation started, negotiationId: $negotiationId');
          print('✅ Updated offerPrice: $offerPrice');

          CustomSnackBar.show(
              message:'Negotiation request sent successfully!',
              type: SnackBarType.success
          );
          await fetchLatestNegotiation();
        } else {
          setState(() {
            isLoading = false;
          });

          CustomSnackBar.show(
              message:jsonData['message'] ?? 'Failed to start negotiation' ,
              type: SnackBarType.error
          );
        }
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unauthorized: Please log in again.';
        });

        CustomSnackBar.show(
            message: 'Unauthorized: Please log in again.',
            type: SnackBarType.error
        );
      } else {
        setState(() {
          isLoading = false;
        });

        CustomSnackBar.show(
            message:  'Error: ${response.statusCode}',
            type: SnackBarType.error
        );
      }
    } catch (e) {
      print('❌ Negotiation API Error: $e');
      setState(() {
        isLoading = false;
      });
        CustomSnackBar.show(
          message: 'Error: $e',
          type: SnackBarType.error
      );
    }
  }

  Future<void> acceptNegotiation() async {
    if (negotiationId == null) {

      CustomSnackBar.show(
          message:  'No negotiation found to accept.',
          type: SnackBarType.error
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });

        CustomSnackBar.show(
            message:'No token found. Please log in again.' ,
            type: SnackBarType.error
        );
        return;
      }

      final payload = {
        'role': 'service_provider',
      };

      print('📤 Sending Accept Negotiation Payload: ${jsonEncode(payload)}');
      print('🔐 Using Token: $token');

      final response = await http.put(
        Uri.parse(
            'https://api.thebharatworks.com/api/negotiations/accept/$negotiationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📥 Accept Negotiation Response Status: ${response.statusCode}');
      print('📥 Accept Negotiation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] == 'Negotiation accepted') {
          setState(() {
            isLoading = false;
            offerPrice =
                '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
            print('✅ Setting offerPrice in acceptNegotiation: $offerPrice');
          });

          CustomSnackBar.show(
              message:  'Negotiation accepted successfully!',
              type: SnackBarType.success
          );
          await fetchLatestNegotiation();
        } else {
          setState(() {
            isLoading = false;
          });


          CustomSnackBar.show(
              message:jsonData['message'] ?? 'Failed to accept negotiation' ,
              type: SnackBarType.error
          );

        }
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unauthorized: Please log in again.';
        });


        CustomSnackBar.show(
            message: 'Unauthorized: Please log in again.',
            type: SnackBarType.error
        );

      } else {
        setState(() {
          isLoading = false;
        });


        CustomSnackBar.show(
            message:'Error: ${response.statusCode}' ,
            type: SnackBarType.error
        );


      }
    } catch (e) {
      print('❌ Accept Negotiation API Error: $e');
      setState(() {
        isLoading = false;
      });


      CustomSnackBar.show(
          message: 'Error: $e',
          type: SnackBarType.error
      );

    }
  }

  Future<void> fetchLatestNegotiation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        print('❌ No token found for fetching latest negotiation');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/negotiations/latest/${widget.orderId}/${biddingOfferId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Latest Negotiation Response Status: ${response.statusCode}');
      print('📥 Latest Negotiation Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['message'] == 'Negotiation found') {
          setState(() {
            offerPrice =
                '₹${jsonData['negotiation']['offer_amount'].toStringAsFixed(2)}';
            negotiationId = jsonData['negotiation']['_id'];
            print(
                '✅ Setting offerPrice in fetchLatestNegotiation: $offerPrice');
          });
          print('✅ Latest offerPrice: $offerPrice');
          print('✅ Latest negotiationId: $negotiationId');
        } else {
          print(
              '⚠️ No negotiation found or unexpected message: ${jsonData['message']}');
        }
      } else {
        print('⚠️ Failed to fetch latest negotiation: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Fetch Latest Negotiation Error: $e');
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

  String getCurrentUserBidAmount() {
    if (bidders.isNotEmpty) {
      for (var bidder in bidders) {
        if (bidder['offer_id'] == biddingOfferId) {
          return bidder['bid_amount'];
        }
      }
      return bidders[0]['bid_amount'];
    }
    return biddingOrder != null
        ? '₹${biddingOrder!.cost.toStringAsFixed(2)}'
        : '₹0.00';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    print('Building Biddingserviceproviderworkdetail with offerPrice: $offerPrice, hireStatus: ${widget.hireStatus}');

    if (isLoading || biddingOrder == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: height * 0.03,
          automaticallyImplyLeading: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: height * 0.03,
          automaticallyImplyLeading: false,
        ),
        body: Center(child: Text(errorMessage)),
      );
    }

    bool isAccepted = widget.hireStatus.toLowerCase() == 'accepted';
    bool isPending = widget.hireStatus.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Work Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: height * 0.01),
                // Row(
                //   children: [
                //     GestureDetector(
                //       onTap: () => Navigator.pop(context),
                //       child: Padding(
                //         padding: EdgeInsets.only(left: width * 0.02),
                //         child: Icon(Icons.arrow_back, size: width * 0.06),
                //       ),
                //     ),
                //     SizedBox(width: width * 0.25),
                //     Text(
                //       "",
                //       style: GoogleFonts.roboto(
                //         fontSize: width * 0.045,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.black,
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: height * 0.01),
                Padding(
                  padding: EdgeInsets.all(width * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.grey,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: height * 0.25,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            viewportFraction: 1,
                          ),
                          items: biddingOrder!.imageUrls.isNotEmpty
                              ? biddingOrder!.imageUrls.map((item) {
                                  print('🖼️ Image: $item');
                                  return ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    child: Image.network(
                                      item,
                                      // fit: BoxFit.cover,
                                      width: width,
                                      errorBuilder: (context, error, stackTrace) {
                                        print(
                                            'Image error: $item, Error: $error');
                                        return Image.asset(
                                          'assets/images/chair.png',
                                          fit: BoxFit.cover,
                                          width: width,
                                        );
                                      },
                                    ),
                                  );
                                }).toList()
                              : [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(width * 0.025),
                                    child: Image.asset(
                                      'assets/images/chair.png',
                                      fit: BoxFit.cover,
                                      width: width,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                      SizedBox(height: height * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                openMap(
                                  biddingOrder?.latitude ?? 0.0,
                                  biddingOrder?.longitude ?? 0.0,
                                );
                                print(
                                    "Abhi:- print latitude : ${biddingOrder?.latitude ?? 0.0} logiture ${biddingOrder?.longitude ?? 0.0}");
                              },
                              child: Container(
                                height: height * 0.03,
                                width: width * 0.4,
                                // padding: EdgeInsets.symmetric(
                                //   horizontal: width * 0.06,
                                //   vertical: height * 0.005,
                                // ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade300,
                                  borderRadius:
                                      BorderRadius.circular(width * 0.02),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    // biddingOrder!.address,
                                    biddingOrder?.userId?.location?.address ??
                                        "No data",
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: width * 0.03,
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
                              biddingOrder?.projectId ?? "No data",
                              style: TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          )
                        ],
                      ),
                      SizedBox(height: height * 0.015),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.02),
                        child: Text(
                          biddingOrder!.title,
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.02),
                        child: Text(
                          'Completion Date  : ${biddingOrder!.deadline.split('T').first}',
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    // ),
                    // SizedBox(height: height * 0.005),
                    // Padding(
                    //   padding: EdgeInsets.only(left: width * 0.02),
                    //   child: Text(
                    //     'Completion Date : ${biddingOrder!.deadline.split('T').first}',
                    //     style: TextStyle(
                    //       fontSize: width * 0.035,
                    //       color: Colors.grey,

                      SizedBox(height: height * 0.015),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.02),
                        child: Text(
                          '₹${biddingOrder!.cost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: width * 0.05,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),

                        ),
                      ),
                      SizedBox(height: height * 0.015),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.02),
                        child: Text(
                          'Task Details',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Padding(
                        padding: EdgeInsets.only(left: width * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: biddingOrder!.description
                              .split('.')
                              .where((s) => s.trim().isNotEmpty)
                              .map((s) => Padding(
                                    padding:
                                        EdgeInsets.only(bottom: height * 0.004),
                                    child: Text(
                                      '• $s',
                                      style: TextStyle(fontSize: width * 0.035),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      biddingOrder?.hireStatus == 'cancelled'
                          ? Center(
                              child: Container(
                                height: 35,
                                width: 250,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          biddingOrder!.userId?.fullName ??
                                              'Unknown',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.withOpacity(0.1),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.call,
                                              color: Colors.green.shade700,
                                              size: 14,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          'Awarded amount: ₹${biddingOrder!.cost.toStringAsFixed(0)}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 17,
                                        ),
                                        Spacer(),
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.withOpacity(0.1),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.message_rounded,
                                              color: Colors.green.shade700,
                                              size: 14,
                                            ),
                                            onPressed: ()  async {
                                              final receiverId =  biddingOrder!.userId?.id != null && biddingOrder!.userId?.id != null
                                                  ? biddingOrder!.userId?.id.toString() ?? 'Unknown'
                                                  : 'Unknown';
                                              final fullNamed = biddingOrder!.userId?.id != null && biddingOrder!.userId?.id != null
                                                  ?   biddingOrder!.userId?.fullName ?? 'Unknown'
                                                  : 'Unknown';
                                              print("Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullNamed");
                                              if (receiverId != 'Unknown' && receiverId.isNotEmpty) {
                                                await _startOrFetchConversation(context, receiverId);
                                              } else {
                                                print("Abhi:- Error: Invalid receiver ID");
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error: Invalid receiver ID')),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                //     SizedBox(
                                //       height: height * 0.008,
                                //     Icon(Icons.warning_amber, color: Colors.red),
                                //     Text(
                                //       "This order is cancelled",
                                //       style: TextStyle(
                                //           fontWeight: FontWeight.w600,
                                //           color: Colors.red),
                                //     ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      biddingOrder?.hireStatus == 'cancelledDispute'
                          ? Center(
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning_amber, color: Colors.red),
                                    Flexible(
                                        child: Text(
                                      "The order has been cancelled due to a dispute.",
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red),
                                    )),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      biddingOrder?.hireStatus == 'completed'
                          ? Center(
                              child: Container(
                                height: 35,
                                width: 300,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      biddingOrder?.hireStatus == 'rejected'
                          ? Center(
                              child: Container(
                                height: 35,
                                width: 300,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey)),
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
                      if (isAccepted) ...[
                        Card(
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: biddingOrder!.userId != null &&
                                          biddingOrder!.userId!.profilePic !=
                                              null &&
                                          biddingOrder!
                                              .userId!.profilePic!.isNotEmpty
                                      ? Image.network(
                                          biddingOrder!.userId!.profilePic!
                                                  .startsWith('http')
                                              ? biddingOrder!.userId!.profilePic!
                                                  .replaceFirst(
                                                      'http://', 'https://')
                                              : 'https://api.thebharatworks.com${biddingOrder!.userId!.profilePic}',
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                '❌ Profile image error: ${biddingOrder!.userId!.profilePic}');
                                            return Image.asset(
                                              'assets/images/d_png/no_profile_image.png',
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/d_png/no_profile_image.png',
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            biddingOrder!.userId?.fullName ??
                                                'Unknown',
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.withOpacity(0.1),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.call,
                                                color: Colors.green.shade700,
                                                size: 14,
                                              ),
                                              onPressed: () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(
                                            'Awarded amount: ₹${biddingOrder!.cost.toStringAsFixed(0)}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 17,
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.withOpacity(0.1),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.message_rounded,
                                                color: Colors.green.shade700,
                                                size: 14,
                                              ),
                                              onPressed: () {},
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: height * 0.008,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewUserProfileScreen(
                                                          userId: biddingOrder!
                                                                  .userId?.id ??
                                                              'Unknown',
                                                          profileImage: biddingOrder!
                                                                  .userId
                                                                  ?.profilePic ??
                                                              'Unknown',
                                                        )));
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
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BiddingWorkerList(orderId: widget.id),
                              ),
                            );
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
                        // Conditionally show assigned worker card only if assignedWorker is not null
                        if (isAccepted && assignedWorker != null) ...[
                          SizedBox(height: 20),
                          Card(
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      assignedWorker!.image,
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print(
                                            '❌ Worker image error: ${assignedWorker!.image}');
                                        return Image.asset(
                                          'assets/images/d_png/no_profile_image.png',
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              assignedWorker!.name,
                                              style: GoogleFonts.roboto(
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              assignedWorker!.address,
                                              style: GoogleFonts.roboto(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        WorkerListViewProfileScreen(
                                                      workerId:
                                                          assignedWorker!.id,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 30,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade700,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "View",
                                                    style: GoogleFonts.roboto(
                                                      color: Colors.white,
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
                          ),
                        ],
                        if (isAccepted) ...[
                          SizedBox(height: 20),
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
                                      'Payment Details',
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
                                  if (biddingOrder!.servicePayment != null &&
                                      biddingOrder!.servicePayment![
                                              'payment_history'] !=
                                          null &&
                                      biddingOrder!
                                          .servicePayment!['payment_history']
                                          .isNotEmpty)
                                    ...List.generate(
                                      biddingOrder!
                                          .servicePayment!['payment_history']
                                          .length,
                                      (index) {
                                        final item =
                                            biddingOrder!.servicePayment![
                                                'payment_history'][index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    flex: 2,
                                                    child: Text(
                                                      "${index + 1}. ${item['description'] ?? 'No Description'}",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 3,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            "${item['status'] == 'success' ? 'Paid' : item['status'] == 'pending' ? 'Pending' : 'Failed'}",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color: item['status'] ==
                                                                      'success'
                                                                  ? Colors.green
                                                                  : item['status'] ==
                                                                          'pending'
                                                                      ? Colors
                                                                          .orange
                                                                      : Colors
                                                                          .red,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                            ),
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Flexible(
                                                          child: Text(
                                                            "₹${item['amount']}",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                            ),
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 40),
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
                      ],
                      if (isPending) ...[
                        SizedBox(height: height * 0.02),
                        /*hasAlreadyBid ? */
                        biddingOrder!.userId == currentUserId || hasAlreadyBid
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      final TextEditingController
                                          editamountController =
                                          TextEditingController();
                                      final TextEditingController
                                          editdescriptionController =
                                          TextEditingController();
                                      final TextEditingController
                                          editdurationController =
                                          TextEditingController();
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        insetPadding: EdgeInsets.symmetric(
                                            horizontal: width * 0.05),
                                        title: Center(
                                          child: Text(
                                            "Bid",
                                            style: GoogleFonts.roboto(
                                              fontSize: width * 0.05,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        content: SingleChildScrollView(
                                          child: SizedBox(
                                            width: width * 0.8,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Enter Amount",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: width * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                TextField(
                                                  controller:
                                                      editamountController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText: "₹0.00",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              width * 0.02),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.01),
                                                Text(
                                                  "Description",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: width * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                TextField(
                                                  controller:
                                                      editdescriptionController,
                                                  maxLines: 3,
                                                  decoration: InputDecoration(
                                                    hintText: "Enter Description",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              width * 0.02),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.01),
                                                Text(
                                                  "Duration",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: width * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.005),
                                                TextField(
                                                  controller:
                                                      editdurationController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Enter Duration (in days)",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              width * 0.02),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: height * 0.015),
                                                Center(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      String editbidAmout =
                                                          editamountController
                                                              .text
                                                              .trim();
                                                      String editbidmessage =
                                                          editdescriptionController
                                                              .text
                                                              .trim();
                                                      String editbidduration =
                                                          editdurationController
                                                              .text
                                                              .trim();
                                                      print(
                                                          "Abhi:- edit bid amount print : amount : $editbidAmout editbidmessage : $editbidmessage editbidduration : $editbidduration");
                                                      editBid(
                                                          editbidAmout,
                                                          editbidduration,
                                                          editbidmessage);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: width * 0.18,
                                                        vertical: height * 0.012,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.green.shade700,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                width * 0.02),
                                                      ),
                                                      child: Text(
                                                        "Edit Bid",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: width * 0.04,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.18,
                                      vertical: height * 0.012,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade700,
                                      borderRadius:
                                          BorderRadius.circular(width * 0.02),
                                    ),
                                    child: Text(
                                      "Edit bid",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: GestureDetector(
                                  onTap: biddingOrder!.userId == currentUserId
                                      ? () {
        
                                          CustomSnackBar.show(
                                              message:  'You cannot bid on your own order',
                                              type: SnackBarType.error
                                          );
                                        }
                                      : hasAlreadyBid
                                          ? () {
        
                                              CustomSnackBar.show(
                                                  message:'You have already placed a bid on this order' ,
                                                  type: SnackBarType.error
                                              );
                                            }
                                          : () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  final TextEditingController
                                                      amountController =
                                                      TextEditingController();
                                                  final TextEditingController
                                                      descriptionController =
                                                      TextEditingController();
                                                  final TextEditingController
                                                      durationController =
                                                      TextEditingController();
                                                  return AlertDialog(
                                                    backgroundColor: Colors.white,
                                                    insetPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * 0.05),
                                                    title: Center(
                                                      child: Text(
                                                        "Bid",
                                                        style: GoogleFonts.roboto(
                                                          fontSize: width * 0.05,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: SizedBox(
                                                        width: width * 0.8,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Enter Amount",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize:
                                                                    width * 0.035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: height *
                                                                    0.005),
                                                            TextField(
                                                              controller:
                                                                  amountController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText: "₹0.00",
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(width *
                                                                              0.02),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: height *
                                                                    0.01),
                                                            Text(
                                                              "Description",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize:
                                                                    width * 0.035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: height *
                                                                    0.005),
                                                            TextField(
                                                              controller:
                                                                  descriptionController,
                                                              maxLines: 3,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    "Enter Description",
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(width *
                                                                              0.02),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: height *
                                                                    0.01),
                                                            Text(
                                                              "Duration",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                fontSize:
                                                                    width * 0.035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: height *
                                                                    0.005),
                                                            TextField(
                                                              controller:
                                                                  durationController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    "Enter Duration (in days)",
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(width *
                                                                              0.02),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: height *
                                                                    0.015),
                                                            Center(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  String amount =
                                                                      amountController
                                                                          .text
                                                                          .trim();
                                                                  String
                                                                      description =
                                                                      descriptionController
                                                                          .text
                                                                          .trim();
                                                                  String
                                                                      duration =
                                                                      durationController
                                                                          .text
                                                                          .trim();
                                                                  submitBid(
                                                                      amount,
                                                                      description,
                                                                      duration);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                    horizontal:
                                                                        width *
                                                                            0.18,
                                                                    vertical:
                                                                        height *
                                                                            0.012,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .green
                                                                        .shade700,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            width *
                                                                                0.02),
                                                                  ),
                                                                  child: Text(
                                                                    "Bid",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          width *
                                                                              0.04,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.18,
                                      vertical: height * 0.012,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          biddingOrder!.userId == currentUserId ||
                                                  hasAlreadyBid
                                              ? Colors.grey.shade400
                                              : Colors.green.shade700,
                                      borderRadius:
                                          BorderRadius.circular(width * 0.02),
                                    ),
                                    child: Text(
                                      "Bid",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(height: height * 0.02),
                        NegotiationCard(
                          key: ValueKey(offerPrice),
                          width: width,
                          height: height,
                          offerPrice: offerPrice,
                          bidAmount: getCurrentUserBidAmount(),
                          onNegotiate: (amount) {
                            if (hasAlreadyBid && biddingOfferId != null) {
                              startNegotiation(amount);
                            } else {
        
                              CustomSnackBar.show(
                                  message: 'Please place a bid first.',
                                  type: SnackBarType.error
                              );
                            }
                          },
                          onAccept: () {
                            if (hasAlreadyBid && biddingOfferId != null) {
                              acceptNegotiation();
                            } else {
        
                              CustomSnackBar.show(
                                  message: 'Please place a bid first.' ,
                                  type: SnackBarType.error
                              );
                            }
                          },
                        ),
                        SizedBox(height: height * 0.02),
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
                                        _selectedIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      height: height * 0.045,
                                      width: width * 0.40,
                                      decoration: BoxDecoration(
                                        color: _selectedIndex == 0
                                            ? Colors.green.shade700
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
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
                                                color: _selectedIndex == 0
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
                                  SizedBox(width: width * 0.0),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = 1;
                                      });
                                    },
                                    child: Container(
                                      height: height * 0.045,
                                      width: width * 0.40,
                                      decoration: BoxDecoration(
                                        color: _selectedIndex == 1
                                            ? Colors.green.shade700
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
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
                                                color: _selectedIndex == 1
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
                              if (_selectedIndex == 0)
                                Padding(
                                  padding: EdgeInsets.only(top: height * 0.01),
                                  child: bidders.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No bidders found',
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: bidders.length,
                                          itemBuilder: (context, index) {
                                            final bidder = bidders[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: height * 0.01,
                                                horizontal: width * 0.01,
                                              ),
                                              padding:
                                                  EdgeInsets.all(width * 0.02),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    child: Image.asset(
                                                      "assets/images/d_png/no_profile_image.png",
                                                      height: 90,
                                                      width: 90,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(width: width * 0.03),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          bidder['name'],
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.045,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                        Text(
                                                          'Status: ${bidder['status']}',
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.035,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                        Text(
                                                          bidder['address'],
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.035,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                        Text(
                                                          bidder['bid_amount'],
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.035,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                )
                              else
                                Padding(
                                  padding: EdgeInsets.only(top: height * 0.01),
                                  child: relatedWorkers.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No related workers found',
                                            style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: relatedWorkers.length,
                                          itemBuilder: (context, index) {
                                            final worker = relatedWorkers[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: height * 0.01,
                                                horizontal: width * 0.01,
                                              ),
                                              padding:
                                                  EdgeInsets.all(width * 0.02),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    child: Image.asset(
                                                      "assets/images/d_png/no_profile_image.png",
                                                      height: 90,
                                                      width: 90,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(width: width * 0.03),
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
                                                                worker['name'],
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      width *
                                                                          0.045,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "${worker['rating']}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        width *
                                                                            0.035,
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons.star,
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
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                        Text(
                                                          worker['amount'],
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.035,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                        Text(
                                                          worker['location'],
                                                          style: TextStyle(
                                                            fontSize:
                                                                width * 0.035,
                                                            color: Colors.grey,
                                                          ),
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
                            ],
                          ),
                        ),
                      ],
                      if (isAccepted) ...[
                        SizedBox(height: height * 0.02),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BiddingWorkerDisputeScreen(
                                  orderId: widget.orderId,
                                  flowType: "bidding",
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
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NegotiationCard extends StatefulWidget {
  final double width;
  final double height;
  final String offerPrice;
  final String bidAmount;
  final Function(String) onNegotiate;
  final Function() onAccept;

  const NegotiationCard({
    Key? key,
    required this.width,
    required this.height,
    required this.offerPrice,
    required this.bidAmount,
    required this.onNegotiate,
    required this.onAccept,
  }) : super(key: key);

  @override
  _NegotiationCardState createState() => _NegotiationCardState();
}

class _NegotiationCardState extends State<NegotiationCard> {
  bool isNegotiating = false;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(
        '🖼️ NegotiationCard initialized with offerPrice: ${widget.offerPrice}');
  }

  @override
  void didUpdateWidget(NegotiationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerPrice != widget.offerPrice) {
      print(
          '🖼️ NegotiationCard updated with new offerPrice: ${widget.offerPrice}');
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        '🖼️ NegotiationCard rebuilding with offerPrice: ${widget.offerPrice}');
    return Card(
      color: Colors.white,
      child: Container(
        width: widget.width,
        padding: EdgeInsets.all(widget.width * 0.04),
        child: Column(
          children: [
            Container(
              width: widget.width,
              padding: EdgeInsets.all(widget.width * 0.015),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.width * 0.02),
                color: Colors.green.shade100,
              ),
              child: Row(
                children: [
                  SizedBox(width: widget.width * 0.015),
                  Expanded(
                    child: Container(
                      height: 45,
                      padding:
                          EdgeInsets.symmetric(vertical: widget.height * 0.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.width * 0.02),
                        border: Border.all(color: Colors.green),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Offer Price",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: widget.width * 0.04,
                            ),
                          ),
                          Text(
                            widget.offerPrice,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: widget.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: widget.width * 0.015),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isNegotiating = !isNegotiating;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: widget.height * 0.015),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.width * 0.02),
                          border: Border.all(color: Colors.green.shade700),
                          color: isNegotiating
                              ? Colors.green.shade700
                              : Colors.white,
                        ),
                        child: Text(
                          "Negotiate",
                          style: GoogleFonts.roboto(
                            color: isNegotiating
                                ? Colors.white
                                : Colors.green.shade700,
                            fontSize: widget.width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.height * 0.02),
            if (isNegotiating) ...[
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter your offer Amount",
                  hintStyle: GoogleFonts.roboto(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.width * 0.04,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.width * 0.02),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                style: GoogleFonts.roboto(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.width * 0.04,
                ),
              ),
              SizedBox(height: widget.height * 0.02),
              GestureDetector(
                onTap: () {
                  String amount = amountController.text.trim();
                  widget.onNegotiate(amount);
                  setState(() {
                    isNegotiating = false;
                    amountController.clear();
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: widget.height * 0.018),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.width * 0.02),
                    color: Colors.green.shade700,
                  ),
                  child: Text(
                    "Send Request",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: widget.width * 0.04,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: widget.height * 0.02),
            GestureDetector(
              onTap: widget.onAccept,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: widget.height * 0.018),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.width * 0.02),
                  color: Colors.green.shade700,
                ),
                child: Text(
                  "Accept",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: widget.width * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
