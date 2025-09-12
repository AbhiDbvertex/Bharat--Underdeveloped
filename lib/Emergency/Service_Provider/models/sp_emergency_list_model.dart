class SpEmergencyOrderListModel {
  bool status;
  String message;
  List<SpEmergencyOrderData> data;

  SpEmergencyOrderListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SpEmergencyOrderListModel.fromJson(Map<String, dynamic> json) {
    return SpEmergencyOrderListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SpEmergencyOrderData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class SpEmergencyOrderData {
  SpServicePayment servicePayment;
  SpCommission commission;
  double? latitude;
  double? longitude;
  String id;
  SpUser userId;
  String projectId;
  SpCategory categoryId;
  List<SpCategory> subCategoryIds;
  String googleAddress;
  String detailedAddress;
  String contact;
  String deadline;
  List<String> imageUrls;
  String hireStatus;
  String? userStatus;
  String paymentStatus;
  String serviceProviderId;
  bool platformFeePaid;
  int platformFee;
  String razorOrderIdPlatform;
  List<SpAcceptedProvider> acceptedByProviders;
  String createdAt;
  String updatedAt;
  int v;
  String razorPaymentIdPlatform;

  SpEmergencyOrderData({
    required this.servicePayment,
    required this.commission,
    this.latitude,
    this.longitude,
    required this.id,
    required this.userId,
    required this.projectId,
    required this.categoryId,
    required this.subCategoryIds,
    required this.googleAddress,
    required this.detailedAddress,
    required this.contact,
    required this.deadline,
    required this.imageUrls,
    required this.hireStatus,
    required this.userStatus,
    required this.paymentStatus,
    required this.serviceProviderId,
    required this.platformFeePaid,
    required this.platformFee,
    required this.razorOrderIdPlatform,
    required this.acceptedByProviders,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.razorPaymentIdPlatform,
  });

  factory SpEmergencyOrderData.fromJson(Map<String, dynamic> json) {
    return SpEmergencyOrderData(
      servicePayment: SpServicePayment.fromJson(json['service_payment']),
      commission: SpCommission.fromJson(json['commission']),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),

    id: json['_id'] ?? '',
      userId: SpUser.fromJson(json['user_id']),
      projectId: json['project_id'] ?? '',
      categoryId: SpCategory.fromJson(json['category_id']),
      subCategoryIds: (json['sub_category_ids'] as List<dynamic>?)
          ?.map((e) => SpCategory.fromJson(e))
          .toList() ??
          [],
      googleAddress: json['google_address'] ?? '',
      detailedAddress: json['detailed_address'] ?? '',
      contact: json['contact'] ?? '',
      deadline: json['deadline'] ?? '',
      imageUrls:
      (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      hireStatus: json['hire_status'] ?? '',
      userStatus: json['user_status'],
      paymentStatus: json['payment_status'] ?? '',
      serviceProviderId: json['service_provider_id'] ?? '',
      platformFeePaid: json['platform_fee_paid'] ?? false,
      platformFee: json['platform_fee'] ?? 0,
      razorOrderIdPlatform: json['razorOrderIdPlatform'] ?? '',
      acceptedByProviders: (json['accepted_by_providers'] as List<dynamic>?)
          ?.map((e) => SpAcceptedProvider.fromJson(e))
          .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
      razorPaymentIdPlatform: json['razorPaymentIdPlatform'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "service_payment": servicePayment.toJson(),
      "commission": commission.toJson(),
    "latitude" : latitude,
    "longitude" : longitude,
    "_id": id,
      "user_id": userId.toJson(),
      "project_id": projectId,
      "category_id": categoryId.toJson(),
      "sub_category_ids": subCategoryIds.map((e) => e.toJson()).toList(),
      "google_address": googleAddress,
      "detailed_address": detailedAddress,
      "contact": contact,
      "deadline": deadline,
      "image_urls": imageUrls,
      "hire_status": hireStatus,
      "user_status": userStatus,
      "payment_status": paymentStatus,
      "service_provider_id": serviceProviderId,
      "platform_fee_paid": platformFeePaid,
      "platform_fee": platformFee,
      "razorOrderIdPlatform": razorOrderIdPlatform,
      "accepted_by_providers": acceptedByProviders.map((e) => e.toJson()).toList(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
      "razorPaymentIdPlatform": razorPaymentIdPlatform,
    };
  }
}

class SpServicePayment {
  int amount;
  int totalExpected;
  int remainingAmount;
  int totalTax;
  List<SpPaymentHistory> paymentHistory;

  SpServicePayment({
    required this.amount,
    required this.totalExpected,
    required this.remainingAmount,
    required this.totalTax,
    required this.paymentHistory,
  });

  factory SpServicePayment.fromJson(Map<String, dynamic> json) {
    return SpServicePayment(
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      totalExpected: (json['total_expected'] as num?)?.toInt() ?? 0,
      remainingAmount: (json['remaining_amount'] as num?)?.toInt() ?? 0,  // Agar ye double rehna hai toh double field bana, warna int
      totalTax: (json['total_tax'] as num?)?.toInt() ?? 0,
      paymentHistory: (json['payment_history'] as List<dynamic>?)
          ?.map((e) => SpPaymentHistory.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "total_expected": totalExpected,
      "remaining_amount": remainingAmount,
      "total_tax": totalTax,
      "payment_history": paymentHistory.map((e) => e.toJson()).toList(),
    };
  }
}

class SpPaymentHistory {
  int amount;
  int tax;
  String paymentId;
  String description;
  String method;
  String status;
  String releaseStatus;
  bool isCollected;
  int commissionAmount;
  int providerEarning;
  String commissionType;
  int commissionPercentage;
  String id;
  String date;

  SpPaymentHistory({
    required this.amount,
    required this.tax,
    required this.paymentId,
    required this.description,
    required this.method,
    required this.status,
    required this.releaseStatus,
    required this.isCollected,
    required this.commissionAmount,
    required this.providerEarning,
    required this.commissionType,
    required this.commissionPercentage,
    required this.id,
    required this.date,
  });

  factory SpPaymentHistory.fromJson(Map<String, dynamic> json) {
    return SpPaymentHistory(
      amount: (json['amount'] as num?)?.toInt() ?? 0,  // Safe cast
      tax: (json['tax'] as num?)?.toInt() ?? 0,
      paymentId: json['payment_id'] ?? '',
      description: json['description'] ?? '',
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      releaseStatus: json['release_status'] ?? '',
      isCollected: json['is_collected'] ?? false,
      commissionAmount: (json['commission_amount'] as num?)?.toInt() ?? 0,  // Yahan default 0 bana, 0.0 mat rakh
      providerEarning: (json['provider_earning'] as num?)?.toInt() ?? 0,
      commissionType: json['commissionType'] ?? '',
      commissionPercentage: (json['commissionPercentage'] as num?)?.toInt() ?? 0,
      id: json['_id'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "tax": tax,
      "payment_id": paymentId,
      "description": description,
      "method": method,
      "status": status,
      "release_status": releaseStatus,
      "is_collected": isCollected,
      "commission_amount": commissionAmount,
      "provider_earning": providerEarning,
      "commissionType": commissionType,
      "commissionPercentage": commissionPercentage,
      "_id": id,
      "date": date,
    };
  }
}

class SpCommission {
  int amount;
  int percentage;
  String type;
  bool isCollected;

  SpCommission({
    required this.amount,
    required this.percentage,
    required this.type,
    required this.isCollected,
  });

  factory SpCommission.fromJson(Map<String, dynamic> json) {
    return SpCommission(
      amount: json['amount'] ?? 0,
      percentage: json['percentage'] ?? 0,
      type: json['type'] ?? '',
      isCollected: json['is_collected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "percentage": percentage,
      "type": type,
      "is_collected": isCollected,
    };
  }
}

class SpUser {
  String id;
  String fullName;
  String phone;
  String? profilePic;

  SpUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.profilePic,
  });

  factory SpUser.fromJson(Map<String, dynamic> json) {
    return SpUser(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      profilePic: json['profile_pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "full_name": fullName,
      "phone": phone,
      "profile_pic": profilePic,
    };
  }
}

class SpCategory {
  String id;
  String name;

  SpCategory({
    required this.id,
    required this.name,
  });

  factory SpCategory.fromJson(Map<String, dynamic> json) {
    return SpCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
    };
  }
}

class SpAcceptedProvider {
  String provider;
  String status;
  String id;

  SpAcceptedProvider({
    required this.provider,
    required this.status,
    required this.id,
  });

  factory SpAcceptedProvider.fromJson(Map<String, dynamic> json) {
    return SpAcceptedProvider(
      provider: json['provider'] ?? '',
      status: json['status'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "provider": provider,
      "status": status,
      "_id": id,
    };
  }
}
