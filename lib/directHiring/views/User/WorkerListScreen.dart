
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/userModel/subCategoriesModel.dart';
import 'HireScreen.dart';
import 'UserViewWorkerDetails.dart';

class WorkerlistScreen extends StatefulWidget {
  final dynamic categreyId;
  final dynamic subcategreyId;
  final List<ServiceProviderModel> providers;

  const WorkerlistScreen({
    Key? key,
    required this.providers,
    this.categreyId,
    this.subcategreyId,
  }) : super(key: key);

  @override
  State<WorkerlistScreen> createState() => _WorkerlistScreenState();
}

class _WorkerlistScreenState extends State<WorkerlistScreen> {
  late List<ServiceProviderModel> providerslist;
  late List<ServiceProviderModel> filteredProviders; // New filtered list
  bool _hasNavigated = false;
  final TextEditingController _searchController = TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    providerslist = List.from(widget.providers);
    filteredProviders = List.from(providerslist); // Initialize filtered list
    print("📋 Providers: ${providerslist.length}");
    for (var provider in providerslist) {
      print(
        "📋 Worker: ${provider.fullName}, profilePic: ${provider.profilePic}",
      );
    }

    if (providerslist.isEmpty && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print("No providers found, navigating to categoryScreen");
        Navigator.pushReplacementNamed(context, '/categoryScreen');
      });
    }

    // Add listener to search input
    _searchController.addListener(() {
      _filterProviders();
    });
  }

  // Function to filter providers based on search query
  void _filterProviders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProviders = providerslist.where((worker) {
        final name = worker.fullName?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller to prevent memory leaks
    super.dispose();
  }

  String? getImageUrl(ServiceProviderModel worker) {
    print(
      "📷 Worker: ${worker.fullName}, ProfilePic: ${worker.profilePic}, HisWork: ${worker.hisWork}",
    );

    if (worker.profilePic != null && worker.profilePic!.isNotEmpty) {
      final profilePath = worker.profilePic!.replaceAll("\\", "/");
      if (profilePath.startsWith('http')) {
        print("📷 Using profile pic: $profilePath");
        return profilePath;
      }
      final url = "https://api.thebharatworks.com/$profilePath";
      print("📷 Constructed profile pic: $url");
      return url;
    }
    if (worker.hisWork != null && worker.hisWork.isNotEmpty) {
      final workPath = worker.hisWork.first.replaceAll("\\", "/");
      if (workPath.startsWith('http')) {
        print("📷 Using work image: $workPath");
        return workPath;
      }
      final url = "https://api.thebharatworks.com/$workPath";
      print("📷 Constructed work image: $url");
      return url;
    }
    print("📷 No image for worker: ${worker.fullName}");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismisses the keyboard
        },
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 10,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_outlined, size: 22),
                ),
                const SizedBox(width: 90),
                Text(
                  "Direct hire",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Image.asset('assets/images/filter.png'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Image.asset('assets/images/search1.png', height: 20, width: 20),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search for services..",
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF616161),
                      ),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: const Color(0xFF616161),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProviders.isEmpty
                ? Center(
              child: Text(
                "No Worker Available",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filteredProviders.length, // Use filtered list
              itemBuilder: (context, index) {
                final worker = filteredProviders[index]; // Use filtered list
                final imageUrl = getImageUrl(worker);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          headers: worker.currentToken != null
                              ? {
                            'Authorization':
                            'Bearer ${worker.currentToken}',
                          }
                              : null,
                          errorBuilder: (
                              context,
                              error,
                              stackTrace,
                              ) {
                            print(
                              "📷 Image load failed: $imageUrl, Error: $error",
                            );
                            return Image.asset(
                              "assets/images/account1.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : Image.asset(
                          "assets/images/account1.png",
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    worker.fullName ?? "Unknown",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      worker.rating.toStringAsFixed(1),
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.yellow,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              "\u20B9200.00",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    worker.skill ?? "No skill info",
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (worker.id != null &&
                                        worker.id!.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UserViewWorkerDetails(
                                                workerId: worker.id!,
                                                categreyId: widget.categreyId,
                                                subcategreyId:
                                                widget.subcategreyId,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "View Profile",
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: height * 0.03,
                                  width: width * 0.32,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 35,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF27773),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      worker.location?['address'] ??
                                          "No address",
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final hiredId = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HireScreen(
                                          firstProviderId:
                                          worker.id ?? '',
                                          categreyId: widget.categreyId,
                                          subcategreyId:
                                          widget.subcategreyId,
                                        ),
                                      ),
                                    );
                                    if (hiredId != null) {
                                      final prefs =
                                      await SharedPreferences
                                          .getInstance();
                                      List<String> hiredProviders =
                                          prefs.getStringList(
                                            'hiredProviders',
                                          ) ??
                                              [];
                                      if (!hiredProviders
                                          .contains(hiredId)) {
                                        hiredProviders.add(hiredId);
                                        await prefs.setStringList(
                                          'hiredProviders',
                                          hiredProviders,
                                        );
                                      }
                                      setState(() {
                                        providerslist.removeWhere(
                                                (e) => e.id == hiredId);
                                        filteredProviders.removeWhere(
                                                (e) => e.id == hiredId);
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.green.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    minimumSize: const Size(60, 28),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    "Hire",
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: Colors.white,
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
        ],
      ),
    )
    );
  }
}
