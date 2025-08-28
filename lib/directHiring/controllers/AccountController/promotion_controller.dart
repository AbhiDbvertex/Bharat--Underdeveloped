import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PromotionController extends GetxController {
  RxList<File> selectedImages = <File>[].obs;
  RxBool isPromoting = false.obs;

  Future<bool> submitForm(Map<String, dynamic> promotionForm) async {
    print("dss :- ${promotionForm['description']}");
    print("dss :- ${promotionForm['whyPromote']}");
    print("dss :- ${promotionForm['images']}");
    final uri = Uri.parse('https://api.thebharatworks.com/api/promotion/create');
    try {
      final request = http.MultipartRequest('POST', uri);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      //Optional headers (e.g., auth). DON'T set Content-Type; http sets it.

        request.headers['Authorization'] = 'Bearer $token';


      // Text fields
      request.fields['description'] = promotionForm['description'];
      request.fields['title'] = promotionForm['whyPromote'];

      // Files
      for (final file in promotionForm['images']) {
        request.files.add(
          await http.MultipartFile.fromPath("images", file.path),
        );
      }

      // Send
      final rawResponse = await request.send();
      print(rawResponse.toString());
      if (rawResponse.statusCode == 201) {
        // Convert StreamedResponse → normal Response
        var response = await http.Response.fromStream(rawResponse);

        // Decode JSON
        final decodedData = jsonDecode(response.body);
        if(decodedData['success'] == true){
          print('dss :- Request Sent successfully ${decodedData['message']}');
          return decodedData['success'];
        }
      } else {
        return false;
      }
      return false;
    } catch (e) {
      print('Somthing went wrong whle sending promotion from ${e.toString}');
      return false;
    }
  }
}
