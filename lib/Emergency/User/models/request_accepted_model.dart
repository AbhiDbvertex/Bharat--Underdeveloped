class RequestAcceptedModel {
  final bool status;
  final String message;
  final int count;
  final List<ServiceProvider> providers;

  RequestAcceptedModel({
    required this.status,
    required this.message,
    required this.count,
    required this.providers,
  });

  factory RequestAcceptedModel.fromJson(Map<String, dynamic> json) {
    return RequestAcceptedModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      providers: (json['providers'] as List<dynamic>)
          .map((e) => ServiceProvider.fromJson(e))
          .toList(),
    );
  }
}

class ServiceProvider {
  final String providersId;
  final String phone;
  final String fullName;
  final String profilePic;
  final int totalReview;
  final double rating;
  final String id;

  // 👇 extra fields
  final double amount;
  final String location;
  final String view;

  ServiceProvider({
    required this.providersId,
    required this.phone,
    required this.fullName,
    required this.profilePic,
    required this.totalReview,
    required this.rating,
    required this.amount,
    required this.location,
    required this.view,
    required this.id,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      providersId: json['_id'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'] ?? '',
      totalReview: json['totalReview'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),

      // 👇 extra fields (agar backend se nahi aa rahe toh dummy assign kar le)
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      location: json['location'] ?? '',
      view: json['view'] ?? '',
      id: json['id'] ?? '',
    );
  }
}
class AssignOrderResponse {
  final bool status;
  final String message;
  final AssignOrderData? data;

  AssignOrderResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AssignOrderResponse.fromJson(Map<String, dynamic> json) {
    return AssignOrderResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AssignOrderData.fromJson(json['data']) : null,
    );
  }
}

class AssignOrderData {
  final String orderId;
  final String assignedTo;

  AssignOrderData({
    required this.orderId,
    required this.assignedTo,
  });

  factory AssignOrderData.fromJson(Map<String, dynamic> json) {
    return AssignOrderData(
      orderId: json['order_id'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
    );
  }
}
