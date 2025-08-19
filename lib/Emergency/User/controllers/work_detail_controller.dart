import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/emergency_list_model.dart';

class WorkDetailController extends GetxController {
  final EmergencyOrderData data;

  WorkDetailController(this.data);

  var imageUrls = <String>[].obs;
  var projectId = "".obs;
  var categoryName = "".obs;
  var subCategories = "".obs;
  var googleAddress = "".obs;
  var detailedAddress = "".obs;
  var contact = "".obs;
  var deadline = "".obs;
  var hireStatus = "".obs;
  var paymentAmount = 0.obs;
  var currentImageIndex = 0.obs;   // dots indicator ke liye

  @override
  void onInit() {
    super.onInit();

    imageUrls.value = data.imageUrls; // ye ab sab images ko hold karega
    projectId.value = data.projectId;
    categoryName.value = data.categoryId.name;

    // take only first 2 subcategories
    if (data.subCategoryIds.isNotEmpty) {
      final subNames = data.subCategoryIds.map((e) => e.name).toList();
      subCategories.value = subNames.take(2).join(", ");
    } else {
      subCategories.value = "N/A";
    }

    googleAddress.value = data.googleAddress;
    detailedAddress.value = data.detailedAddress;
    contact.value = data.contact;
    deadline.value = DateFormat('dd/MM/yyyy').format(data.deadline);
    hireStatus.value =
    "${data.hireStatus[0].toUpperCase()}${data.hireStatus.substring(1)}";
    paymentAmount.value = data.servicePayment.amount;
  }
}
