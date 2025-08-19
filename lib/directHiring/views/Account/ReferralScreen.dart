import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Widgets/AppColors.dart';
import '../../controllers/AccountController/ReferralController.dart';
import '../../models/AccountModel/ReferralModel.dart';
import 'AccountScreen.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReferralController controller = ReferralController();
    final List<ReferralModel> referralList = controller.getReferralList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Top bar with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 90),
                  Text(
                    "Referral",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Image
            SizedBox(
              height: 160,
              child: Image.asset(
                'assets/images/Referral.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "Your Code",
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Only for 5 person", style: GoogleFonts.roboto(fontSize: 10)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              width: MediaQuery.of(context).size.width,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF9DF89D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  controller.referralCode,
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    color: const Color(0xFF929292),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () => controller.copyReferralCode(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 120,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Copy Code",
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 15),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 45,
              width: double.infinity,
              color: const Color(0xFF9DF89D),
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "Referral List",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildTableHeader(),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: referralList.length,
              itemBuilder: (context, index) {
                final entry = referralList[index];
                return _buildReferralRow(index, entry);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "S.No",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Date",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Amount",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralRow(int index, ReferralModel entry) {
    return Column(
      children: [
        Container(
          height: 45,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: const Color(0xFFFFF2F2),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("${index + 1}"),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    entry.date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    entry.amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
