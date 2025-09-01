/*
class  SpEmergencyListModel {
  bool status;
  String message;
  List<SpEmergencyOrderData> data;

  SpEmergencyListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SpEmergencyListModel.fromJson(Map<String, dynamic> json) {
    return SpEmergencyListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<SpEmergencyOrderData>.from(json['data'].map((x) => SpEmergencyOrderData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class SpEmergencyOrderData {
  SpServicePayment servicePayment;
  String id;
  SpUserModel userId;
  String projectId;
  SpCategory categoryId;
  List<SpSubCategory> subCategoryIds;
  String googleAddress;
  String detailedAddress;
  String contact;
  DateTime deadline;
  List<String> imageUrls;
  String hireStatus;
  String? userStatus;
  String paymentStatus;
  SpServiceProvider? serviceProviderId;
  bool platformFeePaid;
  int platformFee;
  String razorOrderIdPlatform;
  // List<dynamic> acceptedByProviders;
  List<SpAcceptedByProvider> acceptedByProviders;

  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String? razorPaymentIdPlatform;

  SpEmergencyOrderData({
    required this.servicePayment,
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
    this.userStatus,
    required this.paymentStatus,
    this.serviceProviderId,
    required this.platformFeePaid,
    required this.platformFee,
    required this.razorOrderIdPlatform,
    required this.acceptedByProviders,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.razorPaymentIdPlatform,
  });

  factory SpEmergencyOrderData.fromJson(Map<String, dynamic> json) {
    dynamic userJson = json['user_id'];
    SpUserModel parsedUser;

    if (userJson is String) {
      parsedUser = SpUserModel(
        id: userJson,
        phone: "",
        fullName: "",
        profilePic: null,
        totalReview: 0,
        rating: 0,
      );
    } else if (userJson is Map<String, dynamic>) {
      parsedUser = SpUserModel.fromJson(userJson);
    } else {
      parsedUser = SpUserModel(
        id: "",
        phone: "",
        fullName: "",
        profilePic: null,
        totalReview: 0,
        rating: 0,
      );
    }


    return SpEmergencyOrderData(
      servicePayment: SpServicePayment.fromJson(json['service_payment'] ?? {}),
      id: json['_id'] ?? '',
      // userId: UserModel.fromJson(json['user_id'] ?? {}),
      userId: parsedUser,
      projectId: json['project_id'] ?? '',
      categoryId: SpCategory.fromJson(json['category_id'] ?? {}),
      subCategoryIds: json['sub_category_ids'] != null
          ? List<SpSubCategory>.from(json['sub_category_ids'].map((x) => SpSubCategory.fromJson(x)))
          : [],
      googleAddress: json['google_address'] ?? '',
      detailedAddress: json['detailed_address'] ?? '',
      contact: json['contact'] ?? '',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : DateTime.now(),
      imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : [],
      hireStatus: json['hire_status'] ?? '',
      userStatus: json['user_status'],
      paymentStatus: json['payment_status'] ?? '',

      // serviceProviderId: json['service_provider_id'],
      serviceProviderId: json['service_provider_id'] != null
          ? SpServiceProvider.fromJson(json['service_provider_id'])
          : null,

      platformFeePaid: json['platform_fee_paid'] ?? false,
      platformFee: json['platform_fee'] ?? 0,
      razorOrderIdPlatform: json['razorOrderIdPlatform'] ?? '',
      // acceptedByProviders: json['accepted_by_providers'] != null
      //     ? List<dynamic>.from(json['accepted_by_providers'])
      //     : [],
      // acceptedByProviders: List<dynamic>.from(json['accepted_by_providers']),
      acceptedByProviders: (json['accepted_by_providers'] as List<dynamic>?)
          ?.map((e) => SpAcceptedByProvider.fromJson(e))
          .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      v: json['__v'] ?? 0,
      razorPaymentIdPlatform: json['razorPaymentIdPlatform'],
    );
  }

  Map<String, dynamic> toJson() => {
    'service_payment': servicePayment.toJson(),
    '_id': id,
    'user_id': userId.toJson(),
    'project_id': projectId,
    'category_id': categoryId.toJson(),
    'sub_category_ids': List<dynamic>.from(subCategoryIds.map((x) => x.toJson())),
    'google_address': googleAddress,
    'detailed_address': detailedAddress,
    'contact': contact,
    'deadline': deadline.toIso8601String(),
    'image_urls': List<dynamic>.from(imageUrls),
    'hire_status': hireStatus,
    'user_status': userStatus,
    'payment_status': paymentStatus,
    'service_provider_id': serviceProviderId?.toJson(),
    'platform_fee_paid': platformFeePaid,
    'platform_fee': platformFee,
    'razorOrderIdPlatform': razorOrderIdPlatform,
    // 'accepted_by_providers': List<dynamic>.from(acceptedByProviders),
    // 'accepted_by_providers': List<dynamic>.from(acceptedByProviders),
    'accepted_by_providers':
    List<dynamic>.from(acceptedByProviders.map((x) => x.toJson())), // ✅ UPDATED
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
    'razorPaymentIdPlatform': razorPaymentIdPlatform,
  };
}

class SpUserModel {
  String id;
  String phone;
  String fullName;
  String? profilePic; // Changed to nullable String
  int totalReview;
  int rating;

  SpUserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    this.profilePic, // Nullable field
    required this.totalReview,
    required this.rating,
  });

  factory SpUserModel.fromJson(Map<String, dynamic> json) {
    return SpUserModel(
      id: json['_id'] ?? json['id'] ?? '', // Fallback for id
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'], // Nullable, so no need for fallback
      totalReview: json['totalReview'] ?? 0,
      rating: json['rating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'phone': phone,
    'full_name': fullName,
    'profile_pic': profilePic,
    'totalReview': totalReview,
    'rating': rating,
  };
}

class SpServicePayment {
  int amount;
  int totalExpected;
  int remainingAmount;
  int totalTax;
  List<dynamic> paymentHistory;

  SpServicePayment({
    required this.amount,
    required this.totalExpected,
    required this.remainingAmount,
    required this.totalTax,
    required this.paymentHistory,
  });

  factory SpServicePayment.fromJson(Map<String, dynamic> json) {
    return SpServicePayment(
      amount: json['amount'] ?? 0,
      totalExpected: json['total_expected'] ?? 0,
      remainingAmount: json['remaining_amount'] ?? 0,
      totalTax: json['total_tax'] ?? 0,
      paymentHistory: json['payment_history'] != null
          ? List<dynamic>.from(json['payment_history'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'total_expected': totalExpected,
    'remaining_amount': remainingAmount,
    'total_tax': totalTax,
    'payment_history': List<dynamic>.from(paymentHistory),
  };
}

class SpCategory {
  String id;
  String name;

  SpCategory({required this.id, required this.name});

  factory SpCategory.fromJson(Map<String, dynamic> json) {
    return SpCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
  };
}

class SpSubCategory {
  String id;
  String name;

  SpSubCategory({required this.id, required this.name});

  factory SpSubCategory.fromJson(Map<String, dynamic> json) {
    return SpSubCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
  };
}

class SpAcceptedByProvider {
  String provider;
  String status;
  String id;

  SpAcceptedByProvider({
    required this.provider,
    required this.status,
    required this.id,
  });

  factory SpAcceptedByProvider.fromJson(Map<String, dynamic> json) {
    return SpAcceptedByProvider(
      provider: json['provider'] ?? '',
      status: json['status'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'status': status,
    '_id': id,
  };
}
class SpServiceProvider {
  String id;
  String phone;
  String fullName;
  String? profilePic;

  SpServiceProvider({
    required this.id,
    required this.phone,
    required this.fullName,
    this.profilePic,
  });

  factory SpServiceProvider.fromJson(Map<String, dynamic> json) {
    return SpServiceProvider(
      id: json['_id'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'phone': phone,
    'full_name': fullName,
    'profile_pic': profilePic,
  };
}
*/
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
  ServicePayment servicePayment;
  Commission commission;
  String id;
  User userId;
  String projectId;
  Category categoryId;
  List<Category> subCategoryIds;
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
  List<AcceptedProvider> acceptedByProviders;
  String createdAt;
  String updatedAt;
  int v;
  String razorPaymentIdPlatform;

  SpEmergencyOrderData({
    required this.servicePayment,
    required this.commission,
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
      servicePayment: ServicePayment.fromJson(json['service_payment']),
      commission: Commission.fromJson(json['commission']),
      id: json['_id'] ?? '',
      userId: User.fromJson(json['user_id']),
      projectId: json['project_id'] ?? '',
      categoryId: Category.fromJson(json['category_id']),
      subCategoryIds: (json['sub_category_ids'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e))
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
          ?.map((e) => AcceptedProvider.fromJson(e))
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

class ServicePayment {
  int amount;
  int totalExpected;
  int remainingAmount;
  int totalTax;
  List<PaymentHistory> paymentHistory;

  ServicePayment({
    required this.amount,
    required this.totalExpected,
    required this.remainingAmount,
    required this.totalTax,
    required this.paymentHistory,
  });

  factory ServicePayment.fromJson(Map<String, dynamic> json) {
    return ServicePayment(
      amount: json['amount'] ?? 0,
      totalExpected: json['total_expected'] ?? 0,
      remainingAmount: json['remaining_amount'] ?? 0,
      totalTax: json['total_tax'] ?? 0,
      paymentHistory: (json['payment_history'] as List<dynamic>?)
          ?.map((e) => PaymentHistory.fromJson(e))
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

class PaymentHistory {
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

  PaymentHistory({
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

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      amount: json['amount'] ?? 0,
      tax: json['tax'] ?? 0,
      paymentId: json['payment_id'] ?? '',
      description: json['description'] ?? '',
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      releaseStatus: json['release_status'] ?? '',
      isCollected: json['is_collected'] ?? false,
      commissionAmount: json['commission_amount'] ?? 0,
      providerEarning: json['provider_earning'] ?? 0,
      commissionType: json['commissionType'] ?? '',
      commissionPercentage: json['commissionPercentage'] ?? 0,
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

class Commission {
  int amount;
  int percentage;
  String type;
  bool isCollected;

  Commission({
    required this.amount,
    required this.percentage,
    required this.type,
    required this.isCollected,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
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

class User {
  String id;
  String fullName;
  String phone;
  String? profilePic;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

class Category {
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
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

class AcceptedProvider {
  String provider;
  String status;
  String id;

  AcceptedProvider({
    required this.provider,
    required this.status,
    required this.id,
  });

  factory AcceptedProvider.fromJson(Map<String, dynamic> json) {
    return AcceptedProvider(
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
