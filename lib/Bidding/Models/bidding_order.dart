
class UserId {
  final String id;
  final String fullName;
  final String phone;
  final String? profilePic;
  final Location? location;

  UserId({
    required this.id,
    required this.fullName,
    required this.phone,
    this.profilePic,
    this.location,
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown User',
      phone: json['phone'] ?? '',
      profilePic: json['profile_pic'] != null
          ? json['profile_pic'].startsWith('http')
          ? json['profile_pic']
          : 'https://api.thebharatworks.com${json['profile_pic'].replaceAll('//Uploads', '/Uploads')}'
          : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }
}

// Location model for UserId
class Location {
  final double latitude;
  final double longitude;
  final String address;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? 'No Address',
    );
  }
}

// AssignedWorker model (tumhara code same rakha hai)
class AssignedWorker {
  final String id;
  final String name;
  final String? image;
  final String? address;

  AssignedWorker({
    required this.id,
    required this.name,
    this.image,
    this.address,
  });

  factory AssignedWorker.fromJson(Map<String, dynamic> json) {
    return AssignedWorker(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Worker',
      image: json['image'] != null
          ? json['image'].startsWith('http')
          ? json['image']
          : 'https://api.thebharatworks.com${json['image'].replaceAll('//Uploads', '/Uploads')}'
          : null,
      address: json['address'] ?? 'No Address',
    );
  }
}


class BiddingOrder {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String address;
  final double cost;
  final String deadline;
  final String hireStatus;
  final String? serviceProviderId;
  final List<String> imageUrls;
  final UserId? userId;
  final String categoryId;
  final List<String> subcategoryIds;
  final Map<String, dynamic>? servicePayment;
  final AssignedWorker? assignedWorker;
  final double latitude; // Added latitude field
  final double longitude; // Added longitude field

  BiddingOrder({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.address,
    required this.cost,
    required this.deadline,
    required this.hireStatus,
    this.serviceProviderId,
    required this.imageUrls,
    this.userId,
    required this.categoryId,
    required this.subcategoryIds,
    this.servicePayment,
    this.assignedWorker,
    required this.latitude, // Make latitude required
    required this.longitude, // Make longitude required
  });

