// // lib/models/service_worker_model.dart
//
// class ServiceWorkerListModel {
//   final String name;
//   final String location;
//   final String image;
//   final String date;
//
//   ServiceWorkerListModel({
//     required this.name,
//     required this.location,
//     required this.image,
//     required this.date,
//   });
//
//   factory ServiceWorkerListModel.fromJson(Map<String, dynamic> json) {
//     final rawImage = json['image'] ?? '';
//
//     final fullImageUrl =
//         rawImage.startsWith('/uploads/worker/')
//             ? 'https://api.thebharatworks.com$rawImage'
//             : 'https://api.thebharatworks.com/uploads/worker/default.jpg';
//
//     return ServiceWorkerListModel(
//       name: json['name'] ?? '',
//       location: json['address'] ?? 'Unknown',
//       image: fullImageUrl,
//       date: json['dob']?.split("T")[0] ?? '',
//     );
//   }
// }

class ServiceWorkerListModel {
  final String id; // Add this
  final String name;
  final String location;
  final String image;
  final String date;

  ServiceWorkerListModel({
    required this.id, // Add this
    required this.name,
    required this.location,
    required this.image,
    required this.date,
  });

  factory ServiceWorkerListModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ?? '';
    final fullImageUrl =
    rawImage.isEmpty
        ? 'https://api.thebharatworks.com/uploads/worker/default.jpg'
        : rawImage.startsWith('http')
        ? rawImage.replaceFirst('http://', 'https://')
        : 'https://api.thebharatworks.com$rawImage';

    return ServiceWorkerListModel(
      id: json['_id'] ?? '', // Add this
      name: json['name'] ?? '',
      location: json['address'] ?? 'Unknown',
      image: fullImageUrl,
      date: json['dob']?.split("T")[0] ?? '',
    );
  }
}