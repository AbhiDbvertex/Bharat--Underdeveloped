import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Service_Provider/models/sp_review_model.dart';

class SpReviewScreen extends StatelessWidget {
  final List<SpReviewModel> reviews;

  const SpReviewScreen({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text("Review"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _buildReviewCard(review);
        },
      ),
    );
  }

  Widget _buildReviewCard(SpReviewModel review) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // rating stars
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 6),

            Text(
              review.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            Text(
              review.description,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),

            Text(
              review.date,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),

            Row(
              children: review.images.map((url) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    )
                  ),
                );
              }).toList(),
            ),

            // const SizedBox(height: 12),
            // ElevatedButton(
            //   onPressed: () {},
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.green,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   child: const Text("Collaborate Work"),
            // ),
          ],
        ),
      ),
    );
  }
}
