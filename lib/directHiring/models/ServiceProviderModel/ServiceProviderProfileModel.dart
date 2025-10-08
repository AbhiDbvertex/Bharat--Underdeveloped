import '../userModel/UserViewWorkerDetailsModel.dart';
import 'ServiceProfileModel.dart';
class Document {
  final String? documentName;
  final List<String>? images;

  Document({this.documentName, this.images});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentName: json['documentName']?.toString(),
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
class ServiceProviderProfileModel {
  final String? id;
  final String? phone;
  late final String? fullName;
  late final String? age;
  late final String? gender;
  final String? location;
  final String? currentLocation;
  final String? fullAddress;
  final String? landmark;
  final String? colonyName;
  final String? referralCode;
  final bool? active;
  final bool? isProfileComplete;
  final String? role;
  final String? verificationStatus;
  final String? rejectionReason;
  final String? categoryId;
  final String? categoryName;
  final List<String>? subCategoryIds;
  final List<String>? subCategoryNames;
  final List<String>? subEmergencyCategoryIds;
  final List<String>? subEmergencyCategoryNames;
  final String? skill;
  final String? requestStatus;
  late final String? profilePic;
  final List<String>? hisWork;
  final List<Review>? rateAndReviews;
  final List<String>? customerReview;
  final int? totalReview;
  final String? rating;
  final BankDetail? bankDetail;
  // final String? documents;// ✅ MISSING FIELD ADDED
  final BusinessAddress? businessAddress;
  final bool? isShop;
  final List<Document>? documents; // Changed from String? to List<Document>?
  final List<String>? businessImage;

  ServiceProviderProfileModel({
    this.id,
    this.phone,
    this.fullName,
    this.age,
    this.gender,
    this.location,
    this.currentLocation,
    this.fullAddress,
    this.landmark,
    this.colonyName,
    this.referralCode,
    this.active,
    this.isProfileComplete,
    this.role,
    this.verificationStatus,
    this.rejectionReason,
    this.categoryId,
    this.categoryName,
    this.subCategoryIds,
    this.subCategoryNames,
    this.subEmergencyCategoryIds,
    this.subEmergencyCategoryNames,
    this.skill,
    this.profilePic,
    this.hisWork,
    this.rateAndReviews,
    this.customerReview,
    this.totalReview,
    this.rating,
    this.requestStatus,
    this.bankDetail,
    this.documents,
    this.businessAddress,
    this.isShop,
    this.businessImage
  });
  //Keys in Flutter uniquely identify widgets and preserve their state during rebuilds, especially in lists or tree changes

  factory ServiceProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderProfileModel(
      id: json['_id']?.toString(),
      phone: json['phone']?.toString(),
      fullName: json['full_name']?.toString(),
      age: json['age']?.toString(),
      gender: json['gender']?.toString(),
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
      rejectionReason: json['rejectionReason']?.toString(),
      verificationStatus: json['verificationStatus'] ?? "",
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
      // subEmergencyCategoryIds:
      //     (json['emergencySubcategory_ids'] as List<dynamic>?)
      //         ?.map((e) => e.toString())
      //         .toList() ??
      //     [],
      // subEmergencyCategoryNames:
      //     (json['emergencySubcategory_names'] as List<dynamic>?)
      //         ?.map((e) => e.toString())
      //         .toList() ??
      //     [],
      subEmergencyCategoryIds:
      (json['emergencysubcategory_ids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      subEmergencyCategoryNames:
      (json['emergencySubcategory_names'] as List<dynamic>?)
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
          (json['rateAndReviews'] as List<dynamic>?)?.map((e) => Review.fromJson(e)).toList() ?? [],
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
      // documents: json['documents']?.toString(),
      documents: (json['documents'] as List<dynamic>?)?.map((e) => Document.fromJson(e)).toList() ?? [],
      businessAddress: json['businessAddress'] != null
          ? BusinessAddress.fromJson(json['businessAddress'])
          : null,
      isShop: json['isShop'] == true,
      businessImage: (json['businessImage'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],

    );
  }
}
class BusinessAddress {
  final String? address;
  final double? latitude;
  final double? longitude;

  BusinessAddress({
    this.address,
    this.latitude,
    this.longitude,
  });

  factory BusinessAddress.fromJson(Map<String, dynamic> json) {
    return BusinessAddress(
      address: json['address']?.toString(),
      latitude: json['latitude'] is double
          ? json['latitude']
          : double.tryParse(json['latitude'].toString()),
      longitude: json['longitude'] is double
          ? json['longitude']
          : double.tryParse(json['longitude'].toString()),
    );
  }
}