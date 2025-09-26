// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:developer/directHiring/views/comm/view_images_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../Widgets/AppColors.dart';
// import '../controllers/work_detail_controller.dart';
// import '../models/emergency_list_model.dart';
//
// class WorkDetailPage extends StatefulWidget {
//   final EmergencyOrderData data;
//   final bool isUser;
//
//   WorkDetailPage(this.data, {required this.isUser});
//
//   @override
//   State<WorkDetailPage> createState() => _WorkDetailPageState();
// }
//
// class _WorkDetailPageState extends State<WorkDetailPage> {
//   late WorkDetailController controller;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     controller = Get.put(WorkDetailController(widget.data));
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     Get.delete<WorkDetailController>();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: const Text("Work Detail",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         leading: const BackButton(color: Colors.black),
//         actions: [],
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryGreen,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: Obx(
//         () => SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// IMAGE + CARD OVERLAY
//               // Stack(
//               //   children: [
//               //     Image.network(
//               //       controller.imageUrl.value,
//               //       height: 200,
//               //       width: double.infinity,
//               //       fit: BoxFit.cover,
//               //     ),
//               //     Positioned(
//               //       bottom: 10,
//               //       left: 10,
//               //       child: Container(
//               //         padding: const EdgeInsets.symmetric(
//               //             horizontal: 8, vertical: 4),
//               //         decoration: BoxDecoration(
//               //           color: Colors.black,
//               //           borderRadius: BorderRadius.circular(8),
//               //         ),
//               //         child: Text(
//               //           controller.projectId.value,
//               //           style: GoogleFonts.roboto(
//               //             color: Colors.white,
//               //             fontSize: 12,
//               //           ),
//               //         ),
//               //       ),
//               //     ),
//               //   ],
//               // ),
//
//               Stack(
//                 children: [
//                   Obx(
//                     () => CarouselSlider(
//                       options: CarouselOptions(
//                         height: 200,
//                         viewportFraction: 1.0,
//                         enableInfiniteScroll: true,
//                         autoPlay: true,
//                         autoPlayInterval: Duration(seconds: 2),
//                         onPageChanged: (index, reason) {
//                           controller.currentImageIndex.value = index;
//                         },
//                       ),
//                       items: controller.imageUrls.map((url) {
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => ViewImage(
//                                     imageUrl: url,
//                                     title: "Product Image",
//                                   ),
//                                 ));
//                           },
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(0),
//                             child: Image.network(
//                               url,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Container(
//                                   color: Colors.grey.shade200,
//                                   height: 200,
//                                   child: const Center(
//                                     child: CircularProgressIndicator(color: AppColors.primaryGreen,),
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey.shade200,
//                                   height: 200,
//                                   child: const Center(
//                                     child: Icon(Icons.broken_image,
//                                         size: 50, color: Colors.grey),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//
//                   // dots indicator
//                   // Positioned(
//                   //   bottom: 10,
//                   //   left: 0,
//                   //   right: 0,
//                   //   child: /*Obx(
//                   //     () => Row(
//                   //       mainAxisAlignment: MainAxisAlignment.center,
//                   //       children:
//                   //           controller.imageUrls.asMap().entries.map((entry) {
//                   //         int idx = entry.key;
//                   //         return Container(
//                   //           width: 8.0,
//                   //           height: 8.0,
//                   //           margin: const EdgeInsets.symmetric(horizontal: 3.0),
//                   //           decoration: BoxDecoration(
//                   //             shape: BoxShape.circle,
//                   //             color: controller.currentImageIndex.value == idx
//                   //                 ? AppColors.primaryGreen
//                   //                 : AppColors.primaryGreen.withAlpha(100),
//                   //           ),
//                   //         );
//                   //       }).toList(),
//                   //     ),
//                   //   ),*/
//                   // ),
//
//                   // project id overlay (jaisa pehle)
//                   Positioned(
//                     bottom: 10,
//                     left: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         controller.projectId.value,
//                         style: GoogleFonts.roboto(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//
//               Obx(
//                 () => Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: controller.imageUrls.asMap().entries.map((entry) {
//                     int idx = entry.key;
//                     return Container(
//                       width: 8.0,
//                       height: 8.0,
//                       margin: const EdgeInsets.symmetric(horizontal: 3.0),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: controller.currentImageIndex.value == idx
//                             ? AppColors.primaryGreen
//                             : AppColors.primaryGreen.withAlpha(100),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//
//               /// BELOW IMAGE -> COLUMN
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// ROW 1
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 4, horizontal: 8),
//                       decoration: BoxDecoration(
//                         color: Color(0xfff27773),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         controller.googleAddress.value,
//                         style: GoogleFonts.roboto(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       controller.detailedAddress.value,
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     /// WORK TITLE
//                     Text(
//                       controller.categoryName.value,
//                       style: GoogleFonts.roboto(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 4),
//
//                     /// DATE
//                     Text(
//                       "Complete - ${controller.deadline.value}",
//                       style: GoogleFonts.roboto(
//                           fontSize: 12, color: Colors.grey.shade700),
//                     ),
//                     const SizedBox(height: 6),
//
//                     /// AMOUNT
//                     Text(
//                       "₹ 0",
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     Divider(color: Colors.grey.shade300, thickness: 1),
//                     const SizedBox(height: 6),
//
//                     Text(
//                       "Task Details",
//                       style: GoogleFonts.roboto(
//                           fontSize: 14, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 6),
//
//                     /// TASK DETAILS
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: controller.subCategories.value
//                           .split(", ")
//                           .map((subName) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 2.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text("• ", style: TextStyle(fontSize: 16)),
//                               // bullet
//                               Expanded(
//                                 child: Text(
//                                   subName,
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 14,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     /// CANCEL BUTTON
//                     widget.isUser
//                         ? widget.data.hireStatus == "pending"
//                             ? Center(
//                                 child: ElevatedButton.icon(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                     minimumSize: const Size(160, 40),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () async {
//                                     var orderId = "${controller.orderId}";
//                                     String status = await controller
//                                         .cancelEmergencyOrder(orderId);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text("$status")),
//                                     );
//
//                                     if (status.toLowerCase().contains("successfully")) {
//                                       // Future.delayed(const Duration(seconds: 1), () {
//                                         Navigator.pop(context); // ya Get.back();
//                                       // });
//                                     }
//
//                                     // cancel logic
//                                   },
//                                   icon: const Icon(
//                                       Icons.cancel_presentation_outlined,
//                                       color: Colors.white),
//                                   label: controller.isLoading.value
//                                       ? CircularProgressIndicator(
//                                           color: Colors.white,
//                                         )
//                                       : Text(
//                                           "Cancel Task",
//                                           style: GoogleFonts.roboto(
//                                               color: Colors.white,
//                                               fontSize: 14),
//                                         ),
//                                 ),
//                               )
//                             : widget.data.hireStatus == "cancelled"
//                                 ? Container(
//                                     width: double.infinity,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red,
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         "Cancelled",
//                                         style: GoogleFonts.roboto(
//                                             color: Colors.white,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox()
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.primaryGreen,
//                                   minimumSize: const Size(140, 40),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   // accept logic
//                                 },
//                                 child: Text(
//                                   "Accept",
//                                   style: GoogleFonts.roboto(
//                                       color: Colors.white, fontSize: 15),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red,
//                                   minimumSize: const Size(140, 40),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   // reject logic
//                                 },
//                                 child: Text(
//                                   "Reject",
//                                   style: GoogleFonts.roboto(
//                                       color: Colors.white, fontSize: 15),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       /// BOTTOM STATUS
//       bottomNavigationBar: Obx(
//         () => Container(
//           height: 45,
//           alignment: Alignment.center,
//           color: Colors.grey.shade300,
//           child: Text(
//             controller.hireStatus.value,
//             style: GoogleFonts.roboto(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black54,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
/////////////////////////////
import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/Emergency/User/screens/request_accepted_section.dart';
import 'package:developer/Emergency/User/screens/task_view.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:developer/directHiring/views/comm/view_images_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Widgets/AppColors.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../utils/map_launcher_lat_long.dart';
import '../controllers/work_detail_controller.dart';

class WorkDetailPage extends StatefulWidget {
  final data;
  final bool isUser;

  WorkDetailPage(this.data, {required this.isUser});

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  final tag = "WorkDetailPage";
  late WorkDetailController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bwDebug("data : ${widget.data}");
    controller = Get.put(WorkDetailController());
    controller.getEmergencyOrder(widget.data);
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
      body: Obx(() {
        if (controller.isLoading.value) {
          // loading true -> show loader
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SingleChildScrollView(
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
                      () => Container(
                        color: Colors.grey,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            onPageChanged: (index, reason) {
                              controller.currentImageIndex.value = index;
                            },
                          ),
                          items: controller.imageUrls.map((url) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewImage(
                                        imageUrl: url,
                                        title: "Product Image",
                                      ),
                                    ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: Image.network(
                                  url,
                                  width: double.infinity,
                                  // fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade200,
                                      height: 200,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      height: 200,
                                      child: const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 50, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
                const SizedBox(height: 8),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: controller.imageUrls.asMap().entries.map((entry) {
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

                /// BELOW IMAGE -> COLUMN
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ROW 1
                      GestureDetector(
                        onTap: () async {
                          bwDebug("on tap call: ", tag: tag);
                          final address = controller.googleAddress.value;
                          final latitude = controller.latitude.value;
                          final longitude = controller.longitude.value;
                          bool success = await MapLauncher.openMap(
                              latitude: latitude,
                              longitude: longitude,
                              address: address);
                          if (!success) {

                            CustomSnackBar.show(
                                message:"Could not open the map" ,
                                type: SnackBarType.error
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Color(0xfff27773),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.googleAddress.value,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.detailedAddress.value,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                        "Completion Date  - ${controller.deadline.value}",
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
                        children: controller.subCategories.value
                            .split(", ")
                            .map((subName) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ",
                                    style: TextStyle(fontSize: 16)),
                                // bullet
                                Expanded(
                                  child: Text(
                                    subName,
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      /// CANCEL BUTTON

                      widget.isUser
                          ? controller.hireStatus == "pending"
                              ? Center(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      minimumSize: const Size(160, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      controller.isLoading.value = true;
                                      var orderId = "${controller.orderId}";
                                      String status = await controller
                                          .cancelEmergencyOrder(orderId);

                                       CustomSnackBar.show(
                                          message: status,
                                          type:status=="Order cancelled successfully"?SnackBarType.success: SnackBarType.error
                                      );


                                      controller.isLoading.value = false;
                                      // cancel logic
                                    },
                                    icon: const Icon(
                                        Icons.cancel_presentation_outlined,
                                        color: Colors.white),
                                    label: controller.isLoading.value
                                        ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            "Cancel Task",
                                            style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                  ),
                                )
                              : controller.hireStatus == "cancelled"
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Cancelled",
                                          style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )
                                  : SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    minimumSize: const Size(140, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    controller.isLoading.value = true;
                                    String status =
                                        await controller.acceptUserOrder(
                                            controller.orderId.value);


                                    CustomSnackBar.show(
                                        message: status,
                                        type: status=="Something went wrong"?SnackBarType.error: SnackBarType.success
                                    );
                                    controller.isLoading.value = false;
                                    // accept logic
                                  },
                                  child: Text(
                                    "Accept",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size(140, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    controller.isLoading.value = true;
                                    String status =
                                        await controller.rejectUserOrder(
                                            "6871f5b5ed31367eed8d2210");
                                  CustomSnackBar.show(
                                        message: status,
                                        type: status=="Something went wrong"?SnackBarType.error: SnackBarType.success
                                    );
                                    controller.isLoading.value = false;
                                  },
                                  child: Text(
                                    "Reject",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                controller.hireStatus != "cancelled" && controller.hireStatus != "assigned" &&
                        controller.hireStatus != "cancelledDispute"
                    ? RequestAcceptedSection(orderId: controller.orderId.value)
                    : controller.hireStatus != "assigned"? Center(
                      child: Container(
                                        height: 35,
                                        width: 250,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.red)),
                                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber, color: Colors.red),
                        Text("This order is cancelled",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.red),),
                      ],
                                        ),
                                      ),
                    ):SizedBox(),

                controller.hireStatus.value == "assigned" &&
                        controller.providerName.isNotEmpty
                    ? TaskView(
                        orderId: controller.orderId.value,
                        // providerId:controller.providerId.value,
                        // providerName: controller.providerName.value,
                        // providerPhone: controller.providerPhone.value,
                        // providerImage: controller.providerImage.value,
                        // platFormFee:controller.plateFormFee.value,
                        // isAssign: false,
                      )
                    : const SizedBox(),
              ],
            ),
          );
        }
      }),
    );
  }
}
