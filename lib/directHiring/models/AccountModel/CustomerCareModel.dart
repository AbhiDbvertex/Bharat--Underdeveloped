class CustomerCareModel {
  String? selectedSubject;
  String contactDetail = '';
  String description = '';
  bool isEmailSelected = true;

  final List<String> subjects = ['Technical Issue', 'General Inquiry', 'Feedback'];

  void reset() {
    selectedSubject = null;
    contactDetail = '';
    description = '';
    isEmailSelected = true;
  }
}
