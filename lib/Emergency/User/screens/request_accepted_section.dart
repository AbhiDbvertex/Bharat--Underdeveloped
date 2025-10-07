import 'dart:convert';

import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/map_launcher_lat_long.dart';
import 'package:developer/Widgets/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../chat/APIServices.dart';
import '../../../chat/SocketService.dart';
import '../../../chat/chatScreen.dart';
import '../../../directHiring/views/User/UserViewWorkerDetails.dart';
import '../../../directHiring/views/User/viewServiceProviderProfile.dart';
import '../../../utility/custom_snack_bar.dart';
import '../controllers/request_accepted_controller.dart';
import '../controllers/work_detail_controller.dart';
import '../models/request_accepted_model.dart';

class RequestAcceptedSection extends StatefulWidget {

  final orderId;

  RequestAcceptedSection({super.key, required this.orderId});

  @override
  State<RequestAcceptedSection> createState() => _RequestAcceptedSectionState();
}

class _RequestAcceptedSectionState extends State<RequestAcceptedSection> {
  final RequestController controller = Get.put(RequestController());
  bool _isChatLoading = false; // Add this as a field in your State class
  // final workController = Get.find<WorkDetailController>();
  final workController = Get.find<WorkDetailController>();

final tag="RequestAcceptedSection";

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


  @override
  Widget build(BuildContext context) {
    controller.getRequestAccepted(widget.orderId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Container(
          width: double.infinity,
          color: Colors.grey.shade300,
          padding: const EdgeInsets.all(10),
          child: const Center(
            child: Text(
              "Request Accepted",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        // Dynamic List from Controller
        Obx(() {
          if (controller.isFetchingRequests.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              ),
            );
          }

          if (controller.requestAcceptedModel.value == null ||
              controller.requestAcceptedModel.value!.providers.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text("No requests found")),
            );
          }

        /*  return ListView.builder(
            itemCount: controller.requests.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = controller.requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image + status
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + Call
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.call,
                                      color: Colors.green),
                                  onPressed: () {
                                    // TODO: call action
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Amount
                            Text(
                              "₹${item.amount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Location + Message
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message,
                                      color: Colors.blueAccent),
                                  onPressed: () {
                                    // TODO: message action
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // View Profile + Hire buttons
                            Row(
                              children: [
                                OutlinedButton(

                                  onPressed: () {
                                    // TODO: view profile
                                  },
                                  child: const Text("View Profile"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: hire action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Hire"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );*/

         /* return ListView.builder(
            itemCount: controller.requests.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = controller.requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side image
                      Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  height: 110,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Viewed",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Right side content (split in 2 columns)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT COLUMN: name, amount, location, view profile
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "₹${item.amount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryGreen,
                                  ),
                                  child: const Text("View Profile"),
                                ),
                              ],
                            ),

                            // RIGHT COLUMN: call, chat, hire
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.green.shade100,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.call,
                                        color: Colors.green, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.green.shade100,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.message,
                                        color: Colors.green, size: 18),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    minimumSize: const Size(60, 30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Hire"),
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
          );*/



          ////////////////
          return ListView.builder(
            itemCount: controller.requestAcceptedModel.value?.providers.length??0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final ServiceProvider  item = controller.requestAcceptedModel.value!.providers[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side image
                      Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: 110,
                                width: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.profilePic,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.black54,
                                        ),
                                      );

                                    },
                                  ),

                                ),
                              ),

                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.view.isNotEmpty ? item.view : "", // ✅ use view
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Right side details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Name, Amount, Call
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //////////////
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // left align text

                                    children: [
                                      Text(
                                        item.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "₹${item.amount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///////////
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade300,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.call,
                                          color: Colors.green, size: 18),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Row 2: Location + Chat
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                item.location.address.isNotEmpty? Expanded(
                                  child: InkWell(
                                    onTap:() async {
                                      final latitude = item.location.latitude;
                                      final longitude = item.location.longitude;
                                      final address = item.location.address;
                                      //final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

                                      // if (await canLaunch(googleMapsUrl)) {
                                      // await launch(googleMapsUrl);
                                      // } else {
                                      // bwDebug("Could not open the map.");
                                      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open the map.")));
                                      // }

                                      bool success=await MapLauncher.openMap(latitude: latitude, longitude: longitude,address: address);
                                      if(!success) {
                                        // SnackBarHelper.showSnackBar(context, "Could not open the map");
                                        CustomSnackBar.show(

                                            message:"Could not open the map" ,
                                            type: SnackBarType.error
                                        );

                                      }
                                      },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xffF27773),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.location.address,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ):SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: GestureDetector(
                                    onTap: _isChatLoading
                                        ? null  // Disable tap while loading
                                        : ()  async {
                                      final receiverId =  item?.id != null && item?.id != null
                                          ? item?.id.toString() ?? 'Unknown'
                                          : 'Unknown';
                                      final fullNamed = item?.id != null && item?.id != null
                                          ?   item?.fullName ?? 'Unknown'
                                          : 'Unknown';
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
                                    child: /*CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey.shade300,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.message,
                                            color: Colors.green, size: 18),
                                        onPressed: () {},
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
                            const SizedBox(height: 8),

                            // Row 3: View Profile + Hire
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                            context,
                                            ) => /*ViewServiceProviderProfileScreen(
                                          serviceProviderId:
                                          item.providersId ??
                                              '',
                                        ),*/
                                            UserViewWorkerDetails(
                                              workerId: item.providersId,
                                            ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryGreen,
                                    padding: EdgeInsets.zero, // 👈 yeh add kar
                                    minimumSize: Size(0, 0),  // 👈 extra padding hata de
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 👈 button ka hitbox compact ho jayega
                                    alignment: Alignment.centerLeft, // 👈 text bilkul left se align hoga
                                  ),
                                  child: const Text("View Profile"),
                                ),
                                Obx(
                                   () {
                                    return ElevatedButton(
                                      onPressed:controller.isHiring.value
                                          ? null
                                          : () async {
                                        bwDebug(" [HIRE BUTTON]: press",tag: tag);
                                       await controller.assignEmergencyOrder(orderId:widget.orderId , serviceProviderId: item.providersId);
                                       Get.back();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        minimumSize: const Size(70, 32),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("Hire",style: TextStyle(color: Colors.white),),
                                    );
                                  }
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
          );



        }),
      ],
    );
  }
}
