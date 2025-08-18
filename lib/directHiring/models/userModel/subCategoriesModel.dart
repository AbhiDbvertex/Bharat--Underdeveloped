// class ServiceProviderModel {
//   final String? id;
//   final String? fullName;
//   final String? location;
//   final String? skill;
//   final List<String> hisWork;
//   final bool? verified;
//   final double rating;
//   final int totalReview;
//   final String? categoryName;
//   final String? subCategoryName;
//   final String? profilePic;
//   final String? currentToken; // Added for authentication
//
//   ServiceProviderModel({
//     this.id,
//     this.fullName,
//     this.location,
//     this.skill,
//     this.hisWork = const [],
//     this.verified,
//     this.rating = 0.0,
//     this.totalReview = 0,
//     this.categoryName,
//     this.subCategoryName,
//     this.profilePic,
//     this.currentToken,
//   });
//
//   factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
//     print(
//       "📌 Worker: ${json['full_name'] ?? 'Unknown'}, profilePic: ${json['profilePic'] ?? json['profile_pic']}",
//     );
//
//     double avgRating = 0.0;
//     int reviewCount = 0;
//
//     if (json['rateAndReviews'] != null && json['rateAndReviews'] is List) {
//       List<dynamic> reviews = json['rateAndReviews'];
//       reviewCount = reviews.length;
//
//       if (reviewCount > 0) {
//         double total = 0.0;
//         for (var review in reviews) {
//           if (review['rating'] != null) {
//             total += double.tryParse(review['rating'].toString()) ?? 0.0;
//           }
//         }
//         avgRating = total / reviewCount;
//       }
//     }
//
//     return ServiceProviderModel(
//       id: (json['_id'] ?? json['id'])?.toString().trim(),
//       fullName: json['full_name'] ?? "Unnamed",
//       location: json['location'] ?? "No location",
//       skill: json['skill'],
//       verified: json['verified'],
//       rating: avgRating,
//       totalReview: reviewCount,
//       hisWork:
//           (json['hiswork'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       categoryName: json['category_id'] ?? "N/A",
//       subCategoryName: json['sub_category_id'] ?? "N/A",
//       profilePic:
//           json['profilePic']?.toString() ?? json['profile_pic']?.toString(),
//       currentToken: json['current_token']?.toString(),
//     );
//   }
// }

class ServiceProviderModel {
  final String? id;
  final String? fullName;
  final Map<String, dynamic>? location; // 👈 fixed: location is a Map now
  final String? skill;
  final List<String> hisWork;
  final bool? verified;
  final double rating;
  final int totalReview;
  final String? categoryName;
  final String? subCategoryName;
  final String? profilePic;
  final String? currentToken;

  ServiceProviderModel({
    this.id,
    this.fullName,
    this.location,
    this.skill,
    this.hisWork = const [],
    this.verified,
    this.rating = 0.0,
    this.totalReview = 0,
    this.categoryName,
    this.subCategoryName,
    this.profilePic,
    this.currentToken,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    print(
      "📌 Worker: ${json['full_name'] ?? 'Unknown'}, profilePic: ${json['profilePic'] ?? json['profile_pic']}",
    );

    double avgRating = 0.0;
    int reviewCount = 0;

    if (json['rateAndReviews'] != null && json['rateAndReviews'] is List) {
      List<dynamic> reviews = json['rateAndReviews'];
      reviewCount = reviews.length;

      if (reviewCount > 0) {
        double total = 0.0;
        for (var review in reviews) {
          if (review['rating'] != null) {
            total += double.tryParse(review['rating'].toString()) ?? 0.0;
          }
        }
        avgRating = total / reviewCount;
      }
    }

    return ServiceProviderModel(
      id: (json['_id'] ?? json['id'])?.toString().trim(),
      fullName: json['full_name'] ?? "Unnamed",
      location: json['location'] as Map<String, dynamic>?, // 👈 fix here
      skill: json['skill'],
      verified: json['verified'],
      rating: avgRating,
      totalReview: reviewCount,
      hisWork: (json['hiswork'] as List?)?.map((e) => e.toString()).toList() ?? [],
      categoryName: json['category_id'] ?? "N/A",
      subCategoryName: json['sub_category_id'] ?? "N/A",
      profilePic: json['profilePic']?.toString() ?? json['profile_pic']?.toString(),
      currentToken: json['current_token']?.toString(),
    );
  }
}
