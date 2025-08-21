// // class UserId {
// //   final String id;
// //   final String fullName;
// //   final String? profilePic;
// //
// //   UserId({
// //     required this.id,
// //     required this.fullName,
// //     this.profilePic,
// //   });
// //
// //   factory UserId.fromJson(Map<String, dynamic> json) {
// //     return UserId(
// //       id: json['_id'] ?? '',
// //       fullName: json['full_name'] ?? 'Unknown',
// //       profilePic: json['profile_pic'],
// //     );
// //   }
// // }
// //
// // class BiddingOrder {
// //   final String id;
// //   final String projectId;
// //   final String title;
// //   final String description;
// //   final String address;
// //   final double cost;
// //   final String deadline;
// //   final String hireStatus;
// //   final String? serviceProviderId;
// //   final List<String> imageUrls;
// //   final UserId? userId;
// //
// //   BiddingOrder({
// //     required this.id,
// //     required this.projectId,
// //     required this.title,
// //     required this.description,
// //     required this.address,
// //     required this.cost,
// //     required this.deadline,
// //     required this.hireStatus,
// //     this.serviceProviderId,
// //     required this.imageUrls,
// //     this.userId,
// //   });
// //
// //   factory BiddingOrder.fromJson(Map<String, dynamic> json) {
// //     // Clean up the image_url by removing double slashes
// //     String? imageUrl = json['image_url'] != null
// //         ? json['image_url'].toString().replaceAll('//uploads', '/uploads')
// //         : null;
// //
// //     return BiddingOrder(
// //       id: json['_id'] ?? '',
// //       projectId: json['project_id'] ?? '',
// //       title: json['title'] ?? '',
// //       description: json['description'] ?? '',
// //       address: json['address'] ?? '',
// //       cost: (json['cost'] ?? 0).toDouble(),
// //       deadline: json['deadline'] ?? '',
// //       hireStatus: json['hire_status'] ?? 'pending',
// //       serviceProviderId: json['service_provider_id'] != null
// //           ? json['service_provider_id'] is String
// //               ? json['service_provider_id']
// //               : json['service_provider_id']['_id'] ?? ''
// //           : null,
// //       imageUrls: imageUrl != null ? [imageUrl] : [],
// //       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
// //     );
// //   }
// // }
//
// class UserId {
//   final String id;
//   final String fullName;
//   final String? profilePic;
//
//   UserId({
//     required this.id,
//     required this.fullName,
//     this.profilePic,
//   });
//
//   factory UserId.fromJson(Map<String, dynamic> json) {
//     return UserId(
//       id: json['_id'] ?? '',
//       fullName: json['full_name'] ?? 'Unknown',
//       profilePic: json['profile_pic'],
//     );
//   }
// }
//
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
//   });
//
//   factory BiddingOrder.fromJson(Map<String, dynamic> json) {
//     // Handle image_url as a list and clean up URLs
//     final List<String> imageUrls =
//         (json['image_url'] as List<dynamic>?)?.map((url) {
//               String cleanUrl =
//                   url.toString().replaceAll('//uploads', '/uploads');
//               // Ensure the URL starts with the base URL if it doesn't have http
//               return cleanUrl.startsWith('http')
//                   ? cleanUrl
//                   : 'https://api.thebharatworks.com$cleanUrl';
//             }).toList() ??
//             [];
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
//       serviceProviderId: json['service_provider_id'] != null
//           ? json['service_provider_id'] is String
//               ? json['service_provider_id']
//               : json['service_provider_id']['_id'] ?? ''
//           : null,
//       imageUrls: imageUrls,
//       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
//     );
//   }
// }

class UserId {
  final String id;
  final String fullName;
  final String? profilePic;

  UserId({
    required this.id,
    required this.fullName,
    this.profilePic,
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      profilePic: json['profile_pic'],
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
  });

  factory BiddingOrder.fromJson(Map<String, dynamic> json) {
    // Handle image_url as either a String or a List<dynamic>
    List<String> imageUrls = [];
    if (json['image_url'] != null) {
      if (json['image_url'] is String) {
        // If image_url is a single string
        String cleanUrl =
            json['image_url'].toString().replaceAll('//uploads', '/uploads');
        imageUrls = [
          cleanUrl.startsWith('http')
              ? cleanUrl
              : 'https://api.thebharatworks.com$cleanUrl'
        ];
      } else if (json['image_url'] is List<dynamic>) {
        // If image_url is a list
        imageUrls = (json['image_url'] as List<dynamic>).map((url) {
          String cleanUrl = url.toString().replaceAll('//uploads', '/uploads');
          return cleanUrl.startsWith('http')
              ? cleanUrl
              : 'https://api.thebharatworks.com$cleanUrl';
        }).toList();
      }
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
    );
  }
}
