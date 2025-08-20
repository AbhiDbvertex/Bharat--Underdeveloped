// class EmergencyListModel {
//   bool status;
//   String message;
//   List<EmergencyOrderData> data;
//
//   EmergencyListModel({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   factory EmergencyListModel.fromJson(Map<String, dynamic> json) {
//     return EmergencyListModel(
//       status: json['status'],
//       message: json['message'],
//       data: List<EmergencyOrderData>.from(
//           json['data'].map((x) => EmergencyOrderData.fromJson(x))),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'status': status,
//     'message': message,
//     'data': List<dynamic>.from(data.map((x) => x.toJson())),
//   };
// }
//
// class EmergencyOrderData {
//   ServicePayment servicePayment;
//   String id;
//   String userId;
//   String projectId;
//   Category categoryId;
//   List<SubCategory> subCategoryIds;
//   String googleAddress;
//   String detailedAddress;
//   String contact;
//   DateTime deadline;
//   List<String> imageUrls;
//   String hireStatus;
//   String? userStatus;
//   String paymentStatus;
//   String? serviceProviderId;
//   bool platformFeePaid;
//   int platformFee;
//   String razorOrderIdPlatform;
//   List<dynamic> acceptedByProviders;
//   DateTime createdAt;
//   DateTime updatedAt;
//   int v;
//   String? razorPaymentIdPlatform;
//
//   EmergencyOrderData({
//     required this.servicePayment,
//     required this.id,
//     required this.userId,
//     required this.projectId,
//     required this.categoryId,
//     required this.subCategoryIds,
//     required this.googleAddress,
//     required this.detailedAddress,
//     required this.contact,
//     required this.deadline,
//     required this.imageUrls,
//     required this.hireStatus,
//     this.userStatus,
//     required this.paymentStatus,
//     this.serviceProviderId,
//     required this.platformFeePaid,
//     required this.platformFee,
//     required this.razorOrderIdPlatform,
//     required this.acceptedByProviders,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.v,
//     this.razorPaymentIdPlatform,
//   });
//
//   factory EmergencyOrderData.fromJson(Map<String, dynamic> json) {
//     return EmergencyOrderData(
//       servicePayment: ServicePayment.fromJson(json['service_payment']),
//       id: json['_id'],
//       userId: json['user_id'],
//       projectId: json['project_id'],
//       categoryId: Category.fromJson(json['category_id']),
//       subCategoryIds: List<SubCategory>.from(
//           json['sub_category_ids'].map((x) => SubCategory.fromJson(x))),
//       googleAddress: json['google_address'],
//       detailedAddress: json['detailed_address'],
//       contact: json['contact'],
//       deadline: DateTime.parse(json['deadline']),
//       imageUrls: List<String>.from(json['image_urls']),
//       hireStatus: json['hire_status'],
//       userStatus: json['user_status'],
//       paymentStatus: json['payment_status'],
//       serviceProviderId: json['service_provider_id'],
//       platformFeePaid: json['platform_fee_paid'],
//       platformFee: json['platform_fee'],
//       razorOrderIdPlatform: json['razorOrderIdPlatform'],
//       acceptedByProviders: List<dynamic>.from(json['accepted_by_providers']),
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       v: json['__v'],
//       razorPaymentIdPlatform: json['razorPaymentIdPlatform'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'service_payment': servicePayment.toJson(),
//     '_id': id,
//     'user_id': userId,
//     'project_id': projectId,
//     'category_id': categoryId.toJson(),
//     'sub_category_ids':
//     List<dynamic>.from(subCategoryIds.map((x) => x.toJson())),
//     'google_address': googleAddress,
//     'detailed_address': detailedAddress,
//     'contact': contact,
//     'deadline': deadline.toIso8601String(),
//     'image_urls': List<dynamic>.from(imageUrls),
//     'hire_status': hireStatus,
//     'user_status': userStatus,
//     'payment_status': paymentStatus,
//     'service_provider_id': serviceProviderId,
//     'platform_fee_paid': platformFeePaid,
//     'platform_fee': platformFee,
//     'razorOrderIdPlatform': razorOrderIdPlatform,
//     'accepted_by_providers': List<dynamic>.from(acceptedByProviders),
//     'createdAt': createdAt.toIso8601String(),
//     'updatedAt': updatedAt.toIso8601String(),
//     '__v': v,
//     'razorPaymentIdPlatform': razorPaymentIdPlatform,
//   };
// }
//
// class ServicePayment {
//   int amount;
//   int totalExpected;
//   int remainingAmount;
//   int totalTax;
//   List<dynamic> paymentHistory;
//
//   ServicePayment({
//     required this.amount,
//     required this.totalExpected,
//     required this.remainingAmount,
//     required this.totalTax,
//     required this.paymentHistory,
//   });
//
//   factory ServicePayment.fromJson(Map<String, dynamic> json) {
//     return ServicePayment(
//       amount: json['amount'],
//       totalExpected: json['total_expected'],
//       remainingAmount: json['remaining_amount'],
//       totalTax: json['total_tax'],
//       paymentHistory: List<dynamic>.from(json['payment_history']),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'amount': amount,
//     'total_expected': totalExpected,
//     'remaining_amount': remainingAmount,
//     'total_tax': totalTax,
//     'payment_history': List<dynamic>.from(paymentHistory),
//   };
// }
//
// class Category {
//   String id;
//   String name;
//
//   Category({required this.id, required this.name});
//
//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['_id'],
//       name: json['name'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     '_id': id,
//     'name': name,
//   };
// }
//
// class SubCategory {
//   String id;
//   String name;
//
//   SubCategory({required this.id, required this.name});
//
//   factory SubCategory.fromJson(Map<String, dynamic> json) {
//     return SubCategory(
//       id: json['_id'],
//       name: json['name'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     '_id': id,
//     'name': name,
//   };
// }


