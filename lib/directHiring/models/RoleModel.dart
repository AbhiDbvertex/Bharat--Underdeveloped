class RoleModel {
  String selectedRole = '';
  String role = '';
  String name = '';
  String landmark = '';
  String location = '';
  String currentLocation = ''; // keep only one version
  String fullAddress = '';
  String colonyName = '';
  String galiNumber = '';
  String referral = '';

  Map<String, String?> errorTexts = {};

  void clear() {
    selectedRole = '';
    role = '';
    name = '';
    landmark = '';
    location = '';
    currentLocation = '';
    fullAddress = '';
    colonyName = '';
    galiNumber = '';
    referral = '';
    errorTexts.clear();
  }
}
