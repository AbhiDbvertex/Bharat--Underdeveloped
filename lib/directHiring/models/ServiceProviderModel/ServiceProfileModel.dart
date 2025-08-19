class ServiceProfileModel {
  final String? id;
  final String? phone;
  final String? fullName;
  final String? location;
  final String? currentLocation;
  final String? fullAddress;
  final String? landmark;
  final String? colonyName;
  final String? referralCode;
  final bool active;
  final bool isProfileComplete;
  final String? role;
  final bool verified;
  final String? categoryId;
  final String? categoryName;
  final List<String> subcategoryIds;
  final List<String> subcategoryNames;
  final String? skill;
  final String? profilePic;
  final List<String> hiswork;
  final List<RateAndReview> rateAndReviews;
  final List<CustomerReview> customerReviews;
  final int totalReview;
  final double rating;
  final BankDetail? bankDetail;

  ServiceProfileModel({
    this.id,
    this.phone,
    this.fullName,
    this.location,
    this.currentLocation,
    this.fullAddress,
    this.landmark,
    this.colonyName,
    this.referralCode,
    this.active = false,
    this.isProfileComplete = false,
    this.role,
    this.verified = false,
    this.categoryId,
    this.categoryName,
    this.subcategoryIds = const [],
    this.subcategoryNames = const [],
    this.skill,
    this.profilePic,
    this.hiswork = const [],
    this.rateAndReviews = const [],
    this.customerReviews = const [],
    this.totalReview = 0,
    this.rating = 0.0,
    this.bankDetail,
  });

  factory ServiceProfileModel.fromJson(Map<String, dynamic> json) {
    return ServiceProfileModel(
      id: json['_id'],
      phone: json['phone'],
      fullName: json['full_name'],
      location: json['location'],
      currentLocation: json['current_location'],
      fullAddress: json['full_address'],
      landmark: json['landmark'],
      colonyName: json['colony_name'],
      referralCode: json['referral_code'],
      active: json['active'] ?? false,
      isProfileComplete: json['isProfileComplete'] ?? false,
      role: json['role'],
      verified: json['verified'] ?? false,
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      subcategoryIds: List<String>.from(json['subcategory_ids'] ?? []),
      subcategoryNames: List<String>.from(json['subcategory_names'] ?? []),
      skill: json['skill'],
      profilePic: json['profilePic'],
      hiswork: List<String>.from(json['hiswork'] ?? []),
      rateAndReviews:
          (json['rateAndReviews'] as List<dynamic>?)
              ?.map((e) => RateAndReview.fromJson(e))
              .toList() ??
          [],
      customerReviews:
          (json['customerReview'] as List<dynamic>?)
              ?.map((e) => CustomerReview.fromJson(e))
              .toList() ??
          [],
      totalReview: json['totalReview'] ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      bankDetail:
          json['bankdetail'] != null
              ? BankDetail.fromJson(json['bankdetail'])
              : null,
    );
  }
}

class RateAndReview {
  final String? userId;
  final String? review;
  final double rating;
  final List<String> images;
  final String createdAt;

  RateAndReview({
    this.userId,
    this.review,
    this.rating = 0.0,
    this.images = const [],
    this.createdAt = '',
  });

  factory RateAndReview.fromJson(Map<String, dynamic> json) {
    return RateAndReview(
      userId: json['user_id'],
      review: json['review'],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class CustomerReview {
  final List<String> images;

  CustomerReview({this.images = const []});

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(images: List<String>.from(json['images'] ?? []));
  }
}

class BankDetail {
  final String? accountNumber;
  final String? accountHolderName;
  final String? bankName;
  final String? ifscCode;
  final String? upiId;

  BankDetail({
    this.accountNumber,
    this.accountHolderName,
    this.bankName,
    this.ifscCode,
    this.upiId,
  });

  factory BankDetail.fromJson(Map<String, dynamic> json) {
    return BankDetail(
      accountNumber: json['accountNumber'],
      accountHolderName: json['accountHolderName'],
      bankName: json['bankName'],
      ifscCode: json['ifscCode'],
      upiId: json['upiId'],
    );
  }
}