  factory BiddingOrder.fromJson(Map<String, dynamic> json) {
    // Handle image_url
    List<String> imageUrls = [];
    if (json['image_url'] != null) {
      if (json['image_url'] is String) {
        String cleanUrl =
        json['image_url'].toString().replaceAll('//Uploads', '/Uploads');
        imageUrls = [
          cleanUrl.startsWith('http')
              ? cleanUrl
              : 'https://api.thebharatworks.com$cleanUrl'
        ];
      } else if (json['image_url'] is List<dynamic>) {
        imageUrls = (json['image_url'] as List<dynamic>).map((url) {
          String cleanUrl = url.toString().replaceAll('//Uploads', '/Uploads');
          return cleanUrl.startsWith('http')
              ? cleanUrl
              : 'https://api.thebharatworks.com$cleanUrl';
        }).toList();
      }
    }

    // Handle category_id
    String categoryId = '';
    if (json['category_id'] != null) {
      if (json['category_id'] is String) {
        categoryId = json['category_id'];
      } else if (json['category_id'] is Map) {
        categoryId = json['category_id']['_id'] ?? '';
      }
    }

    // Handle subcategory_ids
    List<String> subcategoryIds = [];
    if (json['sub_category_ids'] != null && json['sub_category_ids'] is List) {
      subcategoryIds = (json['sub_category_ids'] as List<dynamic>)
          .map((subcategory) {
        if (subcategory is String) {
          return subcategory;
        } else if (subcategory is Map) {
          return subcategory['_id']?.toString() ?? '';
        }
        return '';
      })
          .where((id) => id.isNotEmpty)
          .toList();
    }

    // Handle assignedWorker
    AssignedWorker? assignedWorker;
    if (json['assignedWorker'] != null) {
      assignedWorker = AssignedWorker.fromJson(json['assignedWorker']);
    } else if (json['assigned_worker'] != null) {
      assignedWorker = AssignedWorker.fromJson(json['assigned_worker']);
    } else if (json['worker_id'] != null) {
      assignedWorker = AssignedWorker.fromJson(json['worker_id'] is Map
          ? json['worker_id']
          : {'_id': json['worker_id']});
    }

    return BiddingOrder(
      id: json['_id'] ?? '',
      projectId: json['project_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      deadline: json['deadline'] ?? '',
      hireStatus: json['hire_status'] ?? 'pending',
      serviceProviderId: json['service_provider_id'] != null
          ? json['service_provider_id'] is String
          ? json['service_provider_id']
          : json['service_provider_id']['_id'] ?? ''
          : null,
      imageUrls: imageUrls,
      userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
      categoryId: categoryId,
      subcategoryIds: subcategoryIds,
      servicePayment: json['service_payment'],
      assignedWorker: assignedWorker,
      latitude: (json['latitude'] ?? 0).toDouble(), // Extract latitude
      longitude: (json['longitude'] ?? 0).toDouble(), // Extract longitude
    );
  }
}
/// BiddingOrder model
// class BiddingOrder {
//   final String id;
//   final String projectId;
//   final String title;
//   final String description;
//   final String address;
//   final double cost;
//   final String deadline;
//   final String hireStatus;
//   final String? serviceProviderId;
//   final List<String> imageUrls;
//   final UserId? userId;
//   final String categoryId;
//   final List<String> subcategoryIds;
//   final Map<String, dynamic>? servicePayment;
//   final AssignedWorker? assignedWorker;
//
//   BiddingOrder({
//     required this.id,
//     required this.projectId,
//     required this.title,
//     required this.description,
//     required this.address,
//     required this.cost,
//     required this.deadline,
//     required this.hireStatus,
//     this.serviceProviderId,
//     required this.imageUrls,
//     this.userId,
//     required this.categoryId,
//     required this.subcategoryIds,
//     this.servicePayment,
//     this.assignedWorker,
//   });
//
//   factory BiddingOrder.fromJson(Map<String, dynamic> json) {
//     // Handle image_url
//     List<String> imageUrls = [];
//     if (json['image_url'] != null) {
//       if (json['image_url'] is String) {
//         String cleanUrl =
//         json['image_url'].toString().replaceAll('//Uploads', '/Uploads');
//         imageUrls = [
//           cleanUrl.startsWith('http')
//               ? cleanUrl
//               : 'https://api.thebharatworks.com$cleanUrl'
//         ];
//       } else if (json['image_url'] is List<dynamic>) {
//         imageUrls = (json['image_url'] as List<dynamic>).map((url) {
//           String cleanUrl = url.toString().replaceAll('//Uploads', '/Uploads');
//           return cleanUrl.startsWith('http')
//               ? cleanUrl
//               : 'https://api.thebharatworks.com$cleanUrl';
//         }).toList();
//       }
//     }
//
//     // Handle category_id
//     String categoryId = '';
//     if (json['category_id'] != null) {
//       if (json['category_id'] is String) {
//         categoryId = json['category_id'];
//       } else if (json['category_id'] is Map) {
//         categoryId = json['category_id']['_id'] ?? '';
//       }
//     }
//
//     // Handle subcategory_ids
//     List<String> subcategoryIds = [];
//     if (json['sub_category_ids'] != null && json['sub_category_ids'] is List) {
//       subcategoryIds = (json['sub_category_ids'] as List<dynamic>)
//           .map((subcategory) {
//         if (subcategory is String) {
//           return subcategory;
//         } else if (subcategory is Map) {
//           return subcategory['_id']?.toString() ?? '';
//         }
//         return '';
//       })
//           .where((id) => id.isNotEmpty)
//           .toList();
//     }
//
//     // Handle assignedWorker
//     AssignedWorker? assignedWorker;
//     if (json['assignedWorker'] != null) {
//       assignedWorker = AssignedWorker.fromJson(json['assignedWorker']);
//     } else if (json['assigned_worker'] != null) {
//       assignedWorker = AssignedWorker.fromJson(json['assigned_worker']);
//     } else if (json['worker_id'] != null) {
//       assignedWorker = AssignedWorker.fromJson(json['worker_id'] is Map
//           ? json['worker_id']
//           : {'_id': json['worker_id']});
//     }
//
//     return BiddingOrder(
//       id: json['_id'] ?? '',
//       projectId: json['project_id'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       address: json['address'] ?? '',
//       cost: (json['cost'] ?? 0).toDouble(),
//       deadline: json['deadline'] ?? '',
//       hireStatus: json['hire_status'] ?? 'pending',
//     serviceProviderId: json['service_provider_id'] != null
//     ? json['service_provider_id'] is String
//     ? json['service_provider_id']
//         : json['service_provider_id']['_id'] ?? ''
//       : null,
//       imageUrls: imageUrls,
//       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
//       categoryId: categoryId,
//       subcategoryIds: subcategoryIds,
//       servicePayment: json['service_payment'],
//       assignedWorker: assignedWorker,
//     );
//   }
// }