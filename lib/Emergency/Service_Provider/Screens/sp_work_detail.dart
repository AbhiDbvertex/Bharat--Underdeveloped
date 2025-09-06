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
import 'package:developer/Emergency/Service_Provider/Screens/sp_task_view.dart';
import 'package:developer/Emergency/Service_Provider/controllers/sp_work_detail_controller.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:developer/directHiring/views/comm/view_images_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Widgets/AppColors.dart';
import '../../User/screens/request_accepted_section.dart';
import '../../User/screens/task_view.dart';

class SpWorkDetail extends StatefulWidget {
  final  data;
  final bool isUser;

  SpWorkDetail(this.data, {required this.isUser});

  @override
  State<SpWorkDetail> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<SpWorkDetail> {
  late SpWorkDetailController controller;
  late bool isAccepted;
  final tag="SpWorkDetail";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bwDebug("data : ${widget.data}",tag: tag);
    controller = Get.put(SpWorkDetailController() );
    controller.getEmergencyOrder(widget.data);
    isAccepted = controller.hireStatus.value == "assigned";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Get.delete<SpWorkDetailController>();
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
        title: const Text("Work Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Obx(
              ()  {
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
                              () => CarouselSlider(
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
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade200,
                                        height: 200,
                                        child: const Center(
                                          child: CircularProgressIndicator(color: AppColors.primaryGreen,),
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
                          Container(
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
                            children: controller.subCategories.value
                                .split(", ")
                                .map((subName) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• ", style: TextStyle(fontSize: 16)),
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

                          /*!widget.isUser
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("$status")),
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
                              :*/ controller.hireStatus.value == "cancelled"
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
                              // : SizedBox()

                          : (controller.hireStatus.value == "assigned" && controller.providerName.isNotEmpty) ?
                              SizedBox()
                          :Row(
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
                                  String status= await  controller.acceptUserOrder(controller.orderId.value);
                                  ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
                                    SnackBar(content: Text(status)),
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
                                  String status=   await controller.rejectUserOrder(controller.orderId.value);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
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
                        ],
                      ),
                    ),
                    // if(controller.hireStatus != "cancelled" && controller.hireStatus !="assigned")
                    //
                    //   RequestAcceptedSection(orderId: controller.orderId.value),

                    controller.hireStatus.value == "assigned" && controller.providerName.isNotEmpty
                        ? SpTaskView(
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
              );}}
      ),


    );
  }
}