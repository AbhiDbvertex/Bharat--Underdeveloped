class EmergencyCreateOrderModel {
  final bool? status;
  final String? message;
  final RazorpayOrder? razorpayOrder;
  final EmergencyOrder? order;

  EmergencyCreateOrderModel({
    this.status,
    this.message,
    this.razorpayOrder,
    this.order,
  });

  factory EmergencyCreateOrderModel.fromJson(Map<String, dynamic> json) {
    return EmergencyCreateOrderModel(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      razorpayOrder: json['razorpay_order'] != null
          ? RazorpayOrder.fromJson(json['razorpay_order'] as Map<String, dynamic>)
          : null,
      order: json['order'] != null
          ? EmergencyOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'razorpay_order': razorpayOrder?.toJson(),
    'order': order?.toJson(),
  };
}

class RazorpayOrder {
  final int? amount;
  final int? amountDue;
  final int? amountPaid;
  final int? attempts;
  final int? createdAt; // epoch seconds
  final String? currency;
  final String? entity;
  final String? id;
  final List<dynamic>? notes;
  final String? offerId;
  final String? receipt;
  final String? status;

  RazorpayOrder({
    this.amount,
    this.amountDue,
    this.amountPaid,
    this.attempts,
    this.createdAt,
    this.currency,
    this.entity,
    this.id,
    this.notes,
    this.offerId,
    this.receipt,
    this.status,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) => RazorpayOrder(
    amount: json['amount'] as int?,
    amountDue: json['amount_due'] as int?,
    amountPaid: json['amount_paid'] as int?,
    attempts: json['attempts'] as int?,
    createdAt: json['created_at'] as int?,
    currency: json['currency'] as String?,
    entity: json['entity'] as String?,
    id: json['id'] as String?,
    notes: (json['notes'] as List?)?.toList(),
    offerId: json['offer_id']?.toString(),
    receipt: json['receipt'] as String?,
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'amount_due': amountDue,
    'amount_paid': amountPaid,
    'attempts': attempts,
    'created_at': createdAt,
    'currency': currency,
    'entity': entity,
    'id': id,
    'notes': notes,
    'offer_id': offerId,
    'receipt': receipt,
    'status': status,
  };
}

class EmergencyOrder {
  final String? userId;
  final String? projectId;
  final String? categoryId;
  final List<String>? subCategoryIds;
  final String? googleAddress;
  final String? detailedAddress;
  final String? contact;
  final DateTime? deadline;
  final List<String>? imageUrls;
  final String? hireStatus;
  final String? userStatus;
  final String? paymentStatus;
  final String? serviceProviderId;
  final bool? platformFeePaid;
  final num? platformFee;
  final String? razorOrderIdPlatform;
  final ServicePayment? servicePayment;
  final Commission? commission;
  final String? id;
  final List<dynamic>? acceptedByProviders;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  EmergencyOrder({
    this.userId,
    this.projectId,
    this.categoryId,
    this.subCategoryIds,
    this.googleAddress,
    this.detailedAddress,
    this.contact,
    this.deadline,
    this.imageUrls,
    this.hireStatus,
    this.userStatus,
    this.paymentStatus,
    this.serviceProviderId,
    this.platformFeePaid,
    this.platformFee,
    this.razorOrderIdPlatform,
    this.servicePayment,
    this.commission,
    this.id,
    this.acceptedByProviders,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory EmergencyOrder.fromJson(Map<String, dynamic> json) => EmergencyOrder(
    userId: json['user_id'] as String?,
    projectId: json['project_id'] as String?,
    categoryId: json['category_id'] as String?,
    subCategoryIds: (json['sub_category_ids'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    googleAddress: json['google_address'] as String?,
    detailedAddress: json['detailed_address'] as String?,
    contact: json['contact'] as String?,
    deadline: json['deadline'] != null
        ? DateTime.tryParse(json['deadline'].toString())
        : null,
    imageUrls: (json['image_urls'] as List?)
        ?.map((e) => e.toString())
        .toList(),
    hireStatus: json['hire_status']?.toString(),
    userStatus: json['user_status']?.toString(),
    paymentStatus: json['payment_status']?.toString(),
    serviceProviderId: json['service_provider_id']?.toString(),
    platformFeePaid: json['platform_fee_paid'] as bool?,
    platformFee: json['platform_fee'] as num?,
    razorOrderIdPlatform: json['razorOrderIdPlatform']?.toString(),
    servicePayment: json['service_payment'] != null
        ? ServicePayment.fromJson(json['service_payment'])
        : null,
    commission: json['commission'] != null
        ? Commission.fromJson(json['commission'])
        : null,
    id: json['_id'],
    acceptedByProviders: json['accepted_by_providers'] != null
        ? List<dynamic>.from(json['accepted_by_providers'])
        : [],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    v: json['__v'],
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'project_id': projectId,
    'category_id': categoryId,
    'sub_category_ids': subCategoryIds,
    'google_address': googleAddress,
    'detailed_address': detailedAddress,
    'contact': contact,
    'deadline': deadline?.toIso8601String(),
    'image_urls': imageUrls,
    'hire_status': hireStatus,
    'user_status': userStatus,
    'payment_status': paymentStatus,
    'service_provider_id': serviceProviderId,
    'platform_fee_paid': platformFeePaid,
    'platform_fee': platformFee,
    'razorOrderIdPlatform': razorOrderIdPlatform,
    "service_payment": servicePayment?.toJson(),
    "commission": commission?.toJson(),
    "_id": id,
    "accepted_by_providers": acceptedByProviders,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}
class ServicePayment {
  final int? amount;
  final int? totalExpected;
  final int? remainingAmount;
  final int? totalTax;
  final List<dynamic>? paymentHistory;

  ServicePayment({
    this.amount,
    this.totalExpected,
    this.remainingAmount,
    this.totalTax,
    this.paymentHistory,
  });

  factory ServicePayment.fromJson(Map<String, dynamic> json) {
    return ServicePayment(
      amount: json['amount'],
      totalExpected: json['total_expected'],
      remainingAmount: json['remaining_amount'],
      totalTax: json['total_tax'],
      paymentHistory: json['payment_history'] != null
          ? List<dynamic>.from(json['payment_history'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "total_expected": totalExpected,
      "remaining_amount": remainingAmount,
      "total_tax": totalTax,
      "payment_history": paymentHistory,
    };
  }
}
class Commission {
  final int? amount;
  final int? percentage;
  final String? type;
  final bool ? isCollected;

  Commission({
    this.amount,
    this.percentage,
    this.type,
    this.isCollected,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      amount: json['amount'],
      percentage: json['percentage'],
      type: json['remaining_amount'],
      isCollected: json['total_tax'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "percentage": percentage,
      "type": type,
      "is_collected": isCollected,
    };
  }
}