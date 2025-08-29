import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../models/dispute_model.dart';
import '../../widgets/view_image_screen.dart';

class ViewDispute extends StatelessWidget {
  final DisputeModel dispute;

  const ViewDispute({Key? key, required this.dispute}) : super(key: key);

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
          Expanded(child: Text(value.isNotEmpty ? value : "-",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),)),
        ],
      ),
    );
  }Widget _buildTwoFieldRow({
    required String label1,
    required String value1,
    required String label2,
    required String value2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // First field
          Container(
            width: 200,
            child: Row(
              children: [
                Text(
                  "$label1: ",
                  style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 18),
                ),
                Flexible(
                  child: Text(value1.isNotEmpty ? value1 : "-",style:TextStyle(fontSize: 18),overflow: TextOverflow.ellipsis,),
                ),
              ],
            ),
          ),

          // Second field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4)
            ),
            width: 70,
            child: Row(
              children: [
                Text(
                  "$label2 ",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Flexible(
                  child: Text(value2.isNotEmpty ? value2 : "-"),
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xff228B22),
        ),
        title: const Text('View Dispute'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Dispute Info
            _buildSectionTitle("Dispute Info"),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTwoFieldRow(
                      label1: "Dispute ID",
                      value1: dispute.uniqueId.toString(),
                      label2: "",
                      value2: formatDate(dispute.createdAt),
                    ),
                    //_buildRow("Dispute ID", dispute.uniqueId),
                    _buildRow("Flow Type", dispute.flowType),
                    _buildRow("Amount", dispute.amount.toString()),
                    _buildRow("Status", dispute.status),
                    _buildRow("Description", dispute.description),
                    _buildRow("Requirement", dispute.requirement),
                    SizedBox(height: 4),
                    if (dispute.image.isNotEmpty)
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCarosuleImage(imagePath: dispute.image)));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              dispute.image,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    "assets/images/d_png/no-image.png",
                                    height: 100,
                                    fit: BoxFit.fill,
                                  ),
                            ),

                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 📌 Order Info
            _buildSectionTitle("Order Info"),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("Project ID", dispute.order.projectId),
                    _buildRow("Title", dispute.order.title),
                    _buildRow("Description", dispute.order.description),
                  ],
                ),
              ),
            ),

            // 📌 Raised By User
            _buildSectionTitle("Raised By"),
            _buildUserCard(dispute.raisedBy,true),

            // 📌 Against User
            _buildSectionTitle("Against"),
            _buildUserCard(dispute.against,false),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, bool isServiceProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            child: user.profilePic.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                                user.profilePic,
                                fit: BoxFit.cover,
                                width: 70,
                                height: 70,
                                errorBuilder: (context, error, stackTrace) {
                  return SvgPicture.asset(
                    "assets/svg_images/d_svg/user_icon.svg",
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  );
                                },
                              ),
                )
                : SvgPicture.asset(
              "assets/svg_images/d_svg/user_icon.svg",
              fit: BoxFit.cover,
              width: 60,
              height: 60,
            ),
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone ${user.phone}',textAlign: TextAlign.start,),
              Row(
                spacing: 8,
                children: [
                  Text('Review: ${user.totalReview}'),
                  Text('Rating: ${user.rating}')
                ],
              )
            ],
          ),
        ),

      ),
    );
  }
  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr); // convert String → DateTime
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      String year = date.year.toString();
      return "$day/$month/$year";
    } catch (e) {
      return "-"; // fallback if parsing fails
    }
  }
}
