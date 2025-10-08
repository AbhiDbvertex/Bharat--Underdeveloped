class ServiceProviderDetailModel {
  final String? fullName;
  final String? skill;
  final String? profilePic;
  final List<String>? hisWork;
  final List<Review>? rateAndReviews;
  final String? categoryName;
  final List<String>? subcategoryNames;
  final List<String>? emergencySubcategoryNames;
  // final String? documents;
  final List<Document>? documents;
  final Map<String, dynamic>? location;  // Location object
  final List<Map<String, dynamic>>? fullAddress;
  final List<String>? customerReview;
  final int? totalReview;
  final String? rating;


  ServiceProviderDetailModel({
    this.fullName,
    this.skill,
    this.profilePic,
    this.hisWork,
    this.rateAndReviews,
    this.categoryName,
    this.subcategoryNames,
    this.emergencySubcategoryNames,
    this.documents,
    this.location,
    this.fullAddress,
    this.customerReview,
    this.totalReview,
    this.rating,

  });

  factory ServiceProviderDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderDetailModel(
      fullName: json["full_name"],
      skill: json["skill"],
      profilePic: json["profilePic"],
      hisWork: List<String>.from(json["hiswork"] ?? []),
      rateAndReviews: (json["rateAndReviews"] as List?)?.map((e) => Review.fromJson(e)).toList(),
      // categoryName: json["category_name"],
      categoryName: json["category"]?["name"] as String?,
      subcategoryNames: List<String>.from(json["subcategory_names"] ?? []),
      emergencySubcategoryNames: List<String>.from(json["emergencySubcategory_names"] ?? []),
      // documents: json["documents"],
      documents: (json["documents"] as List<dynamic>?)?.map((e) => Document.fromJson(e as Map<String, dynamic>)).toList(),      location: json["location"],  // Location object
      fullAddress: (json["full_address"] as List?)?.map((e) => e as Map<String, dynamic>).toList(),  // Full address list
      customerReview: List<String>.from(json["customerReview"] ?? []),
      totalReview:
      json['totalReview'] is int
          ? json['totalReview']
          : int.tryParse(json['totalReview'].toString()),
      rating: json['rating']?.toString(),
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
}class Document {
  final String? documentName;
  final List<String>? images;

  Document({this.documentName, this.images});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentName: json["documentName"] as String?,
      images: List<String>.from(json["images"] ?? []),
    );
  }
}