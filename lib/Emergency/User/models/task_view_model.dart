class TaskModel {
  WorkerDetails workerDetails;
  AssignedPerson assignedPerson;
  List<Payment> payments;
  WarningMessage? warningMessage;

  TaskModel({
    required this.workerDetails,
    required this.assignedPerson,
    required this.payments,
    this.warningMessage,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      workerDetails: WorkerDetails.fromJson(json['workerDetails']),
      assignedPerson: AssignedPerson.fromJson(json['assignedPerson']),
      payments: (json['payments'] as List)
          .map((item) => Payment.fromJson(item))
          .toList(),
      warningMessage: json['warningMessage'] != null
          ? WarningMessage.fromJson(json['warningMessage'])
          : null,
    );
  }
}

class WorkerDetails {
  String name;
  String imageUrl;
  String emergencyFees;

  WorkerDetails({
    required this.name,
    required this.imageUrl,
    required this.emergencyFees,
  });

  factory WorkerDetails.fromJson(Map<String, dynamic> json) {
    return WorkerDetails(
      name: json['name'],
      imageUrl: json['imageUrl'],
      emergencyFees: json['emergencyFees'],
    );
  }
}

class AssignedPerson {
  String name;
  String imageUrl;
  String subCategory;

  AssignedPerson({
    required this.name,
    required this.imageUrl,
    required this.subCategory,
  });

  factory AssignedPerson.fromJson(Map<String, dynamic> json) {
    return AssignedPerson(
      name: json['name'],
      imageUrl: json['imageUrl'],
      subCategory: json['subCategory'],
    );
  }
}

class Payment {
  String name;
  String amount;
  bool isPaid;

  Payment({
    required this.name,
    required this.amount,
    required this.isPaid,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      name: json['name'],
      amount: json['amount'],
      isPaid: json['isPaid'],
    );
  }
}

class WarningMessage {
  String message;

  WarningMessage({required this.message});

  factory WarningMessage.fromJson(Map<String, dynamic> json) {
    return WarningMessage(
      message: json['message'],
    );
  }
}