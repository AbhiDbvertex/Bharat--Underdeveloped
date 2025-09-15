// // //
// // // import 'dart:convert';
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:http_parser/http_parser.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:mime/mime.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // import '../../../../Widgets/AppColors.dart';
// // // import '../../Consent/app_constants.dart';
// // // import 'FullImageScreen.dart';
// // //
// // // class GalleryScreen extends StatefulWidget {
// // //   final List<String> images; // Initial images passed from profile.hisWork
// // //   final String serviceProviderId; // Dynamic service provider ID
// // //
// // //   const GalleryScreen({
// // //     super.key,
// // //     required this.images,
// // //     required this.serviceProviderId,
// // //   });
// // //
// // //   @override
// // //   State<GalleryScreen> createState() => _GalleryScreenState();
// // // }
// // //
// // // class _GalleryScreenState extends State<GalleryScreen> {
// // //   List<String> _images = [];
// // //   bool _isUploading = false;
// // //   bool _isLoading = true;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     // Initialize with passed images
// // //     _images = widget.images;
// // //     _fetchImagesFromApi(); // Fetch additional images from API
// // //   }
// // //
// // //   // Fetch images from the API dynamically using serviceProviderId
// // //   Future<void> _fetchImagesFromApi() async {
// // //     setState(() => _isLoading = true);
// // //
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final token = prefs.getString('token');
// // //       if (token == null || token.isEmpty) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
// // //         );
// // //         setState(() => _isLoading = false);
// // //         return;
// // //       }
// // //
// // //       final response = await http.get(
// // //         Uri.parse(
// // //           '${AppConstants.baseUrl}/user/getServiceProvider/${widget.serviceProviderId}',
// // //         ),
// // //         headers: {'Authorization': 'Bearer $token'},
// // //       );
// // //
// // //       if (response.statusCode == 200) {
// // //         final responseData = jsonDecode(response.body);
// // //         final List<dynamic> hiswork = responseData['data']['hiswork'];
// // //         final List<String> fullUrls = hiswork.cast<String>().toList();
// // //
// // //         // Merge passed images with API-fetched images, removing duplicates
// // //         final mergedList = [..._images, ...fullUrls].toSet().toList();
// // //         setState(() => _images = mergedList);
// // //
// // //         // Save to local storage for offline use
// // //         // await _saveImagesToLocal(mergedList);
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text('❌ Failed to fetch images: ${response.statusCode}'),
// // //           ),
// // //         );
// // //         // Load from local storage if API fails
// // //         await _loadSavedImages();
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(
// // //         context,
// // //       ).showSnackBar(SnackBar(content: Text('⚠️ Error fetching images: $e')));
// // //       // Load from local storage on error
// // //       // await _loadSavedImages();
// // //     } finally {
// // //       setState(() => _isLoading = false);
// // //     }
// // //   }
// // //
// // //   // Load images from local storage
// // //   Future<void> _loadSavedImages() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final saved = prefs.getString('local_gallery_${widget.serviceProviderId}');
// // //     if (saved != null) {
// // //       final List<String> images = List<String>.from(jsonDecode(saved));
// // //       setState(() => _images = [...widget.images, ...images].toSet().toList());
// // //     }
// // //   }
// // //
// // //   // // Save images to local storage
// // //   // Future<void> _saveImagesToLocal(List<String> images) async {
// // //   //   final prefs = await SharedPreferences.getInstance();
// // //   //   await prefs.setString(
// // //   //     'local_gallery_${widget.serviceProviderId}',
// // //   //     jsonEncode(images),
// // //   //   );
// // //   // }
// // //
// // //   // Upload images
// // //   Future<void> _uploadImage() async {
// // //     final picker = ImagePicker();
// // //     final pickedFiles = await picker.pickMultiImage();
// // //     if (pickedFiles.isEmpty) {
// // //       ScaffoldMessenger.of(
// // //         context,
// // //       ).showSnackBar(const SnackBar(content: Text('No images selected')));
// // //       return;
// // //     }
// // //
// // //     setState(() => _isUploading = true);
// // //
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final token = prefs.getString('token');
// // //       if (token == null || token.isEmpty) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
// // //         );
// // //         setState(() => _isUploading = false);
// // //         return;
// // //       }
// // //
// // //       var request = http.MultipartRequest(
// // //         'POST',
// // //         Uri.parse('${AppConstants.baseUrl}/user/updateHisWork'),
// // //       )..headers['Authorization'] = 'Bearer $token';
// // //
// // //       for (var file in pickedFiles) {
// // //         final mimeType =
// // //             lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];
// // //         request.files.add(
// // //           await http.MultipartFile.fromPath(
// // //             'hiswork',
// // //             file.path,
// // //             contentType: MediaType(mimeType[0], mimeType[1]),
// // //           ),
// // //         );
// // //       }
// // //
// // //       final response = await request.send();
// // //       final responseBody = await response.stream.bytesToString();
// // //       final responseData = jsonDecode(responseBody);
// // //
// // //       if (response.statusCode == 200) {
// // //         final List<dynamic> hiswork = responseData['data']['hiswork'];
// // //         final List<String> fullUrls =
// // //         hiswork.map<String>((img) {
// // //           final cleanPath = img.toString().replaceAll('\\', '/');
// // //           return cleanPath.startsWith('http')
// // //               ? cleanPath
// // //               : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
// // //         }).toList();
// // //
// // //         final mergedList = [..._images, ...fullUrls].toSet().toList();
// // //         setState(() => _images = mergedList);
// // //         // await _saveImagesToLocal(mergedList);
// // //         Navigator.pop(context);
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('✅ Images uploaded successfully')),
// // //         );
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('❌ Upload failed: ${response.statusCode}')),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(
// // //         context,
// // //       ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
// // //     } finally {
// // //       setState(() => _isUploading = false);
// // //     }
// // //   }
// // //
// // //   Future<void> deleteImages(ImageUrl) async {
// // //     final String url = 'https://api.thebharatworks.com/api/user/deleteHisworkImage';
// // //     print("Abhi:- deleteImages api url : $url");
// // //
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final token = prefs.getString('token');
// // //     if (token == null || token.isEmpty) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
// // //       );
// // //       setState(() => _isLoading = false);
// // //       return;
// // //     }
// // //
// // //     try{
// // //       var response = await http.post(Uri.parse(url),headers: {'Authorization': 'Bearer $token'},
// // //           body: {
// // //         "imagePath": ImageUrl
// // //       }
// // //       );
// // //
// // //       if(response.statusCode == 200 || response.statusCode == 201)
// // //       {
// // //         print("Abhi:- deleteImage api statusCode : ${response.statusCode}");
// // //         print("Abhi:- deleteImage api response : ${response.body}");
// // //       }else{
// // //
// // //         print("Abhi:- else deleteImage api statusCode : ${response.statusCode}");
// // //         print("Abhi:- else deleteImage api response : ${response.body}");
// // //       }
// // //
// // //     }catch(e){
// // //       print("Abhi:- print Exception : $e");
// // //     }
// // //
// // //   }
// // //
// // //   // Delete confirmation dialog
// // //   void _confirmDelete(int index) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) {
// // //         return AlertDialog(
// // //           backgroundColor: Colors.white,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(12),
// // //           ),
// // //           content: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               const SizedBox(height: 20),
// // //               Image.asset(
// // //                 "assets/images/delete2.png",
// // //                 height: 140,
// // //                 width: 130,
// // //                 fit: BoxFit.cover,
// // //               ),
// // //               const SizedBox(height: 16),
// // //               Text(
// // //                 "Are You Really Want\n To Delete This Image",
// // //                 style: GoogleFonts.roboto(
// // //                   fontSize: 16,
// // //                   fontWeight: FontWeight.w500,
// // //                   color: Colors.black,
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //               ),
// // //             ],
// // //           ),
// // //           actions: [
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 12.0),
// // //               child: Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                 children: [
// // //                   InkWell(
// // //                     onTap: () async {
// // //                       setState(() => _images.removeAt(index));
// // //                       // await _saveImagesToLocal(_images);
// // //                       deleteImages();   //       yaha use jis image ko delete karna chahta hai us ka url pass karo
// // //                       Navigator.pop(context);
// // //                       ScaffoldMessenger.of(context).showSnackBar(
// // //                         const SnackBar(content: Text("Image deleted")),
// // //                       );
// // //                     }, // this time sliping
// // //                     borderRadius: BorderRadius.circular(8),
// // //                     splashColor: Colors.white.withOpacity(0.2),
// // //                     child: Container(
// // //                       padding: const EdgeInsets.symmetric(
// // //                         horizontal: 42,
// // //                         vertical: 10,
// // //                       ),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.green,
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                       child: const Text(
// // //                         "OK",
// // //                         style: TextStyle(
// // //                           color: Colors.white,
// // //                           fontWeight: FontWeight.w700,
// // //                           fontSize: 14,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   InkWell(
// // //                     onTap: () => Navigator.pop(context),
// // //                     borderRadius: BorderRadius.circular(8),
// // //                     splashColor: Colors.green.withOpacity(0.2),
// // //                     child: Container(
// // //                       padding: const EdgeInsets.symmetric(
// // //                         horizontal: 28,
// // //                         vertical: 8,
// // //                       ),
// // //                       decoration: BoxDecoration(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                         border: Border.all(color: Colors.green),
// // //                       ),
// // //                       child: const Text(
// // //                         "Cancel",
// // //                         style: TextStyle(
// // //                           color: Colors.green,
// // //                           fontWeight: FontWeight.w700,
// // //                           fontSize: 14,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey[100],
// // //       appBar: AppBar(
// // //         backgroundColor: AppColors.primaryGreen,
// // //         centerTitle: true,
// // //         elevation: 0,
// // //         toolbarHeight: 20,
// // //         automaticallyImplyLeading: false,
// // //       ),
// // //       body: Column(
// // //         children: [
// // //           const SizedBox(height: 20),
// // //           Row(
// // //             children: [
// // //               GestureDetector(
// // //                 onTap: () => Navigator.pop(context),
// // //                 child: const Padding(
// // //                   padding: EdgeInsets.only(left: 18.0),
// // //                   child: Icon(
// // //                     Icons.arrow_back_outlined,
// // //                     size: 22,
// // //                     color: Colors.black,
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 100),
// // //               Text(
// // //                 'Gallery',
// // //                 style: GoogleFonts.roboto(
// // //                   fontSize: 18,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 40),
// // //           Expanded(
// // //             child:
// // //             _isLoading
// // //                 ? const Center(child: CircularProgressIndicator())
// // //                 : _images.isEmpty
// // //                 ? Center(
// // //               child: Text(
// // //                 'No images in gallery. Upload some!',
// // //                 style: GoogleFonts.roboto(
// // //                   fontSize: 16,
// // //                   color: Colors.grey.shade600,
// // //                 ),
// // //               ),
// // //             )
// // //                 : GridView.builder(
// // //               padding: const EdgeInsets.all(8),
// // //               gridDelegate:
// // //               const SliverGridDelegateWithFixedCrossAxisCount(
// // //                 crossAxisCount: 2,
// // //                 crossAxisSpacing: 8,
// // //                 mainAxisSpacing: 8,
// // //                 childAspectRatio: 160 / 144,
// // //               ),
// // //               itemCount: _images.length,
// // //               itemBuilder: (context, i) {
// // //                 return Stack(
// // //                   children: [
// // //                     GestureDetector(
// // //                       onTap: () {
// // //                         Navigator.push(
// // //                           context,
// // //                           MaterialPageRoute(
// // //                             builder:
// // //                                 (_) => FullImageScreen(
// // //                               imageUrl: _images[i],
// // //                             ),
// // //                           ),
// // //                         );
// // //                       },
// // //                       child: ClipRRect(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                         child: Image.network(
// // //                           _images[i],
// // //                           fit: BoxFit.cover,
// // //                           width: double.infinity,
// // //                           height: double.infinity,
// // //                           errorBuilder:
// // //                               (_, __, ___) => Container(
// // //                             color: Colors.grey[300],
// // //                             child: const Icon(
// // //                               Icons.broken_image,
// // //                               color: Colors.grey,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     Positioned(
// // //                       top: 4,
// // //                       right: 4,
// // //                       child: GestureDetector(
// // //                         onTap: () => _confirmDelete(i),
// // //                         child: Container(
// // //                           decoration: BoxDecoration(
// // //                             color: Colors.white,
// // //                             shape: BoxShape.circle,
// // //                             boxShadow: [
// // //                               BoxShadow(
// // //                                 blurRadius: 2,
// // //                                 color: Colors.black26,
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           padding: const EdgeInsets.all(4),
// // //                           child: Icon(
// // //                             Icons.close,
// // //                             size: 18,
// // //                             color: Colors.green[700],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           Padding(
// // //             padding: const EdgeInsets.all(16),
// // //             child: SizedBox(
// // //               width: 300,
// // //               child: ElevatedButton(
// // //                 onPressed: _isUploading ? null : _uploadImage,
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: Colors.green.shade700,
// // //                   padding: const EdgeInsets.symmetric(vertical: 16),
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(8),
// // //                   ),
// // //                 ),
// // //                 child:
// // //                 _isUploading
// // //                     ? const CircularProgressIndicator(
// // //                   color: Colors.white,
// // //                   strokeWidth: 2,
// // //                 )
// // //                     : Text(
// // //                   'Upload',
// // //                   style: GoogleFonts.roboto(
// // //                     fontSize: 16,
// // //                     fontWeight: FontWeight.w600,
// // //                     color: Colors.white,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:mime/mime.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../../../Widgets/AppColors.dart';
// // import '../../Consent/app_constants.dart';
// // import 'FullImageScreen.dart';
// //
// // class GalleryScreen extends StatefulWidget {
// //   final List<String> images; // Initial images passed from profile.hisWork
// //   final String serviceProviderId; // Dynamic service provider ID
// //
// //   const GalleryScreen({
// //     super.key,
// //     required this.images,
// //     required this.serviceProviderId,
// //   });
// //
// //   @override
// //   State<GalleryScreen> createState() => _GalleryScreenState();
// // }
// //
// // class _GalleryScreenState extends State<GalleryScreen> {
// //   List<String> _images = [];
// //   bool _isUploading = false;
// //   bool _isLoading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initial images set karo
// //     _images = widget.images;
// //     _fetchImagesFromApi(); // API se images fetch karo
// //   }
// //
// //   // Fetch images from API
// //   Future<void> _fetchImagesFromApi() async {
// //     setState(() => _isLoading = true);
// //
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');
// //       if (token == null || token.isEmpty) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
// //         );
// //         setState(() => _isLoading = false);
// //         return;
// //       }
// //
// //       final response = await http.get(
// //         Uri.parse(
// //           '${AppConstants.baseUrl}/user/getServiceProvider/${widget.serviceProviderId}',
// //         ),
// //         headers: {'Authorization': 'Bearer $token'},
// //       );
// //
// //       if (response.statusCode == 200) {
// //         final responseData = jsonDecode(response.body);
// //         final List<dynamic> hiswork = responseData['data']['hiswork'];
// //         final List<String> fullUrls = hiswork.cast<String>().toList();
// //
// //         // Merge passed images with API-fetched images, duplicates hatao
// //         final mergedList = [..._images, ...fullUrls].toSet().toList();
// //         setState(() => _images = mergedList);
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('❌ Failed to fetch images: ${response.statusCode}'),
// //           ),
// //         );
// //         // await _loadSavedImages();
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('⚠️ Error fetching images: $e')),
// //       );
// //       // await _loadSavedImages();
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   // // Load images from local storage
// //   // Future<void> _loadSavedImages() async {
// //   //   final prefs = await SharedPreferences.getInstance();
// //   //   final saved = prefs.getString('local_gallery_${widget.serviceProviderId}');
// //   //   if (saved != null) {
// //   //     final List<String> images = List<String>.from(jsonDecode(saved));
// //   //     setState(() => _images = [...widget.images, ...images].toSet().toList());
// //   //   }
// //   // }
// //
// //   // Upload images
// //   Future<void> _uploadImage() async {
// //     final picker = ImagePicker();
// //     final pickedFiles = await picker.pickMultiImage();
// //     if (pickedFiles.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('No images selected')),
// //       );
// //       return;
// //     }
// //
// //     setState(() => _isUploading = true);
// //
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');
// //       if (token == null || token.isEmpty) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
// //         );
// //         setState(() => _isUploading = false);
// //         return;
// //       }
// //
// //       var request = http.MultipartRequest(
// //         'POST',
// //         Uri.parse('${AppConstants.baseUrl}/user/updateHisWork'),
// //       )..headers['Authorization'] = 'Bearer $token';
// //
// //       for (var file in pickedFiles) {
// //         final mimeType =
// //             lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];
// //         request.files.add(
// //           await http.MultipartFile.fromPath(
// //             'hiswork',
// //             file.path,
// //             contentType: MediaType(mimeType[0], mimeType[1]),
// //           ),
// //         );
// //       }
// //
// //       final response = await request.send();
// //       final responseBody = await response.stream.bytesToString();
// //       final responseData = jsonDecode(responseBody);
// //
// //       if (response.statusCode == 200) {
// //         final List<dynamic> hiswork = responseData['data']['hiswork'];
// //         final List<String> fullUrls = hiswork.map<String>((img) {
// //           final cleanPath = img.toString().replaceAll('\\', '/');
// //           return cleanPath.startsWith('http')
// //               ? cleanPath
// //               : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
// //         }).toList();
// //
// //         final mergedList = [..._images, ...fullUrls].toSet().toList();
// //         setState(() => _images = mergedList);
// //         Navigator.pop(context);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('✅ Images uploaded successfully')),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('❌ Upload failed: ${response.statusCode}')),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('⚠️ Error: $e')),
// //       );
// //     } finally {
// //       setState(() => _isUploading = false);
// //     }
// //   }
// //
// //   // Delete image function - imageUrl parameter add kiya
// //   Future<void> deleteImages(String imageUrl) async {
// //     final String url = 'https://api.thebharatworks.com/api/user/deleteHisworkImage';
// //     print("Abhi:- deleteImages api url: $url");
// //     print("Abhi:- Deleting image: $imageUrl"); // Debug ke liye URL print
// //
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token');
// //     if (token == null || token.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
// //       );
// //       return;
// //     }
// //
// //     try {
// //       var response = await http.post(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Content-Type': 'application/json', // JSON body ke liye
// //         },
// //         body: jsonEncode({
// //           "imagePath": imageUrl, // Image URL pass karo
// //         }),
// //       );
// //
// //       print("Abhi:- deleteImage api statusCode: ${response.statusCode}");
// //       print("Abhi:- deleteImage api response: ${response.body}");
// //
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         // Image list se remove karo
// //         setState(() {
// //           _images.remove(imageUrl);
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('✅ Image deleted successfully')),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('❌ Delete failed: ${response.statusCode}'),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       print("Abhi:- Exception: $e");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('⚠️ Error deleting image: $e')),
// //       );
// //     }
// //   }
// //
// //   // Delete confirmation dialog
// //   void _confirmDelete(int index) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const SizedBox(height: 20),
// //               Image.asset(
// //                 "assets/images/delete2.png",
// //                 height: 140,
// //                 width: 130,
// //                 fit: BoxFit.cover,
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 "Are You Really Want\n To Delete This Image",
// //                 style: GoogleFonts.roboto(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.w500,
// //                   color: Colors.black,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             Padding(
// //               padding: const EdgeInsets.only(bottom: 12.0),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   InkWell(
// //                     onTap: () async {
// //                       final imageUrl = _images[index]; // Image URL lo
// //                       Navigator.pop(context); // Dialog close karo
// //                       await deleteImages(imageUrl); // Delete API call with URL
// //                     },
// //                     borderRadius: BorderRadius.circular(8),
// //                     splashColor: Colors.white.withOpacity(0.2),
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 42,
// //                         vertical: 10,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.green,
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: const Text(
// //                         "OK",
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w700,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   InkWell(
// //                     onTap: () => Navigator.pop(context),
// //                     borderRadius: BorderRadius.circular(8),
// //                     splashColor: Colors.green.withOpacity(0.2),
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 28,
// //                         vertical: 8,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.green),
// //                       ),
// //                       child: const Text(
// //                         "Cancel",
// //                         style: TextStyle(
// //                           color: Colors.green,
// //                           fontWeight: FontWeight.w700,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         backgroundColor: AppColors.primaryGreen,
// //         centerTitle: true,
// //         elevation: 0,
// //         toolbarHeight: 20,
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: Column(
// //         children: [
// //           const SizedBox(height: 20),
// //           Row(
// //             children: [
// //               GestureDetector(
// //                 onTap: () => Navigator.pop(context),
// //                 child: const Padding(
// //                   padding: EdgeInsets.only(left: 18.0),
// //                   child: Icon(
// //                     Icons.arrow_back_outlined,
// //                     size: 22,
// //                     color: Colors.black,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 100),
// //               Text(
// //                 'Gallery',
// //                 style: GoogleFonts.roboto(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 40),
// //           Expanded(
// //             child: _isLoading
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : _images.isEmpty
// //                 ? Center(
// //               child: Text(
// //                 'No images in gallery. Upload some!',
// //                 style: GoogleFonts.roboto(
// //                   fontSize: 16,
// //                   color: Colors.grey.shade600,
// //                 ),
// //               ),
// //             )
// //                 : GridView.builder(
// //               padding: const EdgeInsets.all(8),
// //               gridDelegate:
// //               const SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: 2,
// //                 crossAxisSpacing: 8,
// //                 mainAxisSpacing: 8,
// //                 childAspectRatio: 160 / 144,
// //               ),
// //               itemCount: _images.length,
// //               itemBuilder: (context, i) {
// //                 return Stack(
// //                   children: [
// //                     GestureDetector(
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (_) => FullImageScreen(
// //                               imageUrl: _images[i],
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                       child: ClipRRect(
// //                         borderRadius: BorderRadius.circular(8),
// //                         child: Image.network(
// //                           _images[i],
// //                           fit: BoxFit.cover,
// //                           width: double.infinity,
// //                           height: double.infinity,
// //                           errorBuilder: (_, __, ___) => Container(
// //                             color: Colors.grey[300],
// //                             child: const Icon(
// //                               Icons.broken_image,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     Positioned(
// //                       top: 4,
// //                       right: 4,
// //                       child: GestureDetector(
// //                         onTap: () => _confirmDelete(i),
// //                         child: Container(
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             shape: BoxShape.circle,
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 blurRadius: 2,
// //                                 color: Colors.black26,
// //                               ),
// //                             ],
// //                           ),
// //                           padding: const EdgeInsets.all(4),
// //                           child: Icon(
// //                             Icons.close,
// //                             size: 18,
// //                             color: Colors.green[700],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: SizedBox(
// //               width: 300,
// //               child: ElevatedButton(
// //                 onPressed: _isUploading ? null : _uploadImage,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.green.shade700,
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                 ),
// //                 child: _isUploading
// //                     ? const CircularProgressIndicator(
// //                   color: Colors.white,
// //                   strokeWidth: 2,
// //                 )
// //                     : Text(
// //                   'Upload',
// //                   style: GoogleFonts.roboto(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mime/mime.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../Widgets/AppColors.dart';
// import '../../Consent/app_constants.dart';
// import 'FullImageScreen.dart';
//
// class GalleryScreen extends StatefulWidget {
//   final List<String> images; // Initial images passed from profile.hisWork
//   final String serviceProviderId; // Dynamic service provider ID
//
//   const GalleryScreen({
//     super.key,
//     required this.images,
//     required this.serviceProviderId,
//   });
//
//   @override
//   State<GalleryScreen> createState() => _GalleryScreenState();
// }
//
// class _GalleryScreenState extends State<GalleryScreen> {
//   List<String> _images = [];
//   bool _isUploading = false;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initial images set karo
//     _images = widget.images;
//     _fetchImagesFromApi(); // API se images fetch karo
//   }
//
//   // Fetch images from API
//   Future<void> _fetchImagesFromApi() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null || token.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
//         );
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse(
//           '${AppConstants.baseUrl}/user/getServiceProvider/${widget.serviceProviderId}',
//         ),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final List<dynamic> hiswork = responseData['data']['hiswork'];
//         final List<String> fullUrls = hiswork.cast<String>().toList();
//
//         // Merge passed images with API-fetched images, duplicates hatao
//         final mergedList = [..._images, ...fullUrls].toSet().toList();
//         setState(() => _images = mergedList);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Failed to fetch images: ${response.statusCode}'),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('⚠️ Error fetching images: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // Upload images
//   Future<void> _uploadImage() async {
//     final picker = ImagePicker();
//     final pickedFiles = await picker.pickMultiImage();
//     if (pickedFiles.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No images selected')),
//       );
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
//         'POST',
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
//         final List<String> fullUrls = hiswork.map<String>((img) {
//           final cleanPath = img.toString().replaceAll('\\', '/');
//           return cleanPath.startsWith('http')
//               ? cleanPath
//               : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
//         }).toList();
//
//         final mergedList = [..._images, ...fullUrls].toSet().toList();
//         setState(() => _images = mergedList);
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('✅ Images uploaded successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('❌ Upload failed: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('⚠️ Error: $e')),
//       );
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }
//
//   // Delete image function
//   Future<void> deleteImages(String imageUrl) async {
//     final String url = 'https://api.thebharatworks.com/api/user/deleteHisworkImage';
//     print("Abhi:- deleteImages api url: $url");
//     print("Abhi:- Deleting image: $imageUrl"); // Debug ke liye URL print
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null || token.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('⚠️ Token not found! Please log in.')),
//       );
//       return;
//     }
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "imagePath": imageUrl, // Image URL pass karo
//         }),
//       );
//
//       print("Abhi:- deleteImage api statusCode: ${response.statusCode}");
//       print("Abhi:- deleteImage api response: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // Image list se remove karo
//         setState(() {
//           _images.remove(imageUrl);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('✅ Image deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Delete failed: ${response.statusCode}'),
//           ),
//         );
//       }
//     } catch (e) {
//       print("Abhi:- Exception: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('⚠️ Error deleting image: $e')),
//       );
//     }
//   }
//
//   // Delete confirmation dialog
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
//                       final imageUrl = _images[index]; // Image URL lo
//                       Navigator.pop(context); // Dialog close karo
//                       await deleteImages(imageUrl); // Delete API call with URL
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
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _images.isEmpty
//                 ? Center(
//               child: Text(
//                 'No images in gallery. Upload some!',
//                 style: GoogleFonts.roboto(
//                   fontSize: 16,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             )
//                 : GridView.builder(
//               padding: const EdgeInsets.all(8),
//               gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//                 childAspectRatio: 160 / 144,
//               ),
//               itemCount: _images.length,
//               itemBuilder: (context, i) {
//                 return Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => FullImageScreen(
//                               imageUrl: _images[i],
//                             ),
//                           ),
//                         );
//                       },
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           _images[i],
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: double.infinity,
//                           errorBuilder: (_, __, ___) => Container(
//                             color: Colors.grey[300],
//                             child: const Icon(
//                               Icons.broken_image,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: GestureDetector(
//                         onTap: () => _confirmDelete(i),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 blurRadius: 2,
//                                 color: Colors.black26,
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(4),
//                           child: Icon(
//                             Icons.close,
//                             size: 18,
//                             color: Colors.green[700],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
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
//                 child: _isUploading
//                     ? const CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 )
//                     : Text(
//                   'Upload',
//                   style: GoogleFonts.roboto(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
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
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import '../../../utility/custom_snack_bar.dart';
import '../../Consent/app_constants.dart';
import 'FullImageScreen.dart';

class GalleryScreen extends StatefulWidget {
  final List<String> images;
  final String serviceProviderId;

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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _images = widget.images;
    _fetchImagesFromApi();
  }

  // Fetch images from API
  Future<void> _fetchImagesFromApi() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        CustomSnackBar.show(
            context,
            message:'Token not found! Please log in.' ,
            type: SnackBarType.warning
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
        final List<String> fullUrls = hiswork.map<String>((img) {
          final cleanPath = img.toString().replaceAll('\\', '/');
          return cleanPath.startsWith('http')
              ? cleanPath
              : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
        }).toList();
        final mergedList = [..._images, ...fullUrls].toSet().toList();
        setState(() => _images = mergedList);
        setState(() {

        });
      } else {
               CustomSnackBar.show(
            context,
            message: 'Failed to fetch images: ${response.statusCode}',
            type: SnackBarType.warning
        );

      }
    } catch (e) {

      CustomSnackBar.show(
          context,
          message: 'Error fetching images: $e',
          type: SnackBarType.error
      );

    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _showImageSourceBottomSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: Text(
                  'Camera',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _uploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _uploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  // Upload images
  // Future<void> _uploadImage() async {
  //   final picker = ImagePicker();
  //   final pickedFiles = await picker.pickMultiImage();
  //   if (pickedFiles.isEmpty) {
  //
  //     CustomSnackBar.show(
  //         context,
  //         message: 'No images selected',
  //         type: SnackBarType.warning
  //     );
  //
  //     return;
  //   }
  //
  //   setState(() => _isUploading = true);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');
  //     if (token == null || token.isEmpty) {
  //
  //       CustomSnackBar.show(
  //           context,
  //           message:'Token not found! Please log in.',
  //           type: SnackBarType.warning
  //       );
  //
  //       setState(() => _isUploading = false);
  //       return;
  //     }
  //
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${AppConstants.baseUrl}/user/updateHisWork'),
  //     )..headers['Authorization'] = 'Bearer $token';
  //
  //     for (var file in pickedFiles) {
  //       final mimeType =
  //           lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           'hiswork',
  //           file.path,
  //           contentType: MediaType(mimeType[0], mimeType[1]),
  //         ),
  //       );
  //     }
  //
  //     final response = await request.send();
  //     final responseBody = await response.stream.bytesToString();
  //     final responseData = jsonDecode(responseBody);
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> hiswork = responseData['data']['hiswork'];
  //       final List<String> fullUrls = hiswork.map<String>((img) {
  //         final cleanPath = img.toString().replaceAll('\\', '/');
  //         return cleanPath.startsWith('http')
  //             ? cleanPath
  //             : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
  //       }).toList();
  //
  //       final mergedList = [..._images, ...fullUrls].toSet().toList();
  //       setState(() => _images = mergedList);
  //       Navigator.pop(context,true);
  //       CustomSnackBar.show(
  //           context,
  //           message:'Images uploaded successfully' ,
  //           type: SnackBarType.success
  //       );
  //
  //     } else {
  //
  //       CustomSnackBar.show(
  //           context,
  //           message: 'Upload failed: ${response.statusCode}',
  //           type: SnackBarType.error
  //       );
  //     }
  //   } catch (e) {
  //          CustomSnackBar.show(
  //         context,
  //         message:'Error: $e' ,
  //         type: SnackBarType.error
  //     );
  //
  //   } finally {
  //     setState(() => _isUploading = false);
  //   }
  // }

  // Delete image function - exact relative path bhejo

  Future<void> _uploadImage(ImageSource source) async {
    final picker = ImagePicker();
    List<XFile>? pickedFiles;

    if (source == ImageSource.camera) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        pickedFiles = [pickedFile];
      }
    } else {
      pickedFiles = await picker.pickMultiImage();
    }

    if (pickedFiles == null || pickedFiles.isEmpty) {
      CustomSnackBar.show(
          context,
          message: 'No images selected',
          type: SnackBarType.error
      );

      return;
    }

    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {

        CustomSnackBar.show(
            context,
            message: 'Token not found! Please log in.',
            type: SnackBarType.warning
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
        final List<String> fullUrls = hiswork.map<String>((img) {
          final cleanPath = img.toString().replaceAll('\\', '/');
          return cleanPath.startsWith('http')
              ? cleanPath
              : '${AppConstants.baseImageUrl}/${cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath}';
        }).toList();

        final mergedList = [..._images, ...fullUrls].toSet().toList();
        setState(() => _images = mergedList);
        setState(() => _hasChanges = true);
        Navigator.pop(context, true);

        CustomSnackBar.show(
            context,
            message:'Images uploaded successfully' ,
            type: SnackBarType.success
        );
      } else {

        CustomSnackBar.show(
            context,
            message: 'Upload failed: ${response.statusCode}',
            type: SnackBarType.error
        );
      }
    } catch (e) {

      CustomSnackBar.show(
          context,
          message:'Error: $e' ,
          type: SnackBarType.error
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> deleteImages(String imageUrl) async {
    final String url = 'https://api.thebharatworks.com/api/user/deleteHisworkImage';
    print("Abhi:- deleteImages api url: $url");

    String relativePath = imageUrl.replaceFirst('https://api.thebharatworks.com/', '');
    relativePath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    print("Abhi:- Deleting image relative path: $relativePath");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //await _fetchImagesFromApi();
    if (token == null || token.isEmpty) {

      CustomSnackBar.show(
          context,
          message: 'Token not found! Please log in.',
          type: SnackBarType.warning
      );


      return;
    }

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "imagePath": relativePath,
        }),
      );

      print("Abhi:- deleteImage api statusCode: ${response.statusCode}");
      print("Abhi:- deleteImage api response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Image list se remove karo
        setState(() {
          _images.remove(imageUrl);
        });

        CustomSnackBar.show(
            context,
            message:'Image deleted successfully' ,
            type: SnackBarType.success
        );
        setState(() => _hasChanges = true);
        await _fetchImagesFromApi();
      } else {

        CustomSnackBar.show(
            context,
            message: 'Delete failed: ${response.statusCode} - ${response.body}',
            type: SnackBarType.error
        );

      }
    } catch (e) {
      print("Abhi:- Exception: $e");

      CustomSnackBar.show(
          context,
          message:'Error deleting image: $e' ,
          type: SnackBarType.error
      );

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
                      final imageUrl = _images[index]; 
                      Navigator.pop(context); 
                      print("Abhi:- delete image url :---> $imageUrl");
                      await deleteImages(imageUrl); 
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
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context,_hasChanges);
        return false;
      },
      child: Scaffold(
       // backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Gallery",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          // leading: BackButton(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, _hasChanges),  // Pop with value
          ),
          actions: [],
          systemOverlayStyle:  SystemUiOverlayStyle(
            statusBarColor: AppColors.primaryGreen,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
                       const SizedBox(height: 40),
              Expanded(
                child: _isLoading
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
                                builder: (_) => FullImageScreen(
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
                              errorBuilder: (_, __, ___) => Container(
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
                                color: Colors.red,
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
                    onPressed: _isUploading ? null : _showImageSourceBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isUploading
                        ? SizedBox(
                      height: 25,
                          width: 25,
                          child: const CircularProgressIndicator(

                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
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
        ),
      ),
    );
  }
}