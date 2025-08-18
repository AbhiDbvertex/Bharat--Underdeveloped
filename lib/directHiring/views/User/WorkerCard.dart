import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/userModel/Worker.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 129,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/images/plumber1.png',
              height: 109,
              width: 108.75,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            worker.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  worker.role,
                  style: GoogleFonts.roboto(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.star_outline, size: 14, color: Colors.green.shade700),
              const SizedBox(width: 2),
              Text(
                worker.rating.toString(),
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