class EmergencyListModel {
  bool status;
  String message;
  List<EmergencyOrderData> data;

  EmergencyListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EmergencyListModel.fromJson(Map<String, dynamic> json) {
    return EmergencyListModel(
      status: json['status'],
      message: json['message'],
      data: List<EmergencyOrderData>.from(
          json['data'].map((x) => EmergencyOrderData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class EmergencyOrderData {
  ServicePayment servicePayment;
  String id;
  UserModel userId;
  String projectId;
  Category categoryId;
  List<SubCategory> subCategoryIds;
  String googleAddress;
  String detailedAddress;
  String contact;
  DateTime deadline;
  List<String> imageUrls;
  String hireStatus;
  String? userStatus;
  String paymentStatus;
  String? serviceProviderId;
  bool platformFeePaid;
  int platformFee;
  String razorOrderIdPlatform;
  List<dynamic> acceptedByProviders;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String? razorPaymentIdPlatform;

  EmergencyOrderData({
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

  factory EmergencyOrderData.fromJson(Map<String, dynamic> json) {
    return EmergencyOrderData(
      servicePayment: ServicePayment.fromJson(json['service_payment']),
      id: json['_id'],
      userId: UserModel.fromJson(json['user_id']),
      projectId: json['project_id'],
      categoryId: Category.fromJson(json['category_id']),
      subCategoryIds: List<SubCategory>.from(
          json['sub_category_ids'].map((x) => SubCategory.fromJson(x))),
      googleAddress: json['google_address'],
      detailedAddress: json['detailed_address'],
      contact: json['contact'],
      deadline: DateTime.parse(json['deadline']),
      imageUrls: List<String>.from(json['image_urls']),
      hireStatus: json['hire_status'],
      userStatus: json['user_status'],
      paymentStatus: json['payment_status'],
      serviceProviderId: json['service_provider_id'],
      platformFeePaid: json['platform_fee_paid'],
      platformFee: json['platform_fee'],
      razorOrderIdPlatform: json['razorOrderIdPlatform'],
      acceptedByProviders: List<dynamic>.from(json['accepted_by_providers']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
      razorPaymentIdPlatform: json['razorPaymentIdPlatform'],
    );
  }

  Map<String, dynamic> toJson() => {
    'service_payment': servicePayment.toJson(),
    '_id': id,
    'user_id': userId.toJson(),
    'project_id': projectId,
    'category_id': categoryId.toJson(),
    'sub_category_ids':
    List<dynamic>.from(subCategoryIds.map((x) => x.toJson())),
    'google_address': googleAddress,
    'detailed_address': detailedAddress,
    'contact': contact,
    'deadline': deadline.toIso8601String(),
    'image_urls': List<dynamic>.from(imageUrls),
    'hire_status': hireStatus,
    'user_status': userStatus,
    'payment_status': paymentStatus,
    'service_provider_id': serviceProviderId,
    'platform_fee_paid': platformFeePaid,
    'platform_fee': platformFee,
    'razorOrderIdPlatform': razorOrderIdPlatform,
    'accepted_by_providers': List<dynamic>.from(acceptedByProviders),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
    'razorPaymentIdPlatform': razorPaymentIdPlatform,
  };
}

class UserModel {
  String id;
  String phone;
  String fullName;
  String profilePic;
  int totalReview;
  int rating;

  UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.profilePic,
    required this.totalReview,
    required this.rating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      phone: json['phone'],
      fullName: json['full_name'],
      profilePic: json['profile_pic'],
      totalReview: json['totalReview'],
      rating: json['rating'],
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

class ServicePayment {
  int amount;
  int totalExpected;
  int remainingAmount;
  int totalTax;
  List<dynamic> paymentHistory;

  ServicePayment({
    required this.amount,
    required this.totalExpected,
    required this.remainingAmount,
    required this.totalTax,
    required this.paymentHistory,
  });

  factory ServicePayment.fromJson(Map<String, dynamic> json) {
    return ServicePayment(
      amount: json['amount'],
      totalExpected: json['total_expected'],
      remainingAmount: json['remaining_amount'],
      totalTax: json['total_tax'],
      paymentHistory: List<dynamic>.from(json['payment_history']),
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

class Category {
  String id;
  String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
  };
}

class SubCategory {
  String id;
  String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
  };
}
