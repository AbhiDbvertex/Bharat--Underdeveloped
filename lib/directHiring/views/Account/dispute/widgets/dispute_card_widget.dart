

import 'package:developer/Emergency/utils/size_ratio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../models/dispute_model.dart';
import '../screens/view_dispute_screen.dart';

class DisputeCard extends StatelessWidget {
  DisputeModel dispute;
  DisputeCard( {super.key,required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(12),
        ),
        width: 0.8.toWidthPercent(),
        child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                        spacing: 4,
                      children: [
                        SvgPicture.asset('assets/svg_images/d_svg/dispte_icon.svg'),
                        Text('Dispute ID: ${dispute.uniqueId}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewDispute(dispute: dispute)));
                      },
                      child: Container(
                        height: 35,
                        width: 0.255.toWidthPercent(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          color: Color(0xff228B22)
                        ),
                        child:  Text("View Dispute",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        SvgPicture.asset('assets/svg_images/d_svg/projecId_icon.svg',),
                        Text('Project ID: ${dispute.order.projectId}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
                      ],
                    ),

                  ],
                ),
                SizedBox(height: 15),
                Row(
                  spacing: 4,
                  children: [
                    SvgPicture.asset('assets/svg_images/d_svg/service_provider_icon.svg',),
                    Text('Service Provider: ${dispute.raisedBy.fullName}',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis),),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                 spacing: 4,
                  children: [
                  SvgPicture.asset('assets/svg_images/d_svg/user_icon.svg',),
                    Text("User Name: ${dispute.against.fullName}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis),)
                  ],
                ),
              ],
            )
        ),
      ),
    );
  }
}
