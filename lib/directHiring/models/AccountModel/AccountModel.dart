class AccountModel {
  final String phone;
  final String full_name;
  final String? profilePic;
  final String role; // ✅ ADD THIS

  AccountModel({
    required this.phone,
    required this.full_name,
    this.profilePic,
    required this.role, // ✅ ADD THIS
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      phone: json['phone'] ?? '',
      full_name: json['full_name'] ?? '',
      profilePic: json['profilePic'],
      role: json['role'] ?? '', // ✅ ADD THIS
    );
  }

  String get name => full_name;
  String get imageUrl => profilePic ?? '';
}
