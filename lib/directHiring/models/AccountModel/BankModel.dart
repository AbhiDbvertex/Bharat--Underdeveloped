class BankModel {
  final String accountNumber;
  final String bankName;
  final String ifscCode;
  final String upiId;
  final String accountHolderName;

  BankModel({
    required this.accountNumber,
    required this.bankName,
    required this.ifscCode,
    required this.upiId,
    required this.accountHolderName,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    try {
      return BankModel(
        accountNumber: json['accountNumber']?.toString() ?? '',
        bankName: json['bankName']?.toString() ?? '',
        ifscCode: json['ifscCode']?.toString() ?? '',
        upiId: json['upiId']?.toString() ?? '',
        accountHolderName: json['accountHolderName']?.toString() ?? '',
      );
    } catch (e) {
      print("❌ BankModel parsing error: $e\nRaw JSON: $json");
      return BankModel(
        accountNumber: '',
        bankName: '',
        ifscCode: '',
        upiId: '',
        accountHolderName: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'upiId': upiId,
      'accountHolderName': accountHolderName,
    };
  }
}
