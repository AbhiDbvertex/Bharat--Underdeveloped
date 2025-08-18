
/*class DirectOrder {
  final String id;
  final String title;
  final String description;
  final String date;
  final String status;
  final String image;
  final String providerId;
  final User? user_id;
  final List<Offer>? offer_history; // 👈 Added offer_history field

  DirectOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.image,
    required this.providerId,
    this.user_id,
    this.offer_history,
  });

  factory DirectOrder.fromJson(Map<String, dynamic> json) {
    return DirectOrder(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['deadline'] != null && json['deadline'].toString().length >= 10
          ? json['deadline'].toString().substring(0, 10)
          : '',
      status: json['hire_status'] ?? 'pending',
      image: json['image_url'] is List && (json['image_url'] as List).isNotEmpty
          ? 'http://api.thebharatworks.com${json['image_url'][0]}'
          : '',
      providerId: json['provider_id'] is Map
          ? json['provider_id']['_id'] ?? ''
          : json['provider_id'] ?? '',
      user_id: json['user_id'] != null ? User.fromJson(json['user_id']) : null,
      offer_history: json['offer_history'] != null
          ? (json['offer_history'] as List)
          .map((e) => Offer.fromJson(e))
          .toList()
          : null,
    );
  }
}*/

class DirectOrder {
  final String id;
  final String title;
  final String description;
  final String date;
  final String status;
  final String image; // Single string for first image_url
  final String providerId;
  final User? user_id;
  final List<Offer>? offer_history;

  DirectOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.image,
    required this.providerId,
    this.user_id,
    this.offer_history,
  });

  factory DirectOrder.fromJson(Map<String, dynamic> json) {
    return DirectOrder(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date:
      json['deadline'] != null && json['deadline'].toString().length >= 10
          ? json['deadline'].toString().substring(0, 10)
          : '',
      status: json['hire_status'] ?? 'pending',
      image:
      json['image_url'] is List && (json['image_url'] as List).isNotEmpty
          ? json['image_url'][0] // Directly use image_url[0]
          : '', // Empty string if no image_url
      providerId:
      json['provider_id'] is Map
          ? json['provider_id']['_id'] ?? ''
          : json['provider_id'] ?? '',
      user_id: json['user_id'] != null ? User.fromJson(json['user_id']) : null,
      offer_history:
      json['offer_history'] != null
          ? (json['offer_history'] as List)
          .map((e) => Offer.fromJson(e))
          .toList()
          : null,
    );
  }
}

class User {
  final String? profile_pic;

  User({this.profile_pic});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(profile_pic: json['profile_pic'] as String?);
  }
}

class Offer {
  final String? status;
  final Provider? provider_id;

  Offer({this.status, this.provider_id});

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      status: json['status'] as String?,
      provider_id: json['provider_id'] != null
          ? Provider.fromJson(json['provider_id'])
          : null,
    );
  }
}

class Provider {
  final String? id;
  final String? full_name;

  Provider({this.id, this.full_name});

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['_id'] as String?,
      full_name: json['full_name'] as String?,
    );
  }
}