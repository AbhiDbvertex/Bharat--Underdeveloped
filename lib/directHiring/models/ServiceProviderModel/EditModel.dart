class EditWorkerModel {
  String name;
  String phone;
  String aadhaar;
  String dob;
  String address;

  EditWorkerModel({
    required this.name,
    required this.phone,
    required this.aadhaar,
    required this.dob,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'aadhaar': aadhaar,
      'dob': dob,
      'address': address,
    };
  }

  factory EditWorkerModel.fromJson(Map<String, dynamic> json) {
    return EditWorkerModel(
      name: json['name'],
      phone: json['phone'],
      aadhaar: json['aadhaar'],
      dob: json['dob'],
      address: json['address'],
    );
  }
}
