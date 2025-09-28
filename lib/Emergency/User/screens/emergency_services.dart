import 'dart:async';
import 'dart:io';

import 'package:developer/Emergency/User/controllers/emergency_service_controller.dart';
import 'package:developer/Emergency/utils/logger.dart';
import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:developer/Widgets/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Bidding/controller/bidding_post_task_controller.dart';
import '../../../utility/custom_snack_bar.dart';

class EmergencyScreen extends StatefulWidget {
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final tag="EmergencyServiceScreen";
  final controller = Get.put(EmergencyServiceController());
  TextStyle fieldHintStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.calculateFee();
    SharedPreferences.getInstance().then((prefs) {
      String? savedLocation = prefs.getString('selected_location') ?? prefs.getString('address');
      var savedLatitude = prefs.getDouble('user_latitude');
      var savedLongitude = prefs.getDouble('user_longitude');

      if (savedLocation != null && savedLocation != 'Select Location') {
        setState(() {
          controller.googleAddressController.text = savedLocation;
          controller.latitude.value = savedLatitude;
          controller.longitude.value = savedLongitude;

          bwDebug(
              "📍 Pre-populated googleAddressController with: $savedLocation");
        });
      } else {
        bwDebug("📍 No valid saved location found");
      }
    });
    // await controller.loadSavedLocation();
  }

  @override
  Widget build(BuildContext context) {
    bwDebug("address: ${controller.googleAddressController.text}\n"
        "latitude: ${controller.latitude.value}\n"
        "longitude: ${controller.longitude.value}",tag: tag);
    final postTaskController = Get.put(PostTaskController(), permanent: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Emergency Services",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black),
        actions: [],
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  color: Color(0xff5abc47).withOpacity(0.1),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Text(
                      "Choose you'r problem",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle("Work Category"),
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          focusColor: AppColors.primaryGreen,
                          value: controller.selectedCategoryId.value.isEmpty
                              ? null
                              : controller.selectedCategoryId.value,
                          hint: Text("Select Category", style: fieldHintStyle),
                          icon: Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: AppColors.primaryGreen,
                          ),
                          items: controller.categories
                              .map((c) => DropdownMenuItem(
                                    value: c['id'],
                                    child: Text(
                                      c['name']!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            controller.selectedCategoryId.value = val!;
                            controller.fetchSubCategories(val);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: AppColors.primaryGreen, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 15),
                          ),
                        );
                      }),
        
                      SizedBox(height: .04.toWidthPercent()),
        
                      _buildTitle("Choose your problem ",
                          otherText: "(Multiple Select)"),
                      customMultiSelectDropdown(
                        hint: "Select Subcategories",
                        items: controller.subCategories,
                        selectedIds: controller.selectedSubCategoryIds,
                      ),
                      SizedBox(height: .04.toWidthPercent()),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTitle("Google Address (GPS)"),
                          InkWell(
                            onTap: postTaskController.navigateToLocationScreen,
                            child: Container(
                              width: 0.35.toWidthPercent(),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Center(
                                child: Text(
                                  "Change location",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //customTextField(hint: "Abc gali 145 banglow no. Indore"),
                      _googleLocationField(controller.googleAddressController),
                      SizedBox(height: .04.toWidthPercent()),
        
                      _buildTitle("Detailed Address (Landmark)"),
                      customTextField(
                          hint: "Enter address",
                          controller: controller.detailedAddressController),
                      SizedBox(height: .04.toWidthPercent()),
        
                      _buildTitle("Contact"),
                      customTextField(
                          hint: "Enter Number",
                          keyboardType: TextInputType.phone,
                          controller: controller.contactController,
                          inputFormatters:  [
                          FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10),
                      SizedBox(height: .04.toWidthPercent()),
        
                      _buildTitle("Task Completed by(Date & Time)"),
                      customDateTimePicker(
                        context: context,
                        selectedDateTime: controller.selectedDateTime,
                      ),
                      SizedBox(height: .04.toWidthPercent()),
        
                      _buildTitle("Upload image"),
                      customImagePicker(
                        images: controller.images,
                        onPick: () async {
                          // controller.pickImages();
                          _showImageSourceSheet(context);
        
                          bwDebug("select image: call ");
                          // file picker logic
                        },
                      ),
        
                      SizedBox(height: 20),
                    ],
                  ),
                ),
        
                // Task Fee
                Obx(() => Container(
                  height: 0.12.toWidthPercent(),
                      width: double.infinity,
                      color: Color(0xfff17773),
                      child: Center(
                        child: Text(
                          "Emergency Task Fees - RS. ${controller.taskFee.value} /-",
                          style: TextStyle(
                            fontSize: 0.040.toWidthPercent(),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
        
                SizedBox(height: 20),
        
                Padding(
                    padding: const EdgeInsets.all(25),
                    child: Obx(() => customButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  controller.isLoading.value = true;
                                  try {
                                    await controller.submitForm(context);
                                  } finally {
                                    controller.isLoading.value = false;
                                  }
                                },
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryGreen,
                                  ),
                                )
                              : Text("Pay"),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ------------------ REUSABLE WIDGETS -------------------

  Widget customTextField({
    TextEditingController? controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: fieldHintStyle,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }

  Widget customDropdown({
    required String hint,
    required RxString selectedValue,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Obx(() => DropdownButtonFormField<String>(
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down_sharp,
              size: 0.1.toWidthPercent(), color: AppColors.primaryGreen),
          value: selectedValue.value.isEmpty ? null : selectedValue.value,
          hint: Text(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            // labelText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
          ),
        ));
  }

  Widget customButton({
    String? text,
    Widget? child,
    required FutureOr<void> Function()? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: child ?? Text(text ?? ""),
      ),
    );
  }

  Widget customDateTimePicker({
    required BuildContext context,
    required Rxn<DateTime> selectedDateTime,
  }) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text(
                selectedDateTime.value == null
                    ? "Select Date & Time"
                    : "${selectedDateTime.value!.day}-${selectedDateTime.value!.month}-${selectedDateTime.value!.year} "
                        "${TimeOfDay.fromDateTime(selectedDateTime.value!).format(context)}",
              ),
              trailing:
                  Icon(Icons.calendar_month, color: AppColors.primaryGreen),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final fullDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    selectedDateTime.value = fullDateTime;
                  } else {
                    selectedDateTime.value = pickedDate;
                  }
                }
              }),
        ));
  }

  Widget customImagePicker({
    required RxList<File> images,
    required VoidCallback onPick,
  }) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ElevatedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen
                //  minimumSize: Size(double.infinity, 60),
                 // side: BorderSide(color: AppColors.primaryGreen, width: 2),
                //  foregroundColor: AppColors.primaryGreen,
                ),
                onPressed: onPick,
                label: Text("+  Upload Image ",style: TextStyle(color: Colors.white),),
              ),
            ),
            SizedBox(height: 10),
            if (images.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length + 1,
                  separatorBuilder: (c, i) => SizedBox(width: 10),
                  itemBuilder: (c, i) {
                    if (i == images.length) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: onPick,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green)),
                            width: 120,
                            height: 120,
                            child: Icon(
                              Icons.add,
                              color: Colors.green,
                              size: 50,
                            ),
                          ),
                        ),
                      );
                    } else {
                      final file = images[i];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: InkWell(
                              onTap: () => images.remove(file),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
          ],
        ));
  }

  Widget _buildTitle(String text, {String? otherText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            text,
            style:
                GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          if (otherText != null)
            Text(otherText,
                style: GoogleFonts.roboto(
                    fontSize: 12, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _googleLocationField(googleAddressController) {
    return
        /*GestureDetector(
      onTap: () async {
        final result = await Navigator.push(context,
          MaterialPageRoute(builder: (_) => MapPickerScreen()),
        );
        if (result != null && result is String) {
          setState(() => googleAddressController.text = result);
        }
      },
      child: AbsorbPointer(
        child: */

        TextFormField(
      enabled: false,
      maxLines: 2,
      controller: googleAddressController,
      // decoration: _inputDecoration("Location", icon: Icons.my_location,),
      decoration: _inputDecoration("Location", icon: Icons.my_location),

      validator: (val) => val == null || val.isEmpty ? "Required field" : null,
    ) /*,
      ),
    )*/
        ;
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: fieldHintStyle,

        prefixIcon:
            icon != null ? Icon(icon, color: AppColors.primaryGreen) : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),

        // 👇 Common border style
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryGreen, width:1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      );

  @override
  void dispose() {
    controller.selectedCategoryId.value = '';
    controller.subCategories.clear();
    controller.selectedSubCategoryIds.clear();
    controller.googleAddressController.clear();
    controller.detailedAddressController.clear();
    controller.contactController.clear();
    controller.selectedDateTime.value = null;
    controller.images.clear();
    //controller.taskFee.value = 0;
    super.dispose();
  }

  Widget customMultiSelectDropdown({
    required String hint,
    required List<Map<String, String>> items,
    required RxList<String> selectedIds,
  }) {
    return Obx(() {
      return GestureDetector(
        onTap: () async {
          if (controller.selectedCategoryId.value.isEmpty) {
            // Get.showSnackbar(GetSnackBar(
            //   message: "Select a category first",
            //   duration: Duration(seconds: 2),
            // ));
            CustomSnackBar.show(

                message:  "Select a category first",
                type: SnackBarType.error
            );

            return;
          }
          // Create a temporary RxList for dialog
          final tempSelected = <String>[].obs;
          tempSelected.assignAll(selectedIds);

          await showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                  hint,
                  style: fieldHintStyle,
                ),
                content: Obx(() => controller.subCategories.isEmpty?Text("Subcategory not available"):SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        children: items.map((item) {
                          final id = item['id']!;
                          final name = item['name']!;
                          return CheckboxListTile(
                            title: Text(name),
                            value: tempSelected.contains(id),
                            onChanged: (val) {
                              if (val == true) {
                                tempSelected.add(id);
                              } else {
                                tempSelected.remove(id);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    )),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      selectedIds.assignAll(tempSelected);
                      controller.calculateFee(); // update fee
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedIds.isEmpty
                      ? hint
                      : items
                          .where((i) => selectedIds.contains(i['id']))
                          .map((i) => i['name'])
                          .join(", "),
                  style: TextStyle(
                    color: selectedIds.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_sharp,
                  color: AppColors.primaryGreen),
            ],
          ),
        ),
      );
    });
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImageFromCamera(context);
                },
              ),
              Divider(),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: AppColors.primaryGreen),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImagesFromGallery(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
