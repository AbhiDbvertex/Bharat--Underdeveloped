//
// import 'package:developer/Emergency/utils/assets.dart';
// import 'package:developer/Emergency/utils/size_ratio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/get_navigation.dart';
// import 'package:intl/intl.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../../directHiring/views/Account/RazorpayScreen.dart';
// import '../models/create_order_model.dart';
//
// class PaymentConformationScreen extends StatelessWidget {
//   // final String orderId;
//   // final int amount;
//   final EmergencyCreateOrderModel responseModel;
//   const PaymentConformationScreen({super.key,required this.responseModel/*required this.orderId,required this.amount*/});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar:  AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title:  Text("Confirm", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
//         leading: const BackButton(color: Colors.black),
//         actions:    [
//
//         ],
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryGreen,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.only(top: 0.2.toWidthPercent()),
//             width: 0.6.toWidthPercent(),
//             alignment: Alignment.center,
//             child: Image.asset(BharatAssets.paymentConfLogo),
//
//           ),
//           SizedBox(height: 0.1.toWidthPercent()),
//           Text('Payment Proceed',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500),),
//           SizedBox(height: 45),
//           Container(
//             width: 169,
//             height: 58,
//             color: Color(0xffB1FDCA),
//             alignment: Alignment.center,
//             child: Text('₹${(responseModel.razorpayOrder?.amountDue??0)/100}',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500,color: Color(0xFF334247)),),
//           ),
//           SizedBox(height: 40,),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.asset(BharatAssets.payImage),
//           ),
//           SizedBox(height: 65,),
//           InkWell(
//             onTap: (){
//               showTotalDialog(context);
//              // Navigator.push(context, MaterialPageRoute(builder: (context) => WorkDetail()));
//             },
//             child: Container(
//               height: 35,
//               width: 0.4.toWidthPercent(),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: Color(0xff228B22)
//               ),
//               child: Text("Hire",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white),),
//             ),
//           )
//
//         ],
//       ),
//     );
//   }
//
//   void showTotalDialog(context) {
//
//      showDialog(
//         context: context,
//         builder: (context) {
//           return Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 24,horizontal: 24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Title
//                   const Text(
//                     "Payment Confirmation",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Image
//                   Image.asset(BharatAssets.payConfLogo2),
//                   const SizedBox(height: 24),
//
//                   // Details section
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                        Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("Date",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
//                           Text(
//                             responseModel.order?.updatedAt != null
//                                 ? DateFormat("dd-MM-yy").format(
//                               DateTime.parse(responseModel.order!.updatedAt!).toLocal(),
//                             )
//                                 : '',
//                             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//                           ),                        ],
//                       ),
//                       const SizedBox(height: 8),
//                        Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("Time",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
//                           Text(
//                             responseModel.order?.updatedAt != null
//                                 ? DateFormat("hh:mm a").format(
//                               DateTime.parse(responseModel.order!.updatedAt!).toLocal(),
//                             )
//                                 : '',
//                             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//                           ),                    ],
//                       ),
//                       const SizedBox(height: 8),
//                        Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("Amount",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
//                           Text("${responseModel.order?.servicePayment?.amount} RS",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                        Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("Platform fees",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
//                           Text("${responseModel.order?.platformFee} INR",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                 Image.asset(BharatAssets.payLine),
//                       const SizedBox(height: 20),
//                        Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Total",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 24,
//                             ),
//                           ),
//                           Text(
//                             "${(responseModel.razorpayOrder?.amount)!/100}/-",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 24,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Divider(height: 4,color: Colors.green,),
//                   const SizedBox(height: 20),
//                   // Buttons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       InkWell(
//                         onTap: () async {
//                           final razorPayId=responseModel.razorpayOrder?.id;
//                           final amount=(responseModel.razorpayOrder?.amount)!;
//                           final provierId=responseModel.order?.serviceProviderId;
//                           final paymentSuccess = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => RazorpayScreen(
//                                 razorpayOrderId:razorPayId! ,
//                                 amount: amount,
//                                 providerId: provierId,
//                                 from: "Emergency",
//                                 // categoryId: widget.categoryId,
//                                 // subcategoryId: widget.subcategoryId,
//                               ),
//                             ),
//                           );
//                          // Navigator.push(context, MaterialPageRoute(builder: (context) => WorkDetail()));
//                         },
//                         child: Container(
//                           height: 35,
//                           width: 0.28.toWidthPercent(),
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               color: Color(0xff228B22)
//                           ),
//                           child: Text("Pay",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white),),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: (){
//
//                           Get.back();
//                         },
//                         child: Container(
//                           height: 35,
//                           width: 0.28.toWidthPercent(),
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: Colors.green, // ✅ Green border
//                               width: 1.5,          // thickness of border
//                             ),
//
//                           ),
//                           child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.green),),
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//
//
//   }
// }

/////////////////////////////////////////////////

import 'package:developer/Emergency/utils/assets.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';

import '../../../../Widgets/AppColors.dart';
import '../../../directHiring/views/Account/RazorpayScreen.dart';
import '../models/create_order_model.dart';

class PaymentConformationScreen extends StatelessWidget {
  final String razorOrderIdPlatform;
  final int platformAmount;
  final String serviceProviderId;
  final String orderId;
  // final EmergencyCreateOrderModel responseModel;
  // const PaymentConformationScreen({super.key,required this.responseModel/*required this.orderId,required this.amount*/});
  const PaymentConformationScreen({super.key,required this.razorOrderIdPlatform,required this.orderId,required this.serviceProviderId,required this.platformAmount,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title:  Text("Confirm", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions:    [

        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 0.2.toWidthPercent()),
            width: 0.6.toWidthPercent(),
            alignment: Alignment.center,
            child: Image.asset(BharatAssets.paymentConfLogo),

          ),
          SizedBox(height: 0.1.toWidthPercent()),
          Text('Payment Proceed',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500),),
          SizedBox(height: 45),
          Container(
            width: 169,
            height: 58,
            color: Color(0xffB1FDCA),
            alignment: Alignment.center,
            // child: Text('₹${(responseModel.razorpayOrder?.amountDue??0)/100}',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500,color: Color(0xFF334247)),),
            child: Text(' ₹$platformAmount /-',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500,color: Color(0xFF334247)),),
          ),
          SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(BharatAssets.payImage),
          ),
          SizedBox(height: 65,),
          InkWell(
            onTap: (){
              showTotalDialog(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => WorkDetail()));
            },
            child: Container(
              height: 35,
              width: 0.4.toWidthPercent(),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xff228B22)
              ),
              child: Text("Hire",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white),),
            ),
          )

        ],
      ),
    );
  }

  void showTotalDialog(context) {

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24,horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                const Text(
                  "Payment Confirmation",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // Image
                Image.asset(BharatAssets.payConfLogo2),
                const SizedBox(height: 24),

                // Details section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
                        Text(
                      DateFormat("dd-MM-yy").format(
                          DateTime.now()
                          )
                      ,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),                        ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Time",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
                        Text(
 DateFormat("hh:mm a").format(
DateTime.now()
                          )
,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),                    ],
                    ),
                    const SizedBox(height: 8),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("Amount",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
                    //     Text("${responseModel.order?.servicePayment?.amount} RS",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
                    //   ],
                    // ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Platform fees",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
                        Text("$platformAmount INR",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Image.asset(BharatAssets.payLine),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          "$platformAmount /-",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 4,color: Colors.green,),
                const SizedBox(height: 20),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        final amount=platformAmount*100;

                     final paymentSuccess = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RazorpayScreen(
                              razorpayOrderId:razorOrderIdPlatform ,
                              orderId: orderId,
                              amount: amount,
                              providerId: serviceProviderId,
                              from: "Emergency",
                              passIndex: 2,
                              // categoryId: widget.categoryId,
                              // subcategoryId: widget.subcategoryId,
                            ),

                          ),
                        );
                        // Get.back();
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => WorkDetail()));
                      },
                      child: Container(
                        height: 35,
                        width: 0.28.toWidthPercent(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xff228B22)
                        ),
                        child: Text("Pay",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white),),
                      ),
                    ),
                    InkWell(
                      onTap: (){

                        Get.back();
                      },
                      child: Container(
                        height: 35,
                        width: 0.28.toWidthPercent(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green, // ✅ Green border
                            width: 1.5,          // thickness of border
                          ),

                        ),
                        child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Colors.green),),
                      ),
                    )
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