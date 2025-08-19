import '../userModel/UserViewWorkerDetailsModel.dart';
import 'ServiceProfileModel.dart';

class ServiceProviderProfileModel {
  final String? id;
  final String? phone;
  late final String? fullName;
  final String? location;
  final String? currentLocation;
  final String? fullAddress;
  final String? landmark;
  final String? colonyName;
  final String? referralCode;
  final bool? active;
  final bool? isProfileComplete;
  final String? role;
  final bool? verified;
  final String? categoryId;
  final String? categoryName;
  final List<String>? subCategoryIds;
  final List<String>? subCategoryNames;
  final String? skill;
  final String? requestStatus;
  late final String? profilePic;
  final List<String>? hisWork;
  final List<Review>? rateAndReviews;
  final List<String>? customerReview;
  final int? totalReview;
  final String? rating;
  final BankDetail? bankDetail;
  final String? documents; // ✅ MISSING FIELD ADDED

  ServiceProviderProfileModel({
    this.id,
    this.phone,
    this.fullName,
    this.location,
    this.currentLocation,
    this.fullAddress,
    this.landmark,
    this.colonyName,
    this.referralCode,
    this.active,
    this.isProfileComplete,
    this.role,
    this.verified,
    this.categoryId,
    this.categoryName,
    this.subCategoryIds,
    this.subCategoryNames,
    this.skill,
    this.profilePic,
    this.hisWork,
    this.rateAndReviews,
    this.customerReview,
    this.totalReview,
    this.rating,
    this.requestStatus,
    this.bankDetail,
    this.documents, // ✅ ADDED HERE TOO
  });

  factory ServiceProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderProfileModel(
      id: json['_id']?.toString(),
      phone: json['phone']?.toString(),
      fullName: json['full_name']?.toString(),
      location: json['location']?.toString(),
      currentLocation: json['current_location']?.toString(),
      fullAddress: json['full_address']?.toString(),
      landmark: json['landmark']?.toString(),
      colonyName: json['colony_name']?.toString(),
      referralCode: json['referral_code']?.toString(),
      active: json['active'] == true,
      isProfileComplete: json['isProfileComplete'] == true,
      role: json['role']?.toString(),
      requestStatus: json['requestStatus']?.toString(),
      verified: json['verified'] == true,
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name']?.toString(),
      subCategoryIds:
          (json['subcategory_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      subCategoryNames:
          (json['subcategory_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      skill: json['skill']?.toString(),
      profilePic: json['profilePic']?.toString(),
      hisWork:
          (json['hiswork'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rateAndReviews:
          (json['rateAndReviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e))
              .toList() ??
          [],
      customerReview:
          (json['customerReview'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalReview:
          json['totalReview'] is int
              ? json['totalReview']
              : int.tryParse(json['totalReview'].toString()),
      rating: json['rating']?.toString(),
      bankDetail:
          json['bankdetail'] != null
              ? BankDetail.fromJson(json['bankdetail'])
              : null,
      documents: json['documents']?.toString(),
    );
  }
}
