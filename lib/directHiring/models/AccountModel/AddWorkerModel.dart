class AddWorkerModel {
  final String name;
  final String phone;
  final String aadhaarNumber;
  final String dob;
  final String address;
  final String? imagePath;

  AddWorkerModel({
    required this.name,
    required this.phone,
    required this.aadhaarNumber,
    required this.dob,
    required this.address,
    this.imagePath,
  });
}
