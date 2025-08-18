// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../Consent/app_constants.dart';
//
// class HisWorkScreen extends StatefulWidget {
//   final List<String> images;
//
//   HisWorkScreen({super.key, required this.images});
//
//   @override
//   State<HisWorkScreen> createState() => _HisWorkScreenState();
//
//   List<String> _images = [];
//   bool _isUploading = false;
//   Future<void> _loadSavedImages() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getString('local_gallery');
//     if (saved != null) {
//       final List<String> images = List<String>.from(jsonDecode(saved));
//       setState(() => _images = images);
//     }
//   }
//
//   Future<void> _saveImagesToLocal(List<String> images) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('local_gallery', jsonEncode(images));
//   }
//
//   Future<void> _uploadImage() async {
//     final picker = ImagePicker();
//     final pickedFiles = await picker.pickMultiImage();
//     if (pickedFiles.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('No images selected')));
//       return;
//     }
//
//     setState(() => _isUploading = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null || token.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
//         );
//         setState(() => _isUploading = false);
//         return;
//       }
//
//       var request = http.MultipartRequest(
//         'PUT',
//         Uri.parse('${AppConstants.baseUrl}/user/updateHisWork'),
//       )..headers['Authorization'] = 'Bearer $token';
//
//       for (var file in pickedFiles) {
//         final mimeType =
//             lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'hiswork',
//             file.path,
//             contentType: MediaType(mimeType[0], mimeType[1]),
//           ),
//         );
//       }
//
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final responseData = jsonDecode(responseBody);
//
//       if (response.statusCode == 200) {
//         final List<dynamic> hiswork = responseData['data']['hiswork'];
//         print("Abhi:- response gallery iamge : ${responseBody}");
//         final List<String> fullUrls =
//             hiswork.map<String>((img) {
//               final cleanPath = img.toString().replaceAll('\\', '/');
//               return cleanPath.startsWith('http')
//                   ? cleanPath
//                   : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
//             }).toList();
//
//         /// ✅ FIXED: Merge existing images with new ones without duplicates
//         final mergedList = [..._images, ...fullUrls].toSet().toList();
//
//         setState(() => _images = mergedList);
//         await _saveImagesToLocal(mergedList);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('✅ Images uploaded successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Upload failed: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }
//
//   void _confirmDelete(int index) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 20),
//               Image.asset(
//                 "assets/images/delete2.png",
//                 height: 140,
//                 width: 130,
//                 fit: BoxFit.cover,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 "Are You Really Want\n To Delete This Image",
//                 style: GoogleFonts.roboto(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   InkWell(
//                     onTap: () async {
//                       setState(() => _images.removeAt(index));
//                       await _saveImagesToLocal(_images);
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("✅ Image deleted")),
//                       );
//                     },
//                     borderRadius: BorderRadius.circular(8),
//                     splashColor: Colors.white.withOpacity(0.2),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 42,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         "OK",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () => Navigator.pop(context),
//                     borderRadius: BorderRadius.circular(8),
//                     splashColor: Colors.green.withOpacity(0.2),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 28,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.green),
//                       ),
//                       child: const Text(
//                         "Cancel",
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _HisWorkScreenState extends State<HisWorkScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade700,
//         title: Text(
//           "His Work",
//           style: GoogleFonts.poppins(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body:
//           widget.images.isEmpty
//               ? Center(
//                 child: Text(
//                   "No work images available.",
//                   style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
//                 ),
//               )
//               : Column(
//                 children: [
//                   GridView.builder(
//                     padding: const EdgeInsets.all(16),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2, // Two images per row
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 1, // Square images
//                         ),
//                     itemCount: widget.images.length,
//                     itemBuilder: (context, index) {
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.network(
//                           widget.images[index],
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey.shade200,
//                               child: const Center(
//                                 child: Icon(
//                                   Icons.broken_image,
//                                   color: Colors.grey,
//                                   size: 50,
//                                 ),
//                               ),
//                             );
//                           },
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 value:
//                                     loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress
//                                                 .cumulativeBytesLoaded /
//                                             (loadingProgress
//                                                     .expectedTotalBytes ??
//                                                 1)
//                                         : null,
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: SizedBox(
//                       width: 300,
//                       child: ElevatedButton(
//                         onPressed: _isUploading ? null : _uploadImage,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green.shade700,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child:
//                             _isUploading
//                                 ? const CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 )
//                                 : Text(
//                                   'Upload',
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//     );
//   }
// }
//
// import 'dart:convert';
//
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Consent/app_constants.dart';

// class AppConstants {
//   // static const String baseUrl = 'YOUR_BASE_URL'; // Replace with your API base URL
//   // static const String baseImageUrl = 'YOUR_IMAGE_BASE_URL'; // Replace with your image base URL
// }

class HisWorkScreen extends StatefulWidget {
  final List<String> images;
  const HisWorkScreen({super.key, required this.images});

  @override
  State<HisWorkScreen> createState() => _HisWorkScreenState();
}

class _HisWorkScreenState extends State<HisWorkScreen> {
  List<String> _images = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('local_gallery');
    if (saved != null) {
      final List<String> images = List<String>.from(jsonDecode(saved));
      setState(() {
        _images = images;
      });
    }
  }

  Future<void> _saveImagesToLocal(List<String> images) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_gallery', jsonEncode(images));
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No images selected')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${AppConstants.baseUrl}/user/updateHisWork'),
      )..headers['Authorization'] = 'Bearer $token';

      for (var file in pickedFiles) {
        final mimeType =
            lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];
        request.files.add(
          await http.MultipartFile.fromPath(
            'hiswork',
            file.path,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        final List<dynamic> hiswork = responseData['data']['hiswork'];
        final List<String> fullUrls =
            hiswork.map<String>((img) {
              final cleanPath = img.toString().replaceAll('\\', '/');
              return cleanPath.startsWith('http')
                  ? cleanPath
                  : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
            }).toList();

        // Merge existing images with new ones without duplicates
        final mergedList = [..._images, ...fullUrls].toSet().toList();

        setState(() {
          _images = mergedList;
        });
        await _saveImagesToLocal(mergedList);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Images uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                "assets/images/delete2.png",
                height: 140,
                width: 130,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                "Are you sure you want\nto delete this image?",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _images.removeAt(index);
                      });
                      await _saveImagesToLocal(_images);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Image deleted")),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    splashColor: Colors.white.withOpacity(0.2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 42,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    splashColor: Colors.green.withOpacity(0.2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          "His Work",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      /*  body:
          _images.isEmpty
              ? Center(
                child: Text(
                  "No work images available.",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () => _confirmDelete(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _uploadImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isUploading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                : Text(
                                  'Upload',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),*/
      body:
          widget.images.isEmpty
              ? Center(
                child: Text(
                  "No work images available.",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two images per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1, // Square images
                          ),
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              (loadingProgress
                                                      .expectedTotalBytes ??
                                                  1)
                                          : null,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _uploadImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isUploading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                                : Text(
                                  'Upload',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
