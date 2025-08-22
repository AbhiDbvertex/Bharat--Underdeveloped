import 'package:developer/Emergency/User/controllers/work_detail_controller.dart';
import 'package:developer/Emergency/utils/assets.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:developer/Widgets/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../directHiring/views/ServiceProvider/ServiceDisputeScreen.dart';
import '../../../directHiring/views/User/user_feedback.dart';
import '../controllers/task_view_controller.dart';
import '../models/task_view_model.dart';

class TaskView extends StatelessWidget {
  final String orderId;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String providerImage;
  final platFormFee;
  final bool isAssign;

  const TaskView({
    Key? key,
    required this.orderId,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.providerImage,
    required this.platFormFee,
    required this.isAssign,
  }) : super(key: key);

  final tag = "taskView";

  @override
  Widget build(BuildContext context) {
    bwDebug(
        " $orderId, $providerId,$providerName,$providerPhone,,$platFormFee,$providerImage,");
    final TaskController taskController = Get.put(TaskController());

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Worker Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildWorkerDetails(taskController.task.value.workerDetails),
            const SizedBox(height: 20),
            if (isAssign)
              _buildAssignedPerson(taskController.task.value.assignedPerson),
            const SizedBox(height: 5),
            _buildPaymentSection(taskController),
            const SizedBox(height: 20),
            Obx(() {
              if (taskController.showWarning.value) {
                return _buildWarningMessage(
                  taskController.task.value.warningMessage!,
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 20),
            _buildActionButtons(taskController, context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerDetails(WorkerDetails worker) {
    return Container(
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
                    providerImage,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 40); // fallback
                    },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Emergency Fees - $platFormFee/-',
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
    );
  }

  Widget _buildAssignedPerson(AssignedPerson person) {
    return Container(
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
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(person.imageUrl),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      person.subCategory,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff777777),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
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

  Widget _buildPaymentSection(TaskController controller) {
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
                  if (controller.task.value.payments.isEmpty)
                    ElevatedButton(
                      onPressed: () {
                        controller.createNewPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: const Text('Create',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 0.3),
              const SizedBox(height: 10),
              if (controller.task.value.payments.isEmpty)
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
                  itemCount: controller.task.value.payments.length,
                  itemBuilder: (context, index) {
                    final payment = controller.task.value.payments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${index + 1}.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              payment.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: payment.isPaid
                                ? const Text(
                                    'Paid',
                                    style: TextStyle(
                                        color: AppColors.primaryGreen),
                                  )
                                : const SizedBox(),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              '₹${payment.amount}/-',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: !payment.isPaid
                                ? ElevatedButton(
                                    onPressed: () =>
                                        controller.selectPaymentToPay(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      minimumSize: const Size(0, 35),
                                    ),
                                    child: const Text(
                                      'Pay',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (controller.selectedPaymentIndex.value != -1 ||
                  controller.isCreatingNewPayment.value)
                _buildPaymentInput(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInput(TaskController controller) {
    final payment = controller.isCreatingNewPayment.value
        ? Payment(name: "", amount: '', isPaid: false)
        : controller.task.value.payments[controller.selectedPaymentIndex.value];

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
                // Serial no bold
                Text(
                  controller.isCreatingNewPayment.value
                      ? ''
                      : '${controller.selectedPaymentIndex.value + 1}.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),

                // Description field
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Amount box (Now editable)
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: controller.amountController,
                    cursorColor: AppColors.primaryGreen,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      prefixText: '₹',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => controller.cancelPaymentInput(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    // Box ka background white
                    foregroundColor: AppColors.primaryGreen,
                    // Text ka color green
                    side: const BorderSide(
                        color: AppColors.primaryGreen), // Border ka color green
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => controller.submitPayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  Widget _buildWarningMessage(WarningMessage message) {
    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.14.toWidthPercent()),
            padding: EdgeInsets.fromLTRB(50, 50, 16, 16),
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
                  message.message,
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

  Widget _buildActionButtons(TaskController controller, context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.05.toWidthPercent()),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                bwDebug("Cancel Task and create dispute : orderId: $orderId",
                    tag: tag);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDisputeScreen(
                      orderId: orderId,
                      flowType: "emergency",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cancel Task and create dispute',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                bool isMarkCompleteSuccess = await controller.markAsComplete(orderId: orderId);

                if (isMarkCompleteSuccess) {
                  bwDebug("Mark as complete was successful ");
                  if (context.mounted) {
                    final wordDetailController = Get.find<WorkDetailController>();
                    bool isGetOrderSuccess = await wordDetailController.getEmergencyOrder(orderId);

                    if (isGetOrderSuccess) {
                      Get.to(() => UserFeedback(
                        providerId: providerId,
                        oderId: orderId,
                      ));
                    } else {
                      bwDebug("Failed to get emergency order");
                      // Handle the case where getEmergencyOrder fails
                    }
                  }
                } else {
                  bwDebug("Mark as complete failed ");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Mark as complete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
