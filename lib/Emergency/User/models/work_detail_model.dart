class WorkDetailModel {
  bool? status;
  String? message;
  Data? data;
  dynamic assignedWorker;

  WorkDetailModel({this.status, this.message, this.data, this.assignedWorker});

  WorkDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    assignedWorker = json['assignedWorker'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    map['assignedWorker'] = assignedWorker;
    return map;
  }
}

class Data {
  String? id;
  UserId? userId;
  String? projectId;
  CategoryId? categoryId;
  List<SubCategoryIds>? subCategoryIds;
  String? googleAddress;
  String? detailedAddress;
  String? contact;
  String? deadline;
  List<String>? imageUrls;
  String? hireStatus;
  String? userStatus;
  String? paymentStatus;
  dynamic serviceProviderId;
  bool? platformFeePaid;
  int? platformFee;
  String? razorOrderIdPlatform;
  ServicePayment? servicePayment;
  List<dynamic>? acceptedByProviders;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? razorPaymentIdPlatform;

  Data(
      {this.id,
        this.userId,
        this.projectId,
        this.categoryId,
        this.subCategoryIds,
        this.googleAddress,
        this.detailedAddress,
        this.contact,
        this.deadline,
        this.imageUrls,
        this.hireStatus,
        this.userStatus,
        this.paymentStatus,
        this.serviceProviderId,
        this.platformFeePaid,
        this.platformFee,
        this.razorOrderIdPlatform,
        this.servicePayment,
        this.acceptedByProviders,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.razorPaymentIdPlatform});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['user_id'] != null ? UserId.fromJson(json['user_id']) : null;
    projectId = json['project_id'];
    categoryId = json['category_id'] != null
        ? CategoryId.fromJson(json['category_id'])
        : null;
    if (json['sub_category_ids'] != null) {
      subCategoryIds = <SubCategoryIds>[];
      json['sub_category_ids'].forEach((v) {
        subCategoryIds!.add(SubCategoryIds.fromJson(v));
      });
    }
    googleAddress = json['google_address'];
    detailedAddress = json['detailed_address'];
    contact = json['contact'];
    deadline = json['deadline'];

    imageUrls = json['image_urls'] != null
        ? json['image_urls'].cast<String>()
        : null;
    hireStatus = json['hire_status'];
    userStatus = json['user_status'];
    paymentStatus = json['payment_status'];
    serviceProviderId = json['service_provider_id'];
    platformFeePaid = json['platform_fee_paid'];
    platformFee = json['platform_fee'];
    razorOrderIdPlatform = json['razorOrderIdPlatform'];
    servicePayment = json['service_payment'] != null
        ? ServicePayment.fromJson(json['service_payment'])
        : null;
    acceptedByProviders = json['accepted_by_providers'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
    razorPaymentIdPlatform = json['razorPaymentIdPlatform'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['_id'] = id;
    if (userId != null) map['user_id'] = userId!.toJson();
    map['project_id'] = projectId;
    if (categoryId != null) map['category_id'] = categoryId!.toJson();
    if (subCategoryIds != null) {
      map['sub_category_ids'] =
          subCategoryIds!.map((v) => v.toJson()).toList();
    }
    map['google_address'] = googleAddress;
    map['detailed_address'] = detailedAddress;
    map['contact'] = contact;
    map['deadline'] = deadline;
    map['image_urls'] = imageUrls;
    map['hire_status'] = hireStatus;
    map['user_status'] = userStatus;
    map['payment_status'] = paymentStatus;
    map['service_provider_id'] = serviceProviderId;
    map['platform_fee_paid'] = platformFeePaid;
    map['platform_fee'] = platformFee;
    map['razorOrderIdPlatform'] = razorOrderIdPlatform;
    if (servicePayment != null) map['service_payment'] = servicePayment!.toJson();
    map['accepted_by_providers'] = acceptedByProviders;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    map['razorPaymentIdPlatform'] = razorPaymentIdPlatform;
    return map;
  }
}

class UserId {
  String? id;
  String? phone;
  String? fullName;

  UserId({this.id, this.phone, this.fullName});

  UserId.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    phone = json['phone'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['_id'] = id;
    map['phone'] = phone;
    map['full_name'] = fullName;
    return map;
  }
}

class CategoryId {
  String? id;
  String? name;

  CategoryId({this.id, this.name});

  CategoryId.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['_id'] = id;
    map['name'] = name;
    return map;
  }
}

class SubCategoryIds {
  String? id;
  String? name;

  SubCategoryIds({this.id, this.name});

  SubCategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['_id'] = id;
    map['name'] = name;
    return map;
  }
}

class ServicePayment {
  int? amount;
  int? totalExpected;
  int? remainingAmount;
  int? totalTax;
  List<dynamic>? paymentHistory;

  ServicePayment(
      {this.amount,
        this.totalExpected,
        this.remainingAmount,
        this.totalTax,
        this.paymentHistory});

  ServicePayment.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    totalExpected = json['total_expected'];
    remainingAmount = json['remaining_amount'];
    totalTax = json['total_tax'];
    paymentHistory = json['payment_history'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['amount'] = amount;
    map['total_expected'] = totalExpected;
    map['remaining_amount'] = remainingAmount;
    map['total_tax'] = totalTax;
    map['payment_history'] = paymentHistory;
    return map;
  }
}
