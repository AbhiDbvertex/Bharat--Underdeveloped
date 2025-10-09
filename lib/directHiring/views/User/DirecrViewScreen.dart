import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../chat/APIServices.dart';
import '../../../chat/SocketService.dart';
import '../../../chat/chatScreen.dart';
import '../../../testingfile.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/userModel/subCategoriesModel.dart';
import '../ServiceProvider/WorkerListViewProfileScreen.dart';
import '../comm/view_images_screen.dart';
import 'MyHireScreen.dart';
import 'PaymentScreen.dart';
import 'UserViewWorkerDetails.dart';

class DirectViewScreen extends StatefulWidget {
  final String id;
  final String? categreyId; // Note: Typo in 'categreyId', consider renaming to 'categoryId'
  final String? subcategreyId; // Note: Typo in 'subcategreyId', consider renaming to 'subcategoryId'
  final passIndex;

  const DirectViewScreen({
    super.key,
    required this.id,
    this.categreyId,
    this.subcategreyId,
    this.passIndex,
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listViewKey = GlobalKey();
  Timer? _timer;
  //    Abhi new added

  @override
  void initState() {
    super.initState();
    _clearHiredProviders().then((_) => fetchOrderDetail());
    // _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   fetchOrderDetail();
    // });
    if (order != null && order!['service_provider_id']?['_id'] != null) {
      fetchProviderById(order!['service_provider_id']['_id']);
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  bool _isChatLoading = false; // Add this as a field in your State class
  String? getcategoryId;
  List<String> getsubCategoryIds = [];
  String? workerName;
  String? workerAddress;
  String? workerImageUrl;
  String? workerId;
  Future<void> fetchOrderDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      print("Abhi:- fetchOrderDetail token: $token");
      print("Abhi:- darect orderid ---> : ${widget.id}");

      final response = await http.get(
        Uri.parse(
          'https://api.thebharatworks.com/api/direct-order/getDirectOrderWithWorker/${widget.id}',
        ),
        headers: await getCustomHeaders() /*{'Authorization': 'Bearer $token'}*/,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("Abhi:- fetchOrderDetail response: ${response.body}");
        print("Abhi:- Service Payment: ${decoded['data']['order']['service_payment']}");

        String? providerId;
        String? categoryId;
        List<String> subCategoryIds = [];

        // providerId nikalna
        if (decoded['data']?['order']?['offer_history'] != null &&
            (decoded['data']['order']['offer_history'] as List).isNotEmpty &&
            decoded['data']['order']['offer_history'][0]['provider_id'] != null) {
          providerId = decoded['data']['order']['offer_history'][0]['provider_id']['_id']?.toString();
          print("🚫 Order Provider ID set: $providerId");

          // categoryId nikalna
          categoryId = decoded['data']['order']['offer_history'][0]['provider_id']['category_id']?['_id']?.toString();
          print("📌 Category ID: $categoryId");

          // subcategoryIds nikalna
          if (decoded['data']['order']['offer_history'][0]['provider_id']['subcategory_ids'] != null) {
            subCategoryIds = (decoded['data']['order']['offer_history'][0]['provider_id']['subcategory_ids'] as List)
                .map((sub) => sub['_id'].toString())
                .toList();
          }
          print("📌 SubCategory IDs: $subCategoryIds categoryid : $categoryId");

          setState(() {
            getcategoryId = categoryId;
            getsubCategoryIds = subCategoryIds;
          });
        } else {
          print("⚠️ No provider_id found in offer_history");
        }

        // Add assignedWorker to providerslist if available
        List<ServiceProviderModel> tempProviders = [];
        if (decoded['data']['assignedWorker'] != null) {
          final worker = decoded['data']['assignedWorker'];
          tempProviders.add(ServiceProviderModel(
            id: worker['_id']?.toString(),
            fullName: worker['name']?.toString() ?? 'Unknown',
            skill: 'Worker', // Default skill, adjust if needed
            location: {'address': worker['address'] ?? 'No address'},
            rating: 0.0, // Default rating, adjust if API provides
            hisWork: worker['image'] != null ? [worker['image']] : [],
          ));
        }

        // setState(() {
        //   order = decoded['data']['order'];
        //   orderProviderId = providerId;
        //   providerslist = tempProviders; // Initially set with assignedWorker
        //   isLoading = false;
        // });

        setState(() {
          order = decoded['data']['order'];
          orderProviderId = providerId;
          providerslist = tempProviders; // Initially set with assignedWorker
          isLoading = false;
          workerName = decoded['data']['assignedWorker']?['name']?.toString() ?? 'Unknown';
          workerAddress = decoded['data']['assignedWorker']?['address']?.toString() ?? 'No address';
          workerImageUrl = decoded['data']['assignedWorker']?['image']?.toString();
          workerId = decoded['data']['assignedWorker']?['_id']?.toString();
        });

        print("️ No provider_id found in offer_history id : ${orderProviderId} ${providerId}");

        if (providerId != null) {
          await _saveHiredProviderId(providerId);
          await fetchProviderById(providerId);
        }

        await fetchServiceProvidersListinWorkDetails(
          categoryId ?? widget.categreyId ?? '68443fdbf03868e7d6b74874',
          (subCategoryIds.isNotEmpty ? subCategoryIds.first : widget.subcategreyId) ?? '684e7226962b4919ae932af5',
        );
      } else {
        print("❌ fetchOrderDetail failed: ${response.statusCode} - ${response.body}");
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

  Future<void> openMap(double lat, double lng) async {
    final Uri googleMapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open the map.";
    }
  }

  Future<void> cancelDarectOder() async {
    print("Abhi:- darect cancelOder order id ${widget.id}");
    final String url = '${AppConstants.baseUrl}${ApiEndpoint.darectCanceloffer}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- cancelOder token: $token");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: await getCustomHeaders(), /*{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },*/
        body: jsonEncode({"order_id": widget.id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- darecthire cancelOder success :- ${response.body}");
        print("Abhi:- darecthire cancelOder statusCode :- ${response.statusCode}");
        Navigator.pop(context);
        _clearHiredProviders().then((_) => fetchOrderDetail());

         CustomSnackBar.show(
            message:"Order cancelled successfully" ,
            type: SnackBarType.success
        );
      } else {
        print("Abhi:- else darect-hire cancelOder error :- ${response.body}");
        print("Abhi:- else darect-hire cancelOder statusCode :- ${response.statusCode}");

         CustomSnackBar.show(
            message:   'Failed to cancel order',
            type: SnackBarType.error
        );

      }
    } catch (e) {
      print("Abhi:- Exception darect-hire : - $e");

       CustomSnackBar.show(
          message: 'Error cancelling order.',
          type: SnackBarType.error
      );

    }
  }

  Future<void> fetchProviderById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print("Abhi:- fetchproviderbyId providerId --> ${id}");

    final uri = Uri.parse('https://api.thebharatworks.com/api/user/getServiceProvider/$id');

    try {
      final response = await http.get(
        uri,
        headers: await getCustomHeaders() /*{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },*/
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          providerDetail = jsonData['user'];
        });
        print("Provider by id response: ${response.body}");
      } else {
        print("❌ Provider fetch failed: ${response.body}");

         CustomSnackBar.show(
            message:  'Failed to fetch provider:',
            type: SnackBarType.error
        );

      }
    } catch (e) {
      print("❗ fetchProviderById Error: $e");
       CustomSnackBar.show(
          message:'Error fetching provider' ,
          type: SnackBarType.error
      );

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
          Uri.parse('https://api.razorpay.com/v1/payments/${order!['service_payment']['payment_history'][0]['payment_id']}/refund'),
          headers: await getCustomHeaders() /*{
            'Authorization': 'Basic ${base64Encode(utf8.encode('YOUR_RAZORPAY_KEY_ID:YOUR_RAZORPAY_KEY_SECRET'))}',
          },*/
        );
        print("📤 Refund API response: ${response.body}");
      } catch (e) {
        print("❗ Refund Error: $e");

         CustomSnackBar.show(
            message:'Error processing refund.' ,
            type: SnackBarType.error
        );

      }
    }
  }

  Future<void> fetchServiceProvidersListinWorkDetails(String? categoryId, String? subCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hiredProviderIds = prefs.getStringList('hiredProviderIds') ?? [];
    print("🚫 Hired Provider IDs: $hiredProviderIds");
    print("🚫 Offer History: ${order?['offer_history']}");

    if (token == null) {

       CustomSnackBar.show(
          message:  'Login Required' ,
          type: SnackBarType.error
      );

      return;
    }
    print("Abhi:- get subCategoryId : $subCategoryId");

    final effectiveCategoryId = categoryId ?? '68443fdbf03868e7d6b74874';
    final effectiveSubCategoryId = subCategoryId ?? '684e7226962b4919ae932af5';
    print("📌 Using categoryId: $effectiveCategoryId, subCategoryId: $effectiveSubCategoryId");

    final uri = Uri.parse('https://api.thebharatworks.com/api/user/getServiceProviders');

    try {
      final response = await http.post(
        uri,
        headers: await getCustomHeaders(), /*{
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },*/
        body: json.encode({
          "category_id": effectiveCategoryId,
          "subcategory_ids": [effectiveSubCategoryId],
        }),
      );

      print("📦 API Body Sent: ${json.encode({"category_id": effectiveCategoryId, "subcategory_id": effectiveSubCategoryId})}");
      print("📦 Abhi:- Status: ${response.statusCode}, Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == true && data["data"] != null) {
          // Preserve existing assignedWorker in providerslist
          List<ServiceProviderModel> tempProviders = [];
          if (order != null && order!['assignedWorker'] != null) {
            final worker = order!['assignedWorker'];
            tempProviders.add(ServiceProviderModel(
              id: worker['_id']?.toString(),
              fullName: worker['name']?.toString() ?? 'Unknown',
              skill: 'Worker', // Default skill, adjust if needed
              location: {'address': worker['address'] ?? 'No address'},
              rating: 0.0, // Default rating, adjust if API provides
              hisWork: worker['image'] != null ? [worker['image']] : [],
            ));
          }

          // Add new providers from API response
          tempProviders.addAll(
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
              bool isExcluded = hiredProviderIds.contains(provider.id) ||
                  (order?['offer_history'] != null &&
                      (order!['offer_history'] as List).any((offer) {
                        String offerProviderId = offer['provider_id'] is String
                            ? offer['provider_id']
                            : offer['provider_id']?['_id']?.toString() ?? '';
                        bool match = offerProviderId == provider.id;
                        print("🔍 Checking Offer: $offerProviderId vs ${provider.id} => $match");
                        return match;
                      }));
              print("🔍 Provider: ${provider.id}, Name: ${provider.fullName}, Chhupa?: $isExcluded");
              return !isExcluded;
            })
                .toList(),
          );

          setState(() {
            providerslist = tempProviders; // Update with assignedWorker + new providers
            print("✅ Providers loaded: ${providerslist.length}");
            print("✅ Providers IDs: ${providerslist.map((p) => p.id).toList()}");
          });
        } else {
          print("⚠️ No providers in API response");

          //   CustomSnackBar.show(
          //     message:'No provider found!' ,
          //     type: SnackBarType.error
          // );

        }
      } else {
        print("❌ API Error: ${response.statusCode}");

        //  CustomSnackBar.show(
        //     message:"Somthing went wrong." ,
        //     type: SnackBarType.error
        // );

      }
    } catch (e) {
      print("❗ Error: $e");

      //  CustomSnackBar.show(
      //     message:'Error' ,
      //     type: SnackBarType.error
      // );

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

    final alreadyOffered = hiredProviderIds.contains(providerId.trim()) ||
        (order != null &&
            order!['offer_history'] != null &&
            (order!['offer_history'] as List).any((offer) {
              bool match = false;
              if (offer['provider_id'] is String) {
                match = offer['provider_id'].toString().trim() == providerId.trim();
              } else if (offer['provider_id'] is Map) {
                match = offer['provider_id']['_id'].toString().trim() == providerId.trim();
              }
              print("🧐 Offer history match check: $match | Offer: $offer");
              return match;
            }));

    if (alreadyOffered) {
      print("⚠️ Provider has already been offered.");

       CustomSnackBar.show(
          message: 'Offer already sent to this provider',
          type: SnackBarType.info
      );

      return;
    }

    final uri = Uri.parse('https://api.thebharatworks.com/api/direct-order/send-next-offer');
    print("🌐 Sending POST request to: $uri");

    try {
      final response = await http.post(
        uri,
        headers: await getCustomHeaders(), /* {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },*/
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

          await prefs.setString('category_id', widget.categreyId ?? '68443fdbf03868e7d6b74874');
          await prefs.setString('sub_category_id', widget.subcategreyId ?? '684e7226962b4919ae932af5');

          if (mounted) {
            setState(() {
              providerslist.removeWhere((provider) {
                bool isRemoved = provider.id?.trim() == providerId.trim();
                print("🔍 Comparing: ${provider.id?.trim()} == ${providerId.trim()} => $isRemoved");
                return isRemoved;
              });
              print("📋 Updated providerslist: ${providerslist.map((p) => p.id).toList()}");
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


             CustomSnackBar.show(
                message: 'Offer sent successfully' ,
                type: SnackBarType.success
            );

          }
        } else {
          print("❌ Send offer failed: ${data['message']}");

          //   CustomSnackBar.show(
          //     message: 'Something wrong',
          //     type: SnackBarType.error
          // );

        }
      } else {
        final err = json.decode(response.body);
        print("❗ API Error: ${response.statusCode} - ${err['message']}");

         CustomSnackBar.show(
            message: '${err['message']}',
            type: SnackBarType.error
        );

      }
    } catch (e) {
      print("❗ sendNextOffer Exception: $e");
       CustomSnackBar.show(
          message:"Something went wrong" ,
          type: SnackBarType.error
      );


    }
  }

  void _scrollToListView() {
    final RenderObject? renderObject = _listViewKey.currentContext?.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

                      ///            Chat code Added by Abhishek
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

      // Step 8: Navigate to ChatDetailScreen
      print("Abhi:- Navigating to ChatDetailScreen with conversationId: ${currentChat['_id']}");
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
      );
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
    print("Abhi:- darect order passIndex ${widget.passIndex} ");
    print("Abhi:- darect oder id categaroyid : ${getcategoryId}");
    print("Abhi:- darect oder id subcategaroyid : ${getsubCategoryIds}");
    final images = (order?['image_url'] as List?) ?? [];
    return WillPopScope(
          onWillPop: () async {
            if (widget.passIndex == 1) {
              // 👇 Agar passIndex == 1 hai to MyHireScreen par jao
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHireScreen(passIndex: 1,)),
              );
              return false; // default back ko cancel karo
            }
            return true; // normal back chalega
          },
      child: GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text("Work Details",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            leading: const BackButton(color: Colors.black),
            actions: [],
            systemOverlayStyle:  SystemUiOverlayStyle(
              statusBarColor: AppColors.primaryGreen,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : order == null
              ? const Center(child: Text("No data found"))
              : SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order!['image_url'] != null &&
                    order!['image_url'] is List &&
                    (order!['image_url'] as List).isNotEmpty)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewImage(
                            imageUrl: 'https://api.thebharatworks.com/uploads/hiswork/1752481481201.jpg${order!['image_url'] ?? ""}',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.grey,
                      child:
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: images.length > 1, // agar ek image hai to autoplay band
                          enlargeCenterPage: images.length > 1,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1.0,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                        ),
                        items: images.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Image.network(
                                '$imageUrl',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
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
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order?['title'] ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(color: Colors.black54,borderRadius: BorderRadius.circular(5)),
                      child: Center(child: Text(order?['project_id'] ?? "No data",style: TextStyle(color: Colors.white), maxLines: 1,
                        overflow: TextOverflow.ellipsis,)),)
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: (){                                  //           Abhishek add map
                                openMap(order?['latitude'] ?? 'No lat',
                                  order?['longitude'] ?? 'No long',);
                              print("Abhi:- print lat : ${order?['latitude'] ?? 'No lat'} long : ${order?['longitude'] ?? 'No long'}");
                            },
                            child: Container(
                              height: 24,
                              width: 160,
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.red,
                              ),
                              child: Text(
                                order?['address'] ?? '',
                                // order?['user_id']?['location']?['address'] ?? 'No lat',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Text(
                            "Posted: ${order?['createdAt']?.toString().substring(0, 10) ?? ''}",
                            style: GoogleFonts.roboto(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Completion Date - ${order?['deadline']?.toString().substring(0, 10) ?? ''}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Task Details",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order?['description'] ?? "No description available.",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                order?['hire_status'] == 'accepted' || order?['hire_status'] == 'completed'|| order?['hire_status'] == 'cancelled'|| order?['hire_status'] == 'cancelledDispute'
                    ? Center(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              "${order?['service_provider_id']?['profile_pic'] ?? ''}",
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
                                        "${order?['service_provider_id']?['full_name'] ?? ''}",
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   padding: const EdgeInsets.all(6),
                                    //   decoration: BoxDecoration(
                                    //     shape: BoxShape.circle,
                                    //     color: Colors.grey.shade200,
                                    //   ),
                                    //   child: const Icon(
                                    //     Icons.call,
                                    //     size: 16,
                                    //     color: Colors.green,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Project Fees - ₹${order?['platform_fee'] ?? "200"}/-",
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
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
                                        builder: (context) => /*ViewServiceProviderProfileScreen(
                                          serviceProviderId: order!['service_provider_id']?['_id'] ?? '',
                                        ),*/
                                        UserViewWorkerDetails(
                                          workerId: order?['service_provider_id']?['_id'] ?? '',
                                          categreyId: widget.categreyId,
                                          subcategreyId:
                                          widget.subcategreyId,
                                          hirebuttonhide: "hideOnly",
                                          hideonly: 'hideOnly',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment,
                                    children: [
                                      InkWell(
                                        onTap: _isChatLoading
                                            ? null  // Disable tap while loading
                                            : () async {
                                          print("Abhi:- tap user chat button");
                                          final receiverId = order != null && order!['user_id'] != null
                                              ? order?['service_provider_id']?['_id']?.toString() ?? 'Unknown'
                                              : 'Unknown';
                                          print("Abhi:- tap user chat print resiverId ${order?['service_provider_id']?['_id']?.toString() ?? 'Unknown'}");
                                          final fullName = order != null && order?['service_provider_id'] != null
                                              ? order?['service_provider_id']?['full_name'] ?? 'Unknown'
                                              : 'Unknown';
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
                                          } else {
                                            print("Abhi:- Error: Invalid receiver ID");
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: Invalid receiver ID')),
                                            );
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: _isChatLoading ? Colors.grey : Colors.grey[300],
                                          child: _isChatLoading
                                              ? SizedBox(
                                            width: 2,
                                            height: 2,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                            ),
                                          )
                                              : Icon(
                                            Icons.message,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade200,
                                        ),
                                        child: const Icon(
                                          Icons.call,
                                          size: 30,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Spacer(),
                                      Align(
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
                                    ],
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
                // this is show only pending time for serviceprovider
            // && order!['offer_history'].any((e) => e['status'] == 'pending')
                order!['hire_status'] == 'pending'
                    ? ListView.builder(
                  shrinkWrap: true, // Yeh ensure karta hai ki ListView content ke hisaab se height le
                  physics: const NeverScrollableScrollPhysics(), // Parent SingleChildScrollView scroll handle karega
                  itemCount: order!['offer_history']?.length ?? 0, // Dynamic itemCount offer_history ke length se
                  itemBuilder: (context, index) {
                    final pendingProviderData = order!['offer_history'][index]['provider_id']; // provider_id se data
                    print("Abhi:- print status in provider : ${pendingProviderData['status']}");
                    return Center(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Container(
                          height: 140,
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
                                  pendingProviderData['profile_pic'] ?? '', // provider_id se profile_pic
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 80,
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
                                            pendingProviderData['full_name'] ?? 'Unknown', // provider_id se full_name
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Project Fees - ₹${order?['platform_fee'] ?? '200'}/-", // Platform fee same rakha
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        // InkWell(
                                        //   onTap: _isChatLoading
                                        //       ? null  // Disable tap while loading
                                        //       : () async {
                                        //     print("Abhi:- tap user chat button");
                                        //     final receiverId = pendingProviderData != null && pendingProviderData['_id'] != null
                                        //         ?  pendingProviderData['_id']?.toString() ?? 'Unknown'
                                        //         : 'Unknown';
                                        //     print("Abhi:- tap user chat print resiverId ${order?['service_provider_id']?['_id']?.toString() ?? 'Unknown'}");
                                        //     final fullName = order != null && pendingProviderData['_id'] != null
                                        //         ?  pendingProviderData['full_name'] ?? 'Unknown'
                                        //         : 'Unknown';
                                        //     print("Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullName");
                                        //
                                        //     if (receiverId != 'Unknown' && receiverId.isNotEmpty) {
                                        //       setState(() {
                                        //         _isChatLoading = true;  // Disable button immediately
                                        //       });
                                        //       // await _startOrFetchConversation(context, receiverId);
                                        //       try {
                                        //         await _startOrFetchConversation(context, receiverId);
                                        //       } catch (e) {
                                        //         print("Abhi:- Error starting conversation: $e");
                                        //         ScaffoldMessenger.of(context).showSnackBar(
                                        //           SnackBar(content: Text('Error starting chat')),
                                        //         );
                                        //       }finally {
                                        //         if (mounted) {  // Check if widget is still mounted
                                        //           setState(() {
                                        //             _isChatLoading = false;  // Re-enable button
                                        //           });
                                        //         }
                                        //       }
                                        //     } else {
                                        //       print("Abhi:- Error: Invalid receiver ID");
                                        //       ScaffoldMessenger.of(context).showSnackBar(
                                        //         SnackBar(content: Text('Error: Invalid receiver ID')),
                                        //       );
                                        //     }
                                        //   },
                                        //   child:  CircleAvatar(
                                        //     radius: 14,
                                        //     backgroundColor: _isChatLoading ? Colors.grey : Colors.grey[300],
                                        //     child: _isChatLoading
                                        //         ? SizedBox(
                                        //       width: 18,
                                        //       height: 18,
                                        //       child: CircularProgressIndicator(
                                        //         strokeWidth: 2,
                                        //         valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                        //       ),
                                        //     )
                                        //         : Icon(
                                        //       Icons.message,
                                        //       color: Colors.green,
                                        //       size: 18,
                                        //     ),),
                                        // ),
                                      ],
                                    ),
                                   Row(
                                     children: [
                                       InkWell(
                                         onTap: _isChatLoading
                                             ? null  // Disable tap while loading
                                             : () async {
                                           print("Abhi:- tap user chat button");
                                           final receiverId = pendingProviderData != null && pendingProviderData['_id'] != null
                                               ?  pendingProviderData['_id']?.toString() ?? 'Unknown'
                                               : 'Unknown';
                                           print("Abhi:- tap user chat print resiverId ${order?['service_provider_id']?['_id']?.toString() ?? 'Unknown'}");
                                           final fullName = order != null && pendingProviderData['_id'] != null
                                               ?  pendingProviderData['full_name'] ?? 'Unknown'
                                               : 'Unknown';
                                           print("Abhi:- Attempting to start conversation with receiverId: $receiverId, name: $fullName");

                                           if (receiverId != 'Unknown' && receiverId.isNotEmpty) {
                                             setState(() {
                                               _isChatLoading = true;  // Disable button immediately
                                             });
                                             // await _startOrFetchConversation(context, receiverId);
                                             try {
                                               await _startOrFetchConversation(context, receiverId);
                                             } catch (e) {
                                               print("Abhi:- Error starting conversation: $e");
                                               ScaffoldMessenger.of(context).showSnackBar(
                                                 SnackBar(content: Text('Error starting chat')),
                                               );
                                             }finally {
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
                                         child:  CircleAvatar(
                                           radius: 20,
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
                                             size: 26,
                                           ),),
                                       ),
                                       SizedBox(
                                         width: 15,
                                       ),
                                       Container(
                                         padding: const EdgeInsets.all(6),
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           color: Colors.grey.shade200,
                                         ),
                                         child: const Icon(
                                           Icons.call,
                                           size: 27,
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
                                            builder: (context) => /*ViewServiceProviderProfileScreen(
                                              serviceProviderId: pendingProviderData['_id'] ?? '', // provider_id se _id
                                            ),*/

                                            UserViewWorkerDetails(
                                              workerId: pendingProviderData['_id'] ?? '',
                                              categreyId: widget.categreyId,
                                              subcategreyId:
                                              widget.subcategreyId,
                                              hirebuttonhide: "hideOnly",
                                              hideonly: 'hideOnly',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Center(child: Text(order!['offer_history'][index]['status'] ??"NO STATUS",style: TextStyle(color: Colors.white),)),
                                            height: 23,width: 78,decoration: BoxDecoration(color: order!['offer_history'][index]['status'] == "rejected" ? Colors.red : AppColors.primaryGreen,borderRadius: BorderRadius.circular(3)),),
                                          Align(
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
                                        ],
                                      ),
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
                )
                    : SizedBox(),

                ///            this is assing worker
                order != null && order?['hire_status'] == 'accepted' && workerId != null
                    ? Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assigned Person",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            workerImageUrl != null
                                ? CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(workerImageUrl!),
                              onBackgroundImageError: (_, __) => Icon(Icons.person, color: Colors.grey),
                            )
                                : CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.person, color: Colors.grey),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workerName ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    workerAddress ?? 'No address',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WorkerListViewProfileScreen(
                                              workerId: workerId!,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "View profile",
                                        style: TextStyle(color: Colors.white),
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
                    : Container(), // Empty container if conditions are not met

                //         Abhishek add assign
                order!['hire_status'] == 'pending'  ?
                SizedBox(
                  // height: 200,
                  child: ListView.builder(
                    key: _listViewKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: providerslist.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      final worker = providerslist[index];
                      final imageUrl = worker.hisWork.isNotEmpty
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
                                child: imageUrl != null
                                    ? Center(
                                  child: Image.network(
                                    imageUrl,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print("📸 Image load error: $error");
                                      return const Icon(
                                        Icons.broken_image,
                                        size: 60,
                                      );
                                    },
                                  ),
                                )
                                    : Image.asset(
                                  "assets/images/d_png/no_profile_image.png",
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                worker.rating?.toStringAsFixed(1) ?? "0.0",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
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
                                          final url = "https://api.thebharatworks.com/api/user/getServiceProvider/${worker.id}";
                                          try {
                                            final prefs = await SharedPreferences.getInstance();
                                            final token = prefs.getString('token');
                                            if (token == null) {

                                               CustomSnackBar.show(
                                                  message: 'Login Required, User not logged in.',
                                                  type: SnackBarType.error
                                              );

                                              return;
                                            }
                                            final response = await http.get(
                                              Uri.parse(url),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'Authorization': 'Bearer $token',
                                              },
                                            );
                                            if (response.statusCode == 200) {
                                              final data = jsonDecode(response.body);
                                              if (mounted) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => WorkerListViewProfileScreen(
                                                      workerId: worker.id!,
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {

                                               CustomSnackBar.show(
                                                  message: 'Failed: ${response.statusCode}',
                                                  type: SnackBarType.error
                                              );

                                            }
                                          } catch (e) {

                                             CustomSnackBar.show(
                                                message:  'Error: $e',
                                                type: SnackBarType.error
                                            );

                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
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
                                      InkWell(
                                        onTap: (){

                                        },
                                        child: Container(
                                          width: 120,
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF27773),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            worker.location?['address'] ?? "No address",
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
                                          backgroundColor: Colors.green.shade700,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          minimumSize: const Size(60, 28),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        onPressed: () async {
                                          if (order?['_id'] != null && worker.id != null) {
                                            await sendNextOffer(order!['_id'], worker.id!);
                                          } else {

                                             CustomSnackBar.show(
                                                message: 'Invalid order or provider ID',
                                                type: SnackBarType.error
                                            );

                                          }
                                        },
                                        child: Text(
                                          "Send Offer",
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
                ) : SizedBox(),

                const SizedBox(height: 20),
                order!['hire_status'] == 'pending'
                    ?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     _scrollToListView();
                      //   },
                      //   child: Container(
                      //     width: double.infinity,
                      //     height: 50,
                      //     decoration: BoxDecoration(
                      //       color: Colors.green.shade700,
                      //       borderRadius: BorderRadius.circular(12),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.grey.withOpacity(0.1),
                      //           spreadRadius: 1,
                      //           blurRadius: 6,
                      //           offset: const Offset(0, 2),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Center(
                      //       child: Text(
                      //         "Send offer",
                      //         style: GoogleFonts.roboto(
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w500,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                ) :SizedBox(),

                // order!['hire_status'] == 'cancelled'
                //     ? Center(
                //   child: Container(
                //     height: 35,
                //     width: 250,
                //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         Icon(Icons.warning_amber, color: Colors.red),
                //         Text("This order is cancelled",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
                //       ],
                //     ),
                //   ),
                // )
                //     : SizedBox(),
                // order!['hire_status'] == 'cancelledDispute'
                //     ? Center(
                //   child: Container(
                //     height: 40,
                //     width: double.infinity,
                //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         Icon(Icons.warning_amber, color: Colors.red),
                //         Flexible(
                //           child: Text("The order has been cancelled due to a dispute", textAlign: TextAlign.center,maxLines: 2,
                //             style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
                //         ),
                //       ],
                //     ),
                //   ),
                // )
                //     : SizedBox(),
                //
                // order!['hire_status'] == 'completed'
                //     ? Center(
                //   child: Container(
                //     height: 35,
                //     width: 300,
                //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.green)),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         Icon(Icons.check_circle_outline, color: Colors.green),
                //         Text("  This order has been completed.",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600),),
                //       ],
                //     ),
                //   ),
                // )
                //     : SizedBox(),
                order!['hire_status'] == 'rejected'
                    ? Center(
                  child: Container(
                    height: 35,
                    width: 300,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey)),
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
                order!['hire_status'] == 'accepted' ? const SizedBox(height: 20) : SizedBox(),
                if (providerslist.isEmpty && order!['hire_status'] == 'pending')
                  const Center(
                    child: Text(
                      "No providers available",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                else if (order!['hire_status'] == 'pending'  /*&& order!['offer_history'].any((e) => e['status'] == 'pending')*/)
                  ListView.builder(
                    key: _listViewKey,
                    shrinkWrap: true, // Yeh ensure karta hai ki ListView content ke hisaab se height le
                    physics: const NeverScrollableScrollPhysics(), // Parent SingleChildScrollView scroll handle karega
                    itemCount: providerslist.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      final worker = providerslist[index];
                      final imageUrl = worker.hisWork.isNotEmpty
                          ? "https://api.thebharatworks.com/${worker.hisWork.first.replaceAll("\\", "/")}"
                          : null;

                      return order!['offer_history'].any((e) => e['status'] == 'pending') ?  SizedBox(): Container(
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
                                child: imageUrl != null
                                    ? Center(
                                  child: Image.network(
                                    imageUrl,
                                    height: 100,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 60,
                                    ),
                                  ),
                                )
                                    : Image.asset(
                                  "assets/images/d_png/no_profile_image.png",
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                worker.rating.toStringAsFixed(1),
                                                style: GoogleFonts.roboto(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
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
                                          final url = "https://api.thebharatworks.com/api/user/getServiceProvider/${worker.id}";
                                          try {
                                            final prefs = await SharedPreferences.getInstance();
                                            final token = prefs.getString('token');
                                            if (token == null) {

                                               CustomSnackBar.show(
                                                  message: 'Login Required, User not logged in.',
                                                  type: SnackBarType.error
                                              );

                                              return;
                                            }
                                            final response = await http.get(
                                              Uri.parse(url),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'Authorization': 'Bearer $token',
                                              },
                                            );
                                            if (response.statusCode == 200) {
                                              final data = jsonDecode(response.body);
                                              if (mounted) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => /*ViewServiceProviderProfileScreen(
                                                      serviceProviderId: worker.id,
                                                    ),*/
                                                    UserViewWorkerDetails(
                                                      // paymentStatus: false,
                                                      workerId: worker.id!,
                                                      categreyId: widget.categreyId,
                                                      subcategreyId:
                                                      widget.subcategreyId,
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {

                                               CustomSnackBar.show(
                                                  message:'Failed: ${response.statusCode}' ,
                                                  type: SnackBarType.error
                                              );

                                            }
                                          } catch (e) {

                                             CustomSnackBar.show(
                                                message:'Error: something wrong' ,
                                                type: SnackBarType.error
                                            );

                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF27773),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          worker.location?['address'] ?? "No address",
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
                                          backgroundColor: Colors.green.shade700,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          minimumSize: const Size(60, 28),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        onPressed: () async {
                                          if (order?['_id'] != null && worker.id != null) {
                                            await sendNextOffer(order!['_id'], worker.id!);
                                            await fetchOrderDetail();
                                          } else {
                                             CustomSnackBar.show(
                                                message:  'Invalid order or provider ID' ,
                                                type: SnackBarType.error
                                            );

                                          }
                                        },
                                        child: Text(
                                          "Send Offer",
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
                order!['hire_status'] == 'accepted' ? SizedBox() : const SizedBox(height: 10),
                order?['hire_status'] == 'accepted' || order?['hire_status'] == 'completed'|| order?['hire_status'] == 'cancelled'|| order?['hire_status'] == 'cancelledDispute'
                    ? PaymentScreen(
                  orderId: widget.id,
                  orderProviderId: orderProviderId,
                  paymentHistory: order?['service_payment']?['payment_history'],
                  status: order?['hire_status'],
                )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
