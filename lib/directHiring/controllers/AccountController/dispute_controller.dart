import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/dispute_model.dart';

class DisputeController extends GetxController{
  RxList<DisputeModel> disputeList  = <DisputeModel>[].obs;
  RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    getDisputes();
    super.onInit();
  }
  Future<void> getDisputes() async {
    await getDisputeData();
    //disputeList.value = disputes;
  }
  Future<void> getDisputeData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.get(
      Uri.parse('https://api.thebharatworks.com/api/dispute/getAllDisputes'),
      headers: {'Authorization': 'Bearer $token'},

    );
    print('dss $token');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if(data['success']){
        print('geee');
        data['disputes'].map((e) => disputeList.add(DisputeModel.fromJson(e))).toList();
        print(disputeList.length);
      }
    }
  }
}