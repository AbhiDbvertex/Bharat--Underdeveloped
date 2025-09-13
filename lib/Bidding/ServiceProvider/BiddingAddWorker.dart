import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiddingAddWorker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: BiddingAddWorker(),
    );
  }
}

class BiddingAddWorker extends StatelessWidget {
  final List<Map<String, String>> workers = [
    {"name": "Dipak Sharma", "location": "Indore MP", "date": "12/05/25"},
    {"name": "Dipak Sharma", "location": "Indore MP", "date": "12/05/25"},
    {"name": "Dipak Sharma", "location": "Indore MP", "date": "12/05/25"},
    {"name": "Dipak Sharma", "location": "Indore MP", "date": "12/05/25"},
    {"name": "Dipak Sharma", "location": "Indore MP", "date": "12/05/25"},
    {"name": "Dipak Sharma", "location": "Indore MP", "date": "12/05/25"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Worker'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle add worker action
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: workers.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Increased size of the image
                  Image.asset(
                    'assets/images/d_png/no_profile_image.png',
                    height: 100, // Increased height
                    width: 100, // Increased width
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 16), // Added spacing between image and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(workers[index]["name"]!),
                        Row(
                          children: [
                            Flexible(child: Text(workers[index]["location"]!)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                height: 20,
                                width: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.red.shade300,
                                ),
                                child: Center(
                                  child: Text(
                                    workers[index]["date"]!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Moved View and Assign to the end
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "View",
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 25,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.green.shade700,
                        ),
                        child: Center(
                          child: Text(
                            'Assign',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
