import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import '../../data/history_api.dart';

import '../widgets/driver_filter.dart';
import '../widgets/driver_table.dart';
import '../widgets/driver_carousel.dart';

class HistoryDriverUserPage extends StatefulWidget {
  const HistoryDriverUserPage({super.key});

  @override
  State<HistoryDriverUserPage> createState() => _HistoryDriverUserPageState();
}

class _HistoryDriverUserPageState extends State<HistoryDriverUserPage> {
  final HistoryApi api = HistoryApi();

  List<Driver> allDrivers = [];
  List<Driver> displayedDrivers = [];
  List<Driver> newestDrivers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  // FETCH DRIVERS
  Future<void> fetchDrivers() async {
    setState(() => isLoading = true);

    try {
      final drivers = await api.fetchDrivers();

      // Dapatin 3 driver terbaru berdasarkan ID nya
      final newest = List<Driver>.from(drivers)
        ..sort((a, b) => b.id.compareTo(a.id));

      setState(() {
        allDrivers = drivers;
        displayedDrivers = drivers;
        newestDrivers = newest.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetch drivers (user): $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // Reset filter --> tampilin semua nya kembali
  void resetFilter() {
    setState(() {
      displayedDrivers = List.from(allDrivers);
    });
  }

  // BUILD UI nyaa
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Driver History", style: TextStyle(color: Colors.white)),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // === Title ===
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Driver History Overview",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // === Carousel ===
                  DriverCarousel(drivers: newestDrivers),

                  const SizedBox(height: 20),

                  // === Filter ===
                  DriverFilter(
                    allDrivers: allDrivers,
                    onChanged: (filtered) {
                      setState(() => displayedDrivers = filtered);
                    },
                    onReset: resetFilter,
                  ),

                  const SizedBox(height: 20),

                  // === Table User ===
                  DriverTable(
                    drivers: displayedDrivers,
                    isAdmin: false,
                  ),
                ],
              ),
            ),
    );
  }
}
