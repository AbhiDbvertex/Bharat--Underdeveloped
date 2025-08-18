// models/user_profile_model.dart
class UserProfile {
  final String name;
  final String location;
  final String currentLocation;
  final String? address;
  final String? landmark;
  final String? colony;
  final String? category;
  final List<String> subCategories;
  final String profilePic;
  final String skill;
  final List<String> hisWork;
  final List<Review> rateAndReviews;

  UserProfile({
    required this.name,
    required this.location,
    required this.currentLocation,
    this.address,
    this.landmark,
    this.colony,
    required this.category,
    required this.subCategories,
    required this.profilePic,
    required this.skill,
    required this.hisWork,
    required this.rateAndReviews,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['full_name'] ?? 'N/A',
      location: json['location'] ?? 'N/A',
      currentLocation: json['current_location'] ?? 'N/A',
      address: json['full_address'],
      landmark: json['landmark'],
      colony: json['colony_name'],
      category: json['category_name'] ?? '',
      subCategories: List<String>.from(json['subcategory_names'] ?? []),
      profilePic: json['profilePic'] ?? '',
      skill: json['skill'] ?? '',
      hisWork: List<String>.from(json['hiswork'] ?? []),
      rateAndReviews:
          (json['rateAndReviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Review {
  final String review;
  final double rating;
  final List<String> images;
  final String date;

  Review({
    required this.review,
    required this.rating,
    required this.images,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      review: json['review'] ?? '',
      rating: (json['rating'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      date: json['createdAt'] ?? '',
    );
  }
}
