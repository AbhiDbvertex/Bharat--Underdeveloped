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
