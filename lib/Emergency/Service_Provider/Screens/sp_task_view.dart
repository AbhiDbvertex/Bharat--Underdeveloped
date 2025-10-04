import 'package:developer/Emergency/Service_Provider/controllers/sp_work_detail_controller.dart';
import 'package:developer/Emergency/utils/assets.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:developer/Widgets/AppColors.dart';
import 'package:developer/directHiring/views/ServiceProvider/ServiceWorkerListScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../directHiring/views/ServiceProvider/ServiceDisputeScreen.dart';
import '../../../directHiring/views/ServiceProvider/WorkerListViewProfileScreen.dart';
import '../../../directHiring/views/ServiceProvider/WorkerScreen.dart';
import '../../../directHiring/views/User/viewServiceProviderProfile.dart';

class SpTaskView extends StatefulWidget {
  final String orderId;

  SpTaskView({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<SpTaskView> createState() => _SpTaskViewState();
}

class _SpTaskViewState extends State<SpTaskView> {


  final tag = "TaskView";
  late final controller;
  @override
  void initState() {
    // TODO: implement initState
     controller = Get.find<SpWorkDetailController>();
     WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.getEmergencyOrder();
     });
  }

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Worker Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildWorkerDetails(
                  controller.providerId.value,
                  controller.providerImage.value,
                  controller.providerName.value,
                  controller.plateFormFee.value,
                  context
              ),
              const SizedBox(height: 10),
                _buildAssignedPerson(controller.assignedWorker.value,context),
              const SizedBox(height: 10),
              _buildPaymentSection(controller, context),
              const SizedBox(height: 20),
              if (controller.warningMessage.value.isNotEmpty)
                _buildWarningMessage(controller.warningMessage.value),
              const SizedBox(height: 20),
              _buildActionButtons(controller, context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWorkerDetails(String id,String imageUrl, String name, int fee,context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                context,
                ) => ViewServiceProviderProfileScreen(
              serviceProviderId:
              id ??
                  '',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bada Circular Avatar
            CircleAvatar(
              radius: 40,
           //   backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 40);
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name + Fees
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Emergency Fees - ₹$fee/-',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff334247),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )



    /*child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 40);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Emergency Fees - ₹$fee/-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff334247),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),*/
    );
  }

  Widget _buildAssignedPerson(person,BuildContext context) {

    return controller.assignedWorker.value.id == null?
      InkWell(
        onTap: () {
          Get.to(() => ServiceWorkerListScreen(orderId: controller.orderId.value,callType:"emergency"));
          // Get.to(() => WorkerScreen());
          },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryGreen, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Assign to another person',
            style: TextStyle(color: Colors.green, fontSize: 20,fontWeight: FontWeight.w600),
          ),
        ),
      )
          :
      Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Person',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // CircleAvatar(
              //   radius: 40,
              //   backgroundImage: NetworkImage(person.image ?? ""),
              // ),
              CircleAvatar(
                radius: 40,
                backgroundImage: person.image != null && person.image!.isNotEmpty
                    ? NetworkImage(person.image!)
                    : null,
                child: (person.image == null || person.image!.isEmpty)
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                /*    Text(
                      'Category: ${controller.categoryName.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff777777),
                      ),
                    ),*/
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder:
                        //         (
                        //         context,
                        //         ) => ViewServiceProviderProfileScreen(
                        //       serviceProviderId:
                        //       person.id ??
                        //           '',
                        //     ),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkerListViewProfileScreen(
                                  workerId:
                                  person.id

                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: const Text('View Profile',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(SpWorkDetailController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Obx(
            () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     controller.createNewPayment();
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: AppColors.primaryGreen,
                  //   ),
                  //   child: const Text('Create',
                  //       style: TextStyle(color: Colors.white)),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 0.3),
              const SizedBox(height: 10),
              if (controller.payments.isEmpty)
                const Center(
                  child: Text(
                    "No payment yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.payments.length,
                  itemBuilder: (context, index) {
                    final payment = controller.payments[index];
                    final totalAmount = payment.amount! + payment.tax!;
                    String statusText = '';
                    Color statusColor = Colors.grey;
                    switch (payment.releaseStatus) {
                      case 'pending':
                        statusText = 'Pending';
                        statusColor = Colors.orange;
                        break;
                      case 'release_requested':
                        statusText = 'Requested';
                        statusColor = Colors.blue;
                        break;
                      case 'released':
                        statusText = 'Released';
                        statusColor = AppColors.primaryGreen;
                        break;
                      case 'refunded':
                        statusText = 'Refunded';
                        statusColor = Colors.red;
                        break;
                      default:
                        statusText = 'N/A';
                        statusColor = Colors.grey;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Expanded(
                              child: Text(
                                '${index + 1}.',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              payment.description ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: payment.status == 'success'
                                ?  Text(
                              statusText,
                              style: TextStyle(color: AppColors.primaryGreen),
                            )
                                : const SizedBox(),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '₹${totalAmount}/-',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          // SizedBox(
                          //   width: 70,
                          //   child: payment.releaseStatus == 'pending'
                          //       ? ElevatedButton(
                          //     // onPressed: () => controller.selectPaymentToPay(index),
                          //     onPressed: () {
                          //       controller.requestPaymentRelease(
                          //         orderId: controller.orderId.value,
                          //         paymentId: payment.id!, //
                          //       );
                          //       bwDebug("Pay button clicked for pending payment. Payment ID: ${payment.paymentId}");
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: AppColors.primaryGreen,
                          //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //       minimumSize: const Size(0, 35),
                          //     ),
                          //     child: const Text(
                          //       'Pay',
                          //       style: TextStyle(color: Colors.white, fontSize: 12),
                          //     ),
                          //   )
                          //       : const SizedBox(),
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              // if (controller.selectedPaymentIndex.value != -1 ||
              //     controller.isCreatingNewPayment.value)
                // _buildPaymentInput(controller, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInput(SpWorkDetailController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  controller.isCreatingNewPayment.value
                      ? ''
                      : '${controller.selectedPaymentIndex.value + 1}.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.descriptionController,
                    cursorColor: AppColors.primaryGreen,
                    maxLength: 20,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Enter description',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: controller.amountController,
                    cursorColor: AppColors.primaryGreen,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      prefixText: '₹',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => controller.cancelPaymentInput(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => controller.submitPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningMessage(String message) {
    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.14.toWidthPercent()),
            padding: const EdgeInsets.fromLTRB(50, 50, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xffFBFBBA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Warning Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 0.01.toWidthPercent()),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Image.asset(
            BharatAssets.warning,
            height: 0.28.toWidthPercent(),
            width: 0.27.toWidthPercent(),
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SpWorkDetailController controller, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.05.toWidthPercent()),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                bwDebug("Cancel Task and create dispute : orderId: ${controller.orderId.value}", tag: tag);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDisputeScreen(
                      orderId: controller.orderId.value,
                      flowType: "emergency",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cancel Task and Create Dispute',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       bool isMarkCompleteSuccess = await controller.markAsComplete(orderId: controller.orderId.value);
          //       if (isMarkCompleteSuccess) {
          //         bwDebug("Mark as complete was successful");
          //         if (context.mounted) {
          //           Get.to(() => UserFeedback(
          //             providerId: controller.providerId.value,
          //             oderId: controller.orderId.value,
          //           ));
          //         }
          //       } else {
          //         bwDebug("Mark as complete failed");
          //       }
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.primaryGreen,
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //     ),
          //     child: const Text(
          //       'Mark as complete',
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}