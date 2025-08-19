// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../Widgets/AppColors.dart';
// import '../../Consent/app_constants.dart';
// import 'FullImageScreen.dart';
//
// class GalleryScreen extends StatefulWidget {
//   const GalleryScreen({super.key});
//
//   @override
//   State<GalleryScreen> createState() => _GalleryScreenState();
// }
//
// class _GalleryScreenState extends State<GalleryScreen> {
//   List<String> _images = [];
//   bool _isUploading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedImages();
//   }
//
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
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryGreen,
//         centerTitle: true,
//         elevation: 0,
//         toolbarHeight: 20,
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Padding(
//                   padding: EdgeInsets.only(left: 18.0),
//                   child: Icon(
//                     Icons.arrow_back_outlined,
//                     size: 22,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 100),
//               Text(
//                 'Gallery',
//                 style: GoogleFonts.roboto(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 40),
//           Expanded(
//             child:
//                 _images.isEmpty
//                     ? Center(
//                       child: Text(
//                         'No images in gallery. Upload some!',
//                         style: GoogleFonts.roboto(
//                           fontSize: 16,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     )
//                     : GridView.builder(
//                       padding: const EdgeInsets.all(8),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 8,
//                             mainAxisSpacing: 8,
//                             childAspectRatio: 160 / 144,
//                           ),
//                       itemCount: _images.length,
//                       itemBuilder: (context, i) {
//                         return Stack(
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder:
//                                         (_) => FullImageScreen(
//                                           imageUrl: _images[i],
//                                         ),
//                                   ),
//                                 );
//                               },
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.network(
//                                   _images[i],
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   errorBuilder:
//                                       (_, __, ___) => Container(
//                                         color: Colors.grey[300],
//                                         child: const Icon(
//                                           Icons.broken_image,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               top: 4,
//                               right: 4,
//                               child: GestureDetector(
//                                 onTap: () => _confirmDelete(i),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     shape: BoxShape.circle,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         blurRadius: 2,
//                                         color: Colors.black26,
//                                       ),
//                                     ],
//                                   ),
//                                   padding: const EdgeInsets.all(4),
//                                   child: const Icon(
//                                     Icons.close,
//                                     size: 16,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: SizedBox(
//               width: 300,
//               child: ElevatedButton(
//                 onPressed: _isUploading ? null : _uploadImage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade700,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child:
//                     _isUploading
//                         ? const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         )
//                         : Text(
//                           'Upload',
//                           style: GoogleFonts.roboto(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Widgets/AppColors.dart';
import '../../Consent/app_constants.dart';
import 'FullImageScreen.dart';

class GalleryScreen extends StatefulWidget {
  final List<String> images; // Initial images passed from profile.hisWork
  final String serviceProviderId; // Dynamic service provider ID

  const GalleryScreen({
    super.key,
    required this.images,
    required this.serviceProviderId,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> _images = [];
  bool _isUploading = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with passed images
    _images = widget.images;
    _fetchImagesFromApi(); // Fetch additional images from API
  }

  // Fetch images from the API dynamically using serviceProviderId
  Future<void> _fetchImagesFromApi() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/user/getServiceProvider/${widget.serviceProviderId}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> hiswork = responseData['data']['hiswork'];
        final List<String> fullUrls = hiswork.cast<String>().toList();

        // Merge passed images with API-fetched images, removing duplicates
        final mergedList = [..._images, ...fullUrls].toSet().toList();
        setState(() => _images = mergedList);

        // Save to local storage for offline use
        await _saveImagesToLocal(mergedList);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to fetch images: ${response.statusCode}'),
          ),
        );
        // Load from local storage if API fails
        await _loadSavedImages();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error fetching images: $e')));
      // Load from local storage on error
      await _loadSavedImages();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Load images from local storage
  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('local_gallery_${widget.serviceProviderId}');
    if (saved != null) {
      final List<String> images = List<String>.from(jsonDecode(saved));
      setState(() => _images = [...widget.images, ...images].toSet().toList());
    }
  }

  // Save images to local storage
  Future<void> _saveImagesToLocal(List<String> images) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'local_gallery_${widget.serviceProviderId}',
      jsonEncode(images),
    );
  }

  // Upload images
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No images selected')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
        );
        setState(() => _isUploading = false);
        return;
      }

      var request = http.MultipartRequest(
        'POST',
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

        final mergedList = [..._images, ...fullUrls].toSet().toList();
        setState(() => _images = mergedList);
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
      setState(() => _isUploading = false);
    }
  }

  // Delete confirmation dialog
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
                "Are You Really Want\n To Delete This Image",
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
                      setState(() => _images.removeAt(index));
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Icon(
                    Icons.arrow_back_outlined,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 100),
              Text(
                'Gallery',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _images.isEmpty
                ? Center(
              child: Text(
                'No images in gallery. Upload some!',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 160 / 144,
              ),
              itemCount: _images.length,
              itemBuilder: (context, i) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FullImageScreen(
                              imageUrl: _images[i],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _images[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder:
                              (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _confirmDelete(i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ),
                  ],
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