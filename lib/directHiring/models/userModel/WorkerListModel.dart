class WorkerListModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String image;
  final String verifyStatus;
  final String createdAt;

  WorkerListModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.image,
    required this.verifyStatus,
    required this.createdAt,
  });

  factory WorkerListModel.fromJson(Map<String, dynamic> json) {
    return WorkerListModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      image: json['image'] ?? '',
      verifyStatus: json['verifyStatus'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $name, phone: $phone, status: $verifyStatus)';
  }
}
