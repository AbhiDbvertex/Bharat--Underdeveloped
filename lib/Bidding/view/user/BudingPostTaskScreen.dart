
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart' as mime;
import '../../../../Widgets/AppColors.dart';
import '../../../directHiring/views/auth/MapPickerScreen.dart';
import '../../controller/bidding_post_task_controller.dart';

class PostTaskScreen extends StatelessWidget {
  const PostTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostTaskController(), permanent: false); // Mark controller as non-permanent
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print("");

    return WillPopScope(
      onWillPop: () async {
        controller.resetForm(); // Reset form before navigating back
        Get.delete<PostTaskController>(); // Delete controller to ensure fresh instance on re-entry
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 20,
          automaticallyImplyLeading: false,
        ),
        body: Obx(
              () => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(context, controller),
                  _buildLabel("Title"),
                  _buildTextField(controller.titleController, "Enter Title of work"),
                  _buildLabel("Category"),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration("Choose category"),
                    value: controller.selectedCategoryId.value,
                    items: controller.categories
                        .map(
                          (cat) => DropdownMenuItem(
                        value: cat['id'],
                        child: Text(cat['name']!),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      controller.selectedCategoryId.value = val;
                      controller.selectedSubCategoryIds.clear();
                      controller.allSubCategories.clear();
                      if (val != null) controller.fetchSubCategories(val);
                    },
                    validator: (val) => val == null ? "Please select a category" : null,
                  ),
                  _buildLabel("Sub Category (Multiple selection)"),
                  _subcategorySelector(controller),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel("Location"),
                      InkWell(
                        onTap: controller.navigateToLocationScreen,
                        child: Container(
                          width: width * 0.35,
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
                  // TextButton(onPressed: (){
                  //   print("Abhi:- print late : ${controller.late} long : ${controller.long}");
                  // }, child: Text("Print data")),
                  TextFormField(
                    enabled: false,
                    controller: controller.addressController,
                    decoration: _inputDecoration(controller.userLocation.value).copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: controller.getCurrentLocation,
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty || val == 'Select Location'
                        ? "Please enter a valid address"
                        : null,
                  ),
                  _buildLabel("Google Address"),
                  _googleLocationField(controller),
                  _buildLabel("Description"),
                  _buildTextField(
                    controller.descriptionController,
                    "Describe your task",
                    maxLines: 4,
                  ),
                  _buildLabel("Cost"),
                  _buildTextField(
                    controller.costController,
                    "Enter cost in INR",
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please enter the cost";
                      }
                      if (double.tryParse(val) == null) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                  ),
                  _buildLabel("Select Deadline"),
                  GestureDetector(
                    onTap: () => controller.selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: controller.dateController,
                        decoration: _inputDecoration("Select Deadline Date", icon: Icons.calendar_today),
                        validator: (val) => val == null || val.isEmpty ? "Please pick a deadline" : null,
                      ),
                    ),
                  ),
                  _buildLabel("Upload Task Image"),
                  _buildImagePicker(controller),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      if (controller.formKey.currentState!.validate()) {
                        if (controller.selectedCategoryId.value == null) {
                          controller.showSnackbar("Error", "Please select a category", context: context);
                          return;
                        }
                        if (controller.selectedSubCategoryIds.isEmpty) {
                          controller.showSnackbar("Error", "Please select at least one sub category", context: context);
                          return;
                        }
                        controller.submitTask(context); // Pass context to submitTask
                        // Get.back();
                      }
                    },
                    child: const Text("Post Task", style: TextStyle(fontSize: 16,color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageHeader(BuildContext context, PostTaskController controller) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            controller.resetForm(); // Reset form before navigating back
            Get.delete<PostTaskController>(); // Delete controller to ensure fresh instance
            Get.back();
          },
          child: const Icon(Icons.arrow_back_outlined, color: Colors.black),
        ),
        const SizedBox(width: 86),
        Text(
          "Post New Task",
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _googleLocationField(PostTaskController controller) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => MapPickerScreen());
        if (result != null && result is String) {
          controller.googleAddressController.text = result;
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller.googleAddressController,
          decoration: _inputDecoration("Location", icon: Icons.my_location),
          validator: (val) => val == null || val.isEmpty ? "Please select a Google address" : null,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 12,
    ),
  );

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(hint),
        validator: validator ?? (val) => val == null || val.isEmpty ? "This field is required" : null,
      );

  Widget _subcategorySelector(PostTaskController controller) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedCategoryId.value != null) {
          controller.showSubcategoryDialog();
        } else {
          controller.showSnackbar("Error", "Please select category first", context: Get.context!);
        }
      },
      child: _buildDropdownTile(controller),
    );
  }

  Widget _buildDropdownTile(PostTaskController controller) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            controller.selectedSubCategoryIds.isEmpty
                ? "Choose sub categories"
                : controller.allSubCategories
                .where((sub) => controller.selectedSubCategoryIds.contains(sub['id']))
                .map((sub) => sub['name'])
                .join(', '),
            style: TextStyle(
              fontSize: 14,
              color: controller.selectedSubCategoryIds.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
        ),
        const Icon(Icons.arrow_drop_down),
      ],
    ),
  );

  Widget _buildImagePicker(PostTaskController controller) {
    return Column(
      children: [
        if (controller.selectedImages.isEmpty)
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 120,
                    width: 270,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload, size: 20, color: Colors.green),
                        Text(
                          "Upload Work Photo",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Upload",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Upload (.png, .jpg, .jpeg) File (300px * 300px)",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...controller.selectedImages.map((img) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      img,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        controller.selectedImages.remove(img);
                      },
                    ),
                  ),
                ],
              )),
              if (controller.selectedImages.length < 5)
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 50, color: Colors.green),
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}