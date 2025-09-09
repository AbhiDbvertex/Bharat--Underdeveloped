import 'package:developer/Emergency/Service_Provider/controllers/sp_emergency_service_controller.dart';
import 'package:developer/Emergency/Service_Provider/models/sp_emergency_list_model.dart';
import 'package:developer/Emergency/Service_Provider/Screens/sp_work_detail.dart';
import 'package:developer/Emergency/utils/map_launcher_lat_long.dart';
import 'package:developer/Widgets/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SpEmergencyWorkPage extends StatefulWidget {
  @override
  _SpEmergencyWorkPageState createState() => _SpEmergencyWorkPageState();
}

class _SpEmergencyWorkPageState extends State<SpEmergencyWorkPage> {
  final SpEmergencyServiceController controller = Get.find<SpEmergencyServiceController>();
  final TextEditingController _searchController = TextEditingController();
  List<SpEmergencyOrderData> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    // Fetch orders if not already loaded
    if (controller.orders.isEmpty) {
      controller.getEmergencySpOrderList();
    }
    // Initialize filteredOrders with all orders
    filteredOrders = controller.orders;
    // Add listener for search filtering
    _searchController.addListener(() {
      _filterOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredOrders = controller.orders;
      } else {
        filteredOrders = controller.orders.where((order) {
          final categoryName = order.categoryId.name.toLowerCase() ?? '';
          final subCategoryName = order.subCategoryIds.isNotEmpty
              ? order.subCategoryIds.first.name.toLowerCase() ?? ''
              : '';
          final address = order.googleAddress.toLowerCase();
          return categoryName.contains(query) ||
              subCategoryName.contains(query) ||
              address.contains(query);
        }).toList();
      }
    });
  }

  // Color _getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'cancelled':
  //     case 'cancelleddispute':
  //       return Colors.red;
  //     case 'accepted':
  //       return Colors.green;
  //     case 'completed':
  //       return Colors.green;
  //     case 'pending':
  //       return Colors.orange;
  //     case 'rejected':
  //       return Colors.red;
  //     case 'review':
  //       return Colors.brown;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  TextStyle _cardTitle({required double fontSize}) =>
      GoogleFonts.roboto(fontSize: fontSize, fontWeight: FontWeight.bold);

  TextStyle _cardBody({required double fontSize}) =>
      GoogleFonts.roboto(fontSize: fontSize);

  TextStyle _cardDate({required double fontSize}) =>
      GoogleFonts.roboto(fontSize: fontSize, color: Colors.grey[700]);

  Widget _buildEmergencyCard(SpEmergencyOrderData data) {
  //  String displayStatus = data.hireStatus ?? "pending";

    // Check last accepted status
    // if (data.acceptedByProviders != null &&
    //     data.acceptedByProviders.isNotEmpty &&
    //     displayStatus != 'cancelled' &&
    //     displayStatus != 'completed') {
    //   displayStatus = data.acceptedByProviders.last.status ?? displayStatus;
    // }

    // Image check
    final bool hasImage = data.imageUrls != null && data.imageUrls.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 15, right: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                hasImage
                    ? Image.network(
                  data.imageUrls.first,
                  height: 150,
                  width: 110,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      width: 110,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                        strokeWidth: 2.5,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/task.png',
                    height: 150,
                    width: 110,
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  'assets/images/task.png',
                  height: 150,
                  width: 110,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      "${data.projectId ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.categoryId.name ?? "",
                  style: _cardTitle(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "₹${data.servicePayment.amount ?? 0}",
                  style: _cardBody(fontSize: 13).copyWith(
                      color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.subCategoryIds.isNotEmpty
                            ? data.subCategoryIds.take(2).map((e) => e.name).join(", ")
                            : "",
                        style: _cardDate(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => SpWorkDetail(
                    //           data.id,
                    //           isUser: true,
                    //         ),
                    //       ),
                    //     ).then((_) async {
                    //       await controller.getEmergencySpOrderList();
                    //       setState(() {
                    //         filteredOrders = controller.orders;
                    //       });
                    //     });
                    //   },
                    //   style: TextButton.styleFrom(
                    //     backgroundColor: Color(0xff353026),
                    //     minimumSize: const Size(70, 20),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: Text(
                    //     "Review",
                    //     style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                    //   ),
                    // ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${data.deadline != null ?  DateFormat('dd/MM/yyyy').format(DateTime.parse(data.deadline).toLocal()) : 'N/A'}",
                        style: _cardDate(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    //   decoration: BoxDecoration(
                    //     color: _getStatusColor(displayStatus),
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Text(
                    //     "${displayStatus[0].toUpperCase()}${displayStatus.substring(1)}",
                    //     style: GoogleFonts.roboto(
                    //       color: Colors.white,
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // MapLauncher.openMap(address: data.googleAddress);
                          MapLauncher.openMap(latitude: data.latitude,longitude: data.longitude,address: data.googleAddress);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xffF27773),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            data.googleAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpWorkDetail(
                              data.id,
                              isUser: false,
                            ),
                          ),
                        ).then((_) async {
                          await controller.getEmergencySpOrderList();
                          setState(() {
                            filteredOrders = controller.orders;
                          });
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: const Size(70, 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Emergency",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SvgPicture.asset('assets/svg_images/Vector1.svg'),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryGreen,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Container(
              width: screenWidth * 0.95,
              height: screenHeight * 0.07,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.010,
                vertical: screenHeight * 0.015,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: Colors.grey, size: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for emergency tasks',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.04),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (filteredOrders.isEmpty) {
                return const Center(child: Text("No Emergency Tasks Found"));
              }
              return ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  return _buildEmergencyCard(filteredOrders[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}