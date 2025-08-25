import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widgets/AppColors.dart';
import '../../models/userModel/WorkerListModel.dart';
import 'AddWorkerScreen.dart';
import 'EditWorkerScreen.dart';
import 'ViewWorkerScreen.dart';

class WorkerScreen extends StatefulWidget {
  const WorkerScreen({super.key});

  @override
  State<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  List<WorkerListModel> workers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Future<void> fetchWorkers() async {
  //   final token = await getToken();
  //   if (token == null) {
  //     setState(() => isLoading = false);
  //     return;
  //   }
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         'https://api.thebharatworks.com/api/worker/all',
  //       ), // Updated to correct API
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     print('Abhi:- print get worker response: ${response.body}');
  //     print('Abhi:- print get worker statusCode: ${response.statusCode}');
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['success'] == true) {
  //         final List fetchedWorkers = data['workers'];
  //         setState(() {
  //           workers =
  //               fetchedWorkers
  //                   .map((json) => WorkerListModel.fromJson(json))
  //                   .toList()
  //                 ..sort((a, b) => a.verifyStatus == 'approved' ? -1 : 1);
  //           isLoading = false;
  //         });
  //       } else {
  //         setState(() => isLoading = false);
  //       }
  //     } else {
  //       setState(() => isLoading = false);
  //       if (!context.mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Failed to fetch workers: ${response.statusCode}"),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error fetching workers: $e');
  //     setState(() => isLoading = false);
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Error fetching workers: $e")));
  //   }
  // }
  Future<void> fetchWorkers() async {
    final token = await getToken();
    if (token == null) {
      print("❌ Token not found in local storage");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.thebharatworks.com/api/worker/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Fetch workers response: ${response.body}');
      print('Fetch workers statusCode: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List fetchedWorkers = data['workers'];
          setState(() {
            workers =
            fetchedWorkers
                .map((json) => WorkerListModel.fromJson(json))
                .toList()
              ..sort((a, b) => a.verifyStatus == 'approved' ? -1 : 1);
            isLoading = false;
          });
        } else {
          print("❌ API error: ${data['message']}");
          setState(() => isLoading = false);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("API error: ${data['message']}")),
          );
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        setState(() => isLoading = false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch workers: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      print('❌ Error fetching workers: $e');
      setState(() => isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching workers: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          _buildTopBar(context),
          Expanded(
            child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : workers.isEmpty
                ? const Center(child: Text("No workers found"))
                : _buildWorkerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_outlined, size: 22),
          ),
          const SizedBox(width: 90),
          Text(
            "Worker List",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWorkerScreen()),
              );
              if (result == true) {
                fetchWorkers();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Worker added successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Container(
              height: 27,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Add Worker",
                  style: GoogleFonts.roboto(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerList() {
    return ListView.builder(
      itemCount: workers.length,
      itemBuilder: (context, index) {
        final worker = workers[index];
        final imageUrl =
        worker.image == null || worker.image.isEmpty
            ? 'https://api.thebharatworks.com/uploads/worker/default.jpg'
            : worker.image.startsWith('http')
            ? worker.image.replaceFirst('http://', 'https://')
            : 'https://api.thebharatworks.com${worker.image}';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print(
                        'Error loading image for worker ${worker.name}: $error',
                      );
                      return Image.asset(
                        'assets/images/account1.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        worker.address,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF27773),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          worker.createdAt.substring(0, 10),
                          style: GoogleFonts.roboto(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print(
                          'Navigating to ViewWorkerScreen with workerId: ${worker.id}',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ViewWorkerScreen(workerId: worker.id),
                          ),
                        ).then((_) {
                          print(
                            'Returned from ViewWorkerScreen for workerId: ${worker.id}',
                          );
                        });
                      },
                      child: Text(
                        "View",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    // _actionButton('Edit', Colors.green.shade700, () async {
                    //   final result = await Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (_) => EditWorkerScreen(workerId: worker.id),
                    //     ),
                    //   );
                    //   if (result == true) {
                    //     fetchWorkers();
                    //     if (!context.mounted) return;
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(
                    //         content: Text("Worker updated successfully"),
                    //         backgroundColor: Colors.green,
                    //       ),
                    //     );
                    //   }
                    // }),
                    _actionButton('Edit', Colors.green.shade700, () async {
                      print(
                        'Navigating to EditWorkerScreen with workerId: ${worker.id}',
                      );
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditWorkerScreen(workerId: worker.id),
                        ),
                      );
                      if (result == true) {
                        print(
                          'Refreshing workers after edit for workerId: ${worker.id}',
                        );
                        setState(() {
                          isLoading =
                          true; // Show loading indicator during refresh
                        });
                        await fetchWorkers();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Worker updated successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }),
                    _actionButton('Delete', Colors.green.shade700, () {
                      _confirmDelete(worker.id);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        width: 60,
        height: 30,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String workerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text(
          "Are you sure you want to delete this worker?",
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            height: 40,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
          Container(
            height: 40,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await getToken();
      if (token == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      final response = await http.delete(
        Uri.parse('https://api.thebharatworks.com/api/worker/delete/$workerId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          workers.removeWhere((w) => w.id == workerId);
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Worker deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete worker: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}