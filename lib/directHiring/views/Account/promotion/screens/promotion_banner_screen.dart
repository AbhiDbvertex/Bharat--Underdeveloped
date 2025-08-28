

import 'dart:io';

import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

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


  final ImagePicker _picker = ImagePicker();

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
  Widget build(BuildContext context) {
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
                height: 250,
                child: PromotionCarouselSlider(),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Title",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w500),),
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
                    prefixIcon : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset("assets/svg_images/d_svg/why_promote_icon.svg"),
                    ),
                    hintText: 'Why you want to promote',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22)), // default border
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
                  validator: (value) =>
                  value == null || value.isEmpty ? "" : null,
                  onChanged: (value) {
                    // re-run validation, will clear error immediately if valid
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
                    Text("Description",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w500),),
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
                    alignLabelWithHint: true, // helps with multi-line alignment
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff228B22)), // default border
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
                  validator: (value) =>
                  value == null || value.isEmpty ? "" : null,
                  onChanged: (value) {
                    _promotionForm.currentState?.validate();
                  },
                ),


              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: (){
                    _pickImages();
                  },
                  child: Container(
                    height: 53,
                    width: 1.toWidthPercent(),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xff228B22)
                      )
                    ),
                    child:  Text("Upload Images +",style: TextStyle(color: Color(0xff228B22)),),
                    ),
                ),
                ),
              const SizedBox(height: 20),
              Obx(
                () {
                  if (promotionController.selectedImages.isNotEmpty && promotionController.selectedImages.length < 6) {
                    return SizedBox(
                      width: 1.toWidthPercent(),
                      height: 120, // fixed height for the horizontal list
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: promotionController.selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 120, // fixed width per image
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
                                        promotionController.selectedImages
                                            .removeAt(index);
                                      },
                                      child: SvgPicture.asset(
                                          "assets/svg_images/d_svg/remove_icon.svg")
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );

                }else if (promotionController.selectedImages.length > 5){
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("You can upload max 5 images")),
                      );
                    });
                    return SizedBox();
                  }else{
                    return SizedBox();
                  }

                } ,
              ),

              const SizedBox(height: 50),

              // ✅ Submit Button
              InkWell(
                onTap: () async {
                  promotionController.isPromoting.value = true;
                  if(_promotionForm.currentState?.validate() == true && (promotionController.selectedImages.isNotEmpty || promotionController.selectedImages != null)){
                    print('dss :- Submitting promotion form .....');
                    bool success = await promotionController.submitForm(
                        {
                          'whyPromote': _whyPromoteController.text.trim(),
                          'description': _descriptionController.text.trim(),
                          'images': promotionController.selectedImages,
                        }
                    );
                    if(success){
                      promotionController.isPromoting.value = false;
                      promotionController.selectedImages.clear();
                      _whyPromoteController.clear();
                      _descriptionController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Promoted Successfully")));

                    }else{
                      promotionController.isPromoting.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Promotion Failed")));
                    }
                  }else{
                    promotionController.isPromoting.value = false;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Promotion Failed")));                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  width: 1.toWidthPercent(),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xff228B22),
                  ),child:Obx(
                    () => promotionController.isPromoting.value ? CircularProgressIndicator(color: Colors.white,): Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                )

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
