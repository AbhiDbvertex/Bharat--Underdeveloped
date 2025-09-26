// import 'dart:io';
// import 'package:developer/Consent/ApiEndpoint.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Consent/app_constants.dart';
// import '../../Widgets/AppColors.dart';
//
// class UserFeedback extends StatefulWidget {
//   const UserFeedback({Key? key}) : super(key: key);
//
//   @override
//   State<UserFeedback> createState() => _UserFeedbackState();
// }
//
// class _UserFeedbackState extends State<UserFeedback> {
//   int selectedRating = 0;
//   List<XFile> selectedImages = [];
//   TextEditingController feedController = TextEditingController();
//   Future<void> postRatingDarect() async {
//    final String url = "${AppConstants.baseUrl}${ApiEndpoint.postRatingDarect}";
//    print("Abhi:- postRatingDarect call api url :- $url");
//    final prefs = await SharedPreferences.getInstance();
//    final token = prefs.getString('token') ?? '';
//    var response = await http.post(Uri.parse(url),
//        headers: {
//          'Authorization': 'Bearer $token',
//          'Content-Type': 'application/json',
//        },body: {
//          "serviceProviderId":"68468e6452af78dd54bebda3",
//          "review": feedController.text.trim(),
//          "rating": selectedRating,
//          "images": selectedImages,
//        });
//
//   try{
//     if(response.statusCode == 200 || response.statusCode==201){
//       print("Abhi:- postRatingDarect response ${response.body}");
//       print("Abhi:- postRatingDarect response ${response.statusCode}");
//     }else{
//       print("Abhi:- else postRatingDarect response ${response.body}");
//       print("Abhi:- else postRatingDarect response ${response.statusCode}");
//     }
//   }catch(e){
//     print("Abhi:- Exception postRatingDarect $e");
//   }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: Text("Feedback", style: TextStyle(color: Colors.white)),
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Icon(Icons.arrow_back_outlined, color: Colors.white),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Card(
//                 elevation: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           "Rate a Vendor",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 19,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: height * 0.01),
//                       Center(child: Text("How was your experience with us?",)),
//                       SizedBox(height: height * 0.02),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(5, (index) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 selectedRating = index + 1;
//                               });
//                             },
//                             child: Icon(
//                               index < selectedRating
//                                   ? Icons.star
//                                   : Icons.star_border,
//                               color: Colors.amber,
//                               size: height * 0.05,
//                             ),
//                           );
//                         }),
//                       ),
//                       SizedBox(height: 10),
//                       Center(child: Text("Selected Rating: $selectedRating",style: TextStyle(color: Colors.grey),)),
//                       SizedBox(height: height * 0.02),
//                       buildLabel("Add Feedback"),
//                       TextFormField(
//                         controller: feedController,
//                         maxLines: 5, // 👈 Yeh important hai, 1 line ka nahi rahega
//                         decoration: InputDecoration(
//                           hintText: 'Write your feedback...',
//                           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                         ),
//                         style: TextStyle(fontSize: 14),
//                       ),
//
//                       SizedBox(height: height * 0.02),
//                       buildLabel("Upload Images:"),
//                       buildImageUpload(),
//                       SizedBox(height: height * 0.02),
//                       Center(
//                         child: Container(
//                           height: height*0.05,
//                             width: double.infinity,
//                             decoration: BoxDecoration(color: AppColors.primaryGreen,borderRadius: BorderRadius.circular(6)),
//                             child: TextButton(onPressed: (){
//                               postRatingDarect();
//                             }, child: Text("Rate",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 16)))),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   // ✅ Label widget
//   Widget buildLabel(String label) {
//     return Text(
//       label,
//       style: GoogleFonts.roboto(
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//         color: Colors.black87,
//       ),
//     );
//   }
//
//   // ✅ Images select karne ka function
//   Future<void> pickImages() async {
//     final picker = ImagePicker();
//     final pickedList = await picker.pickMultiImage();
//     if (pickedList.isNotEmpty) {
//       setState(() {
//         if (selectedImages.length + pickedList.length <= 5) {
//           selectedImages.addAll(pickedList);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Maximum 5 images allowed")),
//           );
//         }
//       });
//     }
//   }
//
//   Widget buildImageUpload() {
//     return Container(
//       height: 100,
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade400),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child:
//           selectedImages.isEmpty
//               ? GestureDetector(
//                 onTap: pickImages,
//                 child: const Center(
//                   child: Text(
//                     "Upload Images",
//                     style: TextStyle(color: Colors.green),
//                   ),
//                 ),
//               )
//               : ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: selectedImages.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index == selectedImages.length) {
//                     return GestureDetector(
//                       onTap: pickImages,
//                       child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           color: Colors.blue[100],
//                           border: Border.all(color: Colors.blue),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Center(
//                           child: Icon(Icons.add, color: Colors.blue, size: 40),
//                         ),
//                       ),
//                     );
//                   }
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 5),
//                     child: Stack(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.file(
//                             File(selectedImages[index].path),
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         Positioned(
//                           top: 0,
//                           right: 0,
//                           child: IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () {
//                               setState(() {
//                                 selectedImages.removeAt(index);
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../Consent/ApiEndpoint.dart';
import '../../Consent/app_constants.dart';
import '../../../../Widgets/AppColors.dart';


class UserFeedback extends StatefulWidget {
  final providerId;
  final oderId;
  final String oderType;
  const UserFeedback({Key? key, this.providerId, this.oderId, required this.oderType}) : super(key: key);

  @override
  State<UserFeedback> createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  int selectedRating = 0;
  List<XFile> selectedImages = [];
  TextEditingController feedController = TextEditingController();
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> postRatingDarect() async {
    if (selectedRating == 0) {

       CustomSnackBar.show(
          message: "Please select a rating",
          type: SnackBarType.error
      );

      return;
    }

    if (feedController.text.trim().isEmpty) {
       CustomSnackBar.show(
          message: "Please enter feedback",
          type: SnackBarType.error
      );

      return;
    }

    if (feedController.text.trim().length < 10) {

       CustomSnackBar.show(
          message:"Feedback must be at least 10 characters long" ,
          type: SnackBarType.error
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final String url = "${AppConstants.baseUrl}${ApiEndpoint.postRatingDarect}";
      print("Abhi:- postRatingDarect call api url :- $url");
      print("Abhi:- postRatingDarect call api oderId :- ${widget.oderId} providerId : ${widget.providerId} type : ${widget.oderType}");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Create MultipartRequest
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add form fields
      request.fields['serviceProviderId'] = /*'685d21fdb93a9a07a9fe3d0d'*/ widget.providerId;
      request.fields['orderId'] = /*'685d21fdb93a9a07a9fe3d0d'*/ widget.oderId;
      request.fields['type'] = /*'direct'*/ widget.oderType;
      request.fields['review'] = feedController.text.trim();
      request.fields['rating'] = selectedRating.toString();

      // Add images
      for (var image in selectedImages) {
        var compressedImage = await FlutterImageCompress.compressWithFile(
          image.path,
          minWidth: 800,
          minHeight: 800,
          quality: 85,
        );

        if (compressedImage != null) {
          var multipartFile = await http.MultipartFile.fromPath(
            'images',
            image.path,
            filename: image.name,
          );
          request.files.add(multipartFile);
        }
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- postRatingDarect response ${response.body}");
         CustomSnackBar.show(
            message: "Feedback submitted successfully",
            type: SnackBarType.success
        );
        Navigator.pop(context,true);
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => const Bottombar(initialIndex: 1),
        //   ),
        //       (Route<dynamic> route) => false, // sab hata dega
        // );
        // Clear form
        setState(() {
          selectedRating = 0;
          feedController.clear();
          selectedImages.clear();
        });
      }  if (response.statusCode == 500 ) {
        print("Abhi:- else postRatingDarect respons 500  ${response.body}");

         CustomSnackBar.show(
            message: "Internal server error.Try again...",
            type: SnackBarType.error
        );

      } else {
        print("Abhi:- else postRatingDarect response ${response.body}");
        print("Abhi:- else postRatingDarect response ${response.statusCode}");

         CustomSnackBar.show(
            message: "You already reviewed this provider.",
            type: SnackBarType.info
        );

      }
    } catch (e) {
      print("Abhi:- Exception postRatingDarect $e");

       CustomSnackBar.show(
          message: "An error occurred while submitting",
          type: SnackBarType.error
      );

    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar:  AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Feedback",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Rate a Vendor",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Center(child: Text("How was your experience with us?")),
                        SizedBox(height: height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedRating = index + 1;
                                });
                              },
                              child: Icon(
                                index < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: height * 0.05,
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            "Selected Rating: $selectedRating",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        buildLabel("Add Feedback"),
                        TextFormField(
                          controller: feedController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Write your feedback...',
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          style: TextStyle(fontSize: 14),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter feedback';
                            }
                            if (value.trim().length < 10) {
                              return 'Feedback must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        buildLabel("Upload Images:"),
                        buildImageUpload(),
                        SizedBox(height: height * 0.02),
                        Center(
                          child: Container(
                            height: height * 0.05,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isSubmitting
                                  ? AppColors.primaryGreen.withOpacity(0.6)
                                  : AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextButton(
                              onPressed: isSubmitting ? null : postRatingDarect,
                              child: isSubmitting
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                "Rate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        if (selectedImages.length + pickedList.length <= 5) {
          selectedImages.addAll(pickedList);
        } else {

            CustomSnackBar.show(
              message: "Maximum 5 images allowed",
              type: SnackBarType.error
          );

        }
      });
    }
  }

  Widget buildImageUpload() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: selectedImages.isEmpty
          ? GestureDetector(
        onTap: pickImages,
        child: const Center(
          child: Text(
            "Upload Images",
            style: TextStyle(color: Colors.green),
          ),
        ),
      )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == selectedImages.length) {
            return GestureDetector(
              onTap: pickImages,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.blue, size: 40),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(selectedImages[index].path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        selectedImages.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}