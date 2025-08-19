class RequestAcceptedModel {
  final String id;
  final String name;
  final double amount;
  final String location;
  final String imageUrl;
  final String status;

  RequestAcceptedModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.location,
    required this.imageUrl,
    required this.status,
  });

  // JSON → Model
  factory RequestAcceptedModel.fromJson(Map<String, dynamic> json) {
    return RequestAcceptedModel(
      id: json["id"].toString(),
      name: json["name"] ?? "",
      amount: double.tryParse(json["amount"].toString()) ?? 0,
      location: json["location"] ?? "",
      imageUrl: json["imageUrl"] ?? "",
      status: json["status"] ?? "",
    );
  }
}
