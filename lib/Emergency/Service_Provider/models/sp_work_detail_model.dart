class SpWorkDetailModel {
  bool? status;
  String? message;
  SpData? data;
  SpAssignedWorker? assignedWorker;

  SpWorkDetailModel({this.status, this.message, this.data, this.assignedWorker});

  SpWorkDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? SpData.fromJson(json['data']) : null;
    // assignedWorker = json['assignedWorker'];
    assignedWorker = json['assignedWorker'] != null
        ? SpAssignedWorker.fromJson(json['assignedWorker'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    // map['assignedWorker'] = assignedWorker;
    if (assignedWorker != null) map['assignedWorker'] = assignedWorker!.toJson();

    return map;
  }
}

// class SpAssignedWorker {
//   String? id;
//   String? phone;
//   String? fullName;
//   String? profilePic;
//
//   SpAssignedWorker({this.id, this.phone, this.fullName, this.profilePic});
//
//   SpAssignedWorker.fromJson(Map<String, dynamic> json) {
//     id = json['_id'];
//     phone = json['phone'];
//     fullName = json['full_name'];
//     profilePic = json['profile_pic'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> map = {};
//     map['_id'] = id;
//     map['phone'] = phone;
//     map['full_name'] = fullName;
//     map['profile_pic'] = profilePic;
//     return map;
//   }
// }
class SpAssignedWorker {
  String? id;
  String? name;
  String? phone;
  String? aadharNumber;
  String? dob;
  String? address;
  String? image;
  String? aadharImage;
  String? serviceProviderId;
  String? verifyStatus;
  List<SpAssignOrder>? assignOrders;
  String? createdAt;
  int? v;

  SpAssignedWorker({
    this.id,
    this.name,
    this.phone,
    this.aadharNumber,
    this.dob,
    this.address,
    this.image,
    this.aadharImage,
    this.serviceProviderId,
    this.verifyStatus,
    this.assignOrders,
    this.createdAt,
    this.v,
  });

  SpAssignedWorker.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    phone = json['phone'];
    aadharNumber = json['aadharNumber'];
    dob = json['dob'];
    address = json['address'];
    image = json['image'];
    aadharImage = json['aadharImage'];
    serviceProviderId = json['service_provider_id'];
    verifyStatus = json['verifyStatus'];
    if (json['assignOrders'] != null) {
      assignOrders = <SpAssignOrder>[];
      json['assignOrders'].forEach((v) {
        assignOrders!.add(SpAssignOrder.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['phone'] = phone;
    map['aadharNumber'] = aadharNumber;
    map['dob'] = dob;
    map['address'] = address;
    map['image'] = image;
    map['aadharImage'] = aadharImage;
    map['service_provider_id'] = serviceProviderId;
    map['verifyStatus'] = verifyStatus;
    if (assignOrders != null) {
      map['assignOrders'] = assignOrders!.map((v) => v.toJson()).toList();
    }
    map['createdAt'] = createdAt;
    map['__v'] = v;
    return map;
  }
}

class SpAssignOrder {
  String? orderId;
  String? type;
  String? id;

  SpAssignOrder({this.orderId, this.type, this.id});

  SpAssignOrder.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    type = json['type'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['order_id'] = orderId;
    map['type'] = type;
    map['_id'] = id;
    return map;
  }
}

class SpData {
  String? id;
  SpUserId? userId;
  String? projectId;
  SpCategoryId? categoryId;
  List<SpSubCategoryIds>? subCategoryIds;
  String? googleAddress;
  String? detailedAddress;
  String? contact;
  String? deadline;
  List<String>? imageUrls;
  String? hireStatus;
  String? userStatus;
  String? paymentStatus;
  // dynamic serviceProviderId;
  SpServiceProvider? serviceProvider;
  bool? platformFeePaid;
  int? platformFee;
  String? razorOrderIdPlatform;
  SpServicePayment? servicePayment;
  SpCommission ? commission;
  // List<dynamic>? acceptedByProviders;
  List<SpAcceptedByProvider>? acceptedByProviders;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? razorPaymentIdPlatform;
  SpWarningMessage? warningMessage; // Added SpWarningMessage


  SpData(
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
        this.serviceProvider,
        this.platformFeePaid,
        this.platformFee,
        this.razorOrderIdPlatform,
        this.servicePayment,
        this.commission,
        this.acceptedByProviders,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.razorPaymentIdPlatform,
        this.warningMessage});


  SpData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['user_id'] != null ? SpUserId.fromJson(json['user_id']) : null;
    projectId = json['project_id'];
    categoryId = json['category_id'] != null
        ? SpCategoryId.fromJson(json['category_id'])
        : null;
    if (json['sub_category_ids'] != null) {
      subCategoryIds = <SpSubCategoryIds>[];
      json['sub_category_ids'].forEach((v) {
        subCategoryIds!.add(SpSubCategoryIds.fromJson(v));
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
    // serviceProviderId = json['service_provider_id'];
    serviceProvider = json['service_provider_id'] != null
        ? SpServiceProvider.fromJson(json['service_provider_id'])
        : null;
    platformFeePaid = json['platform_fee_paid'];
    platformFee = json['platform_fee'];
    razorOrderIdPlatform = json['razorOrderIdPlatform'];
    servicePayment = json['service_payment'] != null
        ? SpServicePayment.fromJson(json['service_payment'])
        : null;
    // acceptedByProviders = json['accepted_by_providers'];
    // createdAt = json['createdAt'];
    // updatedAt = json['updatedAt'];
    // v = json['__v'];

    if (json['accepted_by_providers'] != null) {
      acceptedByProviders = <SpAcceptedByProvider>[];
      json['accepted_by_providers'].forEach((v) {
        acceptedByProviders!.add(SpAcceptedByProvider.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
    razorPaymentIdPlatform = json['razorPaymentIdPlatform'];
    warningMessage = json['warningMessage'] != null
        ? SpWarningMessage.fromJson(json['warningMessage'])
        : null;
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
    // map['service_provider_id'] = serviceProviderId;
    if (serviceProvider != null) {
      map['service_provider_id'] = serviceProvider!.toJson();
    }
    map['platform_fee_paid'] = platformFeePaid;
    map['platform_fee'] = platformFee;
    map['razorOrderIdPlatform'] = razorOrderIdPlatform;
    if (servicePayment != null) map['service_payment'] = servicePayment!.toJson();
    // map['accepted_by_providers'] = acceptedByProviders;
    if (acceptedByProviders != null) {
      map['accepted_by_providers'] =
          acceptedByProviders!.map((v) => v.toJson()).toList();
    }
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    map['razorPaymentIdPlatform'] = razorPaymentIdPlatform;
    if (warningMessage != null) map['warningMessage'] = warningMessage!.toJson();

    return map;
  }
}

class SpCommission {
  int? amount;
  int? percentage;
  String? type;
  bool? isCollected;

  SpCommission(this.amount,this.percentage, this.type, this.isCollected);

  SpCommission.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    percentage = json['percentage'];
    type = json['type'];
    isCollected = json['is_collected'];

  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['amount'] = amount;
    map['percentage'] = percentage;
    map['type'] = type;
    map['is_collected'] = isCollected;

    return map;
  }
}

class SpUserId {
  String? id;
  String? phone;
  String? fullName;
  String? profilePic;
  SpUserId({this.id, this.phone, this.fullName, this.profilePic});

  SpUserId.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    phone = json['phone'];
    fullName = json['full_name'];
    profilePic = json['profile_pic'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['_id'] = id;
    map['phone'] = phone;
    map['full_name'] = fullName;
    map['profile_pic'] = profilePic;

    return map;
  }
}

class SpCategoryId {
  String? id;
  String? name;

  SpCategoryId({this.id, this.name});

  SpCategoryId.fromJson(Map<String, dynamic> json) {
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

class SpSubCategoryIds {
  String? id;
  String? name;

  SpSubCategoryIds({this.id, this.name});

  SpSubCategoryIds.fromJson(Map<String, dynamic> json) {
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

class SpServicePayment {
  int? amount;
  int? totalExpected;
  int? remainingAmount;
  int? totalTax;
  List<SpPaymentHistory>? paymentHistory;

  SpServicePayment(
      {this.amount,
        this.totalExpected,
        this.remainingAmount,
        this.totalTax,
        this.paymentHistory});

  SpServicePayment.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    totalExpected = json['total_expected'];
    remainingAmount = json['remaining_amount'];
    totalTax = json['total_tax'];
    // paymentHistory = json['payment_history'];
    if (json['payment_history'] != null) {
      paymentHistory = <SpPaymentHistory>[];
      json['payment_history'].forEach((v) {
        paymentHistory!.add(SpPaymentHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['amount'] = amount;
    map['total_expected'] = totalExpected;
    map['remaining_amount'] = remainingAmount;
    map['total_tax'] = totalTax;
    // map['payment_history'] = paymentHistory;
    if (paymentHistory != null) {
      map['payment_history'] = paymentHistory!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SpPaymentHistory {
  int? amount;
  int? tax;
  String? paymentId;
  String? description;
  String? method;
  String? status;
  String? releaseStatus;
  bool? isCollected;
  int? commissionAmount;
  int? providerEarning;
  String? commissionType;
  int? commissionPercentage;
  String? id;
  String? date;

  SpPaymentHistory({
    this.amount,
    this.tax,
    this.paymentId,
    this.description,
    this.method,
    this.status,
    this.releaseStatus,
    this.isCollected,
  this.commissionAmount,
  this.providerEarning,
  this.commissionType,
  this.commissionPercentage,
    this.id,
    this.date,
  });

  SpPaymentHistory.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    tax = json['tax'];
    paymentId = json['payment_id'];
    description = json['description'];
    method = json['method'];
    status = json['status'];
    releaseStatus = json['release_status'];
    isCollected = json['is_collected'];
    commissionAmount = json['commission_amount'];
    providerEarning = json['provider_earning'];
    commissionType = json['commissionType'];
    commissionPercentage = json['commissionPercentage'];
    id = json['_id'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['amount'] = amount;
    data['tax'] = tax;
    data['payment_id'] = paymentId;
    data['description'] = description;
    data['method'] = method;
    data['status'] = status;
    data['release_status'] = releaseStatus;
    data['is_collected'] = isCollected;
    data['commission_amount'] = commissionAmount;
    data['provider_earning'] = providerEarning;
    data['commissionType'] = commissionType;
    data['commissionPercentage'] = commissionPercentage;
    data['_id'] = id;
    data['date'] = date;
    return data;
  }
}
class SpAcceptedByProvider {
  String? provider;
  String? status;
  String? id;

  SpAcceptedByProvider({this.provider, this.status, this.id});

  SpAcceptedByProvider.fromJson(Map<String, dynamic> json) {
    provider = json['provider'];
    status = json['status'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['provider'] = provider;
    map['status'] = status;
    map['_id'] = id;
    return map;
  }

  static List<SpAcceptedByProvider> fromJsonList(List<dynamic> list) {
    return list.map((e) => SpAcceptedByProvider.fromJson(e)).toList();
  }
}

class SpServiceProvider {
  String? id;
  String? phone;
  String? fullName;
  String? profilePic;

  SpServiceProvider({this.id, this.phone, this.fullName, this.profilePic});

  SpServiceProvider.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    phone = json['phone'];
    fullName = json['full_name'];
    profilePic = json['profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['_id'] = id;
    map['phone'] = phone;
    map['full_name'] = fullName;
    map['profile_pic'] = profilePic;
    return map;
  }
}

// SpWarningMessage class
class SpWarningMessage {
  final String message;

  SpWarningMessage({required this.message});

  factory SpWarningMessage.fromJson(Map<String, dynamic> json) {
    return SpWarningMessage(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['message'] = message;
    return map;
  }
}