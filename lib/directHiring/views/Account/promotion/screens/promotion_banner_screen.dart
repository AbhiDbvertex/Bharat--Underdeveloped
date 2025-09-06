//
//
// import 'dart:io';
//
// import 'package:developer/Emergency/utils/size_ratio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../../../controllers/AccountController/promotion_controller.dart';
// import '../widgets/promotion_slider.dart';
//
// class PromotionBannerScreen extends StatefulWidget {
//   const PromotionBannerScreen({super.key});
//
//   @override
//   State<PromotionBannerScreen> createState() => _PromotionBannerScreenState();
// }
//
// class _PromotionBannerScreenState extends State<PromotionBannerScreen> {
//   final promotionController = Get.put(PromotionController());
//   final _promotionForm = GlobalKey<FormState>();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _whyPromoteController = TextEditingController();
//
//
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickImages() async {
//     try {
//       final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: 5);
//       if (pickedFiles.isNotEmpty) {
//         setState(() {
//           promotionController.selectedImages.value = pickedFiles.map((e) => File(e.path)).toList();
//         });
//       }
//     } catch (e) {
//       debugPrint("Image pick error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         systemOverlayStyle:
//         const SystemUiOverlayStyle(statusBarColor: Color(0xff228B22)),
//         title: const Text('Promotion Banner'),
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: _promotionForm,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: 1.toWidthPercent(),
//                 height: 250,
//                 child: PromotionCarouselSlider(),
//               ),
//               const SizedBox(height: 25),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text("Title",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w500),),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: _whyPromoteController,
//                   decoration: InputDecoration(
//                     prefixIcon : Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SvgPicture.asset("assets/svg_images/d_svg/why_promote_icon.svg"),
//                     ),
//                     hintText: 'Why you want to promote',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xff228B22)), // default border
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xff228B22), width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xff228B22), width: 2.0),
//                     ),
//                   ),
//                   validator: (value) =>
//                   value == null || value.isEmpty ? "" : null,
//                   onChanged: (value) {
//                     // re-run validation, will clear error immediately if valid
//                     _promotionForm.currentState?.validate();
//                   },
//                 ),
//               ),
//               const SizedBox(height: 25),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text("Description",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w500),),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   maxLines: 5,
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     prefixIcon: Container(
//                       height: 108,
//                       width: 40,
//                       alignment: Alignment.topLeft,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: SvgPicture.asset(
//                           "assets/svg_images/d_svg/discription_icon.svg",
//                           height: 30,
//                           width: 30,
//                           alignment: Alignment.topCenter,
//                         ),
//                       ),
//                     ),
//                     hintText: 'Description',
//                     alignLabelWithHint: true, // helps with multi-line alignment
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xff228B22)), // default border
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xff228B22), width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: Color(0xff228B22), width: 2.0),
//                     ),
//                   ),
//                   validator: (value) =>
//                   value == null || value.isEmpty ? "" : null,
//                   onChanged: (value) {
//                     _promotionForm.currentState?.validate();
//                   },
//                 ),
//
//
//               ),
//               const SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: InkWell(
//                   onTap: (){
//                     _pickImages();
//                   },
//                   child: Container(
//                     height: 53,
//                     width: 1.toWidthPercent(),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Color(0xff228B22)
//                       )
//                     ),
//                     child:  Text("Upload Images +",style: TextStyle(color: Color(0xff228B22)),),
//                     ),
//                 ),
//                 ),
//               const SizedBox(height: 20),
//               Obx(
//                 () {
//                   if (promotionController.selectedImages.isNotEmpty && promotionController.selectedImages.length < 6) {
//                     return SizedBox(
//                       width: 1.toWidthPercent(),
//                       height: 120, // fixed height for the horizontal list
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: promotionController.selectedImages.length,
//                         itemBuilder: (context, index) {
//                           return Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 6),
//                             width: 120, // fixed width per image
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.file(
//                                     promotionController.selectedImages[index],
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 Positioned(
//                                   right: 4,
//                                   top: 4,
//                                   child: GestureDetector(
//                                       onTap: () {
//                                         promotionController.selectedImages
//                                             .removeAt(index);
//                                       },
//                                       child: SvgPicture.asset(
//                                           "assets/svg_images/d_svg/remove_icon.svg")
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     );
//
//                 }else if (promotionController.selectedImages.length > 5){
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("You can upload max 5 images")),
//                       );
//                     });
//                     return SizedBox();
//                   }else{
//                     return SizedBox();
//                   }
//
//                 } ,
//               ),
//
//               const SizedBox(height: 50),
//
//               // ✅ Submit Button
//               InkWell(
//                 onTap: () async {
//                   promotionController.isPromoting.value = true;
//                   if(_promotionForm.currentState?.validate() == true && (promotionController.selectedImages.isNotEmpty || promotionController.selectedImages != null)){
//                     print('dss :- Submitting promotion form .....');
//                     bool success = await promotionController.submitForm(
//                         {
//                           'whyPromote': _whyPromoteController.text.trim(),
//                           'description': _descriptionController.text.trim(),
//                           'images': promotionController.selectedImages,
//                         }
//                     );
//                     if(success){
//                       promotionController.isPromoting.value = false;
//                       promotionController.selectedImages.clear();
//                       _whyPromoteController.clear();
//                       _descriptionController.clear();
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Promoted Successfully")));
//
//                     }else{
//                       promotionController.isPromoting.value = false;
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Promotion Failed")));
//                     }
//                   }else{
//                     promotionController.isPromoting.value = false;
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Promotion Failed")));                  }
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                   alignment: Alignment.center,
//                   width: 1.toWidthPercent(),
//                   height: 50,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: const Color(0xff228B22),
//                   ),child:Obx(
//                     () => promotionController.isPromoting.value ? CircularProgressIndicator(color: Colors.white,): Text(
//                       'Submit',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                 )
//
//                 ),
//               ),
//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Razorpay import
import '../../../../controllers/AccountController/promotion_controller.dart';
import '../widgets/promotion_slider.dart';

