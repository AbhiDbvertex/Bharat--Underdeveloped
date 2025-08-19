import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeeAllScreen extends StatelessWidget {
  const SeeAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Categories'),
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 5,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20,
          children: List.generate(20, (index) {
            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/Row22.png', // Replace with actual icons if needed
                  width: 18,
                  height: 18,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}





