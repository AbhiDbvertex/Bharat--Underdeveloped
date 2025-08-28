
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../controllers/AccountController/dispute_controller.dart';
import '../widgets/dispute_card_widget.dart';

class DisputeScreen extends StatelessWidget {
  DisputeScreen({super.key});
  final disputeCon = Get.put(DisputeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xff228B22),
        ),
        centerTitle: true,
        title: Text('Disputes'),
        backgroundColor: Colors.white,
      ),
      body: Obx(
          () {
            if(disputeCon.disputeList.isEmpty){
              return Center(
                child: Text('Disputes not found'),

              );
            }
            if(disputeCon.disputeList.isNotEmpty){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return DisputeCard(dispute: disputeCon.disputeList[index],);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 16
                      );
                    },
                    itemCount: disputeCon.disputeList.length),
              );
            }else{
              return Center(
                child: Text("Data not found"),
              );
            }

          }

      ),
    );

  }
}
