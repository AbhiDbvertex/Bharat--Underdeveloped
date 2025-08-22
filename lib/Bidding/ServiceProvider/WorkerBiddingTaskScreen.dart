// // import 'package:developer/Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
// // import 'package:flutter/material.dart';
// //
// // class WorkerbiddingtaskScreen extends StatefulWidget {
// //   @override
// //   _WorkerbiddingtaskScreenState createState() =>
// //       _WorkerbiddingtaskScreenState();
// // }
// //
// // class _WorkerbiddingtaskScreenState extends State<WorkerbiddingtaskScreen> {
// //   final List<Map<String, dynamic>> items = [
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Cancelled",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Accepted",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Completed",
// //     },
// //     {
// //       "title": "Make a chair",
// //       "price": "₹1,500",
// //       "desc": "Lorem ipsum dolor ...",
// //       "view": "View Details",
// //       "date": "21/02/25",
// //       "status": "Review",
// //     },
// //   ];
// //
// //   List<Map<String, dynamic>> filteredItems = [];
// //   TextEditingController _searchController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     filteredItems = items;
// //   }
// //
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   Color getStatusColor(String status) {
// //     switch (status) {
// //       case "Cancelled":
// //         return Colors.red;
// //       case "Accepted":
// //         return Colors.green;
// //       case "Completed":
// //         return Colors.green.shade800;
// //       case "Review":
// //         return Colors.brown;
// //       default:
// //         return Colors.transparent;
// //     }
// //   }
// //
// //   void _filterItems(String query) {
// //     setState(() {
// //       if (query.isEmpty) {
// //         filteredItems = items; // Agar query khali hai, toh saari items dikhaye
// //       } else {
// //         filteredItems = items.where((item) {
// //           final title = item["title"].toString().toLowerCase();
// //           final desc = item["desc"].toString().toLowerCase();
// //           return title.contains(query.toLowerCase()) ||
// //               desc.contains(query.toLowerCase());
// //         }).toList();
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // appBar: AppBar(
// //       //   backgroundColor: AppColors.primaryGreen,
// //       //   centerTitle: true,
// //       //   elevation: 0,
// //       //   toolbarHeight: 20,
// //       //   automaticallyImplyLeading: false,
// //       // ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             SizedBox(height: 20),
// //             // Row(
// //             //   children: [
// //             //     GestureDetector(
// //             //       onTap: () => Navigator.pop(context),
// //             //       child: const Padding(
// //             //         padding: EdgeInsets.only(left: 8.0),
// //             //         child: Icon(Icons.arrow_back, size: 25),
// //             //       ),
// //             //     ),
// //             //     const SizedBox(width: 50),
// //             //     // Text(
// //             //     //   "Recent Posted work",
// //             //     //   style: GoogleFonts.roboto(
// //             //     //     fontSize: 18,
// //             //     //     fontWeight: FontWeight.bold,
// //             //     //     color: Colors.black,
// //             //     //   ),
// //             //     // ),
// //             //     // SizedBox(width: 50),
// //             //     // Image.asset("assets/images/vec1.png"),
// //             //   ],
// //             // ),
// //             SizedBox(height: 10),
// //             Card(
// //               child: Container(
// //                 height: 50,
// //                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(10),
// //                   color: Colors.white,
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(Icons.search_rounded, color: Colors.grey),
// //                     SizedBox(width: 10),
// //                     Expanded(
// //                       child: TextField(
// //                         controller: _searchController,
// //                         decoration: InputDecoration(
// //                           hintText: 'Search for services',
// //                           hintStyle: TextStyle(color: Colors.grey),
// //                           border: InputBorder.none,
// //                         ),
// //                         onChanged: (value) {
// //                           _filterItems(value); // Har type par filter karo
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: 10),
// //             Column(
// //               children: filteredItems.asMap().entries.map((entry) {
// //                 var index = entry.key;
// //                 var item = entry.value;
// //                 return Card(
// //                   color: Colors.white,
// //                   margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
// //                   elevation: 4,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10),
// //                     side: BorderSide(
// //                       color: Colors.green,
// //                       width: 1.0,
// //                     ),
// //                   ),
// //                   child: Padding(
// //                     padding: EdgeInsets.all(8.0),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         ClipRRect(
// //                           borderRadius: BorderRadius.circular(10),
// //                           child: Image.asset(
// //                             "assets/images/chair.png",
// //                             width: 100,
// //                             height: 100,
// //                             fit: BoxFit.cover,
// //                           ),
// //                         ),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 item["title"],
// //                                 style: TextStyle(
// //                                   fontSize: 18,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               Text(
// //                                 item["price"],
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   color: Colors.green,
// //                                 ),
// //                               ),
// //                               Row(
// //                                 children: [
// //                                   Expanded(
// //                                     child: Padding(
// //                                       padding: const EdgeInsets.only(top: 12.0),
// //                                       child: Text(item["desc"]),
// //                                     ),
// //                                   ),
// //                                   if (item["status"] != "")
// //                                     SizedBox(
// //                                       width: 80,
// //                                       height: 30,
// //                                       child: Container(
// //                                         decoration: BoxDecoration(
// //                                           color: getStatusColor(item["status"]),
// //                                           borderRadius:
// //                                               BorderRadius.circular(8),
// //                                         ),
// //                                         child: Center(
// //                                           child: Text(
// //                                             item["status"],
// //                                             style: TextStyle(
// //                                               color: Colors.white,
// //                                               fontSize: 12,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                 ],
// //                               ),
// //                               Row(
// //                                 children: [
// //                                   Text(
// //                                     "Date: ${item["date"]}",
// //                                     style: TextStyle(fontSize: 14),
// //                                   ),
// //                                   SizedBox(width: 54),
// //                                   GestureDetector(
// //                                     onTap: () {
// //                                       Navigator.push(
// //                                         context,
// //                                         MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               Biddingserviceproviderworkdetail(),
// //                                         ),
// //                                       );
// //                                     },
// //                                     child: Padding(
// //                                       padding: const EdgeInsets.only(top: 8.0),
// //                                       child: SizedBox(
// //                                         width: 80,
// //                                         height: 30,
// //                                         child: Container(
// //                                           decoration: BoxDecoration(
// //                                             color: Colors.green,
// //                                             borderRadius:
// //                                                 BorderRadius.circular(8),
// //                                           ),
// //                                           child: Center(
// //                                             child: Text(
// //                                               "View Details",
// //                                               style: TextStyle(
// //                                                 color: Colors.white,
// //                                                 fontSize: 12,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:developer/Bidding/ServiceProvider/BiddingServiceProviderWorkdetail.dart';
// import 'package:flutter/material.dart';
//
// class WorkerbiddingtaskScreen extends StatefulWidget {
//   @override
//   _WorkerbiddingtaskScreenState createState() =>
//       _WorkerbiddingtaskScreenState();
// }
//
// class _WorkerbiddingtaskScreenState extends State<WorkerbiddingtaskScreen> {
//   final List<Map<String, dynamic>> items = [
//     {
//       "title": "Make a chair",
//       "price": "₹1,500",
//       "desc": "Lorem ipsum dolor ...",
//       "view": "View Details",
//       "date": "21/02/25",
//       "status": "",
//     },
//     {
//       "title": "Make a chair",
//       "price": "₹1,500",
//       "desc": "Lorem ipsum dolor ...",
//       "view": "View Details",
//       "date": "21/02/25",
//       "status": "Cancelled",
//     },
//     {
//       "title": "Make a chair",
//       "price": "₹1,500",
//       "desc": "Lorem ipsum dolor ...",
//       "view": "View Details",
//       "date": "21/02/25",
//       "status": "Accepted",
//     },
//     {
//       "title": "Make a chair",
//       "price": "₹1,500",
//       "desc": "Lorem ipsum dolor ...",
//       "view": "View Details",
//       "date": "21/02/25",
//       "status": "Completed",
//     },
//     {
//       "title": "Make a chair",
//       "price": "₹1,500",
//       "desc": "Lorem ipsum dolor ...",
//       "view": "View Details",
//       "date": "21/02/25",
//       "status": "Review",
//     },
//   ];
//
//   List<Map<String, dynamic>> filteredItems = [];
//   TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     filteredItems = items;
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Color getStatusColor(String status) {
//     switch (status) {
//       case "Cancelled":
//         return Colors.red;
//       case "Accepted":
//         return Colors.green;
//       case "Completed":
//         return Colors.green.shade800;
//       case "Review":
//         return Colors.brown;
//       default:
//         return Colors.transparent;
//     }
//   }
//
//   void _filterItems(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredItems = items;
//       } else {
//         filteredItems = items.where((item) {
//           final title = item["title"].toString().toLowerCase();
//           final desc = item["desc"].toString().toLowerCase();
//           return title.contains(query.toLowerCase()) ||
//               desc.contains(query.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 20),
//             Card(
//               child: Container(
//                 height: 50,
//                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.white,
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.search_rounded, color: Colors.grey),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search for services',
//                           hintStyle: TextStyle(color: Colors.grey),
//                           border: InputBorder.none,
//                         ),
//                         onChanged: (value) {
//                           _filterItems(value);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             SizedBox(
//               height: MediaQuery.of(context).size.height -
//                   100, // Adjust height as needed
//               child: ListView.builder(
//                 itemCount: filteredItems.length,
//                 itemBuilder: (context, index) {
//                   var item = filteredItems[index];
//                   return Card(
//                     color: Colors.white,
//                     margin:
//                         EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       side: BorderSide(
//                         color: Colors.green,
//                         width: 1.0,
//                       ),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.asset(
//                               "assets/images/chair.png",
//                               width: 100,
//                               height: 100,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item["title"],
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   item["price"],
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Padding(
//                                         padding:
//                                             const EdgeInsets.only(top: 12.0),
//                                         child: Text(item["desc"]),
//                                       ),
//                                     ),
//                                     if (item["status"] != "")
//                                       SizedBox(
//                                         width: 80,
//                                         height: 30,
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             color:
//                                                 getStatusColor(item["status"]),
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               item["status"],
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       "Date: ${item["date"]}",
//                                       style: TextStyle(fontSize: 14),
//                                     ),
//                                     SizedBox(width: 54),
//                                     GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 Biddingserviceproviderworkdetail(
//                                               orderId: '',
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: Padding(
//                                         padding:
//                                             const EdgeInsets.only(top: 8.0),
//                                         child: SizedBox(
//                                           width: 80,
//                                           height: 30,
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               color: Colors.green,
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 "View Details",
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class BiddingTaskViewDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Work detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://via.placeholder.com/300x200'), // Replace with actual image URL
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Task Info
              Text('#work223', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Want to make a table',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('₹1,000', style: TextStyle(color: Colors.green)),
              SizedBox(height: 8),
              Text(
                'Lorem ipsum dolor sit amet consectetur. Lorem ipsum dolor sit amet consectetur. Lorem ipsum dolor sit amet consectetur...',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),

              // Worker Details
              Text('Worker Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/60'), // Replace with worker image URL
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deepak Sharma',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Bid amount: ₹45,000',
                          style: TextStyle(color: Colors.green)),
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Payment Details
              Text('Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ListTile(
                title: Text('Starting Payment'),
                trailing: Text('₹20,000'),
              ),
              ListTile(
                title: Text('Mid Payment'),
                trailing: Text('₹20,000'),
              ),
              SizedBox(height: 16),

              // Assign Button
              ElevatedButton(
                onPressed: () {},
                child: Text('Assign to another person'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 8),

              // Warning Message
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.yellow[100],
                child: Text(
                  'Lorem ipsum dolor sit amet consectetur.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(height: 16),

              // Cancel Button
              ElevatedButton(
                onPressed: () {},
                child: Text('Cancel Task and create dispute'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BiddingTaskViewDetailsScreen(),
  ));
}
