import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Widgets/AppColors.dart';
import '../controllers/work_detail_controller.dart';
import '../models/emergency_list_model.dart';

class WorkDetailPage extends StatefulWidget {
  final EmergencyOrderData data;

  WorkDetailPage(this.data);

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  late WorkDetailController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = Get.put(WorkDetailController(widget.data));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Get.delete<WorkDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Work Detail",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE + CARD OVERLAY
              // Stack(
              //   children: [
              //     Image.network(
              //       controller.imageUrl.value,
              //       height: 200,
              //       width: double.infinity,
              //       fit: BoxFit.cover,
              //     ),
              //     Positioned(
              //       bottom: 10,
              //       left: 10,
              //       child: Container(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 8, vertical: 4),
              //         decoration: BoxDecoration(
              //           color: Colors.black,
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //         child: Text(
              //           controller.projectId.value,
              //           style: GoogleFonts.roboto(
              //             color: Colors.white,
              //             fontSize: 12,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              Stack(
                children: [
                  Obx(
                    () => CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 2),
                        onPageChanged: (index, reason) {
                          controller.currentImageIndex.value = index;
                        },
                      ),
                      items: controller.imageUrls.map((url) {
                        return Image.network(
                          url,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),
                  ),

                  // dots indicator
                  // Positioned(
                  //   bottom: 10,
                  //   left: 0,
                  //   right: 0,
                  //   child: /*Obx(
                  //     () => Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children:
                  //           controller.imageUrls.asMap().entries.map((entry) {
                  //         int idx = entry.key;
                  //         return Container(
                  //           width: 8.0,
                  //           height: 8.0,
                  //           margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: controller.currentImageIndex.value == idx
                  //                 ? AppColors.primaryGreen
                  //                 : AppColors.primaryGreen.withAlpha(100),
                  //           ),
                  //         );
                  //       }).toList(),
                  //     ),
                  //   ),*/
                  // ),

                  // project id overlay (jaisa pehle)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.projectId.value,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// BELOW IMAGE -> COLUMN
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            controller.imageUrls.asMap().entries.map((entry) {
                          int idx = entry.key;
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: controller.currentImageIndex.value == idx
                                  ? AppColors.primaryGreen
                                  : AppColors.primaryGreen.withAlpha(100),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    /// ROW 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4,),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                controller.googleAddress.value,
                                style: GoogleFonts.roboto(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.detailedAddress.value,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.detailedAddress.value,
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// WORK TITLE
                    Text(
                      controller.categoryName.value,
                      style: GoogleFonts.roboto(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),

                    /// DATE
                    Text(
                      "Complete - ${controller.deadline.value}",
                      style: GoogleFonts.roboto(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),

                    /// AMOUNT
                    Text(
                      "₹ 0",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 6),

                    Text(
                      "Task Details",
                      style: GoogleFonts.roboto(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),

                    /// TASK DETAILS
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.contact.value,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ].toList(),
                    ),
                    const SizedBox(height: 20),

                    /// CANCEL BUTTON
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(160, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {} /*controller.cancelTask()*/,
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: Text(
                          "Cancel Task",
                          style: GoogleFonts.roboto(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// BOTTOM STATUS
      bottomNavigationBar: Obx(
        () => Container(
          height: 45,
          alignment: Alignment.center,
          color: Colors.grey.shade300,
          child: Text(
            controller.hireStatus.value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
