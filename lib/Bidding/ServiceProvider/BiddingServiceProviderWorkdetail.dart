import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Widgets/AppColors.dart';

class Biddingserviceproviderworkdetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 20,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.arrow_back, size: 25),
                    ),
                  ),
                  const SizedBox(width: 90),
                  Text(
                    "Work detail",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              // Card(
              //   color: Colors.white,
              //   elevation: 4,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: Padding(
              //     padding: EdgeInsets.all(9.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         CarouselSlider(
              //           options: CarouselOptions(
              //             enlargeCenterPage: true,
              //             autoPlay: true,
              //             viewportFraction: 0.85,
              //           ),
              //           items: [
              //             "assets/images/chair.png",
              //             "assets/images/chair.png",
              //             "assets/images/chair.png",
              //           ]
              //               .map(
              //                 (item) => Container(
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.circular(20),
              //                     image: DecorationImage(
              //                       image: AssetImage(item),
              //                       fit: BoxFit.cover,
              //                     ),
              //                   ),
              //                 ),
              //               )
              //               .toList(),
              //         ),
              //         SizedBox(height: 10),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: [
              //             Container(
              //               padding: EdgeInsets.symmetric(
              //                   horizontal: 10, vertical: 4),
              //               decoration: BoxDecoration(
              //                 color: Colors.orange,
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: Text(
              //                 'Indore M.P.',
              //                 style:
              //                     TextStyle(color: Colors.white, fontSize: 12),
              //               ),
              //             ),
              //           ],
              //         ),
              //         SizedBox(height: 10),
              //         Padding(
              //           padding: EdgeInsets.only(left: 8.0),
              //           child: Text(
              //             'Want to make a table',
              //             style: TextStyle(
              //                 fontSize: 18, fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //         SizedBox(height: 5),
              //         Padding(
              //           padding: EdgeInsets.only(left: 8.0),
              //           child: Text(
              //             'Complete: 25/02/25',
              //             style: TextStyle(fontSize: 14, color: Colors.grey),
              //           ),
              //         ),
              //         SizedBox(height: 10),
              //         Padding(
              //           padding: EdgeInsets.only(left: 8.0),
              //           child: Text(
              //             '₹1,500',
              //             style: TextStyle(
              //                 fontSize: 20,
              //                 color: Colors.green,
              //                 fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //         SizedBox(height: 10),
              //         Padding(
              //           padding: EdgeInsets.only(left: 8.0),
              //           child: Text(
              //             'Task Details',
              //             style: TextStyle(
              //                 fontSize: 16, fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //         SizedBox(height: 5),
              //         Padding(
              //           padding: EdgeInsets.only(left: 8.0),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: List.generate(10, (index) {
              //               return Padding(
              //                 padding: EdgeInsets.only(bottom: 4),
              //                 child: Text(
              //                   '• Lorem ipsum dolor sit amet consectetur.',
              //                   style: TextStyle(fontSize: 14),
              //                 ),
              //               );
              //             }),
              //           ),
              //         ),
              //         SizedBox(height: 20),
              //         Center(
              //           child: GestureDetector(
              //             onTap: () {},
              //             child: Container(
              //               padding: EdgeInsets.symmetric(
              //                   horizontal: 50, vertical: 10),
              //               decoration: BoxDecoration(
              //                 color: Colors.green,
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: Text(
              //                 'Bid',
              //                 style: TextStyle(
              //                     color: Colors.white,
              //                     fontSize: 16,
              //                     fontWeight: FontWeight.bold),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              Card(
                margin:
                    EdgeInsets.zero, // left-right top-bottom ka space hata diya
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          autoPlay: true,
                          viewportFraction: 1, // ✅ full width ke liye
                        ),
                        items: [
                          "assets/images/chair.png",
                          "assets/images/chair.png",
                          "assets/images/chair.png",
                        ]
                            .map(
                              (item) => ClipRRect(
                                // ✅ image ke 4 corner rounded
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  item,
                                  fit: BoxFit.cover,
                                  width: double.infinity, // full width
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Indore M.P.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Want to make a table',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Complete: 25/02/25',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          '₹1,500',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Task Details',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(10, (index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• Lorem ipsum dolor sit amet consectetur.',
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.symmetric(
                                      horizontal: 20), // Controls width
                                  title: Center(
                                      child: Text(
                                    "Bid",
                                    style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                  content: SingleChildScrollView(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8, // 80% of screen width
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Enter Amount",
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  "\$0.00", // No pre-filled value
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8), // 👈 radius 8
                                                borderSide: BorderSide(
                                                  color: Color(
                                                      0xFF777777), // normal border color
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Color(
                                                      0xFF777777), // normal state border
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Colors
                                                      .blue, // focus hone par border color
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Description",
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Enter description here",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF777777),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12), // 👈 radius 8
                                                borderSide: BorderSide(
                                                  color: Color(0xFF777777),
                                                  width:
                                                      1, // optional: border width
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: Color(0xFF777777),
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            maxLines:
                                                3, // Allows multiple lines for description
                                          ),
                                          SizedBox(height: 10),
                                          Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(
                                                    context); // Close the dialog
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 70,
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade700,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  "Bid",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 70, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Bid",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Bidders',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Related Worker',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