class PromotionBannerScreen extends StatefulWidget {
  const PromotionBannerScreen({super.key});

  @override
  State<PromotionBannerScreen> createState() => _PromotionBannerScreenState();
}

class _PromotionBannerScreenState extends State<PromotionBannerScreen> {
  final promotionController = Get.put(PromotionController());
  final _promotionForm = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _whyPromoteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // New phone controller
  final ImagePicker _picker = ImagePicker();
  late Razorpay _razorpay; // Razorpay instance

  // Image picker function
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: 5);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          promotionController.selectedImages.value = pickedFiles.map((e) => File(e.path)).toList();
        });
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Razorpay init karo
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _whyPromoteController.dispose();
    _phoneController.dispose(); // Phone controller dispose
    _razorpay.clear(); // Razorpay cleanup
    super.dispose();
  }

  // Payment success handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");
    // API call karo with form data
    promotionController.submitForm({
      'whyPromote': _whyPromoteController.text.trim(),
      'description': _descriptionController.text.trim(),
      'phone': _phoneController.text.trim(), // UI se phone
      'images': promotionController.selectedImages,
      'paymentId': response.paymentId, // Razorpay payment ID
      'amount': 100, // Static amount, change kar sakta hai
    });
    Get.back();
    Get.snackbar("Success", "Payment done and promotion submitted!",
        backgroundColor: Colors.green, colorText: Colors.white,snackPosition: SnackPosition.BOTTOM);
    // Clear UI fields after success
    _whyPromoteController.clear();
    _descriptionController.clear();
    _phoneController.clear();
    promotionController.selectedImages.clear();
  }

  // Payment error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.message}");
    Get.snackbar("Error", "Payment failed: ${response.message}",
        backgroundColor: Colors.red, colorText: Colors.white);
    promotionController.isPromoting.value = false;
  }

  // External wallet handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarColor: Color(0xff228B22)),
        title: const Text('Promotion Banner'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _promotionForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 1.toWidthPercent(),
                height:  250,
                child: PromotionCarouselSlider(),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Title", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: _whyPromoteController,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset("assets/svg_images/d_svg/why_promote_icon.svg"),
                    ),
                    hintText: 'Why you want to promote',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22), width: 2.0),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Title is required" : null,
                  onChanged: (value) {
                    _promotionForm.currentState?.validate();
                  },
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Description", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  cursorColor: Colors.black,
                  maxLines: 5,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      height: 108,
                      width: 40,
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SvgPicture.asset(
                          "assets/svg_images/d_svg/discription_icon.svg",
                          height: 30,
                          width: 30,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    hintText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22), width: 2.0),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Description is required" : null,
                  onChanged: (value) {
                    _promotionForm.currentState?.validate();
                  },
                ),
              ),
              const SizedBox(height: 25),
              // New Phone Number Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Phone Number", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.phone, color: Color(0xff228B22)),
                    ),
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22), width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    } else if (value.length != 10) {
                      return 'Enter valid 10-digit phone number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _promotionForm.currentState?.validate();
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () {
                    _pickImages();
                  },
                  child: Container(
                    height: 53,
                    width: 1.toWidthPercent(),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xff228B22)),
                    ),
                    child: Text("Upload Images +", style: TextStyle(color: Color(0xff228B22))),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                    () {
                  if (promotionController.selectedImages.isNotEmpty && promotionController.selectedImages.length < 6) {
                    return SizedBox(
                      width: 1.toWidthPercent(),
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: promotionController.selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 120,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    promotionController.selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      promotionController.selectedImages.removeAt(index);
                                    },
                                    child: SvgPicture.asset("assets/svg_images/d_svg/remove_icon.svg"),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else if (promotionController.selectedImages.length > 5) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("You can upload max 5 images")),
                      );
                    });
                    return SizedBox();
                  } else {
                    return SizedBox();
                  }
                },
              ),
              const SizedBox(height: 50),
              // Submit Button with Razorpay
              InkWell(
                onTap: () async {
                  if (_promotionForm.currentState?.validate() == true && promotionController.selectedImages.isNotEmpty) {
                    promotionController.isPromoting.value = true;
                    // Razorpay open karo
                    var options = {
                      'key': 'rzp_test_R7z5O0bqmRXuiH', // Test key
                      'amount': 100 * 100, // Static 100 rupees (in paise)
                      'name': 'The Bharat Work',
                      'description': 'Promotion Payment',
                      'prefill': {'contact': _phoneController.text, 'email': 'test@razorpay.com'},
                      'external': {'wallets': ['paytm']},
                    };
                    try {
                      _razorpay.open(options);
                    } catch (e) {
                      print('Razorpay Error: $e');
                      promotionController.isPromoting.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Payment initiation failed")),
                      );
                    }
                  } else {
                    promotionController.isPromoting.value = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields and upload images")),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  width: 1.toWidthPercent(),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xff228B22),
                  ),
                  child: Obx(
                        () => promotionController.isPromoting.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}