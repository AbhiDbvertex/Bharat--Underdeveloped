import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/request_accepted_controller.dart';
import '../models/request_accepted_model.dart';

class RequestAcceptedSection extends StatelessWidget {
  final RequestController controller = Get.put(RequestController());

  RequestAcceptedSection({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchRequests();

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
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.requests.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No requests found"),
            );
          }

          return ListView.builder(
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
          );
        }),
      ],
    );
  }
}
