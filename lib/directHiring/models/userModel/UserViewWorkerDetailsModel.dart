
/*
class ServiceProviderDetailModel {
  final String? fullName;
  final String? skill;
  final String? skillDescription;
  final String? profilePic;
  final List<String>? hisWork;
  final List<Review>? rateAndReviews;
  final String? categoryName;
  final String? subCategoryName;
  final String? documents;
  final String? currentLocation;
  final List<String>? customerReview; // ✅ Added customerReview field

  ServiceProviderDetailModel({
    this.fullName,
    this.skill,
    this.skillDescription,
    this.profilePic,
    this.hisWork,
    this.rateAndReviews,
    this.categoryName,
    this.subCategoryName,
    this.documents,
    this.currentLocation,
    this.customerReview, // ✅ Added
  });

  factory ServiceProviderDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderDetailModel(
      fullName: json["full_name"],
      skill: json["skill"],
      skillDescription: json["skill_description"],
      profilePic: json["profilePic"], // Already full URL in your API
      hisWork: List<String>.from(json["hiswork"] ?? []),
      rateAndReviews: (json["rateAndReviews"] as List?)
          ?.map((e) => Review.fromJson(e))
          .toList(),
      categoryName: json["category_name"],
      subCategoryName: json["subcategories"]?.isNotEmpty == true
          ? json["subcategories"][0]["name"]
          : null,
      documents: json["documents"],
      currentLocation: json["current_location"],
      customerReview: List<String>.from(json["customerReview"] ?? []), // ✅ Added
    );
  }
}
*/

class ServiceProviderDetailModel {
  final String? fullName;
  final String? skill;
  final String? profilePic;
  final List<String>? hisWork;
  final List<Review>? rateAndReviews;
  final String? categoryName;
  final List<String>? subcategoryNames;  // Yeh new add kiya, puri list
  final String? documents;
  final Map<String, dynamic>? location;  // Location object
  final List<Map<String, dynamic>>? fullAddress;  // Full address list add kiya
  final List<String>? customerReview;

  ServiceProviderDetailModel({
    this.fullName,
    this.skill,
    this.profilePic,
    this.hisWork,
    this.rateAndReviews,
    this.categoryName,
    this.subcategoryNames,
    this.documents,
    this.location,
    this.fullAddress,
    this.customerReview,
  });

  factory ServiceProviderDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderDetailModel(
      fullName: json["full_name"],
      skill: json["skill"],
      profilePic: json["profilePic"],
      hisWork: List<String>.from(json["hiswork"] ?? []),
      rateAndReviews: (json["rateAndReviews"] as List?)?.map((e) => Review.fromJson(e)).toList(),
      categoryName: json["category_name"],
      subcategoryNames: List<String>.from(json["subcategory_names"] ?? []),  // Yeh puri list
      documents: json["documents"],
      location: json["location"],  // Location object
      fullAddress: (json["full_address"] as List?)?.map((e) => e as Map<String, dynamic>).toList(),  // Full address list
      customerReview: List<String>.from(json["customerReview"] ?? []),
    );
  }
}

class Review {
  final String review;
  final double rating;
  final List<String> images;
  final String createdAt;

  Review({
    required this.review,
    required this.rating,
    required this.images,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      review: json["review"] ?? '',
      rating: json["rating"]?.toDouble() ?? 0.0,
      images: List<String>.from(json["images"] ?? []),
      createdAt: json["createdAt"],
    );
  }
}