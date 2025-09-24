// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Consent/ApiEndpoint.dart';
// import '../../Consent/app_constants.dart';
// import '../../models/userModel/subCategoriesModel.dart';
// import 'WorkerListScreen.dart';
//
// class SubCategories extends StatefulWidget {
//   final String categoryId;
//   final String categoryName;
//
//   const SubCategories({
//     Key? key,
//     required this.categoryId,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   State<SubCategories> createState() => _SubCategoriesState();
// }
//
// class _SubCategoriesState extends State<SubCategories> {
//   List<dynamic> allSubCategories = [];
//   Set<int> selectedIndexes = {};
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchSubCategories();
//   }
//
//   String getFullImageUrl(String path) {
//     if (path.startsWith("http")) return path;
//     return "${AppConstants.baseUrl}$path";
//   }
//
//   Future<void> fetchSubCategories() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       if (token == null) {
//         setState(() => isLoading = false);
//         return;
//       }
//
//       final uri = Uri.parse(
//         '${AppConstants.baseUrl}/subcategories/${widget.categoryId}',
//       );
//
//       final response = await http.get(
//         uri,
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData["status"] == true && jsonData["data"] is List) {
//           setState(() {
//             allSubCategories = jsonData["data"];
//             isLoading = false;
//           });
//         } else {
//           setState(() => isLoading = false);
//         }
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> fetchServiceProviders(
//     String categoryId,
//     String subCategoryId,
//     String subCategoryName,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//
//     if (token == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please login first")));
//       return;
//     }
//
//     final uri = Uri.parse(
//       '${AppConstants.baseUrl}${ApiEndpoint.SubCategories}',
//     );
//
//     try {
//       final body = {"category_id": categoryId, "subcategory_ids": [subCategoryId]};
//
//       final response = await http.post(
//         uri,
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: json.encode(body),
//       );
//       print("dfcdf:- ${response.body}");
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data["status"] == true && data["data"] != null) {
//           List<ServiceProviderModel> providers =
//               (data["data"] as List)
//                   .map((json) => ServiceProviderModel.fromJson(json))
//                   .toList();
//
//
//           Get.to(WorkerlistScreen(providers: providers, categreyId: categoryId, subcategreyId: subCategoryId,),);
//
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder:
//           //         (_) => WorkerlistScreen(
//           //           providers: providers,
//           //           categreyId: categoryId,
//           //           subcategreyId: subCategoryId,
//           //         ),
//           //   ),
//           // );
//         } else {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("No providers found.")));
//         }
//       } else {
//         final err = json.decode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error ${response.statusCode}: ${err['message']}"),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }
//
//   Widget categoryItemWidget(Map<String, dynamic> category, bool isSelected) {
//     final rawImagePath = category['image'] ?? '';
//     final imagePath =
//         rawImagePath.isNotEmpty ? getFullImageUrl(rawImagePath) : '';
//
//     return SizedBox(
//       height: 100,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             height: 42,
//             width: 42,
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.green : Colors.green.shade100,
//               shape: BoxShape.circle,
//               border:
//                   isSelected
//                       ? Border.all(color: Colors.green.shade700, width: 2.5)
//                       : null,
//             ),
//             child: Center(
//               child: ClipOval(
//                 child:
//                     imagePath.isNotEmpty
//
//                         ? Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Image.network(
//                             imagePath,
//                             height: 42,
//                             width: 42,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Icon(Icons.broken_image, size: 22);
//                             },
//                           ),
//
//                         )
//                         : const Icon(Icons.image, size: 22),
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             category['name'] ?? '',
//             textAlign: TextAlign.center,
//             style: GoogleFonts.roboto(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade800,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 10,
//       ),
//       backgroundColor: Colors.white,
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: const Padding(
//                           padding: EdgeInsets.only(left: 18.0),
//                           child: Icon(Icons.arrow_back_outlined, size: 22),
//                         ),
//                       ),
//                       const SizedBox(width: 70),
//                       Text(
//                         "Sub Categories",
//                         style: GoogleFonts.roboto(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child:
//                           allSubCategories.isNotEmpty
//                               ? GridView.count(
//                                 crossAxisCount: 5,
//                                 mainAxisSpacing: 10,
//                                 crossAxisSpacing: 8,
//                                 childAspectRatio: 0.8,
//                                 children: List.generate(
//                                   allSubCategories.length,
//                                   (index) {
//                                     final category =
//                                         allSubCategories[index]
//                                             as Map<String, dynamic>;
//                                     return GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           if (selectedIndexes.contains(index)) {
//                                             selectedIndexes.remove(index);
//                                           } else {
//                                             selectedIndexes.add(index);
//                                           }
//                                         });
//                                       },
//                                       child: categoryItemWidget(
//                                         category,
//                                         selectedIndexes.contains(index),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               )
//                               : Center(
//                                 child: Text(
//                                   "No subcategories found.",
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 14,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                     ),
//                   ),
//                   SafeArea(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed:
//                                   selectedIndexes.isNotEmpty
//                                       ? () {
//                                         for (var index in selectedIndexes) {
//                                           final selectedSubCategory =
//                                               allSubCategories[index];
//                                           fetchServiceProviders(
//                                             widget.categoryId,
//                                             selectedSubCategory['_id'],
//                                             selectedSubCategory['name'],
//                                           );
//                                         }
//                                       }
//                                       : null,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green.shade700,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               child: Text(
//                                 "Submit",
//                                 style: GoogleFonts.roboto(
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: () => Navigator.pop(context),
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: Colors.black,
//                                 side: BorderSide(color: Colors.green.shade700),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               child: Text(
//                                 "Cancel",
//                                 style: GoogleFonts.roboto(
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.green.shade700,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//     );
//   }
// }

import 'dart:convert';

import 'package:developer/Emergency/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Widgets/AppColors.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../models/userModel/subCategoriesModel.dart';
import 'WorkerListScreen.dart';

class SubCategories extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubCategories({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<SubCategories> createState() => _SubCategoriesState();
}

class _SubCategoriesState extends State<SubCategories> {
  List<dynamic> allSubCategories = [];
  Set<int> selectedIndexes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubCategories();
  }

  String getFullImageUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${AppConstants.baseUrl}$path";
  }

  Future<void> fetchSubCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      final uri = Uri.parse(
        '${AppConstants.baseUrl}/subcategories/${widget.categoryId}',
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true && jsonData["data"] is List) {
          setState(() {
            allSubCategories = jsonData["data"];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchServiceProviders(
      String categoryId,
      List<String> subCategoryIds,
      String subCategoryName, // Keep for WorkerlistScreen, using first selected name
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
       CustomSnackBar.show(
          context,
          message: "Please login first",
          type: SnackBarType.error
      );

      return;
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoint.SubCategories}',
    );

    try {
      final body = {
        "category_id": categoryId,
        "subcategory_ids": subCategoryIds, // Send all selected IDs
      };
      print("Abhi:- print selected all subcategories : $subCategoryIds");

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );
      print("dfcdf:- ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == true && data["data"] != null) {
          List<ServiceProviderModel> providers = (data["data"] as List)
              .map((json) => ServiceProviderModel.fromJson(json))
              .toList();

          Get.to(
            WorkerlistScreen(
              providers: providers,
              categreyId: categoryId,
              subcategreyId: subCategoryIds.join(','), // Join IDs for WorkerlistScreen
            ),
          );
        } else {

          CustomSnackBar.show(
              context,
              message:"No providers found." ,
              type: SnackBarType.error
          );

        }
      } else {
        final err = json.decode(response.body);

        CustomSnackBar.show(
            context,
            message: "Error ${response.statusCode}: ${err['message']}",
            type: SnackBarType.error
        );

      }
    } catch (e) {

      CustomSnackBar.show(
          context,
          message:"Something went wrong",
          type: SnackBarType.error
      );

    }
  }

  Widget categoryItemWidget(Map<String, dynamic> category, bool isSelected) {
    final rawImagePath = category['image'] ?? '';
    final imagePath = rawImagePath.isNotEmpty ? getFullImageUrl(rawImagePath) : '';

    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.green.shade100,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.green.shade700, width: 2.5)
                  : null,
            ),
            child: Center(
              child: ClipOval(
                child: imagePath.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.network(
                    imagePath,
                    height: 42,
                    width: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 22);
                    },
                  ),
                )
                    : const Icon(Icons.image, size: 22),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category['name'] ?? '',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Sub Categories",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

           
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: allSubCategories.isNotEmpty
                    ? GridView.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.8,
                  children: List.generate(
                    allSubCategories.length,
                        (index) {
                      final category = allSubCategories[index] as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedIndexes.contains(index)) {
                              selectedIndexes.remove(index);
                            } else {
                              selectedIndexes.add(index);
                            }
                          });
                        },
                        child: categoryItemWidget(
                          category,
                          selectedIndexes.contains(index),
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Text(
                    "No subcategories found.",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
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
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedIndexes.isNotEmpty
                            ? () {
                          // Collect all selected subcategory IDs
                          final selectedSubCategoryIds = selectedIndexes
                              .map((index) => allSubCategories[index]['_id'] as String)
                              .toList();
                          // Use the first selected subcategory's name for WorkerlistScreen
                          final firstSelectedSubCategory = allSubCategories[selectedIndexes.first];
                        bwDebug("categoryId: ${widget.categoryId}, sub catecory Id: $selectedSubCategoryIds");
                          fetchServiceProviders(
                            widget.categoryId,
                            selectedSubCategoryIds,
                            firstSelectedSubCategory['name'],
                          );
                        }
                            : null,
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
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}