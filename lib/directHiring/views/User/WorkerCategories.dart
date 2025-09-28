import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Widgets/AppColors.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import 'SubCategories.dart';

class WorkerCategories extends StatefulWidget {
  const WorkerCategories({Key? key}) : super(key: key);

  @override
  State<WorkerCategories> createState() => _WorkerCategoriesState();
}

class _WorkerCategoriesState extends State<WorkerCategories> {
  List<dynamic> allCategories = [];
  int? selectedIndex;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print("❌ Token missing");
        setState(() => isLoading = false);
        return;
      }

      final uri = Uri.parse(
        '${AppConstants.baseUrl}${ApiEndpoint.workerCategories}',
      );
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print(
        "Fetching categories: Status ${response.statusCode}, Response: ${response.body}",
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true && jsonData["data"] is List) {
          setState(() {
            allCategories = jsonData["data"];
            isLoading = false;
          });
        } else {
          print("❌ Invalid response data");
          setState(() => isLoading = false);
        }
      } else {
        print(
          "❌ Error fetching categories: Status Code ${response.statusCode}",
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❗ Exception fetching categories: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar:AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Work Categories",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.8,
                        children: List.generate(allCategories.length, (index) {

                          final category =
                              allCategories[index] as Map<String, dynamic>;
                          final imagePath = category['image']?.toString() ?? '';

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: SizedBox(
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedIndex == index
                                              ? Colors.green
                                              : Colors.green.shade100,
                                      shape: BoxShape.circle,
                                      border:
                                          selectedIndex == index
                                              ? Border.all(
                                                color: Colors.black,
                                                width: 1,
                                              )
                                              : null,
                                    ),
                                    child: Center(
                                      child: ClipOval(
                                        child:
                                            imagePath.isNotEmpty

                                                ? Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: Image.network(
                                                    imagePath.startsWith('http')
                                                        ? imagePath
                                                        : '${AppConstants.baseUrl}$imagePath',
                                                    height: 42,
                                                    width: 42,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress == null)
                                                        return child;
                                                      return Container(
                                                        height: 42,
                                                        width: 42,
                                                        color:
                                                            Colors.grey.shade100,
                                                        child: const Icon(
                                                          Icons.image_outlined,
                                                          size: 22,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      print(
                                                        "Image load failed in WorkerCategories: $imagePath, Error: $error",
                                                      );
                                                      return Container(
                                                        height: 42,
                                                        width: 42,
                                                        color:
                                                            Colors.grey.shade100,
                                                        child: const Icon(
                                                          Icons.image_outlined,
                                                          size: 22,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                                : Container(
                                                  height: 42,
                                                  width: 42,
                                                  color: Colors.grey.shade100,
                                                  child: const Icon(
                                                    Icons.image_outlined,
                                                    size: 22,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['name']?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedIndex != null) {
                                  final selected =
                                      allCategories[selectedIndex!]
                                          as Map<String, dynamic>;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SubCategories(
                                            categoryId:
                                                selected['_id'].toString(),
                                            categoryName:
                                                selected['name']?.toString() ??
                                                '',
                                          ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please select a category first.",
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.green.shade700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
