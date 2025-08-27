// // // class UserId {
// // //   final String id;
// // //   final String fullName;
// // //   final String? profilePic;
// // //
// // //   UserId({
// // //     required this.id,
// // //     required this.fullName,
// // //     this.profilePic,
// // //   });
// // //
// // //   factory UserId.fromJson(Map<String, dynamic> json) {
// // //     return UserId(
// // //       id: json['_id'] ?? '',
// // //       fullName: json['full_name'] ?? 'Unknown',
// // //       profilePic: json['profile_pic'],
// // //     );
// // //   }
// // // }
// // //
// // // class BiddingOrder {
// // //   final String id;
// // //   final String projectId;
// // //   final String title;
// // //   final String description;
// // //   final String address;
// // //   final double cost;
// // //   final String deadline;
// // //   final String hireStatus;
// // //   final String? serviceProviderId;
// // //   final List<String> imageUrls;
// // //   final UserId? userId;
// // //
// // //   BiddingOrder({
// // //     required this.id,
// // //     required this.projectId,
// // //     required this.title,
// // //     required this.description,
// // //     required this.address,
// // //     required this.cost,
// // //     required this.deadline,
// // //     required this.hireStatus,
// // //     this.serviceProviderId,
// // //     required this.imageUrls,
// // //     this.userId,
// // //   });
// // //
// // //   factory BiddingOrder.fromJson(Map<String, dynamic> json) {
// // //     // Clean up the image_url by removing double slashes
// // //     String? imageUrl = json['image_url'] != null
// // //         ? json['image_url'].toString().replaceAll('//uploads', '/uploads')
// // //         : null;
// // //
// // //     return BiddingOrder(
// // //       id: json['_id'] ?? '',
// // //       projectId: json['project_id'] ?? '',
// // //       title: json['title'] ?? '',
// // //       description: json['description'] ?? '',
// // //       address: json['address'] ?? '',
// // //       cost: (json['cost'] ?? 0).toDouble(),
// // //       deadline: json['deadline'] ?? '',
// // //       hireStatus: json['hire_status'] ?? 'pending',
// // //       serviceProviderId: json['service_provider_id'] != null
// // //           ? json['service_provider_id'] is String
// // //               ? json['service_provider_id']
// // //               : json['service_provider_id']['_id'] ?? ''
// // //           : null,
// // //       imageUrls: imageUrl != null ? [imageUrl] : [],
// // //       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
// // //     );
// // //   }
// // // }
// //
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
// //     // Handle image_url as a list and clean up URLs
// //     final List<String> imageUrls =
// //         (json['image_url'] as List<dynamic>?)?.map((url) {
// //               String cleanUrl =
// //                   url.toString().replaceAll('//uploads', '/uploads');
// //               // Ensure the URL starts with the base URL if it doesn't have http
// //               return cleanUrl.startsWith('http')
// //                   ? cleanUrl
// //                   : 'https://api.thebharatworks.com$cleanUrl';
// //             }).toList() ??
// //             [];
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
// //       imageUrls: imageUrls,
// //       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
// //     );
// //   }
// // }
//
// import '../../Emergency/User/models/work_detail_model.dart';
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
//   final String categoryId;
//   final List<String> subcategoryIds;
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
//   });
//
//   factory BiddingOrder.fromJson(Map<String, dynamic> json) {
//     // Handle image_url as either a String or a List<dynamic>
//     List<String> imageUrls = [];
//     if (json['image_url'] != null) {
//       if (json['image_url'] is String) {
//         String cleanUrl =
//             json['image_url'].toString().replaceAll('//uploads', '/uploads');
//         imageUrls = [
//           cleanUrl.startsWith('http')
//               ? cleanUrl
//               : 'https://api.thebharatworks.com$cleanUrl'
//         ];
//       } else if (json['image_url'] is List<dynamic>) {
//         imageUrls = (json['image_url'] as List<dynamic>).map((url) {
//           String cleanUrl = url.toString().replaceAll('//uploads', '/uploads');
//           return cleanUrl.startsWith('http')
//               ? cleanUrl
//               : 'https://api.thebharatworks.com$cleanUrl';
//         }).toList();
//       }
//     }
//
//     // Handle category_id (string or object)
//     String categoryId = '';
//     if (json['category_id'] != null) {
//       if (json['category_id'] is String) {
//         categoryId = json['category_id'];
//       } else if (json['category_id'] is Map) {
//         categoryId = json['category_id']['_id'] ?? '';
//       }
//     }
//
//     // Handle subcategory_ids (list of strings or objects)
//     List<String> subcategoryIds = [];
//     if (json['sub_category_ids'] != null && json['sub_category_ids'] is List) {
//       subcategoryIds = (json['sub_category_ids'] as List<dynamic>)
//           .map((subcategory) {
//             if (subcategory is String) {
//               return subcategory;
//             } else if (subcategory is Map) {
//               return subcategory['_id']?.toString() ?? '';
//             }
//             return '';
//           })
//           .where((id) => id.isNotEmpty)
//           .toList();
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
//       serviceProviderId: json['service_provider_id'] != null
//           ? json['service_provider_id'] is String
//               ? json['service_provider_id']
//               : json['service_provider_id']['_id'] ?? ''
//           : null,
//       imageUrls: imageUrls,
//       userId: json['user_id'] != null ? UserId.fromJson(json['user_id']) : null,
//       categoryId: categoryId,
//       subcategoryIds: subcategoryIds,
//     );
//   }
// }
import '../../Emergency/Service_Provider/models/sp_work_detail_model.dart';

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
  final Map<String, dynamic>? servicePayment; // New field added

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
    this.servicePayment, // Added to constructor
  });

  factory BiddingOrder.fromJson(Map<String, dynamic> json) {
    // Handle image_url as either a String or a List<dynamic>
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

    // Handle category_id (string or object)
    String categoryId = '';
    if (json['category_id'] != null) {
      if (json['category_id'] is String) {
        categoryId = json['category_id'];
      } else if (json['category_id'] is Map) {
        categoryId = json['category_id']['_id'] ?? '';
      }
    }

    // Handle subcategory_ids (list of strings or objects)
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
      servicePayment: json['service_payment'], // Added service_payment
    );
  }
}
