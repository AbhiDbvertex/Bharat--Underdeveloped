class DisputeModel {
  final String id;
  final OrderInfo order;
  final String flowType;
  final UserModel raisedBy;
  final UserModel against;
  final int amount;
  final String description;
  final String requirement;
  final String image;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String uniqueId;

  DisputeModel({
    required this.id,
    required this.order,
    required this.flowType,
    required this.raisedBy,
    required this.against,
    required this.amount,
    required this.description,
    required this.requirement,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.uniqueId,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json["_id"] ?? "",
      order: OrderInfo.fromJson(json["order_id"] ?? {}),
      flowType: json["flow_type"] ?? "",
      raisedBy: UserModel.fromJson(json["raised_by"] ?? {}),
      against: UserModel.fromJson(json["against"] ?? {}),
      amount: json["amount"] ?? 0,
      description: json["description"] ?? "",
      requirement: json["requirement"] ?? "",
      image: json["image"] ?? "",
      status: json["status"] ?? "",
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      v: json["__v"] ?? 0,
      uniqueId: json["unique_id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "order_id": order.toJson(),
      "flow_type": flowType,
      "raised_by": raisedBy.toJson(),
      "against": against.toJson(),
      "amount": amount,
      "description": description,
      "requirement": requirement,
      "image": image,
      "status": status,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
      "unique_id": uniqueId,
    };
  }
}

class OrderInfo {
  final String id;
  final String projectId;
  final String title;
  final String description;

  OrderInfo({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: json["_id"] ?? "",
      projectId: json["project_id"] ?? "",
      title: json["title"] ?? "",
      description: json["description"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "project_id": projectId,
      "title": title,
      "description": description,
    };
  }
}

class UserModel {
  final String id;
  final String phone;
  final String fullName;
  final String profilePic;
  final String uniqueId;
  final int totalReview;
  final int rating;

  UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.profilePic,
    required this.uniqueId,
    required this.totalReview,
    required this.rating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? "",
      phone: json["phone"] ?? "",
      fullName: json["full_name"] ?? "",
      profilePic: json["profile_pic"] ?? "",
      uniqueId: json["unique_id"] ?? "",
      totalReview: json["totalReview"] ?? 0,
      rating: json["rating"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "phone": phone,
      "full_name": fullName,
      "profile_pic": profilePic,
      "unique_id": uniqueId,
      "totalReview": totalReview,
      "rating": rating,
    };
  }
}
