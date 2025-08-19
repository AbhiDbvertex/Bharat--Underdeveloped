import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../models/AccountModel/ReferralModel.dart';

class ReferralController {
  final String referralCode = "568500";

  List<ReferralModel> getReferralList() {
    return [
       ReferralModel(name: "Ram Sharma", date: "05/15/25", amount: "Rs. 200/-"),
      ReferralModel(name: "Sita Verma", date: "05/16/25", amount: "Rs. 250/-"),
      ReferralModel(name: "Amit Singh", date: "05/17/25", amount: "Rs. 300/-"),
      ReferralModel(name: "Geeta Yadav", date: "05/18/25", amount: "Rs. 150/-"),
      ReferralModel(name: "Ravi Kumar", date: "05/19/25", amount: "Rs. 100/-"),
    ];
  }

  void copyReferralCode(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: "568500"));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Code copied!")),
    );
  }
}
