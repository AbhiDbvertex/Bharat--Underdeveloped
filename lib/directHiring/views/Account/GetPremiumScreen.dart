import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Add provider package to pubspec.yaml
import '../../../Widgets/AppColors.dart';
import '../../controllers/AccountController/PremiumController.dart';
import '../../models/AccountModel/PremiumModel.dart';
import 'AccountScreen.dart';

class GetPremiumScreen extends StatelessWidget {
  const GetPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PremiumController(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Get Premium Access",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: const BackButton(color: Colors.black),
          actions: [],
          systemOverlayStyle:  SystemUiOverlayStyle(
            statusBarColor: AppColors.primaryGreen,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: PremiumView(),
        ),
      ),
    );
  }
}

class PremiumView extends StatelessWidget {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PremiumController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     GestureDetector(
        //       onTap: () {
        //         Navigator.pop(
        //           context,
        //           MaterialPageRoute(builder: (_) => AccountScreen()),
        //         );
        //       },
        //       child: const Padding(
        //         padding: EdgeInsets.only(left: 8.0),
        //         child: Icon(Icons.arrow_back, size: 25),
        //       ),
        //     ),
        //     const SizedBox(width: 50),
        //     Text(
        //       "Get Premium Access",
        //       style: GoogleFonts.roboto(
        //         fontSize: 18,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.black,
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 70),
        Center(
          child: Text(
            'Premium Plans',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            controller.plans.length,
            (index) => Flexible(
              child: GestureDetector(
                onTap: () {
                  controller.selectPlan(index);
                },
                child: _buildPlanCard(
                  controller.plans[index],
                  controller.selectedPlanIndex == index,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade700, width: 1.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Premium Features',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (controller.selectedPlan != null)
                ...controller.selectedPlan!.features
                    .map((feature) => _buildFeatureItem(feature))
                    .toList()
              else
                _buildFeatureItem('Select a plan to view features'),
              const SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Center(
          child: Container(
            height: 50,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green.shade700,
            ),
            child: Center(
              child: Text(
                'Purchase Plan',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('Not Now', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(PremiumModel plan, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 127,
      height: 145,
      decoration: BoxDecoration(
        gradient: plan.gradient,
        borderRadius: BorderRadius.circular(8.0),
        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              plan.price,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              plan.perMonth,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              plan.duration,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.check_circle, color: Colors.green, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
