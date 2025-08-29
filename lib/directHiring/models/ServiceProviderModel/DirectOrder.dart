class DirectOrder {
  final String id;
  final String title;
  final String description;
  final String date;
  final String status;
  final String image; // First image
  final String? address; // <-- yeh add kiya
  final User? user_id;
  final List<Offer>? offer_history;

  DirectOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.image,
    this.address, // <-- yeh add kiya
    this.user_id,
    this.offer_history,
  });

  factory DirectOrder.fromJson(Map<String, dynamic> json) {
    return DirectOrder(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['deadline'] != null
          ? json['deadline'].toString().substring(0, 10)
          : '',
      status: json['hire_status'] ?? 'pending',
      image:
          (json['image_url'] is List && (json['image_url'] as List).isNotEmpty)
              ? json['image_url'][0]
              : '',
      address: json['address'] ?? '', // <-- yaha se address pick karega
      user_id: json['user_id'] != null ? User.fromJson(json['user_id']) : null,
      offer_history: json['offer_history'] != null
          ? (json['offer_history'] as List)
              .map((e) => Offer.fromJson(e))
              .toList()
          : null,
    );
  }
}

class User {
  final String? id;
  final String? phone;
  final String? full_name;
  final String? profile_pic;

  User({this.id, this.phone, this.full_name, this.profile_pic});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String?,
      phone: json['phone'] as String?,
      full_name: json['full_name'] as String?,
      profile_pic: json['profile_pic'] as String?,
    );
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
  final String? phone;
  final String? full_name;
  final String? profile_pic;
  final Category? category_id;
  final List<Subcategory>? subcategory_ids;

  Provider({
    this.id,
    this.phone,
    this.full_name,
    this.profile_pic,
    this.category_id,
    this.subcategory_ids,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['_id'] as String?,
      phone: json['phone'] as String?,
      full_name: json['full_name'] as String?,
      profile_pic: json['profile_pic'] as String?,
      category_id: json['category_id'] != null
          ? Category.fromJson(json['category_id'])
          : null,
      subcategory_ids: json['subcategory_ids'] != null
          ? (json['subcategory_ids'] as List)
              .map((e) => Subcategory.fromJson(e))
              .toList()
          : null,
    );
  }
}

class Category {
  final String? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String?,
      name: json['name'] as String?,
    );
  }
}

class Subcategory {
  final String? id;
  final String? name;

  Subcategory({this.id, this.name});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['_id'] as String?,
      name: json['name'] as String?,
    );
  }
}
