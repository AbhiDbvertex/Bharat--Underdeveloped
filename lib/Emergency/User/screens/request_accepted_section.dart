import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/map_launcher_lat_long.dart';
import 'package:developer/Emergency/utils/snack_bar_helper.dart';
import 'package:developer/Widgets/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../directHiring/views/User/viewServiceProviderProfile.dart';
import '../controllers/request_accepted_controller.dart';
import '../controllers/work_detail_controller.dart';
import '../models/request_accepted_model.dart';

class RequestAcceptedSection extends StatelessWidget {

  final orderId;
  final RequestController controller = Get.put(RequestController());
  // final workController = Get.find<WorkDetailController>();
  final workController = Get.put(WorkDetailController());

  RequestAcceptedSection({super.key, required this.orderId});
final tag="RequestAcceptedSection";
  @override
  Widget build(BuildContext context) {
    controller.getRequestAccepted(orderId);

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
                                        SnackBarHelper.showSnackBar(context, "Could not open the map");
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
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade300,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.message,
                                          color: Colors.green, size: 18),
                                      onPressed: () {},
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
                                            ) => ViewServiceProviderProfileScreen(
                                          serviceProviderId:
                                          item.providersId ??
                                              '',
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
                                       await controller.assignEmergencyOrder(orderId:orderId , serviceProviderId: item.providersId);

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
