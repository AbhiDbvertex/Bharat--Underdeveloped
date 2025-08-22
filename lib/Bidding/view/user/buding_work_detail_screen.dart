import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Widgets/AppColors.dart';

class BiddingWorkerDetailScreen extends StatefulWidget {
  const BiddingWorkerDetailScreen({super.key});

  @override
  State<BiddingWorkerDetailScreen> createState() =>
      _BiddingWorkerDetailScreenState();
}

class _BiddingWorkerDetailScreenState extends State<BiddingWorkerDetailScreen> {
  bool isBiddersClicked = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: SafeArea(
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(width * 0.05),
              topRight: Radius.circular(width * 0.05),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Icon(Icons.arrow_back_outlined, size: 22),
                      ),
                    ),
                    const SizedBox(width: 90),
                    Text(
                      'Worker details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),

                CarouselSlider(
                  options: CarouselOptions(
                    height: height * 0.25,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    viewportFraction: 0.85,
                  ),
                  items:
                  [
                    "assets/images/Bid.png",
                    "assets/images/Bid.png",
                    "assets/images/Bid.png",
                  ]
                      .map(
                        (item) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(item),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),

                // Container(
                //   height: height * 0.25,
                //   width: width,
                //   decoration: BoxDecoration(
                //     image: const DecorationImage(
                //       image: AssetImage("assets/images/Bid.png"),
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
                SizedBox(height: height * 0.015),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.025,
                        width: MediaQuery.of(context).size.width * 0.28,
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Indore M.P.",
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize:
                              MediaQuery.of(context).size.width * 0.03,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      const Text(
                        "Chhawni Indore M.P.\nWant to make a table",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: height * 0.002),
                      Text(
                        "Complete - 25/12/15",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        "₹1,500",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Task Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 8,
                        itemBuilder:
                            (context, index) => Row(
                          children: [
                            const Icon(Icons.circle, size: 6),
                            SizedBox(width: width * 0.02),
                            Expanded(
                              child: Text(
                                "Lorem ipsum dolor sit amet consectetur...",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              height: height * 0.045,
                              width: width * 0.40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green.shade700,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/edit21.png"),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.05),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              height: height * 0.045,
                              width: width * 0.40,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/close.png"),
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      "Cancel Task",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.015),


                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                isBiddersClicked = true; // Bidders tab select
                              });
                            },
                            child: Container(
                              height: height * 0.045,
                              width: width * 0.40,
                              decoration: BoxDecoration(
                                color:
                                isBiddersClicked
                                    ? Colors.green.shade700
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      "Bidders",
                                      style: TextStyle(
                                        color:
                                        isBiddersClicked
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontSize: width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.0),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isBiddersClicked =
                                false; // Related Worker tab select
                              });
                            },
                            child: Container(
                              height: height * 0.045,
                              width: width * 0.40,
                              decoration: BoxDecoration(
                                color:
                                !isBiddersClicked
                                    ? Colors.green.shade700
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: width * 0.02),
                                    Text(
                                      "Related Worker",
                                      style: TextStyle(
                                        color:
                                        !isBiddersClicked
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isBiddersClicked)
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.01),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: height * 0.01,
                                  horizontal: width * 0.01,
                                ),
                                padding: EdgeInsets.all(width * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        "assets/images/account1.png",
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  "Dipak Sharma",
                                                  style: TextStyle(
                                                    fontSize: width * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "4.5",
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: width * 0.04,
                                                    color:
                                                    Colors.yellow.shade700,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "₹2000.00",
                                                style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.10),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 13,
                                                          backgroundColor:
                                                          Colors
                                                              .grey
                                                              .shade300,
                                                          child: Icon(
                                                            Icons.phone,
                                                            size: 18,
                                                            color:
                                                            Colors
                                                                .green
                                                                .shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: height * 0.005),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  height: 22,
                                                  constraints: BoxConstraints(
                                                    maxWidth: width * 0.25,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade300,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Indore M.P.",
                                                      style: TextStyle(
                                                        fontSize: width * 0.033,
                                                        color: Colors.white,
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: width * 0.03),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                  Colors.grey.shade300,
                                                  child: Icon(
                                                    Icons.message,
                                                    size: 18,
                                                    color:
                                                    Colors.green.shade600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () {},
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size(0, 25),
                                                  tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                                ),
                                                child: Text(
                                                  "View Profile",
                                                  style: TextStyle(
                                                    fontSize: width * 0.032,
                                                    color:
                                                    Colors.green.shade700,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 32,
                                                  constraints: BoxConstraints(
                                                    maxWidth: width * 0.2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                    Colors.green.shade700,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                        fontSize: width * 0.032,
                                                        color: Colors.white,
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
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
                            },
                          ),
                        ),
                      if (!isBiddersClicked)
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.01),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 2, // Example: 2 workers
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: height * 0.01,
                                  horizontal: width * 0.01,
                                ),
                                padding: EdgeInsets.all(width * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        "assets/images/account1.png", // Different image for Related Worker
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  "Rahul Verma", // Different name
                                                  style: TextStyle(
                                                    fontSize: width * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "4.8", // Different rating
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    size: width * 0.04,
                                                    color:
                                                    Colors.yellow.shade700,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "₹2500.00", // Different price
                                                style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: width * 0.10),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 13,
                                                          backgroundColor:
                                                          Colors
                                                              .grey
                                                              .shade300,
                                                          child: Icon(
                                                            Icons.phone,
                                                            size: 18,
                                                            color:
                                                            Colors
                                                                .green
                                                                .shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: height * 0.005),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  height: 22,
                                                  constraints: BoxConstraints(
                                                    maxWidth: width * 0.25,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade300,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Bhopal M.P.", // Different location
                                                      style: TextStyle(
                                                        fontSize: width * 0.033,
                                                        color: Colors.white,
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: width * 0.03),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                  Colors.grey.shade300,
                                                  child: Icon(
                                                    Icons.message,
                                                    size: 18,
                                                    color:
                                                    Colors.green.shade600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () {},
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size(0, 25),
                                                  tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                                ),
                                                child: Text(
                                                  "View Profile",
                                                  style: TextStyle(
                                                    fontSize: width * 0.032,
                                                    color:
                                                    Colors.green.shade700,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  height: 32,
                                                  constraints: BoxConstraints(
                                                    maxWidth: width * 0.2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                    Colors.green.shade700,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Accept",
                                                      style: TextStyle(
                                                        fontSize: width * 0.032,
                                                        color: Colors.white,
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
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
                            },
                          ),
                        ),
                      SizedBox(height: height * 0.02),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Container(
                    height: height * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search for services",
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: height * 0.015,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
                Column(
                  children: [
                    Center(child: Image.asset("assets/images/bidder.png")),
                  ],
                ),
                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}