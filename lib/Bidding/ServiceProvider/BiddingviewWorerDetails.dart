import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/bidding_order.dart'; // BiddingOrder model import kiya gaya

class BiddingViewWorkDetails extends StatefulWidget {
  final String orderId;

  const BiddingViewWorkDetails({Key? key, required this.orderId})
      : super(key: key);

  @override
  _BiddingViewWorkDetailsState createState() => _BiddingViewWorkDetailsState();
}

class _BiddingViewWorkDetailsState extends State<BiddingViewWorkDetails> {
  int _selectedIndex = 0; // 0 for Bidders tab, 1 for Related Worker tab
  List<Map<String, dynamic>> bidders = []; // Bidders ki list, API se aayegi
  List<Map<String, dynamic>> relatedWorkers =
      []; // Workers ki list, API se fill hogi
  BiddingOrder? biddingOrder; // Order ka data store karne ke liye
  bool isLoading = true; // Jab data fetch ho raha ho
  String errorMessage = ''; // Agar kuch galat ho toh message yahan
  String? currentUserId; // Current user ka ID
  bool hasAlreadyBid = false; // Check karega ki user ne bid daali ya nahi

  @override
  void initState() {
    super.initState();
    // Pehle order ka data fetch karo, phir related workers aur bidders
    fetchBiddingOrder().then((_) {
      if (biddingOrder != null && biddingOrder!.categoryId.isNotEmpty) {
        print('✅ Bidding Order Mil Gaya: ${biddingOrder!.title}');
        print('✅ Category ID: ${biddingOrder!.categoryId}');
        print('✅ Subcategory IDs: ${biddingOrder!.subcategoryIds}');
        fetchRelatedWorkers(); // Agar order valid hai toh workers fetch karo
      } else {
        setState(() {
          errorMessage = 'Bhai, bidding order ya category ID nahi mila!';
          isLoading = false;
        });
        print('❌ Order ya category ID mein kuch gadbad hai');
      }
      fetchBidders(); // Bidders ka data bhi lao
      fetchCurrentUserId(); // Current user ka ID nikaalo
      checkIfAlreadyBid(); // Check karo ki bid daali hai ya nahi
    });
  }

  // Current user ka ID token se nikaalne ka function
  Future<void> fetchCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        print('❌ Bhai, token nahi mila!');
        return;
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Token ka format galat hai!');
        return;
      }
      final payload = jsonDecode(String.fromCharCodes(
          base64Url.decode(base64Url.normalize(parts[1]))));
      setState(() {
        currentUserId = payload['id']?.toString();
      });
      print('👤 Current User ID: $currentUserId');
    } catch (e) {
      print('❌ User ID nikaalne mein error: $e');
    }
  }

  // Check karo ki user ne is order pe bid daali hai ya nahi
  Future<void> checkIfAlreadyBid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        print('❌ Token nahi mila, bid check nahi kar sakte!');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://api.thebharatworks.com/api/bidding-order/getBiddingOffers/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Bid Check ka Response Status: ${response.statusCode}');
      print('📥 Bid Check ka Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          List<dynamic> offers = jsonData['data'];
          setState(() {
            hasAlreadyBid = offers.any((offer) =>
                offer['provider_id']['_id'] == currentUserId ||
                offer['user_id'] == currentUserId);
          });
          print('👀 User ne bid daali hai kya? $hasAlreadyBid');
        }
      }
    } catch (e) {
      print('❌ Bid check karte waqt error: $e');
    }
  }

  // Bidding order ka data fetch karne ka function
  Future<void> fetchBiddingOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Bhai, token nahi mila! Phir se login karo.';
          isLoading = false;
        });
        print('❌ SharedPreferences mein token nahi mila');
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
            biddingOrder = BiddingOrder.fromJson(jsonData['data']);
            isLoading = false;
          });
          print('✅ Bidding Order: ${biddingOrder!.title}');
          print('✅ Image URLs: ${biddingOrder!.imageUrls}');
          print('👤 Order Owner ID: ${biddingOrder!.userId}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Data fetch nahi hua!';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Nahi chalega! Phir se login karo.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Kuch toh gadbad hai: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ API Error: $e');
      setState(() {
        errorMessage = 'Bhai, kuch toh galat ho gaya: $e';
        isLoading = false;
      });
    }
  }

  // Bidders ka data fetch karne ka function
  Future<void> fetchBidders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Token nahi mila, bhai! Login karo phir se.';
          isLoading = false;
        });
        print('❌ SharedPreferences mein token nahi hai');
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
          setState(() {
            bidders = offers.map((offer) {
              return {
                'name': offer['provider_id']['full_name'] ?? 'Koi Naam Nahi',
                'amount': '₹${offer['bid_amount'].toStringAsFixed(2)}',
                'location': 'Pata Nahi Kahan',
                'rating': (offer['provider_id']['rating'] ?? 0).toDouble(),
                'status': offer['status'] ?? 'pending',
                'viewed': false,
              };
            }).toList();
            isLoading = false;
          });
          print('✅ Bidders mil gaye: ${bidders.length}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Bidders ka data nahi mila!';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Bhai, unauthorized hai! Phir se login kar.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error aaya: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Bidders API mein error: $e');
      setState(() {
        errorMessage = 'Kuch toh gadbad hai bhai: $e';
        isLoading = false;
      });
    }
  }

  // Related workers ka data fetch karne ka function
  Future<void> fetchRelatedWorkers() async {
    try {
      // Check karo ki bidding order aur category ID hai ya nahi
      if (biddingOrder == null || biddingOrder!.categoryId.isEmpty) {
        setState(() {
          errorMessage = 'Order ka details ya category ID nahi mila bhai!';
          isLoading = false;
        });
        print('❌ Bidding order ya category ID nahi hai');
        return;
      }

      // Agar subcategory IDs nahi hain toh check karo
      if (biddingOrder!.subcategoryIds.isEmpty) {
        print('⚠️ Subcategory IDs khali hain, API ke hisaab se dekho');
      }

      setState(() {
        isLoading = true; // Loading shuru karo
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          errorMessage = 'Token nahi mila! Phir se login karo.';
          isLoading = false;
        });
        print('❌ Token nahi mila SharedPreferences mein');
        return;
      }
      print('🔐 Token: $token');

      // Payload banao API ke liye
      final payload = {
        'category_id': biddingOrder!.categoryId,
        'subcategory_ids': biddingOrder!.subcategoryIds,
      };

      print('📤 Payload bhej rahe hain: ${jsonEncode(payload)}');

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
                'name': provider['full_name'] ?? 'Koi Naam Nahi',
                'amount':
                    '₹${biddingOrder?.cost.toStringAsFixed(2) ?? '1500.00'}',
                'location':
                    provider['location']['address'] ?? 'Pata Nahi Kahan',
                'rating': (provider['rateAndReviews']?.isNotEmpty ?? false)
                    ? provider['rateAndReviews']
                            .map((review) => review['rating'])
                            .reduce((a, b) => a + b) /
                        provider['rateAndReviews'].length
                    : 0.0,
                'viewed': false,
              };
            }).toList();
            isLoading = false;
          });
          print('✅ Related Workers mil gaye: ${relatedWorkers.length}');
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Workers ka data nahi mila!';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized bhai! Phir se login karo.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error aaya: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Related Workers API mein error: $e');
      setState(() {
        errorMessage = 'Kuch toh galat ho gaya: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
