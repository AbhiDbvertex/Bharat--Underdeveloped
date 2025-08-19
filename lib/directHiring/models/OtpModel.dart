class OtpModel {
  final String phoneNumber;
  List<String> otpDigits;
  String actualOtpCode = ''; // 👈 Used for testing OTP UI (backend OTP)

  OtpModel({required this.phoneNumber}) : otpDigits = List.generate(4, (_) => '');

  bool get isComplete => otpDigits.every((d) => d.isNotEmpty);

  String get otpCode => otpDigits.join();
}
